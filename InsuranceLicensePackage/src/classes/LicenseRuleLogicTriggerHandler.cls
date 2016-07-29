public with sharing class LicenseRuleLogicTriggerHandler {
 	
 	public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    public static final LicenseRuleLogicValidator ruleValidator = new LicenseRuleLogicValidator(ruleHelper);
 	
 	public static void validate(List<License_Rule_Logic__c> ruleLogics) {
 		Set<String> objNames = new Set<String>();
 		Boolean needValidation = false; 		
 		for (License_Rule_Logic__c ruleLogic : ruleLogics) {
 			if (ruleLogic.isActive__c) {
 				needValidation = true;
 			}
 			objNames.add(ruleLogic.object__c);
 		}
 		
 		if (needValidation) {
 			LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule__c'), new Set<String> {AppConfig.getAppNamespacedName('Object__c'), AppConfig.getAppNamespacedName('isActive__c')}, 'query', false);        
 			List<License_Rule__c> rules = [SELECT id, object__c FROM license_rule__c WHERE object__c IN:objNames AND isActive__c=true]; 		
	 		Map<String, Set<String>> ruleIdsByObjName = new Map<String, Set<String>>();
	 		for (License_Rule__c rule : rules) {
	 			Set<String> ruleIds = ruleIdsByObjName.get(rule.object__c);
	 			if (ruleIds == null) {
	 				ruleIds = new Set<String>();
	 				ruleIdsByObjName.put(rule.object__c, ruleIds);
	 			}
	 			ruleIds.add(rule.id);
	 		}
	 		
	 		Map<String, Set<String>> filterRuleLogicIdsByObjName = new Map<String, Set<String>>();
	 		LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule_Logic__c'), new Set<String> {'RecordTypeId', AppConfig.getAppNamespacedName('Object__c'), AppConfig.getAppNamespacedName('isActive__c')}, 'query', false);  
	 		List<License_Rule_Logic__c> filterRuleLogics = [SELECT id, object__c FROM license_rule_logic__c WHERE object__c IN:objNames AND recordtypeid=:LicenseRuleHelper.filterRuleLogicRecordTypeId and isActive__c=true];
	 		for (License_Rule_Logic__c filterRuleLogic : filterRuleLogics) {
	 			Set<String> filterRuleLogicIds = filterRuleLogicIdsByObjName.get(filterRuleLogic.object__c);
	 			if (filterRuleLogicIds == null) {
	 				filterRuleLogicIds = new Set<String>();
	 				filterRuleLogicIdsByObjName.put(filterRuleLogic.object__c, filterRuleLogicIds);
	 			}
	 			filterRuleLogicIds.add(filterRuleLogic.id);
	 		}
	 		
	 		
	 		for (License_Rule_Logic__c ruleLogic : ruleLogics) {
	 			if (ruleLogic.isActive__c) {
	 				try {
		 				ruleValidator.validate(ruleLogic, ruleIdsByObjName, filterRuleLogicIdsByObjName);
		 				LogUtils.logInfo('LicenseRuleLogicTriggerHandler', 'validate', 'License Rule Logic validation passed: ' + ruleLogic.logic__c);
		    		} catch (LicenseRuleException e){
						LogUtils.logInfo('LicenseRuleLogicTriggerHandler', 'validate', 'LicenseRuleException errorMessage: ' + e.getMessage());
						ruleLogic.addError(e.getMessage());	
		    		}	
	 			}
	 		}
 		}
 	}
}