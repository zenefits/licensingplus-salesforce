@isTest
private class ComplianceControllerTest {
	private static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
	
    static testmethod void testGetAllLicenseRuleSetResults() {
    	License_Rule__c licenseStateRuleOne = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);	
		List<License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);	
		License_Rule_Logic__c filterRuleLogicOne = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c licenseRuleLogicOne = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne, true);
    	License_Rule__c residentLicenseRuleOne = LicenseRuleTestDataSeeder.createValidResidentLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	
    	License_Rule__c licenseStateRuleTwo = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.OPPORTUNITY_OBJ);
    	List<License_Rule__c> regularFilterRulesTwo = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.OPPORTUNITY_OBJ, true);	
		License_Rule_Logic__c filterRuleLogicTwo = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesTwo, LicenseRuleTestDataSeeder.OPPORTUNITY_OBJ, true);
		List<License_Rule__c> licenseFilterRulesTwo = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.OPPORTUNITY_OBJ, true);
		List<License_Rule__c> licenseComparisonRulesTwo = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.OPPORTUNITY_OBJ, true);
		License_Rule_Logic__c licenseRuleLogicTwo = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesTwo, licenseComparisonRulesTwo, LicenseRuleTestDataSeeder.OPPORTUNITY_OBJ, filterRuleLogicTwo, true);
		License_Rule__c residentLicenseRuleTwo = LicenseRuleTestDataSeeder.createValidResidentLicenseRule(LicenseRuleTestDataSeeder.OPPORTUNITY_OBJ);
		
		Map<String, LicenseRuleSetResult> result = ComplianceController.getAllLicenseRuleSetResults();
		
		System.assertEquals(2, result.size());
		
		LicenseRuleSetResult accountResult = result.get(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	LicenseRuleSetResult opportunityResult = result.get(LicenseRuleTestDataSeeder.OPPORTUNITY_OBJ);
		System.assert(accountResult!=null);
    	System.assert(opportunityResult!=null);
    	
    	System.assert(accountResult.stateRule.id == licenseStateRuleOne.id);
    	System.assert(accountResult.residentLicenseRule.id == residentLicenseRuleOne.id);
    	
    	LicenseRuleSetResult.LicenseRuleSet accountRuleSet = accountResult.ruleSets.get(0);
    	System.assert(accountRuleSet.filterRuleLogic.id == filterRuleLogicOne.id);
    	System.assertEquals(3, accountRuleSet.regularFilterRules.size());
    	System.assert(accountRuleSet.licenseRuleLogic.id == licenseRuleLogicOne.id);
    	System.assertEquals(3, accountRuleSet.licenseRules.size());
    	
    	System.assert(opportunityResult.stateRule.id == licenseStateRuleTwo.id);
    	System.assert(opportunityResult.residentLicenseRule.id == residentLicenseRuleTwo.id);
    	
    	LicenseRuleSetResult.LicenseRuleSet opportunityRuleSet = opportunityResult.ruleSets.get(0);
    	System.assert(opportunityRuleSet.filterRuleLogic.id == filterRuleLogicTwo.id);
    	System.assertEquals(3, opportunityRuleSet.regularFilterRules.size());
    	System.assert(opportunityRuleSet.licenseRuleLogic.id == licenseRuleLogicTwo.id);
    	System.assertEquals(3, opportunityRuleSet.licenseRules.size());   	
    }

    static testmethod void testGetLicenseRuleSetResult() {
    	License_Rule__c licenseStateRuleOne = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);	
		List<License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);	
		License_Rule_Logic__c filterRuleLogicOne = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidLicenseFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		List<License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
		License_Rule_Logic__c licenseRuleLogicOne = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne, true);
    	License_Rule__c residentLicenseRuleOne = LicenseRuleTestDataSeeder.createValidResidentLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
		
		LicenseRuleSetResult accountResult = ComplianceController.getLicenseRuleSetResult('Account');

		System.assert(accountResult!=null);
    	
    	System.assert(accountResult.stateRule.id == licenseStateRuleOne.id);
    	System.assert(accountResult.residentLicenseRule.id == residentLicenseRuleOne.id);
    	
    	LicenseRuleSetResult.LicenseRuleSet accountRuleSet = accountResult.ruleSets.get(0);
    	System.assert(accountRuleSet.filterRuleLogic.id == filterRuleLogicOne.id);
    	System.assertEquals(3, accountRuleSet.regularFilterRules.size());
    	System.assert(accountRuleSet.licenseRuleLogic.id == licenseRuleLogicOne.id);
    	System.assertEquals(3, accountRuleSet.licenseRules.size());    	
    }
    
    static testmethod void testSaveLicenseRuleSetResult() {
    	try {
    		ComplianceController.saveLicenseRuleSetResult(null, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    		throw new ComplianceController.ComplianceException('An exception should have been thrown but was not.');
    	} catch (ComplianceController.ComplianceException e) {
    		
    	}
    	
    	// first scenario - insert all new rules and new rule logics
    	LicenseRuleSetResult result = new LicenseRuleSetResult();
    	
    	License_Rule__c residentLicenseRule = LicenseRuleTestDataSeeder.getValidResidentLicenseRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);
    	License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.getValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);	
		List<License_Rule__c> regularFilterRules = LicenseRuleTestDataSeeder.getValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false, true, false);	
		License_Rule_Logic__c filterRuleLogic = LicenseRuleTestDataSeeder.getValidFilterRuleLogic(null, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, false);
		List<License_Rule__c> licenseFilterRules = LicenseRuleTestDataSeeder.getValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, true, false);
		List<License_Rule__c> licenseComparisonRules = LicenseRuleTestDataSeeder.getValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, false);
		License_Rule_Logic__c licenseRuleLogic = LicenseRuleTestDataSeeder.getValidLicenseRuleLogic(null, null, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, null, true, false);
    	
    	result.stateRule = licenseStateRule;
    	result.residentLicenseRule = residentLicenseRule;
    	LicenseRuleSetResult.LicenseRuleSet ruleSet = new LicenseRuleSetResult.LicenseRuleSet();
    	result.ruleSets.add(ruleSet);
    	ruleSet.filterRuleLogic = filterRuleLogic;
    	ruleSet.regularFilterRules.addAll(regularFilterRules);
    	ruleSet.licenseRuleLogic = licenseRuleLogic;
    	ruleSet.licenseRules.add(licenseFilterRules.get(0));
    	ruleSet.licenseRules.add(licenseFilterRules.get(1));
    	ruleSet.licenseRules.add(licenseComparisonRules.get(0));
    	
    	ComplianceController.saveLicenseRuleSetResult(result, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	System.assert(residentLicenseRule.id != null);
    	System.assert(licenseStateRule.id != null);
    	System.assert(filterRuleLogic.id != null);
    	for (License_Rule__c rule : regularFilterRules) {
    		System.assert(rule.id != null);
    		System.assert(filterRuleLogic.logic__c.contains(rule.id));
    	}
    	System.assertEquals(filterRuleLogic.id, licenseRuleLogic.filter_rule__c);
    	System.assert(licenseRuleLogic.id != null);
    	System.assert(licenseFilterRules.get(0).id!=null);
    	System.assert(licenseFilterRules.get(1).id!=null);
    	System.assert(licenseComparisonRules.get(0).id!=null);
    	System.assert(licenseRuleLogic.logic__c.contains(licenseFilterRules.get(0).id));
    	System.assert(licenseRuleLogic.logic__c.contains(licenseFilterRules.get(1).id));
    	System.assert(licenseRuleLogic.logic__c.contains(licenseComparisonRules.get(0).id));
    	
    	// second scenario - update some rules and rule logics, delete resident license rule
    	result.residentLicenseRule = null;
    	ruleSet.filterRuleLogic.logic__c = '{1} | {2}';
    	ruleSet.regularFilterRules.clear();
    	ruleSet.regularFilterRules.add(regularFilterRules.get(0));
    	ruleSet.regularFilterRules.add(regularFilterRules.get(1));
    	ruleSet.deletedRegularFilterRules.add(regularFilterRules.get(2));
    	ruleSet.licenseRuleLogic.logic__c = '{1}';
    	ruleSet.licenseRules.clear();
    	ruleSet.licenseRules.add(licenseFilterRules.get(1));
    	ruleSet.deletedLicenseRules.add(licenseFilterRules.get(0));
    	ruleSet.deletedLicenseRules.add(licenseComparisonRules.get(0));
    	
    	ComplianceController.saveLicenseRuleSetResult(result, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	System.assert(licenseStateRule.id != null);
    	System.assert(filterRuleLogic.id != null);
    	System.assert(regularFilterRules.get(0).id!=null);
    	System.assert(regularFilterRules.get(1).id!=null);
    	System.assert(filterRuleLogic.logic__c.contains(regularFilterRules.get(0).id));
    	System.assert(filterRuleLogic.logic__c.contains(regularFilterRules.get(1).id));
    	
    	System.assertEquals(filterRuleLogic.id, licenseRuleLogic.filter_rule__c);
    	System.assert(licenseRuleLogic.id != null);
    	System.assert(licenseFilterRules.get(1).id!=null);
    	System.assert(licenseRuleLogic.logic__c.contains(licenseFilterRules.get(1).id));
    	
    	Set<String> deletedRuleIds = new Set<String>{
    		regularFilterRules.get(2).id,
    		licenseFilterRules.get(0).id,
    		residentLicenseRule.id,
    		licenseComparisonRules.get(0).id
    	};
    	List<License_Rule__c> deletedRules = [SELECT id FROM license_rule__c WHERE id IN:deletedRuleIds AND object__c=:LicenseRuleTestDataSeeder.ACCOUNT_OBJ];
    	System.assert(deletedRules.isEmpty());
    	
    	// third scenario - delete both filter rule logic and license rule logic
    	ruleSet.isFilterRuleLogicRemoved = true;
    	ruleSet.regularFilterRules.clear();
    	ruleSet.deletedRegularFilterRules.clear();
    	ruleSet.deletedRegularFilterRules.add(regularFilterRules.get(0));
    	ruleSet.deletedRegularFilterRules.add(regularFilterRules.get(1));
    	
    	ruleSet.isLicenseRuleLogicRemoved = true;
    	ruleSet.licenseRules.clear();
    	ruleSet.deletedLicenseRules.clear();
    	ruleSet.deletedLicenseRules.add(licenseFilterRules.get(1));
    	
    	ComplianceController.saveLicenseRuleSetResult(result, LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	
    	List<License_Rule__c> stateRules = [SELECT id FROM license_rule__c WHERE id =:licenseStateRule.id AND object__c=:LicenseRuleTestDataSeeder.ACCOUNT_OBJ];
    	System.assert(!stateRules.isEmpty());
    	
    	Set<String> deletedRuleLogicIds = new Set<String>{
    		filterRuleLogic.id,
    		licenseRuleLogic.id
    	};
    	
    	List<License_Rule_Logic__c> deletedRuleLogics = [SELECT id FROM license_rule_logic__c WHERE id IN:deletedRuleLogicIds AND object__c=:LicenseRuleTestDataSeeder.ACCOUNT_OBJ];
    	System.assert(deletedRuleLogics.isEmpty());
    	
    	deletedRuleIds = new Set<String>{
    		regularFilterRules.get(0).id,
    		regularFilterRules.get(1).id,
    		licenseFilterRules.get(1).id
    	};
    	
    	deletedRules = [SELECT id FROM license_rule__c WHERE id IN:deletedRuleIds AND object__c=:LicenseRuleTestDataSeeder.ACCOUNT_OBJ];
    	System.assert(deletedRules.isEmpty());
    }
    
    static testmethod void testGetSObjectNames() {
    	Set<String> allSObjectNames = ComplianceController.getSObjectNames();
    	System.assert(allSObjectNames.contains(LicenseRuleTestDataSeeder.ACCOUNT_OBJ));
    }
    
    static testmethod void testGetFieldTypeByName() {
    	Map<String, Object> sObjectFields = ComplianceController.getSobjectWithFields(LicenseRuleTestDataSeeder.ACCOUNT_OBJ);
    	System.assertEquals('Account', (String)sObjectFields.get('label'));
    	System.assert(((Map<String, String>)sObjectFields.get('fields')).containsKey('Name'));
    }
    
    static testmethod void testToggleLicenseRuleSet() {
    	License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);	
		List<License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false, true, false);	
		License_Rule_Logic__c filterRuleLogicOne = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, false);
		List<License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, true, false);
		List<License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, false);
		License_Rule_Logic__c licenseRuleLogicOne = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne, true, false);
    	Set<String> ruleIds = new Set<String>();
    	Set<String> ruleLogicIds = new Set<String>();
    	
    	ruleIds.add(licenseStateRule.id);
    	for (License_Rule__c rule : regularFilterRulesOne) {
    		ruleIds.add(rule.id);
    	}
    	for (License_Rule__c rule : licenseFilterRulesOne) {
    		ruleIds.add(rule.id);
    	}
    	for (License_Rule__c rule : licenseComparisonRulesOne) {
    		ruleIds.add(rule.id);
    	}
    	ruleLogicIds.add(filterRuleLogicOne.id);
    	ruleLogicIds.add(licenseRuleLogicOne.id);
    	
    	ComplianceController.toggleLicenseRuleSet(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true);
    	Integer ruleCount = 0;
    	for (License_Rule__c rule : [SELECT id, isActive__c FROM License_Rule__c WHERE id IN:ruleIds]) {
    		System.assert(rule.isActive__c);
    		ruleCount += 1;
    	}
    	System.assertEquals(ruleIds.size(), ruleCount);
    	
    	Integer ruleLogicCount = 0;
    	for (License_Rule_Logic__c ruleLogic : [SELECT id, isActive__c FROM License_Rule_Logic__c WHERE id IN:ruleLogicIds]) {
    		System.assert(ruleLogic.isActive__c);
    		ruleLogicCount += 1;
    	}
    	System.assertEquals(ruleLogicIds.size(), ruleLogicCount);
    	  	
    	ComplianceController.toggleLicenseRuleSet(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);
    	ruleCount = 0;
    	for (License_Rule__c rule : [SELECT id, isActive__c FROM License_Rule__c WHERE id IN:ruleIds]) {
    		System.assert(!rule.isActive__c);
    		ruleCount += 1;
    	}
    	System.assertEquals(ruleIds.size(), ruleCount);
    	
    	ruleLogicCount = 0;
    	for (License_Rule_Logic__c ruleLogic : [SELECT id, isActive__c FROM License_Rule_Logic__c WHERE id IN:ruleLogicIds]) {
    		System.assert(!ruleLogic.isActive__c);
    		ruleLogicCount += 1;
    	}
    	System.assertEquals(ruleLogicIds.size(), ruleLogicCount);
    }
    
    static testmethod void testToggleLicenseRuleSetWithFilterLogicId() {
    	License_Rule__c licenseStateRule = LicenseRuleTestDataSeeder.createValidLicenseStateRule(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false);	
		List<License_Rule__c> regularFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, false, true, false);	
		License_Rule_Logic__c filterRuleLogicOne = LicenseRuleTestDataSeeder.createValidFilterRuleLogic(regularFilterRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, false);
		List<License_Rule__c> licenseFilterRulesOne = LicenseRuleTestDataSeeder.createValidFilterRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, true, false);
		List<License_Rule__c> licenseComparisonRulesOne = LicenseRuleTestDataSeeder.createValidLicenseComparisonRules(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, true, false);
		License_Rule_Logic__c licenseRuleLogicOne = LicenseRuleTestDataSeeder.createValidLicenseRuleLogic(licenseFilterRulesOne, licenseComparisonRulesOne, LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne, true, false);
    	
    	Set<String> ruleIds = new Set<String>();
    	Set<String> ruleLogicIds = new Set<String>();
    	
    	for (License_Rule__c rule : regularFilterRulesOne) {
    		ruleIds.add(rule.id);
    	}
    	for (License_Rule__c rule : licenseFilterRulesOne) {
    		ruleIds.add(rule.id);
    	}
    	for (License_Rule__c rule : licenseComparisonRulesOne) {
    		ruleIds.add(rule.id);
    	}
    	ruleLogicIds.add(filterRuleLogicOne.id);
    	ruleLogicIds.add(licenseRuleLogicOne.id);
    	
    	ruleHelper.toggleLicenseRuleSet(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne.id, true);
    	Integer ruleCount = 0;
    	for (License_Rule__c rule : [SELECT id, isActive__c FROM License_Rule__c WHERE id IN:ruleIds]) {
    		System.assert(rule.isActive__c);
    		ruleCount += 1;
    	}
    	System.assertEquals(ruleIds.size(), ruleCount);
    	
    	Integer ruleLogicCount = 0;
    	for (License_Rule_Logic__c ruleLogic : [SELECT id, isActive__c FROM License_Rule_Logic__c WHERE id IN:ruleLogicIds]) {
    		System.assert(ruleLogic.isActive__c);
    		ruleLogicCount += 1;
    	}
    	System.assertEquals(ruleLogicIds.size(), ruleLogicCount);
    	  	
    	ruleHelper.toggleLicenseRuleSet(LicenseRuleTestDataSeeder.ACCOUNT_OBJ, filterRuleLogicOne.id, false);
    	ruleCount = 0;
    	for (License_Rule__c rule : [SELECT id, isActive__c FROM License_Rule__c WHERE id IN:ruleIds]) {
    		System.assert(!rule.isActive__c);
    		ruleCount += 1;
    	}
    	System.assertEquals(ruleIds.size(), ruleCount);
    	
    	ruleLogicCount = 0;
    	for (License_Rule_Logic__c ruleLogic : [SELECT id, isActive__c FROM License_Rule_Logic__c WHERE id IN:ruleLogicIds]) {
    		System.assert(!ruleLogic.isActive__c);
    		ruleLogicCount += 1;
    	}
    	System.assertEquals(ruleLogicIds.size(), ruleLogicCount);
    }

    static testmethod void testGetLinesOfAuth() {
        // setup LOA custom setting data
        List<Line_Of_Authority_Map__c> loaSettings = new List<Line_Of_Authority_Map__c>();
        Line_Of_Authority_Map__c health = new Line_Of_Authority_Map__c(name = 'Health', loa_name__c = 'Health', type__c = 'Health');
        Line_Of_Authority_Map__c life = new Line_Of_Authority_Map__c(name = 'Life', loa_name__c = 'Life', type__c = 'Life');
        Line_Of_Authority_Map__c property = new Line_Of_Authority_Map__c(name = 'P&C1', loa_name__c = 'Property & Casualty', type__c = 'Property'); 
        Line_Of_Authority_Map__c casualty = new Line_Of_Authority_Map__c(name = 'P&C2', loa_name__c = 'Property & Casualty', type__c = 'Casualty');            
        loaSettings.addAll(new List<Line_Of_Authority_Map__c>{health, life, property, casualty});
        insert loaSettings;

        test.startTest();
        List<Line_Of_Authority_Map__c> loasFromController = ComplianceController.getLinesOfAuth();
        test.stopTest();

        system.assertEquals(Line_Of_Authority_Map__c.getAll().size(), loasFromController.size());
    }

    static testmethod void testDeleteLineOfAuth() {
        // setup LOA custom setting data
        List<Line_Of_Authority_Map__c> loaSettings = new List<Line_Of_Authority_Map__c>();
        Line_Of_Authority_Map__c health = new Line_Of_Authority_Map__c(name = 'Health', loa_name__c = 'Health', type__c = 'Health');
        Line_Of_Authority_Map__c life = new Line_Of_Authority_Map__c(name = 'Life', loa_name__c = 'Life', type__c = 'Life');
        Line_Of_Authority_Map__c property = new Line_Of_Authority_Map__c(name = 'P&C1', loa_name__c = 'Property & Casualty', type__c = 'Property'); 
        Line_Of_Authority_Map__c casualty = new Line_Of_Authority_Map__c(name = 'P&C2', loa_name__c = 'Property & Casualty', type__c = 'Casualty');            
        loaSettings.addAll(new List<Line_Of_Authority_Map__c>{health, life, property, casualty});
        insert loaSettings;

        test.startTest();
        ComplianceController.deleteLineOfAuth(health);
        test.stopTest();

        System.assertEquals(loaSettings.size() - 1, Line_Of_Authority_Map__c.getAll().size());
    }    

    static testmethod void testInsertLinesOfAuth() {
        // setup LOA custom setting data
        List<Line_Of_Authority_Map__c> loaSettings = new List<Line_Of_Authority_Map__c>();
        Line_Of_Authority_Map__c health = new Line_Of_Authority_Map__c(name = 'Health', loa_name__c = 'Health', type__c = 'Health');
        Line_Of_Authority_Map__c life = new Line_Of_Authority_Map__c(name = 'Life', loa_name__c = 'Life', type__c = 'Life');
        Line_Of_Authority_Map__c property = new Line_Of_Authority_Map__c(name = 'P&C1', loa_name__c = 'Property & Casualty', type__c = 'Property'); 
        Line_Of_Authority_Map__c casualty = new Line_Of_Authority_Map__c(name = 'P&C2', loa_name__c = 'Property & Casualty', type__c = 'Casualty');            
        loaSettings.addAll(new List<Line_Of_Authority_Map__c>{health, life, property, casualty});

        test.startTest();
        ComplianceController.insertLinesOfAuth(loaSettings);
        test.stopTest();

        System.assertEquals(loaSettings.size(), Line_Of_Authority_Map__c.getAll().size());
    }      

    static testmethod void testGetChecklist() {
    	Checklist__c checklist = ComplianceController.getChecklist();
    	system.assertEquals(Checklist__c.getOrgDefaults().id, checklist.id);
    }

    static testmethod void testToggleChecklist() {
    	Checklist__c orgDefaults = Checklist__c.getOrgDefaults();
    	orgDefaults.set_approvals__c = false;
    	upsert orgDefaults;

    	system.assertEquals(false, Checklist__c.getOrgDefaults().set_approvals__c);    	    	

    	test.startTest();
    	orgDefaults.set_approvals__c = true;
    	ComplianceController.toggleChecklist(orgDefaults);    	
    	test.stopTest();

    	system.assertEquals(true, Checklist__c.getOrgDefaults().set_approvals__c);    	
    }

    static testmethod void testToggleChecklist_error() {
    	// don't insert custom setting
    	Checklist__c orgDefaults = Checklist__c.getOrgDefaults();
    	orgDefaults.set_approvals__c = true;    	

    	Exception complianceExc;
    	test.startTest();
    	try {
    		// running this should throw an error because the custom setting
    		// has not been inserted yet
    		ComplianceController.toggleChecklist(orgDefaults);    	    		
    	} catch (ComplianceController.ComplianceException e) {
    		complianceExc = e;
    	}
    	test.stopTest();

    	system.assert(complianceExc != null);
    }
}