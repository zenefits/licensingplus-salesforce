public with sharing class LicenseRuleChecker {
	
    public final LicenseRuleHelper ruleHelper;       
    
    public LicenseRuleChecker (LicenseRuleHelper ruleHelper) {
    	this.ruleHelper = ruleHelper;
    }
    
    private void checkStateRule(String fieldName, List<SObject> objs) {
    	Set<String> ownerIds = new Set<String>();
		for (SObject obj : objs) {
			ownerIds.add(String.valueOf(obj.get('OwnerId')));	
		}
		
		Map<String, Set<String>> statesByOwnerId = ruleHelper.constructLicenseStateByOwnerId(ownerIds);
		
		for (SObject obj : objs) {
			String ownerId = String.valueOf(obj.get('OwnerId'));
			Set<String> states = statesByOwnerId.get(ownerId);
			
			String stateValue = String.valueOf(obj.get(fieldName));
			if (stateValue == null) {
				obj.addError('owner does not have an active license in state - ' + stateValue);
			} else {
				if (states == null) {
					obj.addError('owner does not have an active license in state - ' + stateValue);
				} else {
					if (!states.contains(stateValue)) {
						obj.addError('owner does not have an active license in state - ' + stateValue);
					}
				}
			}				
		}  		
    }
    
   public void checkStandardLicenseRules(List<SObject> objs, String objName) {
		List<Standard_License_Rule__c> standardControlRules = [SELECT id, field__c, object__c, type__c FROM Standard_License_Rule__c 
    															WHERE object__c=:objName AND isActive__c = true
    															ORDER BY type__c desc, lastmodifieddate asc];
    															
		for (Standard_License_Rule__c rule : standardControlRules) {
			String ruleType = rule.type__c;
			if (StandardLicenseRuleValidator.STATE_RULE.equalsIgnoreCase(ruleType)) {
				checkStateRule(rule.field__c, objs);
			}
		}
    }
    
   public List<SObject> checkCustomLicenseRules(Map<String, SObject> objById, String objName) {
    	List<Custom_License_Rule__c> rules = [SELECT id, field__c, object__c, operator__c, parent_object__c, value__c FROM custom_license_rule__c WHERE isActive__c=true AND object__c=:objName]; 	
    	List<SObject> filteredObjs = new List<SObject>();
    	String customQueryTemplate = 'SELECT id FROM {0} WHERE id in ({1}) AND ({2})';
    	if (!rules.isEmpty()) {
    		List<Custom_License_Rule_Logic__c> logics = [SELECT id, object__c, logic__c FROM custom_license_rule_logic__c WHERE object__c=:objName order by lastmodifieddate limit 1];	
    		if (!logics.isEmpty()) {  			
    			Custom_License_Rule_Logic__c ruleLogic = logics.get(0);
    			
    			String formattedRules = ruleHelper.getFormattedRules(rules, ruleLogic);
				Set<String> objIds = objById.keySet();
    			
    			//TODO - fix dynamic SOQL injection
    			String customQuery = String.format(customQueryTemplate, new String[]{objName, LicenseRuleHelper.setToString(objIds), formattedRules});   			
    			try {
    				List<SObject> filteredResults = Database.query(customQuery); 
    				Set<String> filteredObjIds = new Set<String>();
    				
	    			// ADDING ERRORS FOR FILTERED OUT SOBJECTS
	    			for (SObject filterResult : filteredResults) {
	    				filteredObjIds.add(String.valueOf(filterResult.get('Id')));
	    			}
	    			
					for (String id : objById.keySet()) {
						SObject obj = objById.get(id);
						// valid license
						if (filteredObjIds.contains(id)) {
							filteredObjs.add(obj);					
						} else {
							obj.addError('opportunity custom license rule check failed - ' + id);
						}
					}
    			} catch (QueryException e) {
    				LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkCustomLicenseRules', 'QueryException errorMessage: ' + e.getMessage());
    				String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.ValidationRuleError.CRL_QUERY_EXCEPTION);
    				throw new LicenseRuleException(String.format(errorMessage, new String[]{objName}), e);
    			}			
    			
    		} else {
    			String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.ValidationRuleError.CRL_NO_RULE_LOGIC_FOUND);
    			throw new LicenseRuleException(errorMessage);
    		}
    	} else {
    		filteredObjs = objById.values();
    	}
    	
    	
    	return filteredObjs;
    }
}