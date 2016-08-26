public with sharing class LicenseSetController {

    public Id runAs { get; set; }

    public List<License> insuranceLicenses { get; private set; }    
    
    public Map<String, Set<String>> loaTypesByName {get; private set;}
    public boolean hasPageErrors {get; private set;}

    public LicenseSetController(ApexPages.StandardSetController controller) {

        runAs = ApexPages.currentPage().getParameters().get('runAs');
        insuranceLicenses = new List<License>();         
        loaTypesByName = new Map<String, Set<String>>();

        // custom fields from field set to add to FLS check and License query
        Set<String> customLicenseFields = new Set<String>();
        for (Schema.FieldSetMember field : SObjectType.License__c.FieldSets.Custom_License_Fields.getFields()) {
            customLicenseFields.add(field.getFieldPath());
        }        

        // Field Level Security checks
        Boolean noAccess = false;
        Set<String> licenseFieldsToCheck = new Set<String>{'Id', AppConfig.getAppNamespacedName('State__c'), 'RecordTypeId', AppConfig.getAppNamespacedName('Status__c'), 'OwnerId'};
        licenseFieldsToCheck.addAll(customLicenseFields);              
        Set<String> loaFieldsToCheck = new Set<String>{'Name'};    
        if (!LicenseRuleHelper.enforceCRUDAndFLSInController(AppConfig.getAppNamespacedName('License__c'), licenseFieldsToCheck, 'query')) {noAccess = true;}  
        if (!LicenseRuleHelper.enforceCRUDAndFLSInController(AppConfig.getAppNamespacedName('Line_of_Authority__c'), loaFieldsToCheck, 'query')) {noAccess = true;}        
        if (noAccess) {
            hasPageErrors = true;
            return;
        }
        // end Field Level Security checks        
        
        for (String loaSettingName : Line_Of_Authority_Map__c.getAll().keyset()) {
            Line_Of_Authority_Map__c loaSetting = Line_Of_Authority_Map__c.getInstance(loaSettingName);
            String loaName = loaSetting.loa_name__c.toLowerCase();
            Set<String> loaTypes = loaTypesByName.get(loaName) != null ? loaTypesByName.get(loaName) : new Set<String>();
            loaTypes.add(loaSetting.type__c);
            loaTypesByName.put(loaName, loaTypes);
        }
		
		     
    	Set<String> licenseFields = new Set<String>{
    		'Id',AppConfig.getAppNamespacedName('State__c'),'RecordType.Name',AppConfig.getAppNamespacedName('Status__c')
    	};
		licenseFields.addAll(customLicenseFields);
		String queryTemplate = 'SELECT {0},' +
                       			'(SELECT Name from {1}) ' +
                                   'FROM {2} ' +
                                   'WHERE OwnerId = {3} ' + 
                                   'ORDER BY {4}, CreatedDate DESC';
		
		String queryStr = String.format(queryTemplate, 
										new String[]{
											String.escapeSingleQuotes(String.join(new List<String>(licenseFields), ',')), 
											AppConfig.getAppNamespacedName('Lines_Of_Authority__r'),
											AppConfig.getAppNamespacedName('License__c'),
											'\''+String.escapeSingleQuotes(runAs())+'\'',
											AppConfig.getAppNamespacedName('State__c')
											});
		LogUtils.logInfo('LicenseSetController', 'LicenseSetController', 'QUERY - ' + queryStr);
		
        for (License__c license : Database.query(queryStr)) {
            insuranceLicenses.add(new License(license, loaTypesByName));                           
        }      
    }

    public Id runAs() {
        if (runAs != null) return runAs;
        return UserInfo.getUserId();
    }
    
    private class license {
        public License__c license {get; set;}
        public String loaTypes {get; set;}
        
        public license(License__c license, Map<String, Set<String>> loaTypesByName) {
            this.license = license;
            this.loaTypes = getLoaTypes(loaTypesByName);
        }
        
        private String getLoaTypes(Map<String, Set<String>> loaTypesByName) {
            Set<String> allTypes = new Set<String>();
            
            for (Line_Of_Authority__c loa : license.lines_of_authority__r) {
                String loaName = loa.name.toLowerCase();
                if (loaTypesByName.get(loaName) != null) {
	                allTypes.addAll(loaTypesByName.get(loaName));                    
                }
            }
            
            return String.join(new List<String>(allTypes), ', ');
        }
    }   
}