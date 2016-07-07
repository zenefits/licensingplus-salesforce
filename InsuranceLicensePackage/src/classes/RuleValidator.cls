public abstract with sharing class RuleValidator {
    
    public enum RuleError {
    	LICENSE_QUERY_EXCEPTION,
    	UNSUPPORTED_OPERATOR,
    	RULE_NOT_FOUND,
    	WRONG_RULE_TYPE,
    	ONLY_LICENSE_FILTER_COMPARISON_RULE,
    	MULTIPLE_LICENSE_FILTER_COMPARISON_RULES,
    	NO_LICENSE_STATE_RULE,
    	RESIDENT_LICENSE_CHECK_FAILED,
    	LICENSE_STATE_RULE_CHECK_FAILED,
    	LICENSE_FILTER_COMPARISON_RULE_CHECK_FAILED,
    	OPERATOR_NOT_MATCH_FIELD_TYPE,
    	FIELD_VALUE_NOT_MATCH_FIELD_TYPE,
    	FIELD_TYPE_NOT_MATCH_LICENSE_FIELD_TYPE,
    	RULE_LOGIC_FOUND,
    	NO_OWNER_ID_FIELD_FOUND,
    	UNDEFINED_SOBJECT_TYPE,
    	UNDEFINED_SOBJECT_FIELD
    }
    
    public static final Map<RuleError, String> errorMessageByType = new Map<RuleError, String>();
    
    static {
    	errorMessageByType.put(RuleError.LICENSE_QUERY_EXCEPTION, 'There are some issues on your license comparison rules configuration for fields - {0}'); 
    	errorMessageByType.put(RuleError.UNSUPPORTED_OPERATOR, '{0} operator is not supported to use for field {1} withe type {2}'); 
    	errorMessageByType.put(RuleError.RULE_NOT_FOUND, '{0} not found in the rule logic, rule logic - {1}, rule id - {2}');
    	errorMessageByType.put(RuleError.WRONG_RULE_TYPE, 'The rule type should not be in the rule logic, rule type - {0}, rule logic type - {1}');
    	errorMessageByType.put(RuleError.ONLY_LICENSE_FILTER_COMPARISON_RULE, 'No filter rule logic and no state rule found, but active license rule logic found, rule logic id - {0}');
    	errorMessageByType.put(RuleError.MULTIPLE_LICENSE_FILTER_COMPARISON_RULES, 'You should only have one active license rule logic if no filter rule logic are defined, rule logic id - {0}');
    	errorMessageByType.put(RuleError.NO_LICENSE_STATE_RULE, 'You should configure license state rule if you have configured regular filter rule and filter rule logic, rule logic id - {0}');
    	errorMessageByType.put(RuleError.RESIDENT_LICENSE_CHECK_FAILED, 'Owner does not have an active resident license');
    	errorMessageByType.put(RuleError.LICENSE_STATE_RULE_CHECK_FAILED, 'Owner does not have an active license in state - {0}, fieldName - {1}, objName - {2}');
    	errorMessageByType.put(RuleError.LICENSE_FILTER_COMPARISON_RULE_CHECK_FAILED, 'License rule check failed, please check whether data matches license filter or comparison rules');
    	errorMessageByType.put(RuleError.OPERATOR_NOT_MATCH_FIELD_TYPE, 'Operator - {0} can not be applied to field - {1} on sObject - {2}');
    	errorMessageByType.put(RuleError.FIELD_VALUE_NOT_MATCH_FIELD_TYPE, 'Field value - {0} can not be applied to field type - {1} for field - {2} on sObject - {3}');
    	errorMessageByType.put(RuleError.FIELD_TYPE_NOT_MATCH_LICENSE_FIELD_TYPE, 'Field - {0}({1}) should match the type of license field - {2}({3}) on sObject - {4}');
    	errorMessageByType.put(RuleError.RULE_LOGIC_FOUND, 'No active rules found, but rule logic found for sObject {0}, please delete or turn off the logic');
    	errorMessageByType.put(RuleError.NO_OWNER_ID_FIELD_FOUND, 'OwnerId or OwnerId__c field not found on object, for sobject witout OwnerId field, please create one formula field OwnerId__c to designate the OwnerId');
    	errorMessageByType.put(RuleError.UNDEFINED_SOBJECT_TYPE, 'SObject - {0} cannot be found, it is not configured on this org.');
    	errorMessageByType.put(RuleError.UNDEFINED_SOBJECT_FIELD, 'Field - {0} on SObject - {1} cannot be found, it is not configured on this org.');
    }
    
    protected final LicenseRuleHelper ruleHelper;
    
    public RuleValidator(LicenseRuleHelper ruleHelper) {
    	this.ruleHelper = ruleHelper;
    }
	
}