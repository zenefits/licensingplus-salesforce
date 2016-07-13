public with sharing class LicenseRuleChecker {
	
    private final LicenseRuleHelper ruleHelper;
    
    public LicenseRuleChecker (LicenseRuleHelper ruleHelper) {
    	this.ruleHelper = ruleHelper;
    }
    
    private String getOwnerId(SObject obj) {
    	Object ownerIdObj = null;
    	try {
    		ownerIdObj = obj.get('OwnerId');
    	} catch (SObjectException e) {
    		try {
    			ownerIdObj = obj.get('OwnerId__c');
    		} catch (SObjectException se) {
    			LicenseRuleHelper.logInfo('LicenseRuleChecker', 'getOwnerId', 'no owner id column on sobject');
    			System.debug(se);
    		}
    	}
    	
    	return (ownerIdObj==null) ? null : (String)ownerIdObj;
    }
    
    private void validateLicenseRule(Map<String, Set<licensingplus__License__c>> licensesByOwnerId,
    						Map<String, Set<Id>> objIdsByFilterRuleLogicId,
    						Map<String, String> licenseRuleLogicIdByFilterRuleLogicId, 
    						Map<String, licensingplus__License_Rule_Logic__c> licenseRuleLogicById,
    						Map<Id, SObject> objById,
    						Map<String, licensingplus__License_Rule__c> ruleById,
    						Map<String, Map<String, Schema.SobjectField>> objFieldsByName,
    						licensingplus__License_Rule__c stateRule,
    						licensingplus__License_Rule__c residentLicenseRule) {
    	
    	for(String ruleLogicId : objIdsByFilterRuleLogicId.keySet()) {  		
    		String licenseRuleLogicId = licenseRuleLogicIdByFilterRuleLogicId.get(ruleLogicId);
    		licensingplus__License_Rule_Logic__c licenseRuleLogic = licenseRuleLogicById.get(licenseRuleLogicId);
    		
    		// there are no license rule logic setup
    		Set<String> ruleIdArray = null;
    		String ruleLogicStr = null;
    		if (licenseRuleLogic != null) {
    			ruleLogicStr = licenseRuleLogic.licensingplus__logic__c;
    			ruleIdArray = ruleHelper.getRuleIdArray(ruleLogicStr);   
    			LicenseRuleHelper.logInfo('LicenseRuleChecker', 'validateLicenseRule', 'license filter rule ids: ' + LicenseRuleHelper.setToStringWithoutQuotes(ruleIdArray));			
    		}
		    		
    		Set<Id> objIds = objIdsByFilterRuleLogicId.get(ruleLogicId);
    		for (Id objId : objIds) {
    			Boolean hasValidLicenseRule = false;
    			Boolean hasValidStateRule = false;
    			Boolean hasResidentLicense = false;
    			SObject obj = objById.get(objId);
    			String objStateValue = obj.get(stateRule.licensingplus__field__c) == null ? null : String.valueOf(obj.get(stateRule.licensingplus__field__c));
				if (LicensingUtils.stateMap.get(objStateValue) != null) {
					objStateValue = LicensingUtils.stateMap.get(objStateValue);
				}
    			String ownerId = getOwnerId(obj);
    			    			
    			if (licensesByOwnerId.containsKey(ownerId)) {
    				// check license rule  			
					for (licensingplus__License__c license : licensesByOwnerId.get(ownerId)) {
						// if needs checking resident license rule
						if (residentLicenseRule != null && !hasResidentLicense) {
							hasResidentLicense = (license.recordTypeId == LicenseTriggerHandler.residentLicenseType);
						}
										
						String licenseStateValue = (String)license.get(stateRule.licensingplus__license_field__c);
						LicenseRuleHelper.loginfo('LicenseRuleChecker', 'validateLicenseRule', 'License state value - ' + licenseStateValue + ' Object state value - ' + objStateValue);
						if (objStateValue == licenseStateValue && !hasValidLicenseRule) {
							hasValidStateRule = true;
							if (licenseRuleLogic != null) {
								String logic = ruleLogicStr;
				    			for (String ruleId : ruleIdArray) {
				    				licensingplus__License_Rule__c rule = ruleById.get(ruleId);
				    				Boolean result = false;
				    				if (rule==null) {
				    					String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.RULE_NOT_FOUND);
										throw new LicenseRuleException(String.format(errorMessage, new String[]{ 'License Filter Rule or License Comparison Rule', ruleLogicStr, ruleId}));
				    				} else {
				    					Boolean isLicenseComparisonRule = (rule.recordtypeId == LicenseRuleHelper.licenseComparisonRuleRecordTypeId);
				    					Boolean isLicenseFilterRule = (rule.recordtypeId == LicenseRuleHelper.licenseFilterRuleRecordTypeId);			    					
					    				if (isLicenseComparisonRule) {
					    					result = ruleHelper.evaluateLicenseComparisonRule(obj, rule, license, objFieldsByName);
					    				} else if (isLicenseFilterRule){
					    					result = ruleHelper.evaluateLicenseFilterRule(license, rule, objFieldsByName);
					    				} else {
					    					String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.WRONG_RULE_TYPE);
											throw new LicenseRuleException(String.format(errorMessage, new String[]{rule.recordtype.name, licenseRuleLogic.recordtype.name}));
					    				}
					    			}
				    				logic = logic.replace(ruleId, String.valueOf(result));
				    			}
			    				
			    				LicenseRuleHelper.logInfo('LicenseRuleChecker', 'validateLicenseRule', 'BEFORE evaluate license rule ' + logic);
			    				BooleanExpressionEvaluator licenseLogicBooleanEval = new BooleanExpressionEvaluator(logic); 
								hasValidLicenseRule = licenseLogicBooleanEval.eval();
							}
						}					
					}
    			}
  			
				LicenseRuleHelper.loginfo('LicenseRuleChecker', 'validateLicenseRule', 'RESIDENT RULE - ' + hasResidentLicense + ' STATE RULE - ' + hasValidStateRule + ' LICENSE RULE - ' + hasValidLicenseRule);
				// check resident license rule
				if (residentLicenseRule != null && !hasResidentLicense) {
					String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.RESIDENT_LICENSE_CHECK_FAILED);
					obj.addError(errorMessage);
					break;
				}
				
				// check state license rule
				if (!hasValidStateRule) {
					String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.LICENSE_STATE_RULE_CHECK_FAILED);
					obj.addError(String.format(errorMessage, new String[]{objStateValue}));
					break;
				}
				
				// check filter licese rule  				
				if (licenseRuleLogic!=null && !hasValidLicenseRule) {
    				String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.LICENSE_FILTER_COMPARISON_RULE_CHECK_FAILED);
    				obj.addError(errorMessage);
    			}    				  			
	    	}  		 
    	}	
    }
     
    private void validate(
    					Set<String> licenseFields,
    					Map<Id, SObject> objById, 
    					Map<String, licensingplus__License_Rule__c> ruleById,
    					Map<String, Map<String, Schema.SobjectField>> objFieldsByName,
    					Map<String, licensingplus__License_Rule_Logic__c> filterRuleLogicById,
    					Map<String, licensingplus__License_Rule_Logic__c> licenseRuleLogicById,
    					Map<String, String> licenseRuleLogicIdByFilterRuleLogicId,
    					licensingplus__License_Rule__c stateRule,
    					licensingplus__License_Rule__c residentLicenseRule) {
    	
    	Map<String, Set<Id>> objIdsByFilterRuleLogicId = new Map<String, Set<Id>>(); 
    	Set<String> ownerIds = new Set<String>();
		
		// no filter rule logic
		if (filterRuleLogicById.isEmpty()) {
			LicenseRuleHelper.logInfo('LicenseRuleChecker', 'validate', 'no rule logic found');
			Set<Id> objIds = new Set<Id>();
			for (SObject obj : objById.values()) {
	    		String ownerId = getOwnerId(obj);   		
				// bypass if ownerId is null
				if (ownerId!=null) {
					ownerIds.add(ownerId);
					objIds.add(obj.id);
				} else {
	    			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.NO_OWNER_ID_FIELD_FOUND);
					obj.addError(errorMessage);
	    		}	
			}	
			objIdsByFilterRuleLogicId.put(LicenseRuleHelper.NO_RULE_LOGIC_ID, objIds);
		// filter rule logic exists
		} else {
			for (SObject obj : objById.values()) {
	    		String ownerId = getOwnerId(obj);   		
				// bypass if ownerId is null
				if (ownerId!=null) {
					ownerIds.add(ownerId);
	    			for (licensingplus__License_Rule_Logic__c ruleLogic : filterRuleLogicById.values()) {
		    			String logic = ruleLogic.licensingplus__logic__c;
		    			Set<String> ruleIdArray = ruleHelper.getRuleIdArray(logic);
		    			LicenseRuleHelper.logInfo('LicenseRuleChecker', 'validate', 'regular filter rule ids: ' + LicenseRuleHelper.setToStringWithoutQuotes(ruleIdArray));
		    			for (String ruleId : ruleIdArray) {
		    				licensingplus__License_Rule__c rule = ruleById.get(ruleId);
		    				if (rule==null) {
		    					String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.RULE_NOT_FOUND);
								throw new LicenseRuleException(String.format(errorMessage, new String[]{'Regular Filter Rule', ruleLogic.licensingplus__logic__c, ruleId}));
		    				} else{
		    					Boolean isRegularFilterRule = (rule.recordtypeId == LicenseRuleHelper.regularFilterRuleRecordTypeId);    				
			    				if (isRegularFilterRule) {
			    					Boolean result = ruleHelper.evaluateRegularFilterRule(obj, rule, objFieldsByName);
			    					logic = logic.replace(ruleId, String.valueOf(result));
			    				} else {
			    					String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.WRONG_RULE_TYPE);
									throw new LicenseRuleException(String.format(errorMessage, new String[]{rule.recordtype.name, ruleLogic.recordtype.name}));
			    				}
		    				}
		    				
		    				LicenseRuleHelper.logInfo('LicenseRuleChecker', 'validate', 'BEFORE evaluate filter rule ' + logic);
		    			}
		    			
		    			BooleanExpressionEvaluator filterRuleBooleanEval = new BooleanExpressionEvaluator(logic); 
		    			Boolean ruleResult = filterRuleBooleanEval.eval();
		    			if (ruleResult) {
		    				Set<Id> filteredObjIds = objIdsByFilterRuleLogicId.get(ruleLogic.id);	
		    				if (filteredObjIds==null) {
		    					filteredObjIds = new Set<Id>();
		    					objIdsByFilterRuleLogicId.put(ruleLogic.id, filteredObjIds);
		    				}
		    				filteredObjIds.add(obj.id);
		    			}
		    		}
	    		}  else {
	    			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.NO_OWNER_ID_FIELD_FOUND);
					obj.addError(errorMessage);
	    		}		
			}		
    	}
    	
    	for (String ruleLogicId : objIdsByFilterRuleLogicId.keySet()) {
    		Set<Id> objIds = objIdsByFilterRuleLogicId.get(ruleLogicId);
    		LicenseRuleHelper.logInfo('LicenseRuleChecker', 'validate', 'rule logic id: ' + ruleLogicId);
    		System.debug('[LicenseRuleChecker] - validate - objIds matched: ' + objIds);
    	}
    	
    	if (!ownerIds.isEmpty()) {
	    	Map<String, Set<licensingplus__License__c>> licensesByOwnerId = ruleHelper.constructLicensesByOwnerId(licenseFields, ownerIds);
	    	    	
	    	validateLicenseRule(licensesByOwnerId,
	    						objIdsByFilterRuleLogicId,
	    						licenseRuleLogicIdByFilterRuleLogicId, 
	    						licenseRuleLogicById,
	    						objById,
	    						ruleById,
	    						objFieldsByName,
	    						stateRule,
	    						residentLicenseRule);
    	}
    }
    
    public void checkLicenseRules(Map<Id, SObject> objById, String objName) {

    	LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule_Logic__c', new Set<String> {'Id', 'licensingplus__Logic__c', 'licensingplus__Object__c', 'licensingplus__Filter_Rule__c', 'RecordTypeid'}, 'query', false);
    	
    	List<licensingplus__License_Rule_Logic__c> ruleLogics = [SELECT Id, licensingplus__Logic__c, licensingplus__Object__c, licensingplus__Filter_Rule__c, RecordTypeid, RecordType.Name
													FROM licensingplus__License_Rule_Logic__c WHERE licensingplus__Object__c=:objName
													AND licensingplus__isActive__c = true];
		
		Map<String, licensingplus__License_Rule_Logic__c> filterRuleLogicById = new Map<String, licensingplus__License_Rule_Logic__c>();
		Map<String, licensingplus__License_Rule_Logic__c> licenseRuleLogicById = new Map<String, licensingplus__License_Rule_Logic__c>();
		Map<String, String> licenseRuleLogicIdByFilterRuleLogicId = new Map<String, String>();
		
		for (licensingplus__License_Rule_Logic__c ruleLogic : ruleLogics) {
			if (ruleLogic.recordTypeId == LicenseRuleHelper.filterRuleLogicRecordTypeId) {
				filterRuleLogicById.put(ruleLogic.id, ruleLogic);
			} else if (ruleLogic.recordTypeId == LicenseRuleHelper.licenseRuleLogicRecordTypeId){
				licenseRuleLogicById.put(ruleLogic.id, ruleLogic);
				if (ruleLogic.licensingplus__filter_rule__c != null) {
					licenseRuleLogicIdByFilterRuleLogicId.put(ruleLogic.licensingplus__filter_rule__c, ruleLogic.id);
				}
			}
		}
		
		LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', LicenseRuleHelper.setToStringWithoutQuotes(filterRuleLogicById.keySet()));
		LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', LicenseRuleHelper.setToStringWithoutQuotes(licenseRuleLogicById.keySet()));
		LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', LicenseRuleHelper.setToStringWithoutQuotes(licenseRuleLogicIdByFilterRuleLogicId.keySet()));
        
        LicenseRuleHelper.enforceCRUDAndFLS('licensingplus__License_Rule__c', new Set<String> {'Id', 'RecordTypeId', 'licensingplus__Object__c', 'licensingplus__Field__c', 'licensingplus__License_Field__c', 'licensingplus__Operator__c', 'licensingplus__Value__c'}, 'query', false);
		
		List<licensingplus__License_Rule__c> rules = [SELECT Id, RecordTypeId, licensingplus__Object__c, licensingplus__Field__c, licensingplus__License_Field__c, licensingplus__Operator__c, licensingplus__Value__c, RecordType.Name 
    											FROM licensingplus__License_Rule__c WHERE licensingplus__Object__c=:objName and licensingplus__isActive__c=true];
    	
    	Map<String, licensingplus__License_Rule__c> ruleById = new Map<String, licensingplus__License_Rule__c>();
    	Set<String> licenseFields = new Set<String>();
    	// always add Id, OwnerId and RecordTypeId column
    	licenseFields.add('Id');
    	licenseFields.add('RecordTypeId');
    	licenseFields.add('OwnerId');
    	licensingplus__License_Rule__c stateRule = null;
    	licensingplus__License_Rule__c residentLicenseRule = null;
    	
    	for (licensingplus__License_Rule__c rule : rules) {
    		if (rule.recordTypeId == LicenseRuleHelper.licenseStateRuleRecordTypeId) {
    			stateRule = rule;
    		} else if (rule.recordTypeId == LicenseRuleHelper.residentLicenseRuleRecordTypeId) {
    			residentLicenseRule = rule;
    		} else {
    			ruleById.put(rule.id, rule); 
    		}
    		  		
    		if (rule.licensingplus__license_field__c != null) {
				licenseFields.add(rule.licensingplus__license_field__c);
			}		
    	}
    	
    	LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', stateRule == null ? 'state rule not found' : 'state rule found with state field ' + stateRule.licensingplus__field__c);
    	LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', residentLicenseRule == null ? 'resident license rule not found' : 'resident license rule found with resident license field ' + residentLicenseRule.licensingplus__license_field__c);
    	LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', LicenseRuleHelper.setToStringWithoutQuotes(licenseFields));
	
		Set<String> sObjectNames = new Set<String>();
		sObjectNames.add(objName);
		sObjectNames.add('licensingplus__License__c');
		Map<String, Map<String, Schema.SobjectField>> objFieldsByName = ruleHelper.getObjFieldsByName(sObjectNames);
	    	
		if (filterRuleLogicById.isEmpty()) {
			if (stateRule == null) {
				if (!licenseRuleLogicById.isEmpty()) {
					LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', '[ERROR] - no filter rule logic, no state, license rule logic found');
					String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.ONLY_LICENSE_FILTER_COMPARISON_RULE);
					throw new LicenseRuleException(String.format(errorMessage, new String[]{LicenseRuleHelper.setToStringWithoutQuotes(licenseRuleLogicById.keySet())}));
				
				} else {
					LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', 'no filter rule logic, no state, no license rule logic');
				}
			} else {				
				if (licenseRuleLogicById.isEmpty() || licenseRuleLogicById.size() == 1) {
					LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', 'no filter rule logic, state, one or no license rule logic found');
					String licenseRuleLogicId = null;
					for (String id : licenseRuleLogicById.keySet()) {
						licenseRuleLogicId = id;
					}
					
					licenseRuleLogicIdByFilterRuleLogicId.put(LicenseRuleHelper.NO_RULE_LOGIC_ID, licenseRuleLogicId);			
					validate(licenseFields,
    									objById, 
    									ruleById,
    									objFieldsByName,
    									filterRuleLogicById,
    									licenseRuleLogicById,
    									licenseRuleLogicIdByFilterRuleLogicId,
    									stateRule,
    									residentLicenseRule);
				} else {
					LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', '[ERROR] - no filter rule logic found, state found, multiple license rule logics found');
					String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.MULTIPLE_LICENSE_FILTER_COMPARISON_RULES);
					throw new LicenseRuleException(String.format(errorMessage, new String[]{LicenseRuleHelper.setToStringWithoutQuotes(licenseRuleLogicById.keySet())}));
				}
			}
			
		} else {
			if (stateRule == null) {
				LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', '[ERROR] - filter rule logic found, no state found');
				String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.NO_LICENSE_STATE_RULE);
				throw new LicenseRuleException(String.format(errorMessage, new String[]{LicenseRuleHelper.setToStringWithoutQuotes(filterRuleLogicById.keySet())}));
			
			} else {
				LicenseRuleHelper.logInfo('LicenseRuleChecker', 'checkLicenseRules', 'filter rule logic, state' + (licenseRuleLogicById.isEmpty() ? ' found' : ', license rule logic found'));
				validate(licenseFields,
    								objById, 
    								ruleById,
    								objFieldsByName,
    								filterRuleLogicById,
    								licenseRuleLogicById,
    								licenseRuleLogicIdByFilterRuleLogicId,
    								stateRule,
    								residentLicenseRule);
			}
		}   	
    }
}