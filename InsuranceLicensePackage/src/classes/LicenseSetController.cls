global with sharing class LicenseSetController {

    public Id runAs { get; set; }

    public List<License__c> insuranceLicenses { get; private set; }

    public LicenseSetController(ApexPages.StandardSetController controller) {
        runAs = ApexPages.currentPage().getParameters().get('runAs');
        insuranceLicenses = new List<License__c>();       

        for (License__c license : [SELECT Id, State__c, Status__c, RecordType.Name, Casualty__c, Health__c, Life__c, Property__c FROM License__c WHERE OwnerId = :runAs() ORDER BY State__c, CreatedDate DESC]) {
            insuranceLicenses.add(license);
        }
    }

    public Id runAs() {
        if (runAs != null) return runAs;
        return UserInfo.getUserId();
    }

}