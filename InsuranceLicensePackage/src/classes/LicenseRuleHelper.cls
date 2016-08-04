public with sharing class LicenseRuleHelper {
	
	// record type id for license rule
	public static final String licenseComparisonRuleRecordTypeId = Schema.SObjectType.License_Rule__c.RecordTypeInfosByName.get('License Comparison Rule').RecordTypeId;
	public static final String regularFilterRuleRecordTypeId = Schema.SObjectType.License_Rule__c.RecordTypeInfosByName.get('Regular Filter Rule').RecordTypeId;
	public static final String licenseFilterRuleRecordTypeId = Schema.SObjectType.License_Rule__c.RecordTypeInfosByName.get('License Filter Rule').RecordTypeId;
	public static final String licenseStateRuleRecordTypeId = Schema.SObjectType.License_Rule__c.RecordTypeInfosByName.get('License State Rule').RecordTypeId;
	public static final String residentLicenseRuleRecordTypeId = Schema.SObjectType.License_Rule__c.RecordTypeInfosByName.get('Resident License Rule').RecordTypeId;
	
	// record type id for license rule logic
	public static final String filterRuleLogicRecordTypeId = Schema.SObjectType.License_Rule_Logic__c.RecordTypeInfosByName.get('Filter Rule').RecordTypeId;
	public static final String licenseRuleLogicRecordTypeId = Schema.SObjectType.License_Rule_Logic__c.RecordTypeInfosByName.get('License Rule').RecordTypeId;
	
	public static final String NO_RULE_LOGIC_ID = '00000000000000000';
	
    public Map<String,Set<License__c>> constructLicensesByOwnerId(
    						Set<String> licenseFields, 
    						Set<Id> ownerIds) {
        
        LicenseRuleHelper.enforceCRUDAndFLS('License__c', licenseFields, 'query', false);
    	
    	String licenseQueryTemplate = 'SELECT {0} FROM {1} WHERE {2}={3} AND ownerId IN ({4})';
	    
	    String licenseFieldsStr = String.escapeSingleQuotes(String.join(new List<String>(licenseFields), ','));
	    String licenseQuery = String.format(licenseQueryTemplate, 
	    									new String[]{
	    										licenseFieldsStr, 
	    										AppConfig.getAppNamespacedName('License__c'),
	    										AppConfig.getAppNamespacedName('Status__c'),
	    										'\'Active\'',
	    										LicenseRuleHelper.setToStringWithQuotes(ownerIds)});
    	LogUtils.logInfo('LicenseRuleHelper', 'constructLicensesByOwnerId', 'LICENSE QUERY - ' + licenseQuery);
    	
    	List<License__c> licenses = null;
    	try {
    		licenses = Database.query(licenseQuery);
    	} catch (QueryException e) {
    		String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.LICENSE_QUERY_EXCEPTION);
			throw new LicenseRuleException(String.format(errorMessage, new String[]{licenseFieldsStr}), e);
    	}
    	
    	Map<String, Set<License__c>> licensesByOwnerId = new Map<String, Set<License__c>>();
    	for (License__c license : licenses) {
    		Set<License__c> ownerLicenses = licensesByOwnerId.get(license.ownerId);
    		if (ownerLicenses == null) {
    			ownerLicenses = new Set<License__c>();
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
        
    public Boolean evaluateLicenseComparisonRule(SObject obj, License_Rule__c rule, License__c license, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	String objName = rule.object__c;
    	String fieldName = rule.field__c;
    	String fieldOperator = rule.operator__c;
    	String licenseFieldName = rule.license_field__c;
    	
    	LogUtils.logInfo('LicenseRuleHelper', 'evaluateLicenseComparisonRule', 
    			String.format('license comparison rule - objName {0}, fieldName {1}, fieldValue {2}, fieldOperator {3}, licenseFieldName {4}, licenseFieldValue {5}', 
    					new String[]{objName, fieldName, obj.get(fieldName)+'', fieldOperator, licenseFieldName, license.get(licenseFieldName)+''}));
    	
    	Boolean result = false;
    	//check for null
    	if (obj.get(fieldName) == null && license.get(licenseFieldName) == null) {
    		LogUtils.logInfo('LicenseRuleHelper', 'evaluateLicenseComparisonRule', 'both fields are null');
    		if ('equals' == fieldOperator) {
    			result = true;
    		}     		
    	} else if (obj.get(fieldName) == null || license.get(licenseFieldName) == null) {
    		if ('not equal to' == fieldOperator) {
    			LogUtils.logInfo('LicenseRuleHelper', 'evaluateLicenseComparisonRule', 'one of the fields is null');
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
    
    private Boolean evaluateFilterRule(SObject obj, License_Rule__c rule, String objName, String fieldName, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	Object value = rule.value__c;
    	String fieldOperator = rule.operator__c;
    	
    	LogUtils.logInfo('LicenseRuleHelper', 'evaluateFilterRule', 
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
    
    public Boolean evaluateLicenseFilterRule(SObject obj, License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {    	
    	LogUtils.logInfo('LicenseRuleHelper', 'evaluateLicenseFilterRule', 'License - ' + rule.license_field__c);
    	return evaluateFilterRule(obj, rule, AppConfig.getAppNamespacedName('License__c'), rule.license_field__c, objFieldsByName);
    }
       
    public Boolean evaluateRegularFilterRule(SObject obj, License_Rule__c rule, Map<String, Map<String, Schema.SobjectField>> objFieldsByName) {
    	LogUtils.logInfo('LicenseRuleHelper', 'evaluateRegularFilterRule', rule.object__c + ' - ' + rule.field__c);
    	return evaluateFilterRule(obj, rule, rule.object__c, rule.field__c, objFieldsByName);
    }
    
    // this method will activate/deactivate all license and license rules for a particular object
    public void toggleLicenseRuleSet(String objName, Boolean isActive) {
    	toggleLicenseRuleSet(objName, null, isActive);
    }
    
    public void toggleLicenseRuleSet(String objName, String filterRuleLogicId, Boolean isActive) {

        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule__c'), new Set<String> {'Id', AppConfig.getAppNamespacedName('isActive__c')}, 'query', false);
        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule_Logic__c'), new Set<String> {'Id', AppConfig.getAppNamespacedName('isActive__c'), AppConfig.getAppNamespacedName('logic__c')}, 'query', false);
        
        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule__c'), new Set<String> {AppConfig.getAppNamespacedName('isActive__c')}, 'update', false);
        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule_Logic__c'), new Set<String> {AppConfig.getAppNamespacedName('isActive__c'), AppConfig.getAppNamespacedName('logic__c')}, 'update', false);

        	        
	    if (filterRuleLogicId == null) {
    		List<License_Rule__c> rules = [SELECT id, isActive__c FROM License_Rule__c WHERE object__c=:objName];
			for (License_Rule__c rule : rules) {
				rule.isActive__c = isActive;
			}
			
			List<License_Rule_Logic__c> ruleLogics = [SELECT id, isActive__c FROM License_Rule_Logic__c WHERE object__c=:objName];
			for (License_Rule_Logic__c ruleLogic : ruleLogics) {
				ruleLogic.isActive__c = isActive;
			}
			
			if (!rules.isEmpty()) {
				update rules;
			}
			
			if (!ruleLogics.isEmpty()) {
				update ruleLogics;
			}			
    	
    	// when we allow multiple filter rules for the same objects, we need to activate/deactivate state rule and resident license state rule separately	
    	} else {
    		List<License_Rule_Logic__c> ruleLogics = [SELECT id, isActive__c, logic__c FROM License_Rule_Logic__c WHERE object__c=:objName AND (id=:filterRuleLogicId OR filter_rule__c=:filterRuleLogicId)];
    		Set<String> ruleIds = new Set<String>();
    		for (License_Rule_Logic__c ruleLogic : ruleLogics) {
    			ruleIds.addAll(getRuleIdArray(ruleLogic.logic__c));
    			ruleLogic.isActive__c = isActive;
    		}    		
    		List<License_Rule__c> rules = [SELECT id, isActive__c FROM License_Rule__c WHERE object__c=:objName AND id IN:ruleIds];
    		for (License_Rule__c rule : rules) {
    			rule.isActive__c = isActive;
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
    public void updateLicenseRuleSetResult(List<LicenseRuleSetResult.LicenseRuleSet> ruleSets, License_Rule__c stateRule, License_Rule__c residentLicenseRule, String objName) {
    	List<License_Rule_Logic__c> ruleLogicsToDelete = new List<License_Rule_Logic__c>();
    	List<License_Rule_Logic__c> filterRuleLogicsToUpsert = new List<License_Rule_Logic__c>();
    	List<License_Rule_Logic__c> licenseRuleLogicsToUpsert = new List<License_Rule_Logic__c>();
    	List<License_Rule__c> rulesToDelete = new List<License_Rule__c>();
    	List<License_Rule__c> rulesToUpsert = new List<License_Rule__c>();
		
		// handle license state rule
		Boolean deleteStateRule = false;
		if (stateRule!=null) {
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'license state rule defined - ' + objName);
			stateRule.recordTypeId = licenseStateRuleRecordTypeId;
			stateRule.license_field__c = AppConfig.getAppNamespacedName('State__c');
			stateRule.operator__c = 'equals';
			rulesToUpsert.add(stateRule);
		} else {
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'license state rule deleted - ' + objName);
			deleteStateRule = true;
		}
		
		// handle resident license rule
		Boolean deleteResidentLicenseRule = false;
		if (residentLicenseRule!=null) {
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'resident license rule defined - ' + objName);
			residentLicenseRule.recordTypeId = residentLicenseRuleRecordTypeId;
			residentLicenseRule.license_field__c = 'RecordType.Name';
			residentLicenseRule.value__c = 'Resident State';
			residentLicenseRule.operator__c = 'equals';
			rulesToUpsert.add(residentLicenseRule);
		} else {
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'resident license rule deleted - ' + objName);
			deleteResidentLicenseRule = true;
		}
		
		if (deleteStateRule || deleteResidentLicenseRule) {
	        
	        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule__c'), new Set<String> {'Id', 'recordtypeid'}, 'query', false);
	        
			for(License_Rule__c existingRule : [SELECT id, recordtypeid FROM License_Rule__c WHERE object__c=:objName AND (recordtypeid=:licenseStateRuleRecordTypeId OR recordtypeid=:residentLicenseRuleRecordTypeId)]) {
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
				LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'filter rule logic removed - id: ' + ruleSet.filterRuleLogic.id + ' obj: ' + objName );
				ruleLogicsToDelete.add(ruleSet.filterRuleLogic);				
			} else {
				for (License_Rule__c rule : ruleSet.regularFilterRules) {
					rule.recordTypeId = regularFilterRuleRecordTypeId;
					rulesToUpsert.add(rule);
				}	
			}
			 
			rulesToDelete.addAll(ruleSet.deletedRegularFilterRules);
			
			if (ruleSet.isLicenseRuleLogicRemoved && ruleSet.licenseRuleLogic!=null) {
				LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'license rule logic removed - id: ' + ruleSet.licenseRuleLogic.id + ' obj: ' + objName );
				ruleLogicsToDelete.add(ruleSet.licenseRuleLogic);		
			} else {
				for (License_Rule__c rule : ruleSet.licenseRules) {
					if (rule.field__c!=null && rule.license_field__c!=null) {
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
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'upsert rules ' + objName);
	        
	        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule__c'), new Set<String> {'recordTypeId', AppConfig.getAppNamespacedName('license_field__c'), AppConfig.getAppNamespacedName('operator__c'), AppConfig.getAppNamespacedName('value__c'), AppConfig.getAppNamespacedName('field__c')}, 'upsert', false);
        
			upsert rulesToUpsert;
		}

	    LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule_Logic__c'), new Set<String> {'recordTypeId', AppConfig.getAppNamespacedName('logic__c'), AppConfig.getAppNamespacedName('filter_rule__c')}, 'upsert', false);
		
		// second iteration replace the filter rule logic with the actual rule id, and upsert them
		List<License_Rule_Logic__c> filterRuleLogics = new List<License_Rule_Logic__c>();
		for (LicenseRuleSetResult.LicenseRuleSet ruleSet : ruleSets) {
			if (!ruleSet.isFilterRuleLogicRemoved && (ruleSet.filterRuleLogic!=null && String.isNotBlank(ruleSet.filterRuleLogic.logic__c))) {
				LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'before replacing filter rule logic: ' + ruleSet.filterRuleLogic.logic__c);
				ruleSet.filterRuleLogic.recordTypeId = filterRuleLogicRecordTypeId;
				for (Integer index=1; index<=ruleSet.regularFilterRules.size(); index++) {
					License_Rule__c rule = ruleSet.regularFilterRules.get(index-1);
					ruleSet.filterRuleLogic.logic__c = ruleSet.filterRuleLogic.logic__c.replace('{'+index+'}', rule.id);
				}
				LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'after replacing filter rule logic: ' + ruleSet.filterRuleLogic.logic__c );
				filterRuleLogicsToUpsert.add(ruleSet.filterRuleLogic);
			}
		}
		
		if (!filterRuleLogicsToUpsert.isEmpty()) {
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'upsert filter rule logics ' + objName);
			upsert filterRuleLogicsToUpsert;
		}
		
		// third iteration replace the license rule logic with the actual rule id, and set the filter rule id then upsert them
		for (LicenseRuleSetResult.LicenseRuleSet ruleSet : ruleSets) {
			if (!ruleSet.isLicenseRuleLogicRemoved && (ruleSet.licenseRuleLogic!=null && String.isNotBlank(ruleSet.licenseRuleLogic.logic__c))) {
				ruleSet.licenseRuleLogic.recordTypeId = licenseRuleLogicRecordTypeId;
				LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'before replacing license rule logic: ' + ruleSet.licenseRuleLogic.logic__c );
				for (Integer index=1; index<=ruleSet.licenseRules.size(); index++) {
					License_Rule__c rule = ruleSet.licenseRules.get(index-1);
					ruleSet.licenseRuleLogic.logic__c = ruleSet.licenseRuleLogic.logic__c.replace('{'+index+'}', rule.id);
				}
				
				LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'filter rule logic id: ' + (ruleSet.filterRuleLogic==null ? null : ruleSet.filterRuleLogic.id));
				if (ruleSet.filterRuleLogic!=null) {
					ruleSet.licenseRuleLogic.filter_rule__c = ruleSet.filterRuleLogic.id;
				}
				LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'after replacing license rule logic: ' + ruleSet.licenseRuleLogic.logic__c );
				licenseRuleLogicsToUpsert.add(ruleSet.licenseRuleLogic);
			}
		}
		
		if (!licenseRuleLogicsToUpsert.isEmpty()) {
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'upsert license rule logics ' + objName);
			upsert licenseRuleLogicsToUpsert;
		}
		
		// delete rule logics and rules
		if (!ruleLogicsToDelete.isEmpty()) {
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'delete license rule logics ' + objName);
			
		    LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule_Logic__c'), null, 'delete', false);
			
			delete ruleLogicsToDelete;
		}
		
		if (!rulesToDelete.isEmpty()) {
			LogUtils.logInfo('LicenseRuleHelper', 'updateLicenseRuleSetResult', 'delete license rules ' + objName);
			
			LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule__c'), null, 'delete', false);
			
			delete rulesToDelete;
		}
     }
    
     public Map<String, LicenseRuleSetResult> getAllLicenseRuleSetResults(Boolean excludeLicenseObj) {    	
    	Map<String, List<License_Rule_Logic__c>> ruleLogicsByObjName = new Map<String, List<License_Rule_Logic__c>>();
    	Map<String, List<License_Rule__c>> rulesByObjName = new Map<String, List<License_Rule__c>>();
    	Set<String> objNames = new Set<String>();
		Set<String> objNamesException = new Set<String> {
			AppConfig.getAppNamespacedName('License__c')
		};
        
        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule_Logic__c'), new Set<String> {'CreatedDate', 'Id', AppConfig.getAppNamespacedName('Logic__c'), AppConfig.getAppNamespacedName('Object__c'), AppConfig.getAppNamespacedName('Filter_Rule__c'), 'RecordTypeid', AppConfig.getAppNamespacedName('IsActive__c')}, 'query', false);
        
        // exclude license obj if displaying compliance criteria
        List<License_Rule_Logic__c> ruleLogicList = null;
        if (excludeLicenseObj) {			
			ruleLogicList = [SELECT CreatedDate, Id, Logic__c, Object__c, Filter_Rule__c, RecordTypeid, RecordType.Name,
													IsActive__c FROM License_Rule_Logic__c WHERE object__c not in:objNamesException];
		} else {
			ruleLogicList = [SELECT CreatedDate, Id, Logic__c, Object__c, Filter_Rule__c, RecordTypeid, RecordType.Name,
													IsActive__c FROM License_Rule_Logic__c];
		}
    	for (License_Rule_Logic__c ruleLogic : ruleLogicList) {
			String objName = ruleLogic.object__c;
			List<License_Rule_Logic__c> ruleLogics = ruleLogicsByObjName.get(objName);
			if (ruleLogics == null) {
				ruleLogics = new List<License_Rule_Logic__c>();
				ruleLogicsByObjName.put(objName, ruleLogics);
			}
			ruleLogics.add(ruleLogic);
			objNames.add(objName);
		}
		
        
        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule__c'), new Set<String> {'CreatedDate', 'Id', 'RecordTypeId', AppConfig.getAppNamespacedName('Object__c'), AppConfig.getAppNamespacedName('Field__c'), AppConfig.getAppNamespacedName('License_Field__c'), AppConfig.getAppNamespacedName('Operator__c'), AppConfig.getAppNamespacedName('Value__c'), AppConfig.getAppNamespacedName('IsActive__c')}, 'query', false);
		
		// exclude license obj if displaying compliance criteria
		List<License_Rule__c> ruleList = null;
		if (excludeLicenseObj) {
			ruleList = [SELECT CreatedDate, Id, RecordTypeId, Object__c, Field__c, License_Field__c, Operator__c, Value__c, RecordType.Name,
    											IsActive__c FROM License_Rule__c WHERE object__c not in:objNamesException];
		} else {
			ruleList = [SELECT CreatedDate, Id, RecordTypeId, Object__c, Field__c, License_Field__c, Operator__c, Value__c, RecordType.Name,
    											IsActive__c FROM License_Rule__c];
		}		
		for (License_Rule__c rule : ruleList) {  		
    		String objName = rule.object__c;
			List<License_Rule__c> rules = rulesByObjName.get(objName);
			if (rules == null) {
				rules = new List<License_Rule__c>();
				rulesByObjName.put(objName, rules);
			}
			rules.add(rule); 
			objNames.add(objName);											
    	}
		
		Map<String, LicenseRuleSetResult> results = new Map<String, LicenseRuleSetResult>();
		for (String objName : objNames) {
			List<License_Rule_Logic__c> ruleLogics = ruleLogicsByObjName.get(objName);
			ruleLogics = (ruleLogics!=null ? ruleLogics: new List<License_Rule_Logic__c>());
			List<License_Rule__c> rules = rulesByObjName.get(objName);
			rules = (rules!=null ? rules: new List<License_Rule__c>());
			LicenseRuleSetResult resultSet = getLicenseRuleSetResult(ruleLogics, rules);
			results.put(objName, resultSet);
		}

		return results;										
    }
    
    
    private LicenseRuleSetResult getLicenseRuleSetResult(List<License_Rule_Logic__c> ruleLogics, List<License_Rule__c> rules) {		
		LicenseRuleSetResult ruleSetResult = new LicenseRuleSetResult();
		Map<String, License_Rule_Logic__c> filterRuleLogicById = new Map<String, License_Rule_Logic__c>();
		Map<String, License_Rule_Logic__c> licenseRuleLogicById = new Map<String, License_Rule_Logic__c>();
		Map<String, License_Rule_Logic__c> licenseRuleLogicByFilterRuleLogicId = new Map<String, License_Rule_Logic__c>();
		
		for (License_Rule_Logic__c ruleLogic : ruleLogics) {
			if (ruleLogic.recordTypeId == LicenseRuleHelper.filterRuleLogicRecordTypeId) {
				filterRuleLogicById.put(ruleLogic.id, ruleLogic);
			} else if (ruleLogic.recordTypeId == LicenseRuleHelper.licenseRuleLogicRecordTypeId) {
				licenseRuleLogicById.put(ruleLogic.id, ruleLogic);
				if (ruleLogic.filter_rule__c != null) {
					licenseRuleLogicByFilterRuleLogicId.put(ruleLogic.filter_rule__c, ruleLogic);
				}
			} 
		}
		
    	Map<String, License_Rule__c> ruleById = new Map<String, License_Rule__c>();    	
    	for (License_Rule__c rule : rules) {
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
				
				String licenseRuleLogicStr = ruleSet.licenseRuleLogic.logic__c;
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
				String filterRuleLogicStr = ruleSet.filterRuleLogic.logic__c;
				Set<String> filterRuleIds = getRuleIdArray(filterRuleLogicStr);
				for (String filterRuleId : filterRuleIds) {
					if (ruleById.get(filterRuleId)!=null) {
						ruleSet.regularFilterRules.add(ruleById.get(filterRuleId));
					}						
				}
				
				if (ruleSet.licenseRuleLogic!=null) {
					String licenseRuleLogicStr = ruleSet.licenseRuleLogic.logic__c;
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
    
    public static String setToStringWithQuotes(Set<Id> idSet) {
    	List<String> idWithQuotes = new List<String>();
    	for (Id id : idSet) {
    		idWithQuotes.add('\'' + id + '\'');
    	}
    	return String.join(idWithQuotes, ',');
    }
    
    public static String setToStringWithQuotes(Set<String> strSet) {
    	List<String> strWithQuotes = new List<String>();
    	for (String str : strSet) {
    		strWithQuotes.add('\'' + str + '\'');
    	}
    	return String.join(strWithQuotes, ',');
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
        
        if (dmlType == 'delete' || fieldsToCheck==null || fieldsToCheck.isEmpty()) {
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