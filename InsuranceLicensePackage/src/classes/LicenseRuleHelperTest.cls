@isTest
private class LicenseRuleHelperTest {
    
    static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    
    static testmethod void testGetRuleIdArray() {
    	String ruleLogic = '005360000023PA6AAD | 005360000023PA6AAM & 005360000023PA7AAM';
    	Set<String> ruleIdArray = ruleHelper.getRuleIdArray(ruleLogic);
    	System.assertEquals(3, ruleIdArray.size());
    	for (String ruleId : ruleIdArray) {
    		System.assert(ruleLogic.contains(ruleId));	
    	}
    }
    
    static testmethod void testSetToStringWithQuotes() {
    	Set<String> strSet = new Set<String>{'005360000023PA6AAD','005360000023PA6AAM','005360000023PA7AAM'};
    	
    	String actual = LicenseRuleHelper.setToStringWithQuotes(strSet);
    	
    	System.assertEquals(3, actual.split(',').size());
    	for (String str : strSet) {
    		System.assert(actual.contains(str));	
    	}
    	
    	Set<Id> idSet = new Set<Id>{'005360000023PA6AAD','005360000023PA6AAM','005360000023PA7AAM'};
    	
    	actual = LicenseRuleHelper.setToStringWithQuotes(idSet);
    	
    	System.assertEquals(3, actual.split(',').size());
    	for (Id id : idSet) {
    		System.assert(actual.contains(String.valueOf(id)));	
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
        License__c license = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today(),
            Approved__c = false
        );
        insert license;
        Test.setCreatedDate(license.id, createdDate);     
        license = [select id, approved__c, expiration_date__c, NPN_Number__c, class__c, createdDate from license__c where id =: license.id];     

        // create and insert rules
        License_Rule__c booleanRule = new License_Rule__c(Object__c = 'Account', field__c = 'isDeleted', license_Field__c = AppConfig.getAppNamespacedName('approved__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        //License_Rule__c integerRule = new License_Rule__c(Object__c = 'Account', field__c = 'NumberOfEmployees', license_Field__c = AppConfig.getAppNamespacedName('approved__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        //License_Rule__c doubleRule = new License_Rule__c(Object__c = 'Account', field__c = 'isDeleted', license_Field__c = AppConfig.getAppNamespacedName('approved__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c dateRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', license_Field__c = AppConfig.getAppNamespacedName('Expiration_Date__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c dateTimeRule = new License_Rule__c(Object__c = 'Account', field__c = 'createdDate', license_Field__c = 'createdDate', operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c textRule = new License_Rule__c(Object__c = 'Account', field__c = 'description', license_Field__c = AppConfig.getAppNamespacedName('NPN_Number__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c textRule_blankFields = new License_Rule__c(Object__c = 'Account', field__c = 'description', license_Field__c = AppConfig.getAppNamespacedName('Class__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        License_Rule__c textRule_notEqual = new License_Rule__c(Object__c = 'Account', field__c = 'name', license_Field__c = AppConfig.getAppNamespacedName('NPN_Number__c'), operator__c = 'not equal to', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        License_Rule__c textRule_notEqual_oneBlankField = new License_Rule__c(Object__c = 'Account', field__c = 'description', license_Field__c = AppConfig.getAppNamespacedName('NPN_Number__c'), operator__c = 'not equal to', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                
        insert new List<License_Rule__c>{booleanRule, dateRule, dateTimeRule, textRule, textRule_blankFields, textRule_notEqual};

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
        License__c license = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today(),
            Approved__c = false
        );
        insert license;    
        Test.setCreatedDate(license.id, createdDate);     
        license = [select id, name, expiration_date__c, createdDate from license__c where id =: license.id];                  

        // create and insert rules
        //License_Rule__c integerRule = new License_Rule__c(Object__c = 'Account', field__c = 'NumberOfEmployees', license_Field__c = AppConfig.getAppNamespacedName('approved__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        //License_Rule__c doubleRule = new License_Rule__c(Object__c = 'Account', field__c = 'isDeleted', license_Field__c = AppConfig.getAppNamespacedName('approved__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c dateRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', license_Field__c = AppConfig.getAppNamespacedName('Expiration_Date__c'), operator__c = 'greater than', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c dateRule_orEqual = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', license_Field__c = AppConfig.getAppNamespacedName('Expiration_Date__c'), operator__c = 'greater or equal', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        License_Rule__c dateTimeRule = new License_Rule__c(Object__c = 'Account', field__c = 'createdDate', license_Field__c = 'createdDate', operator__c = 'greater than', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c dateTimeRule_orEqual = new License_Rule__c(Object__c = 'Account', field__c = 'createdDate', license_Field__c = 'createdDate', operator__c = 'greater or equal', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        License_Rule__c textRule = new License_Rule__c(Object__c = 'Account', field__c = 'name', license_Field__c = 'name', operator__c = 'greater than', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c textRule_orEqual = new License_Rule__c(Object__c = 'Account', field__c = 'name', license_Field__c = 'name', operator__c = 'greater or equal', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        insert new List<License_Rule__c>{dateRule, dateRule_orEqual, dateTimeRule, dateTimeRule_orEqual, textRule, textRule_orEqual}; 

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
        License__c license = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today(),
            Approved__c = false
        );
        insert license;    
        Test.setCreatedDate(license.id, createdDate);     
        license = [select id, name, expiration_date__c, createdDate from license__c where id =: license.id];                  

        // create and insert rules
        //License_Rule__c integerRule = new License_Rule__c(Object__c = 'Account', field__c = 'NumberOfEmployees', license_Field__c = AppConfig.getAppNamespacedName('approved__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());        
        //License_Rule__c doubleRule = new License_Rule__c(Object__c = 'Account', field__c = 'isDeleted', license_Field__c = AppConfig.getAppNamespacedName('approved__c'), operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c dateRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', license_Field__c = AppConfig.getAppNamespacedName('Expiration_Date__c'), operator__c = 'less than', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c dateRule_orEqual = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', license_Field__c = AppConfig.getAppNamespacedName('Expiration_Date__c'), operator__c = 'less or equal', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                
        License_Rule__c dateTimeRule = new License_Rule__c(Object__c = 'Account', field__c = 'createdDate', license_Field__c = 'createdDate', operator__c = 'less than', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c dateTimeRule_orEqual = new License_Rule__c(Object__c = 'Account', field__c = 'createdDate', license_Field__c = 'createdDate', operator__c = 'less or equal', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                
        License_Rule__c textRule = new License_Rule__c(Object__c = 'Account', field__c = 'name', license_Field__c = 'name', operator__c = 'less than', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());
        License_Rule__c textRule_orEqual = new License_Rule__c(Object__c = 'Account', field__c = 'name', license_Field__c = 'name', operator__c = 'less or equal', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                
        insert new List<License_Rule__c>{dateRule, dateRule_orEqual, dateTimeRule, dateTimeRule_orEqual, textRule, textRule_orEqual}; 

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
        License__c license = new License__c(
            State__c = 'California',
            RecordTypeId = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId(),
            NPN_Number__c = '123',
            Number__c = '123',
            Effective_Date__c = Date.today().addDays(-1),
            Expiration_Date__c = Date.today(),
            Approved__c = false
        );
        insert license;    
        Test.setCreatedDate(license.id, createdDate);     
        license = [select id, name, expiration_date__c, createdDate from license__c where id =: license.id]; 

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
            License_Rule__c invalidOperatorRule_comparison = new License_Rule__c(Object__c = 'Account', field__c = 'name', license_Field__c = 'name', operator__c = 'invalid', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('License Comparison Rule').getRecordTypeId());                                                            
            helper.evaluateLicenseComparisonRule((sObject)account, invalidOperatorRule_comparison, license, objFieldsByName);
        } catch (LicenseRuleException e) {
            licenseRuleException5 = e;
        }
        System.assert(licenseRuleException5 != null);
        // end evaluateLicenseComparisonRule Tests ----------------------------------------------

        // handleStartsWith Tests ---------------------------------------------------------------
        Exception licenseRuleException6;
        try {
            License_Rule__c startsWithRule = new License_Rule__c(Object__c = 'Account', field__c = 'NumberOfEmployees', value__c = 'test', operator__c = 'starts with', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                            
            helper.evaluateRegularFilterRule((sObject)account, startsWithRule, objFieldsByName);    
        } catch (LicenseRuleException e) {
            licenseRuleException6 = e;
        }
        System.assert(licenseRuleException6 != null);
        // end handleStartsWith Tests--------------------------------------------------------------

        // handleContains Tests ---------------------------------------------------------------
        Exception licenseRuleException7;
        try {
            License_Rule__c containsRule = new License_Rule__c(Object__c = 'Account', field__c = 'NumberOfEmployees', value__c = 'test', operator__c = 'contains', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
            helper.evaluateRegularFilterRule((sObject)account, containsRule, objFieldsByName);    
        } catch (LicenseRuleException e) {
            licenseRuleException7 = e;
        }
        System.assert(licenseRuleException7 != null);
        // end handleContains Tests--------------------------------------------------------------

        // handleIn Tests ---------------------------------------------------------------
        Exception licenseRuleException8;
        try {
            License_Rule__c inRule = new License_Rule__c(Object__c = 'Account', field__c = 'createdDate', value__c = 'test account, new account', operator__c = 'in', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
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
            License_Rule__c invalidOperatorRule_filter = new License_Rule__c(Object__c = 'Account', field__c = 'NumberOfEmployees', value__c = '100', operator__c = 'invalid', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                
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
        License_Rule__c equalsRule = new License_Rule__c(Object__c = 'Account', field__c = 'NumberOfEmployees', value__c = '100', operator__c = 'equals', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                
        License_Rule__c greaterThanRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', value__c = String.valueOf(Date.today()), operator__c = 'greater than', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                        
        License_Rule__c greaterOrEqualRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', value__c = String.valueOf(Date.today()), operator__c = 'greater or equal', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                
        License_Rule__c lessThanRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', value__c = String.valueOf(Date.today()), operator__c = 'less than', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                        
        License_Rule__c lessOrEqualRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', value__c = String.valueOf(Date.today()), operator__c = 'less or equal', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                        
        License_Rule__c notEqualRule = new License_Rule__c(Object__c = 'Opportunity', field__c = 'closeDate', value__c = String.valueOf(Date.today()), operator__c = 'not equal to', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        License_Rule__c startsWithRule = new License_Rule__c(Object__c = 'Account', field__c = 'name', value__c = 'test', operator__c = 'starts with', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        License_Rule__c containsRule = new License_Rule__c(Object__c = 'Account', field__c = 'name', value__c = 'test', operator__c = 'contains', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        License_Rule__c doesNotContainRule = new License_Rule__c(Object__c = 'Account', field__c = 'name', value__c = 'abc', operator__c = 'does not contain', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        License_Rule__c inRule = new License_Rule__c(Object__c = 'Account', field__c = 'name', value__c = 'test account, new account', operator__c = 'in', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                
        License_Rule__c notInRule = new License_Rule__c(Object__c = 'Account', field__c = 'name', value__c = 'real account, old account', operator__c = 'not in', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                                                                
        License_Rule__c notBlankRule = new License_Rule__c(Object__c = 'Account', field__c = 'name', operator__c = 'not blank', isActive__c = true, recordTypeId = Schema.SObjectType.License_Rule__c.getRecordTypeInfosByName().get('Regular Filter Rule').getRecordTypeId());                                                                                                        
        insert new List<License_Rule__c>{
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