global with sharing class NIPRSyncApiResponse {
    
    global class LicenseSyncResponse {
        global String key;
        global Boolean isSuccess;
        global String errorMessage;
        global String errorCode;
        
        global LicenseSyncResponse() {
            isSuccess = false;
        }
    }
    
    public static LicenseSyncResponse getLicenseSyncResponse(String key, Boolean isSuccess, NIPRSyncError.SyncError errorCode, String errorMessage) {
        LicenseSyncResponse response = new LicenseSyncResponse();
        response.key = key;
        response.isSuccess = isSuccess;
        response.errorCode = (errorCode!=null) ? errorCode.name() : null;
        response.errorMessage = errorMessage;
        return response;
    } 
}