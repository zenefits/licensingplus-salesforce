public abstract with sharing class LicenseRuleValidator {    
    
    public class ValidationResult {
    	public Boolean isValid;
    	public String errorMessage;
    	
    	public ValidationResult() {
    		this(true, null, null);
    	}
    	
    	public ValidationResult(LicenseRuleError error) {
    		this(false, error, null);
    	}
    	
    	public ValidationResult(LicenseRuleError error, String[] arguments) {
    		this(false, error, arguments);
    	}
    	
    	private ValidationResult(Boolean isValid, LicenseRuleError error, String[] arguments) {
    		this.isValid = isValid;
    		if (error != null) {
    			String messageTemplate = errorMessageByType.get(error);
	    		if (arguments!=null) {
	    			this.errorMessage = String.format(messageTemplate, arguments);
	    		} else {
	    			this.errorMessage = messageTemplate;
	    		}
    		}		
    	}
    }
    
    public enum LicenseRuleError {
    	CRL_QUERY_EXCEPTION,
    	CRL_NO_RULE_LOGIC_FOUND,
    	CRL_ACTIVE_RULE_MISSING,
    	CRL_RULE_LOGIC_FOUND,
    	UNDEFINED_SOBJECT_TYPE,
    	UNDEFINED_SOBJECT_FIELD,
		SR_STATE_FIELD_NOT_VALID,
		S_NO_ACTIVE_STATE_LICENSE,
    	C_RULE_CHECK_FAILED
    }
    
    public static final Map<LicenseRuleError, String> errorMessageByType = new Map<LicenseRuleError, String>();
    
    static {
    	errorMessageByType.put(LicenseRuleError.CRL_QUERY_EXCEPTION, 'There are some issues on your custom license rules configuration for sObject {0} with logic {1}');
    	errorMessageByType.put(LicenseRuleError.CRL_NO_RULE_LOGIC_FOUND, 'Active custom license rules found, but no custom license rule logic found for sObject {0}, pleease create the logic');
    	errorMessageByType.put(LicenseRuleError.CRL_RULE_LOGIC_FOUND, 'No active custom license rules found, but custom license rule logic found for sObject {0}, please delete the logic');
    	errorMessageByType.put(LicenseRuleError.CRL_ACTIVE_RULE_MISSING, 'Active Control Rule not included in the logic, logic - {0}, rule id - {1}');
    	errorMessageByType.put(LicenseRuleError.UNDEFINED_SOBJECT_TYPE, 'SObject - {0} cannot be found, it is not configured on this org.');
    	errorMessageByType.put(LicenseRuleError.UNDEFINED_SOBJECT_FIELD, 'Field - {0} on SObject - {1} cannot be found, it is not configured on this org.');
    	errorMessageByType.put(LicenseRuleError.SR_STATE_FIELD_NOT_VALID, 'State Rule field - {0} on object - {1} is not string type');
    	errorMessageByType.put(LicenseRuleError.S_NO_ACTIVE_STATE_LICENSE, 'Owner does not have an active license in state - {0}, fieldName - {1}');
    	errorMessageByType.put(LicenseRuleError.C_RULE_CHECK_FAILED, 'Opportunity custom license rule check failed, please check whether data matches custom license rules');
    }
    
    public final LicenseRuleHelper ruleHelper;
    
    public LicenseRuleValidator(LicenseRuleHelper ruleHelper) {
    	this.ruleHelper = ruleHelper;
    }
	
}