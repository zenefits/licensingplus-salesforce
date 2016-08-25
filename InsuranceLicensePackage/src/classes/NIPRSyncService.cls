public with sharing class NIPRSyncService {
    
    private static final Integer BATCH_SIZE = 200;
    private NIPR_Sync_Config__c defaultSetting = NIPR_Sync_Config__c.getOrgDefaults() ;
    public NIPRSyncService() {}
    
    public List<NIPRSyncApiResponse.LicenseSyncResponse> syncLicenses(List<NIPRLicense> niprLicenses) {
		NIPRSyncReportBuilder reportBuilder = new NIPRSyncReportBuilder();
		LicenseRuleHelper licenseRuleHelper = new LicenseRuleHelper();
		NIPRLicenseSyncHelper syncHelper = new NIPRLicenseSyncHelper(niprLicenses, reportBuilder, licenseRuleHelper);
		List<NIPRSyncApiResponse.LicenseSyncResponse> responses = syncHelper.syncLicenses();
		  
		String processName = getLicenseApprovalProcessName();
		if (processName!=null) {
		  String batchId = Database.executeBatch(new NIPRLicenseApprovalBatch(syncHelper.getLicensesToApprove(), processName), BATCH_SIZE);
		  reportBuilder.logInfoReport('NIPRSyncService','syncLicenses','[APPROVAL BATCH] submit for license approval process batch id - ' + batchId);     
		}
		  
		LogUtils.logInfo('NIPRLicenseSyncProcessor', 'syncLicenses', '\n\n------NIPR Sync REPOPRT------\n\n');
		LogUtils.logInfo('NIPRLicenseSyncProcessor', 'syncLicenses', '\n\n' + reportBuilder.getInfoReport());
		  
		//if needed send report
		sendLicenseSyncErrorReport(syncHelper.getTotalFailures(), syncHelper.getTotalLOAFailures(), syncHelper.getTotalLicenses(), reportBuilder.getErrorReport());
		  
		return responses;
    }

    private void sendLicenseSyncErrorReport(Integer totalFailures, Integer totalLOAFailures, Integer totalLicenses, String errorReport) {
    	// send email to running user
    	List<String> recepients = new List<String> {UserInfo.getUserEmail()}; 
      
    	// send email report out
    	String displayName = 'Licensing+';
    	String subject = 'NIPR License Sync Summary - ' + String.valueOf(Date.today());
    	String textBody = 'NIPR License Sync has finished. numberOfLicenses: ' + totalLicenses+
                            '\n\nnumberOfFailedLicenses: ' + totalFailures +
                            '\n\nnumberOFFailedLOAs: ' + totalLOAFailures +
                            '\n\n\n--------Sync Error Report--------\n\n\n' + errorReport;
        
    	EmailUtils.sendEmail(recepients, displayName, subject, textBody, false, null);
    }
    
    //method to get approval processes
    private String getLicenseApprovalProcessName() {
        String processName = null;
        //read the name from custom settings
        if(!String.isBlank(defaultSetting.ApprovalProcess__c)) {
            processName = defaultSetting.ApprovalProcess__c;
            //validate the process exists
            List<ProcessDefinition> processes = [SELECT DeveloperName,Id,TableEnumOrId,Type FROM ProcessDefinition WHERE TableEnumOrId =:AppConfig.getAppNamespacedName('License__c') AND Type = 'Approval' AND DeveloperName =:processName];
            if (processes.isEmpty()) {
                processName = null;
            }   
        }
        return processName;
    }
}