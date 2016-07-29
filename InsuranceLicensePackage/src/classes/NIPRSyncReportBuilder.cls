public with sharing class NIPRSyncReportBuilder {
    
    private String infoReport = '';
    private String errorReport = '';
    
    public NIPRSyncReportBuilder() {}
    
    public void logErrorReport(String clazz, String method, String message) {
    	this.errorReport += String.format('[{0}] - {1} - {2}\n\n', new String[]{clazz, method, message});
    }
    
    public void logInfoReport(String clazz, String method, String message) {
    	this.infoReport += String.format('[{0}] - {1} - {2}\n\n', new String[]{clazz, method, message});
    }
    
    public String getErrorReport() {
    	return this.errorReport;
    }
    
    public String getInfoReport() {
    	return this.infoReport;
    }
}