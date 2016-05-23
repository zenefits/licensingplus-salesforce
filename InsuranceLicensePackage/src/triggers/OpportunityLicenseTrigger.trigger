trigger OpportunityLicenseTrigger on Opportunity (after insert, after update) {
	if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
            LicensingUtils.checkSObjectLicenseRules(trigger.newMap, 'Opportunity');
        } 
    }
}