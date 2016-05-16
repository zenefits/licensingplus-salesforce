trigger StandardLicenseRuleTrigger on Standard_License_Rule__c (before insert, before update) {
    if (trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            StandardLicenseRuleTriggerHandler.validate(trigger.new);
        } 
    }
}