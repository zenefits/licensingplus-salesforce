public with sharing class CustomLicenseRuleValidator extends LicenseRuleValidator{
    
    private static final Set<String> COMPARISON_OPERATORS = new Set<String>{
    	'greater than',
    	'greater or equal',
    	'less than',
    	'less or equal'
    };
    
    private static final Set<String> WILD_CARD_OPEARTORS = new Set<String> {
    	'starts with',
    	'contains',
    	'does not contain'
    };
    
    private static final Set<String> COLLECTION_OPERATORS = new Set<String> {
    	'includes',
    	'excludes'
    };
    
    public CustomLicenseRuleValidator(LicenseRuleHelper ruleHelper) {
    	super(ruleHelper);
    }
    
    public boolean validateBooleanField(String value) {
    	return false;
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
    
    /**
     operator__c field supported values:
     	equals 
     	greater than (only allow date and number display type)
     	greater or equal (only allow date and number display type)
     	less than (only allow date and number display type)
     	less or equal (only allow date and number display type)
     	not equal to
     	starts with (only allow string type)
     	contains (only allow string type)
     	does not contain (only allow string type)
     	includes (only allow string and reference type)
     	excludes(only allow string and reference type)
     **/
     
     public boolean validateOperatorFieldType(String operator, Schema.DisplayType fieldType) {
     	if (COMPARISON_OPERATORS.contains(operator)) {
     		return false;
     	}
     	
     	
     	return true;
     }
}