trigger CustomLicenseRuleTrigger on Custom_License_Rule__c (before insert, before update) {
    if (trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            CustomLicenseRuleTriggerHandler.validate(trigger.new);
        } 
    }
}