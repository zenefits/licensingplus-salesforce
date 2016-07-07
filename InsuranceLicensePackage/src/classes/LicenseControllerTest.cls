@isTest
public class LicenseControllerTest {
    @testSetup
    public static void setup() {
        // setup LOA custom setting data
        Lines_of_Authority__c health = new Lines_of_Authority__c(name = 'Health', loa_name__c = 'Health', type__c = 'Health');
        Lines_of_Authority__c life = new Lines_of_Authority__c(name = 'Life', loa_name__c = 'Life', type__c = 'Life');
        Lines_of_Authority__c property = new Lines_of_Authority__c(name = 'P&C1', loa_name__c = 'Property & Casualty', type__c = 'Property'); 
        Lines_of_Authority__c casualty = new Lines_of_Authority__c(name = 'P&C2', loa_name__c = 'Property & Casualty', type__c = 'Casualty');            
        insert new List<Lines_of_Authority__c>{health, life, property, casualty};           
    }

    public static testMethod void testGetIsAdmin() {        
        Test.startTest();
        
        Test.setCurrentPage(Page.License_Edit);
        
        License__c license = new License__c(
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId());
        
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
}