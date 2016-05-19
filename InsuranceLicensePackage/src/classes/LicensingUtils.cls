public class LicensingUtils {
	
	public static final LicenseRuleHelper ruleHelper = new LicenseRuleHelper();
	public static final LicenseRuleChecker ruleChecker = new LicenseRuleChecker(ruleHelper);
	
    public static Map<String, String> stateMap = new Map<String, String>{
        'AK' => 'Alaska', 'AL' => 'Alabama', 'AR' => 'Arkansas', 'AZ' => 'Arizona', 'CA' => 'California', 'CO' => 'Colorado',
        'CT' => 'Connecticut', 'DC' => 'District of Columbia', 'DE' => 'Delaware', 'FL' => 'Florida',
        'GA' => 'Georgia', 'GU' => 'Guam', 'HI' => 'Hawaii', 'IA' => 'Iowa', 'ID' => 'Idaho', 'IL' => 'Illinois',
        'IN' => 'Indiana', 'KS' => 'Kansas', 'KY' => 'Kentucky', 'LA' => 'Louisiana', 'MA' => 'Massachusetts',
        'MD' => 'Maryland', 'ME' => 'Maine', 'MI' => 'Michigan', 'MN' => 'Minnesota', 'MO' => 'Missouri',
        'MS' => 'Mississippi', 'MT' => 'Montana', 'NC' => 'North Carolina', 'ND' => 'North Dakota',
        'NE' => 'Nebraska', 'NH' => 'New Hampshire', 'NJ' => 'New Jersey', 'NM' => 'New Mexico',
        'NV' => 'Nevada', 'NY' => 'New York', 'OH' => 'Ohio', 'OK' => 'Oklahoma', 'OR' => 'Oregon',
        'PA' => 'Pennsylvania', 'PR' => 'Puerto Rico', 'RI' => 'Rhode Island', 'SC' => 'South Carolina',
        'SD' => 'South Dakota', 'TN' => 'Tennessee', 'TX' => 'Texas', 'UNK' => 'Unknown', 'UT' => 'Utah',
        'VA' => 'Virginia', 'VI' => 'US Virgin Islands', 'VT' => 'Vermont', 'WA' => 'Washington',
        'WI' => 'Wisconsin', 'WV' => 'West Virginia', 'WY' => 'Wyoming'
    };
    
    public static void checkSObjectLicenseRules(List<SObject> newObjs, String objName) {
    	// check sObject custom rules
    	Map<String, SObject> objById = new Map<String, SObject>();
    	for (SObject obj : newObjs) {
    		objById.put(obj.id, obj);
    	}
    	
    	System.debug('DEBUG - ');
    	System.debug(objById);
    	List<SObject> filteredObjs = ruleChecker.checkCustomLicenseRules(objById, objName);
    	
    	// check sObject standard rules
    	ruleChecker.checkStandardLicenseRules(filteredObjs, objName);
    }

}