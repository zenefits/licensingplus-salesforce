@isTest
private class LicenseRuleTest {
    static testMethod void testInsertUpdateInvalidSObject() {
    	License_Rule__c rule = new License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.INVALID_OBJECT,
	    		field__c='Name',
	    		operator__c='equals',
	    		value__c='1234',
	    		isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.object__c = LicenseRuleTestDataSeeder.ACCOUNT_OBJ;
    	insert rule;
    	
    	try {
    		rule.object__c=LicenseRuleTestDataSeeder.INVALID_OBJECT;
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidLicenseField() {
    	License_Rule__c rule = new License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		license_field__c=LicenseRuleTestDataSeeder.INVALID_REFERENCE_FIELD,
	    		operator__c='equals',
	    		value__c='1234',
	    		isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.licenseFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.license_field__c = 'Name';
    	insert rule;
    	
    	try {
    		rule.license_field__c=LicenseRuleTestDataSeeder.INVALID_FIELD;
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidField() {
    	License_Rule__c rule = new License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		field__c=LicenseRuleTestDataSeeder.INVALID_FIELD,
	    		operator__c='equals',
	    		value__c='1234',
	    		isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.field__c = 'Name';
    	insert rule;
    	
    	try {
    		rule.field__c=LicenseRuleTestDataSeeder.INVALID_FIELD;
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidOperator() {
    	License_Rule__c rule = new License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		field__c='LastModifiedDate',
	    		operator__c='contains',
	    		value__c='1234',
	    		isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.field__c = 'Name';
    	insert rule;
    	
    	try {
    		rule.field__c='LastModifiedDate';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidBooleanFieldValue() {
    	License_Rule__c rule = new License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		field__c='IsDeleted',
	    		operator__c='equals',
	    		value__c='12345',
	    		isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.value__c = 'true';
    	insert rule;
    	
    	try {
    		rule.value__c='12345';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidNumberFieldValue() {
    	License_Rule__c rule = new License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		field__c='AnnualRevenue',
	    		operator__c='less than',
	    		value__c='thx',
	    		isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.value__c = '12345';
    	insert rule;
    	
    	try {
    		rule.value__c='thx';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidDateFieldValue() {
    	License_Rule__c rule = new License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		field__c='LastModifiedDate',
	    		operator__c='greater than',
	    		value__c='20101123',
	    		isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.value__c = '2005-10-08 01:02:03';
    	insert rule;
    	
    	try {
    		rule.value__c='20101123';
    		update rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateInvalidDatetimeFieldValue() {
    	License_Rule__c rule = new License_Rule__c(
	    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
	    		field__c='LastActivityDate',
	    		operator__c='greater or equal',
	    		value__c='20101123',
	    		isActive__c=true,
	    		recordtypeid=LicenseRuleHelper.regularFilterRuleRecordTypeId
    	);
    	
    	try {
    		insert rule;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');  	
    	
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	rule.value__c = '2005-10-08';
    	insert rule;
    	
    	try {
    		rule.value__c='20101123';
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