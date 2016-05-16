public abstract with sharing class LicenseRuleValidator {    
    
    public class ValidationResult {
    	public Boolean isValid;
    	public String errorMessage;
    	
    	public ValidationResult() {
    		this(true, null, null);
    	}
    	
    	public ValidationResult(ValidationRuleError error) {
    		this(false, error, null);
    	}
    	
    	public ValidationResult(ValidationRuleError error, String[] arguments) {
    		this(false, error, arguments);
    	}
    	
    	private ValidationResult(Boolean isValid, ValidationRuleError error, String[] arguments) {
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
    
    public enum ValidationRuleError {
    	CRL_QUERY_EXCEPTION,
    	CRL_NO_RULE_LOGIC_FOUND,
    	CRL_ACTIVE_RULE_MISSING,
    	UNDEFINED_SOBJECT_TYPE,
    	UNDEFINED_SOBJECT_FIELD,
		SR_STATE_FIELD_NOT_VALID
    }
    
    public static final Map<ValidationRuleError, String> errorMessageByType = new Map<ValidationRuleError, String>();
    
    static {
    	errorMessageByType.put(ValidationRuleError.CRL_QUERY_EXCEPTION, 'There are some issues on your custom license rules configuration for sObject {0} with logic {1}');
    	errorMessageByType.put(ValidationRuleError.CRL_NO_RULE_LOGIC_FOUND, 'Active custom license rules found, but no custom license rule logic found.');
    	errorMessageByType.put(ValidationRuleError.CRL_ACTIVE_RULE_MISSING, 'Active Control Rule not included in the logic, logic - {0}, rule id - {1}');
    	errorMessageByType.put(ValidationRuleError.UNDEFINED_SOBJECT_TYPE, 'SObject - {0} cannot be found, it is not configured on this org.');
    	errorMessageByType.put(ValidationRuleError.UNDEFINED_SOBJECT_FIELD, 'Field - {0} on SObject - {1} cannot be found, it is not configured on this org.');
    	errorMessageByType.put(ValidationRuleError.SR_STATE_FIELD_NOT_VALID, 'State Rule field - {0} on object - {1} is not string type');
    	
    }
    
    public final LicenseRuleHelper ruleHelper;
    
    public LicenseRuleValidator(LicenseRuleHelper ruleHelper) {
    	this.ruleHelper = ruleHelper;
    }
	
}