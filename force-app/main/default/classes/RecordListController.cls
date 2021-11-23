public  without sharing class RecordListController {
    //@AuraEnabled
    //public static List<sObject> getRecords(String recordId, Integer initialRows) {
    //    List<sObject> ss = new List<sObject>();
    //    system.debug('recordId**' + recordId);
    //    List<sObject> sObjectList =
    //        [SELECT Id, ContactId, Role, Contact.Name, Contact.Email  FROM OpportunityContactRole where opportunityId = :recordId];
    //    //where opportunityId=:recordId
    //    //Add isAccessible() check
    //    ss.addAll(sObjectList);
    //    system.debug('sObjectList' + sObjectList);
    //    // ss.addAll(sObjectList);
    //    // ss.addAll(sObjectList);
    //    return ss;
    //}
    @AuraEnabled
    public static String getOpptyStatus(Id opptyId)
    {
     Opportunity oppty = [Select Id, Partner_Opportunity_Verification__c FROM Opportunity Where Id =: opptyId limit 1];   
       return oppty.Partner_Opportunity_Verification__c;
         //return oppty;
    }
    
    @AuraEnabled
    public static Map<String, Object> getColumnsAndData(String sObjectName,
            List<String> sObjectFieldsNames,
            String whereClause,
            String relationshipFields) {
        try {
            system.debug('mapRelationshipFields***' + relationshipFields);
            Map<String, String> mapRelationshipFields = (Map<String, String>)JSON.deserialize(relationshipFields, Map<String, String>.class);
            Map<String, Schema.SObjectField> m = Schema.describeSObjects(sObjectName.split(','))[0].fields.getMap();
            List<Object> columns = new List<Object>();
            system.debug('mmm***' + (sObjectName.split(','))[0]);
            String fieldType;
            system.debug('mapRelationshipFields***' + mapRelationshipFields);
            String fieldLabel;
            String fieldNameDisplay;
            Integer i = 0;
            String query = 'SELECT ' + String.escapeSingleQuotes(String.join( sObjectFieldsNames, ', ')) + ' FROM ' + String.escapeSingleQuotes(sObjectName);
            if (!String.isBlank(whereClause)) {
                query += ' WHERE ' + whereClause;
            }
            system.debug('query***' + query);
            List<SObject> records = Database.query( query );
            for ( String fieldName : sObjectFieldsNames) {
                system.debug('fieldName***' + fieldName);
                Schema.DescribeFieldResult dfr ;
                if (mapRelationshipFields.containsKey(fieldName)) {
                    fieldType = mapRelationshipFields.get(fieldName).split(',')[0];
                    fieldLabel = mapRelationshipFields.get(fieldName).split(',')[1];
                    fieldNameDisplay = mapRelationshipFields.get(fieldName).split(',')[2];
                    //sObjectFieldsNames = sObjectFieldsNames.remove(i);
                } else {
                    system.debug('else fieldName***' + fieldName);
                    dfr = m.get(fieldName).getDescribe();
                    fieldType = String.valueOf( dfr.getType()).toLowerCase();
                    fieldNameDisplay = String.valueOf( dfr.getName());
                    fieldLabel = String.valueOf( dfr.getLabel());
                }
                Map<String, Object> column = new Map<String, Object> {
                    'label' => fieldLabel,
                    'fieldName' => fieldNameDisplay,
                    'type' => fieldType,
                    'sortable' => true
                };
                //if(fieldType=='url'){
                //    column.put('typeAttribute','{label:'+fieldLabel+',target:/'+'}');
                //}
                columns.add(column);
                i++;
            }
            System.debug(records);
            return new Map<String, Object> {
                'columns' => columns,
                'data' => records
            };
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + '******');
            System.debug(e.getMessage() + '******');
            System.debug(e.getLineNumber() + '******');
            // throw AuraUtils.buildAuraHandledException(e);
            return null;
        }
        // return null;
    }
    //@AuraEnabled
    //public static String getIconName(String sObjectName) {
    //    String u;
    //    List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
    //    List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
    //    List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
    //    for (Schema.DescribeTabSetResult tsr : tabSetDesc) {
    //        tabDesc.addAll(tsr.getTabs());
    //    }
    //    for (Schema.DescribeTabResult tr : tabDesc) {
    //        if ( sObjectName == tr.getSobjectName() ) {
    //            if ( tr.isCustom() == true ) {
    //                iconDesc.addAll(tr.getIcons());
    //            } else {
    //                u = 'standard:' + sObjectName.toLowerCase();
    //            }
    //        }
    //    }
    //    for (Schema.DescribeIconResult ir : iconDesc) {
    //        if (ir.getContentType() == 'image/svg+xml') {
    //            u = 'custom:' + ir.getUrl().substringBetween('custom/', '.svg').substringBefore('_');
    //            break;
    //        }
    //    }
    //    return u;
    //}
}