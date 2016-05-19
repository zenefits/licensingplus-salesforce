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
			
			String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.S_NO_ACTIVE_STATE_LICENSE);
			if (obj.get(fieldName) == null) {
				obj.addError(String.format(errorMessage, new String[]{'', fieldName}));
			} else {
				String stateValue = String.valueOf(obj.get(fieldName));
				if (LicensingUtils.stateMap.get(stateValue) != null) {
					stateValue = LicensingUtils.stateMap.get(stateValue);
				}
		
				errorMessage = String.format(errorMessage, new String[]{stateValue, fieldName});
				if (states == null) {
					obj.addError(errorMessage);
				} else {
					if (!states.contains(stateValue.toLowerCase())) {
						obj.addError(errorMessage);
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
    	List<Custom_License_Rule__c> rules = [SELECT id, field__c, object__c, operator__c, reference_field__c, value__c FROM custom_license_rule__c WHERE isActive__c=true AND object__c=:objName]; 	
    	List<Custom_License_Rule_Logic__c> ruleLogics = [SELECT id, object__c, logic__c FROM custom_license_rule_logic__c WHERE object__c=:objName order by lastmodifieddate limit 1];	
    	List<SObject> filteredObjs = new List<SObject>();
    	String customQueryTemplate = 'SELECT id FROM {0} WHERE id in ({1}) AND ({2})';
    	if (!rules.isEmpty()) {
    		if (!ruleLogics.isEmpty()) {  			
    			Custom_License_Rule_Logic__c ruleLogic = ruleLogics.get(0);   			
    			String formattedRules = ruleHelper.getFormattedRules(rules, ruleLogic);
				Set<String> objIds = objById.keySet();
    			
    			//TODO - fix dynamic SOQL injection
    			String customQuery = String.format(customQueryTemplate, new String[]{objName, LicenseRuleHelper.setToStringWithQuotes(objIds), formattedRules});   			
    			LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkCustomLicenseRules', 'QUERY - ' + customQuery);
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
							String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.C_RULE_CHECK_FAILED);
							obj.addError(errorMessage);
						}
					}
    			} catch (QueryException e) {
    				LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkCustomLicenseRules', 'QueryException errorMessage: ' + e.getMessage());
    				String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_QUERY_EXCEPTION);
    				throw new LicenseRuleException(String.format(errorMessage, new String[]{objName, formattedRules}), e);
    			}			
    			
    		} else {
    			String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_NO_RULE_LOGIC_FOUND);
    			throw new LicenseRuleException(String.format(errorMessage, new String[]{objName}));
    		}
    	} else {
    		if (!ruleLogics.isEmpty()) {
    			String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_RULE_LOGIC_FOUND);
    			throw new LicenseRuleException(String.format(errorMessage, new String[]{ruleLogics.get(0).object__c}));
    		}
    		
    		filteredObjs = objById.values();
    	}
    	
    	
    	return filteredObjs;
    }
}