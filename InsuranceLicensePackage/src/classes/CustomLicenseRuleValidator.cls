public with sharing class CustomLicenseRuleValidator extends LicenseRuleValidator{
    
    public CustomLicenseRuleValidator(LicenseRuleHelper ruleHelper) {
    	super(ruleHelper);
    }
    
    public boolean validateBooleanField(String value) {
    	return false;
    }
    
    public String validateAndStoreField(String value) {
    	return null;
    }
    
    //needs to escape single quotes
    public boolean validateStringField(String value) {
    	return false;	
    }
    
    public boolean validateNumberField(String value) {
    	return false;
    }
    
    public boolean validateDateField(String value) {
    	return false;
    }
    
    public boolean validateDatetimeField(String value) {
    	return false;
    }
}