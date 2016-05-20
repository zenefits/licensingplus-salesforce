@isTest
private class CustomLicenseRuleLogicTest {
        
    static testMethod void testInsertUpdateWithQueryException() {
    	List<Custom_License_Rule__c> rules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	String invalidStr = '{0} OR1 {1}) AND {2}';
    	Custom_License_Rule_Logic__c invalidLogic = new Custom_License_Rule_Logic__c(
    		object__c='Account',
    		logic__c=String.format(invalidStr, new String[]{rules.get(0).id, rules.get(1).id, rules.get(2).id})
    	);
    	
    	try {
    		insert invalidLogic;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	Custom_License_Rule_Logic__c validLogic = new Custom_License_Rule_Logic__c(
    		object__c='Account',
    		logic__c=String.format('({0} OR {1}) AND {2}', new String[]{rules.get(0).id, rules.get(1).id, rules.get(2).id})
    	);
    	insert validLogic;
    	
    	try {
    		validLogic.logic__c = invalidStr;
    		update validLogic;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateWithActiveRuleMissingException() {
    	List<Custom_License_Rule__c> rules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	String invalidStr = '({0} OR {1})';
    	Custom_License_Rule_Logic__c invalidLogic = new Custom_License_Rule_Logic__c(
    		object__c='Account',
    		logic__c=String.format(invalidStr, new String[]{rules.get(0).id, rules.get(1).id})
    	);
    	
    	try {
    		insert invalidLogic;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	Custom_License_Rule_Logic__c validLogic = new Custom_License_Rule_Logic__c(
    		object__c='Account',
    		logic__c=String.format('({0} OR {1}) AND {2}', new String[]{rules.get(0).id, rules.get(1).id, rules.get(2).id})
    	);
    	insert validLogic;
    	
    	try {
    		validLogic.logic__c = invalidStr;
    		update validLogic;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    } 
}