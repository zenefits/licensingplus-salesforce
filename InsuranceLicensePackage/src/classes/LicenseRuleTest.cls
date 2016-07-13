@isTest
private class LicenseRuleTest {
    static testMethod void testInsertUpdateInvalidSObject() {
    	licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=LicenseRuleTestDataSeeder.INVALID_OBJECT,
	    		licensingplus__field__c='Name',
	    		licensingplus__operator__c='equals',
	    		licensingplus__value__c='1234',
	    		licensingplus__isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.licensingplus__object__c = LicenseRuleTestDataSeeder.ACCOUNT_OBJ;
    	insert rule;
    	
    	try {
    		rule.licensingplus__object__c=LicenseRuleTestDataSeeder.INVALID_OBJECT;
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidLicenseField() {
    	licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		licensingplus__license_field__c=LicenseRuleTestDataSeeder.INVALID_REFERENCE_FIELD,
	    		licensingplus__operator__c='equals',
	    		licensingplus__value__c='1234',
	    		licensingplus__isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.licenseFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.licensingplus__license_field__c = 'Name';
    	insert rule;
    	
    	try {
    		rule.licensingplus__license_field__c=LicenseRuleTestDataSeeder.INVALID_FIELD;
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidField() {
    	licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		licensingplus__field__c=LicenseRuleTestDataSeeder.INVALID_FIELD,
	    		licensingplus__operator__c='equals',
	    		licensingplus__value__c='1234',
	    		licensingplus__isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.licensingplus__field__c = 'Name';
    	insert rule;
    	
    	try {
    		rule.licensingplus__field__c=LicenseRuleTestDataSeeder.INVALID_FIELD;
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidOperator() {
    	licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		licensingplus__field__c='LastModifiedDate',
	    		licensingplus__operator__c='contains',
	    		licensingplus__value__c='1234',
	    		licensingplus__isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.licensingplus__field__c = 'Name';
    	insert rule;
    	
    	try {
    		rule.licensingplus__field__c='LastModifiedDate';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidBooleanFieldValue() {
    	licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		licensingplus__field__c='IsDeleted',
	    		licensingplus__operator__c='equals',
	    		licensingplus__value__c='12345',
	    		licensingplus__isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.licensingplus__value__c = 'true';
    	insert rule;
    	
    	try {
    		rule.licensingplus__value__c='12345';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidNumberFieldValue() {
    	licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		licensingplus__field__c='AnnualRevenue',
	    		licensingplus__operator__c='less than',
	    		licensingplus__value__c='thx',
	    		licensingplus__isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.licensingplus__value__c = '12345';
    	insert rule;
    	
    	try {
    		rule.licensingplus__value__c='thx';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidDateFieldValue() {
    	licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		licensingplus__field__c='LastModifiedDate',
	    		licensingplus__operator__c='greater than',
	    		licensingplus__value__c='20101123',
	    		licensingplus__isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.licensingplus__value__c = '2005-10-08 01:02:03';
    	insert rule;
    	
    	try {
    		rule.licensingplus__value__c='20101123';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidDatetimeFieldValue() {
    	licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		licensingplus__field__c='LastActivityDate',
	    		licensingplus__operator__c='greater or equal',
	    		licensingplus__value__c='20101123',
	    		licensingplus__isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.licensingplus__value__c = '2005-10-08';
    	insert rule;
    	
    	try {
    		rule.licensingplus__value__c='20101123';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertDuplicateStateLicenseResidentLicenseWillFail() {
    	LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	
    	try {
    		LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	LicenseRuleTestDataSeeder.createValidResidentLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	
    	try {
    		LicenseRuleTestDataSeeder.createValidResidentLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
}