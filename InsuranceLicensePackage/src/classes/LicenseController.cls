public with sharing class LicenseController {
    public Boolean allowed { get; private set; }
    public Boolean locked { get; private set; }
    public Id approver { get; private set; }
	public final String loaTypes {get; private set;}
    public boolean hasPageErrors {get; private set;}

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
        if (!LicenseRuleHelper.enforceCRUDAndFLSInController('RecordType', new Set<String>{'Id', 'DeveloperName'}, 'query')) {
        	hasPageErrors = true;
        	return null;
        }
        
        List<RecordType> licenseRecordTypes = [SELECT DeveloperName FROM RecordType WHERE Id = :license.RecordTypeId];
		if (licenseRecordTypes.isEmpty()) {
			hasPageErrors = true;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You do not have access to license record types, please contact your admin to enable that.'));
        	return null;
		}
		
        return licenseRecordTypes.get(0).DeveloperName;
    }
    
    public LicenseController(ApexPages.StandardController controller) {
        this.controller = controller;
        allowed = true;
        locked = false;                  
        
        Set<String> licenseFields = new Set<String>{
            'OwnerId',
            AppConfig.getAppNamespacedName('Approved__c'),
	        AppConfig.getAppNamespacedName('Class__c'),
	        AppConfig.getAppNamespacedName('NPN_Number__c'),
	        AppConfig.getAppNamespacedName('Number__c'),
	        AppConfig.getAppNamespacedName('Effective_Date__c'),
	        AppConfig.getAppNamespacedName('Expiration_Date__c')
	    };
        Set<String> customLicenseFields = new Set<String>();
        for (Schema.FieldSetMember field : SObjectType.License__c.FieldSets.Custom_License_Fields.getFields()) {
            customLicenseFields.add(field.getFieldPath());
        }
        licenseFields.addAll(customLicenseFields);      

        if (!Test.isRunningTest()) {
            controller.addFields(new List<String>(licenseFields));
        }

        this.license = (License__c) controller.getRecord();        

        // if user doesn't have access to some license fields, lock record and display errors
        if(!LicenseRuleHelper.enforceCRUDAndFLSInController(AppConfig.getAppNamespacedName('License__c'), licenseFields, 'query')) {
            locked = true;
            hasPageErrors = true;
            return;
        }                   
        
        if (this.license.Approved__c || this.license.Status__c == 'Expired' || this.license.Status__c == 'Active') {
            locked = true;
        }

        loaTypes = loaTypes();          
        
        if ('Non_Resident_State' == getRecordTypeName()) {       

            // If user does not have access to License fields, stop operation and display error
            if (LicenseRuleHelper.enforceCRUDAndFLSInController(AppConfig.getAppNamespacedName('License__c'), new Set<String>{AppConfig.getAppNamespacedName('NPN_Number__c'), 'RecordTypeId', AppConfig.getAppNamespacedName('Number__c'), 'OwnerId'}, 'query')) {
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
            } else {
            	hasPageErrors = true;
            }    
        }

        if (controller.getId() != null) {

            // if user does not have access to Attachment fields, display error and skip query
            Set<String> attachmentFieldsToCheck = new Set<String>{'Id', 'Name', 'Body', 'ParentId', 'CreatedDate'}; 
            if (LicenseRuleHelper.enforceCRUDAndFLSInController('Attachment', attachmentFieldsToCheck, 'query')) {
                List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :controller.getId() ORDER BY CreatedDate ASC LIMIT 1];
                
                if (attachments.size() == 1) {
                    licensePDF = attachments[0];
                }
            } else {
            	hasPageErrors = true;
            }  

            // if user does not have access to ProcessInstance object, display error and skip approval data   
            if (LicenseRuleHelper.enforceCRUDAndFLSInController('ProcessInstance', new Set<String>{'Id', 'TargetObjectId', 'Status'}, 'query')) {
                List<ProcessInstance> pendingProcesses = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :controller.getId() AND Status = 'Pending'];
                
                if (pendingProcesses.size() == 1) {
                    // if user does not have access to ProcessInstanceWorkItem, display error and skip
                    if (LicenseRuleHelper.enforceCRUDAndFLSInController('ProcessInstanceWorkitem', new Set<String>{'Id', 'ProcessInstanceId', 'ActorId'}, 'query')) {
                        List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :pendingProcesses[0].Id AND ActorId = :UserInfo.getUserId()];
                    
                        if (workItems.size() == 1) {
                            approver = workItems[0].Id;
                        } else {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Your license has been submitted for approval.'));
                        }

                        locked = true;                        
		            } else {
		            	hasPageErrors = true;
		            }                   
                } else if (this.license.Status__c != 'Active' && this.license.Status__c != 'Expired') {
                    if (LicenseRuleHelper.enforceCRUDAndFLSInController('ProcessInstance', new Set<String>{'Id', 'TargetObjectId', 'Status', 'CreatedDate'}, 'query')) { 
                        List<ProcessInstance> rejectedProcesses = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :controller.getId() AND Status = 'Rejected' ORDER BY CreatedDate DESC];
                        
                        if (rejectedProcesses.size() > 0) {
                            Set<String> processInstanceStepFieldsToCheck = new Set<String>{'Comments', 'StepStatus', 'ProcessInctanceId', 'CreatedDate'};
                            if (LicenseRuleHelper.enforceCRUDAndFLSInController('ProcessInstanceStep', processInstanceStepFieldsToCheck, 'query')) {
                                List<ProcessInstanceStep> steps = [SELECT Comments FROM ProcessInstanceStep WHERE StepStatus = 'Rejected' AND ProcessInstanceId = :rejectedProcesses[0].Id ORDER BY CreatedDate DESC];

                                if (steps.size() > 0) {
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Latest Rejection Reason: ' + steps[0].Comments));
                                }
                            } else {
            					hasPageErrors = true;
            				}  

                        } else if (this.license.Status__c == 'Ready to Submit' ) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Your license is ready to submit for approval.'));
                        }
                    } else {
            			hasPageErrors = true;
            		}                 
                }
            } else {
            	hasPageErrors = true;
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

        // Field Level Security checks -- include all fields from VF page, and all that were added in constructor
        Set<String> licenseFieldsToCheck = new Set<String>{
            'Name','RecordTypeId',AppConfig.getAppNamespacedName('State__c'),'OwnerId',AppConfig.getAppNamespacedName('Approved__c'),AppConfig.getAppNamespacedName('Class__c'),AppConfig.getAppNamespacedName('NPN_Number__c'),AppConfig.getAppNamespacedName('Number__c'),AppConfig.getAppNamespacedName('Effective_Date__c'),AppConfig.getAppNamespacedName('Expiration_Date__c')
        };
        for (Schema.FieldSetMember field : SObjectType.License__c.FieldSets.Custom_License_Fields.getFields()) {
            licenseFieldsToCheck.add(field.getFieldPath());
        }
        Set<String> attachmentFieldsToCheck = new Set<String>{'Body', 'OwnerId', 'IsPrivate'};
		if (licensePDF.id==null) {
        	attachmentFieldsToCheck.add('ParentId');
        }

        Boolean noAccess = false;
        if (!LicenseRuleHelper.enforceCRUDAndFLSInController(AppConfig.getAppNamespacedName('License__c'), licenseFieldsToCheck, 'upsert')) {noAccess = true;}           
        if (!LicenseRuleHelper.enforceCRUDAndFLSInController('Attachment', attachmentFieldsToCheck, (licensePDF.Id==null ? 'insert' : 'update'))) {noAccess = true;}   
        if (noAccess) {
            return null;
        }     
        // end Field Level Security checks       

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

        // FLS checks
        Set<String> attachmentFieldsToCheck = new Set<String>{'Body', 'OwnerId', 'IsPrivate'};  
        if (licensePDF.id==null) {
        	attachmentFieldsToCheck.add('ParentId');
        }
         
        if (!LicenseRuleHelper.enforceCRUDAndFLSInController('Attachment', attachmentFieldsToCheck, (licensePDF.Id == null ? 'insert' : 'update'))) {return null;}   

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
        // FLS checks
        if (!LicenseRuleHelper.enforceCRUDAndFLSInController('GroupMember', new Set<String>{'UserOrGroupId', 'GroupId'}, 'query')) {return null;}  

        if (1 == [SELECT count() FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId() AND Group.DeveloperName = 'License_Approvers']) return true;
        return false;
    }
    
    private String loaTypes() {
        // If user does not have access to LOA fields, display error
        if (!LicenseRuleHelper.enforceCRUDAndFLSInController(AppConfig.getAppNamespacedName('Line_of_Authority__c'), new Set<String>(), 'query')) {
			return null;
        }   

        if (license != null) {
            Map<String, Set<String>> loaTypesByName = new Map<String, Set<String>>();
            for (String loaSettingName : Line_Of_Authority_Map__c.getAll().keyset()) {       
                Line_Of_Authority_Map__c loaSetting = Line_Of_Authority_Map__c.getInstance(loaSettingName);
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