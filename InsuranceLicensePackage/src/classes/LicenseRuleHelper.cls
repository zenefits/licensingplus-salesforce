public with sharing class LicenseRuleHelper {
	
	// record type id for license rule
	public static final String licenseComparisonRuleRecordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.RecordTypeInfosByName.get('License Comparison Rule').RecordTypeId;
	public static final String regularFilterRuleRecordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.RecordTypeInfosByName.get('Regular Filter Rule').RecordTypeId;
	public static final String licenseFilterRuleRecordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.RecordTypeInfosByName.get('License Filter Rule').RecordTypeId;
	public static final String licenseStateRuleRecordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.RecordTypeInfosByName.get('License State Rule').RecordTypeId;
	public static final String residentLicenseRuleRecordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.RecordTypeInfosByName.get('Resident License Rule').RecordTypeId;
	
	// record type id for license rule logic
	public static final String filterRuleLogicRecordTypeId = Schema.SObjectType.licensingplus__License_Rule_Logic__c.RecordTypeInfosByName.get('Filter Rule').RecordTypeId;
	public static final String licenseRuleLogicRecordTypeId = Schema.SObjectType.licensingplus__License_Rule_Logic__c.RecordTypeInfosByName.get('License Rule').RecordTypeId;
	
	public static final String NO_RULE_LOGIC_ID = '00000000000000000';
	
    public Map<String,Set<licensingplus__License__c>> constructLicensesByOwnerId(
    						Set<String> licenseFields, 
    						Set<String> ownerIds) {
        
        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License__c', licenseFields, 'query', false);
        
        Set<String> ownerIdsEscaped = new Set<String>();
        for (String ownerId : ownerIds) {
        	ownerIdsEscaped.add(String.escapeSingleQuotes(ownerId));
        }
    	
    	String licenseQueryTemplate = 'SELECT {0} FROM licensingplus__License__c WHERE licensingplus__status__c={1} AND ownerId IN ({2})';
	    
	    String licenseFieldsStr = String.escapeSingleQuotes(LicenseRuleHelper.setToStringWithoutQuotes(licenseFields));
	    String licenseQuery = String.format(licenseQueryTemplate, new String[]{String.escapeSingleQuotes(licenseFieldsStr), '\'Active\'',
	    									LicenseRuleHelper.setToStringWithQuotes(ownerIdsEscaped)});
    	logInfo('LicenseRuleHelper', 'constructLicensesByOwnerId', 'LICENSE QUERY - ' + licenseQuery);
    	
    	List<licensingplus__License__c> licenses = null;
    	try {
    		licenses = Database.query(licenseQuery);
    	} catch (QueryException e) {
    		String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.LICENSE_QUERY_EXCEPTION);
			throw new LicenseRuleException(String.format(errorMessage, new String[]{licenseFieldsStr}), e);
    	}
    	
    	Map<String, Set<licensingplus__License__c>> licensesByOwnerId = new Map<String, Set<licensingplus__License__c>>();
    	for (licensingplus__License__c license : licenses) {
    		Set<licensingplus__License__c> ownerLicenses = licensesByOwnerId.get(license.ownerId);
    		if (ownerLicenses == null) {
    			ownerLicenses = new Set<licensingplus__License__c>();
    			licensesByOwnerId.put(license.ownerId, ownerLicenses);
    		}
    		ownerLicenses.add(license);
    	}
    	
    	return licensesByOwnerId;
    }
    
    public Set<String> getRuleIdArray(String ruleLogic) {
    	if (ruleLogic==null) {
    		return null;
    	}
    	
    	Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9\\s]');
		Matcher matcher = nonAlphanumeric.matcher(ruleLogic);
		String ruleLogicWithoutNonAlpha = matcher.replaceAll(' ').trim();
		
		return new Set<String>(ruleLogicWithoutNonAlpha.split('\\s+'));
    }
    
    public Map<String, Map<String, Schema.SobjectField>> getObjFieldsByName(Set<String> objNames) {
    	Map<String, Map<String, Schema.SobjectField>> objFieldsByName = new Map<String,Map<String, Schema.SobjectField>>();
    	
    	for (String objName : objNames) {
    		SObject obj = SObjectUtils.getSObject(objName);
			objFieldsByName.put(objName, SObjectUtils.getSObjectFields(obj));
    	}
    	
    	return objFieldsByName;	
    }
    
    
    public Schema.SobjectField validateAndGetSObjectField(String objName, String referenceFieldName, String fieldName, Map<String,Map<String, Schema.SobjectField>> objFieldsByName) {
    	String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.UNDEFINED_SOBJECT_TYPE);
    	if (objFieldsByName.get(objName) == null || (objFieldsByName.get(objName).isEmpty())) { 		
    		throw new LicenseRuleException(String.format(errorMessage, new String[]{objName}));
    	} 
    	
    	if (referenceFieldName != null && (objFieldsByName.get(referenceFieldName) == null || objFieldsByName.get(referenceFieldName).isEmpty())) {
    		throw new LicenseRuleException(String.format(errorMessage, new String[]{referenceFieldName}));
    	}
    	
    	//validate field on sobject or reference field is defined
    	Schema.SobjectField objField = objFieldsByName.get(objName).get(fieldName);
   		errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.UNDEFINED_SOBJECT_FIELD);
    	if (referenceFieldName != null) {   		
    		objField = objFieldsByName.get(referenceFieldName).get(fieldName);
			if (objField == null) {
				throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldName, referenceFieldName}));
			}
		} else {
			if (objField == null) {
    			throw new LicenseRuleException(String.format(errorMessage, new String[]{fieldName, objName}));
    		} 
		}
		
		return objField;
    }
    
    /** PRIVATE METHODS GOES HERE **/
    private Boolean handleEquals(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
    	if (SObjectUtils.isBooleanType(f.getType())) {
 			return (Boolean.valueOf(ruleValue) == Boolean.valueOf(fieldValue));
 		} else if (SObjectUtils.isIntegerType(f.getType())) {
 			return (Integer.valueOf(ruleValue) == Integer.valueOf(fieldValue));
 		} else if (SObjectUtils.isDoubleType(f.getType())) {
 			return (Double.valueOf(ruleValue) == Double.valueOf(fieldValue));
 		} else if (SObjectUtils.isDateType(f.getType())) {
 			if (!(ruleValue instanceof Date)) {
 				return (Date.valueOf(fieldValue) == Date.valueOf(String.valueOf(ruleValue)));
 			} else { 				 			
 				return (Date.valueOf(fieldValue) == Date.valueOf(ruleValue));
 			}
 		} else if (SObjectUtils.isDatetimeType(f.getType())) {
 			if (!(ruleValue instanceof Datetime)) {
 				return (Datetime.valueOf(fieldValue) == Datetime.valueOf(String.valueOf(ruleValue)));
 			} else { 				 			
 				return (Datetime.valueOf(fieldValue) == Datetime.valueOf(ruleValue));
 			}
 		} else {
 			return ruleValue == fieldValue;
 		}
    }
    
    private Boolean handleNotEqualTo(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
    	return !handleEquals(f, ruleValue, fieldValue);
    }
    
    private Boolean handleGreaterThan(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
		if (SObjectUtils.isIntegerType(f.getType())) {
 			return (Integer.valueOf(fieldValue) > Integer.valueOf(ruleValue));
 		} else if (SObjectUtils.isDoubleType(f.getType())) {
 			return (Double.valueOf(fieldValue) > Double.valueOf(ruleValue));
 		} else if (SObjectUtils.isDateType(f.getType())) {
 			if (!(ruleValue instanceof Date)) {
 				return (Date.valueOf(fieldValue) > Date.valueOf(String.valueOf(ruleValue)));
 			} else { 				 			
 				return (Date.valueOf(fieldValue) > Date.valueOf(ruleValue));
 			}
 		} else if (SObjectUtils.isDatetimeType(f.getType())) {
 			if (!(ruleValue instanceof Datetime)) {
 				return (Datetime.valueOf(fieldValue) > Datetime.valueOf(String.valueOf(ruleValue)));
 			} else { 				 			
 				return (Datetime.valueOf(fieldValue) > Datetime.valueOf(ruleValue));
 			}
 		} else {
            return String.valueOf(fieldValue) > String.valueOf(ruleValue);
        }
    }
        
    private Boolean handleLessOrEqual(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
		return !handleGreaterThan(f, ruleValue, fieldValue);
    }
    
    private Boolean handleGreaterOrEqual(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
		return !handleLessThan(f, ruleValue, fieldValue);
    }
    
    private Boolean handleLessThan(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
		if (SObjectUtils.isIntegerType(f.getType())) {
 			return (Integer.valueOf(fieldValue) < Integer.valueOf(ruleValue));
 		} else if (SObjectUtils.isDoubleType(f.getType())) {
 			return (Double.valueOf(fieldValue) < Double.valueOf(ruleValue));
 		} else if (SObjectUtils.isDateType(f.getType())) {
 			if (!(ruleValue instanceof Date)) {
 				return (Date.valueOf(fieldValue) < Date.valueOf(String.valueOf(ruleValue)));
 			} else { 				 			
 				return (Date.valueOf(fieldValue) < Date.valueOf(ruleValue));
 			}
 		} else if (SObjectUtils.isDatetimeType(f.getType())) {
 			if (!(ruleValue instanceof Datetime)) {
 				return (Datetime.valueOf(fieldValue) < Datetime.valueOf(String.valueOf(ruleValue)));
 			} else { 				 			
 				return (Datetime.valueOf(fieldValue) < Datetime.valueOf(ruleValue));
 			}
 		} else {
            return String.valueOf(fieldValue) < String.valueOf(ruleValue);
        }
    }
    
    private Boolean handleStartsWith(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
		if (f.getType()!=Schema.DisplayType.MultiPicklist && SObjectUtils.isStringOrReferenceType(f.getType())) {
 			return (String.valueOf(fieldValue).startsWithIgnoreCase(String.valueOf(ruleValue)));
 		} else {
 			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.UNSUPPORTED_OPERATOR);
			throw new LicenseRuleException(String.format(errorMessage, new String[]{'starts with', f.getName(), f.getType().name()}));
 		}
    }
    
    private Boolean handleContains(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
		if (f.getType()!=Schema.DisplayType.MultiPicklist && SObjectUtils.isStringOrReferenceType(f.getType())) {
 			return (String.valueOf(fieldValue).containsIgnoreCase(String.valueOf(ruleValue)));
 		} else {
 			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.UNSUPPORTED_OPERATOR);
			throw new LicenseRuleException(String.format(errorMessage, new String[]{'contains, not contain', f.getName(), f.getType().name()}));
 		}
    }
    
    private Boolean handleDoesNotContain(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
		return !handleContains(f, ruleValue, fieldValue);
    }
    
    private Boolean handleIn(Schema.DescribeFieldResult f, Object ruleValue, Object fieldValue) {
    	if ((f.getType()!=Schema.DisplayType.MultiPicklist && SObjectUtils.isStringOrReferenceType(f.getType()))
    		|| SObjectUtils.isNumberType(f.getType())) {
    		Set<String> strSet = new Set<String>(String.valueOf(ruleValue).trim().toLowerCase().split('\\s*,\\s*'));
    		return strSet.contains(String.valueOf(fieldValue).toLowerCase());
    	} else {
 			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.UNSUPPORTED_OPERATOR);
			throw new LicenseRuleException(String.format(errorMessage, new String[]{'in, not in', f.getName(), f.getType().name()}));
 		}
    }
    
    private Boolean handleNotIn(Schema.DescribeFieldResult f, Object value, Object fieldValue) {
    	return !handleIn(f, value, fieldValue);
    }
    
    private Boolean handleNotBlank(Schema.DescribeFieldResult f, Object fieldValue) {
    	if (SObjectUtils.isStringOrReferenceType(f.getType())) {
    		return String.isNotBlank(String.valueOf(fieldValue));
    	} else {
    		return fieldValue != null;
    	}
    }
        
    public Boolean evaluateLicenseComparisonRule(SObject obj, licensingplus__License_Rule__c rule, licensingplus__License__c license, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	String objName = rule.licensingplus__object__c;
    	String fieldName = rule.licensingplus__field__c;
    	String fieldOperator = rule.licensingplus__operator__c;
    	String licenseFieldName = rule.licensingplus__license_field__c;
    	
    	logInfo('LicenseRuleHelper', 'evaluateLicenseComparisonRule', 
    			String.format('license comparison rule - objName {0}, fieldName {1}, fieldValue {2}, fieldOperator {3}, licenseFieldName {4}, licenseFieldValue {5}', 
    					new String[]{objName, fieldName, obj.get(fieldName)+'', fieldOperator, licenseFieldName, license.get(licenseFieldName)+''}));
    	
    	Boolean result = false;
    	//check for null
    	if (obj.get(fieldName) == null && license.get(licenseFieldName) == null) {
    		logInfo('LicenseRuleHelper', 'evaluateLicenseComparisonRule', 'both fields are null');
    		if ('equals' == fieldOperator) {
    			result = true;
    		}     		
    	} else if (obj.get(fieldName) == null || license.get(licenseFieldName) == null) {
    		if ('not equal to' == fieldOperator) {
    			logInfo('LicenseRuleHelper', 'evaluateLicenseComparisonRule', 'one of the fields is null');
    			result = true;
    		} 
    	} else {
	    	Schema.SobjectField objField = validateAndGetSObjectField(objName, null, fieldName, objFieldsByName);		 	
	    	Schema.DescribeFieldResult f = objField.getDescribe();
	    	
	    	if ('equals' == fieldOperator) {
	 			result = handleEquals(f, license.get(licenseFieldName), obj.get(fieldName));	
	 		} else if ('greater than' == fieldOperator) {
	 			result = handleGreaterThan(f, license.get(licenseFieldName), obj.get(fieldName));
	 		} else if ('greater or equal' == fieldOperator)  {
	 			result = handleGreaterOrEqual(f, license.get(licenseFieldName), obj.get(fieldName));
	 		} else if ('less than' == fieldOperator) {
	 			result = handleLessThan(f, license.get(licenseFieldName), obj.get(fieldName));
	 		} else if ('less or equal' == fieldOperator) {
	 			result = handleLessOrEqual(f, license.get(licenseFieldName), obj.get(fieldName));
	 		} else if ('not equal to' == fieldOperator) {
	 			result = handleNotEqualTo(f, license.get(licenseFieldName), obj.get(fieldName));
	 		} else {
	 			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.UNSUPPORTED_OPERATOR);
				throw new LicenseRuleException(String.format(errorMessage, new String[]{'License Comparison Rule ' + fieldOperator, f.getName(), f.getType().name()}));
	 		}
    	}
   		
  		return result;  	  	
    }
    
    private Boolean evaluateFilterRule(SObject obj, licensingplus__License_Rule__c rule, String objName, String fieldName, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	Object value = rule.licensingplus__value__c;
    	String fieldOperator = rule.licensingplus__operator__c;
    	
    	logInfo('LicenseRuleHelper', 'evaluateFilterRule', 
    			String.format('filter rule - objName {0}, fieldName {1}, fieldOperator {2}, value {3}', 
    					new String[]{objName, fieldName, fieldOperator, value+''}));   	
    	    	
    	//check for null
    	if (obj.get(fieldName) == null) {
    		return false;
    	}
    	
    	Schema.SobjectField objField = validateAndGetSObjectField(objName, null, fieldName, objFieldsByName);		 	
    	Schema.DescribeFieldResult f = objField.getDescribe();
    	Boolean result = false;
    	
    	if ('not blank' == fieldOperator) {
    		result = handleNotBlank(f, obj.get(fieldName));
    	} else if ('equals' == fieldOperator) {
 			result = handleEquals(f, value, obj.get(fieldName));	
 		} else if ('greater than' == fieldOperator) {
 			result = handleGreaterThan(f, value, obj.get(fieldName));
 		} else if ('greater or equal' == fieldOperator)  {
 			result = handleGreaterOrEqual(f, value, obj.get(fieldName));
 		} else if ('less than' == fieldOperator) {
 			result = handleLessThan(f, value, obj.get(fieldName));
 		} else if ('less or equal' == fieldOperator) {
 			result = handleLessOrEqual(f, value, obj.get(fieldName));
 		} else if ('not equal to' == fieldOperator) {
 			result = handleNotEqualTo(f, value, obj.get(fieldName));
 		} else if ('starts with' == fieldOperator) {
 			result = handleStartsWith(f, value, obj.get(fieldName));
 		} else if ('contains' == fieldOperator)  {
 			result = handleContains(f, value, obj.get(fieldName));
    	} else if ('does not contain' == fieldOperator) {
 			result = handleDoesNotContain(f, value, obj.get(fieldName));
 		} else if ('in' == fieldOperator) {
 			result = handleIn(f, value, obj.get(fieldName));
 		} else if ('not in' == fieldOperator) {
 			result = handleNotIn(f, value, obj.get(fieldName));
 		} else {
			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.UNSUPPORTED_OPERATOR);
			throw new LicenseRuleException(String.format(errorMessage, new String[]{'Filter Rule ' + fieldOperator, f.getName(), f.getType().name()}));
		}
		
		return result;
    }
    
    public Boolean evaluateLicenseFilterRule(SObject obj, licensingplus__License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {    	
    	logInfo('LicenseRuleHelper', 'evaluateLicenseFilterRule', 'License - ' + rule.licensingplus__license_field__c);
    	return evaluateFilterRule(obj, rule, 'licensingplus__License__c', rule.licensingplus__license_field__c, objFieldsByName);
    }
       
    public Boolean evaluateRegularFilterRule(SObject obj, licensingplus__License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	logInfo('LicenseRuleHelper', 'evaluateRegularFilterRule', rule.licensingplus__object__c + ' - ' + rule.licensingplus__field__c);
    	return evaluateFilterRule(obj, rule, rule.licensingplus__object__c, rule.licensingplus__field__c, objFieldsByName);
    }
    
    // this method will activate/deactivate all license and license rules for a particular object
    public void toggleLicenseRuleSet(String objName, Boolean isActive) {
    	toggleLicenseRuleSet(objName, null, isActive);
    }
    
    public void toggleLicenseRuleSet(String objName, String filterRuleLogicId, Boolean isActive) {

        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule__c', new Set<String> {'Id', 'licensingplus__isActive__c'}, 'query', false);
        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule_Logic__c', new Set<String> {'Id', 'licensingplus__isActive__c', 'licensingplus__logic__c'}, 'query', false);
        
        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule__c', new Set<String> {'licensingplus__isActive__c'}, 'update', false);
        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule_Logic__c', new Set<String> {'licensingplus__isActive__c', 'licensingplus__logic__c'}, 'update', false);

        	        
	    if (filterRuleLogicId == null) {
    		List<licensingplus__License_Rule__c> rules = [SELECT id, licensingplus__isActive__c FROM licensingplus__License_Rule__c WHERE licensingplus__object__c=:objName];
			for (licensingplus__License_Rule__c rule : rules) {
				rule.licensingplus__isActive__c = isActive;
			}
			
			List<licensingplus__License_Rule_Logic__c> ruleLogics = [SELECT id, licensingplus__isActive__c FROM licensingplus__License_Rule_Logic__c WHERE licensingplus__object__c=:objName];
			for (licensingplus__License_Rule_Logic__c ruleLogic : ruleLogics) {
				ruleLogic.licensingplus__isActive__c = isActive;
			}
			
			if (!rules.isEmpty()) {
				update rules;
			}
			
			if (!ruleLogics.isEmpty()) {
				update ruleLogics;
			}			
    	
    	// when we allow multiple filter rules for the same objects, we need to activate/deactivate state rule and resident license state rule separately	
    	} else {
    		List<licensingplus__License_Rule_Logic__c> ruleLogics = [SELECT id, licensingplus__isActive__c, licensingplus__logic__c FROM licensingplus__License_Rule_Logic__c WHERE licensingplus__object__c=:objName AND (id=:filterRuleLogicId OR licensingplus__filter_rule__c=:filterRuleLogicId)];
    		Set<String> ruleIds = new Set<String>();
    		for (licensingplus__License_Rule_Logic__c ruleLogic : ruleLogics) {
    			ruleIds.addAll(getRuleIdArray(ruleLogic.licensingplus__logic__c));
    			ruleLogic.licensingplus__isActive__c = isActive;
    		}    		
    		List<licensingplus__License_Rule__c> rules = [SELECT id, licensingplus__isActive__c FROM licensingplus__License_Rule__c WHERE licensingplus__object__c=:objName AND id IN:ruleIds];
    		for (licensingplus__License_Rule__c rule : rules) {
    			rule.licensingplus__isActive__c = isActive;
    		}
    		
    		if (!rules.isEmpty()) {
				update rules;
			}
			
			if (!ruleLogics.isEmpty()) {
				update ruleLogics;
			} 		
    	} 	
    }
    
    // assume the passed in rule logic is '{1} | {2} & {3}'
    public void updateLicenseRuleSetResult(List<LicenseRuleSetResult.LicenseRuleSet> ruleSets, licensingplus__License_Rule__c stateRule, licensingplus__License_Rule__c residentLicenseRule, String objName) {
    	List<licensingplus__License_Rule_Logic__c> ruleLogicsToDelete = new List<licensingplus__License_Rule_Logic__c>();
    	List<licensingplus__License_Rule_Logic__c> filterRuleLogicsToUpsert = new List<licensingplus__License_Rule_Logic__c>();
    	List<licensingplus__License_Rule_Logic__c> licenseRuleLogicsToUpsert = new List<licensingplus__License_Rule_Logic__c>();
    	List<licensingplus__License_Rule__c> rulesToDelete = new List<licensingplus__License_Rule__c>();
    	List<licensingplus__License_Rule__c> rulesToUpsert = new List<licensingplus__License_Rule__c>();
		
		// handle license state rule
		Boolean deleteStateRule = false;
		if (stateRule!=null) {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'license state rule defined - ' + objName);
			stateRule.recordTypeId = licenseStateRuleRecordTypeId;
			stateRule.license_field__c = 'LicensingPlus__State__c';
			stateRule.licensingplus__operator__c = 'equals';
			rulesToUpsert.add(stateRule);
		} else {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'license state rule deleted - ' + objName);
			deleteStateRule = true;
		}
		
		// handle resident license rule
		Boolean deleteResidentLicenseRule = false;
		if (residentLicenseRule!=null) {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'resident license rule defined - ' + objName);
			residentLicenseRule.recordTypeId = residentLicenseRuleRecordTypeId;
			residentLicenseRule.licensingplus__license_field__c = 'RecordType.Name';
			residentLicenseRule.licensingplus__value__c = 'Resident State';
			residentLicenseRule.licensingplus__operator__c = 'equals';
			rulesToUpsert.add(residentLicenseRule);
		} else {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'resident license rule deleted - ' + objName);
			deleteResidentLicenseRule = true;
		}
		
		if (deleteStateRule || deleteResidentLicenseRule) {
	        
	        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule__c', new Set<String> {'Id', 'recordtypeid'}, 'query', false);
	        
			for(licensingplus__License_Rule__c existingRule : [SELECT id, recordtypeid FROM licensingplus__License_Rule__c WHERE licensingplus__object__c=:objName AND (recordtypeid=:licenseStateRuleRecordTypeId OR recordtypeid=:residentLicenseRuleRecordTypeId)]) {
				if (existingRule.recordtypeid == licenseStateRuleRecordTypeId && deleteStateRule) {
					rulesToDelete.add(existingRule);
				} else if (existingRule.recordtypeid == residentLicenseRuleRecordTypeId && deleteResidentLicenseRule) {
					rulesToDelete.add(existingRule);
				}
			}	
		}

		// first iteration, identify whether there are any filter logic removed, add set the record type id for rules
		for (LicenseRuleSetResult.LicenseRuleSet ruleSet : ruleSets) {			
			if (ruleSet.isFilterRuleLogicRemoved && ruleSet.filterRuleLogic!=null) {
				logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'filter rule logic removed - id: ' + ruleSet.filterRuleLogic.id + ' obj: ' + objName );
				ruleLogicsToDelete.add(ruleSet.filterRuleLogic);				
			} else {
				for (licensingplus__License_Rule__c rule : ruleSet.regularFilterRules) {
					rule.recordTypeId = regularFilterRuleRecordTypeId;
					rulesToUpsert.add(rule);
				}	
			}
			 
			rulesToDelete.addAll(ruleSet.deletedRegularFilterRules);
			
			if (ruleSet.isLicenseRuleLogicRemoved && ruleSet.licenseRuleLogic!=null) {
				logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'license rule logic removed - id: ' + ruleSet.licenseRuleLogic.id + ' obj: ' + objName );
				ruleLogicsToDelete.add(ruleSet.licenseRuleLogic);		
			} else {
				for (licensingplus__License_Rule__c rule : ruleSet.licenseRules) {
					if (rule.licensingplus__field__c!=null && rule.licensingplus__license_field__c!=null) {
						rule.recordTypeId = licenseComparisonRuleRecordTypeId;
					} else {
						rule.recordTypeId = licenseFilterRuleRecordTypeId;
					}			
					rulesToUpsert.add(rule);		
				}		
			}

			rulesToDelete.addAll(ruleSet.deletedLicenseRules);
		}
		
		// upsert rules, so the rule id is set				
		if (!rulesToUpsert.isEmpty()) {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'upsert rules ' + objName);
	        
	        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule__c', new Set<String> {'recordTypeId', 'licensingplus__license_field__c', 'licensingplus__operator__c', 'licensingplus__value__c', 'licensingplus__field__c'}, 'upsert', false);
        
			upsert rulesToUpsert;
		}

	    LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule_Logic__c', new Set<String> {'recordTypeId', 'licensingplus__logic__c', 'licensingplus__filter_rule__c'}, 'upsert', false);
		
		// second iteration replace the filter rule logic with the actual rule id, and upsert them
		List<licensingplus__License_Rule_Logic__c> filterRuleLogics = new List<licensingplus__License_Rule_Logic__c>();
		for (LicenseRuleSetResult.LicenseRuleSet ruleSet : ruleSets) {
			if (!ruleSet.isFilterRuleLogicRemoved && (ruleSet.filterRuleLogic!=null && String.isNotBlank(ruleSet.filterRuleLogic.licensingplus__logic__c))) {
				logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'before replacing filter rule logic: ' + ruleSet.filterRuleLogic.licensingplus__logic__c);
				ruleSet.filterRuleLogic.recordTypeId = filterRuleLogicRecordTypeId;
				for (Integer index=1; index<=ruleSet.regularFilterRules.size(); index++) {
					licensingplus__License_Rule__c rule = ruleSet.regularFilterRules.get(index-1);
					ruleSet.filterRuleLogic.licensingplus__logic__c = ruleSet.filterRuleLogic.licensingplus__logic__c.replace('{'+index+'}', rule.id);
				}
				logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'after replacing filter rule logic: ' + ruleSet.filterRuleLogic.licensingplus__logic__c );
				filterRuleLogicsToUpsert.add(ruleSet.filterRuleLogic);
			}
		}
		
		if (!filterRuleLogicsToUpsert.isEmpty()) {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'upsert filter rule logics ' + objName);
			upsert filterRuleLogicsToUpsert;
		}
		
		// third iteration replace the license rule logic with the actual rule id, and set the filter rule id then upsert them
		for (LicenseRuleSetResult.LicenseRuleSet ruleSet : ruleSets) {
			if (!ruleSet.isLicenseRuleLogicRemoved && (ruleSet.licenseRuleLogic!=null && String.isNotBlank(ruleSet.licenseRuleLogic.licensingplus__logic__c))) {
				ruleSet.licenseRuleLogic.recordTypeId = licenseRuleLogicRecordTypeId;
				logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'before replacing license rule logic: ' + ruleSet.licenseRuleLogic.licensingplus__logic__c );
				for (Integer index=1; index<=ruleSet.licenseRules.size(); index++) {
					licensingplus__License_Rule__c rule = ruleSet.licenseRules.get(index-1);
					ruleSet.licenseRuleLogic.logic__c = ruleSet.licenseRuleLogic.licensingplus__logic__c.replace('{'+index+'}', rule.id);
				}
				
				logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'filter rule logic id: ' + (ruleSet.filterRuleLogic==null ? null : ruleSet.filterRuleLogic.id));
				if (ruleSet.filterRuleLogic!=null) {
					ruleSet.licenseRuleLogic.licensingplus__filter_rule__c = ruleSet.filterRuleLogic.id;
				}
				logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'after replacing license rule logic: ' + ruleSet.licenseRuleLogic.licensingplus__logic__c );
				licenseRuleLogicsToUpsert.add(ruleSet.licenseRuleLogic);
			}
		}
		
		if (!licenseRuleLogicsToUpsert.isEmpty()) {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'upsert license rule logics ' + objName);
			upsert licenseRuleLogicsToUpsert;
		}
		
		// delete rule logics and rules
		if (!ruleLogicsToDelete.isEmpty()) {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'delete license rule logics ' + objName);
			
		    LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule_Logic__c', null, 'delete', false);
			
			delete ruleLogicsToDelete;
		}
		
		if (!rulesToDelete.isEmpty()) {
			logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'delete license rules ' + objName);
			
			LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule__c', null, 'delete', false);
			
			delete rulesToDelete;
		}
     }
    
     public Map<String, LicenseRuleSetResult> getAllLicenseRuleSetResults() {    	
    	Map<String, List<licensingplus__License_Rule_Logic__c>> ruleLogicsByObjName = new Map<String, List<licensingplus__License_Rule_Logic__c>>();
    	Map<String, List<licensingplus__License_Rule__c>> rulesByObjName = new Map<String, List<licensingplus__License_Rule__c>>();
    	Set<String> objNames = new Set<String>();

        
        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule_Logic__c', new Set<String> {'CreatedDate', 'Id', 'licensingplus__Logic__c', 'licensingplus__Object__c', 'licensingplus__Filter_Rule__c', 'RecordTypeid', 'licensingplus__IsActive__c'}, 'query', false);
            	
    	for (licensingplus__License_Rule_Logic__c ruleLogic : [SELECT CreatedDate, Id, licensingplus__Logic__c, licensingplus__Object__c, licensingplus__Filter_Rule__c, RecordTypeid, RecordType.Name,
													licensingplus__IsActive__c FROM licensingplus__License_Rule_Logic__c]) {
			String objName = ruleLogic.licensingplus__object__c;
			List<licensingplus__License_Rule_Logic__c> ruleLogics = ruleLogicsByObjName.get(objName);
			if (ruleLogics == null) {
				ruleLogics = new List<licensingplus__License_Rule_Logic__c>();
				ruleLogicsByObjName.put(objName, ruleLogics);
			}
			ruleLogics.add(ruleLogic);
			objNames.add(objName);
		}
		
        
        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule__c', new Set<String> {'CreatedDate', 'Id', 'RecordTypeId', 'licensingplus__Object__c', 'licensingplus__Field__c', 'licensingplus__License_Field__c', 'licensingplus__Operator__c', 'licensingplus__Value__c', 'licensingplus__IsActive__c'}, 'query', false);
		
		for (licensingplus__License_Rule__c rule : [SELECT CreatedDate, Id, RecordTypeId, licensingplus__Object__c, licensingplus__Field__c, licensingplus__License_Field__c, licensingplus__Operator__c, licensingplus__Value__c, RecordType.Name,
    											IsActive__c FROM licensingplus__License_Rule__c]) {  		
    		String objName = rule.licensingplus__object__c;
			List<licensingplus__License_Rule__c> rules = rulesByObjName.get(objName);
			if (rules == null) {
				rules = new List<licensingplus__License_Rule__c>();
				rulesByObjName.put(objName, rules);
			}
			rules.add(rule); 
			objNames.add(objName);											
    	}
		
		Map<String, LicenseRuleSetResult> results = new Map<String, LicenseRuleSetResult>();
		for (String objName : objNames) {
			List<licensingplus__License_Rule_Logic__c> ruleLogics = ruleLogicsByObjName.get(objName);
			ruleLogics = (ruleLogics!=null ? ruleLogics: new List<licensingplus__License_Rule_Logic__c>());
			List<licensingplus__License_Rule__c> rules = rulesByObjName.get(objName);
			rules = (rules!=null ? rules: new List<licensingplus__License_Rule__c>());
			LicenseRuleSetResult resultSet = getLicenseRuleSetResult(ruleLogics, rules);
			results.put(objName, resultSet);
		}

		return results;										
    }
    
    
    private LicenseRuleSetResult getLicenseRuleSetResult(List<licensingplus__License_Rule_Logic__c> ruleLogics, List<licensingplus__License_Rule__c> rules) {		
		LicenseRuleSetResult ruleSetResult = new LicenseRuleSetResult();
		Map<String, licensingplus__License_Rule_Logic__c> filterRuleLogicById = new Map<String, licensingplus__License_Rule_Logic__c>();
		Map<String, licensingplus__License_Rule_Logic__c> licenseRuleLogicById = new Map<String, licensingplus__License_Rule_Logic__c>();
		Map<String, licensingplus__License_Rule_Logic__c> licenseRuleLogicByFilterRuleLogicId = new Map<String, licensingplus__License_Rule_Logic__c>();
		
		for (licensingplus__License_Rule_Logic__c ruleLogic : ruleLogics) {
			if (ruleLogic.recordTypeId == LicenseRuleHelper.filterRuleLogicRecordTypeId) {
				filterRuleLogicById.put(ruleLogic.id, ruleLogic);
			} else if (ruleLogic.recordTypeId == LicenseRuleHelper.licenseRuleLogicRecordTypeId) {
				licenseRuleLogicById.put(ruleLogic.id, ruleLogic);
				if (ruleLogic.licensingplus__filter_rule__c != null) {
					licenseRuleLogicByFilterRuleLogicId.put(ruleLogic.licensingplus__filter_rule__c, ruleLogic);
				}
			} 
		}
		
    	Map<String, licensingplus__License_Rule__c> ruleById = new Map<String, licensingplus__License_Rule__c>();    	
    	for (licensingplus__License_Rule__c rule : rules) {
    		if (rule.recordTypeId == LicenseRuleHelper.licenseStateRuleRecordTypeId) {
    			ruleSetResult.stateRule = rule;
    		} else if (rule.recordTypeId == LicenseRuleHelper.residentLicenseRuleRecordTypeId) {
    			ruleSetResult.residentLicenseRule = rule;
    		} else {
    			ruleById.put(rule.id, rule); 
    		}		
    	}
    	
    	// no filter rule logic defined		
		if (filterRuleLogicById.isEmpty()) {
			for (String licenseRuleLogicId : licenseRuleLogicById.keySet()) {
				LicenseRuleSetResult.LicenseRuleSet ruleSet = new LicenseRuleSetResult.LicenseRuleSet();
				ruleSet.licenseRuleLogic = licenseRuleLogicById.get(licenseRuleLogicId);
				
				String licenseRuleLogicStr = ruleSet.licenseRuleLogic.licensingplus__logic__c;
				Set<String> licenseRuleIds = getRuleIdArray(licenseRuleLogicStr);
				for (String licenseRuleId : licenseRuleIds) {
					if (ruleById.get(licenseRuleId)!=null) {
						ruleSet.licenseRules.add(ruleById.get(licenseRuleId));
					}						
				}
				ruleSetResult.ruleSets.add(ruleSet);
			}
		// filter rule logic defined
		} else {
			for (String filterRuleLogicId : filterRuleLogicById.keySet()) {
				LicenseRuleSetResult.LicenseRuleSet ruleSet = new LicenseRuleSetResult.LicenseRuleSet();
				ruleSet.filterRuleLogic = filterRuleLogicById.get(filterRuleLogicId);
				ruleSet.licenseRuleLogic = licenseRuleLogicByFilterRuleLogicId.get(filterRuleLogicId);			
				String filterRuleLogicStr = ruleSet.filterRuleLogic.licensingplus__logic__c;
				Set<String> filterRuleIds = getRuleIdArray(filterRuleLogicStr);
				for (String filterRuleId : filterRuleIds) {
					if (ruleById.get(filterRuleId)!=null) {
						ruleSet.regularFilterRules.add(ruleById.get(filterRuleId));
					}						
				}
				
				if (ruleSet.licenseRuleLogic!=null) {
					String licenseRuleLogicStr = ruleSet.licenseRuleLogic.licensingplus__logic__c;
					Set<String> licenseRuleIds = getRuleIdArray(licenseRuleLogicStr);
					for (String licenseRuleId : licenseRuleIds) {
						if (ruleById.get(licenseRuleId)!=null) {
							ruleSet.licenseRules.add(ruleById.get(licenseRuleId));
						}						
					}
				}
				ruleSetResult.ruleSets.add(ruleSet);
			}
		}
		
		return ruleSetResult;
    }
    
    /*******************STATIC METHODS BELOW****************/
    public static String convertCommaSeparatedStringToStringWithQuotes(String inputStr) {
    	String str = '';
    	for (String s : inputStr.split(',')) {
    		str += '\'' + s + '\',';
    	}
    	
    	if (str.length() > 0) {
			str = str.substring(0, str.length()-1);
		}
    	
    	return str;
    }
    
    public static void logInfo(String clazz, String method, String info) {
    	System.debug(String.format('[{0}] - {1} - {2}', new String[]{clazz, method, info}));
    }
    
    public static String setToStringWithoutQuotes(Set<String> strSet) {
    	return setToString(strSet, false);
    }
    
    public static String setToStringWithQuotes(Set<String> strSet) {
    	return setToString(strSet, true);
    }
    
    private static String setToString(Set<String> strSet, Boolean wrapQuotes) {
    	String str = '';
		for(String s : strSet) {
			if (wrapQuotes) {
				str += '\'' + s + '\',';
			} else {
				str += s + ',';
			}		
		}
		if (str.length() > 0) {
			str = str.substring(0, str.length()-1);
		}
		return str;
    }
   
    private static boolean enforceCRUD(Schema.DescribeSObjectResult objResult, String dmlType, Boolean addMessage) {
        boolean hasAccess = true;
        
		if (dmlType == 'delete') {
			hasAccess = objResult.isDeletable();
		}else if (dmlType == 'insert') {
            hasAccess = objResult.isCreateable();
        } else if (dmlType == 'update') {
            hasAccess = objResult.isUpdateable();
        } else if (dmlType == 'query') {
            hasAccess = objResult.isAccessible();
        } else if (dmlType == 'upsert') {
        	hasAccess = objResult.isUpdateable() && objResult.isCreateable();
        }
            
        if(!hasAccess){
        	String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.OBJECT_FAILED_CRUD);
            errorMessage = String.format(errorMessage, new String[] {dmlType, objResult.getName()});
            if (addMessage) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            } else {
                throw new LicenseRuleException(errorMessage);
            }
        }    
        return hasAccess;  
    }
    
    private static boolean enforceFLS(Schema.DescribeSObjectResult objResult, Set<String> fieldsToCheck, String dmlType, Boolean addMessage) {
        boolean hasAccess = true;
        
        if (dmlType == 'delete') {
        	return hasAccess;
        }
        
        // field map for object
        Map<String, Schema.SobjectField> fieldMap = objResult.fields.getMap();

        for (String field : fieldsToCheck) {
            Boolean failFLScheck = false;
            Schema.SobjectField objField = fieldMap.get(field);
            
            // bypass invalid obj field
            if (objField==null) {
            	continue;
            }
                   
            if (dmlType == 'insert') {
                failFLScheck = !objField.getDescribe().isCreateable();
            } else if (dmlType == 'update') {
                failFLScheck = !objField.getDescribe().isUpdateable();
            } else if (dmlType == 'query') {
                failFLScheck = !objField.getDescribe().isAccessible();
            } else if (dmlType == 'upsert') {
                failFLScheck = !objField.getDescribe().isUpdateable() || !objField.getDescribe().isCreateable();
            }

            if (failFLScheck) {
                String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.FIELD_FAILED_FLS);
                errorMessage = String.format(errorMessage, new String[] {dmlType, field, objResult.getName()});
                if (addMessage) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                } else {
                    throw new LicenseRuleException(errorMessage);
                }
                hasAccess = false;
            }
        } 

        return hasAccess;  
    }
    
    public static boolean enforceCRUDAndFLSInController(String objectName, Set<String> fieldsToCheck, String dmlType) {
		return enforceCRUDAndFLS(objectName, fieldsToCheck, dmlType, true);
    }
    
    public static boolean enforceCRUDAndFLS(String objectName, Set<String> fieldsToCheck, String dmlType, Boolean addMessage) {
    	Schema.SObjectType obj = Schema.getGlobalDescribe().get(objectName);
    	if (obj == null) {
    		return false;
    	}
    	
    	return enforceCRUD(obj.getDescribe(), dmlType, addMessage) && enforceFLS(obj.getDescribe(), fieldsToCheck, dmlType, addMessage);
    }
}