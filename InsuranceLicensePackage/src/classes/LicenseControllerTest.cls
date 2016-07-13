@isTest
public class LicenseControllerTest {
    @testSetup
    public static void setup() {
        // setup LOA custom setting data
        licensingplus__Lines_of_Authority__c health = new licensingplus__Lines_of_Authority__c(name = 'Health', licensingplus__loa_name__c = 'Health', licensingplus__type__c = 'Health');
        licensingplus__Lines_of_Authority__c life = new licensingplus__Lines_of_Authority__c(name = 'Life', licensingplus__loa_name__c = 'Life', licensingplus__type__c = 'Life');
        licensingplus__Lines_of_Authority__c property = new licensingplus__Lines_of_Authority__c(name = 'P&C1', licensingplus__loa_name__c = 'Property & Casualty', licensingplus__type__c = 'Property'); 
        licensingplus__Lines_of_Authority__c casualty = new licensingplus__Lines_of_Authority__c(name = 'P&C2', licensingplus__loa_name__c = 'Property & Casualty', licensingplus__type__c = 'Casualty');            
        insert new List<licensingplus__Lines_of_Authority__c>{health, life, property, casualty};           
    }

    public static testMethod void testGetIsAdmin() {        
        Test.startTest();
        
        Test.setCurrentPage(Page.License_Edit);
        
        licensingplus__License__c license = new licensingplus__License__c(
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        
        system.assertEquals(false, lc.getIsAdmin());
        
        Group licenseApprovers = [select id from group where DeveloperName = 'License_Approvers'];
        GroupMember member = new GroupMember(groupId = licenseApprovers.id, UserOrGroupId = UserInfo.getUserId());
        insert member;        
        
        system.assertEquals(true, lc.getIsAdmin());

		Test.stopTest();        
    }

    public static testMethod void testExistingLicense() {
        Test.startTest();
        
        Test.setCurrentPage(Page.License_View);
        
        licensingplus__License__c license = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today());
        insert license;                     
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);   

        lc.approveReject();    
        
        Test.stopTest(); 
    }   

    public static testMethod void testExistingLicense_LOAData() {
        Test.startTest();
        
        Test.setCurrentPage(Page.License_View);
        
        licensingplus__License__c license = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today());
        insert license;

        licensingplus__Line_of_Authority__c health = new licensingplus__Line_of_Authority__c(licensingplus__license__c = license.id, name = 'health');
        licensingplus__Line_of_Authority__c life = new licensingplus__Line_of_Authority__c(licensingplus__license__c = license.id, name = 'life');
        licensingplus__Line_of_Authority__c property = new licensingplus__Line_of_Authority__c(licensingplus__license__c = license.id, name = 'property & casualty');
        insert new List<licensingplus__Line_of_Authority__c>{health, life, property};                      
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        
        System.assert(lc.loaTypes.containsIgnoreCase('health'));
        System.assert(lc.loaTypes.containsIgnoreCase('life'));
        System.assert(lc.loaTypes.containsIgnoreCase('property'));
        System.assert(lc.loaTypes.containsIgnoreCase('casualty'));        
        
        Test.stopTest();        
    }
    
    public static testMethod void testLDupeLicense() {
        licensingplus__License__c residentlicense = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today());
        insert residentlicense;
        try {
            licensingplus__License__c residentlicense2 = new licensingplus__License__c(
                licensingplus__State__c = 'California',
                RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
                licensingplus__NPN_Number__c = '123',
                licensingplus__Number__c = '123',
                licensingplus__Effective_Date__c = Date.today().addDays(-1),
                licensingplus__Expiration_Date__c = Date.today());
            insert residentlicense2;
            System.assert(false, 'Shouldn\'t get here.');
        } catch(Exception e) {
            System.assert(true, 'It works!');
        }
    }

    public static testMethod void testLicenseControllerSet() {
        licensingplus__License__c residentlicense = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Approved__c = true,
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today());
        insert residentlicense;
        
        licensingplus__Line_of_Authority__c health = new licensingplus__Line_of_Authority__c(licensingplus__license__c = residentlicense.id, name = 'health');
        licensingplus__Line_of_Authority__c life = new licensingplus__Line_of_Authority__c(licensingplus__license__c = residentlicense.id, name = 'life');
        licensingplus__Line_of_Authority__c property = new licensingplus__Line_of_Authority__c(licensingplus__license__c = residentlicense.id, name = 'property & casualty');
        insert new List<Line_of_Authority__c>{health, life, property};    
            
        licensingplus__License__c nonResidentlicense = new licensingplus__License__c(
            licensingplus__State__c = 'Nebraska',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Approved__c = true,
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today());
        insert nonResidentlicense;

        Test.setCurrentPage(Page.License_List);
        
        List<licensingplus__License__c> licenses = new List<licensingplus__License__c>();
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
            
            List<licensingplus__License__c> licenses = new List<licensingplus__License__c>();
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
        
        licensingplus__License__c license = new licensingplus__License__c(
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId());
        
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
        licensingplus__License__c residentlicense = new licensingplus__License__c(
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId());
        insert residentlicense;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.License_Edit);
        
        licensingplus__License__c license = new licensingplus__License__c(
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        
        System.assertEquals(lc.allowed, false, 'Resident State is incomplete, so should fail');
        
        Test.stopTest();
    }
    
    public static testMethod void testNewNonResidentWithResident() {
        licensingplus__License__c residentlicense = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Approved__c = true,
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today());
        insert residentlicense;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.License_Edit);
        
        licensingplus__License__c license = new licensingplus__License__c(
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(license);
        LicenseController lc = new LicenseController(sc);
        lc.licensePDF.Body = Blob.valueOf('123456');
        lc.licensePDF.Name = 'test.txt';
        
        System.assertEquals(lc.allowed, true, 'Resident State is complete, so should not fail');
        
        license.licensingplus__State__c = 'Nebraska';
        
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