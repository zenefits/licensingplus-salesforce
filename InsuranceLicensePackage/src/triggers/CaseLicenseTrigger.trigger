trigger CaseLicenseTrigger on Case (after insert, after update) {
    if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
            LicensingUtils.checkSObjectLicenseRules(trigger.newMap, 'Case');
        } 
    }
}