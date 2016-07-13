public with sharing class LicenseRuleLogicTriggerHandler {
 	
 	public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    public static final LicenseRuleLogicValidator ruleValidator = new LicenseRuleLogicValidator(ruleHelper);
 	
 	public static void validate(List<licensingplus__License_Rule_Logic__c> ruleLogics) {
 		Set<String> objNames = new Set<String>();
 		Boolean needValidation = false; 		
 		for (licensingplus__License_Rule_Logic__c ruleLogic : ruleLogics) {
 			if (ruleLogic.licensingplus__isActive__c) {
 				needValidation = true;
 			}
 			objNames.add(ruleLogic.licensingplus__object__c);
 		}
 		
 		if (needValidation) {
 			List<licensingplus__License_Rule__c> rules = [SELECT id, licensingplus__object__c FROM licensingplus__license_rule__c WHERE licensingplus__object__c IN:objNames AND licensingplus__isActive__c=true]; 		
	 		Map<String, Set<String>> ruleIdsByObjName = new Map<String, Set<String>>();
	 		for (licensingplus__License_Rule__c rule : rules) {
	 			Set<String> ruleIds = ruleIdsByObjName.get(rule.licensingplus__object__c);
	 			if (ruleIds == null) {
	 				ruleIds = new Set<String>();
	 				ruleIdsByObjName.put(rule.licensingplus__object__c, ruleIds);
	 			}
	 			ruleIds.add(rule.id);
	 		}
	 		
	 		Map<String, Set<String>> filterRuleLogicIdsByObjName = new Map<String, Set<String>>();
	 		List<licensingplus__License_Rule_Logic__c> filterRuleLogics = [SELECT id, licensingplus__object__c FROM licensingplus__license_rule_logic__c WHERE licensingplus__object__c IN:objNames AND recordtypeid=:LicenseRuleHelper.filterRuleLogicRecordTypeId and licensingplus__isActive__c=true];
	 		for (licensingplus__License_Rule_Logic__c filterRuleLogic : filterRuleLogics) {
	 			Set<String> filterRuleLogicIds = filterRuleLogicIdsByObjName.get(filterRuleLogic.licensingplus__object__c);
	 			if (filterRuleLogicIds == null) {
	 				filterRuleLogicIds = new Set<String>();
	 				filterRuleLogicIdsByObjName.put(filterRuleLogic.licensingplus__object__c, filterRuleLogicIds);
	 			}
	 			filterRuleLogicIds.add(filterRuleLogic.id);
	 		}
	 		
	 		
	 		for (licensingplus__License_Rule_Logic__c ruleLogic : ruleLogics) {
	 			if (ruleLogic.licensingplus__isActive__c) {
	 				try {
		 				ruleValidator.validate(ruleLogic, ruleIdsByObjName, filterRuleLogicIdsByObjName);
		 				LicenseRuleHelper.logInfo('LicenseRuleLogicTriggerHandler', 'validate', 'License Rule Logic validation passed: ' + ruleLogic.licensingplus__logic__c);
		    		} catch (LicenseRuleException e){
						LicenseRuleHelper.logInfo('LicenseRuleLogicTriggerHandler', 'validate', 'LicenseRuleException errorMessage: ' + e.getMessage());
						ruleLogic.addError(e.getMessage());	
		    		}	
	 			}
	 		}
 		}
 	}
}