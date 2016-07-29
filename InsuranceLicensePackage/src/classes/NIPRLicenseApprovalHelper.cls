public with sharing class NIPRLicenseApprovalHelper {
    public static final String SUBMIT_ACTION = 'Submit';
    public static final String APPROVE_ACTION = 'Approve';
    public static final String STATUS_APPROVED = 'approved';
    public static final String STATUS_PENDING = 'pending';
    
    public class InstanceInfo {
    	public String workItemId;
    	public String status;
    	public String licenseId; 
    }
    
    public Map<Id, InstanceInfo> getExistingApprovalProcessWorkitems(List<License__c> licenses) {
    	List<Id> licenseIds = new List<Id>();
    	for (License__c license : licenses) {
    		licenseIds.add(license.id);
    	}
    	
    	LicenseRuleHelper.enforceCRUDAndFLS('ProcessInstance', new Set<String>{'TargetObjectId', 'status'}, 'query', false);    	
    	List<ProcessInstance> processInstances = [Select Id, TargetObjectId, status from ProcessInstance  where TargetObjectId in: licenseIds];
    	Map<Id, InstanceInfo> instanceInfoByLicenseId = new Map<Id, InstanceInfo>();
    	for (ProcessInstance p : processInstances) {
    		if (STATUS_APPROVED.equalsIgnoreCase(p.status) || STATUS_PENDING.equalsIgnoreCase(p.status)) {
    			InstanceInfo info = new InstanceInfo();
    			info.status = p.status;
    			info.licenseId = p.targetObjectId;
    			instanceInfoByLicenseId.put(p.targetObjectId, info);
    		}
    	}
   	
    	List<ProcessInstanceWorkitem> workItems = [Select p.Id, p.ProcessInstance.TargetObjectId, p.ProcessInstance.status from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId in:licenseIds];	
    	for (ProcessInstanceWorkitem workItem : workItems) {
    		InstanceInfo info = instanceInfoByLicenseId.get(workItem.ProcessInstance.TargetObjectId);
    		if (info == null) {
    			LogUtils.logError('NIPRLicenseApprovalHelper', 'getExistingApprovalProcessWorkitems' ,'process info is not found (SHOULD NOT HAPPEN)');
    			continue;
    		}
    		
    		if (STATUS_PENDING.equalsIgnoreCase(workItem.ProcessInstance.status)) {
    			info.workItemId = workItem.Id;
    		}
    	}
    	
    	return instanceInfoByLicenseId;
    }
    
    public List<Approval.ProcessResult> processApproval(List<Approval.ProcessRequest> licenseRequests, String action, NIPRLicenseApprovalBatch.ApprovalProcessResult processResult) {
    	List<Approval.ProcessResult> results = Approval.process(licenseRequests, false);
    	List<Approval.ProcessResult> successResults = new List<Approval.ProcessResult>();
    	Integer index = 0;
    	for (Approval.ProcessResult result : results) {
    		if (!result.isSuccess()) {
    			LogUtils.logInfo('NIPRLicenseApprovalHelper', 'processApproval', 'License request status ' + result.getInstanceStatus());
    			if (action == SUBMIT_ACTION) {
    				Approval.ProcessSubmitRequest licenseRequest = (Approval.ProcessSubmitRequest)licenseRequests.get(index);
    				LogUtils.logError('NIPRLicenseApprovalHelper', 'processApproval', 'Action: ' + action + ' failed, for licenseId - ' + licenseRequest.getObjectId());	
    				processResult.errorReport += 'Action: ' + action + ' failed, for licenseId - ' + licenseRequest.getObjectId();
    			} else if (action == APPROVE_ACTION){
    				Approval.ProcessWorkitemRequest licenseRequest = (Approval.ProcessWorkitemRequest)licenseRequests.get(index);
    				LogUtils.logError('NIPRLicenseApprovalHelper', 'processApproval', 'Action: ' + action + ' failed, for workItemId - ' + licenseRequest.getWorkitemId());	
    				processResult.errorReport += 'Action: ' + action + ' failed, for workItemId - ' + licenseRequest.getWorkitemId();
    			}
    			
    			for (Database.Error error : result.getErrors()) {
           	  	   	processResult.errorReport += ' ' + error.getMessage() + '\n\n';
           	  	} 
           	  	processResult.numberOfFailedApprovalProcesses += 1;
    		} else {
    			successResults.add(result);
    			processResult.numberOfSuccessApprovalProcesses += 1;
    		}
    		index += 1;
    	}
    	
    	return successResults;
    }
    
    public Approval.ProcessSubmitRequest submitLicenseApprovalProcess(License__c license, String processNameOfId) {
        // Create an approval request for the license
        Approval.ProcessSubmitRequest licenseRequest = new Approval.ProcessSubmitRequest();
        licenseRequest.setComments('Submitting request for approval.');
        licenseRequest.setObjectId(license.id);
        
        // Submit on behalf of the license owner
        licenseRequest.setSubmitterId(license.ownerId); 
        
        // Submit the record to specific process and skip the criteria evaluation
        licenseRequest.setProcessDefinitionNameOrId(processNameOfId);
       	licenseRequest.setSkipEntryCriteria(true);
        
        return licenseRequest;
    }
        
    // Approve the submitted request
    public Approval.ProcessWorkitemRequest approveLicenseRequest(Id workItemId) {
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest licenseRequestToApprove = new Approval.ProcessWorkitemRequest();
        licenseRequestToApprove.setComments('Approving license request');
        licenseRequestToApprove.setAction(APPROVE_ACTION);
        // this will always be the nipr integration user
        licenseRequestToApprove.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        licenseRequestToApprove.setWorkitemId(workItemId);
        
        return licenseRequestToApprove;
    }
}