@isTest
private class LicenseRuleValidatorTest {
    
    static testmethod void testValidateLicenseRule() {
    	License_Rule__c comparisonRuleTypeNotSame = new License_Rule__c
    		(Object__c = 'Opportunity', field__c = 'closeDate', license_Field__c = 'name', operator__c = 'greater than', isActive__c = true, recordTypeId = LicenseRuleHelper.licenseComparisonRuleRecordTypeId);
    	
    	 License_Rule__c startsWithRuleShouldNotBeBoolean = new License_Rule__c(Object__c = 'Account', field__c = 'isDeleted', value__c = 'test', operator__c = 'starts with', isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 
    	 License_Rule__c inRuleShouldNotBeBoolean = new License_Rule__c(Object__c = 'Account', field__c = 'isDeleted', value__c = 'test', operator__c = 'in', isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 
    	 License_Rule__c invalidBooleanRule = new License_Rule__c(Object__c = 'Account', field__c = 'isDeleted', value__c = 'test', operator__c = 'equals', isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 License_Rule__c invalidDateRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closedate', value__c = 'test', operator__c = 'greater than', isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 License_Rule__c invalidDatetimeRule = new License_Rule__c(Object__c = 'Account', field__c = 'lastmodifieddate', value__c = 'test', operator__c = 'greater than', isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 License_Rule__c invalidNumberRule = new License_Rule__c(Object__c = 'Account', field__c = 'numberOfEmployees', value__c = 'test', operator__c = 'greater than', isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	
    	try {
    		insert comparisonRuleTypeNotSame;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	try {
    		insert startsWithRuleShouldNotBeBoolean;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	try {
    		insert inRuleShouldNotBeBoolean;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	try {
    		insert invalidBooleanRule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	try {
    		insert invalidDateRule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	try {
    		insert invalidDatetimeRule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	try {
    		insert invalidNumberRule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}		 
    }
}