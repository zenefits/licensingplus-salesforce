public with sharing class CustomLicenseRuleValidator extends LicenseRuleValidator{
    
    private static final Set<String> COMPARISON_OPERATORS = new Set<String>{
    	'greater than',
    	'greater or equal',
    	'less than',
    	'less or equal'
    };
    
    private static final Set<String> WILD_CARD_OPERATORS = new Set<String> {
    	'starts with',
    	'contains',
    	'does not contain'
    };
    
    private static final Set<String> COLLECTION_OPERATORS = new Set<String> {
    	'includes',
    	'excludes'
    };
    
    public CustomLicenseRuleValidator(LicenseRuleHelper ruleHelper) {
    	super(ruleHelper);
    }
    
    public void validate(Custom_License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	String objName = rule.object__c;
    	String referenceFieldName = rule.reference_field__c;
    	String operator = rule.operator__c;
    	String fieldName = rule.field__c;
    	String fieldValue = rule.value__c;
    	
    	//validate sobject and field is defined
    	Schema.SobjectField objField = ruleHelper.validateAndGetSObjectField(objName, referenceFieldName, fieldName, objFieldsByName);		
		Schema.DescribeFieldResult f = objField.getDescribe();
		
		//validate operator matches field type
		String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.C_RULE_OPERATOR_NOT_MATCH_FIELD_TYPE);
		if (!validateOperatorFieldType(operator, f.getType())) {			
			throw new LicenseRuleException(String.format(errorMessage, new String[]{operator, fieldName, objName, referenceFieldName}));
		}
		
		errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.C_RULE_FIELD_VALUE_NOT_MATCH_FIELD_TYPE);
		//validate field value matches field type
		if (SObjectUtils.isBooleanType(f.getType())) {
			if (!validateBooleanField(fieldValue)) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldValue, 'Boolean', fieldName, objName, referenceFieldName}));
			}
		} else if (SObjectUtils.isNumberType(f.getType())) {
			if (!validateNumberField(fieldValue)) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldValue, 'Number', fieldName, objName, referenceFieldName}));
			}
		} else if (SObjectUtils.isDateType(f.getType())) {
			if (!validateDateField(fieldValue)) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldValue, 'Date', fieldName, objName, referenceFieldName}));
			}
		} else if (SObjectUtils.isDatetimeType(f.getType())) {
			if (!validateDatetimeField(fieldValue)) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldValue, 'Datetime', fieldName, objName, referenceFieldName}));
			}
		}		
    }
    
    private boolean validateBooleanField(String value) {
    	Boolean result = true;   	
    	if (value != 'true' && value != 'false') {
    		LicenseRuleHelper.logInfo('CustomLicenseRuleValidator', 'validateBooleanField', 'invalid boolean field value - ' + value);
    		result = false;
    	}
    	
    	return result;
    }
    
    private Boolean validateNumberField(String value) {
    	Boolean result = true;
    	try {
    		Decimal.valueOf(value);
    	} catch (TypeException e) {
    		LicenseRuleHelper.logInfo('CustomLicenseRuleValidator', 'validateNumberField', 'invalid number field value - ' + value);
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
    		LicenseRuleHelper.logInfo('CustomLicenseRuleValidator', 'validateDateField', 'invalid date field value - ' + value);
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
    		LicenseRuleHelper.logInfo('CustomLicenseRuleValidator', 'validateDatetimeField', 'invalid datetime field value - ' + value);
    		result = false;
    	}
    	return result;
    }
    
    /**
     operator__c field supported values:
     	equals 
     	greater than (only allow date and number display type)
     	greater or equal (only allow date and number display type)
     	less than (only allow date and number display type)
     	less or equal (only allow date and number display type)
     	not equal to
     	starts with (only allow string type)
     	contains (only allow string type)
     	does not contain (only allow string type)
     	includes (only allow string and reference type)
     	excludes(only allow string and reference type)
     **/
     
     private boolean validateOperatorFieldType(String operator, Schema.DisplayType fieldType) {
     	if (COMPARISON_OPERATORS.contains(operator)) {
     		return SObjectUtils.isDateOrDatetimeOrNumberType(fieldType);
     	}
     	
     	if (WILD_CARD_OPERATORS.contains(operator)) {
     		return SObjectUtils.isStringType(fieldType);
     	}
     	
     	if (COLLECTION_OPERATORS.contains(operator)) {
     		return SObjectUtils.isStringOrReferenceType(fieldType);
     	}
     	
     	return true;
     }
}