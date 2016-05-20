@isTest
private class StandardLicenseRuleTest {
    
    static testMethod void testInsertUpdateWithInvalidObject() { 
    	Standard_License_Rule__c invalidRule = new Standard_License_Rule__c(object__c=LicenseRuleTestDataSeeder.INVALID_OBJECT,
    	field__c=LicenseRuleTestDataSeeder.INVALID_FIELD, type__c=StandardLicenseRuleValidator.STATE_RULE,
    	isActive__c=True);

    	try {
    		insert invalidRule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	// insert valid rule;
    	Standard_License_Rule__c validRule = new Standard_License_Rule__c(object__c='Account',
    	field__c='BillingState', type__c=StandardLicenseRuleValidator.STATE_RULE,
    	isActive__c=True);
    	insert validRule;
		validRule.object__c = LicenseRuleTestDataSeeder.INVALID_OBJECT;
    	
    	try {
    		update validRule;   
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  		
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateWithInvalidField() {
		Standard_License_Rule__c invalidRule = new Standard_License_Rule__c(object__c='Account',
    	field__c=LicenseRuleTestDataSeeder.INVALID_FIELD, type__c=StandardLicenseRuleValidator.STATE_RULE,
    	isActive__c=True);
    	
    	try {
    		insert invalidRule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	// insert valid rule;
    	Standard_License_Rule__c validRule = new Standard_License_Rule__c(object__c='Account',
    	field__c='BillingState', type__c=StandardLicenseRuleValidator.STATE_RULE,
    	isActive__c=True);
    	insert validRule;
		validRule.field__c = LicenseRuleTestDataSeeder.INVALID_FIELD;
    	
    	try {
    		update validRule;   
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  		
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateWithInvalidStateField() {
		Standard_License_Rule__c invalidRule = new Standard_License_Rule__c(object__c='Account',
    	field__c='ParentId', type__c=StandardLicenseRuleValidator.STATE_RULE,
    	isActive__c=True);
    	
    	try {
    		insert invalidRule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	// insert valid rule;
    	Standard_License_Rule__c validRule = new Standard_License_Rule__c(object__c='Account',
    	field__c='BillingState', type__c=StandardLicenseRuleValidator.STATE_RULE,
    	isActive__c=True);
    	insert validRule;
		validRule.field__c = 'ParentId';
    	
    	try {
    		update validRule;   
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  		
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }    
    
    static testMethod void testInsertValidRuleWithUniqueKeySet() {
    	Standard_License_Rule__c validRule = new Standard_License_Rule__c(object__c='Account',
    	field__c='BillingState', type__c=StandardLicenseRuleValidator.STATE_RULE,
    	isActive__c=True);
    	insert validRule;
    	
    	Standard_License_Rule__c rule = [SELECT id, unique_key__c FROM Standard_License_Rule__c where id=:validRule.id limit 1];
    	System.assertEquals(validRule.object__c+';'+validRule.field__c+';'+validRule.type__c, rule.unique_key__c);
    }
    
}