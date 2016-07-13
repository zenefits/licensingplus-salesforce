public class LicenseTriggerHandler {
    
    public static Id residentLicenseType = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Resident State').getRecordTypeId();
    public static Id nonResidentLicenseType = Schema.SObjectType.licensingplus__License__c.getRecordTypeInfosByName().get('Non-Resident State').getRecordTypeId();
    
    //On license insertion, set Type and resident license and do some validation
    public static void setTypeAndResidentLicense(List<licensingplus__License__c> newList) {
        
        Map<Id, Set<String>> existingLicenses = new Map<Id, Set<String>>();
        Map<Id, Id> residentLicenses = new Map<Id, Id>();
        
        for (licensingplus__License__c license : newList) {
            
            if (license.RecordTypeId == nonResidentLicenseType) {
                residentLicenses.put(license.OwnerId, null);
            }
            
            existingLicenses.put(license.OwnerId, new Set<String>());
        }
        
        if (existingLicenses.size() > 0) {
        	//Get other licenses that are not Active/Expired and with the same owner
            for (licensingplus__License__c otherLicense : [SELECT licensingplus__State__c, OwnerId FROM licensingplus__License__c WHERE OwnerId IN :existingLicenses.keySet() AND licensingplus__Status__c != 'Active' AND licensingplus__Status__c != 'Expired']) {
                Set<String> states = existingLicenses.get(otherLicense.OwnerId);
                states.add(otherLicense.licensingplus__State__c);
                existingLicenses.put(otherLicense.OwnerId, states);
            }
        }
        
        for (licensingplus__License__c license : newList) {            
            //If there is already an existing license for the owner/state that is not Active/Expired, throw error
            if (existingLicenses.get(license.OwnerId).contains(license.licensingplus__State__c)) {
                license.addError('You have an existing ' + license.licensingplus__State__c + ' license that is not Active or Expired. Please update that license.');
            }
        }
        
        if (residentLicenses.size() > 0) {
        	//Get Active resident license for the owner
            for (licensingplus__License__c license : [SELECT Id, OwnerId FROM licensingplus__License__c WHERE RecordTypeId = :residentLicenseType AND licensingplus__Status__c = 'Active' AND OwnerId IN :residentLicenses.keySet()]) {
                residentLicenses.put(license.OwnerId, license.Id);
            }
            
            for (licensingplus__License__c license : newList) {
                if (license.RecordTypeId == nonResidentLicenseType) {
                    if (residentLicenses.get(license.OwnerId) != null) {
                    	//On insertion of Non-Resident license, set the Resident License lookup to the Active Resident license of this owner
                        license.Resident_License__c = residentLicenses.get(license.OwnerId);
                    } else {
                    	//On insertion of Non-Resident license, if there is no active Resident License, throw error
                        license.addError('You must have an active resident state license before creating a non-resident state license.');
                    }
                }
            }
        }
        
        
    }
    
    //No one should be able to delete Approved license 
    public static void preventLicenseDeletion(List<licensingplus__License__c> oldList) {
        for (licensingplus__License__c license : oldList) {
        	//If the license is already approved, no one should be able to delete the license
            if (license.licensingplus__Approved__c) {
                license.addError('You can not delete an approved license');
            }
        }
    }
    
    //After insert of Active License or update of license to Active, update the Resident License lookup for the Non-Resident licenses
    public static void setResidentLicense(List<licensingplus__License__c> newList, Map<Id, licensingplus__License__c> oldMap) {
    	Map<Id, Id> residentLicenses = new Map<Id, Id>();
    	
        for (licensingplus__License__c license : newList) {
        	//On update, get the licenses where Status is changed to Active
            if (oldMap != null && license.RecordTypeId == residentLicenseType && license.licensingplus__Status__c == 'Active' && license.licensingplus__Status__c != oldMap.get(license.Id).licensingplus__Status__c) {
                residentLicenses.put(license.OwnerId, license.Id);
            }
            
            //On insert, get the licenses where Status is Active
            if (oldMap == null && license.RecordTypeId == residentLicenseType && license.licensingplus__Status__c == 'Active') {
                residentLicenses.put(license.OwnerId, license.Id);
            }
        }
        
        if (residentLicenses.size() > 0) {
        	//Get all Non-Resident licenses for the owner
            List<licensingplus__License__c> nonResidentLicenses = [SELECT Id, OwnerId, licensingplus__Resident_License__c FROM licensingplus__License__c WHERE RecordTypeId = :nonResidentLicenseType AND OwnerId IN :residentLicenses.keySet()];
            
            //Set Resident License lookup for these Non-Resident licenses
            for (licensingplus__License__c license : nonResidentLicenses) {
                license.licensingplus__Resident_License__c = residentLicenses.get(license.OwnerId);
            }
            
            update nonResidentLicenses;
        }
        
    }
}