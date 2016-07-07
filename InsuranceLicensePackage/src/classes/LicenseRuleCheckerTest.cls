@isTest
private class LicenseRuleCheckerTest {

	// no rules setup, you should still be able to update the object records
	static testmethod void testNoLicenseControlRulesSetup() {
		Account account = new Account(Name='TestAccount');
		insert account;
	}
	
	static testmethod void testNoRegularFilterRuleWithState() {
		License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);		
		User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createResidentLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'WA', Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		} 
    		
    		Account account1 = new Account(Name = 'Test1234', BillingState = 'CA', Rating = 'hot', OwnerId=testUser.id);    		  		
    		insert account1;  		
    	}	
	}
	
	static testmethod void testNoRegularFilterRuleWithStateAndLicenseRule() {
		List<License_Rule__c> licenseFilterRules = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRules = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);		
		License_Rule_Logic__c licenseRuleLogic = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRules, licenseComparisonRules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, null, true);
		
		User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createResidentLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Type='Whatever', Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		} 
    		
    		Account account1 = new Account(Name = 'Test1234', BillingState = 'CA', Type=LicenseRuleTestDataSeeder.ACCOUNT_TYPE, Rating = 'hot', OwnerId=testUser.id);    		  		
    		insert account1;  	
    		    		
    		license.approved__c = false;
    		update license;
    		
    		license.class__c = '12356';
    		license.number__c = 'validNumber';
    		license.approved__c = true;
    		update license;
    		
    		Account account2 = new Account(Name = 'Test1234', BillingState = 'CA', Type=LicenseRuleTestDataSeeder.ACCOUNT_TYPE, Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account2; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		} 
    			
    	}
	}
	
	static testmethod void testRegularFilterRuleWithState() {
		List<License_Rule__c> regularFilterRules = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);		
		License_Rule_Logic__c filterRuleLogic = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		
		User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createResidentLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'WA', Type='Whatever', Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		} 
    		
    		Account account1 = new Account(Name = '1234Test1234', BillingState = 'WA', Type='Whatever', Rating = 'hot123', OwnerId=testUser.id);    		  		
    		insert account1; 			
    	}
	}
	
	static testmethod void testRegularFilterRuleWithStateAndLicenseRule() {
		License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);	
		List<License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);	
		License_Rule_Logic__c filterRuleLogicOne = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c licenseRuleLogicOne = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne, true);
		
		List<License_Rule__c> regularFilterRulesTwo = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);	
		License_Rule_Logic__c filterRuleLogicTwo = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesTwo, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);
		List<License_Rule__c> licenseFilterRulesTwo = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);
		List<License_Rule__c> licenseComparisonRulesTwo = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);
		License_Rule_Logic__c licenseRuleLogicTwo = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesTwo, licenseComparisonRulesTwo, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicTwo, false);
		
		License_Rule__c residentLicenseRule = LicenseRuleTestDataSeeder.createValidResidentLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
		
		User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c residentLicense = LicenseRuleTestDataSeeder.createResidentLicense(testUser.id, 'California');
    	License__c nonResidentLicense = LicenseRuleTestDataSeeder.createNonResidentLicense(testUser.id, 'Washington');
    	
    	System.runAs(testUser) {
    		Account account1 = new Account(Name = 'Test1234', BillingState = 'CA', Type='Whatever', Rating = 'hot', OwnerId=testUser.id);    		  		
    		Account account2 = new Account(Name = 'Test', BillingState = 'WA', Type='Whatever', Rating = 'hot1', OwnerId=testUser.id);
    		List<Database.SaveResult> results = Database.insert(new List<Account>{account1, account2}, false);
            Integer errorCounts = 0;
            for(Database.SaveResult saveResult : results){
                if(!saveResult.isSuccess()) {
                   errorCounts +=1 ;              
                }
            }
            System.assertEquals(2, errorCounts);
    		
    		// change the license to match the rule
    		nonResidentLicense.approved__c = false;
    		update nonResidentLicense;
    		
    		nonResidentLicense.Class__c = '12356';
    		nonResidentLicense.approved__c = true;
    		update nonResidentLicense;
    		
    		Account account3 = new Account(Name = 'Test1234', BillingState = 'CA', Type=LicenseRuleTestDataSeeder.ACCOUNT_TYPE, Rating = 'hot', OwnerId=testUser.id);    		  		
    		Account account4 = new Account(Name = 'Test', BillingState = 'WA', Type='Whatever', Rating = 'hot1', OwnerId=testUser.id);
    		
    		insert new List<Account>{account3, account4};
    		
    		// make resident license inactive 
    		residentLicense.approved__c = false;
    		update residentLicense;
    		
    		results = Database.update(new List<Account>{account3, account4}, false);
            errorCounts = 0;
            for(Database.SaveResult saveResult : results){
                if(!saveResult.isSuccess()) {
                   errorCounts +=1 ;              
                }
            }
            System.assertEquals(2, errorCounts);
 			
    	}
	}
	
	// invalid
	static testmethod void testInvalidRuleInRuleLogic() {		
		List<License_Rule__c> regularFilterRules = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);		
		License_Rule_Logic__c filterRuleLogic = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		
		List<License_Rule__c> licenseFilterRules = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRules = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c licenseRuleLogic = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRules, licenseComparisonRules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogic, true);
		
		User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createResidentLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		//one inactive license filter rule in license rule logic
    		licenseFilterRules.get(0).isActive__c = false;
    		update licenseFilterRules.get(0);
    		
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Type='Whatever', Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    		
    		//one inactive regular filter rule in filter rule logic
    		regularFilterRules.get(0).isActive__c = false;
    		licenseFilterRules.get(0).isActive__c = true;
    		update new List<License_Rule__c>{regularFilterRules.get(0), licenseFilterRules.get(0)};
    		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    		
    		
    		//license comparison rule in filter rule logic
    		regularFilterRules.get(0).isActive__c = true;
    		update regularFilterRules.get(0);
    		
    		String orignalFilterRuleLogic = filterRuleLogic.logic__c;
    		filterRuleLogic.logic__c = filterRuleLogic.logic__c.replace(regularFilterRules.get(0).id, licenseComparisonRules.get(0).id);
    		update filterRuleLogic;
    		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    		
    		//regular filter rule in license rule logic
    		filterRuleLogic.logic__c = orignalFilterRuleLogic;
    		licenseRuleLogic.logic__c = licenseRuleLogic.logic__c.replace(licenseFilterRules.get(0).id, regularFilterRules.get(0).id);   		
    		update new List<License_Rule_Logic__c>{filterRuleLogic, licenseRuleLogic};
    		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    		
    	}
	}
	
	static testmethod void testNoFilterRuleNoStateRuleWithLicenseRule() {
		List<License_Rule__c> licenseFilterRules = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRules = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c licenseRuleLogic = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRules, licenseComparisonRules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, null, true);

		
		User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createResidentLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Type='Whatever', Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    	}
	}
	
	static testmethod void testNoFilterRuleWithStateRuleMultipleLicenseRules() {
		License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);	
		List<License_Rule__c> licenseFilterRules = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRules = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c licenseRuleLogic = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRules, licenseComparisonRules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, null, true);
					
		List<License_Rule__c> licenseFilterRulesTwo = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);
		List<License_Rule__c> licenseComparisonRulesTwo = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);
		License_Rule_Logic__c licenseRuleLogicTwo = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesTwo, licenseComparisonRulesTwo, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, null, false);
		
		User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createResidentLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Type='Whatever', Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    	}
	}
	
	static testmethod void testWithFilterRuleNoStateRule() {
		List<License_Rule__c> regularFilterRules = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c filterRuleLogic = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		
		List<License_Rule__c> licenseFilterRules = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRules = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c licenseRuleLogic = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRules, licenseComparisonRules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, null, true);
		
		User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createResidentLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Type='Whatever', Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    	}
	}
}