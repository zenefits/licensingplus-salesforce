@isTest
private class LicenseRuleLogicTest {
    
    static testMethod void testInsertUpdateWithInvalidRuleId() {
    	licensingplus__License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);	
		List<licensingplus__License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);	
		licensingplus__License_Rule_Logic__c filterRuleLogicOne = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<licensingplus__License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<licensingplus__License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		licensingplus__License_Rule_Logic__c licenseRuleLogicOne = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne, true);
    	
    	String invalidStr = String.format('({0} ! {1} & {2})', new String[]{regularFilterRulesOne.get(0).id, '123456', regularFilterRulesOne.get(2).id});
    	licensingplus__License_Rule_Logic__c invalidLogic = new licensingplus__License_Rule_Logic__c(
    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
    		licensingplus__logic__c=invalidStr,
    		recordtypeid=LicenseRuleHelper.filterRuleLogicRecordTypeId,
    		licensingplus__isActive__c=true
    	);
    	
    	try {
    		insert invalidLogic;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	try {
    		filterRuleLogicOne.licensingplus__logic__c = invalidStr;
    		update filterRuleLogicOne;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    }
    
    static testMethod void testInsertUpdateWhenNoRegularFilterRuleButRegularFilterRuleSet() {
    	List<licensingplus__License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);	
    	String validStr = '({0} ! {1})';
    	licensingplus__License_Rule_Logic__c validLogic = new licensingplus__License_Rule_Logic__c(
    		licensingplus__object__c=LicenseRuleTestDataSeeder.ACCOUNT_OBJ,
    		licensingplus__logic__c=String.format(validStr, new String[]{regularFilterRulesOne.get(0).id, regularFilterRulesOne.get(1).id}),
    		recordtypeid=LicenseRuleHelper.filterRuleLogicRecordTypeId
    	);
    	insert validLogic;
    	
    	List<licensingplus__License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<licensingplus__License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
    	
    	try {
    		LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, validLogic, true);
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    	
    	validLogic.licensingplus__isActive__c = true;
    	update validLogic;
    	
		licensingplus__License_Rule_Logic__c licenseRuleLogic = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, validLogic, true);
    	
    	validLogic.licensingplus__isActive__c = false;
    	update validLogic;
    	
    	try {
    		update licenseRuleLogic;
    		throw new LicenseRuleException('An exception should have been thrown by the trigger but was not.');
    	} catch (DMLException e) {
    		system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    	}
    } 
}