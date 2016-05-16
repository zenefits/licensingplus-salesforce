trigger CaseLicenseTrigger on Case (before insert, before update) {
    if (trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            LicensingUtils.checkSObjectLicenseRules(trigger.new, 'Case');
        } 
    }
}