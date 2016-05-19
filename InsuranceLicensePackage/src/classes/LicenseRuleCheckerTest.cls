@isTest
private class LicenseRuleCheckerTest {
	
    static testmethod void testValidCustomRuleInvalidStandardRuleOnAccount() {
    	List<Custom_License_Rule__c> crules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Custom_License_Rule_Logic__c ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Standard_License_Rule__c srule = LicenseRuleTestDataSeeder.createValidStandardLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ).get(StandardLicenseRuleValidator.STATE_RULE);
    	srule.field__c = 'name';
    	update srule;
    	User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Rating = 'hot', OwnerId=testUser.id);    		  		
    		try {
    			insert account; 
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		}   		
    	}	
    }
    
    static testmethod void testInvalidCustomRuleValidStandardRuleOnAccount() {
    	List<Custom_License_Rule__c> crules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Standard_License_Rule__c srule = LicenseRuleTestDataSeeder.createValidStandardLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ).get(StandardLicenseRuleValidator.STATE_RULE);
    	User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		// no rule logic defined
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Rating = 'hot', OwnerId=testUser.id);		   		
    		try {
    			insert account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    		
    		
    		Custom_License_Rule_Logic__c ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    		// add a new custom rule but not updating custom rule logic
    		Custom_License_Rule__c crule = new Custom_License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		field__c='id',
	    		operator__c='equals',
	    		value__c='000000000000000000',
	    		isActive__c=true
    		);
    		
    		insert crule;
    		
    		try {
    			insert account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    		
    		// disable two active custom rules   		
    		crules.get(0).isActive__c = false;
    		crule.isActive__c = false;
    		update new Custom_License_Rule__c[]{crules.get(0), crule};	
    		
    		try {
    			insert account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}   		
    	}	
    }
    
    static testmethod void testValidCustomRuleValidStandardRuleOnAccount() {
    	List<Custom_License_Rule__c> crules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Custom_License_Rule_Logic__c ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Standard_License_Rule__c srule = LicenseRuleTestDataSeeder.createValidStandardLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ).get(StandardLicenseRuleValidator.STATE_RULE);
    	User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Rating = 'hot', OwnerId=testUser.id);		
    		insert account;
    		
    		account.Name = 'test12345';
    		account.Rating = 'test1234';   		
    		try {
    			update account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		}
    		
    		account.BillingState = 'TX';
    		try {
    			update account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		}   		
    	}	
    }
    
    static testmethod void testOnlyCustomRulesOnAccount() {
    	List<Custom_License_Rule__c> crules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Custom_License_Rule_Logic__c ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	User testUser = LicenseRuleTestDataSeeder.createUser();
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Rating = 'hot', OwnerId=testUser.id);		
    		insert account;
    		
    		account.Name = 'test12345';
    		account.Rating = 'test123456';   		
    		try {
    			update account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		}  		
    	}	
    }
    
    static testmethod void testOnlyStandardRuleOnAccount() {
    	Standard_License_Rule__c srule = LicenseRuleTestDataSeeder.createValidStandardLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ).get(StandardLicenseRuleValidator.STATE_RULE);
    	User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test12345', BillingState = 'CA', Rating = 'hot1', OwnerId=testUser.id);		
    		insert account;
    		
    		account.BillingState = 'TX';   		
    		try {
    			update account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		}  		
    	}
    }
    
    static testmethod void testCustomRuleTurnedOnAndOffOnAccount() {
    	List<Custom_License_Rule__c> crules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Custom_License_Rule_Logic__c ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Standard_License_Rule__c srule = LicenseRuleTestDataSeeder.createValidStandardLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ).get(StandardLicenseRuleValidator.STATE_RULE);
    	User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Rating = 'hot', OwnerId=testUser.id);		
    		insert account;
    		   		
    		crules.get(0).isActive__c = false;
    		update crules.get(0);
    		
    		ruleLogic.logic__c = String.format('{0} AND {1}', new String[]{crules.get(1).id, crules.get(2).id});
    		update ruleLogic;
    		
    		account.Name = 'Test12345';
    		update account;
    		
    		account.BillingState = 'TX';
    		try {
    			update account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		}   		
    	}	
    }
    
    static testmethod void testStandardRuleTurnedOnAndOffOnAccount() {
    	List<Custom_License_Rule__c> crules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Custom_License_Rule_Logic__c ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Standard_License_Rule__c srule = LicenseRuleTestDataSeeder.createValidStandardLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ).get(StandardLicenseRuleValidator.STATE_RULE);
    	User testUser = LicenseRuleTestDataSeeder.createUser();
    	License__c license = LicenseRuleTestDataSeeder.createLicense(testUser.id, 'California');
    	
    	System.runAs(testUser) {
    		Account account = new Account(Name = 'Test1234', BillingState = 'CA', Rating = 'hot', OwnerId=testUser.id);		
    		insert account;
    		   		
    		crules.get(0).operator__c = 'includes';
    		crules.get(0).value__c = 'Test1234,Test12345';
    		update crules.get(0);
    		
    		ruleLogic.logic__c = String.format('{0} AND ({1} OR {2})', new String[]{crules.get(0).id, crules.get(1).id, crules.get(2).id});
    		update ruleLogic;
    		
    		// turn off standard rule
    		srule.isActive__c = false;
    		update srule;
    		
    		account.Name = 'Test12345';
    		account.Rating = 'test1234';
    		account.BillingState = 'TX';
    		update account; 		
    	}	
    }
    
    static testmethod void testNoActiveRulesOnAccount() {
    	User testUser = LicenseRuleTestDataSeeder.createUser();
    	
    	System.runAs(testUser) {
    		//test no rules on account
    		Account account = new Account(Name = 'Test1234', BillingState = 'California', Rating = 'hot', OwnerId=testUser.id);		
    		insert account;
    		
    		Standard_License_Rule__c srule = LicenseRuleTestDataSeeder.createValidStandardLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ,false).get(StandardLicenseRuleValidator.STATE_RULE);
    		List<Custom_License_Rule__c> crules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);
    		Custom_License_Rule_Logic__c ruleLogic = null;
    		try {
    			ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    		} 
    		crules.get(0).isActive__c = true;
    		crules.get(1).isActive__c = true;
    		crules.get(2).isActive__c = true;
    		update crules;
    		ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
			
			crules.get(0).isActive__c = false;
    		crules.get(1).isActive__c = false;
    		crules.get(2).isActive__c = false;
    		update crules;
    		
    		try {
    			update account;
    			throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    		} catch (DMLException e) {
    			system.assert(e.getMessage().contains('LicenseRuleException'));
    		}
    		
    		delete ruleLogic;

    		//test no active rules on account
    		account.name = 'Test12345';
    		update account;
    	}
    }
}