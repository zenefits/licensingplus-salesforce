@isTest
private class LicenseRuleValidatorTest {
    
    static testmethod void testValidateLicenseRule() {
    	licensingplus__License_Rule__c comparisonRuleTypeNotSame = new licensingplus__License_Rule__c
    		(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__license_Field__c = 'name', licensingplus__operator__c = 'greater than', licensingplus__isActive__c = true, recordTypeId = LicenseRuleHelper.licenseComparisonRuleRecordTypeId);
    	
    	 licensingplus__License_Rule__c startsWithRuleShouldNotBeBoolean = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'isDeleted', licensingplus__value__c = 'test', licensingplus__operator__c = 'starts with', licensingplus__isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 
    	 licensingplus__License_Rule__c inRuleShouldNotBeBoolean = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'isDeleted', licensingplus__value__c = 'test', licensingplus__operator__c = 'in', licensingplus__isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 
    	 licensingplus__License_Rule__c invalidBooleanRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'isDeleted', licensingplus__value__c = 'test', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 licensingplus__License_Rule__c invalidDateRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closedate', licensingplus__value__c = 'test', licensingplus__operator__c = 'greater than', licensingplus__isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 licensingplus__License_Rule__c invalidDatetimeRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'lastmodifieddate', licensingplus__value__c = 'test', licensingplus__operator__c = 'greater than', licensingplus__isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	 licensingplus__License_Rule__c invalidNumberRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'numberOfEmployees', licensingplus__value__c = 'test', licensingplus__operator__c = 'greater than', licensingplus__isActive__c = true, recordTypeId = LicenseRuleHelper.regularFilterRuleRecordTypeId);                      
    	
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