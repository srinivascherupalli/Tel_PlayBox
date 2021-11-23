/*************************************************************************************************************
 * @name			Coms_BulkSiteUploadUtils
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			06 / 09 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-06		BLR\rohit.pal			Changes desription
 *              2.0     2021-09-22      Ajith Kumar             Changed insert method type
 *              3.0     07/Oct/2021     Omkar Jante             DIGI-28081 : Updated logic for soft delete
 *              4.0     08/Nov/2021     Nitin Kumar             DIGI-28079 :- added final variable
**************************************************************************************************************/
public with sharing class Coms_BulkSiteUploadUtils {

    //DIGI-28079
    public static final String IS_DELETE_FALSE = 'FALSE';           
    public static final String PROCESS_NAME = 'Bulk_Site_Upload';   
    public static final String STATUS_NEW = 'New';                  
    public static final String STATUS_COMPLETED = 'Completed';          
    public static final String STATUS_ABORTED = 'Aborted';          
    public static final String STATUS_FOUND = 'Match Found';        
    public static final String STATUS_NOT_FOUND = 'Not Found';          
    public static final String STATUS_FAILED = 'Failed';             
    public static final String STR_FALSE='false';                   
    public static final String STR_TRUE='true';      
    public static final Integer Batch_Size = 45; 
    public static string insertedLogger;  
    public static DateTime submittedTime;           
    //DIGI-28079    

    private Coms_BulkSiteUploadUtils(){

    }

    public static String insertOrchestrationTechnicals(Map<String,Map<String,String>>  siteDataMap){
        Map<String,String> siteDataWrapperMap=new Map<String,String>();
        List<Map<String,String>> siteDataWrapperList=siteDataMap.values();
        Map<string , TechnicalObjectFieldMapping__mdt> mapTechnicalObjectFieldMapping = mdtGetTechnicalObjectFieldMapping();
        List<Orchestration_Technical__c> lstToInsert = new List<Orchestration_Technical__c>();
        string strIsInserted;
        try{
            for(Integer i=0;i<siteDataWrapperList.size();i++){
                Orchestration_Technical__c objOrchTech = new Orchestration_Technical__c();
                siteDataWrapperMap=siteDataWrapperList.get(i);
                objOrchTech.put(mapTechnicalObjectFieldMapping.get('accountId').Object_Field_Name__c,siteDataWrapperMap.get('accountId'));
                objOrchTech.put(mapTechnicalObjectFieldMapping.get('adborId').Object_Field_Name__c,siteDataWrapperMap.get('adborId'));
                objOrchTech.put(mapTechnicalObjectFieldMapping.get('address').Object_Field_Name__c,siteDataWrapperMap.get('address'));
                objOrchTech.put(mapTechnicalObjectFieldMapping.get('status').Object_Field_Name__c,siteDataWrapperMap.get('status'));
                objOrchTech.put(mapTechnicalObjectFieldMapping.get('siteName').Object_Field_Name__c,siteDataWrapperMap.get('siteName'));
                objOrchTech.put(mapTechnicalObjectFieldMapping.get('isDelete').Object_Field_Name__c,siteDataWrapperMap.get('isDelete'));
                objOrchTech.CorrelationId__c=GuidUtil.NewGuid();
                objOrchTech.Process_Name__c=PROCESS_NAME;
                lstToInsert.add(objOrchTech);       
            }
            if(!lstToInsert.isEmpty()){
                insert lstToInsert; 
                strIsInserted='Success';
            } 
        }
        catch(Exception ex){
            strIsInserted=ex.getMessage();            
        }      
        return strIsInserted;  
    }

    /**
    * @description 
    * @author Rohit Pal | 09-06-2021 
    * @param objOrchestrationTechnical 
    * @return string 
    **/
    public static string updateOrchestrationTechnicals(List<Orchestration_Technical__c> objOrchestrationTechnical){
        string strIsUpdated;
        try{
            update objOrchestrationTechnical;
            strIsUpdated='Success';
        }catch(Exception e){
            strIsUpdated = e.getMessage();
        }
        return strIsUpdated;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-06-2021 
    * @param strCorrelationId 
    * @param idAccount 
    * @param deleteAll 
    * @return string 
    **/
    public static string deleteOrchestrationTechnicals(string strCorrelationId , Id idAccount){
        string strIsDeleted;
        try {
            List<Orchestration_Technical__c> listOrchestrationTechnical = new List<Orchestration_Technical__c>();
            if(string.isNotBlank(strCorrelationId)){
                listOrchestrationTechnical.add(getCorrelationIds(strCorrelationId));
            }else if(idAccount != null){
                listOrchestrationTechnical.addAll(getAllOrchestrationTechnicalRecords(idAccount,null,null,0,null));
            }
            if(listOrchestrationTechnical != null && !listOrchestrationTechnical.isEmpty()){
                // Soft delete code instead of hard delete
                //delete listOrchestrationTechnical;
                for (Orchestration_Technical__c objTechOrcRec : listOrchestrationTechnical) {
                    objTechOrcRec.Field_7__c = 'TRUE';
                }
                update listOrchestrationTechnical;
                strIsDeleted= 'Success';
            }
            else{
                strIsDeleted= 'No Records';
            }
        } catch (Exception e) {
            strIsDeleted = e.getMessage();
        }
        return strIsDeleted;
    }


    /**
    * @description 
    * @author Rohit Pal | 09-06-2021 
    * @param strExternalId 
    * @return List<Orchestration_Technical__c> 
    **/
    public static List<Orchestration_Technical__c> getAllOrchestrationTechnicalRecords(string accountId,List<String> status,List<String> corelationId,Integer queryLimit,Integer offsetValue){
        List<Orchestration_Technical__c> listOrchestrationTechnical = new List<Orchestration_Technical__c>();
        SObjectType sobType =  Orchestration_Technical__c.SObjectType;
        List<string> fields = mdtGetDynamicQueryFields('Orchestration_Technical__c');
        // String processName = 'Bulk_Site_Upload'; //DIGI-28079
        // String isDelete = 'FALSE'; //DIGI-28079
        String queryCondition = ' WHERE Process_Name__c =:PROCESS_NAME AND Field_7__c =: IS_DELETE_FALSE';
        queryCondition = queryCondition + ((String.isNotBlank(accountId))?' AND External_Id_1__c =: accountId': '');
        queryCondition = queryCondition + ((status == null || status.isEmpty())?'':' AND Field_3__c in: status');
        queryCondition = queryCondition + ((corelationId == null || corelationId.isEmpty())? ' ':' AND CorrelationId__c in: corelationId');
        queryCondition = queryCondition + ' ORDER BY CreatedDate';
        queryCondition = queryCondition + ((queryLimit >0)? ' LIMIT '+ queryLimit :'');
        queryCondition = queryCondition + ((offsetValue != null )? ' OFFSET '+ offsetValue :'');
        string query=' SELECT ' + String.escapeSingleQuotes(String.join(fields, ',')) + ' FROM ' + sobType + String.escapeSingleQuotes(queryCondition);
        listOrchestrationTechnical = Database.query(query);
        return listOrchestrationTechnical;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-06-2021 
    * @param strCorrelationId 
    * @return List<Orchestration_Technical__c> 
    **/
    public static Orchestration_Technical__c getCorrelationIds(string strCorrelationId){
        Orchestration_Technical__c objOrchestrationTechnical = new Orchestration_Technical__c();
        SObjectType sobType =  Orchestration_Technical__c.SObjectType;
        List<string> fields = mdtGetDynamicQueryFields('Orchestration_Technical__c');
        String query=' SELECT '+ String.escapeSingleQuotes(String.join(fields, ',')) + ' FROM ' + sobType + ' WHERE  CorrelationId__c =:strCorrelationId LIMIT 1';
        objOrchestrationTechnical = Database.query(query);
        return objOrchestrationTechnical;
    }

    
    /**
    * @description 
    * @author Rohit Pal | 09-06-2021 
    * @return Map<string, TechnicalObjectFieldMapping__mdt> 
    **/
    public static Map<string , TechnicalObjectFieldMapping__mdt> mdtGetTechnicalObjectFieldMapping(){
        Map<string , TechnicalObjectFieldMapping__mdt> mapTechnicalObjectFieldMapping = new Map<string , TechnicalObjectFieldMapping__mdt>();
        for(TechnicalObjectFieldMapping__mdt iterator : [SELECT MasterLabel,
                                                                Object_Field_Name__c,
                                                                Object_Name__c,
                                                                Category__c FROM TechnicalObjectFieldMapping__mdt WHERE Process__c = 'Bulk Site Upload']){
            mapTechnicalObjectFieldMapping.put(iterator.MasterLabel , iterator);
        }
        return mapTechnicalObjectFieldMapping;
    }
    
    /**
    * @description 
    * @author Rohit Pal | 09-08-2021 
    * @param objectName 
    * @return List<string> 
    **/
    public static List<string> mdtGetDynamicQueryFields(string objectName){
        List<string> listFields;
        for(ConstantMetadataUtility__mdt iterator : [SELECT MasterLabel,
                                                            QueryFieldNames__c 
                                                    FROM ConstantMetadataUtility__mdt 
                                                    WHERE MasterLabel =: objectName]){
            listFields = new List<string>(string.valueof(iterator.QueryFieldNames__c).Split(', '));
        }
        return listFields;
    }

/**
*   
* @author Ajith Kumar | 08-10-2021 
* @description  This method to be used for Aggregate query results
* @return List<AggregateResult> 
**/
    public static List<AggregateResult> getCountQueryResult(string accountId,List<String> status,string groupByField){
        List<AggregateResult> aggregateQueryResult = new List<AggregateResult>();
        SObjectType sobType =  Orchestration_Technical__c.SObjectType;        
        List<string> fields = mdtGetDynamicQueryFields('Orchestration_Technical__c');
        // String processName = 'Bulk_Site_Upload'; //DIGI-28079
        // String isDelete = 'FALSE'; //DIGI-28079  
        String queryCondition = ' WHERE Process_Name__c =:PROCESS_NAME AND Field_7__c =: IS_DELETE_FALSE';
        queryCondition = queryCondition + ((String.isNotBlank(accountId))?' AND External_Id_1__c =: accountId': '');
        queryCondition = queryCondition + ((status == null || status.isEmpty())?'':' AND Field_3__c in: status');
        queryCondition = queryCondition + ((String.isNotBlank(groupByField))?' GROUP BY '+ groupByField : '');
        String queryFields=((String.isNotBlank(groupByField))? ','+groupByField: '');
        string query=' SELECT Count(Id)cnt' +String.escapeSingleQuotes(queryFields) + ' FROM ' + sobType + String.escapeSingleQuotes(queryCondition);
        aggregateQueryResult = Database.query(query);
        return aggregateQueryResult;
    }
}