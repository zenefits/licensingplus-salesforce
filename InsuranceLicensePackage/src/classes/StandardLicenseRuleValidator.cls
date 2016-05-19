public with sharing class StandardLicenseRuleValidator extends LicenseRuleValidator{
	
	public static final String STATE_RULE = 'State';
	
	public StandardLicenseRuleValidator(LicenseRuleHelper ruleHelper) {
		super(ruleHelper);
	}
	
	public Boolean validateStateFieldIsCorrect(Map<String, Schema.SobjectField> objFields, String fieldName) {
		Schema.SobjectField objField = objFields.get(fieldName);
		if (objField==null) {
			return false;
		} else {
			Schema.DisplayType fieldType = objField.getDescribe().getType();
			if (SObjectUtils.isStringType(fieldType)) {
				return false;
			}
		}
		
		return true;
	}
    
}