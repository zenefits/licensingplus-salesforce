public with sharing class LicenseController {
    public Boolean allowed { get; private set; }
    public Boolean locked { get; private set; }
    public Id approver { get; private set; }

    private final License__c license;
    private ApexPages.StandardController controller;
    
    public String getRecordTypeName() {
        return [SELECT DeveloperName FROM RecordType WHERE Id = :license.RecordTypeId].DeveloperName;
    }
    
    public LicenseController(ApexPages.StandardController controller) {
        this.controller = controller;
        allowed = true;
        locked = false;
        
        if (!Test.isRunningTest())
            controller.addFields(new List<String>{
                'OwnerId',
                'Approved__c',
                'Confirmation_ID__c',
                'NPN_Number__c',
                'Application_Date__c',
                'Number__c',
                'Effective_Date__c',
                'Status__c',
                'Expiration_Date__c',
                'Casualty__c',
                'Health__c',
                'Life__c',
                'Property__c'});
        
        this.license = (License__c) controller.getRecord();
        
        if (this.license.Approved__c || this.license.Status__c == 'Expired' || this.license.Status__c == 'Active') {
            locked = true;
        }
        
        if ('Non_Resident_State' == getRecordTypeName()) {
            List<License__c> residentLicenses = [SELECT NPN_Number__c
                          FROM License__c
                              WHERE RecordType.DeveloperName = 'Resident_State'
                                  AND Number__c != ''
                                  AND OwnerId = :UserInfo.getUserId()];
            
            if (0 == residentLicenses.size() && controller.getId() == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to locate an active resident state license'));
                
                allowed = false;
            } else {
                if (controller.getId() == null)
                    this.license.NPN_Number__c = residentLicenses[0].NPN_Number__c;
            }
        }

        if (controller.getId() != null) {            
            List<ProcessInstance> pendingProcesses = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :controller.getId() AND Status = 'Pending'];
            
            if (pendingProcesses.size() == 1) {
                List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :pendingProcesses[0].Id AND ActorId = :UserInfo.getUserId()];
            
                if (workItems.size() == 1) {
                    approver = workItems[0].Id;
                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Your license has been submitted for approval.'));
                }

                locked = true;
            } else if (this.license.Status__c != 'Active' && this.license.Status__c != 'Expired') {
                List<ProcessInstance> rejectedProcesses = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :controller.getId() AND Status = 'Rejected' ORDER BY CreatedDate DESC];
                
                if (rejectedProcesses.size() > 0) {
                    List<ProcessInstanceStep> steps = [SELECT Comments FROM ProcessInstanceStep WHERE StepStatus = 'Rejected' AND ProcessInstanceId = :rejectedProcesses[0].Id ORDER BY CreatedDate DESC];

                    if (steps.size() > 0) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Latest Rejection Reason: ' + steps[0].Comments));
                    }
                } else if (this.license.Status__c == 'Ready to Submit' ) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Your license is ready to submit for approval.'));
                }
            }
        }
    }

    public PageReference approveReject() {
        PageReference pr = new PageReference('/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + approver);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference viewList() {
        PageReference pageRef = new PageReference('/' +  License__c.SObjectType.getDescribe().getKeyPrefix());
        
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    public Boolean getIsAdmin() {
        if (1 == [SELECT count() FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId() AND Group.DeveloperName = 'License_Approvers']) return true;
        return false;
    }
}