@isTest
private class LicenseTriggerHandlerTest {
	
	static String residentRTId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId();
	static String nonResidentRTId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId();
	
	static testMethod void testCreateExistingResidentLicense(){
		User testUser = testSetupUser();
        insert testUser;

        License__c residentLicense = new License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'California', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1));
		
		Test.startTest();
		system.runAs(testUser){
			insert residentLicense;

			//Active resident state license must exists before creating a non-resident state license
            License__c nonResidentLicense = new License__c(Name = 'AZ License', RecordtypeId = nonResidentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'Arizona', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1), Approved__c = true);
			try{
				insert nonResidentLicense;
			}catch(DMLException e){
				system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
			}
			
			//Exiting California license already exists, need to update that one first before inserting new ones
	        License__c residentLicense2 = new License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'California', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1));
			try{
				insert residentLicense2;
			}catch(DMLException e){
				system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
			}
						
		}
		Test.stopTest();
		
	}	

	static testMethod void testEditDeleteApprovedLicense(){
		User testUser = testSetupUser();
        insert testUser;
		Test.startTest();
		
        License__c residentLicense = new License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'California', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1), Approved__c = true);
        insert residentLicense;

        system.runAs(testUser){
        	residentLicense.Number__c = '456';
        	//You can not edit an approved license 
        	try{
        		update residentLicense;
			}catch(DMLException e){
				system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
			}
			
			//You can not delete an approved license
			try{
        		delete residentLicense;
        	}catch(DMLException e){
				system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
			}	
        }

        Test.stopTest();		
	}

	static testMethod void testSetResidentLicense(){
		User testUser = testSetupUser();
        insert testUser;
 
	    License__c residentLicense = new License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'California', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1), Approved__c = true);
	    License__c nonResidentLicense = new License__c(Name = 'AZ License', RecordtypeId = nonResidentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'Arizona', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1), Approved__c = true);
	    License__c nonResidentLicense2 = new License__c(Name = 'AZ License', RecordtypeId = nonResidentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'Arizona', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1), Approved__c = true);
	    License__c residentLicense2 = new License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'California', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1), Approved__c = true);
			        
		Test.startTest();
		system.runAs(testUser){
	        insert residentLicense;
			insert nonResidentLicense;        
			insert nonResidentLicense2; 
	
			//Residence license lookup should be set for the non-resident licenses
	        nonResidentLicense = [SELECT Id, Resident_License__c FROM License__c WHERE Id =: nonResidentLicense.Id limit 1];
	        system.assertEquals(residentLicense.Id, nonResidentLicense.Resident_License__c);        
	        nonResidentLicense2 = [SELECT Id, Resident_License__c FROM License__c WHERE Id =: nonResidentLicense2.Id limit 1];
	        system.assertEquals(residentLicense.Id, nonResidentLicense2.Resident_License__c);         
	
	        insert residentLicense2;
		}
        Test.stopTest();
        
		//On insert/update of resident license, the resident license lookup field should be updated for the non-resident licenses
        nonResidentLicense = [SELECT Id, Resident_License__c FROM License__c WHERE Id =: nonResidentLicense.Id limit 1];
        system.assertEquals(residentLicense2.Id, nonResidentLicense.Resident_License__c);        
        nonResidentLicense2 = [SELECT Id, Resident_License__c FROM License__c WHERE Id =: nonResidentLicense2.Id limit 1];
        system.assertEquals(residentLicense2.Id, nonResidentLicense2.Resident_License__c);  
        
	}


	static testMethod void testBulkInsertUpdateLicense(){
		User testUser = testSetupUser();
        insert testUser;
 
	    License__c residentLicense = new License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, Number__c = '123', NPN_Number__c  = '123', Confirmation_ID__c = '123', State__c = 'California', Effective_Date__c = Date.today().addDays(-1), Expiration_Date__c = Date.today().addDays(1), Approved__c = true);
	    
	    //Generate a list of 500 licenses for insert
	    List<License__c> licList = new List<License__c>();
	    for(Integer i=0; i<500; i++){
	    	License__c nonResidentLicense = new License__c();
	    	nonResidentLicense.Name = 'AZ License';
	    	nonResidentLicense.RecordTypeId = nonResidentRTId;
	    	nonResidentLicense.OwnerId = testUser.Id;
	    	nonResidentLicense.Number__c = '123';
	    	nonResidentLicense.NPN_Number__c = '123';
	    	nonResidentLicense.Confirmation_ID__c = '123';
	    	nonResidentLicense.State__c = 'Arizona';
	    	nonResidentLicense.Effective_Date__c = Date.today().addDays(-1);
	    	nonResidentLicense.Expiration_Date__c = Date.today().addDays(1);
	    	nonResidentLicense.Approved__c = true;
	    	licList.add(nonResidentLicense);
	    
	    }
	     
		Test.startTest();
		system.runAs(testUser){
			//insert resident license
			insert residentLicense;
			
			//insert list of 500 non-resident license
	        insert licList;
	        
	        //update list of 500 non-resident license
	        for(License__c nonResidentLic: licList){
	        	nonResidentLic.Number__c = '123';
	        	nonResidentLic.Expiration_Date__c = Date.today().addDays(10);
	        	nonResidentLic.Approved__c = false;
	        }
	        update licList;
	
		}
        Test.stopTest();
        
        //Verify Type and Resident License lookup is set for the 500 non-resident licenses	        
	    licList = [SELECT Id, Resident_License__c, Type__c FROM License__c WHERE ID =: licList];
	    for(License__c nonResidentLic: licList){
	        system.assertEquals('Health', nonResidentLic.Type__c); 
	        system.assertEquals(residentLicense.Id, nonResidentLic.Resident_License__c); 	
	    }
	}	
	
	
	private static User testSetupUser(){
        Profile sp = [SELECT Id FROM profile WHERE name='System Administrator'];
        User testUser = new User(alias = 'uxxx1', email='test@test.com', emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', localesidkey='en_US', profileid = sp.Id, country='United States',
            timezonesidkey='America/Los_Angeles', username='test321CBA@test.com'); 
        return testUser;
    }
}