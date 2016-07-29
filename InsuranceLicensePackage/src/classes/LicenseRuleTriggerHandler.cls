public with sharing class LicenseRuleTriggerHandler {
    public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    public static final LicenseRuleValidator ruleValidator = new LicenseRuleValidator(ruleHelper);
        
    public static void validate(List<License_Rule__c> rules) {   	
		Set<String> objNames = new Set<String>();
		 	
    	for (License_Rule__c rule : rules) {
			objNames.add(rule.object__c);
		}
		objNames.add(AppConfig.getAppNamespacedName('License__c'));
		
		Map<String, Map<String, Schema.SobjectField>> objFieldsByName = ruleHelper.getObjFieldsByName(objNames);
    	
    	for (License_Rule__c rule : rules) {
    		try {
				ruleValidator.validate(rule, objFieldsByName);	
				LogUtils.logInfo('LicenseRuleTriggerHandler', 'validate', 'Custom License Rule validation passed: ' + rule);
			} catch (LicenseRuleException e){
				LogUtils.logInfo('LicenseRuleTriggerHandler', 'validate', 'LicenseRuleException errorMessage: ' + e.getMessage());
				rule.addError(e.getMessage());	
			}
    	}
    }
    
    //Before insert, make sure only one license state rule or resident license rule can be created per object
    public static void validateStateAndResidentLicenseRules(List<License_Rule__c> rules) {
    	Set<String> objNames = new Set<String>();
		Map<String, Map<String, License_Rule__c>> rulesByObjName = new Map<String, Map<String, License_Rule__c>>();
		Set<String> rtIds = new Set<String>{LicenseRuleHelper.licenseStateRuleRecordTypeId, LicenseRuleHelper.residentLicenseRuleRecordTypeId};
		
    	for (License_Rule__c rule : rules) {
			if (rtIds.contains(rule.recordTypeId)) {
				String objName = rule.object__c;
				Map<String, License_Rule__c> ruleById = rulesByObjName.get(objName);
				if (ruleById==null) {
					ruleById = new Map<String, License_Rule__c>();
					rulesByObjName.put(objName, ruleById);
				}				
				ruleById.put(rule.recordTypeId, rule);
				objNames.add(rule.object__c);
			}		
		}
		
		LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License_Rule__c'), new Set<String> {'RecordTypeId', AppConfig.getAppNamespacedName('Object__c')}, 'query', false);        
    	List<License_Rule__c> existingRules = [SELECT id, recordTypeId, object__c FROM License_Rule__c WHERE recordTypeId IN:rtIds AND object__c IN:objNames];
    	for (License_Rule__c existingRule : existingRules) {
    		Map<String, License_Rule__c> rulesMap = rulesByObjName.get(existingRule.object__c);
    		if (rulesMap!=null && rulesMap.get(existingRule.recordTypeId)!=null) {
    			rulesMap.get(existingRule.recordTypeId).addError('You can only create one rule per object for ' 
    				+ (existingRule.recordTypeId == LicenseRuleHelper.licenseStateRuleRecordTypeId ? 'License State Rule' : 'Resident License Rule'));
    		}
    	}
    }
}