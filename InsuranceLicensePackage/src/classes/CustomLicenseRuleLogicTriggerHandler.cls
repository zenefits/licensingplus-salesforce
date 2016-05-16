public with sharing class CustomLicenseRuleLogicTriggerHandler {
     
    public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    public static final CustomLicenseRuleLogicValidator ruleValidator = new CustomLicenseRuleLogicValidator(ruleHelper);
        
    public static void validate(List<Custom_License_Rule_Logic__c> ruleLogics) {   	
    	Map<String, List<Custom_License_Rule_Logic__c>> ruleLogicByObj = new Map<String, List<Custom_License_Rule_Logic__c>>();
    	
    	for (Custom_License_Rule_Logic__c ruleLogic : ruleLogics) {
    		String obj = ruleLogic.object__c;
    		List<Custom_License_Rule_Logic__c> objRuleLogics = ruleLogicByObj.get(obj);
    		if (objRuleLogics==null) {
    			objRuleLogics = new List<Custom_License_Rule_Logic__c>();
    			ruleLogicByObj.put(obj, objRuleLogics);
    		}
    		objRuleLogics.add(ruleLogic);
    	}
    	
    	List<Custom_License_Rule__c> rules = [SELECT id, object__c, parent_object__c, field__c, value__c FROM Custom_License_Rule__c WHERE isActive__c=true AND object__c IN:ruleLogicByObj.keySet()];
    	Map<String, List<Custom_License_Rule__c>> ruleByObj = new Map<String, List<Custom_License_Rule__c>>();
    	
    	for (Custom_License_Rule__c rule : rules) {
    		String obj = rule.object__c;
    		List<Custom_License_Rule__c> objRules = ruleByObj.get(obj);
    		if (objRules==null) {
    			objRules = new List<Custom_License_Rule__c>();
    			ruleByObj.put(obj, objRules);
    		}
    		objRules.add(rule);
    	}
    	
    	for (String objName : ruleLogicByObj.keySet()) {
    		List<Custom_License_Rule_Logic__c> cruleLogics = ruleLogicByObj.get(objName);
    		List<Custom_License_Rule__c> crules = ruleByObj.get(objName);
    		for (Custom_License_Rule_Logic__c ruleLogic : cruleLogics) {
    			try {
    				ruleValidator.validateRuleLogic(crules, ruleLogic, objName);	
    				LicenseRuleHelper.logInfo('CustomLicenseRuleLogicTriggerHandler', 'validate', 'Custom License Rule Logic validation passed: ' + ruleLogic.logic__c);
    			} catch (LicenseRuleException e){
    				LicenseRuleHelper.logInfo('CustomLicenseRuleLogicTriggerHandler', 'validate', 'LicenseRuleException errorMessage: ' + e.getMessage());
    				ruleLogic.addError(e.getMessage());	
    			}
    		}		
    	}
    }
    
}