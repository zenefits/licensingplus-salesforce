public with sharing class NIPRSyncError {
	
	public enum SyncError {
        NPN_NUMBER_NOT_FOUND,
        DML_ERROR,
        RESPONSE_NOT_FOUND,
        STATE_NOT_FOUND
    }  
    
    public static final Map<SyncError, String> errorMessageByType = new Map<SyncError, String>();
    
    static {
    	errorMessageByType.put(SyncError.NPN_NUMBER_NOT_FOUND, 'Not able to match owner with npn number');
    	errorMessageByType.put(SyncError.DML_ERROR, '{0}');
    	errorMessageByType.put(SyncError.RESPONSE_NOT_FOUND, 'Api response not found');
    	errorMessageByType.put(SyncError.STATE_NOT_FOUND, 'Not able to find license state');
    	
    }
}