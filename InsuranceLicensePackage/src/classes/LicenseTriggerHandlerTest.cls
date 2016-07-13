@isTest
private class LicenseTriggerHandlerTest {
	
	static String residentRTId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId();
	static String nonResidentRTId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId();
	
	static testMethod void testCreateExistingResidentLicense(){
		User testUser = testSetupUser();
        insert testUser;

        licensingplus__License__c residentLicense = new licensingplus__License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'California', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1));
		
		Test.startTest();
		system.runAs(testUser){
			insert residentLicense;

			//Active resident state license must exists before creating a non-resident state license
            licensingplus__License__c nonResidentLicense = new licensingplus__License__c(Name = 'AZ License', RecordtypeId = nonResidentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'Arizona', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1), licensingplus__Approved__c = true);
			try{
				insert nonResidentLicense;
			}catch(DMLException e){
				system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
			}
			
			//Exiting California license already exists, need to update that one first before inserting new ones
	        licensingplus__License__c residentLicense2 = new licensingplus__License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'California', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1));
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
		
        licensingplus__License__c residentLicense = new licensingplus__License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'California', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1), licensingplus__Approved__c = true);
        insert residentLicense;

        system.runAs(testUser){
        	residentLicense.licensingplus__Number__c = '456';
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
 
	    licensingplus__License__c residentLicense = new licensingplus__License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'California', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1), licensingplus__Approved__c = true);
	    licensingplus__License__c nonResidentLicense = new licensingplus__License__c(Name = 'AZ License', RecordtypeId = nonResidentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'Arizona', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1), licensingplus__Approved__c = true);
	    licensingplus__License__c nonResidentLicense2 = new licensingplus__License__c(Name = 'AZ License', RecordtypeId = nonResidentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'Arizona', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1), licensingplus__Approved__c = true);
	    licensingplus__License__c residentLicense2 = new licensingplus__License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'California', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1), licensingplus__Approved__c = true);
			        
		Test.startTest();
		system.runAs(testUser){
	        insert residentLicense;
			insert nonResidentLicense;        
			insert nonResidentLicense2; 
	
			//Residence license lookup should be set for the non-resident licenses
	        nonResidentLicense = [SELECT Id, licensingplus__Resident_License__c FROM licensingplus__License__c WHERE Id =: nonResidentLicense.Id limit 1];
	        system.assertEquals(residentLicense.Id, nonResidentLicense.licensingplus__Resident_License__c);        
	        nonResidentLicense2 = [SELECT Id, licensingplus__Resident_License__c FROM licensingplus__License__c WHERE Id =: nonResidentLicense2.Id limit 1];
	        system.assertEquals(residentLicense.Id, nonResidentLicense2.licensingplus__Resident_License__c);         
	
	        insert residentLicense2;
		}
        Test.stopTest();
        
		//On insert/update of resident license, the resident license lookup field should be updated for the non-resident licenses
        nonResidentLicense = [SELECT Id, licensingplus__Resident_License__c FROM licensingplus__License__c WHERE Id =: nonResidentLicense.Id limit 1];
        system.assertEquals(residentLicense2.Id, nonResidentLicense.licensingplus__Resident_License__c);        
        nonResidentLicense2 = [SELECT Id, licensingplus__Resident_License__c FROM licensingplus__License__c WHERE Id =: nonResidentLicense2.Id limit 1];
        system.assertEquals(residentLicense2.Id, nonResidentLicense2.licensingplus__Resident_License__c);  
        
	}


	static testMethod void testBulkInsertUpdateLicense(){
		User testUser = testSetupUser();
        insert testUser;
 
	    licensingplus__License__c residentLicense = new licensingplus__License__c(Name = 'CA License', RecordtypeId = residentRTId, OwnerId = testUser.Id, licensingplus__Number__c = '123', licensingplus__NPN_Number__c  = '123',  licensingplus__State__c = 'California', licensingplus__Effective_Date__c = Date.today().addDays(-1), licensingplus__Expiration_Date__c = Date.today().addDays(1), licensingplus__Approved__c = true);
	    
	    //Generate a list of 500 licenses for insert
	    List<licensingplus__License__c> licList = new List<licensingplus__License__c>();
	    for(Integer i=0; i<500; i++){
	    	licensingplus__License__c nonResidentLicense = new licensingplus__License__c();
	    	nonResidentLicense.Name = 'AZ License';
	    	nonResidentLicense.RecordTypeId = nonResidentRTId;
	    	nonResidentLicense.OwnerId = testUser.Id;
	    	nonResidentLicense.licensingplus__Number__c = '123';
	    	nonResidentLicense.licensingplus__NPN_Number__c = '123';
	    	nonResidentLicense.licensingplus__State__c = 'Arizona';
	    	nonResidentLicense.licensingplus__Effective_Date__c = Date.today().addDays(-1);
	    	nonResidentLicense.licensingplus__Expiration_Date__c = Date.today().addDays(1);
	    	nonResidentLicense.licensingplus__Approved__c = true;
	    	licList.add(nonResidentLicense);
	    
	    }
	     
		Test.startTest();
		system.runAs(testUser){
			//insert resident license
			insert residentLicense;
			
			//insert list of 500 non-resident license
	        insert licList;
	        
	        //update list of 500 non-resident license
	        for(licensingplus__License__c nonResidentLic: licList){
	        	nonResidentLic.licensingplus__Number__c = '123';
	        	nonResidentLic.licensingplus__Expiration_Date__c = Date.today().addDays(10);
	        	nonResidentLic.licensingplus__Approved__c = false;
	        }
	        update licList;
	
		}
        Test.stopTest();
        
        //Verify Resident License lookup is set for the 500 non-resident licenses	        
	    licList = [SELECT Id, licensingplus__Resident_License__c, licensingplus__Type__c FROM licensingplus__License__c WHERE ID =: licList];
	    for(licensingplus__License__c nonResidentLic: licList){
	        system.assertEquals(residentLicense.Id, nonResidentLic.licensingplus__Resident_License__c); 	
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