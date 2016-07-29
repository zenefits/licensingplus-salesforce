public with sharing class NIPRLicenseSyncHelper {
    
    private class OwnerInfo {
        String npnNumber;
        String userId;
        
        OwnerInfo(String npnNumber, String userId) {
            this.npnNumber = npnNumber;         
            this.userId = userId;
        }
        
        public override String toString() {
            return String.format('npnNumber: {0}, userId: {1}', 
                                    new String[]{this.npnNumber, this.userId});
        }
    }
    
    private final NIPRSyncReportBuilder reportBuilder;
   
   	// used for existing licenses matching
    private Set<String> npnNumbers;
    private Set<String> states;
    private Set<Date> effectiveDates;
    private Set<String> licenseNumbers;

    private List<NIPRLicense> niprLicenses;
    private Map<String, License__c> residentLicensesToCreateByKey;
    private Map<String, License__c> nonresidentLicensesToCreateByKey;
    private Map<String, License__c> licensesToUpdateByKey;
    private Map<String, List<Line_of_Authority__c>> loaToCreateByKey;
    private Map<String, NIPRSyncApiResponse.LicenseSyncResponse> responseByKey;
    private List<License__c> licensesToApprove;
    private Map<String, OwnerInfo> ownerInfoByNpnNumber;
    private Integer totalFailures = 0;
    private Integer totalLOAFailures = 0;
    private Integer totalLicenses = 0;
    
    public static Id rlRT = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId();
    public static Id nonRLRT = Schema.SObjectType.License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId();
    private static final Integer BATCH_SIZE = 50;
    private final static Set<String> licenseFields = new Set<String>{
        'OwnerId',
        AppConfig.getAppNamespacedName('NIPR_Manual_Override__c'),
        AppConfig.getAppNamespacedName('Approved__c'),
        AppConfig.getAppNamespacedName('Class__c'),
        AppConfig.getAppNamespacedName('NPN_Number__c'),
        AppConfig.getAppNamespacedName('Number__c'),
        AppConfig.getAppNamespacedName('Effective_Date__c'),
        AppConfig.getAppNamespacedName('Expiration_Date__c'),
        AppConfig.getAppNamespacedName('Resident_License__c'),
        AppConfig.getAppNamespacedName('State__c')};
    
    public NIPRLicenseSyncHelper(List<NIPRLicense> niprLicenses, NIPRSyncReportBuilder reportBuilder) {
    	this.reportBuilder = reportBuilder;
        this.niprLicenses = niprLicenses;
        
        this.licensesToApprove = new List<License__c>();        
        this.npnNumbers = new Set<String>();
        this.states = new Set<String>();
        this.licenseNumbers = new Set<String>();
        this.effectiveDates = new Set<Date>();
        this.residentLicensesToCreateByKey = new Map<String, License__c>();
        this.nonresidentLicensesToCreateByKey = new Map<String, License__c>();
        this.licensesToUpdateByKey = new Map<String, License__c>();
        this.loaToCreateByKey = new Map<String, List<Line_of_Authority__c>>();
        this.responseByKey = new Map<String, NIPRSyncApiResponse.LicenseSyncResponse>();
        this.ownerInfoByNpnNumber = new Map<String, OwnerInfo>();
        
        init();
    }
    
    public List<NIPRSyncApiResponse.LicenseSyncResponse> syncLicenses() {
    	Set<String> licenseQueryFields = licenseFields.clone();
    	licenseQueryFields.add(AppConfig.getAppNamespacedName('Status__c'));
    	
    	LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License__c'), licenseQueryFields, 'query', false);  
    	LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('Line_of_Authority__c'), new Set<String>(), 'query', false); 	
    	
        List<License__c> existingIncompleteLicenses = [SELECT nipr_manual_override__c, ownerid, id, npn_number__c, number__c, resident_license__r.npn_number__c, effective_date__c, state__c,  (SELECT id, name FROM Lines_of_Authority__r) 
                                            FROM License__c WHERE (npn_number__c = null AND resident_license__r.npn_number__c=null) OR number__c = null OR effective_date__c = null];
        
        Map<String, License__c> existingIncompleteLicenseByKey = buildExistingIncompleteLicenseMap(existingIncompleteLicenses);
        
        List<NIPRLicense> completeNiprLicenses = new List<NIPRLicense>(); 
        Set<Id> incompleteLicenseIds = new Set<Id>();
        logInfo('syncLicense', '[LICENSE STATS] total licenses to process - ' + this.niprLicenses.size());
        for (NIPRLicense nipr : this.niprLicenses) {
            handleIncompleteLicenseUpdate(nipr, existingIncompleteLicenseByKey, completeNiprLicenses, incompleteLicenseIds);
        }
        
        logInfo('syncLicense', '[LICENSE STATS] total complete licenses to process - ' + completeNiprLicenses.size());
            
        List<License__c> existingLicenses = [SELECT nipr_manual_override__c, id, npn_number__c, number__c, resident_license__r.npn_number__c, effective_date__c, state__c,  (SELECT id, name FROM Lines_of_Authority__r) 
                                            FROM License__c WHERE (npn_number__c IN:npnNumbers OR resident_license__r.npn_number__c IN:npnNumbers) AND effective_date__c IN:effectiveDates AND 
                                            					state__c IN:states AND number__c IN:licenseNumbers];
        
        Map<String, License__c> existingLicenseByKey = buildExistingLicenseMap(existingLicenses);
        for (NIPRLicense nipr : completeNiprLicenses) {
            handleLicenseCreateOrUpdate(nipr, existingLicenseByKey);
        }
        
        // handle create/update/delete
        Map<String, String> licenseIdByKey = new Map<String, String>();
        
        logInfo('syncLicense', '[LICENSE STATS] total resident licenses to create ' + residentLicensesToCreateByKey.size());
        Set<String> allLicenseIds = new Set<String>();
        if (!residentLicensesToCreateByKey.isEmpty()) {
            Integer failures = insertOrUpdateLicenses(residentLicensesToCreateByKey, true);
            this.totalFailures += failures;
            for (String key : residentLicensesToCreateByKey.keySet()) {
                License__c license = residentLicensesToCreateByKey.get(key);
                if (license.id!=null) {
                    licenseIdByKey.put(key, license.id);
                    logInfo('syncLicense', '[LICENSE CREATE] inserted licenseId: ' + license.id + ' Key: ' + key);
                    if (license.approved__c) {
                        licensesToApprove.add(license); 
                    }
                }       
            }
        }
        
        logInfo('syncLicense', '[LICENSE STATS] total non resident licenses to create ' + nonresidentLicensesToCreateByKey.size());
        if (!nonresidentLicensesToCreateByKey.isEmpty()) {
            Integer failures = insertOrUpdateLicenses(nonresidentLicensesToCreateByKey, true);
            this.totalFailures += failures;
            for (String key : nonresidentLicensesToCreateByKey.keySet()) {
                License__c license = nonresidentLicensesToCreateByKey.get(key);
                if (license.id!=null) {
                    licenseIdByKey.put(key, license.id);
                    logInfo('syncLicense', '[LICENSE CREATE] inserted non licenseId: ' + license.id + ' Key: ' + key);
                    if (license.approved__c) {
                        licensesToApprove.add(license); 
                    }
                }       
            }
        }
        
        // create loa first to avoid approval trigger issues
        LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('Line_of_Authority__c'), new Set<String>{'Name'}, 'insert', false);  
        if (!loaToCreateByKey.isEmpty()) {
            Integer totalLOAsToCreate = 0;
            List<Line_of_Authority__c> loaToInsert = new List<Line_of_Authority__c>();
            for (String key : loaToCreateByKey.keySet()) {
                List<Line_of_Authority__c> loas = loaToCreateByKey.get(key);
                totalLOAsToCreate += loas.size();
                for (Line_of_Authority__c loa : loas) {
                    if (loa.License__c==null) {
                        String licenseId = licenseIdByKey.get(key);
                        // for insert
                        if (licenseId!=null) {
                            loa.License__c = licenseId;
                            loaToInsert.add(loa);
                        //  loa without license id
                        } else {
                            logInfo('syncLicense', '[LICENSE ERROR] failed to find the license id for loa name ' + + loa.name + ' with license key ' + key);
                        }
                    } else {
                        loaToInsert.add(loa);
                    } 
                }                   
            }
            logInfo('syncLicense', '[LICENSE STATS] total loas to create ' + totalLOAsToCreate);
            List<Database.SaveResult> loaInsertResults = Database.insert(loaToInsert, false);
            for(Integer i=0; i<loaInsertResults.size(); i++){
                Database.SaveResult saveResult = loaInsertResults[i];
                if(!saveResult.isSuccess()) {
                   String errorMessage = '';
                   for (Database.Error error : saveResult.getErrors()) {
                      errorMessage += error.getMessage() + '\n\n';
                   }
                   this.totalLOAFailures += 1;
                   logInfo('syncLicense', errorMessage);                
                }
             }
        }
        
        logInfo('syncLicense', '[LICENSE STATS] total licenses to update ' + licensesToUpdateByKey.size());
        if (!licensesToUpdateByKey.isEmpty()) {
            Integer failures = insertOrUpdateLicenses(licensesToUpdateByKey, false);
            totalFailures += failures;
            for (String key : licensesToUpdateByKey.keySet()) {
                License__c license = licensesToUpdateByKey.get(key);
                if (license.id!=null) {
                    licenseIdByKey.put(key, license.id);
                    logInfo('syncLicense', '[LICENSE UPDATE] updated licenseId: ' + license.id + ' Key: ' + key);
                    if (license.approved__c) {
                        licensesToApprove.add(license); 
                    }
                }       
            }
        }
        
        /* handle loa is not active case
        logInfo('syncLicense', 'Total loas to delete ' + loaToDelete.size());
        if (!loaToDelete.isEmpty()) {
            List<Database.DeleteResult> loaDeleteResults = Database.delete(loaToDelete, false);
            for(Integer i=0; i<loaDeleteResults.size(); i++){
                Database.DeleteResult deleteResult = loaDeleteResults[i];
                if(!deleteResult.isSuccess()) {
                   String errorMessage = '';
                   for (Database.Error error : deleteResult.getErrors()) {
                      errorMessage += error.getMessage() + '\n\n';
                   }
                   totalFailedLOAs += 1;
                   logInfo('syncLicense', errorMessage);                
                }
             }
        }*/
        
        this.totalLicenses = this.niprLicenses.size();

        // construct sync response
        List<NIPRSyncApiResponse.LicenseSyncResponse> responses = new List<NIPRSyncApiResponse.LicenseSyncResponse>();
        for (NIPRLicense nipr : this.niprLicenses) {
            String key = getNIPRLicenseKey(nipr);
            NIPRSyncApiResponse.LicenseSyncResponse response = this.responseByKey.get(key);
            
            //this should not happen
            if (response==null) {
            	String errorMessage = NIPRSyncError.errorMessageByType.get(NIPRSyncError.SyncError.NPN_NUMBER_NOT_FOUND);
            	response = NIPRSyncApiResponse.getLicenseSyncResponse(key, false, NIPRSyncError.SyncError.RESPONSE_NOT_FOUND, errorMessage); 
            }
            responses.add(response);
        }
        
        return responses;
    }
    
    public List<License__c> getLicensesToApprove() {
    	return this.licensesToApprove;
    }
    
    public Integer getTotalFailures() {
    	return this.totalFailures;
    }
    
    public Integer getTotalLOAFailures() {
    	return this.totalLOAFailures;
    }
    
    public Integer getTotalLicenses() {
    	return this.totalLicenses;
    }
     
    /** PRIVATE METHODS GOES HERE **/
    private void logInfo(String method, String message) {
    	this.reportBuilder.logInfoReport('NIPRLicenseSyncHelper', method, message);
    }
    
    private void logError(String method, String message) {
    	logInfo(method, message);
    	this.reportBuilder.logErrorReport('NIPRLicenseSyncHelper', method, message);
    }
    
    private void init() {
        //key will be (npn number, state, effective date, license number)
        for (NIPRLicense nipr : this.niprLicenses) {
        	String originalState = nipr.state;
	        nipr.state = LicensingUtils.stateMap.get(nipr.state);	        	        
	        if (nipr.state == null) {
	           logInfo('init', '[LICENSE ERROR] not able to find state ' + originalState);
	           continue;
	        }                   

            this.npnNumbers.add(nipr.npnNumber);
            this.states.add(nipr.state);        
            this.effectiveDates.add(nipr.effectiveDate);
            this.licenseNumbers.add(nipr.licenseNumber);
        }
        
        LicenseRuleHelper.enforceCRUDAndFLS('User', new Set<String>{AppConfig.getAppNamespacedName('npn_number__c')}, 'query', false);  
        
        for (User user : [SELECT id, npn_number__c FROM User WHERE npn_number__c IN: this.npnNumbers]) {
            OwnerInfo info = new OwnerInfo(user.npn_number__c, user.id);
            this.ownerInfoByNpnNumber.put(user.npn_number__c, info);
            logInfo('init', '[USER INFO] ' + info.toString());
        }
    }
    
    /** Logic to handle incomplete license information in the system **/
    private void handleIncompleteLicenseUpdate(NIPRLicense nipr, Map<String, License__c> existingIncompleteLicenseByKey, List<NIPRLicense> completeLicenses, Set<Id> incompleteLicenseIds) {
        String key = getNIPRLicenseKey(nipr);
        OwnerInfo ownerInfo = this.ownerInfoByNpnNumber.get(nipr.npnNumber);
        if (ownerInfo!=null) {
            if (nipr.state==null) {
            	this.totalFailures += 1;
                String errorMessage = NIPRSyncError.errorMessageByType.get(NIPRSyncError.SyncError.STATE_NOT_FOUND);
                NIPRSyncApiResponse.LicenseSyncResponse response = NIPRSyncApiResponse.getLicenseSyncResponse(key, false, NIPRSyncError.SyncError.STATE_NOT_FOUND, errorMessage);
                this.responseByKey.put(key, response);
                logError('handleIncompleteLicenseUpdate', '[LICENSE ERROR] not able to find state for this license ' + key);
            } else {
                String incompleteKey = ownerInfo.userId + ';' + nipr.state;
                License__c license = existingIncompleteLicenseByKey.get(incompleteKey);
                
                //do nothing for nipr manual override license
                if (license != null && license.nipr_manual_override__c) {
                    NIPRSyncApiResponse.LicenseSyncResponse response = NIPRSyncApiResponse.getLicenseSyncResponse(key, true, null, null);
                    this.responseByKey.put(key, response);
                    logInfo('handleIncompleteLicenseUpdate', '[LICENSE INFO] nipr manual override checked with key - ' + key + ' licenseid - ' + license.id);              
                    return;
                }
                
                if (license != null && !incompleteLicenseIds.contains(license.id)) {
                    logInfo('handleIncompleteLicenseUpdate', '[LICENSE INFO] Incomplete license found with key ' + key);
                    updateLicense(nipr, license, ownerInfo);
                    incompleteLicenseIds.add(license.id);
                } else {
                    completeLicenses.add(nipr);
                }
            }
        } else {
        	this.totalFailures += 1;
        	String errorMessage = NIPRSyncError.errorMessageByType.get(NIPRSyncError.SyncError.NPN_NUMBER_NOT_FOUND);
            NIPRSyncApiResponse.LicenseSyncResponse response = NIPRSyncApiResponse.getLicenseSyncResponse(key, false, NIPRSyncError.SyncError.NPN_NUMBER_NOT_FOUND, errorMessage);
            this.responseByKey.put(key, response);
            logError('handleIncompleteLicenseUpdate', '[LICENSE ERROR] not able to match owner with npn number ' + nipr.npnNumber);
        }
    }
    
    private void handleLicenseCreateOrUpdate(NIPRLicense nipr, Map<String, License__c> existingLicenseByKey) {
        String key = getNIPRLicenseKey(nipr);
        OwnerInfo ownerInfo = this.ownerInfoByNpnNumber.get(nipr.npnNumber);
        if (ownerInfo!=null) {
            if (nipr.state==null) {
            	this.totalFailures += 1;
                String errorMessage = NIPRSyncError.errorMessageByType.get(NIPRSyncError.SyncError.STATE_NOT_FOUND);
                NIPRSyncApiResponse.LicenseSyncResponse response = NIPRSyncApiResponse.getLicenseSyncResponse(key, false, NIPRSyncError.SyncError.STATE_NOT_FOUND, errorMessage);
                this.responseByKey.put(key, response);
                logError('handleLicenseCreateOrUpdate', '[LICENSE ERROR] not able to find state for this license ' + key);
            } else {
                License__c license = matchLicense(nipr, existingLicenseByKey);
                if (license == null) {
                    if (nipr.isActive) {
                        createLicense(nipr, ownerInfo);
                    
                    } else {
                        NIPRSyncApiResponse.LicenseSyncResponse response = NIPRSyncApiResponse.getLicenseSyncResponse(key, true, null, null);
                        this.responseByKey.put(key, response);
                        logInfo('handleLicenseCreateOrUpdate', '[LICENSE INFO] inactive license key - ' + key + ' with no record found in SFDC');
                    }
                } else {
                    //do nothing for nipr manual override license
                    if (license.nipr_manual_override__c) {
                        NIPRSyncApiResponse.LicenseSyncResponse response = NIPRSyncApiResponse.getLicenseSyncResponse(key, true, null, null);
                        this.responseByKey.put(key, response);
                        logInfo('handleLicenseCreateOrUpdate', '[LICENSE INFO] nipr manual override checked with key - ' + key + ' licenseid - ' + license.id);                
                        return;
                    }
                    
                    updateLicense(nipr, license, ownerInfo);
                }   
            }
        } else {
        	this.totalFailures += 1;
        	String errorMessage = NIPRSyncError.errorMessageByType.get(NIPRSyncError.SyncError.NPN_NUMBER_NOT_FOUND);
           	NIPRSyncApiResponse.LicenseSyncResponse response = NIPRSyncApiResponse.getLicenseSyncResponse(key, false, NIPRSyncError.SyncError.RESPONSE_NOT_FOUND, errorMessage); 
            
            this.responseByKey.put(key, response);
            logError('handleLicenseCreateOrUpdate', '[LICENSE ERROR] not able to match owner with npn number ' + nipr.npnNumber);
        }
    }
  
    private Map<String, License__c> buildExistingLicenseMap(List<License__c> existingLicenses) {
        Map<String, License__c> existingLicenseByKey = new Map<String, License__c>();
        
        for (License__c existingLicense : existingLicenses) {
            String key = getNIPRLicenseKey(existingLicense);
            existingLicenseByKey.put(key, existingLicense);
        }
                
        return existingLicenseByKey;
    }
    
    private Map<String, License__c> buildExistingIncompleteLicenseMap(List<License__c> existingIncompleteLicenses) {
        Map<String, License__c> existingIncompleteLicenseByKey = new Map<String, License__c>();
        for (License__c license : existingIncompleteLicenses) {
            String key = license.ownerId + ';' + license.state__c;
            existingIncompleteLicenseByKey.put(key, license);
        }
        
        return existingIncompleteLicenseByKey;
    }
    
    private Integer insertOrUpdateLicenses(Map<String, License__c> licenseByKey, Boolean isInsert) {
        Integer totalFailures = 0;
        List<License__c> licenses = new List<License__c>();
        List<String> keys = new List<String>();
        for (String key : licenseByKey.keySet()) {
            licenses.add(licenseByKey.get(key));
            keys.add(key);
        }
        
        List<Database.SaveResult> results = null;
        if (isInsert) {
        	LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License__c'), licenseFields, 'insert', false);  
            results = Database.insert(licenses, false);
        } else {
            LicenseRuleHelper.enforceCRUDAndFLS(AppConfig.getAppNamespacedName('License__c'), licenseFields, 'update', false); 
            results = Database.update(licenses, false);
        }
        List<License__c> failedResults = new List<License__c>();
        List<String> failedKeys = new List<String>();
        for(Integer i = 0; i < results.size(); i++){
           String key = keys[i];
           if(!results[i].isSuccess()){
                failedKeys.add(keys[i]);
                failedResults.add(licenses[i]); 
           } else {
                NIPRSyncApiResponse.LicenseSyncResponse response = NIPRSyncApiResponse.getLicenseSyncResponse(key, true, null, null);
                this.responseByKey.put(key, response);
           }
        }
        
        //retry a second time
        if (failedResults.size()>0) {
            List<Database.SaveResult> lastResults = null;
            if (isInsert) {
                lastResults = Database.insert(failedResults, false);
            } else {
                lastResults = Database.update(failedResults, false);
            }
            for(Integer i=0; i<lastResults.size(); i++){
                Database.SaveResult saveResult = lastResults[i];
                String key = failedKeys[i];
                NIPRSyncApiResponse.LicenseSyncResponse response = null;
                if(!saveResult.isSuccess()) {
                   	String errorMessage = '';
                   	for (Database.Error error : saveResult.getErrors()) {
                      	errorMessage += error.getMessage() + '\n';
                   	}
                   	String message = String.format(NIPRSyncError.errorMessageByType.get(NIPRSyncError.SyncError.DML_ERROR), new String[]{errorMessage});
            		response = NIPRSyncApiResponse.getLicenseSyncResponse(key, false, NIPRSyncError.SyncError.DML_ERROR, errorMessage); 
					totalFailures += 1;
                   	logError('insertOrUpdateLicenses', '[LICENSE ERROR]'+ message + ' license key: ' + key);                
               
                } else {
                	response = NIPRSyncApiResponse.getLicenseSyncResponse(key, true, null, null);
                }
                this.responseByKey.put(key, response);
             }
         }
         
         return totalFailures;
    } 
    
    private License__c matchLicense(NIPRLicense nipr, Map<String, License__c> existingLicenseByKey) {
        String key = getNIPRLicenseKey(nipr);   
        return existingLicenseByKey.get(key);
    }
    
    private void createLicense(NIPRLicense nipr, OwnerInfo ownerInfo) {
        String key = getNIPRLicenseKey(nipr);
        License__c license = new License__c();
        if (nipr.isResidentLicense) {
            logInfo('createLicense', '[CREATE LICENSE] resident license key - ' + key);
            license.recordTypeId = rlRT;
            license.npn_number__c = nipr.npnNumber;
            this.residentLicensesToCreateByKey.put(key, license);
        } else {
            logInfo('createLicense', '[CREATE LICENSE] non resident license key - ' + key);
            license.recordTypeId = nonRLRT;
            this.nonresidentLicensesToCreateByKey.put(key, license);
        }
        license.effective_date__c = nipr.effectiveDate;
        license.expiration_date__c = nipr.expirationDate;
        license.state__c = nipr.state;
        license.number__c = nipr.licenseNumber;
        license.class__c = nipr.className;
        license.ownerId = ownerInfo.userId;
         
        for (NIPRLicense.LineOfAuthority loa : nipr.linesOfAuthority) {
            if (loa.isActive) { 
                createLOA(nipr, loa);           
            } else {
                logInfo('createLicense', String.format('[LICENSE ERROR] inactive line of authority - {0} for license - {1}', new String[]{loa.name, key}));
            }
        }
        
        setLicenseApproved(ownerInfo, license, key);
    }
    
    private void updateLicense(NIPRLicense nipr, License__c license, OwnerInfo ownerInfo) {
        String key = getNIPRLicenseKey(nipr);
        if (!nipr.isActive) {
            logInfo('updateLicense', String.format('[LICENSE ERROR] license key - {0} with record id - {1} is now inactive', new String[]{key, license.id}));
            license.force_expire__c = true;
        } else {
            license.force_expire__c = false;
        }
        if (nipr.isResidentLicense) {
            logInfo('updateLicense', '[LICENSE UPDATE] residence license key - ' + key);
            license.recordTypeId = rlRT;
            license.npn_number__c = nipr.npnNumber;
        } else {
            logInfo('updateLicense', '[LICENSE UPDATE] non residence license key - ' + key);
            license.recordTypeId = nonRLRT;
            license.npn_number__c = null;
        }
        
       	license.number__c = nipr.licenseNumber;
        license.class__c = nipr.className;
        license.effective_date__c = nipr.effectiveDate;
        license.expiration_date__c = nipr.expirationDate;
        this.licensesToUpdateByKey.put(key, license);
        
        Map<String, Line_of_Authority__c> loaByName = new Map<String, Line_of_Authority__c>();
        for (Line_of_Authority__c loa : license.Lines_of_Authority__r) {
            String loaName = loa.name.toLowerCase();
            loaByName.put(loaName, loa);
        }

        for (NIPRLicense.LineOfAuthority loa : nipr.linesOfAuthority) {
            String loaName = loa.name.toLowerCase();
            Line_of_Authority__c existingLOA = loaByName.get(loaName);
            if (loa.isActive) {               
                if (existingLOA==null) {
                    Line_of_Authority__c newLOA = createLOA(nipr, loa);
                    newLOA.License__c = license.id;
                    
                } else {
                    logInfo('updateLicense', String.format('[LICENESE INFO] existing line of authority - {0} found for license - {1}', new String[]{loa.name, key}));
                }
            } else {
                logInfo('updateLicense', String.format('[LICENSE ERROR] inactive line of authority - {0} for license - {1}', new String[]{loa.name, key}));
                
                /* how to handle inactive loa
                if (existingLOA!=null) {
                    logInfo('deleteLOA', String.format('DELETE existing line of authority - {0} found for license - {1}', new String[]{loa.name, key}));
                    this.loaToDelete.add(existingLOA);
                }*/
            }
        }
        
        Boolean isApprovedBefore = license.approved__c;
        setLicenseApproved(ownerInfo, license, key);
        if (isApprovedBefore && !license.approved__c) {
            license.pending_approval__c = false;
        }
    }
    
    //THIS METHOD NEEDS TO CHANGE TO MEET APPROVE CRITERIA
    private Boolean setLicenseApproved(OwnerInfo ownerInfo, License__c license, String key) {
        /*Boolean result = true;
        if (result) {
        	
        } else {
        	report.append('setLicenseApproved', String.format('Unapproved license - property: {0}, casualty: {1} for license - {2}', new String[]{String.valueOf(hasProperty), String.valueOf(hasCasualty), key})); 
            license.approved__c = false;
            license.missing_criteria__c = true;
        }
        
        if (ownerInfo.userRole !=null && ownerInfo.userRole.containsIgnoreCase(P_C)) {
            if (hasProperty && hasCasualty) {
                license.approved__c = true;
                license.missing_loa__c = false;
            
            } else {
                logInfo('shouldApproveLicense', String.format('Unapproved license - property: {0}, casualty: {1} for license - {2}', new String[]{String.valueOf(hasProperty), String.valueOf(hasCasualty), key})); 
                license.approved__c = false;
                license.missing_loa__c = true;
            }       
        } else {
            if (hasLife && hasHealth) {
                license.approved__c = true;
                license.missing_loa__c = false;
            
            } else {
                logInfo('shouldApproveLicense', String.format('Unapproved license - life: {0}, health: {1} for license - {2}', new String[]{String.valueOf(hasLife), String.valueOf(hasHealth), key})); 
                license.approved__c =false;
                license.missing_loa__c = true;
            }
        }
        
        return license.approved__c;*/
        license.approved__c = true;
        return license.approved__c;
    }
    
    private Line_of_Authority__c createLOA(NIPRLicense nipr, NIPRLicense.LineOfAuthority loa) {
        Line_of_Authority__c newLOA = new Line_of_Authority__c();
        newLOA.name = loa.name;
        String key = getNIPRLicenseKey(nipr);
        List<Line_of_Authority__c> loas = this.loaToCreateByKey.get(key);
        if (loas==null) {
            loas = new List<Line_of_Authority__c>();
            this.loaToCreateByKey.put(key, loas);
        }
        loas.add(newLOA);
        logInfo('createLOA', String.format('[LOA CREATE] no existing line of authority - {0} found for license - {1}', new String[]{loa.name, key}));
        return newLOA;
    }
    
    private String getNIPRLicenseKey(License__c nipr) {
        String npnNumber = nipr.npn_number__c!=null ? nipr.npn_number__c : nipr.resident_license__r.npn_number__c;
        return npnNumber + ';' + nipr.number__c + ';' + nipr.state__c + ';' + nipr.effective_date__c.format();
    }
    
    private String getNIPRLicenseKey(NIPRLicense nipr) {
        return nipr.npnNumber + ';' + nipr.licenseNumber + ';' + nipr.state + ';' + nipr.effectiveDate.format();
    }
}