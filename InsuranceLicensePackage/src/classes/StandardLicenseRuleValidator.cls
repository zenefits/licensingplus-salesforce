public with sharing class StandardLicenseRuleValidator extends LicenseRuleValidator{
	
	public static final String STATE_RULE = 'State';
	
	public StandardLicenseRuleValidator(LicenseRuleHelper ruleHelper) {
		super(ruleHelper);
	}
	
	public void validate(Map<String, Schema.SobjectField> objFields, String objName, String fieldName) {
		validateStateField(objFields, objName, fieldName);
	}
		
	private void validateStateField(Map<String, Schema.SobjectField> objFields, String objName,  String fieldName) {
		Schema.SobjectField objField = objFields.get(fieldName);
		String errorMessage = LicenseRuleValidator.errorMessageByType.get(LicenseRuleValidator.LicenseRuleError.SR_STATE_FIELD_NOT_VALID);
		errorMessage = String.format(errorMessage, new String[]{fieldName, objName});
		if (objField==null) {
			throw new LicenseRuleException(errorMessage);
		} else {
			Schema.DisplayType fieldType = objField.getDescribe().getType();
			if (!SObjectUtils.isStringType(fieldType)) {			
				throw new LicenseRuleException(errorMessage);
			}
		}
	}
    
}