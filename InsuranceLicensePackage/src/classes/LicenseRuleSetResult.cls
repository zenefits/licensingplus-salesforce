public with sharing class LicenseRuleSetResult {
    public License_Rule__c stateRule;
	public License_Rule__c residentLicenseRule;
	public List<LicenseRuleSet> ruleSets;
	
	public LicenseRuleSetResult() {
		this.ruleSets = new List<LicenseRuleSet>();
	}
	
	public class LicenseRuleSet {
		public License_Rule_Logic__c filterRuleLogic;
		public Boolean isFilterRuleLogicRemoved;
		public List<License_Rule__c> regularFilterRules;
		public List<License_Rule__c> deletedRegularFilterRules;
		public License_Rule_Logic__c licenseRuleLogic;
		public Boolean isLicenseRuleLogicRemoved;
		public List<License_Rule__c> licenseRules;
		public List<License_Rule__c> deletedLicenseRules;
		
		public LicenseRuleSet() {
			filterRuleLogic = null;
			licenseRuleLogic = null;
			isFilterRuleLogicRemoved = false;
			isLicenseRuleLogicRemoved = false;
			regularFilterRules = new List<License_Rule__c>();
			deletedRegularFilterRules = new List<License_Rule__c>();
			licenseRules = new List<License_Rule__c>();
			deletedLicenseRules = new List<License_Rule__c>();
		}
	}
}