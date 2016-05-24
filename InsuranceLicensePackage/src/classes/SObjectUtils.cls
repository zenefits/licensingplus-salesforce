global class SObjectUtils {
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
	
	global static Boolean isNumberType(Schema.DisplayType fieldType) {
		return INTEGER_TYPES.contains(fieldType) || DOUBLE_TYPES.contains(fieldType);
	}
	
	global static Boolean isReferenceType(Schema.DisplayType fieldType) {
		return ID_TYPES.contains(fieldType);
	}
		
	global static Boolean isStringType(Schema.DisplayType fieldType) {
		return STRING_TYPES.contains(fieldType);
	}
	
	global static Boolean isDateOrDatetimeOrNumberType(Schema.DisplayType fieldType) {
		return isDateType(fieldType) || isDatetimeType(fieldType) || isNumberType(fieldType);
	}
	
	global static Boolean isStringOrReferenceType(Schema.DisplayType fieldType) {
		return isStringType(fieldType) || isReferenceType(fieldType);
	}
}