public with sharing class CustomLicenseRuleLogicTriggerHandler {
     
    public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    public static final CustomLicenseRuleLogicValidator ruleValidator = new CustomLicenseRuleLogicValidator(ruleHelper);
        
    public static void validate(List<Custom_License_Rule_Logic__c> ruleLogics) {   	
    	Map<String, List<Custom_License_Rule_Logic__c>> ruleLogicByObj = new Map<String, List<Custom_License_Rule_Logic__c>>();
    	
    	for (Custom_License_Rule_Logic__c ruleLogic : ruleLogics) {
    		String objName = ruleLogic.object__c;
    		List<Custom_License_Rule_Logic__c> objRuleLogics = ruleLogicByObj.get(objName);
    		if (objRuleLogics == null) {
    			objRuleLogics = new List<Custom_License_Rule_Logic__c>();
    			ruleLogicByObj.put(objName, objRuleLogics);
    		}
    		objRuleLogics.add(ruleLogic);
    	}
    	
    	List<Custom_License_Rule__c> rules = [SELECT id, object__c, reference_field__c, field__c, value__c, operator__c FROM Custom_License_Rule__c WHERE isActive__c=true AND object__c IN:ruleLogicByObj.keySet()];
    	Map<String, List<Custom_License_Rule__c>> ruleByObj = new Map<String, List<Custom_License_Rule__c>>();
    	
    	for (Custom_License_Rule__c rule : rules) {
    		String objName = rule.object__c;
    		List<Custom_License_Rule__c> objRules = ruleByObj.get(objName);
    		if (objRules == null) {
    			objRules = new List<Custom_License_Rule__c>();
    			ruleByObj.put(objName, objRules);
    		}
    		objRules.add(rule);
    	}
    	
    	for (String objName : ruleLogicByObj.keySet()) {
    		List<Custom_License_Rule_Logic__c> cruleLogics = ruleLogicByObj.get(objName);
    		List<Custom_License_Rule__c> crules = ruleByObj.get(objName);
    		for (Custom_License_Rule_Logic__c ruleLogic : cruleLogics) {
    			try {
    				ruleValidator.validate(crules, ruleLogic, objName);	
    				LicenseRuleHelper.logInfo('CustomLicenseRuleLogicTriggerHandler', 'validate', 'Custom License Rule Logic validation passed: ' + ruleLogic.logic__c);
    			} catch (LicenseRuleException e){
    				LicenseRuleHelper.logInfo('CustomLicenseRuleLogicTriggerHandler', 'validate', 'LicenseRuleException errorMessage: ' + e.getMessage());
    				ruleLogic.addError(e.getMessage());	
    			}
    		}		
    	}
    }
    
}