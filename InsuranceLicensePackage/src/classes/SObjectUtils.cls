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
		return obj==null ? null : obj.getSobjectType().getDescribe().fields.getMap();
	}
	
	global static List<String> getSObjectFieldReferenceNames(Schema.SObjectField field) {
		Schema.DescribeFieldResult f = field.getDescribe();
		List<String> referenceNames = new List<String>();
		for(Schema.SObjectType reference : f.getReferenceTo()) {
    		referenceNames.add(reference.getDescribe().getName());
		}
		return referenceNames;
	} 
	
	global static String getSObjectFieldRelationshipName(Schema.SObjectField field) {
		Schema.DescribeFieldResult f = field.getDescribe();		
		return f.getRelationshipName();
	}
	
	global static Boolean isStringType(Schema.DisplayType fieldType) {
		return STRING_TYPES.contains(fieldType);
	}
	
	global static Boolean isStringOrReferenceType(Schema.DisplayType fieldType) {
		return STRING_TYPES.contains(fieldType) || ID_TYPES.contains(fieldType);
	}
}