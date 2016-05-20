public with sharing class CustomLicenseRuleLogicValidator extends LicenseRuleValidator{

    public CustomLicenseRuleLogicValidator(LicenseRuleHelper ruleHelper) {
    	super(ruleHelper);
    }
    
    public void validate(List<Custom_License_Rule__c> rules, Custom_License_Rule_Logic__c ruleLogic, String objName) {
    	if (rules == null || rules.isEmpty()) {
    		if (ruleLogic != null) {
    			String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_RULE_LOGIC_FOUND);
    			throw new LicenseRuleException(String.format(errorMessage, new String[]{objName}));
    		}    		
    	} else {
    		if (ruleLogic == null) {
    			String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_NO_RULE_LOGIC_FOUND);
    			throw new LicenseRuleException(String.format(errorMessage, new String[]{objName}));
    		}   		
    		String queryTemplate = 'SELECT count() FROM {0} WHERE {1}';
			String logic = ruleHelper.getFormattedRules(rules, ruleLogic);			
			String validateQuery = String.format(queryTemplate, new String[]{objName, logic});   			
    		try {
    			Database.countQuery(validateQuery);
    		} catch (QueryException e) {
    			LicenseRuleHelper.logInfo('CustomLicenseRuleLogicValidator', 'validateRuleLogic', 'QueryException errorMessage: ' + e.getMessage());
				String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.CRL_QUERY_EXCEPTION);
				throw new LicenseRuleException(String.format(errorMessage, new String[]{objName, logic}), e);
    		}
    	}
    }
}