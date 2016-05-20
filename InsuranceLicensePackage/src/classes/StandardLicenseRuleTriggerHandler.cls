public with sharing class StandardLicenseRuleTriggerHandler {
    
    public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    public static final StandardLicenseRuleValidator ruleValidator = new StandardLicenseRuleValidator(ruleHelper);
    
    public static void validate(List<Standard_License_Rule__c> rules) {
    	Set<String> objs = new Set<String>();
    	Map<String, SObject> objByName = new Map<String, SObject>();
    	Map<String, Map<String, Schema.SobjectField>> objFieldsByName = new Map<String, Map<String, Schema.SobjectField>>(); 
    	
    	String errorMessage = null;
    	for (Standard_License_Rule__c rule : rules) {
    		String objName = rule.object__c;
    		if (!objs.contains(objName)) {
    			SObject obj = SObjectUtils.getSObject(objName);    		
    			objs.add(rule.object__c);
    			if (obj!=null) {
    				objByName.put(objName, obj);
    				Map<String, Schema.SobjectField> objFields = SObjectUtils.getSObjectFields(obj);
    				objFieldsByName.put(objName, objFields);
    			}
    		}
    	}
    	
    	
    	for (Standard_License_Rule__c rule : rules) {
    		String objName = rule.object__c;
    		SObject obj = objByName.get(objName);
    		if (obj==null) {
    			// sObject not found;
    			errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.UNDEFINED_SOBJECT_TYPE);
    			rule.addError(String.format(errorMessage, new String[]{rule.object__c}));
    		} else {
    			String fieldName = rule.field__c;
    			Map<String, Schema.SobjectField> objFields = objFieldsByName.get(objName);
    			
    			if (!objFields.containsKey(fieldName)) {
    				// sObject field not found
    				errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.UNDEFINED_SOBJECT_FIELD);
    				rule.addError(String.format(errorMessage, new String[]{rule.field__c, rule.object__c}));
    			} else {
    				String ruleType = rule.type__c;
    				// validate state field type
    				if (StandardLicenseRuleValidator.STATE_RULE.equalsIgnoreCase(ruleType)) {
    					try {
    						ruleValidator.validate(objFields, objName, fieldName);   						
    					} catch (LicenseRuleException e) {
    						rule.addError(e.getMessage());
    					}					
    				}   				
    			}
    		}
    		
    		// set the unique rule field to make sure there is only one standard rule per object, per type
			String uniqueKey = rule.object__c + ';' + rule.field__c + ';' + rule.type__c;
			rule.Unique_Key__c = uniqueKey;	
    	}
    }
}