public with sharing class LicenseRuleHelper {
	
	private static final Set<String> COLLECTION_OPERATORS = new Set<String> {
    	'IN',
    	'NOT IN',
    	'INCLUDES',
    	'EXCLUDES'
    };
	
    public Map<String, Set<String>> constructLicenseStateByOwnerId(Set<String> ownerIds) {
    	Map<String, Set<String>> statesByOwnerId = new Map<String, Set<String>>();   	
    	List<License__c> licenses = [SELECT ownerId, state__c FROM license__c WHERE ownerId IN:ownerIds AND owner.isActive=true AND status__c='Active'];
    	
    	for (License__c license : licenses) {
    		String ownerId = license.ownerId;
    		Set<String> states = statesByOwnerId.get(ownerId);
    		if (states == null) {
    			states = new Set<String>();
    			statesByOwnerId.put(ownerId, states);
    		}
    		states.add(license.state__c.toLowerCase());
    	}
    	
    	return statesByOwnerId;
    }
    
    public String getFormattedRules(List<Custom_License_Rule__c> rules, Custom_License_Rule_Logic__c ruleLogic) {
    	if (rules == null || rules.isEmpty()) {
    		if (ruleLogic != null) {
    			String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_RULE_LOGIC_FOUND);
    			throw new LicenseRuleException(String.format(errorMessage, new String[]{ruleLogic.object__c}));
    		// no rules and no rule logic
    		} else {
    			return '';
    		}   		
    	} 
    	
    	if (ruleLogic == null) {
    		String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_NO_RULE_LOGIC_FOUND);
    		throw new LicenseRuleException(String.format(errorMessage, new String[]{rules.get(0).object__c}));
    	}
    	
    	/**Create a map between object/reference object and fields**/
		Map<String, Map<String, Schema.SobjectField>> objFieldsByName = new Map<String,Map<String, Schema.SobjectField>>();
		
		Set<String> objNames = new Set<String>();
		for (Custom_License_Rule__c rule : rules) {
			String objName = rule.object__c;
			String referenceField = rule.reference_field__c;
			if (!objFieldsByName.containsKey(objName)) {
				SObject obj = SObjectUtils.getSObject(objName);
				objFieldsByName.put(objName, SObjectUtils.getSObjectFields(obj));
			}
			
			if (referenceField!=null && !objFieldsByName.containsKey(referenceField)) {
				Map<String, Schema.SobjectField> objFields = objFieldsByName.get(objName);
				Schema.SobjectField objField = objFields.get(referenceField);
				for (String referenceObjName : SObjectUtils.getSObjectFieldReferenceNames(objField)) {
					SObject obj = SObjectUtils.getSObject(referenceObjName);
					objFieldsByName.put(referenceField, SObjectUtils.getSObjectFields(obj));
				}
			}
		}
	    
	    /** Format custom license rule **/	
    	Map<String, String> ruleById = new Map<String, String>();
		for (Custom_License_Rule__c rule : rules) {
			String formattedRule = formatCustomLicenseRule(rule, objFieldsByName);
			ruleById.put(rule.id, formattedRule);  				
		}		
		
		String logic = ruleLogic.logic__c;
		LicenseRuleHelper.logInfo('LicenseRuleHelper', 'getFormattedRules', 'BEFORE formatting: ' + logic);
		for (String ruleId : ruleById.keySet()) {
			String formattedRule = ruleById.get(ruleId);
			if (logic.contains(ruleId)) {
				logic = logic.replace(ruleId, formattedRule);
			} else {
				String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_ACTIVE_RULE_MISSING);
				throw new LicenseRuleException(String.format(errorMessage, new String[]{ruleLogic.logic__c, ruleId}));
			}
		}
		
		LicenseRuleHelper.logInfo('LicenseRuleHelper', 'getFormattedRules', 'AFTER formatting: ' + logic);
		
		return logic;
    }
    
    public Schema.SobjectField validateAndGetSObjectField(String objName, String referenceFieldName, String fieldName, Map<String,Map<String, Schema.SobjectField>> objFieldsByName) {
    	String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.UNDEFINED_SOBJECT_TYPE);
    	if (objFieldsByName.get(objName) == null || (objFieldsByName.get(objName).isEmpty())) { 		
    		throw new LicenseRuleException(String.format(errorMessage, new String[]{objName}));
    	} 
    	
    	if (referenceFieldName != null && (objFieldsByName.get(referenceFieldName) == null || objFieldsByName.get(referenceFieldName).isEmpty())) {
    		throw new LicenseRuleException(String.format(errorMessage, new String[]{referenceFieldName}));
    	}
    	
    	//validate field on sobject or reference field is defined
    	Schema.SobjectField objField = objFieldsByName.get(objName).get(fieldName);
   		errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.UNDEFINED_SOBJECT_FIELD);
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
    
    private String getOperator(Schema.DisplayType displayType, String fieldOperator) {
    	String operator = '';
 		//TODO - move these hard-coded values out 
 		if ('equals' == fieldOperator) {
 			operator = '=';
 		} else if ('greater than' == fieldOperator) {
 			operator = '>';
 		} else if ('greater or equal' == fieldOperator)  {
 			operator = '>=';
 		} else if ('less than' == fieldOperator) {
 			operator = '<';
 		} else if ('less or equal' == fieldOperator) {
 			operator = '<=';
 		} else if ('not equal to' == fieldOperator) {
 			operator = '!=';
 		} else if ('starts with' == fieldOperator || 'contains' == fieldOperator) {
 			operator = 'LIKE';
 		} else if ('does not contain' == fieldOperator) {
 			operator = 'NOT LIKE';
 		} else if ('includes' == fieldOperator) {
 			if (displayType == Schema.DisplayType.MultiPicklist) {
 				operator = 'INCLUDES';
 			} else {
 				operator = 'IN';
 			}
 		} else if ('excludes' == fieldOperator) {
 			if (displayType == Schema.DisplayType.MultiPicklist) {
 				operator = 'EXCLUDES';
 			} else {
 				operator = 'NOT IN';
 			}
 		} else {
			throw new LicenseRuleException('An invalid operator which is not yet supported');
		}
		
		return operator;
    }
    
    private String formatCustomLicenseRule(Custom_License_Rule__c rule, Map<String,Map<String, Schema.SobjectField>> objFieldsByName) {
    	String template = '{0} {1} {2}';
    	String objName = rule.object__c;
    	String fieldOperator =  rule.operator__C;
    	String fieldName = rule.field__c;
    	String referenceFieldName = rule.reference_field__c;
    	String fieldValue = rule.value__c;
    	
    	//check if the field is string type
    	Schema.SobjectField objField = validateAndGetSObjectField(objName, referenceFieldName, fieldName, objFieldsByName);		 	
    	Schema.DescribeFieldResult f = objField.getDescribe();
		String operator = getOperator(f.getType(), fieldOperator);
		
		if (SObjectUtils.isStringOrReferenceType(f.getType())) {
			if (COLLECTION_OPERATORS.contains(operator)) {
				fieldValue = '(' + convertCommaSeparatedStringToStringWithQuotes(fieldValue) + ')';
			
			} else if (fieldOperator == 'starts with'){
				fieldValue = '\'%' + fieldValue + '\'';
				
			} else if (fieldOperator == 'contains' || fieldOperator == 'does not contain') {
				fieldValue = '\'%' + fieldValue + '%\'';
				
			} else {
				fieldValue = '\'' + fieldValue + '\'';
			}
		}
    	
    	/**
          We will store the reference field api name in reference_field__c field.
         **/
    	if (referenceFieldName!=null) {
    		Schema.SobjectField referenceObj = objFieldsByName.get(objName).get(referenceFieldName);
	 		String relationshipName = SObjectUtils.getSObjectFieldRelationshipName(referenceObj);    		
			fieldName = relationshipName + '.' + fieldName;
    	}
    	
    	return String.format(template, new String[]{fieldName, operator, fieldValue});
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
    
    public static String setToStringWithQuotes(Set<Id> strSet) {
    	String str = '';
		for(Id s : strSet) {
   			str += '\'' + s + '\',';
		}
		if (str.length() > 0) {
			str = str.substring(0, str.length()-1);
		}
		return str;
    }
}