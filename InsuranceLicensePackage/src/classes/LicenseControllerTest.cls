@isTest
public class LicenseControllerTest {
    public static testMethod void testLDupeLicense() {
        License__c residentlicense = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            Confirmation_ID__c = '123',
            NPN_Number__c = '123',
            Number__c = '123',
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today());
        insert residentlicense;
        try {
            License__c residentlicense2 = new License__c(
                State__c = 'California',
                RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
                Confirmation_ID__c = '123',
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
            Confirmation_ID__c = '123',
            NPN_Number__c = '123',
            Number__c = '123',
            Approved__c = true,
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today());
        insert residentlicense;
        License__c nonResidentlicense = new License__c(
            State__c = 'Nebraska',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId(),
            Confirmation_ID__c = '123',
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
        
        license.Application_Date__c = Date.today();
        license.Confirmation_ID__c = '123';
        
        System.assertNotEquals(sc.save(), null);
        
        lc.viewList();
        
        Test.stopTest();
    }
    
    public static testMethod void testNewNonResidentWithoutResident() {
        License__c residentlicense = new License__c(
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            Confirmation_ID__c = '123');
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
            Confirmation_ID__c = '123',
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
        
        System.assertEquals(lc.allowed, true, 'Resident State is complete, so should not fail');
        
        license.State__c = 'Nebraska';
        license.Confirmation_ID__c = '123';
        
        System.assertNotEquals(sc.save(), null, ApexPages.getMessages());
        
        Test.stopTest();
    }
}