public with sharing class LicenseRuleLogicValidator extends RuleValidator{
    
    public LicenseRuleLogicValidator(LicenseRuleHelper ruleHelper) {
    	super(ruleHelper);
    }
    
    public void validate(License_Rule_Logic__c ruleLogic, Map<String, Set<String>> ruleIdsByObjName, Map<String, Set<String>> filterRuleLogicIdsByObjName) {    	
    	String logic = ruleLogic.logic__c;
    	String objName = ruleLogic.object__c;
    	
    	Set<String> ruleIdArray = ruleHelper.getRuleIdArray(logic);
    	Set<String> ruleIds = ruleIdsByObjName.get(objName);
    	
    	if (ruleIds==null || ruleIds.isEmpty()) {
    		String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.RULE_LOGIC_FOUND);
    		throw new LicenseRuleException(String.format(errorMessage, new String[]{objName}));
    	} else {   		
    		for (String ruleId : ruleIdArray) {
    			if (!ruleIds.contains(ruleId)) {
    				String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.RULE_NOT_FOUND);
					throw new LicenseRuleException(String.format(errorMessage, new String[]{ 'Rule', logic, ruleId}));
    			}
    		}
    	} 
    	
    	Set<String> filterRuleLogicIds = filterRuleLogicIdsByObjName.get(objName);
    	//verify license rule logic points to filter rule logic only if filter rule logic exists
    	if (ruleLogic.recordTypeId == LicenseRuleHelper.licenseRuleLogicRecordTypeId) {
    		if ((filterRuleLogicIds == null || filterRuleLogicIds.isEmpty()) && ruleLogic.filter_rule__c!=null) {
    			String errorMessage = RuleValidator.errorMessageByType.get(RuleValidator.RuleError.ONLY_LICENSE_FILTER_COMPARISON_RULE);
				throw new LicenseRuleException(String.format(errorMessage, new String[]{ruleLogic.id}));
    		}
    	}
    }
}