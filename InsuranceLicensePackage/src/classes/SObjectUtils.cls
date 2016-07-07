global with sharing class SObjectUtils {
	
	global enum FIELD_TYPE {
		STRING_FIELD,
		INTEGER_FIELD,
		DOUBLE_FIELD,
		DATETIME_FIELD,
		DATE_FIELD,
		BOOLEAN_FIELD,
		ID_FIELD,
		UNKNOWN_FIELD
	}
	
	global static FIELD_TYPE getFieldType (Schema.DisplayType fieldType) {
		if (isStringType(fieldType)) {
			return FIELD_TYPE.STRING_FIELD;
		} else if (isIntegerType(fieldType)) {
			return FIELD_TYPE.INTEGER_FIELD;
		} else if (isDoubleType(fieldType)) {
			return FIELD_TYPE.DOUBLE_FIELD;
		} else if (isDatetimeType(fieldType)) {
			return FIELD_TYPE.DATETIME_FIELD;
		} else if (isDateType(fieldType)) {
			return FIELD_TYPE.DATE_FIELD;
		} else if (isBooleanType(fieldType)) {
			return FIELD_TYPE.BOOLEAN_FIELD;
		} else if (isReferenceType(fieldType)) {
			return FIELD_TYPE.ID_FIELD;
		}
		
		return FIELD_TYPE.UNKNOWN_FIELD;
	}
	
	private static final Set<String> excludedAppObjects = new Set<String>{
		'license__c',
		'line_of_authority__c',
		'license_rule__c',
		'license_rule_logic__c'
	};
	
    private static final Set<Schema.DisplayType> STRING_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.base64
        ,Schema.DisplayType.Email
        ,Schema.DisplayType.MultiPicklist
        ,Schema.DisplayType.Phone
        ,Schema.DisplayType.Picklist
        ,Schema.DisplayType.String
        ,Schema.DisplayType.TextArea
        ,Schema.DisplayType.URL
        ,Schema.DisplayType.EncryptedString
    };

    private static final Set<Schema.DisplayType> INTEGER_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.Integer
    };

    private static final Set<Schema.DisplayType> DOUBLE_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.Currency
        ,Schema.DisplayType.Double
        ,Schema.DisplayType.Percent
    };

    private static final Set<Schema.DisplayType> DATETIME_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.DateTime
    };

    private static final Set<Schema.DisplayType> DATE_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.Date
    };

    private static final Set<Schema.DisplayType> BOOLEAN_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.Boolean
        ,Schema.DisplayType.Combobox
    };
    
    private static final Set<Schema.DisplayType> ID_TYPES = new Set<Schema.DisplayType> {
    	Schema.DisplayType.ID
        ,Schema.DisplayType.Reference
    };
    
    global static SObject getSObject(String objName) {
	    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
	    return targetType==null ? null : targetType.newSObject();
	}
	
	global static Map<String, Schema.SobjectField> getSObjectFields(SObject obj) {
		Map<String, Schema.SobjectField> objFieldsByName = new Map<String, Schema.SobjectField>();
		if (obj != null) {
			objFieldsByName = obj.getSobjectType().getDescribe().fields.getMap();
		}
		
		return objFieldsByName;
	}
	
	global static List<String> getSObjectFieldReferenceNames(Schema.SObjectField field) {
		List<String> referenceNames = new List<String>();
		if (field != null) {
			Schema.DescribeFieldResult f = field.getDescribe();					
			for(Schema.SObjectType reference : f.getReferenceTo()) {
	    		referenceNames.add(reference.getDescribe().getName());
			}
		}

		return referenceNames;
	} 
	
	global static String getSObjectFieldRelationshipName(Schema.SObjectField field) {
		String name = '';		
		if (field != null) {
			Schema.DescribeFieldResult f = field.getDescribe();		
			name = f.getRelationshipName();
		}
				
		return name;
	}
	
	global static Boolean isBooleanType(Schema.DisplayType fieldType) {
		return BOOLEAN_TYPES.contains(fieldType);
	}
	
	global static Boolean isDateType(Schema.DisplayType fieldType) {
		return DATE_TYPES.contains(fieldType);
	}
	
	global static Boolean isDatetimeType(Schema.DisplayType fieldType) {
		return DATETIME_TYPES.contains(fieldType);
	}
	
	global static Boolean isIntegerType(Schema.DisplayType fieldType) {
		return INTEGER_TYPES.contains(fieldType);
	}
	
	global static Boolean isDoubleType(Schema.DisplayType fieldType) {
		return DOUBLE_TYPES.contains(fieldType);
	}
	
	global static Boolean isNumberType(Schema.DisplayType fieldType) {
		return isIntegerType(fieldType) || isDoubleType(fieldType);
	}
	
	global static Boolean isReferenceType(Schema.DisplayType fieldType) {
		return ID_TYPES.contains(fieldType);
	}
		
	global static Boolean isStringType(Schema.DisplayType fieldType) {
		return STRING_TYPES.contains(fieldType);
	}
	
	global static Boolean isStringOrReferenceType(Schema.DisplayType fieldType) {
		return isStringType(fieldType) || isReferenceType(fieldType);
	}
	
	global static Set<String> getAllSObjectNames() {
		Set<String> objNames = new Set<String>();
		for (Schema.SObjectType o : Schema.getGlobalDescribe().values()) {
    		Schema.DescribeSObjectResult objResult = o.getDescribe();
			// exclude package objects itself, exclude custom settings, 
			// exclude standard share objects, exclude custom share objects
			// only keep objects createable, updateable and deleteable
			if (!excludedAppObjects.contains(objResult.getName().toLowerCase()) && 
				!objResult.isCustomSetting() &&
				(objResult.isUpdateable() && objResult.isDeletable() && objResult.isCreateable())) {
				
				// make sure there is ownerid or ownerid__c field on this object
				Map<String, Schema.SobjectField> objFields = objResult.fields.getMap();
				if (objFields.get('OwnerId')!=null || objFields.get('OwnerId__c')!=null) {
					if (!objResult.isCustom()) {
						if (!objResult.getName().toLowerCase().endsWith('share')) {
							objNames.add(objResult.getName());	
						}
					} else {
						if (!objResult.getName().toLowerCase().endsWith('__share')) {
							objNames.add(objResult.getName());
						}					
					}		
				} 	
			} 
		}
		
		return objNames;
	}
}