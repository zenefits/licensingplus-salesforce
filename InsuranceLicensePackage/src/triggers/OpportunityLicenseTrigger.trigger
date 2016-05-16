trigger OpportunityLicenseTrigger on Opportunity (before insert, before update) {
	if (trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            LicensingUtils.checkSObjectLicenseRules(trigger.new, 'Opportunity');
        } 
    }
}