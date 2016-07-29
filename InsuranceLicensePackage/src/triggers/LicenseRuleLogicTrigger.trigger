trigger LicenseRuleLogicTrigger on License_Rule_Logic__c (after insert, after update) {
    if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
            LicenseRuleLogicTriggerHandler.validate(trigger.new);
        } 
    }
}