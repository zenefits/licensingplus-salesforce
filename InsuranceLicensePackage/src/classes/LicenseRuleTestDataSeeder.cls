public with sharing class LicenseRuleTestDataSeeder {
    
    public static final String ACCOUNT_OBJ = 'Account';
    public static final String CASE_OBJ = 'Case';
    public static final String OPPORTUNITY_OBJ = 'Opportunity';
    
    public static Map<String, List<Map<String, String>>> cfieldsByObj = new Map<String, List<Map<String, String>>>();
    public static Map<String, List<Map<String, String>>> sfieldsByObj = new Map<String, List<Map<String, String>>>();
        
    private static Map<String, Schema.RecordTypeInfo> licenseRecordTypes = Schema.SObjectType.License__c.getRecordTypeInfosByName();

    static {
    	List<Map<String, String>> accountCFieldsList = new List<Map<String, String>>();
    	cfieldsByObj.put(ACCOUNT_OBJ, accountCFieldsList);
    	
    	Map<String, String> accountFieldsMap1 = new Map<String, String>();
    	accountFieldsMap1.put('field__c', 'Name');
    	accountFieldsMap1.put('value__c', 'Test1234');
    	accountFieldsMap1.put('operator__c', 'equals');    	
    	accountCFieldsList.add(accountFieldsMap1);
    	
    	Map<String, String> accountFieldsMap2 = new Map<String, String>();
    	accountFieldsMap2.put('field__c', 'Rating');
    	accountFieldsMap2.put('value__c', 'hot,warm');
    	accountFieldsMap2.put('operator__c', 'includes');    	
    	accountCFieldsList.add(accountFieldsMap2);
    	
    	Map<String, String> accountFieldsMap3 = new Map<String, String>();
    	accountFieldsMap3.put('field__c', 'LastmodifiedDate');
    	accountFieldsMap3.put('value__c', '2005-10-08T01:02:03Z');
    	accountFieldsMap3.put('operator__c', 'greater than');    	
    	accountCFieldsList.add(accountFieldsMap3);
    	
    	List<Map<String, String>> accountSFieldsList = new List<Map<String, String>>();
    	sfieldsByObj.put(ACCOUNT_OBJ, accountSFieldsList);
    	Map<String, String> accountSFieldsMap1 = new Map<String, String>();
    	accountSFieldsMap1.put('field__c', 'BillingState');
    	accountSFieldsMap1.put('type__c', StandardLicenseRuleValidator.STATE_RULE);
    	accountSFieldsList.add(accountSFieldsMap1);
    	
    }
    
    public static List<Custom_License_Rule__c> createValidCustomLicenseRules(String objName) {
    	return createValidCustomLicenseRules(objName, true);
    }
    
    public static List<Custom_License_Rule__c> createValidCustomLicenseRules(String objName, Boolean isActive) {
    	List<Map<String, String>> objFieldsList = cfieldsByObj.get(objName);
    	List<Custom_License_Rule__c> rules = new List<Custom_License_Rule__c>();
    	
    	for (Map<String, String> objFields : objFieldsList) {
    		Custom_License_Rule__c rule = new Custom_License_Rule__c(
	    		object__c=objName,
	    		field__c=objFields.get('field__c'),
	    		operator__c=objFields.get('operator__c'),
	    		value__c=objFields.get('value__c'),
	    		isActive__c=isActive
    		);
    		
    		rules.add(rule);
    	}

    	insert rules; 
    	
    	return rules;	
    }
    
    public static Custom_License_Rule_Logic__c createValidCustomLicenseRuleLogic(List<Custom_License_Rule__c> rules, String objName) {
    	Custom_License_Rule_Logic__c validLogic = new Custom_License_Rule_Logic__c(
    		object__c=objName,
    		logic__c=String.format('({0} OR {1}) AND {2}', new String[]{rules.get(0).id, rules.get(1).id, rules.get(2).id})
    	);
    	insert validLogic;
    	
    	return validLogic;
    }
    
    public static Map<String, Standard_License_Rule__c> createValidStandardLicenseRule(String objName) {
    	return createValidStandardLicenseRule(objName, true);
    }
    
    public static Map<String, Standard_License_Rule__c> createValidStandardLicenseRule(String objName, Boolean isActive) {
    	List<Map<String, String>> objFieldsList = sfieldsByObj.get(objName);
    	List<Standard_License_Rule__c> rules = new List<Standard_License_Rule__c>();
    	Map<String, Standard_License_Rule__c> ruleByType = new Map<String, Standard_License_Rule__c>();
    	
    	for (Map<String, String> objFields : objFieldsList) {
    		Standard_License_Rule__c rule = new Standard_License_Rule__c(
	    		object__c=objName,
	    		field__c=objFields.get('field__c'), 
	    		type__c=objFields.get('type__c'),
	    		isActive__c=isActive
	    	);
	    	rules.add(rule);
	    	ruleByType.put(rule.type__c, rule);
    	}
    	
    	insert rules;
    	
    	return ruleByType;	
    }
    
    public static License__c createLicense(String ownerId, String state) {
    	License__c license = new License__c(
	        	OwnerId = ownerId, 
	            Name = 'CA License', 
	            RecordtypeId = licenseRecordTypes.get('Resident State').getRecordTypeId(), 
	            Number__c = '123', 
	            NPN_Number__c  = '123', 
	            Confirmation_ID__c = '123', 
	            State__c = state, 
	            Effective_Date__c = Date.today().addDays(-1), 
	            Expiration_Date__c = Date.today().addDays(1),
                approved__c = true
	        );
	   	
	   	insert license;     
	    return license; 
    }
    
    public static User createUser() {
    	Profile sp = [SELECT Id FROM profile WHERE name='System Administrator'];
        User testUser = new User(alias = 'uxxx1', email='this.coly@gmail.com', emailencodingkey='UTF-8', firstname='FN', lastname='Testing', 
          languagelocalekey='en_US', localesidkey='en_US', profileid = sp.Id, country='United States',
          timezonesidkey='America/Los_Angeles', username='test654CBA@test.com'); 
          
        insert testUser;
        return testUser;
    }
}