public with sharing class LicenseRuleSetResult {
    public licensingplus__License_Rule__c stateRule;
	public licensingplus__License_Rule__c residentLicenseRule;
	public List<LicenseRuleSet> ruleSets;
	
	public LicenseRuleSetResult() {
		this.ruleSets = new List<LicenseRuleSet>();
	}
	
	public class LicenseRuleSet {
		public licensingplus__License_Rule_Logic__c filterRuleLogic;
		public Boolean isFilterRuleLogicRemoved;
		public List<licensingplus__License_Rule__c> regularFilterRules;
		public List<licensingplus__License_Rule__c> deletedRegularFilterRules;
		public licensingplus__License_Rule_Logic__c licenseRuleLogic;
		public Boolean isLicenseRuleLogicRemoved;
		public List<licensingplus__License_Rule__c> licenseRules;
		public List<licensingplus__License_Rule__c> deletedLicenseRules;
		
		public LicenseRuleSet() {
			filterRuleLogic = null;
			licenseRuleLogic = null;
			isFilterRuleLogicRemoved = false;
			isLicenseRuleLogicRemoved = false;
			regularFilterRules = new List<licensingplus__License_Rule__c>();
			deletedRegularFilterRules = new List<licensingplus__License_Rule__c>();
			licenseRules = new List<licensingplus__License_Rule__c>();
			deletedLicenseRules = new List<licensingplus__License_Rule__c>();
		}
	}
}