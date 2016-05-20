public with sharing class CustomLicenseRuleTriggerHandler {
	
    public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    public static final CustomLicenseRuleValidator ruleValidator = new CustomLicenseRuleValidator(ruleHelper);
    
    public static void validate(List<Custom_License_Rule__c> rules) {
    	Map<String, Map<String, Schema.SobjectField>> objFieldsByName = new Map<String, Map<String, Schema.SobjectField>>(); 
    	  	
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
		
		for (Custom_License_Rule__c rule : rules) {
			try {
				ruleValidator.validate(rule, objFieldsByName);	
				LicenseRuleHelper.logInfo('CustomLicenseRuleTriggerHandler', 'validate', 'Custom License Rule validation passed: ' + rule);
			} catch (LicenseRuleException e){
				LicenseRuleHelper.logInfo('CustomLicenseRuleTriggerHandler', 'validate', 'LicenseRuleException errorMessage: ' + e.getMessage());
				rule.addError(e.getMessage());	
			}
		}
    }
}