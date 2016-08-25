@isTest
private class NIPRLicenseSyncTest {
    
    private static String LOA_NAME = 'Life';
    private static Map<String, Schema.RecordTypeInfo> licenseRecordTypes;
    private static String newNPNNumber = 'test12345';
    private static String newNPNNumber1 = 'test123456';
    private static String invalidNPNNumber = 'test123456890123456789';
    private static String updateClassName = '123456';
    private static Integer numberOfLicenses = 50;
    private static String testLOA = 'Life and Health';
    private static Id rlRecordTypeId = NIPRLicenseSyncHelper.rlRT;
    private static Id nrlRecordTypeId = NIPRLicenseSyncHelper.nonRLRT;
    private static Integer firstIncomplete = 6;
    private static Integer secondIncomplete = 9;
    private static String updatedLicenseNumber = '12345';
    private static Id pendingInstanceId = null;
    private static Id rejectInstanceId = null;
    private static String processName = null;  
    private static User adminUser;
    private static Date niprUpdateDate1 = Date.newInstance(2015, 8, 9);
    private static Date niprUpdateDate2 = Date.newInstance(2015, 8, 10);
    private static Date niprUpdateDateOld = Date.newInstance(2015, 8, 8);
    private static PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'License_Compliance_Admin']; 
    
    class LicenseRequestBody {
        String className = 'test';
        Date effectiveDate  = Date.newInstance(2015, 6, 1);
        Date expirationDate = Date.newInstance(2036, 7, 2);
        Date niprUpdateDate = niprUpdateDate1;
        Boolean isResidentLicense = true;
        String licenseNumber = 'test';
        Boolean isActive = true;
        String resident_state = 'CA';
        String non_resident_state = 'HI';
        String loaName1 = LOA_NAME+'1';
        String loaName2 = LOA_NAME+'2';
        String npnNumber= 'testNpnNumber';
    }
    
    private static Map<String, String> setupUsers(){
        LicenseRequestBody licenseBody = new LicenseRequestBody();
        Profile sp = [SELECT Id FROM profile WHERE name='System Administrator'];
        UserRole ur = new UserRole(Name='Admin');
        insert new UserRole[]{ur};
            
            String username = 'test654CBA@test.com';
        List<User> testUsers = new List<User>();
        for (Integer i=2; i<numberOfLicenses; i=i+2) {
            User testUser = new User(alias = 'uxxx1', email='this.coly@gmail.com', emailencodingkey='UTF-8', firstname='FN', lastname='Testing'+i, 
                                     languagelocalekey='en_US', localesidkey='en_US', profileid = sp.Id, country='United States', UserRoleId = ur.id,
                                     timezonesidkey='America/Los_Angeles', username=username+i, npn_number__c=licenseBody.npnNumber+i); 
            testUsers.add(testUser);
        }
        
        // prepare for new npn number
        User testUser1 = new User(alias = 'uxxx1', email='this.coly@gmail.com', emailencodingkey='UTF-8', firstname='FN', lastname='Testing'+1000, 
                                  languagelocalekey='en_US', localesidkey='en_US', profileid = sp.Id, country='United States', UserRoleId = ur.id,
                                  timezonesidkey='America/Los_Angeles', username=username+1000, npn_number__c=newNPNNumber); 
        
        User testUser2 = new User(alias = 'uxxx1', email='this.coly@gmail.com', emailencodingkey='UTF-8', firstname='FN', lastname='Testing'+1000, 
                                  languagelocalekey='en_US', localesidkey='en_US', profileid = sp.Id, country='United States', UserRoleId = ur.id,
                                  timezonesidkey='America/Los_Angeles', username=username+1001, npn_number__c=newNPNNumber1); 
        
        testUsers.add(testUser1);
        testUsers.add(testUser2);
        
        insert testUsers;
        
        Map<String, String> ownerIdByNpnNumber = new Map<String, String>();
        for (User testUser : testUsers) {
            ownerIdByNpnNumber.put(testUser.npn_number__c, testUser.id);
        }
        
        adminUser = testUsers.get(0);
        insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id); 
        
        return ownerIdByNpnNumber;
    }
    
    private static List<NIPRLicense> generateLicenseRequestBody() {
        LicenseRequestBody licenseBody = new LicenseRequestBody();
        List<NIPRLicense> niprLicenses = new List<NIPRLicense>();
        
        for (Integer i=2; i<numberOfLicenses; i=i+2) {
            String npnNumber = licenseBody.npnNumber + i;
            
            NIPRLicense residentnipr = new NIPRLicense();
            residentnipr.className = licenseBody.className+i;
            residentnipr.effectiveDate = licenseBody.effectiveDate;
            residentnipr.expirationDate = licenseBody.expirationDate;
            residentnipr.state = licenseBody.resident_state;
            residentnipr.licenseNumber = licenseBody.licenseNumber + i;
            residentnipr.npnNumber = npnNumber;
            residentnipr.isActive = true;
            residentnipr.isResidentLicense = true;
            residentnipr.niprUpdateDate = licenseBody.niprUpdateDate;
            
            String loaName1 = licenseBody.loaName1;
            String loaName2 = licenseBody.loaName2;
            
            NIPRLicense.LineOfAuthority loa1 = new NIPRLicense.LineOfAuthority();
            loa1.name = loaName1;
            loa1.isActive = true;
            
            NIPRLicense.LineOfAuthority loa2 = new NIPRLicense.LineOfAuthority();
            loa2.name = loaName2;
            loa2.isActive = true;
            
            residentnipr.linesOfAuthority.add(loa1);
            residentnipr.linesOfAuthority.add(loa2);
            niprLicenses.add(residentnipr);
            
            NIPRLicense nonresidentnipr = new NIPRLicense();
            nonresidentnipr.className = licenseBody.className+i;
            nonresidentnipr.effectiveDate = licenseBody.effectiveDate;
            nonresidentnipr.expirationDate = licenseBody.expirationDate;
            nonresidentnipr.state = licenseBody.non_resident_state;
            nonresidentnipr.licenseNumber = licenseBody.licenseNumber + i + 1;
            nonresidentnipr.npnNumber = npnNumber;
            nonresidentnipr.isActive = true;
            nonresidentnipr.isResidentLicense = false;
            nonresidentnipr.niprUpdateDate = licenseBody.niprUpdateDate;
            
            NIPRLicense.LineOfAuthority loa3 = new NIPRLicense.LineOfAuthority();
            loa3.name = loaName1;
            loa3.isActive = true;
            
            NIPRLicense.LineOfAuthority loa4 = new NIPRLicense.LineOfAuthority();
            loa4.name = loaName2;
            loa4.isActive = true;
            
            nonresidentnipr.linesOfAuthority.add(loa3);
            nonresidentnipr.linesOfAuthority.add(loa4);  
            niprLicenses.add(nonresidentnipr);
        }
        
        return niprLicenses;
    }
    
    private static List<List<License__c>> generateTestLicenses(Map<String, String> ownerIdByNpnNumber, List<NIPRLicense> niprLicenses) {
        List<License__c> testResidentLicenses = new List<License__c>();
        List<License__c> testNonResidentLicenses = new List<License__c>();
        
        Integer index = 0;
        for (NIPRLicense nipr : niprLicenses) {
            // since firstIncomplete license won't be active, we won't be able to create a non resident license for it, so skip it
            if (index!=firstIncomplete+1) {
                Id recordTypeId = nipr.isResidentLicense ? rlRecordTypeId : nrlRecordTypeId;
                
                License__c license = new License__c();
                license.class__c = nipr.className;
                license.effective_date__c = !(index==firstIncomplete || index==secondIncomplete) ? nipr.effectiveDate : null;
                license.expiration_date__c = !(index==firstIncomplete || index==secondIncomplete) ? nipr.expirationDate : null;
                license.state__c = LicensingUtils.stateMap.get(nipr.state);
                license.number__c = !(index==firstIncomplete || index==secondIncomplete) ? nipr.licenseNumber : null;
                license.npn_number__c = !(index==firstIncomplete || index==secondIncomplete) ? (nipr.isResidentLicense ? nipr.npnNumber : null) : null;
                license.ownerId = ownerIdByNpnNumber.get(nipr.npnNumber);
                license.recordTypeId = recordTypeId;
                license.approved__c = !(index==firstIncomplete || index==secondIncomplete) ? true: false;
                license.nipr_update_date__c = nipr.niprUpdateDate;
                if (nipr.isResidentLicense) {
                    testResidentLicenses.add(license);
                } else {
                    testNonResidentLicenses.add(license);  
                }
            }
            index += 1;
        }
        
        insert testResidentLicenses;
        insert testNonResidentLicenses;
        
        List<List<License__c>> results = new List<List<License__c>>();
        results.add(testResidentLicenses);
        results.add(testNonResidentLicenses);
        
        return results;
    }
    
    private static List<Line_of_Authority__c> generateTestLOAs(List<List<License__c>> allLicenses) {
        List<Line_of_Authority__c> testLOAs = new List<Line_of_Authority__c>();
        for (List<License__c> licenses : allLicenses) {
            Integer index = 0;
            for (License__c license : licenses) {
                String loaName1 = LOA_NAME+'1';
                String loaName2 = LOA_NAME+'2';
                
                Line_of_Authority__c testLOA1 = new Line_of_Authority__c();
                testLOA1.name = loaName1;
                testLOA1.License__c = license.id;
                
                Line_of_Authority__c testLOA2 = new Line_of_Authority__c();
                testLOA2.name = loaName2;
                testLOA2.License__c = license.id;
                
                testLOAs.add(testLOA1);
                testLOAs.add(testLOA2);
                index += 1;
            }
        }
        
        insert testLOAs;
        
        List<License__c> testResidentLicenses = allLicenses.get(0);
        List<License__c> testNonResidentLicenses = allLicenses.get(1);
        
        if (processName!=null) {
            // create an approved approval
            Approval.ProcessSubmitRequest licenseRequest1 = new Approval.ProcessSubmitRequest();
            licenseRequest1.setComments('Submitting request for approval.');
            licenseRequest1.setObjectId(testResidentLicenses.get(5).id);
            
            // Submit on behalf of the license owner
            licenseRequest1.setSubmitterId(testResidentLicenses.get(5).ownerId); 
            
            // Submit the record to specific process and skip the criteria evaluation
            licenseRequest1.setProcessDefinitionNameOrId(processName);
            licenseRequest1.setSkipEntryCriteria(true);
            
            Approval.ProcessResult result1 = Approval.process(licenseRequest1);
            
            Approval.ProcessWorkitemRequest licenseRequestToApprove1 = new Approval.ProcessWorkitemRequest();
            licenseRequestToApprove1.setComments('Approving license request');
            licenseRequestToApprove1.setAction('Approve');
            // this will always be niprbot
            licenseRequestToApprove1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            
            // Use the ID from the newly created item to specify the item to be worked
            licenseRequestToApprove1.setWorkitemId(result1.getNewWorkitemIds().get(0));
            Approval.process(licenseRequestToApprove1);
            
            // create a pending approval
            Approval.ProcessSubmitRequest licenseRequest2 = new Approval.ProcessSubmitRequest();
            licenseRequest2.setComments('Submitting request for approval.');
            licenseRequest2.setObjectId(testNonResidentLicenses.get(5).id);
            
            // Submit on behalf of the license owner
            licenseRequest2.setSubmitterId(testNonResidentLicenses.get(5).ownerId); 
            
            // Submit the record to specific process and skip the criteria evaluation
            licenseRequest2.setProcessDefinitionNameOrId(processName);
            licenseRequest2.setSkipEntryCriteria(true);
            
            Approval.ProcessResult result2 = Approval.process(licenseRequest2);
            pendingInstanceId = result2.getInstanceId();
            
            // create an rejected approval
            Approval.ProcessSubmitRequest licenseRequest3 = new Approval.ProcessSubmitRequest();
            licenseRequest3.setComments('Submitting request for approval.');
            licenseRequest3.setObjectId(testResidentLicenses.get(6).id);
            
            // Submit on behalf of the license owner
            licenseRequest3.setSubmitterId(testResidentLicenses.get(6).ownerId); 
            
            // Submit the record to specific process and skip the criteria evaluation
            licenseRequest3.setProcessDefinitionNameOrId('Insurance_License_Approval');
            licenseRequest3.setSkipEntryCriteria(true);
            
            Approval.ProcessResult result3 = Approval.process(licenseRequest3);
            rejectInstanceId = result3.getInstanceId();
            
            Approval.ProcessWorkitemRequest licenseRequestToApprove3 = new Approval.ProcessWorkitemRequest();
            licenseRequestToApprove3.setComments('Rejecting license request');
            licenseRequestToApprove3.setAction('Reject');
            // this will always be niprbot
            licenseRequestToApprove3.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            
            // Use the ID from the newly created item to specify the item to be worked
            licenseRequestToApprove3.setWorkitemId(result3.getNewWorkitemIds().get(0));
            Approval.process(licenseRequestToApprove3);
        }
        
        return testLOAs;
    }
    
    static void addNewNiprLicenses(List<NIPRLicense> licenseRequestBody) {
        // add new resident license for life & health
        LicenseRequestBody licenseBody = new LicenseRequestBody();
        NIPRLicense newNipr = new NIPRLicense();
        newNipr.npnNumber = newNPNNumber;
        newNipr.className = licenseBody.className + 1;
        newNipr.effectiveDate = licenseBody.effectiveDate;
        newNipr.expirationDate = licenseBody.expirationDate;
        newNipr.state = 'MI';
        newNipr.licenseNumber = licenseBody.licenseNumber + 1;
        newNipr.isActive = true;
        newNipr.isResidentLicense = true;
        newNipr.niprUpdateDate = licenseBody.niprUpdateDate;
        
        NIPRLicense.LineOfAuthority loa1 = new NIPRLicense.LineOfAuthority();
        loa1.name = licenseBody.loaName1;
        loa1.isActive = true;
        
        NIPRLicense.LineOfAuthority loa2 = new NIPRLicense.LineOfAuthority();
        loa2.name = licenseBody.loaName2;
        loa2.isActive = true;
        
        newNipr.linesOfAuthority.add(loa1);
        newNipr.linesOfAuthority.add(loa2);
        
        // add new non resident license - life & health
        NIPRLicense newNipr1 = new NIPRLicense();
        newNipr1.className = 'mytest'+ 5001;
        newNipr1.npnNumber = newNPNNumber;
        newNipr1.effectiveDate = licenseBody.effectiveDate;
        newNipr1.expirationDate = null;
        newNipr1.state = 'VA';
        newNipr1.licenseNumber = 'mytest' + 5001;
        newNipr1.isActive = true;
        newNipr1.isResidentLicense = false;
        newNipr1.niprUpdateDate = licenseBody.niprUpdateDate;
        NIPRLicense.LineOfAuthority loa3 = new NIPRLicense.LineOfAuthority();
        loa3.name = 'bad bad';
        loa3.isActive = true;
        
        NIPRLicense.LineOfAuthority loa4 = new NIPRLicense.LineOfAuthority();
        loa4.name = licenseBody.loaName1;
        loa4.isActive = true;
        newNipr1.linesOfAuthority.add(loa3);
        newNipr1.linesOfAuthority.add(loa4);
        
        //test for dml error - non resident license should be created after resident license
        NIPRLicense newNipr2 = new NIPRLicense();
        newNipr2.npnNumber = newNPNNumber1;
        newNipr2.effectiveDate = licenseBody.effectiveDate;
        newNipr2.expirationDate = licenseBody.expirationDate;
        newNipr2.state = 'PA';
        newNipr2.licenseNumber = licenseBody.licenseNumber + 1002;
        newNipr2.isActive = true;
        newNipr2.isResidentLicense = false;
        newNipr2.niprUpdateDate = licenseBody.niprUpdateDate;
        
        //expired license not in sfdc
        NIPRLicense newNipr3 = new NIPRLicense();
        newNipr3.npnNumber = newNPNNumber;
        newNipr3.effectiveDate = Date.newInstance(2006,1,20);
        newNipr3.expirationDate = Date.newInstance(2007,1,20);
        newNipr3.state = 'CA';
        newNipr3.licenseNumber = licenseBody.licenseNumber + 1004;
        newNipr3.isActive = false;
        newNipr3.isResidentLicense = true;
        newNipr3.niprUpdateDate = licenseBody.niprUpdateDate;
        
        licenseRequestBody.add(newNipr);
        licenseRequestBody.add(newNipr1);
        licenseRequestBody.add(newNipr2);
        licenseRequestBody.add(newNipr3);
    }
    
    static void addNewInvalidNiprLicenses(List<NIPRLicense> licenseRequestBody) {
        // add new resident license
        LicenseRequestBody licenseBody = new LicenseRequestBody();
        NIPRLicense newNipr = new NIPRLicense();
        newNipr.npnNumber = invalidNPNNumber;
        newNipr.className = licenseBody.className+1000;
        newNipr.effectiveDate = licenseBody.effectiveDate;
        newNipr.expirationDate = licenseBody.expirationDate;
        newNipr.state = 'CA';
        newNipr.licenseNumber = licenseBody.licenseNumber + 1005;
        newNipr.isActive = true;
        newNipr.isResidentLicense = true;
        newNipr.niprUpdateDate = licenseBody.niprUpdateDate;
        
        licenseRequestBody.add(newNipr);
    }
    
    static void updateNiprLicenses(List<NIPRLicense> licenseRequestBody) {
        
        // update some license to not active
        NIPRLicense niprToUpdate1 = licenseRequestBody.get(0);
        niprToUpdate1.className = updateClassName;
        niprToUpdate1.niprUpdateDate = niprUpdateDate2;
        
        NIPRLicense niprToUpdate2 = licenseRequestBody.get(1);
        niprToUpdate2.isActive = false;
        niprToUpdate2.niprUpdateDate = niprUpdateDate2;
        for (NIPRLicense.LineOfAuthority loa : niprToUpdate2.linesOfAuthority) {
            loa.isActive = false;
        }
        
        // add new loas
        NIPRLicense niprToAddLOAs = licenseRequestBody.get(2);
        NIPRLicense.LineOfAuthority newLOA = new NIPRLicense.LineOfAuthority();
        newLOA.name = testLOA;
        newLOA.isActive = true;
        niprToAddLOAs.linesOfAuthority.add(newLOA);
        
        // remove all loas
        NIPRLicense niprToDeleteLOAs = licenseRequestBody.get(3);
        niprToDeleteLOAs.linesOfAuthority.clear();
        niprToDeleteLOAs.niprUpdateDate = niprUpdateDate2;
        
        // test nipr manual override field
        NIPRLicense niprToTestOverride = licenseRequestBody.get(4);
        niprToTestOverride.className = updateClassName;
        niprToTestOverride.niprUpdateDate = niprUpdateDate2;
        
        // remove one loa
        NIPRLicense niprToRemoveLOAs = licenseRequestBody.get(5);
        niprToRemoveLOAs.linesOfAuthority.remove(0);
        niprToRemoveLOAs.niprUpdateDate = niprUpdateDate2;
        
        // update license with old nipr update date
        NIPRLicense niprToUpdateWithOldNiprDate1 = licenseRequestBody.get(10);
        niprToUpdateWithOldNiprDate1.className = updateClassName;
        niprToUpdateWithOldNiprDate1.niprUpdateDate = niprUpdateDateOld;
        
        NIPRLicense niprToUpdateWithOldNiprDate2 = licenseRequestBody.get(11);
        niprToUpdateWithOldNiprDate2.className = updateClassName;
        niprToUpdateWithOldNiprDate2.niprUpdateDate = niprUpdateDateOld;
    }
    
    static void createNIPRSyncConfig() {
    	NIPR_Sync_Config__c syncConfig = NIPR_Sync_Config__c.getOrgDefaults();
        syncConfig.NIPR_Integration_User_Name__c = adminUser.username;
        syncConfig.ForceExpire__c = true;
    	
        List<ProcessDefinition> processes = [SELECT DeveloperName,Id,TableEnumOrId,Type FROM ProcessDefinition WHERE TableEnumOrId =: AppConfig.getAppNamespacedName('License__c') AND Type = 'Approval'];
        if (!processes.isEmpty()) {
            processName = processes.get(0).developerName;
            syncConfig.ApprovalProcess__c = processName;
        }     
        
        insert syncConfig;
    }
    
    static testMethod void testNIPRLicenseSync() {
        Map<String, String> ownerIdByNpnNumber = setupUsers();
        
        System.runAs(adminUser) {
            createNIPRSyncConfig();
            List<NIPRLicense> licenseRequestBody = generateLicenseRequestBody();
            List<List<License__c>> allLicenses = generateTestLicenses(ownerIdByNpnNumber, licenseRequestBody);
            List<Line_of_Authority__c> allLoas = generateTestLOAs(allLicenses);
            
            List<License_Rule__c> approvalCriteria = LicenseRuleTestDataSeeder.createLicenseApprovalCriteria(true);
            License_Rule_Logic__c approvalCriteriaLogic = LicenseRuleTestDataSeeder.createLicenseApprovalCriteriaLogic(approvalCriteria, true);
            
            updateNiprLicenses(licenseRequestBody);
            addNewNiprLicenses(licenseRequestBody);
            addNewInvalidNiprLicenses(licenseRequestBody);
            
            License__c licenseToSetOverride = allLicenses.get(0).get(2);
            licenseToSetOverride.nipr_manual_override__c = true;
            update licenseToSetOverride;
            
            String payload = Json.serialize(licenseRequestBody);
            Blob testPayload = Blob.ValueOf(payLoad);
            RestRequest req = new RestRequest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/nipr/sync/license';  //Request URL
            req.httpMethod = 'POST';
            req.requestBody = testPayload;
            RestContext.request = req;
            
            Test.startTest();
            List<NIPRSyncApiResponse.LicenseSyncResponse> responses = NIPRLicenseSyncApi.syncNIPRLicenses();
            Test.stopTest();
            
            String[] newNPNNumbers = new String[]{newNPNNumber};
                
                //verify new license is added and approved
                List<License__c> newLicenses = [SELECT nipr_update_date__c, resident_license__r.npn_number__c, effective_date__c, expiration_date__c, id, approved__c, recordtypeid, (SELECT id FROM Lines_of_Authority__r)  FROM License__c WHERE  (npn_number__c IN:newNPNNumbers OR resident_license__r.npn_number__c IN:newNPNNumbers)];
            system.assertEquals(2, newLicenses.size());
            for (License__c license : newLicenses) {
                Integer loaCount = 0;
                for (Line_of_Authority__c loa : license.Lines_of_Authority__r) {
                    loaCount += 1;
                }
                system.assertEquals(2, loaCount);
                system.assertEquals(niprUpdateDate1.day(), license.nipr_update_date__c.day());
                
                if (license.recordTypeId == rlRecordTypeId) {
                    system.assert(license.approved__c);
                } else {
                    system.assert(!license.approved__c);            
                }           
            }
            
            //verify licese is updated
            List<License__c> updatedLicenses = [SELECT nipr_update_date__c, force_expire__c, class__c, recordTypeId, status__c, approved__c, number__c, (SELECT id FROM Lines_of_Authority__r) FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(0).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(0).npnNumber)];
            system.assertEquals(2, updatedLicenses.size());
            for (License__c license : updatedLicenses) {
                system.assertEquals(niprUpdateDate2.day(), license.nipr_update_date__c.day());
                if (license.recordTypeId == rlRecordTypeId) {
                    system.assertEquals(updateClassName, license.class__c);
                    system.assertEquals(false, license.force_expire__c);
                    system.assertEquals('Active', license.status__c);
                    system.assertNotEquals(updatedLicenseNumber, license.number__c);
                    system.assert(license.approved__c);
                    
                } else {
                    system.assertEquals(true, license.force_expire__c);
                    system.assertEquals('Expired', license.status__c);
                    system.assert(license.approved__c);
                }
            }
            
            //verify licese is not updated with old nipr update date
            List<License__c> notUpdatedLicenses = [SELECT nipr_update_date__c, force_expire__c, class__c, recordTypeId, status__c, approved__c, number__c, (SELECT id FROM Lines_of_Authority__r) FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(10).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(10).npnNumber)];
            system.assertEquals(2, notUpdatedLicenses.size());
            for (License__c notUpdatedLicense : notUpdatedLicenses) {
                system.assertEquals(niprUpdateDate1.day(), notUpdatedLicense.nipr_update_date__c.day());
                system.assertNotEquals(updateClassName, notUpdatedLicense.class__c);
            }
            
            //verify loa are added
            List<License__c> loaUpdatedLicenses = [SELECT class__c, effective_date__c, expiration_date__c, recordTypeId, status__c, approved__c, (SELECT id, name FROM Lines_of_Authority__r) FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(2).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(2).npnNumber)];
            system.assertEquals(2, loaUpdatedLicenses.size());
            for (License__c license : loaUpdatedLicenses) {
                if (license.recordTypeId == rlRecordTypeId) {
                    Boolean newLOAAdded = false;
                    for (Line_of_Authority__c loa : license.Lines_of_Authority__r) {
                        if (loa.name == testLOA) {
                            newLOAAdded = true;
                        }
                    }
                    system.assert(newLOAAdded);
                    system.assert(license.approved__c);
                    
                } else {
                    system.assert(license.approved__c);
                } 
            }
            
            //verify loa are added
            List<License__c> loaUpdatedLicenses1 = [SELECT class__c, effective_date__c, expiration_date__c, recordTypeId, status__c, approved__c, (SELECT id, name FROM Lines_of_Authority__r) FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(4).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(4).npnNumber)];
            system.assertEquals(2, loaUpdatedLicenses1.size());
            for (License__c license : loaUpdatedLicenses1) {
                if (license.recordTypeId == rlRecordTypeId) {
                    system.assert(license.approved__c);
                    system.assertNotEquals(updateClassName, license.class__c);
                } else {
                    system.assert(license.approved__c);
                } 
            }
            
            //verify approval process are created and approved
            if (processName!=null) {
                List<License__c> approvedLicenses = [SELECT id FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(10).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(10).npnNumber) OR (npn_number__c=:licenseRequestBody.get(12).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(12).npnNumber)];
                system.assertEquals(4, approvedLicenses.size());
                List<Id> approvedLicenseIds = new List<Id>();
                for (License__c approvedLicense : approvedLicenses) {
                    approvedLicenseIds.add(approvedLicense.id);
                }
                
                List<ProcessInstance> processInstances = [Select p.Id, p.TargetObjectId, p.status from ProcessInstance p where p.TargetObjectId in:approvedLicenseIds];
                
                Boolean existingPendingApprovalFound = false;
                for (ProcessInstance processInstance : processInstances) {            
                    if (processInstance.id == rejectInstanceId) {
                        system.assertEquals('Rejected', processInstance.status);
                        
                    } else {
                        if (processInstance.id == pendingInstanceId) {
                            existingPendingApprovalFound = true;
                        }
                        system.assertEquals('Approved', processInstance.status);  
                    }
                }
                
                system.assert(existingPendingApprovalFound);
            }
            
            Boolean npnNumberNotFound = false;
            Boolean dmlError = false;
            for (NIPRSyncApiResponse.LicenseSyncResponse response : responses) {
                if (!response.isSuccess) {
                    if (response.errorCode==NIPRSyncError.SyncError.NPN_NUMBER_NOT_FOUND.name()) {
                        npnNumberNotFound = true;
                    } else if (response.errorCode==NIPRSyncError.SyncError.DML_ERROR.name()) {
                        dmlError = true;
                    }            
                }
            }
            system.assert(npnNumberNotFound);
            system.assert(dmlError);
        }
    }  
    
    static testmethod void testImportLicenseData() {
        Map<String, String> ownerIdByNpnNumber = setupUsers();
        System.runAs(adminUser) {
            createNIPRSyncConfig();
            List<NIPRLicense> licenseRequestBody = generateLicenseRequestBody();
            List<List<License__c>> allLicenses = generateTestLicenses(ownerIdByNpnNumber, licenseRequestBody);
            List<Line_of_Authority__c> allLoas = generateTestLOAs(allLicenses);
            
            List<License_Rule__c> approvalCriteria = LicenseRuleTestDataSeeder.createLicenseApprovalCriteria(true);
            License_Rule_Logic__c approvalCriteriaLogic = LicenseRuleTestDataSeeder.createLicenseApprovalCriteriaLogic(approvalCriteria, true);
            
            updateNiprLicenses(licenseRequestBody);
            addNewNiprLicenses(licenseRequestBody);
            addNewInvalidNiprLicenses(licenseRequestBody);
            
            License__c licenseToSetOverride = allLicenses.get(0).get(2);
            licenseToSetOverride.nipr_manual_override__c = true;
            update licenseToSetOverride;
            
            
            Test.startTest();
            List<NIPRSyncApiResponse.LicenseSyncResponse> responses = ComplianceController.importLicenseData(licenseRequestBody);
            Test.stopTest();
            
            String[] newNPNNumbers = new String[]{newNPNNumber};
                
                //verify new license is added and approved
                List<License__c> newLicenses = [SELECT nipr_update_date__c, resident_license__r.npn_number__c, effective_date__c, expiration_date__c, id, approved__c, recordtypeid, (SELECT id FROM Lines_of_Authority__r)  FROM License__c WHERE  (npn_number__c IN:newNPNNumbers OR resident_license__r.npn_number__c IN:newNPNNumbers)];
            system.assertEquals(2, newLicenses.size());
            for (License__c license : newLicenses) {
                Integer loaCount = 0;
                for (Line_of_Authority__c loa : license.Lines_of_Authority__r) {
                    loaCount += 1;
                }
                system.assertEquals(2, loaCount);
                system.assertEquals(niprUpdateDate1.day(), license.nipr_update_date__c.day());
                
                if (license.recordTypeId == rlRecordTypeId) {
                    system.assert(license.approved__c);
                } else {
                    system.assert(!license.approved__c);            
                }           
            }
            
            //verify licese is updated
            List<License__c> updatedLicenses = [SELECT nipr_update_date__c, force_expire__c, class__c, recordTypeId, status__c, approved__c, number__c, (SELECT id FROM Lines_of_Authority__r) FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(0).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(0).npnNumber)];
            system.assertEquals(2, updatedLicenses.size());
            for (License__c license : updatedLicenses) {
                system.assertEquals(niprUpdateDate2.day(), license.nipr_update_date__c.day());
                if (license.recordTypeId == rlRecordTypeId) {
                    system.assertEquals(updateClassName, license.class__c);
                    system.assertEquals(false, license.force_expire__c);
                    system.assertEquals('Active', license.status__c);
                    system.assertNotEquals(updatedLicenseNumber, license.number__c);
                    system.assert(license.approved__c);
                    
                } else {
                    system.assertEquals(true, license.force_expire__c);
                    system.assertEquals('Expired', license.status__c);
                    system.assert(license.approved__c);
                }
            }
            
            //verify licese is not updated with old nipr update date
            List<License__c> notUpdatedLicenses = [SELECT nipr_update_date__c, force_expire__c, class__c, recordTypeId, status__c, approved__c, number__c, (SELECT id FROM Lines_of_Authority__r) FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(10).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(10).npnNumber)];
            system.assertEquals(2, notUpdatedLicenses.size());
            for (License__c notUpdatedLicense : notUpdatedLicenses) {
                system.assertEquals(niprUpdateDate1.day(), notUpdatedLicense.nipr_update_date__c.day());
                system.assertNotEquals(updateClassName, notUpdatedLicense.class__c);
            }
            
            //verify loa are added
            List<License__c> loaUpdatedLicenses = [SELECT class__c, effective_date__c, expiration_date__c, recordTypeId, status__c, approved__c, (SELECT id, name FROM Lines_of_Authority__r) FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(2).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(2).npnNumber)];
            system.assertEquals(2, loaUpdatedLicenses.size());
            for (License__c license : loaUpdatedLicenses) {
                if (license.recordTypeId == rlRecordTypeId) {
                    Boolean newLOAAdded = false;
                    for (Line_of_Authority__c loa : license.Lines_of_Authority__r) {
                        if (loa.name == testLOA) {
                            newLOAAdded = true;
                        }
                    }
                    system.assert(newLOAAdded);
                    system.assert(license.approved__c);
                    
                } else {
                    system.assert(license.approved__c);
                } 
            }
            
            //verify loa are added
            List<License__c> loaUpdatedLicenses1 = [SELECT class__c, effective_date__c, expiration_date__c, recordTypeId, status__c, approved__c, (SELECT id, name FROM Lines_of_Authority__r) FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(4).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(4).npnNumber)];
            system.assertEquals(2, loaUpdatedLicenses1.size());
            for (License__c license : loaUpdatedLicenses1) {
                if (license.recordTypeId == rlRecordTypeId) {
                    system.assert(license.approved__c);
                    system.assertNotEquals(updateClassName, license.class__c);
                } else {
                    system.assert(license.approved__c);
                } 
            }
            
            //verify approval process are created and approved
            if (processName!=null) {
                List<License__c> approvedLicenses = [SELECT id FROM License__c WHERE (npn_number__c=:licenseRequestBody.get(10).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(10).npnNumber) OR (npn_number__c=:licenseRequestBody.get(12).npnNumber OR resident_license__r.npn_number__c=:licenseRequestBody.get(12).npnNumber)];
                system.assertEquals(4, approvedLicenses.size());
                List<Id> approvedLicenseIds = new List<Id>();
                for (License__c approvedLicense : approvedLicenses) {
                    approvedLicenseIds.add(approvedLicense.id);
                }
                
                List<ProcessInstance> processInstances = [Select p.Id, p.TargetObjectId, p.status from ProcessInstance p where p.TargetObjectId in:approvedLicenseIds];
                
                Boolean existingPendingApprovalFound = false;
                for (ProcessInstance processInstance : processInstances) {            
                    if (processInstance.id == rejectInstanceId) {
                        system.assertEquals('Rejected', processInstance.status);
                        
                    } else {
                        if (processInstance.id == pendingInstanceId) {
                            existingPendingApprovalFound = true;
                        }
                        system.assertEquals('Approved', processInstance.status);  
                    }
                }
                
                system.assert(existingPendingApprovalFound);
            }
            
            Boolean npnNumberNotFound = false;
            Boolean dmlError = false;
            for (NIPRSyncApiResponse.LicenseSyncResponse response : responses) {
                if (!response.isSuccess) {
                    if (response.errorCode==NIPRSyncError.SyncError.NPN_NUMBER_NOT_FOUND.name()) {
                        npnNumberNotFound = true;
                    } else if (response.errorCode==NIPRSyncError.SyncError.DML_ERROR.name()) {
                        dmlError = true;
                    }            
                }
            }
            system.assert(npnNumberNotFound);
            system.assert(dmlError);
            
        }
    } 
}