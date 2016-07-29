@isTest
private class LicenseRuleLogicTest {
    
    static testMethod void testInsertUpdateWithInvalidRuleId() {
    	License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);	
		List<License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);	
		License_Rule_Logic__c filterRuleLogicOne = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c licenseRuleLogicOne = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne, true);
    	
    	String invalidStr = String.format('({0} ! {1} & {2})', new String[]{regularFilterRulesOne.get(0).id, '123456', regularFilterRulesOne.get(2).id});
    	License_Rule_Logic__c invalidLogic = new License_Rule_Logic__c(
    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
    		logic__c=invalidStr,
    		recordtypeid=LicenseRuleHelper.filterRuleLogicRecordTypeId,
    		isActive__c=true
    	);
    	
    	try {
    		insert invalidLogic;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	try {
    		filterRuleLogicOne.logic__c = invalidStr;
    		update filterRuleLogicOne;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateWhenNoRegularFilterRuleButRegularFilterRuleSet() {
    	List<License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);	
    	String validStr = '({0} ! {1})';
    	License_Rule_Logic__c validLogic = new License_Rule_Logic__c(
    		object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
    		logic__c=String.format(validStr, new String[]{regularFilterRulesOne.get(0).id, regularFilterRulesOne.get(1).id}),
    		recordtypeid=LicenseRuleHelper.filterRuleLogicRecordTypeId
    	);
    	insert validLogic;
    	
    	List<License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
    	
    	try {
    		LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, validLogic, true);
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	validLogic.isActive__c = true;
    	update validLogic;
    	
		License_Rule_Logic__c licenseRuleLogic = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, validLogic, true);
    	
    	validLogic.isActive__c = false;
    	update validLogic;
    	
    	try {
    		update licenseRuleLogic;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    } 
}