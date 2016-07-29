@RestResource(urlMapping='/nipr/sync/license')
global with sharing class NIPRLicenseSyncApi {
 
    @HttpPost
    global static List<NIPRSyncApiResponse.LicenseSyncResponse> syncNIPRLicenses() {
    	RestRequest req = RestContext.request;
    	List<NIPRLicense> niprLicenses = (List<NIPRLicense>)JSON.deserialize(req.requestBody.toString(), List<NIPRLicense>.class);
		
		for (NIPRLicense niprLicense : niprLicenses) {
			LogUtils.logInfo('NIPRLicenseSyncApi', 'syncNIPRLicenses', 'deserialized post nipr license '+ niprLicense);
		}
        
        NIPRSyncService syncService = new NIPRSyncService();
        List<NIPRSyncApiResponse.LicenseSyncResponse> responses = syncService.syncLicenses(niprLicenses);
        return responses;
    }

}