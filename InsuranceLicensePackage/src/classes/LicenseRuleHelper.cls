public with sharing class LicenseRuleHelper {
    
    private static final Set<Schema.DisplayType> STRING_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.base64
        ,Schema.DisplayType.Email
        ,Schema.DisplayType.MultiPicklist
        ,Schema.DisplayType.Phone
        ,Schema.DisplayType.Picklist
        ,Schema.DisplayType.String
        ,Schema.DisplayType.TextArea
        ,Schema.DisplayType.URL
    };
    
    private static final Set<Schema.DisplayType> ID_TYPES = new Set<Schema.DisplayType> {
    	Schema.DisplayType.ID
        ,Schema.DisplayType.Reference
    };
    
    private static final Set<String> COLLECTION_OPERATORS = new Set<String> {
    	'IN',
    	'NOT IN',
    	'INCLUDES',
    	'EXCLUDES'
    };
    
    public LicenseRuleHelper() {}
    
    public SObject getSObject(String objName) {
	    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
	    return targetType==null ? null : targetType.newSObject();
	}
	
	public Map<String, Schema.SobjectField> getSObjectFields(SObject obj) {
		return obj==null ? null : obj.getSobjectType().getDescribe().fields.getMap();
	}
	
	public Boolean isStringType(Schema.DisplayType fieldType) {
		return STRING_TYPES.contains(fieldType);
	}
	
	public Boolean isStringOrReferenceType(Schema.DisplayType fieldType) {
		return STRING_TYPES.contains(fieldType) || ID_TYPES.contains(fieldType);
	}
    
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
    
    private String formatCustomLicenseRule(Custom_License_Rule__c rule, Map<String,Map<String, Schema.SobjectField>> objFields) {
    	String template = '%s %s %s';
    	String objName = rule.object__c;
    	String fieldOperator =  rule.operator__C;
    	String fieldName = rule.field__c;
    	String parentObjName = rule.parent_object__c;
    	String fieldValue = rule.value__c;
    	
    	//check if the field is string type
    	Schema.SobjectField objField = objFields.get(objName).get(fieldName);
    	if (objField==null) {
    		String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.ValidationRuleError.UNDEFINED_SOBJECT_FIELD);
    		if (parentObjName!=null) {
    			Schema.SobjectField parentObjField = objFields.get(parentObjName).get(fieldName);
    			if (parentObjField==null) {
    				throw new LicenseRuleException(String.format(errorMessage, new String[]{parentObjName, fieldName}));
    			}
    		} else {
    			throw new LicenseRuleException(String.format(errorMessage, new String[]{objName, fieldName}));
    		}	
    	} 
    	
    	Schema.DescribeFieldResult f = objField.getDescribe();
		String operator = getOperator(f.getType(), fieldOperator);
		
		if (isStringOrReferenceType(f.getType())) {
			if (COLLECTION_OPERATORS.contains(fieldOperator)) {
				fieldValue = '(' + wrapStringWithQuotes(fieldValue) + ')';
			
			} else if (fieldOperator == 'starts with'){
				fieldValue = '\'%' + fieldValue + '\'';
				
			} else if (fieldOperator == 'contains' || fieldOperator == 'does not contain') {
				fieldValue = '\'%' + fieldValue + '%\'';
				
			} else {
				fieldValue = '\'' + fieldValue + '\'';
			}
		}
    	
    	/**
          We will store the API name in both object__c and parent_object__c field,
          so we need to convert parent_object__c field to a reference field to be used in SOQL,
          For custom object (ends with '__c'), reference field will end with '__r',
          For standard object, reference field will either end with '__r' (custom relations) or
          no suffix(standard relations like Account, Contact etc.)
         **/
    	if (parentObjName!=null) {
	 		if (objName.endsWith('__c')) {
    			if (parentObjName.endsWith('__c')) {
    				parentObjName = parentObjName.replace('__c', '__r');
    			} else {
    				parentObjName += '__r';
    			}
    		} else {
    			if (parentObjName.endsWith('__c')) {
    				parentObjName = parentObjName.replace('__c', '__r');
    			}
    		}
    		
			fieldName = parentObjName + '.' + fieldName;
    	}
    	
    	return String.format(template, new String[]{fieldName, operator, fieldValue});
    }
    
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
    	if (rules==null || (!rules.isEmpty() && ruleLogic==null)) {
    		String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.ValidationRuleError.CRL_NO_RULE_LOGIC_FOUND);
    		throw new LicenseRuleException(errorMessage);
    	}
    	
    	/**Create a map between object/parentObject and fields**/
		Set<String> objNames = new Set<String>();
		for (Custom_License_Rule__c rule : rules) {
			objNames.add(rule.object__c);
			if (rule.parent_object__c!=null) {
				objNames.add(rule.parent_object__c);
			}				
		}
		
		Map<String,Map<String, Schema.SobjectField>> objFields = new Map<String,Map<String, Schema.SobjectField>>();
		for (String objName : objNames) {
			SObject obj = getSObject(objName);
			objFields.put(objName, getSObjectFields(obj));
		}
	    
	    /** Format custom license rule **/	
    	Map<String, String> ruleById = new Map<String, String>();
		for (Custom_License_Rule__c rule : rules) {
			String formattedRule = formatCustomLicenseRule(rule, objFields);
			ruleById.put(rule.id, formattedRule);  				
		}
		
		
		String logic = ruleLogic.logic__c;
		LicenseRuleHelper.logInfo('LicenseRuleHelper', 'getFormattedRules', 'BEFORE formatting: ' + logic);
		for (String ruleId : ruleById.keySet()) {
			String formattedRule = ruleById.get(ruleId);
			if (logic.contains(ruleId)) {
				logic.replace(ruleId, formattedRule);
			} else {
				String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.ValidationRuleError.CRL_ACTIVE_RULE_MISSING);
				throw new LicenseRuleException(String.format(errorMessage, new String[]{ruleLogic.logic__c, ruleId}));
			}
		}
		
		LicenseRuleHelper.logInfo('LicenseRuleHelper', 'getFormattedRules', 'AFTER formatting: ' + logic);
		
		return logic;
    }
    
    /*******************STATIC METHODS BELOW****************/
    
    private static String wrapStringWithQuotes(String inputStr) {
    	String str = '';
    	for (String s : inputStr.split(',')) {
    		str += '\'' + s + '\',';
    	}
    	
    	if (str.length() > 0) {
			str.substring(0, str.length()-1);
		}
    	
    	return str;
    }
    
    public static void logInfo(String clazz, String method, String info) {
    	System.debug(String.format('[{0}] - {1} - {2}', new String[]{clazz, method, info}));
    }
    
    public static String setToString(Set<String> strSet) {
    	String str = '';
		for(String s:strSet) {
   			str += (str == '' ? '' : ',')+s;
		}
		if (str.length() > 0) {
			str.substring(0, str.length()-1);
		}
		return str;
    }
}