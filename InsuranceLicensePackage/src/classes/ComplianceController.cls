public with sharing class ComplianceController {
    
    public class ComplianceException extends Exception {}
    
    private static final Set<Schema.DisplayType> excludedDisplayTypes = new Set<Schema.DisplayType> {
    	Schema.DisplayType.MultiPicklist,
    	Schema.DisplayType.base64
    };
    
    private static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
    
    @RemoteAction
    public static List<Lines_of_Authority__c> getLinesOfAuth( ) {
    	return [SELECT name, loa_name__c, type__c FROM Lines_of_Authority__c];
    }

    @RemoteAction
    public static void deleteLineOfAuth( Lines_of_Authority__c lineOfAuth) {
    	delete lineOfAuth;
    }

    @RemoteAction
    public static List<Lines_of_Authority__c> insertLinesOfAuth( List<Lines_of_Authority__c> linesOfAuth ) {
		  insert linesOfAuth;
      return getLinesOfAuth();
    }

    @RemoteAction
    public static Checklist__c getChecklist() {
		return Checklist__c.getOrgDefaults();
    }

    @RemoteAction
    public static void toggleChecklist(Checklist__c checklist) {
    	try {
        	update checklist;

      	} catch( Exception e ) {
			 // using this for more user friendly error message
        	throw new ComplianceException( 'Error encountered. Please contact administrator, error: ' + e.getMessage());
      	}
    }
    
    @RemoteAction
    public static Set<String> getSobjectNames() {    	
    	return SObjectUtils.getAllSObjectNames();
    }
    
    @RemoteAction
    public static Map<String, Object> getSobjectWithFields(String objName) {
      Map<String, Object> sObjectWithFields = new Map<String, Object>();
    	
      Map<String, String> fieldTypeByName = new Map<String, String>();
    	SObject sObj = SObjectUtils.getSObject(objName);
    	if (sObj != null) {
        String sObjectLabel = Schema.describeSObjects(new String[]{objName})[0].getLabel();
    		Map<String, Schema.SobjectField> objFieldByName = SObjectUtils.getSObjectFields(sObj);
    		for (String fieldName : objFieldByName.keySet()) {
    			Schema.SobjectField field = objFieldByName.get(fieldName);
    			if (!excludedDisplayTypes.contains(field.getDescribe().getType())) {
    				String fieldType = SObjectUtils.getFieldType(field.getDescribe().getType()).name();
    				fieldTypeByName.put(field.getDescribe().getName(), fieldType);	
    			}
    		}
        sObjectWithFields.put('label', (Object)sObjectLabel);
        sObjectWithFields.put('fields', (Object)fieldTypeByName);
    	}

    	return sObjectWithFields;
    }

    @RemoteAction
    public static Map<String,LicenseRuleSetResult> getAllLicenseRuleSetResults() {
      	Map<String,LicenseRuleSetResult> result = new Map<String,LicenseRuleSetResult>();
      	try {
      		result = ruleHelper.getAllLicenseRuleSetResults();
      	} catch (Exception e) {
      		System.debug('[ComplianceController] ' + '[getAllLicenseRuleSetResults] ' + e.getMessage());
      		System.debug(e);
      		throw new ComplianceException('Error encountered. Please contact administrator, error: ' + e.getMessage());
      	}
      	return result;
    }

    @RemoteAction
    public static LicenseRuleSetResult getLicenseRuleSetResult(String objName) {
        LicenseRuleSetResult result = new LicenseRuleSetResult();

        try {
          Map<String,LicenseRuleSetResult> results = ruleHelper.getAllLicenseRuleSetResults();

          if(results.containsKey(objName)){
            result = results.get(objName);
          }
        } catch (Exception e) {
          System.debug('[ComplianceController] ' + '[getLicenseRuleSetResult] ' + e.getMessage());
          System.debug(e);
          throw new ComplianceException('Error encountered. Please contact administrator, error: ' + e.getMessage());
        }
        return result;
    }
    
    @RemoteAction
    public static void saveLicenseRuleSetResult(LicenseRuleSetResult result, String objName) {
    	try {
    		ruleHelper.updateLicenseRuleSetResult(result.ruleSets, result.stateRule, result.residentLicenseRule, objName);
    	} catch (Exception e) {
      		System.debug('[ComplianceController] ' + '[updateLicenseRuleSetResult] ' + e.getMessage());
      		System.debug(e);
      		throw new ComplianceException('Error encountered. Please contact administrator, error: ' + e.getMessage());
      	}  	
    }
    
    @RemoteAction
    public static void toggleLicenseRuleSet(String objName, Boolean isActive) {
    	try {
    		ruleHelper.toggleLicenseRuleSet(objName, isActive);
    	} catch (Exception e) {
      		System.debug('[ComplianceController] ' + '[toggleLicenseRuleSet] ' + e.getMessage());
      		System.debug(e);
      		throw new ComplianceException('Error encountered. Please contact administrator, error: ' + e.getMessage());
      	}
    }
}