public with sharing class LicenseRuleTestDataSeeder {
    
    public static final String ACCOUNT_OBJ = 'Account';
    public static final String ACCOUNT1 = ACCOUNT_OBJ + 1;
    public static final String ACCOUNT2 = ACCOUNT_OBJ + 2;
    
    public static final String CASE_OBJ = 'Case';
    public static final String LICENSE_OBJ = 'licensingplus__License__c';
    public static final String LICENSE1 = LICENSE_OBJ+1;
    public static final String LICENSE2 = LICENSE_OBJ+2;
    public static final String OPPORTUNITY_OBJ = 'Opportunity';
    public static final String OPPORTUNITY1 = OPPORTUNITY_OBJ + 1;
    public static final String LICENSE_NAME = 'test1234';
    public static final String ACCOUNT_TYPE = 'TestType';
	public static final String INVALID_OBJECT = 'INVALID_INVALID_INVALID__c';
	public static final String INVALID_FIELD = 'INVALID_INVALID_INVALID__c';
	public static final String INVALID_REFERENCE_FIELD = 'INVALID_INVALID_INVALID__c';
    
    public static Map<String, List<Map<String, String>>> filterRuleFieldsByObj = new Map<String, List<Map<String, String>>>();
    public static Map<String, String> stateFieldByObj = new Map<String, String>();
    public static Map<String, List<Map<String, String>>> comparisonRuleFieldsByObj = new Map<String, List<Map<String, String>>>();
        
    private static Map<String, Schema.RecordTypeInfo> licenseRecordTypes = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName();

    static {
    	//STATE RULE config
    	stateFieldByObj.put(ACCOUNT_OBJ, 'BillingState');
    	
    	//ACCOUNT RULE SET 1
    	//FILTER RULE - ((Name starts with Test1234) | (Rating in hot,warm)) & (LastmodifiedDate greater than 2005-10-08 01:02:03Z)
    	//LICENSE RULE - ((licensingplus__class__c contains test1234) | (licensingplus__number__c starts with test1234)) & (type equals licensingplus__type__c)
    	List<Map<String, String>> accountFieldsList1 = new List<Map<String, String>>();
    	filterRuleFieldsByObj.put(ACCOUNT1, accountFieldsList1);
    	
    	Map<String, String> accountFieldsMap1 = new Map<String, String>();
    	accountFieldsMap1.put('licensingplus__field__c', 'Name');
    	accountFieldsMap1.put('licensingplus__value__c', 'Test1234');
    	accountFieldsMap1.put('licensingplus__operator__c', 'starts with');    	
    	accountFieldsList1.add(accountFieldsMap1);
    	
    	Map<String, String> accountFieldsMap2 = new Map<String, String>();
    	accountFieldsMap2.put('licensingplus__field__c', 'Rating');
    	accountFieldsMap2.put('licensingplus__value__c', 'hot,warm');
    	accountFieldsMap2.put('licensingplus__operator__c', 'in');    	
    	accountFieldsList1.add(accountFieldsMap2);
    	
    	Map<String, String> accountFieldsMap3 = new Map<String, String>();
    	accountFieldsMap3.put('licensingplus__field__c', 'LastmodifiedDate');
    	accountFieldsMap3.put('licensingplus__value__c', '2005-10-08 01:02:03');
    	accountFieldsMap3.put('licensingplus__operator__c', 'greater than');    	
    	accountFieldsList1.add(accountFieldsMap3);
	
		List<Map<String, String>> licenseFieldsList1 = new List<Map<String, String>>();
		filterRuleFieldsByObj.put(LICENSE1, licenseFieldsList1);
		Map<String, String> licenseFieldsMap1 = new Map<String, String>();
		licenseFieldsMap1.put('licensingplus__license_field__c', 'licensingplus__class__c');
		licenseFieldsMap1.put('licensingplus__operator__c', 'contains');
		licenseFieldsMap1.put('licensingplus__value__c', LICENSE_NAME);
		licenseFieldsList1.add(licenseFieldsMap1);
		
		Map<String, String> licenseFieldsMap2 = new Map<String, String>();		
		licenseFieldsMap2.put('licensingplus__license_field__c', 'licensingplus__number__c');
		licenseFieldsMap2.put('licensingplus__operator__c', 'starts with');
		licenseFieldsMap2.put('licensingplus__value__c', LICENSE_NAME);
		licenseFieldsList1.add(licenseFieldsMap2);
		
		List<Map<String, String>> accountLicenseComparisonFieldsList1 = new List<Map<String, String>>();
		comparisonRuleFieldsByObj.put(ACCOUNT1, accountLicenseComparisonFieldsList1);
		Map<String, String> accountLicenseComparisonFieldsMap1 = new Map<String, String>();
		accountLicenseComparisonFieldsMap1.put('licensingplus__license_field__c', 'licensingplus__type__c');
		accountLicenseComparisonFieldsMap1.put('licensingplus__field__c', 'type');
		accountLicenseComparisonFieldsMap1.put('licensingplus__operator__c', 'equals');
		accountLicenseComparisonFieldsList1.add(accountLicenseComparisonFieldsMap1);
		
		//ACCOUNT RULE SET 2
		//FILTER RULE - (Name not contain Test1234) & ((Rating not in hot,warm) | (LastmodifiedDate greater than 2005-10-08 01:02:03Z))
    	//LICENSE RULE - (licensingplus__class__c not contain test1234) & ((licensingplus__number__c in test1234,test12341) | (type equals licensingplus__status__c))
     	List<Map<String, String>> accountFieldsList2 = new List<Map<String, String>>();
    	filterRuleFieldsByObj.put(ACCOUNT2, accountFieldsList2);
    	
    	Map<String, String> accountFieldsMap11 = new Map<String, String>();
    	accountFieldsMap11.put('licensingplus__field__c', 'Name');
    	accountFieldsMap11.put('licensingplus__value__c', 'Test1234');
    	accountFieldsMap11.put('licensingplus__operator__c', 'does not contain');    	
    	accountFieldsList2.add(accountFieldsMap11);
    	
    	Map<String, String> accountFieldsMap21 = new Map<String, String>();
    	accountFieldsMap21.put('licensingplus__field__c', 'Rating');
    	accountFieldsMap21.put('licensingplus__value__c', 'hot,warm');
    	accountFieldsMap21.put('licensingplus__operator__c', 'not in');    	
    	accountFieldsList2.add(accountFieldsMap21);
    	
    	Map<String, String> accountFieldsMap31 = new Map<String, String>();
    	accountFieldsMap31.put('licensingplus__field__c', 'LastmodifiedDate');
    	accountFieldsMap31.put('licensingplus__value__c', '2005-10-10 01:02:03');
    	accountFieldsMap31.put('licensingplus__operator__c', 'greater than');    	
    	accountFieldsList2.add(accountFieldsMap31);
	
		List<Map<String, String>> licenseFieldsList2 = new List<Map<String, String>>();
		filterRuleFieldsByObj.put(LICENSE2, licenseFieldsList2);
		Map<String, String> licenseFieldsMap11 = new Map<String, String>();
		licenseFieldsMap11.put('licensingplus__license_field__c', 'licensingplus__class__c');
		licenseFieldsMap11.put('licensingplus__operator__c', 'does not contain');
		licenseFieldsMap11.put('licensingplus__value__c', LICENSE_NAME);
		licenseFieldsList2.add(licenseFieldsMap11);
		
		Map<String, String> licenseFieldsMap21 = new Map<String, String>();		
		licenseFieldsMap21.put('licensingplus__license_field__c', 'licensingplus__number__c');
		licenseFieldsMap21.put('licensingplus__operator__c', 'in');
		licenseFieldsMap21.put('licensingplus__value__c', LICENSE_NAME + ',' + LICENSE_NAME+1);
		licenseFieldsList2.add(licenseFieldsMap21);
		
		List<Map<String, String>> accountLicenseComparisonFieldsList2 = new List<Map<String, String>>();
		comparisonRuleFieldsByObj.put(ACCOUNT2, accountLicenseComparisonFieldsList2);
		Map<String, String> accountLicenseComparisonFieldsMap11 = new Map<String, String>();
		accountLicenseComparisonFieldsMap11.put('licensingplus__license_field__c', 'licensingplus__status__c');
		accountLicenseComparisonFieldsMap11.put('licensingplus__field__c', 'type');
		accountLicenseComparisonFieldsMap11.put('licensingplus__operator__c', 'equals');
		accountLicenseComparisonFieldsList2.add(accountLicenseComparisonFieldsMap11);
		
		//STATE RULE config
    	stateFieldByObj.put(OPPORTUNITY_OBJ, 'Description');
    	
    	//OPPORTUNITY RULE SET 1
    	//FILTER RULE - ((Name starts with Test1234) | (StageName not blank)) & (LastmodifiedDate greater than 2005-10-08 01:02:03Z)
    	//LICENSE RULE - ((licensingplus__class__c contains test1234) | (licensingplus__number__c starts with test1234)) & (type equals licensingplus__type__c)
    	List<Map<String, String>> opportunityFieldsList1 = new List<Map<String, String>>();
    	filterRuleFieldsByObj.put(OPPORTUNITY1, opportunityFieldsList1);
    	
    	Map<String, String> opportunityFieldsMap1 = new Map<String, String>();
    	opportunityFieldsMap1.put('licensingplus__field__c', 'Name');
    	opportunityFieldsMap1.put('licensingplus__value__c', 'Test1234');
    	opportunityFieldsMap1.put('licensingplus__operator__c', 'starts with');    	
    	opportunityFieldsList1.add(opportunityFieldsMap1);
    	
    	Map<String, String> opportunityFieldsMap2 = new Map<String, String>();
    	opportunityFieldsMap2.put('licensingplus__field__c', 'StageName');
    	opportunityFieldsMap2.put('licensingplus__value__c', null);
    	opportunityFieldsMap2.put('licensingplus__operator__c', 'not blank');    	
    	opportunityFieldsList1.add(opportunityFieldsMap2);
    	
    	Map<String, String> opportunityFieldsMap3 = new Map<String, String>();
    	opportunityFieldsMap3.put('licensingplus__field__c', 'LastmodifiedDate');
    	opportunityFieldsMap3.put('licensingplus__value__c', '2005-10-08 01:02:03');
    	opportunityFieldsMap3.put('licensingplus__operator__c', 'greater than');    	
    	opportunityFieldsList1.add(opportunityFieldsMap3);
		
		List<Map<String, String>> opportunityLicenseComparisonFieldsList1 = new List<Map<String, String>>();
		comparisonRuleFieldsByObj.put(OPPORTUNITY1, opportunityLicenseComparisonFieldsList1);
		Map<String, String> opportunityLicenseComparisonFieldsMap1 = new Map<String, String>();
		opportunityLicenseComparisonFieldsMap1.put('licensingplus__license_field__c', 'licensingplus__type__c');
		opportunityLicenseComparisonFieldsMap1.put('licensingplus__field__c', 'type');
		opportunityLicenseComparisonFieldsMap1.put('licensingplus__operator__c', 'equals');
		opportunityLicenseComparisonFieldsList1.add(opportunityLicenseComparisonFieldsMap1);
    	
    }
    
    public static List<licensingplus__License_Rule__c> createValidFilterRules(String objName, Boolean isRuleOne) {
    	return createValidFilterRules(objName, false, isRuleOne, true);
    }
    
    public static List<licensingplus__License_Rule__c> createValidLicenseFilterRules(String objName, Boolean isRuleOne) {
    	return createValidFilterRules(objName, true, isRuleOne, true);
    }
    
    public static List<licensingplus__License_Rule__c> getValidFilterRules(String objName, Boolean isLicense, Boolean isRuleOne, Boolean isActive) {
    	String ruleName = (isLicense?LICENSE_OBJ:objName) + (isRuleOne ? 1 : 2);
    	
    	List<Map<String, String>> ruleFields = filterRuleFieldsByObj.get(ruleName);
    	List<licensingplus__License_Rule__c> rules = new List<licensingplus__License_Rule__c>();

    	for (Map<String, String> ruleField : ruleFields) {
    		licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=objName,
	    		licensingplus__value__c=ruleField.get('licensingplus__value__c'),
	    		licensingplus__operator__c=ruleField.get('licensingplus__operator__c'),
	    		licensingplus__isActive__c=isActive	    		
	    	);
	    	
	    	if (isLicense) {
	    		rule.licensingplus__license_field__c = ruleField.get('licensingplus__license_field__c');
	    		rule.recordtypeid = LicenseRuleHelper.licenseFilterRuleRecordTypeId;
	    	} else {
	    		rule.licensingplus__field__c = ruleField.get('licensingplus__field__c');
	    		rule.recordtypeid = LicenseRuleHelper.regularFilterRuleRecordTypeId;
	    	}
	    	rules.add(rule);
    	}
    	
    	return rules;
    }
     
    public static List<licensingplus__License_Rule__c> createValidFilterRules(String objName, Boolean isLicense, Boolean isRuleOne, Boolean isActive) {
    	List<licensingplus__License_Rule__c> rules = getValidFilterRules(objName, isLicense, isRuleOne, isActive); 	
    	insert rules;
    	return rules;
    }  
        
    public static licensingplus__License_Rule__c createValidLicenseStateRule(String objName) {
    	return createValidLicenseStateRule(objName, true);
    }
    
    public static licensingplus__License_Rule__c getValidLicenseStateRule(String objName, Boolean isActive) {
    	return new licensingplus__License_Rule__c(
    		licensingplus__object__c=objName,
    		licensingplus__license_field__c='LicensingPlus__State__c',
    		licensingplus__field__c=stateFieldByObj.get(objName),
    		licensingplus__operator__c='equals',
    		licensingplus__isActive__c=isActive,
    		recordtypeid = LicenseRuleHelper.licenseStateRuleRecordTypeId
    	);
    }
    
    public static licensingplus__License_Rule__c createValidLicenseStateRule(String objName, Boolean isActive) {
    	licensingplus__License_Rule__c rule = getValidLicenseStateRule(objName, isActive);   	
    	insert rule;
    	return rule;
    }
    
    public static licensingplus__License_Rule__c createValidResidentLicenseRule(String objName) {
    	return createValidResidentLicenseRule(objName, true);
    }
    
    public static licensingplus__License_Rule__c getValidResidentLicenseRule(String objName, Boolean isActive) {
    	return new licensingplus__License_Rule__c(
    		licensingplus__object__c=objName,
    		licensingplus__license_field__c='RecordType.Name',
    		licensingplus__value__c='Resident State',
    		licensingplus__operator__c='equals',
    		licensingplus__isActive__c=isActive,
    		recordtypeid = LicenseRuleHelper.residentLicenseRuleRecordTypeId
    	);
    }
    
    public static licensingplus__License_Rule__c createValidResidentLicenseRule(String objName, Boolean isActive) {
    	licensingplus__License_Rule__c rule = getValidResidentLicenseRule(objName, isActive);  	
    	insert rule;
    	return rule;
    }
    
    public static List<licensingplus__License_Rule__c> getValidLicenseComparisonRules(String objName, Boolean isRuleOne, Boolean isActive) {
    	String ruleName = objName + (isRuleOne ? 1 : 2);
    	List<Map<String, String>> ruleFields = comparisonRuleFieldsByObj.get(ruleName);
    	List<licensingplus__License_Rule__c> rules = new List<licensingplus__License_Rule__c>();
    	
    	for (Map<String, String> ruleField : ruleFields) {
    		licensingplus__License_Rule__c rule = new licensingplus__License_Rule__c(
	    		licensingplus__object__c=objName,
	    		licensingplus__license_field__c=ruleField.get('licensingplus__license_field__c'),
	    		licensingplus__field__c=ruleField.get('licensingplus__field__c'),
	    		licensingplus__operator__c=ruleField.get('licensingplus__operator__c'),
	    		licensingplus__isActive__c=isActive,
    			recordtypeid = LicenseRuleHelper.licenseComparisonRuleRecordTypeId	    		
	    	);
	    	rules.add(rule);
    	}
    	
    	return rules;
    }
    
    public static List<licensingplus__License_Rule__c> createValidLicenseComparisonRules(String objName, Boolean isRuleOne) {
    	return createValidLicenseComparisonRules(objName, isRuleOne, true);
    }
    
    public static List<licensingplus__License_Rule__c> createValidLicenseComparisonRules(String objName, Boolean isRuleOne, Boolean isActive) {
    	List<licensingplus__License_Rule__c> rules = getValidLicenseComparisonRules(objName, isRuleOne, isActive);	
    	insert rules;
    	return rules;
    }
    
    public static licensingplus__License_Rule_Logic__c getValidFilterRuleLogic(List<licensingplus__License_Rule__c> rules, String objName, Boolean isRuleOne, Boolean isActive) {
    	String logicStr = isRuleOne ? '({1} | {2}) & {3}' : '{1} & ({2} | {3})';
    	
    	if (rules!=null) {
    		logicStr = logicStr.replace('{1}', rules.get(0).id).replace('{2}', rules.get(1).id).replace('{3}', rules.get(2).id);   		
    	}
    	
    	licensingplus__License_Rule_Logic__c validLogic = new licensingplus__License_Rule_Logic__c(
    		recordTypeId=LicenseRuleHelper.filterRuleLogicRecordTypeId,
    		licensingplus__object__c=objName,
    		licensingplus__logic__c=logicStr,
    		licensingplus__isActive__c=isActive
    	);
    	
    	return validLogic;
    }
    
    public static licensingplus__License_Rule_Logic__c createValidFilterRuleLogic(List<licensingplus__License_Rule__c> rules, String objName, Boolean isRuleOne) {
    	return createValidFilterRuleLogic(rules, objName, isRuleOne, true);
    }
    
    public static licensingplus__License_Rule_Logic__c createValidFilterRuleLogic(List<licensingplus__License_Rule__c> rules, String objName, Boolean isRuleOne, Boolean isActive) {
    	licensingplus__License_Rule_Logic__c validLogic = getValidFilterRuleLogic(rules, objName, isRuleOne, isActive);    	
    	insert validLogic;
    	return validLogic;
    }
    
    public static licensingplus__License_Rule_Logic__c getValidLicenseRuleLogic(List<licensingplus__License_Rule__c> filterRules, List<licensingplus__License_Rule__c> comparisonRules, String objName, licensingplus__License_Rule_Logic__c filterRuleLogic, Boolean isRuleOne, Boolean isActive) {
    	String logicStr = isRuleOne ? '({1} | {2}) & {3}' : '{1} & ({2} | {3})';
    	
    	
    	if (filterRules!=null && comparisonRules!=null) {
    		logicStr = logicStr.replace('{1}', filterRules.get(0).id).replace('{2}', filterRules.get(1).id).replace('{3}', comparisonRules.get(0).id);
    	}
    	licensingplus__License_Rule_Logic__c validLogic = new licensingplus__License_Rule_Logic__c(
    		recordTypeId=LicenseRuleHelper.licenseRuleLogicRecordTypeId,
    		licensingplus__object__c=objName,
    		licensingplus__logic__c=logicStr,
    		licensingplus__isActive__c=isActive
    	);
    	if (filterRuleLogic!=null) {
    		validLogic.licensingplus__filter_rule__c=filterRuleLogic.id;
    	}
    	
    	return validLogic;
    }
    
    public static licensingplus__License_Rule_Logic__c createValidLicenseRuleLogic(List<licensingplus__License_Rule__c> filterRules, List<licensingplus__License_Rule__c> comparisonRules, String objName, licensingplus__License_Rule_Logic__c filterRuleLogic, Boolean isRuleOne) {
    	return createValidLicenseRuleLogic(filterRules, comparisonRules, objName, filterRuleLogic, isRuleOne, true);
    }
    
    public static licensingplus__License_Rule_Logic__c createValidLicenseRuleLogic(List<licensingplus__License_Rule__c> filterRules, List<licensingplus__License_Rule__c> comparisonRules, String objName, licensingplus__License_Rule_Logic__c filterRuleLogic, Boolean isRuleOne, Boolean isActive) {
    	licensingplus__License_Rule_Logic__c validLogic = getValidLicenseRuleLogic(filterRules, comparisonRules, objName, filterRuleLogic, isRuleOne, isActive);
    	insert validLogic;  	
    	return validLogic;
    }
    
    public static licensingplus__License__c createResidentLicense(String ownerId, String state) {
    	return createLicense(ownerId, state, true);
    }
    
    public static licensingplus__License__c createNonResidentLicense(String ownerId, String state) {
    	return createLicense(ownerId, state, false);
    }
    
    private static licensingplus__License__c createLicense(String ownerId, String state, Boolean isResidentLicense) {
    	String recordTypeId = isResidentLicense ? licenseRecordTypes.get('Resident State').getRecordTypeId() :
    							licenseRecordTypes.get('Non-Resident State').getRecordTypeId();
    	
    	licensingplus__License__c license = new licensingplus__License__c(
	        	OwnerId = ownerId, 
	            Name = state + ' License', 
	            RecordtypeId = recordTypeId, 
	            licensingplus__Class__c = 'Test ' + LICENSE_NAME + ' Test' ,
	            licensingplus__Number__c = LICENSE_NAME, 
	            licensingplus__NPN_Number__c  = '123',  
	            licensingplus__State__c = state, 
	            licensingplus__Effective_Date__c = Date.today().addDays(-1), 
	            licensingplus__Expiration_Date__c = Date.today().addDays(1),
                licensingplus__approved__c = true,
                licensingplus__type__c=ACCOUNT_TYPE
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