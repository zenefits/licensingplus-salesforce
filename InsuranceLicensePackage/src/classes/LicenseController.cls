public with sharing class LicenseController {
    public Boolean allowed { get; private set; }
    public Boolean locked { get; private set; }
    public Id approver { get; private set; }
	public final String loaTypes {get; private set;}

    public Attachment licensePDF {
        get {
            if (licensePDF == null)
                licensePDF = new Attachment();
            return licensePDF;
        }
        set;
    }

    private final License__c license;
    private ApexPages.StandardController controller;
    
    public String getRecordTypeName() {
        return [SELECT DeveloperName FROM RecordType WHERE Id = :license.RecordTypeId].DeveloperName;
    }
    
    public LicenseController(ApexPages.StandardController controller) {
        this.controller = controller;
        allowed = true;
        locked = false;
        
        if (!Test.isRunningTest()) {
        	Set<String> licenseFields = new Set<String>{
                'OwnerId',
                'Approved__c',
                'Class__c',
                'NPN_Number__c',
                'Number__c',
                'Effective_Date__c',
                'Status__c',
                'Expiration_Date__c'};
            Set<String> customLicenseFields = new Set<String>();
			for (Schema.FieldSetMember field : SObjectType.License__c.FieldSets.Custom_License_Fields.getFields()) {
				customLicenseFields.add(field.getFieldPath());
			}
            licenseFields.addAll(customLicenseFields);
            controller.addFields(new List<String>(licenseFields));
        }
        
        this.license = (License__c) controller.getRecord();
        
        if (this.license.Approved__c || this.license.Status__c == 'Expired' || this.license.Status__c == 'Active') {
            locked = true;
        }
        
        loaTypes = loaTypes();
        
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
            List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :controller.getId() ORDER BY CreatedDate ASC LIMIT 1];
            
            if (attachments.size() == 1) {
                licensePDF = attachments[0];
            }
            
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
        PageReference pr = new PageReference(System.URL.getSalesforceBaseURL().toExternalForm() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + approver);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference saveAndUpload() {
        if (ApexPages.hasMessages()) {
            return null;
        }

        PageReference savePR = controller.save();

        if (ApexPages.hasMessages()) {
            licensePDF = new Attachment();

            return null;
        }

        if (licensePDF.Body != null) {
            licensePDF.OwnerId = UserInfo.getUserId();
            if (licensePDF.Id == null) licensePDF.ParentId = controller.getId();
            licensePDF.IsPrivate = false;
    
            try {
                upsert licensePDF;
            } catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading License PDF'));
                licensePDF = new Attachment();
    
                return null;
            } finally {
                licensePDF = new Attachment();
            }
        }

        return savePR;
    }

    public PageReference upload() {
        PageReference savePR = new PageReference(System.URL.getSalesforceBaseURL().toExternalForm() + '/' + license.Id);

        if (licensePDF.Body != null) {
            licensePDF.OwnerId = UserInfo.getUserId();
            if (licensePDF.Id == null) licensePDF.ParentId = controller.getId();
            licensePDF.IsPrivate = true;
    
            try {
                upsert licensePDF;
            } catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading License PDF'));
                licensePDF = new Attachment();
    
                return null;
            } finally {
                licensePDF = new Attachment();
            }
        }

        return savePR;
    }

    public PageReference viewList() {
        PageReference pageRef = new PageReference(System.URL.getSalesforceBaseURL().toExternalForm() + '/' +  License__c.SObjectType.getDescribe().getKeyPrefix());
        
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    public Boolean getIsAdmin() {
        if (1 == [SELECT count() FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId() AND Group.DeveloperName = 'License_Approvers']) return true;
        return false;
    }
    
    private String loaTypes() {
        if (license != null) {
            Map<String, Set<String>> loaTypesByName = new Map<String, Set<String>>();
            for (String loaSettingName : Lines_of_Authority__c.getAll().keyset()) {       
                Lines_of_Authority__c loaSetting = Lines_of_Authority__c.getInstance(loaSettingName);
                String loaName = loaSetting.loa_name__c.toLowerCase();
                Set<String> loaTypes = loaTypesByName.get(loaName) != null ? loaTypesByName.get(loaName) : new Set<String>();
                loaTypes.add(loaSetting.type__c);
                loaTypesByName.put(loaName, loaTypes);
            }       
            
            Set<String> allTypes = new Set<String>();            
            for (Line_of_Authority__c loa : [select name from line_of_authority__c where License__c =: license.id]) {                
                String loaName = loa.name.toLowerCase();
                if (loaTypesByName.get(loaName) != null) {
                    allTypes.addAll(loaTypesByName.get(loaName));                    
                }
            }
            
            return String.join(new List<String>(allTypes), ', ');                            
        } else {
            return null;
        }
    }
    
    public Boolean getCustomLicenseFieldsEmpty() {
    	return SObjectType.License__c.FieldSets.Custom_License_Fields.getFields().isEmpty();
    }
}