public with sharing class LicenseRuleTriggerHandler {
    public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    public static final LicenseRuleValidator ruleValidator = new LicenseRuleValidator(ruleHelper);
        
    public static void validate(List<licensingplus__License_Rule__c> rules) {   	
		Set<String> objNames = new Set<String>();
		 	
    	for (licensingplus__License_Rule__c rule : rules) {
			objNames.add(rule.licensingplus__object__c);
		}
		objNames.add('licensingplus__License__c');
		
		Map<String, Map<String, Schema.SobjectField>> objFieldsByName = ruleHelper.getObjFieldsByName(objNames);
    	
    	for (licensingplus__License_Rule__c rule : rules) {
    		try {
				ruleValidator.validate(rule, objFieldsByName);	
				LicenseRuleHelper.logInfo('LicenseRuleTriggerHandler', 'validate', 'Custom License Rule validation passed: ' + rule);
			} catch (LicenseRuleException e){
				LicenseRuleHelper.logInfo('LicenseRuleTriggerHandler', 'validate', 'LicenseRuleException errorMessage: ' + e.getMessage());
				rule.addError(e.getMessage());	
			}
    	}
    }
    
    //Before insert, make sure only one license state rule or resident license rule can be created per object
    public static void validateStateAndResidentLicenseRules(List<licensingplus__License_Rule__c> rules) {
    	Set<String> objNames = new Set<String>();
		Map<String, Map<String, licensingplus__License_Rule__c>> rulesByObjName = new Map<String, Map<String, licensingplus__License_Rule__c>>();
		Set<String> rtIds = new Set<String>{LicenseRuleHelper.licenseStateRuleRecordTypeId, LicenseRuleHelper.residentLicenseRuleRecordTypeId};
		
    	for (licensingplus__License_Rule__c rule : rules) {
			if (rtIds.contains(rule.recordTypeId)) {
				String objName = rule.licensingplus__object__c;
				Map<String, licensingplus__License_Rule__c> ruleById = rulesByObjName.get(objName);
				if (ruleById==null) {
					ruleById = new Map<String, licensingplus__License_Rule__c>();
					rulesByObjName.put(objName, ruleById);
				}				
				ruleById.put(rule.recordTypeId, rule);
				objNames.add(rule.licensingplus__object__c);
			}		
		}

    	List<licensingplus__License_Rule__c> existingRules = [SELECT id, recordTypeId, licensingplus__object__c FROM licensingplus__License_Rule__c WHERE recordTypeId IN:rtIds AND licensingplus__object__c IN:objNames];
    	for (licensingplus__License_Rule__c existingRule : existingRules) {
    		Map<String, licensingplus__License_Rule__c> rulesMap = rulesByObjName.get(existingRule.licensingplus__object__c);
    		if (rulesMap!=null && rulesMap.get(existingRule.recordTypeId)!=null) {
    			rulesMap.get(existingRule.recordTypeId).addError('You can only create one rule per object for ' 
    				+ (existingRule.recordTypeId == LicenseRuleHelper.licenseStateRuleRecordTypeId ? 'License State Rule' : 'Resident License Rule'));
    		}
    	}
    }
}