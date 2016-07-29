global with sharing class LogUtils {
    
    global static void logError(String clazz, String method, String error) {
    	log(loggingLevel.Error, clazz, method, error);
    }
    
    global static void logInfo(String clazz, String method, String info) {
    	log(loggingLevel.INFO, clazz, method, info);
    }
    
    private static void log(System.LoggingLevel loggingLevel, String clazz, String method, String message) {
    	System.debug(loggingLevel, String.format('[{0}] - {1} - {2}', new String[]{clazz, method, message}));
    }
}