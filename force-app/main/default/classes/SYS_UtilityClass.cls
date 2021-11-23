public without sharing class SYS_UtilityClass {
    /* method that returns fields that have changed within a list of
    records. 
    *Typically invoked from a trigger context
    * @param oldValues : a map of record ids & old field values
    * @param newValues : a map of record ids & new field values
    * @param fieldsToCheck : A list fo fields for which we need to
    check for changes
    * Return Value : A Map<Id, Set<String>> - contains record Ids &
    the set of fields that have changed
    */
        public static Map<Id,Set<String>> getChangedFields(Map<Id,SObject> oldValues,Map<Id,SObject> newValues, list<String> fieldsToCheck){
            
            Set<Id> recordIds = newValues.keySet();
            Map<Id,Set<String>> recordChangesMap = new Map<Id,
                Set<String>>();
            for(Id recId : recordIds){
                Set<String> changedFields = new Set<String>();
                SObject o1 = oldValues.get(recId);
                SObject o2 = newValues.get(recId);
                
                for (String field : fieldsToCheck) {
                    Object v1 = o1.get(field);
                    Object v2 = o2.get(field);
                    if (didFieldChange(v1, v2)) {
                        changedFields.add(field);
                    }
                }
                recordChangesMap.put(recId,changedFields);
            }
            
            return recordChangesMap;
        }
        
        public static Map<Id,Map<String,String>> getOldValuesMap(Map<Id,SObject> oldValues, list<String> fieldsToCheck){
            Set<Id> recordIds = oldValues.keySet();
            Map<Id,Map<String,String>> oldFieldValuesMap = new Map<Id,Map<String,String>>();
            for(Id recId : recordIds){
                Map<String, String> oldFldVal= new Map<String, String>();
                
                SObject oldValRec = oldValues.get(recId);
                for (String field : fieldsToCheck) {
                    String fldVal = (oldValRec.get(field) == null)?'':(string)oldValRec.get(field);
                    oldFldVal.put(field, fldVal);
                }
                oldFieldValuesMap.put(recId,oldFldVal);
            }
            return oldFieldValuesMap;
        }
        
        @TestVisible
        private static Boolean didFieldChange(Object v1, Object v2) {
            if (v1 == null && v2 == null) {
                return false;
            }
            if (v1 != v2) {
                return true;
            }
            return false;
        }

        /**
         * Author:- Nitin Kumar  14/Oct/2021
         * Description:- Retrieve display messages from custom setting - created for DIGI-21110, can be reused
        */
        public static String retrieveDisplayMessage(String msgName){
            SharedDisplayMessage__c displayMsg = SharedDisplayMessage__c.getInstance(msgName);
            if(displayMsg != null)
                return displayMsg.Value__c;
            else    
                return '';    
        }
    
    }