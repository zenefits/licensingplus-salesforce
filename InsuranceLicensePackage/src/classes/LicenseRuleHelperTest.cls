@isTest
private class LicenseRuleHelperTest {
    
    static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    
    static testmethod void testGetRuleIdArray() {
    	String ruleLogic = '000000000000000000 | 005360000023PA6AAM & 005360000023PA7AAM';
    	Set<String> ruleIdArray = ruleHelper.getRuleIdArray(ruleLogic);
    	System.assertEquals(3, ruleIdArray.size());
    	for (String ruleId : ruleIdArray) {
    		System.assert(ruleLogic.contains(ruleId));	
    	}
    }
    
    static testmethod void testSetToStringWithQuotes() {
    	Set<String> strSet = new Set<String>{'000000000000000000','005360000023PA6AAM','005360000023PA7AAM'};
    	
    	String actual = LicenseRuleHelper.setToStringWithQuotes(strSet);
    	
    	System.assertEquals(3, actual.split(',').size());
    	for (String str : strSet) {
    		System.assert(actual.contains(str));	
    	}
    }
    
    static testmethod void testSetToStringWithoutQuotes() {
    	Set<String> strSet = new Set<String>{'000000000000000000','005360000023PA6AAM','005360000023PA7AAM'};
    	
    	String actual = LicenseRuleHelper.setToStringWithoutQuotes(strSet);
    	
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

    static testmethod void testEvaluateLicenseComparisonRule_equals() {
        // set up map of object names and and corresponding fields to pass into helper method
        Map<String, Map<String, Schema.SObjectField>> objFieldsByName = new Map<String, Map<String, Schema.sObjectField>>();
        Map<String, Schema.SObjectField> accountFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> opportunityFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        objFieldsByName.put('Account', accountFields);
        objFieldsByName.put('Opportunity', opportunityFields);

        // set up a createdDate to use for multiple objects to test DateTime
        DateTime createdDate = DateTime.newInstance(2016, 1, 1);

        // insert account, then query for it to pull required values
        Account account = new Account(name='test', description = '123');
        insert account;
        Test.setCreatedDate(account.id, createdDate);
        account = [select name, isDeleted, description, createdDate from account where id =: account.id];

        Account account2 = new Account(name='test2');
        insert account2;

        // insert opportunity
        Opportunity opportunity = new Opportunity(name = 'test', closeDate = Date.today(), accountId = account.id, stageName = 'Prospecting');
        insert opportunity;

        // insert license
        licensingplus__License__c license = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today(),
            licensingplus__Approved__c = false
        );
        insert license;
        Test.setCreatedDate(license.id, createdDate);     
        license = [select id, licensingplus__approved__c, licensingplus__expiration_date__c, licensingplus__NPN_Number__c, licensingplus__class__c, createdDate from licensingplus__license__c where id =: license.id];     

        // create and insert rules
        licensingplus__License_Rule__c booleanRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'isDeleted', licensingplus__license_Field__c = 'licensingplus__approved__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        //licensingplus__License_Rule__c integerRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'NumberOfEmployees', licensingplus__license_Field__c = 'licensingplus__approved__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        //licensingplus__License_Rule__c doubleRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'isDeleted', licensingplus__license_Field__c = 'licensingplus__approved__c', licensingplus__perator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c dateRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__license_Field__c = 'licensingplus__Expiration_Date__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c dateTimeRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'createdDate', licensingplus__license_Field__c = 'createdDate', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c textRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'description', licensingplus__license_Field__c = 'licensingplus__NPN_Number__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c textRule_blankFields = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'description', licensingplus__license_Field__c = 'licensingplus__Class__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        licensingplus__License_Rule__c textRule_notEqual = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__license_Field__c = 'licensingplus__NPN_Number__c', licensingplus__operator__c = 'not equal to', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        licensingplus__License_Rule__c textRule_notEqual_oneBlankField = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'description', licensingplus__license_Field__c = 'licensingplus__NPN_Number__c', licensingplus__operator__c = 'not equal to', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                
        insert new List<licensingplus__License_Rule__c>{booleanRule, dateRule, dateTimeRule, textRule, textRule_blankFields, textRule_notEqual};

        test.startTest();
        LicenseRuleHelper helper = new LicenseRuleHelper();
        Boolean booleanResult = helper.evaluateLicenseComparisonRule((sObject)account, booleanRule, license, objFieldsByName);
        Boolean dateResult = helper.evaluateLicenseComparisonRule((sObject)opportunity, dateRule, license, objFieldsByName);
        Boolean dateTimeResult = helper.evaluateLicenseComparisonRule((sObject)account, dateTimeRule, license, objFieldsByName);
        Boolean textResult = helper.evaluateLicenseComparisonRule((sObject)account, textRule, license, objFieldsByName);
        Boolean textResult_blankFields = helper.evaluateLicenseComparisonRule((sObject)account2, textRule_blankFields, license, objFieldsByName);        
        Boolean textResult_notEqual = helper.evaluateLicenseComparisonRule((sObject)account, textRule_notEqual, license, objFieldsByName);
        Boolean textResult_notEqual_oneBlankField = helper.evaluateLicenseComparisonRule((sObject)account2, textRule_notEqual_oneBlankField, license, objFieldsByName);        
        test.stopTest();
        
        system.assertEquals(true, booleanResult);
        system.assertEquals(true, dateResult);
        system.assertEquals(true, dateTimeResult);
        system.assertEquals(true, textResult);
        system.assertEquals(true, textResult_blankFields);
        system.assertEquals(true, textResult_notEqual);
        system.assertEquals(true, textResult_notEqual_oneBlankField);
    }

    static testmethod void testEvaluateLicenseComparisonRule_greaterThan() {
        // set up map of object names and and corresponding fields to pass into helper method
        Map<String, Map<String, Schema.SObjectField>> objFieldsByName = new Map<String, Map<String, Schema.sObjectField>>();
        Map<String, Schema.SObjectField> accountFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> opportunityFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        objFieldsByName.put('Account', accountFields);
        objFieldsByName.put('Opportunity', opportunityFields);

        // set up a createdDate to use for multiple objects to test DateTime
        DateTime createdDate = DateTime.newInstance(2016, 1, 1);        

        // insert account
        Account account = new Account(name='zzzzzz test');
        insert account;
        Test.setCreatedDate(account.id, createdDate.addDays(7));
        account = [select name, createdDate from account where id =: account.id];        

        // insert opportunity
        Opportunity opportunity = new Opportunity(name = 'test', closeDate = Date.today().addDays(7), accountId = account.id, stageName = 'Prospecting');
        insert opportunity;

        // insert license
        licensingplus__License__c license = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today(),
            licensingplus__Approved__c = false
        );
        insert license;    
        Test.setCreatedDate(license.id, createdDate);     
        license = [select id, name, licensingplus__expiration_date__c, createdDate from licensingplus__license__c where id =: license.id];                  

        // create and insert rules
        //licensingplus__License_Rule__c integerRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'NumberOfEmployees', licensingplus__license_Field__c = 'licensingplus__approved__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        //licensingplus__License_Rule__c doubleRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'isDeleted', licensingplus__license_Field__c = 'licensingplus__approved__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c dateRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__license_Field__c = 'licensingplus__Expiration_Date__c', licensingplus__operator__c = 'greater than', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c dateRule_orEqual = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__license_Field__c = 'licensingplus__Expiration_Date__c', licensingplus__operator__c = 'greater or equal', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        licensingplus__License_Rule__c dateTimeRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'createdDate', licensingplus__license_Field__c = 'createdDate', licensingplus__operator__c = 'greater than', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c dateTimeRule_orEqual = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'createdDate', licensingplus__license_Field__c = 'createdDate', licensingplus__operator__c = 'greater or equal', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        licensingplus__License_Rule__c textRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__license_Field__c = 'name', licensingplus__operator__c = 'greater than', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c textRule_orEqual = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__license_Field__c = 'name', licensingplus__operator__c = 'greater or equal', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        insert new List<licensingplus__License_Rule__c>{dateRule, dateRule_orEqual, dateTimeRule, dateTimeRule_orEqual, textRule, textRule_orEqual}; 

        test.startTest();
        LicenseRuleHelper helper = new LicenseRuleHelper();
        Boolean dateResult = helper.evaluateLicenseComparisonRule((sObject)opportunity, dateRule, license, objFieldsByName);
        Boolean dateResult_orEqual = helper.evaluateLicenseComparisonRule((sObject)opportunity, dateRule_orEqual, license, objFieldsByName);        
        Boolean dateTimeResult = helper.evaluateLicenseComparisonRule((sObject)account, dateTimeRule, license, objFieldsByName);
        Boolean dateTimeResult_orEqual = helper.evaluateLicenseComparisonRule((sObject)account, dateTimeRule_orEqual, license, objFieldsByName);        
        Boolean textResult = helper.evaluateLicenseComparisonRule((sObject)account, textRule, license, objFieldsByName);
        Boolean textResult_orEqual = helper.evaluateLicenseComparisonRule((sObject)account, textRule_orEqual, license, objFieldsByName);        
        test.stopTest();
        
        system.assertEquals(true, dateResult);
        system.assertEquals(true, dateResult_orEqual);
        system.assertEquals(true, dateTimeResult);
        system.assertEquals(true, dateTimeResult_orEqual);
        system.assertEquals(true, textResult);    
        system.assertEquals(true, textResult_orEqual);                
    }    

    static testmethod void testEvaluateLicenseComparisonRule_lessThan() {
        // set up map of object names and and corresponding fields to pass into helper method
        Map<String, Map<String, Schema.SObjectField>> objFieldsByName = new Map<String, Map<String, Schema.sObjectField>>();
        Map<String, Schema.SObjectField> accountFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> opportunityFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        objFieldsByName.put('Account', accountFields);
        objFieldsByName.put('Opportunity', opportunityFields);

        // set up a createdDate to use for multiple objects to test DateTime
        DateTime createdDate = DateTime.newInstance(2016, 1, 1);        

        // insert account
        Account account = new Account(name='aaaaaaa test');
        insert account;
        Test.setCreatedDate(account.id, createdDate.addDays(-7));
        account = [select name, createdDate from account where id =: account.id];        

        // insert opportunity
        Opportunity opportunity = new Opportunity(name = 'test', closeDate = Date.today().addDays(-7), accountId = account.id, stageName = 'Prospecting');
        insert opportunity;

        // insert license
        licensingplus__License__c license = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today(),
            licensingplus__Approved__c = false
        );
        insert license;    
        Test.setCreatedDate(license.id, createdDate);     
        license = [select id, name, licensingplus__expiration_date__c, createdDate from licensingplus__license__c where id =: license.id];                  

        // create and insert rules
        //licensingplus__License_Rule__c integerRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'NumberOfEmployees', licensingplus__license_Field__c = 'licensingplus__approved__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        //licensingplus__License_Rule__c doubleRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'isDeleted', licensingplus__license_Field__c = 'licensingplus__approved__c', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c dateRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__license_Field__c = 'licensingplus__Expiration_Date__c', licensingplus__operator__c = 'less than', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c dateRule_orEqual = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__license_Field__c = 'licensingplus__Expiration_Date__c', licensingplus__operator__c = 'less or equal', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                
        licensingplus__License_Rule__c dateTimeRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'createdDate', licensingplus__license_Field__c = 'createdDate', licensingplus__operator__c = 'less than', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c dateTimeRule_orEqual = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'createdDate', licensingplus__license_Field__c = 'createdDate', licensingplus__operator__c = 'less or equal', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                
        licensingplus__License_Rule__c textRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__license_Field__c = 'name', licensingplus__operator__c = 'less than', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        licensingplus__License_Rule__c textRule_orEqual = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__license_Field__c = 'name', licensingplus__operator__c = 'less or equal', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                
        insert new List<licensingplus__License_Rule__c>{dateRule, dateRule_orEqual, dateTimeRule, dateTimeRule_orEqual, textRule, textRule_orEqual}; 

        test.startTest();
        LicenseRuleHelper helper = new LicenseRuleHelper();
        Boolean dateResult = helper.evaluateLicenseComparisonRule((sObject)opportunity, dateRule, license, objFieldsByName);
        Boolean dateResult_orEqual = helper.evaluateLicenseComparisonRule((sObject)opportunity, dateRule_orEqual, license, objFieldsByName);             
        Boolean dateTimeResult = helper.evaluateLicenseComparisonRule((sObject)account, dateTimeRule, license, objFieldsByName);
        Boolean dateTimeResult_orEqual = helper.evaluateLicenseComparisonRule((sObject)account, dateTimeRule_orEqual, license, objFieldsByName);            
        Boolean textResult = helper.evaluateLicenseComparisonRule((sObject)account, textRule, license, objFieldsByName);
        Boolean textResult_orEqual = helper.evaluateLicenseComparisonRule((sObject)account, textRule_orEqual, license, objFieldsByName);           
        test.stopTest();
        
        system.assertEquals(true, dateResult);
        system.assertEquals(true, dateResult_orEqual);
        system.assertEquals(true, dateTimeResult);
        system.assertEquals(true, dateTimeResult_orEqual);
        system.assertEquals(true, textResult);    
        system.assertEquals(true, textResult_orEqual);               
    }  

    static testmethod void testErrors() {
        // set up map of object names and and corresponding fields to pass into helper method
        Map<String, Map<String, Schema.SObjectField>> objFieldsByName = new Map<String, Map<String, Schema.sObjectField>>();
        Map<String, Schema.SObjectField> accountFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> opportunityFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        objFieldsByName.put('Account', accountFields);
        objFieldsByName.put('Opportunity', opportunityFields);

        // set up a createdDate to use for multiple objects to test DateTime
        DateTime createdDate = DateTime.newInstance(2016, 1, 1);        

        // insert account
        Account account = new Account(name='zzzzzz test', NumberOfEmployees = 100);
        insert account;
        Test.setCreatedDate(account.id, createdDate.addDays(7));
        account = [select name, numberOfEmployees, createdDate from account where id =: account.id];        

        // insert opportunity
        Opportunity opportunity = new Opportunity(name = 'test', closeDate = Date.today().addDays(7), accountId = account.id, stageName = 'Prospecting');
        insert opportunity;

        // insert license
        licensingplus__License__c license = new licensingplus__License__c(
            licensingplus__State__c = 'California',
            RecordTypeId = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            licensingplus__NPN_Number__c = '123',
            licensingplus__Number__c = '123',
            licensingplus__Effective_Date__c = Date.today().addDays(-1),
            licensingplus__Expiration_Date__c = Date.today(),
            licensingplus__Approved__c = false
        );
        insert license;    
        Test.setCreatedDate(license.id, createdDate);     
        license = [select id, name, licensingplus__expiration_date__c, createdDate from licensingplus__license__c where id =: license.id]; 

        // define helper
        LicenseRuleHelper helper = new LicenseRuleHelper();

        // validateAndGetSObjectField Tests -----------------------------------------------------        
        // validateAndGetSObjectField - invalid object
        Exception licenseRuleException1;
        try {
            helper.validateAndGetSObjectField('Contact', 'Account', 'name', objFieldsByName);
        } catch (LicenseRuleException e) {
            licenseRuleException1 = e;
        }
        System.assert(licenseRuleException1 != null);

        // validateAndGetSObjectField - invalid reference object
        Exception licenseRuleException2;
        try {
            helper.validateAndGetSObjectField('Account', 'Abc__c', 'name', objFieldsByName);
        } catch (LicenseRuleException e) {
            licenseRuleException2 = e;
        }
        System.assert(licenseRuleException2 != null);  

        // validateAndGetSObjectField - invalid object field, with reference
        Exception licenseRuleException3;
        try {
            helper.validateAndGetSObjectField('Account', 'Opportunity', 'asdf__c', objFieldsByName);
        } catch (LicenseRuleException e) {
            licenseRuleException3 = e;
        }
        System.assert(licenseRuleException3 != null);      

        // validateAndGetSObjectField - invalid object field, without reference
        Exception licenseRuleException4;
        try {
            helper.validateAndGetSObjectField('Account', null, 'asdf__c', objFieldsByName);
        } catch (LicenseRuleException e) {
            licenseRuleException4 = e;
        }
        System.assert(licenseRuleException4 != null); 
        // end validateAndGetSObjectField Tests ------------------------------------------------

        // evaluateLicenseComparisonRule Tests --------------------------------------------------
        Exception licenseRuleException5;
        try {
            // don't insert record - this avoids pre-validation
            licensingplus__License_Rule__c invalidOperatorRule_comparison = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__license_Field__c = 'name', licensingplus__operator__c = 'invalid', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                                                            
            helper.evaluateLicenseComparisonRule((sObject)account, invalidOperatorRule_comparison, license, objFieldsByName);
        } catch (LicenseRuleException e) {
            licenseRuleException5 = e;
        }
        System.assert(licenseRuleException5 != null);
        // end evaluateLicenseComparisonRule Tests ----------------------------------------------

        // handleStartsWith Tests ---------------------------------------------------------------
        Exception licenseRuleException6;
        try {
            licensingplus__License_Rule__c startsWithRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'NumberOfEmployees', licensingplus__value__c = 'test', licensingplus__operator__c = 'starts with', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                            
            helper.evaluateRegularFilterRule((sObject)account, startsWithRule, objFieldsByName);    
        } catch (LicenseRuleException e) {
            licenseRuleException6 = e;
        }
        System.assert(licenseRuleException6 != null);
        // end handleStartsWith Tests--------------------------------------------------------------

        // handleContains Tests ---------------------------------------------------------------
        Exception licenseRuleException7;
        try {
            licensingplus__License_Rule__c containsRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'NumberOfEmployees', licensingplus__value__c = 'test', licensingplus__operator__c = 'contains', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
            helper.evaluateRegularFilterRule((sObject)account, containsRule, objFieldsByName);    
        } catch (LicenseRuleException e) {
            licenseRuleException7 = e;
        }
        System.assert(licenseRuleException7 != null);
        // end handleContains Tests--------------------------------------------------------------

        // handleIn Tests ---------------------------------------------------------------
        Exception licenseRuleException8;
        try {
            licensingplus__License_Rule__c inRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'createdDate', licensingplus__value__c = 'test account, new account', licensingplus__operator__c = 'in', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
            helper.evaluateRegularFilterRule((sObject)account, inRule, objFieldsByName);    
        } catch (LicenseRuleException e) {
            licenseRuleException8 = e;
        }
        System.assert(licenseRuleException8 != null);
        // end handleIn Tests--------------------------------------------------------------  

        // evaluateFilterRule Tests --------------------------------------------------
        Exception licenseRuleException9;
        try {
            // don't insert record - this avoids pre-validation
            licensingplus__License_Rule__c invalidOperatorRule_filter = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'NumberOfEmployees', licensingplus__value__c = '100', licensingplus__operator__c = 'invalid', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                
            helper.evaluateRegularFilterRule((sObject)account, invalidOperatorRule_filter, objFieldsByName);
        } catch (LicenseRuleException e) {
            licenseRuleException9 = e;
        }
        System.assert(licenseRuleException9 != null);
        // end evaluateFilterRule Tests ----------------------------------------------              

    }

    static testmethod void testEvaluateRegularFilterRules() {
        // set up map of object names and and corresponding fields to pass into helper method
        Map<String, Map<String, Schema.SObjectField>> objFieldsByName = new Map<String, Map<String, Schema.sObjectField>>();
        Map<String, Schema.SObjectField> accountFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> opportunityFields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();        
        objFieldsByName.put('Account', accountFields);
        objFieldsByName.put('Opportunity', opportunityFields);        

        // insert account
        Account account = new Account(name='test account', NumberOfEmployees = 100);
        insert account;

        // insert opportunities
        Opportunity opp1 = new Opportunity(name = 'test1', closeDate = Date.today().addDays(7), accountId = account.id, stageName = 'Prospecting');
        Opportunity opp2 = new Opportunity(name = 'test2', closeDate = Date.today().addDays(-7), accountId = account.id, stageName = 'Prospecting');        
        insert new List<Opportunity>{opp1, opp2};           

        // create and insert rules
        licensingplus__License_Rule__c equalsRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'NumberOfEmployees', licensingplus__value__c = '100', licensingplus__operator__c = 'equals', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                
        licensingplus__License_Rule__c greaterThanRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__value__c = String.valueOf(Date.today()), licensingplus__operator__c = 'greater than', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                        
        licensingplus__License_Rule__c greaterOrEqualRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__value__c = String.valueOf(Date.today()), licensingplus__operator__c = 'greater or equal', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                
        licensingplus__License_Rule__c lessThanRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__value__c = String.valueOf(Date.today()), licensingplus__operator__c = 'less than', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                        
        licensingplus__License_Rule__c lessOrEqualRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__value__c = String.valueOf(Date.today()), licensingplus__operator__c = 'less or equal', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                        
        licensingplus__License_Rule__c notEqualRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Opportunity', licensingplus__field__c = 'closeDate', licensingplus__value__c = String.valueOf(Date.today()), licensingplus__operator__c = 'not equal to', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        licensingplus__License_Rule__c startsWithRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__value__c = 'test', licensingplus__operator__c = 'starts with', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        licensingplus__License_Rule__c containsRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__value__c = 'test', licensingplus__operator__c = 'contains', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        licensingplus__License_Rule__c doesNotContainRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__value__c = 'abc', licensingplus__operator__c = 'does not contain', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        licensingplus__License_Rule__c inRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__value__c = 'test account, new account', licensingplus__operator__c = 'in', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        licensingplus__License_Rule__c notInRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__value__c = 'real account, old account', licensingplus__operator__c = 'not in', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                                                                
        licensingplus__License_Rule__c notBlankRule = new licensingplus__License_Rule__c(licensingplus__Object__c = 'Account', licensingplus__field__c = 'name', licensingplus__operator__c = 'not blank', licensingplus__isActive__c = true, recordTypeId = Schema.SObjectType.licensingplus__License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                                                                        
        insert new List<licensingplus__License_Rule__c>{
            equalsRule, 
            greaterThanRule, 
            greaterOrEqualRule, 
            lessThanRule, 
            lessOrEqualRule, 
            notEqualRule, 
            startsWithRule, 
            containsRule, 
            doesNotContainRule,
            inRule, 
            notInRule,
            notBlankRule
        };     

        test.startTest();
        LicenseRuleHelper helper = new LicenseRuleHelper();
        Boolean equalsResult = helper.evaluateRegularFilterRule((sObject)account, equalsRule, objFieldsByName);
        Boolean greaterThanResult = helper.evaluateRegularFilterRule((sObject)opp1, greaterThanRule, objFieldsByName);
        Boolean greaterOrEqualResult = helper.evaluateRegularFilterRule((sObject)opp1, greaterOrEqualRule, objFieldsByName); 
        Boolean lessThanResult = helper.evaluateRegularFilterRule((sObject)opp2, lessThanRule, objFieldsByName);
        Boolean lessOrEqualResult = helper.evaluateRegularFilterRule((sObject)opp2, lessOrEqualRule, objFieldsByName);        
        Boolean notEqualResult = helper.evaluateRegularFilterRule((sObject)opp1, notEqualRule, objFieldsByName);    
        Boolean startsWithResult = helper.evaluateRegularFilterRule((sObject)account, startsWithRule, objFieldsByName);    
        Boolean containsResult = helper.evaluateRegularFilterRule((sObject)account, containsRule, objFieldsByName);    
        Boolean doesNotContainResult = helper.evaluateRegularFilterRule((sObject)account, doesNotContainRule, objFieldsByName);    
        Boolean inResult = helper.evaluateRegularFilterRule((sObject)account, inRule, objFieldsByName);    
        Boolean notInResult = helper.evaluateRegularFilterRule((sObject)account, notInRule, objFieldsByName); 
        Boolean notBlankResult = helper.evaluateRegularFilterRule((sObject)account, notBlankRule, objFieldsByName);             
        test.stopTest();
        
        system.assertEquals(true, equalsResult);
        system.assertEquals(true, greaterThanResult);
        system.assertEquals(true, greaterOrEqualResult);
        system.assertEquals(true, lessThanResult);
        system.assertEquals(true, lessOrEqualResult);   
        system.assertEquals(true, notEqualResult);  
        system.assertEquals(true, startsWithResult);
        system.assertEquals(true, containsResult);
        system.assertEquals(true, doesNotContainResult);
        system.assertEquals(true, inResult);
        system.assertEquals(true, notInResult);         
        system.assertEquals(true, notBlankResult);  
    }          
}