trigger LicenseTrigger on License__c (before insert, before update, after insert, after update, before delete) {
    
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            LicenseTriggerHandler.setTypeAndResidentLicense(trigger.new);
        } else if (trigger.isDelete) {
            LicenseTriggerHandler.preventLicenseDeletion(trigger.old);
        }
    }
    
    
    if (trigger.isAfter) {        
        if(trigger.isInsert || trigger.isUpdate) {
       		LicenseTriggerHandler.setResidentLicense(trigger.new, trigger.oldMap);
        }
    }
    
}