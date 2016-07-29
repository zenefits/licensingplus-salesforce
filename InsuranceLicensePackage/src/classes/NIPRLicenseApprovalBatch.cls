public with sharing class NIPRLicenseApprovalBatch implements Database.Batchable<License__c>, Database.Stateful {
    private static final NIPRLicenseApprovalHelper approvalProcessHelper = new NIPRLicenseApprovalHelper();
    
    private List<License__c> licenses;
    private ApprovalProcessResult processResult;
    private String processName;
    
    public class ApprovalProcessResult {
    	public Integer numberOfSuccessApprovalProcesses = 0;
    	public Integer numberOfFailedApprovalProcesses = 0;
    	public String errorReport = '';
    }
    
    public NIPRLicenseApprovalBatch(List<License__c> licenses, String processName){
        this.licenses = licenses;
        this.processResult = new ApprovalProcessResult();
        this.processName = processName;
    }

    public Iterable<License__c> start(Database.BatchableContext bc){
        return this.licenses;
    }
    
    public void execute(Database.BatchableContext bc, List<License__c> licenses){
        List<License__c> licensesShouldBeApproved = new List<License__c>();
        Map<Id, License__c> licenseById = new Map<Id, License__c>();
        
        for (License__c license : licenses) {
            // ignoring unapproved licenses
            if (license.approved__c) {
                licensesShouldBeApproved.add(license);  
                licenseById.put(license.id, license);
            }
        }
        
        if (licensesShouldBeApproved.size()>0) {
            Map<Id, NIPRLicenseApprovalHelper.InstanceInfo> instanceInfoByLicenseId = approvalProcessHelper.getExistingApprovalProcessWorkitems(licensesShouldBeApproved);
            List<License__c> licensesToSubmitForApproval = new List<License__c>();
            for (License__c license : licensesShouldBeApproved) {
                if (instanceInfoByLicenseId.get(license.id) == null) {
                    licensesToSubmitForApproval.add(license);
                }
            }
            
            // submit a license approval if no approval found before
            List<Approval.ProcessSubmitRequest> submitRequests = new List<Approval.ProcessSubmitRequest>();
            List<Approval.ProcessWorkitemRequest> workItemRequests = new List<Approval.ProcessWorkitemRequest>();
            
            for (License__c license : licensesToSubmitForApproval) {
                Approval.ProcessSubmitRequest submitRequest = approvalProcessHelper.submitLicenseApprovalProcess(license, this.processName);
                submitRequests.add(submitRequest);
            }
            
            // update existing license approval, LOGIC as below:
            // if already have one approved approval process, do nothing
            // if have one pending approval process, approve it
            // if other status, submit a new one and approve
            for(Id licenseId : instanceInfoByLicenseId.keySet()) {
                NIPRLicenseApprovalHelper.InstanceInfo instanceInfo = instanceInfoByLicenseId.get(licenseId);
                if (NIPRLicenseApprovalHelper.STATUS_APPROVED.equalsIgnoreCase(instanceInfo.status)) {
                    LogUtils.logInfo('NIPRLicenseApprovalBatch', 'execute', instanceInfo.workItemId + ' already been approved');
                } else if (NIPRLicenseApprovalHelper.STATUS_PENDING.equalsIgnoreCase(instanceInfo.status)) {
                    LogUtils.logInfo('NIPRLicenseApprovalBatch', 'execute', instanceInfo.workItemId + ' is pending to be approved');
                    Approval.ProcessWorkitemRequest workItemRequest = approvalProcessHelper.approveLicenseRequest(instanceInfo.workItemId);
                    workItemRequests.add(workItemRequest);
                }
            }
            
            List<Approval.ProcessResult> submitResults = approvalProcessHelper.processApproval(submitRequests, NIPRLicenseApprovalHelper.SUBMIT_ACTION, this.processResult);
            
            // APPROVE license
            List<Id> workItemIds = new List<Id>();
            for (Approval.ProcessResult result : submitResults) {
                List<Id> newWorkItemIds = result.getNewWorkitemIds();
                if (!newWorkItemIds.isEmpty()) {
                    Approval.ProcessWorkitemRequest workItemRequest = approvalProcessHelper.approveLicenseRequest(newWorkItemIds.get(0));
                    workItemRequests.add(workItemRequest);
                }
            }
            
            approvalProcessHelper.processApproval(workItemRequests, NIPRLicenseApprovalHelper.APPROVE_ACTION, this.processResult);
       
        } else {
            LogUtils.logInfo('NIPRLicenseApprovalBatch', 'execute', ' no license to approve');
        }
    }
    
    public void finish(Database.BatchableContext bc){   
    	// send email to running user
        List<String> recepients = new List<String>{UserInfo.getUserEmail()};
        String displayName = 'Licensing+';
        String subject = 'Batch update license for approval summary - NIPRLicenseApprovalBatch ' + String.valueOf(Date.today());
        String msg = '\n\nnumberOfSuccessApprovalProcesses: ' + processResult.numberOfSuccessApprovalProcesses 
                     + '\n\nnumberOfFailedApprovalProcesses: ' + processResult.numberOfFailedApprovalProcesses
                     + '\n\nerrors: \n\n ' + processResult.errorReport; 
        
        AsyncApexJob a = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: bc.getJobId()];
        String textBody = 'Your batch job NIPRLicenseApprovalBatch has finished. It executed ' + a.TotalJobItems + ' batches. Of which, ' + a.JobItemsProcessed +
          ' processed without any exceptions thrown and ' + a.NumberOfErrors + ' batches threw unhandled exceptions. ' + msg;
        
        LogUtils.logInfo('NIPRLicenseApprovalBatch', 'finish', 'Errors: \n\n');
        LogUtils.logInfo('NIPRLicenseApprovalBatch', 'finish', msg);
        EmailUtils.sendEmail(recepients, displayName, subject, textBody, false, null);
    }
}