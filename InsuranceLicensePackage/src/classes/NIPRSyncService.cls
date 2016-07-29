public with sharing class NIPRSyncService {
    
    private static final Integer BATCH_SIZE = 200;
    
    public NIPRSyncService() {}
    
    public List<NIPRSyncApiResponse.LicenseSyncResponse> syncLicenses(List<NIPRLicense> niprLicenses) {
    	NIPRSyncReportBuilder reportBuilder = new NIPRSyncReportBuilder();
    	NIPRLicenseSyncHelper syncHelper = new NIPRLicenseSyncHelper(niprLicenses, reportBuilder);
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
    	//read the name from custom settings
    	String processName = 'Insurance_License_Approval';
    	
    	//validate the process exists
    	List<ProcessDefinition> processes = [SELECT DeveloperName,Id,TableEnumOrId,Type FROM ProcessDefinition WHERE TableEnumOrId = 'License__c' AND Type = 'Approval' AND DeveloperName =: processName];
    	if (processes.isEmpty()) {
    		processName = null;
    	}
    	
    	return processName;
    }
}