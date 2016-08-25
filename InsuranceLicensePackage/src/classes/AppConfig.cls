public with sharing class AppConfig {

    public static String getAppNamespace() {
      //return 'licensingplus__';
      String prefix = getClassNamespace();
      if(prefix != ''){
          prefix = prefix.toLowerCase() + '__';
      }
      return prefix;
    }

    public static String getClassNamespace() {
      //return 'LicensingPlus';
      String prefix = ComplianceController.class.getName().substringBefore('ComplianceController');
      if(prefix != ''){
          prefix = prefix.substringBefore('.');
      }
      return  prefix;
    }
    
    public static String getAppNamespacedName(String name) {
      return getAppNamespace() + name;
    }
    
}