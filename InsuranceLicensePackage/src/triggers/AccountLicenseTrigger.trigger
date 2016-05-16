trigger AccountLicenseTrigger on Account (before insert, before update) {
    if (trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            LicensingUtils.checkSObjectLicenseRules(trigger.new, 'Account');
        } 
    }
}