public with sharing class SObjectHelper {
    
    static map<string, Schema.SObjectField[]> cachedObjectsFields =  new map<string, Schema.SObjectField[]>();
    
    /**
     *  Returns a comma separated list of fields of the SObject with the given name, which can be used
     *  in SOQL queries.
     */ 
    public static String getFieldListForSOQL(string objectName) {
        return getFieldListForSOQL(objectName, null, null);
    }
  
    /**
     *  Returns a comma separated list of fields of the SObject with the given name, which can be used
     *  in SOQL queries. Fields defined in ignoreFields will be ignored. The given prefix is added to all fields.
     */ 
    public static String getFieldListForSOQL(string objectName, string prefix, set<string> ignoreFields) {
        
        Schema.SObjectField[] objFields = getObjectFields(objectName);
        
        String result = '';
        for (Schema.SObjectField f : objFields) {
            string fName = f.getDescribe().Name;
            if (ignoreFields == null || !ignoreFields.contains(fName)) {
                result += (prefix != null ? prefix : '') + fName + ',';
            }
        }
        
        // Remove last comma
        if (result.length() > 0) {
            result = result.substring(0, result.length() - 1);
        }
        
        return result;
    }
    
    /**
     *  Returns list of fields of the object with the given name.
     */
    public static Schema.SObjectField[] getObjectFields(string objectName) {
        if (cachedObjectsFields.containsKey(objectName)) {
            return cachedObjectsFields.get(objectName);
        } else {
            SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType == null) {
                return null;
            }
            
            Schema.SObjectField[] objFields = objType.getDescribe().fields.getMap().values();
            cachedObjectsFields.put(objectName, objFields);
            return objFields;
        }
    }
    
    // Girish P
    // Method to get the name of an sObject based on the prefix of an ID
    public static String getObjectNameFromId(Id objId) {
        String output=null;
        if (objId != null) {
            Schema.SObjectType sobjtype = objId.getSObjectType();
            if (sobjtype != null) {
                output = sobjtype.getDescribe().getName();
            }
        }
        return output;
    }
}