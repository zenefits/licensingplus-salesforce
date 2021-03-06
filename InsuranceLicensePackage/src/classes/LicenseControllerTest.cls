@isTest
public class LicenseControllerTest {
    @testSetup
    public static void setup() {
        // setup LOA custom setting data
        Line_Of_Authority_Map__c health = new Line_Of_Authority_Map__c(name = 'Health', loa_name__c = 'Health', type__c = 'Health');
        Line_Of_Authority_Map__c life = new Line_Of_Authority_Map__c(name = 'Life', loa_name__c = 'Life', type__c = 'Life');
        Line_Of_Authority_Map__c property = new Line_Of_Authority_Map__c(name = 'P&C1', loa_name__c = 'Property & Casualty', type__c = 'Property'); 
        Line_Of_Authority_Map__c casualty = new Line_Of_Authority_Map__c(name = 'P&C2', loa_name__c = 'Property & Casualty', type__c = 'Casualty');            
        insert new List<Line_Of_Authority_Map__c>{health, life, property, casualty};           
    }

    public static testMethod void testGetIsAdmin() {        
        Test.startTest();
        
        Test.setCurrentPage(Page.License_Edit);
        
        License__c license = new License__c(
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        
        system.assertEquals(false, lc.getIsAdmin());
        
        List<Group> licenseApprovers = [select id from group where DeveloperName = 'License_Approvers'];
        if (!licenseApprovers.isEmpty()) {
        	GroupMember member = new GroupMember(groupId = licenseApprovers.get(0).id, UserOrGroupId = UserInfo.getUserId());
	        insert member;        
	        
	        system.assertEquals(true, lc.getIsAdmin());	
        }

		Test.stopTest();        
    }

    public static testMethod void testExistingLicense() {
        Test.startTest();
        
        Test.setCurrentPage(Page.License_View);
        
        License__c license = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today());
        insert license;                     
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);   

        lc.approveReject();    
        
        Test.stopTest(); 
    }   

    public static testMethod void testExistingLicense_LOAData() {
        Test.startTest();
        
        Test.setCurrentPage(Page.License_View);
        
        License__c license = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today());
        insert license;

        Line_of_Authority__c health = new Line_of_Authority__c(license__c = license.id, name = 'health');
        Line_of_Authority__c life = new Line_of_Authority__c(license__c = license.id, name = 'life');
        Line_of_Authority__c property = new Line_of_Authority__c(license__c = license.id, name = 'property & casualty');
        insert new List<Line_of_Authority__c>{health, life, property};                      
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        
        System.assert(lc.loaTypes.containsIgnoreCase('health'));
        System.assert(lc.loaTypes.containsIgnoreCase('life'));
        System.assert(lc.loaTypes.containsIgnoreCase('property'));
        System.assert(lc.loaTypes.containsIgnoreCase('casualty'));        
        
        Test.stopTest();        
    }
    
    public static testMethod void testLDupeLicense() {
        License__c residentlicense = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today());
        insert residentlicense;
        try {
            License__c residentlicense2 = new License__c(
                State__c = 'California',
                RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
                NPN_Number__c = '123',
                Number__c = '123',
                Effective_Date__c = Date.today().addDays(-1),
                Expiration_Date__c = Date.today());
            insert residentlicense2;
            System.assert(false, 'Shouldn\'t get here.');
        } catch(Exception e) {
            System.assert(true, 'It works!');
        }
    }

    public static testMethod void testLicenseControllerSet() {
        License__c residentlicense = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Approved__c = true,
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today());
        insert residentlicense;
        
        Line_of_Authority__c health = new Line_of_Authority__c(license__c = residentlicense.id, name = 'health');
        Line_of_Authority__c life = new Line_of_Authority__c(license__c = residentlicense.id, name = 'life');
        Line_of_Authority__c property = new Line_of_Authority__c(license__c = residentlicense.id, name = 'property & casualty');
        insert new List<Line_of_Authority__c>{health, life, property};    
            
        License__c nonResidentlicense = new License__c(
            State__c = 'Nebraska',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Approved__c = true,
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today());
        insert nonResidentlicense;

        Test.setCurrentPage(Page.License_List);
        
        List<License__c> licenses = new List<License__c>();
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(licenses);
        LicenseSetController lsc = new LicenseSetController(ssc);

        System.assertEquals(false, ApexPages.hasMessages());
    }

    public static testMethod void testLicenseControllerSet_noAccess() {
        User readOnlyUser = getReadOnlyUser();
        insert readOnlyUser;

        test.startTest();
        system.runAs(readOnlyUser) {
            Test.setCurrentPage(Page.License_List);
            
            List<License__c> licenses = new List<License__c>();
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(licenses);
            LicenseSetController lsc = new LicenseSetController(ssc);       

            System.assert(ApexPages.hasMessages());     
            for (ApexPages.Message message : ApexPages.getMessages()) {
                system.assertEquals(ApexPages.Severity.Error, message.getSeverity());
                system.assert(message.getSummary().contains('You do not have access'));
            }       
        }
        test.stopTest();
    }

    public static testMethod void testNewResident() {        
        Test.startTest();
        
        Test.setCurrentPage(Page.License_Edit);
        
        License__c license = new License__c(
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        lc.licensePDF.Body = Blob.valueOf('123456');
        lc.licensePDF.Name = 'test.txt';
        
        System.assertNotEquals(lc.saveAndUpload(), null);
        
        lc.viewList();
        lc.getCustomLicenseFieldsEmpty();
        
        lc.licensePDF.Body = Blob.valueOf('123456');
        lc.licensePDF.Name = 'test1.txt';
        System.assertNotEquals(lc.upload(), null);
        Test.stopTest();
    }
    
    public static testMethod void testNewNonResidentWithoutResident() {
        License__c residentlicense = new License__c(
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId());
        insert residentlicense;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.License_Edit);
        
        License__c license = new License__c(
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        
        System.assertEquals(lc.allowed, false, 'Resident State is incomplete, so should fail');
        
        Test.stopTest();
    }
    
    public static testMethod void testNewNonResidentWithResident() {
        License__c residentlicense = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Approved__c = true,
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today());
        insert residentlicense;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.License_Edit);
        
        License__c license = new License__c(
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        lc.licensePDF.Body = Blob.valueOf('123456');
        lc.licensePDF.Name = 'test.txt';
        
        System.assertEquals(lc.allowed, true, 'Resident State is complete, so should not fail');
        
        license.State__c = 'Nebraska';
        
        System.assertNotEquals(lc.saveAndUpload(), null, ApexPages.getMessages());
        
        Test.stopTest();
    }

    public static User getReadOnlyUser() {
        Profile readOnlyProfile = [SELECT Id FROM profile WHERE name='Read Only'];
        User testUser = new User(alias = 'uxxx1', email='readOnly@test.com', emailencodingkey='UTF-8', firstname='FN', lastname='Testing', 
          languagelocalekey='en_US', localesidkey='en_US', profileid = readOnlyProfile.Id, country='United States', 
          timezonesidkey='America/Los_Angeles', username='test654CBA@test.com'); 
        return testUser;
    }
}