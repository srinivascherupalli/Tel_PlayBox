/************
 Created Date : 5th February 2021
 Created By : Team Hawaii (P2OB-11847)
 Description : getting data from list view
 P2OB-12547 : get Picklist value for Filter 
*************/

public with sharing class PRM_GenericListViewController {

    private static final String REFERENCE = 'REFERENCE';
    private static final String  PICKLIST = 'PICKLIST';
    
    //Wrapper class to return Data
    public class ResultWrapper {
        @AuraEnabled
        public Map<String,FieldDetails> fieldDetailsMap {get; set;}
        @AuraEnabled
        public List<SObject> recordList {get; set;}
        @AuraEnabled
        public String listViewLabel {get; set;}
    } 
    
    // wrapper for field details 
    public Class FieldDetails {
        @AuraEnabled 
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldLabel{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
        @AuraEnabled
        public String referenceToField{get;set;}
        @AuraEnabled
        public List<String> picklistValues {get;set;}
        
        public FieldDetails(String fieldName, String fieldLabel){
                this.fieldName = fieldName;
                this.fieldLabel = fieldLabel;
                this.picklistValues  = new List<String>();
        }
    }
    
    /* get list view query and data */
    @AuraEnabled
    public static ResultWrapper getListViewQuery(String listViewName, String sObjectName, String fieldsToShow){
        //Get List view Id
        Listview lv = [SELECT Id,SobjectType,Name FROM ListView WHERE DeveloperName =: listViewName 
                       AND SobjectType = :sObjectName];
        String listQuery='';
        List<String> fieldsToDisplay = new List<String>();
       // List<String> tempFields = new List<String>();
        ResultWrapper res = new ResultWrapper();
        if(fieldsToShow!= null){
            fieldsToDisplay = fieldsToShow.split(',');
        }
        
        listQuery =  getQueryFromListViewAPI(sObjectName,lv.Id);   
        if(!String.isBlank(listQuery)){
            //Get Data and return to frontend
            res.recordList = Database.query(listQuery);
           res.listViewLabel = lv.Name;
        }else{
            res.recordList  = new List<Sobject>();
        }
        // Get Field Details
        res.fieldDetailsMap = getFieldDetails(sobjectName, fieldsToDisplay);
        return res;
        
    }
    /* get Query from List View API */
    private static String getQueryFromListViewAPI(String sobjectName, String listViewId){
        String listQuery = '';
        try{
                HttpRequest req = new HttpRequest();
                //String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                String baseUrl = Label.Base_URL_for_Callouts;
                String endPoinURL = baseUrl+'/services/data/v50.0/sobjects/'+ sobjectName +'/listviews/'+ listViewId +'/describe';
                req.setEndpoint(endPoinURL);
                req.setMethod('GET');
                req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                Http http = new Http();
                if(!Test.isRunningTest()){
                    HttpResponse response = http.send(req);
                    if( response.getStatusCode() == 200 ) {
                        Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        listQuery = (String) tokenResponse.get('query');
                    }
                }else{
                    listQuery = 'SELECT Name, Account.Name, toLabel(StageName), CloseDate, Amount, Top_Priority__c, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, Account.Id, AccountId, Account.RecordTypeId FROM Opportunity USING SCOPE mine ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST';
                }   
        }catch(Exception e){
            system.debug(e);
        }
        return listQuery;
    }
    
    /* get Field Details from Object */
    public static Map<String, FieldDetails> getFieldDetails(String sobjectName, List<String> fieldsToDisplay){
        //Get Map of Labels and API Names
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        Map<String, FieldDetails> fieldDetailsMap = new Map<String, FieldDetails>();
        for(String fieldName : fieldsToDisplay){
            if(fieldMap.containsKey(fieldName)){
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
                FieldDetails fd = new FieldDetails(fieldResult.getName(), fieldResult.getLabel());
                fd.fieldType = fieldResult.getType().name();
                System.debug(': fd.fieldType'+ fd.fieldType);
                // get Reference field details
                if(fd.fieldType == REFERENCE){
                    Schema.SObjectType parentObj = fieldMap.get(fieldName).getDescribe().getReferenceTo().get(0);
                    fd.referenceToField = parentObj.getDescribe().getName();
                 //P2OB-12547 - get picklist Values 
                }else if(fd.fieldType != NULL && fd.fieldType.contains(PICKLIST)){
                    
                    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
                    System.debug(': picklistValues '+ picklistValues);
                    for(Schema.PicklistEntry pe : picklistValues){
                        fd.picklistValues.add(pe.getValue());
                    }
                }
                fieldDetailsMap.put(fieldName,fd);
            }
        }
        return fieldDetailsMap;
    }   
}