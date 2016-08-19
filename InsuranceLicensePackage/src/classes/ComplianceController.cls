public with sharing class ComplianceController {
    
    public class ComplianceException extends Exception {}

    public String namespace {
        get {
            return AppConfig.getAppNamespacedName('');
        }
    }
    
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
    	Checklist__c defaultChecklist = Checklist__c.getOrgDefaults();
    	if (defaultChecklist.id == null) {
    		insert defaultChecklist;
    	}
    	
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
      		result = ruleHelper.getAllLicenseRuleSetResults(true);
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
          Map<String,LicenseRuleSetResult> results = ruleHelper.getAllLicenseRuleSetResults(false);

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
      		System.debug('[ComplianceController] ' + '[saveLicenseRuleSetResult] ' + e.getMessage());
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
    
    @RemoteAction
    public static List<NIPRSyncApiResponse.LicenseSyncResponse> importLicenseData(List<NIPRLicense> niprLicenses) {
        List<NIPRSyncApiResponse.LicenseSyncResponse> results = new List<NIPRSyncApiResponse.LicenseSyncResponse>();
        
        try {
            if(niprLicenses != null && !niprLicenses.isEmpty()) {
                NIPRSyncService syncservice = new NIPRSyncService();
                results = syncservice.syncLicenses(niprLicenses);
            }
        } catch (Exception e) {
            System.debug('[ComplianceController] ' + '[importLicenseData] ' + e.getMessage());
            System.debug(e);
            throw new ComplianceException('Error encountered. Please contact administrator, error: ' + e.getMessage());
        }
        return results;
    } 
    
  
    @RemoteAction
	public static List<String> getApprovalProcessNames() {
		List<String> approvalProcessList = new List<String>();
		for(ProcessDefinition definition: [SELECT Id,Name, DeveloperName FROM ProcessDefinition WHERE TableEnumOrId =:AppConfig.getAppNamespacedName('License__c') AND Type = 'Approval']) {
			approvalProcessList.add(definition.DeveloperName);		
		}
		return approvalProcessList;
	}
	
	@RemoteAction
    public static List<User> getUserNames(String searchString) {
    	List<User> userList = new List<User>();
    	if(!String.isBlank(searchString)) {
    		searchString = '%'+searchString+'%';
    		userList = [SELECT Id,UserName,Name FROM User WHERE UserName LIKE :searchString OR Name LIKE :searchString];
    	}
		return userList;
    }
    
    @RemoteAction
    public static Map<String,Object> getApprovalCriteriaConfig() {
    	Map<String,Object> criteriaMap = new Map<String,Object>();
    	NIPR_Sync_Config__c  configSetting = NIPR_Sync_Config__c.getOrgDefaults();
		if(configSetting.id == null) {
    		insert configSetting;
		}
		criteriaMap.put('niprSyncConfig',configSetting);
		criteriaMap.put('licenseRuleSetResult',getLicenseRuleSetResult(AppConfig.getAppNamespacedName('License__c')));			
    	return criteriaMap;
    }
    
     @RemoteAction
    public static void saveApprovalCriteriaConfig(NIPR_Sync_Config__c niprSyncConfig,LicenseRuleSetResult licenseResult) {
    	if(niprSyncConfig != null) {
    		NIPR_Sync_Config__c defaultSetting = NIPR_Sync_Config__c.getOrgDefaults();
    		if(!String.isBlank(niprSyncConfig.NIPR_Integration_User_Name__c)) {
    			defaultSetting.NIPR_Integration_User_Name__c = niprSyncConfig.NIPR_Integration_User_Name__c;
    		}
    		if(niprSyncConfig.ForceExpire__c != null) {
    			defaultSetting.ForceExpire__c = niprSyncConfig.ForceExpire__c;
    		}
    		if(!String.isBlank(niprSyncConfig.ApprovalProcess__c)) {
    			defaultSetting.ApprovalProcess__c = niprSyncConfig.ApprovalProcess__c;
    		}
    		update defaultSetting;
    	}
 	  if(licenseResult != null) {
 	  		saveLicenseRuleSetResult(licenseResult,AppConfig.getAppNamespacedName('License__c'));
 			toggleLicenseRuleSet(AppConfig.getAppNamespacedName('License__c'),true); 	 
 	  	}	
    }   
}