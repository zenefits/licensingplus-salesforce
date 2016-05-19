trigger AccountLicenseTrigger on Account (after insert, after update) {
    if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
            LicensingUtils.checkSObjectLicenseRules(trigger.new, 'Account');
        } 
    }
}