public with sharing class LicenseRuleValidator extends RuleValidator{
    
    private static final Set<String> WILD_CARD_OPERATORS = new Set<String> {
    	'starts with',
    	'contains',
    	'does not contain'
    };
    
    private static final Set<String> COLLECTION_OPERATORS = new Set<String> {
    	'in',
    	'not in'
    };
    
    
    public LicenseRuleValidator(LicenseRuleHelper ruleHelper) {
    	super(ruleHelper);
    }
    
    public void validate(licensingplus__License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	if (rule.recordTypeId == LicenseRuleHelper.regularFilterRuleRecordTypeId) {
    		validateRegularFilterRule(rule, objFieldsByName);
    	} else if (rule.recordTypeId == LicenseRuleHelper.licenseFilterRuleRecordTypeId) {
    		validateLicenseFilterRule(rule, objFieldsByName);
    	} else if (rule.recordTypeId == LicenseRuleHelper.licenseComparisonRuleRecordTypeId) {
    		validateLicenseComparisonRule(rule, objFieldsByName);
    	}	
    }
    
    private void validateFilterRule(licensingplus__License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName, Boolean isRegularFilterRule) {
    	String objName = isRegularFilterRule ? rule.licensingplus__object__c : 'licensingplus__License__c';
    	String operator = rule.licensingplus__operator__c;
    	String fieldName = isRegularFilterRule ? rule.licensingplus__field__c : rule.licensingplus__license_field__c;
    	String fieldValue = rule.licensingplus__value__c;
    	  			
		// do not validate 'not blank' operator
		if (operator == 'not blank') {
			return;
		}
    	
    	//validate sobject and field is defined
    	Schema.SobjectField objField = ruleHelper.validateAndGetSObjectField(objName, null, fieldName, objFieldsByName);		
		Schema.DescribeFieldResult f = objField.getDescribe();
		
		//validate operator matches field type
		String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.OPERATOR_NOT_MATCH_FIELD_TYPE);
		if (!validateOperatorFieldType(operator, f.getType())) {			
			throw new LicenseRuleException(String.format(errorMessage, new String[]{operator, fieldName, objName, ''}));
		}
		
		errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.FIELD_VALUE_NOT_MATCH_FIELD_TYPE);
		//validate field value matches field type
		if (SObjectUtils.isBooleanType(f.getType())) {
			if (!validateBooleanField(fieldValue)) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldValue, 'Boolean', fieldName, objName}));
			}
		} else if (SObjectUtils.isNumberType(f.getType())) {
			if (!validateNumberField(fieldValue)) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldValue, 'Number', fieldName, objName}));
			}
		} else if (SObjectUtils.isDateType(f.getType())) {
			if (!validateDateField(fieldValue)) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldValue, 'Date', fieldName, objName}));
			}
		} else if (SObjectUtils.isDatetimeType(f.getType())) {
			if (!validateDatetimeField(fieldValue)) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldValue, 'Datetime', fieldName, objName}));
			}
		}		
    }
    
    private boolean validateBooleanField(String value) {
    	Boolean result = true;   	
    	if (value != 'true' && value != 'false') {
    		LicenseRuleHelper.logInfo('LicenseRuleValidator', 'validateBooleanField', 'invalid boolean field value - ' + value);
    		result = false;
    	}
    	
    	return result;
    }
    
    private Boolean validateNumberField(String value) {
    	Boolean result = true;
    	try {
    		Decimal.valueOf(value);
    	} catch (TypeException e) {
    		LicenseRuleHelper.logInfo('LicenseRuleValidator', 'validateNumberField', 'invalid number field value - ' + value);
    		result = false;
    	}
    	return result;
    }
    
    //Date should be passed in the format of 'YYYY-MM-DD' 
    private boolean validateDateField(String value) {
    	Boolean result = true;
    	try {
    		Date.valueOf(value);
    	} catch (TypeException e) {
    		LicenseRuleHelper.logInfo('LicenseRuleValidator', 'validateDateField', 'invalid date field value - ' + value);
    		result = false;
    	}
    	return result;
    }
    
    //Datetime should be passed in the format of 'YYYY-MM-DDThh:mm:ssZ' 
    private boolean validateDatetimeField(String value) {
    	Boolean result = true;
    	try {
    		Datetime.valueOf(value.replace('T',' ').replace('Z',''));
    	} catch (TypeException e) {
    		LicenseRuleHelper.logInfo('LicenseRuleValidator', 'validateDatetimeField', 'invalid datetime field value - ' + value);
    		result = false;
    	}
    	return result;
    }
    
    /**
     licensingplus__operator__c field supported values:
     	equals 
     	greater than (only allow date and number display type)
     	greater or equal (only allow date and number display type)
     	less than (only allow date and number display type)
     	less or equal (only allow date and number display type)
     	not equal to
     	starts with (only allow string type)
     	contains (only allow string type)
     	does not contain (only allow string type)
     	in (only allow string and reference type)
     	not in (only allow string and reference type)
     	not blank
     **/
     
     private boolean validateOperatorFieldType(String operator, Schema.DisplayType fieldType) {     	
     	if (WILD_CARD_OPERATORS.contains(operator)) {
     		return SObjectUtils.isStringOrReferenceType(fieldType);
     	}
     	
     	if (COLLECTION_OPERATORS.contains(operator)) {
     		return SObjectUtils.isStringOrReferenceType(fieldType) || SObjectUtils.isNumberType(fieldType);
     	}
     	
     	return true;
     }
    
    private void validateRegularFilterRule(licensingplus__License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	validateFilterRule(rule, objFieldsByName, true);
    }
    
    private void validateLicenseFilterRule(licensingplus__License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	validateFilterRule(rule, objFieldsByName, false);
    }
    
    private void validateLicenseComparisonRule(licensingplus__License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	String objName = rule.licensingplus__object__c;
    	String operator = rule.licensingplus__operator__c;
    	String fieldName = rule.licensingplus__field__c;
    	String licenseFieldName = rule.licensingplus__license_field__c;
    	
    	//validate sobject and field is defined
    	Schema.SobjectField objField = ruleHelper.validateAndGetSObjectField(objName, null, fieldName, objFieldsByName);		
		Schema.DescribeFieldResult objF = objField.getDescribe();
		
		Schema.SobjectField licenseField = ruleHelper.validateAndGetSObjectField('licensingplus__License__c', null, licenseFieldName, objFieldsByName);		
		Schema.DescribeFieldResult licenseF = licenseField.getDescribe();
		
		SObjectUtils.FIELD_TYPE licenseFtype = SObjectUtils.getFieldType(licenseF.getType());
		SObjectUtils.FIELD_TYPE objFtype = SObjectUtils.getFieldType(objF.getType());
		if (licenseFtype!=objFtype) {
			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.FIELD_TYPE_NOT_MATCH_LICENSE_FIELD_TYPE);
			throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldName, objFtype.name(), licenseFieldName, licenseFtype.name(), objName}));
		}  	
    }
	
}