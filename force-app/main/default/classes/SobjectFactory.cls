/*************************************************************************************************
Name : sobjectFactory 
Description :  Generic class to insert any object using unit of work taking record/records of particular object type
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             28-Oct-2020   EDGE-182452(new)
===============================================================================================================================
***************************************************************************************************/
public with sharing class SobjectFactory {

    //Generic methis to insert any object using unit of work 
    //param: record (any object)
    @AuraEnabled(cacheable=false)
    public static String  insertSobject (Sobject record){
        String objectId='';
        try{
            Schema.SObjectType sObjectType = record.getSObjectType();
            if (sObjectType != null && record!=null){ //objecttype and record should not be null 
            	List<Schema.SObjectType> sObjectTypeList = new  List<Schema.SObjectType>{sObjectType};
            	SObjectUnitOfWork UoW = new SObjectUnitOfWork(sObjectTypeList); // unit of work and passing object type
                String objectname=''+sObjectType;
                SObject castRecord = (SObject)Type.forName(objectname).newInstance(); //type casting object type before inserting
                 castRecord=record;
                 if(castRecord!=null){
                    UoW.registerNew(castRecord); //insert record
                    UoW.commitWork();
                    objectId=castRecord.id;
                 }
            }
        }catch(Exception e){
            system.debug('insertSobject'+e.getMessage());
            throw new AuraHandledException('Error while insertSobject: '+ e.getMessage());
        }
       	return objectId;
    }

    //Generic methis to insert list of object using unit of work 
    //param: record (any list of sobject)
    @AuraEnabled(cacheable=false)

    public static String insertSobjectList (List<Sobject> records){
        Schema.SObjectType sObjectType = records.getSObjectType();
        if (records!=null && records.size()>0 && sObjectType != null)
        {
            String listType = 'List<' + sObjectType + '>';
            List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
            castRecords.addAll(records);
        	List<Schema.SObjectType> sObjectTypeList = new  List<Schema.SObjectType>{sObjectType};
			SObjectUnitOfWork UoW = new SObjectUnitOfWork(sObjectTypeList);
			if(castRecords!=null){
                UoW.registerNew(castRecords);
                UoW.commitWork();
                return 'Success';
             }else{
            	return 'Error';
        	}
        }else{
           return 'Error';
        }

    }

}