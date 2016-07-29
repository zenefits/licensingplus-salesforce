trigger LicenseRuleTrigger on License_Rule__c (before insert, before update, after insert, after update) {
    if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
            LicenseRuleTriggerHandler.validate(trigger.new);
        } 
    } else if (trigger.isBefore) {
    	if (trigger.isInsert) {
    		LicenseRuleTriggerHandler.validateStateAndResidentLicenseRules(trigger.new);
    	}
    }
}