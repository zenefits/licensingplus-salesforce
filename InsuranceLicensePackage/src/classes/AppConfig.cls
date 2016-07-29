public with sharing class AppConfig {

    public static String getAppNamespace() {
    	return 'licensingplus__';
    }
    
    public static String getAppNamespacedName(String name) {
    	return getAppNamespace() + name;
    }
    
}