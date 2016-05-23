@isTest
private class LicenseRuleHelperTest {
    
    static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    
    static testmethod void testGetFormattedRules() {
    	List<Custom_License_Rule__c> crules = LicenseRuleTestDataSeeder.createValidCustomLicenseRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	Custom_License_Rule_Logic__c ruleLogic = LicenseRuleTestDataSeeder.createValidCustomLicenseRuleLogic(crules, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	
    	String expected = '(Name = \'Test1234\' OR Rating IN (\'hot\',\'warm\')) AND LastmodifiedDate > 2005-10-08T01:02:03Z';   	
    	String actual = ruleHelper.getFormattedRules(crules, ruleLogic);   	
    	System.assertEquals(expected, actual);
    	
    	Custom_License_Rule__c rule1 = crules.get(0);
    	Custom_License_Rule__c rule2 = crules.get(1);
    	Custom_License_Rule__c rule3 = crules.get(2);
    	
    	rule1.operator__c = 'starts with';
    	rule2.operator__c = 'contains';
    	rule2.value__c = 'hot';
    	rule3.operator__c = 'less than';
    	update crules;
    	
    	expected = '(Name LIKE \'%Test1234\' OR Rating LIKE \'%hot%\') AND LastmodifiedDate < 2005-10-08T01:02:03Z';   	
    	actual = ruleHelper.getFormattedRules(crules, ruleLogic);
    	System.assertEquals(expected, actual);
    	
    	rule1.operator__c = 'does not contain';
    	rule2.operator__c = 'excludes';
    	rule2.value__c = 'hot,warm';
    	rule3.operator__c = 'greater or equal';
    	update crules;
    	
    	expected = '(Name NOT LIKE \'%Test1234%\' OR Rating NOT IN (\'hot\',\'warm\')) AND LastmodifiedDate >= 2005-10-08T01:02:03Z';   	
    	actual = ruleHelper.getFormattedRules(crules, ruleLogic);
    	System.assertEquals(expected, actual);
    	
    	rule1.operator__c = 'not equal to';
    	rule2.reference_field__c = 'ParentId';
    	rule2.field__c = 'Name';
    	rule2.operator__c = 'equals';
    	rule2.value__c = 'test12345';
    	rule3.operator__c = 'less or equal';
    	update crules;
    	
    	expected = '(Name != \'Test1234\' OR Parent.Name = \'test12345\') AND LastmodifiedDate <= 2005-10-08T01:02:03Z';   	
    	actual = ruleHelper.getFormattedRules(crules, ruleLogic);
    	System.assertEquals(expected, actual);
    }
    
    static testmethod void testSetToStringWithQuotes() {
    	Set<Id> strSet = new Set<Id>{'000000000000000000','005360000023PA6AAM','005360000023PA7AAM'};
    	
    	String actual = LicenseRuleHelper.setToStringWithQuotes(strSet);
    	
    	System.assertEquals(3, actual.split(',').size());
    	for (String str : strSet) {
    		System.assert(actual.contains(str));	
    	}
    }
    
    static testmethod void testConvertCommaSeparatedStringToStringWithQuotes() {
    	String inputStr = 'a,b,c';
    	
    	String expected = '\'a\',\'b\',\'c\'';
    	String actual = LicenseRuleHelper.convertCommaSeparatedStringToStringWithQuotes(inputStr);
    	
    	System.assertEquals(expected, actual);
    }
}