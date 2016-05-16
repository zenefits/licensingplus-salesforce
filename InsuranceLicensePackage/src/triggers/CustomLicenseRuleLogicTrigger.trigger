trigger CustomLicenseRuleLogicTrigger on Custom_License_Rule_Logic__c (before insert, before update) {
    if (trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            CustomLicenseRuleLogicTriggerHandler.validate(trigger.new);
        } 
    }
}