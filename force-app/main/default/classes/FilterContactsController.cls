/*******************************************************************
@Class Name:FilterContactsController
@Description:Sprint 20.03 , P2OB-4620 ,SFO 20.06 :P2OB-5883 ,SFO 20.07 :P2OB-6382,Sprint 20.09 : P2OB-6724
@Author:SFO Team (Sravanthi)
@Comments:To Fetch all the Contacts with given account based on input selection into lightning component FilterContacts.
            And Update contacts passed during inline edit.
            Fetching if user has create access on contact object
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
                        SFO 21.04 :P2OB-12577 :Telstra Connect Status Selections
============================================================================
ChangeSet   No    Name            Date                    Description
EDGE-151592 1     Purushottam     14-07-2020              View related list in PRM to the authorised Partners
*********************************************************************/
public with sharing class FilterContactsController {
    
    private static List<String> lstFieldsToQuery = new List<String>();
    /*
    @Method Name:fetchContacts
    @Description:* Sprint 20.03 , P2OB-4620 ,To Fetch all related Contacts for the given account Id 
                    based on the filter selection fon Active / End Dated contacts.
                * Sprint 20.07 :P2OB-6382,I should see all of the related contacts on my account and not just the PRIMARY account contact.
                * Sprint 20.09 : P2OB-6724 , Updated the query filter from relation ship end date to contact status field.
                * SFO 21.04 :P2OB-12577 :Telstra Connect Status Selection Queries added
    @Author:SFO Team (Sravanthi)
    */
    
    private static DataAndColumns fetchContacts(Id recordId, String filter, Boolean viewAll,DataAndColumns response) {
        try{
            String selectedID = string.escapeSingleQuotes(recordId);
            String contactStatusActive = System.Label.Contact_Active_Status;
            String telstraConnectStatusRegisteredActive = System.Label.Telstra_Connect_Status_Registered_Active;
            String telstraConnectStatusRegisteredNotActive = System.Label.Telstra_Connect_Status_Registered_Not_Active;
            
            Set<Id> contactIdList = new Set<Id>();

            for(AccountContactRelation acrRec : [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: selectedID]){
                contactIdList.add(acrRec.ContactId);
            }
            String query = 'SELECT '+ String.escapeSingleQuotes(String.join(lstFieldsToQuery, ',')) +' from Contact where ';
            
            String criteria;             
            
            if(filter == 'Active' || filter == Null){
                criteria = 'Id IN :contactIdList AND Contact_Status__c = :contactStatusActive ' ;   
            }else if(filter == 'InActive'){
                criteria = 'Id IN :contactIdList AND Contact_Status__c != :contactStatusActive ' ;	    
            }else if(filter == 'All'){
                criteria = 'Id IN :contactIdList ';
            }else if(filter == 'RegisteredActive'){
                criteria = 'Id IN :contactIdList AND Telstra_Connect_Status__c = :telstraConnectStatusRegisteredActive ';
            }else if(filter == 'RegisteredNotActive'){
                criteria = 'Id IN :contactIdList AND Telstra_Connect_Status__c = :telstraConnectStatusRegisteredNotActive ';
            }else if(filter == 'NotRegistered'){
                criteria = 'Id IN :contactIdList AND Telstra_Connect_Status__c != :telstraConnectStatusRegisteredNotActive AND Telstra_Connect_Status__c != :telstraConnectStatusRegisteredActive ';
            }
            
            if(viewAll){
                criteria += 'LIMIT 5';  
            }
            
            String queryString = query + criteria;
            
            List<Contact> contactList = Database.query(queryString);
            
            response.lstTableData = contactList;
            
        }
        catch(QueryException e){
            System.debug('FilterContactsController Class --- fetchContacts Method --- QueryException' + e);
        }
        return response;
    }
    /*
    @Method Name: updateContacts
    @Description:Sprint 20.03 , P2OB-4620 ,To update the contacts edited via inline editing in Related contact datatable 
                 and return appropriate errors.
    @Author:SFO Team (Sravanthi)
    */
    @AuraEnabled
    public static void updateContacts(List<Contact> contactList ){
        try{
            if(contactList != null && !contactList.isEmpty()){
                update contactList;
            }
        }
        catch(DMLException e){
            List<CustomExceptionData> errorList = new List<CustomExceptionData> ();
           
            for(integer i=0; i < e.getNumDml(); i++){
                errorList.add(new CustomExceptionData(e.getDmlStatusCode(i), e.getDmlMessage(i), e.getDmlId(i)));
            }
            System.debug('FilterContactsController Class--- updateContacts Method --- DMLException' + e);
            throw new AuraHandledException(JSON.serialize(errorList));

        }
    }
    /*
    @Method Name: getDataTableColumns
    @Description:Sprint 20.03 , P2OB-4620 ,To get dynamic columns from contact field set for the related contact list 
                 and relavant feasible column properties based on thier data types.
                 SFO 20.06 : P2OB-5883 Added Create contact access to enable/disable new button
    @Author:SFO Team (Sravanthi)
    */
    
    private static DataAndColumns getDataTableColumns(){

        DataAndColumns response = new DataAndColumns();
        List<ColumnProperties> lstofColumns = new List<ColumnProperties>();
        Schema.FieldSet fs1 = Schema.SObjectType.Contact.fieldSets.getMap().get(System.Label.Contact_Field_Set);
        Boolean isPartner = FeatureManagement.checkPermission('Partner_User');
        for(FieldSetMember fieldSetMem :fs1.getFields()){
            String dataType = String.valueOf(fieldSetMem.getType()).toLowerCase();
            Boolean editable = true;
            Boolean sortable = false;
            editable = !(dataType == 'Picklist' || dataType =='MultiselectPicklist'); 
            if(isPartner)
            {
                 editable = false;
            }
            dataType = getDataType(dataType);
            sortable = (dataType == 'Checkbox' || dataType == 'Text' || dataType == 'Boolean'|| dataType == 'String' || dataType == 'picklist' || dataType =='MultiselectPicklist');//getSortable(dataType);
            
            if(fieldSetMem.getLabel() != 'Full Name' || fieldSetMem.getFieldPath() != 'Name'){
                lstofColumns.add(new ColumnProperties(String.valueOf(fieldSetMem.getLabel()),
                                                    String.valueOf(fieldSetMem.getFieldPath()),
                                                    dataType,editable,sortable));
                lstFieldsToQuery.add(String.valueOf(fieldSetMem.getFieldPath()));
            }
        }
        
        lstFieldsToQuery.add('Name');
        lstFieldsToQuery.add('id');
        if(!lstFieldsToQuery.contains('AccountId')){
            lstFieldsToQuery.add('AccountId');
        }
        lstFieldsToQuery.add('Account.Name');
        lstFieldsToQuery.add('Contact_Status__c');
        if(!lstofColumns.isEmpty()){
            response.ColumnProperties =lstofColumns;
            response.listFieldsToQuery =lstFieldsToQuery;
        }
        return response;
       
    }
    /*
    @Method Name: getDataTableColumns
    @Description:Sprint 20.03 , P2OB-4620 ,To get Datatable columns and data for the datatable.
    @Author:SFO Team (Sravanthi)
    */
    @AuraEnabled
    public static DataAndColumns getDataAndColumns(Id recordId, String filter, Boolean viewAll,Boolean initialLoad,List<String> listFieldsToQuery){
        DataAndColumns response = new DataAndColumns();
        try{
            if(initialLoad){
            response = getDataTableColumns();
            }
            else{
                lstFieldsToQuery=listFieldsToQuery;
            }
            //response.createConaccess= schema.sobjecttype.contact.iscreateable();
            checkcreateConaccess(recordId,response);	//Added by Purushottam - EDGE-151592
            response = fetchContacts(recordId,filter,viewAll,response);
        }
        catch(Exception e){
            System.debug('FilterContactsController Class --- getDataAndColumns Method --- Exception' + e);
        }
        return response;
    }
    /*
    @Method Name: getDataType
    @Description:Sprint 20.03 , P2OB-4620 ,Returns data type feasible for lightning data table.
    @Author:SFO Team (Sravanthi)
    */
    
    private static string getDataType(String DataType){
        if(dataType == 'picklist' || dataType =='MultiselectPicklist'){
            return 'text';
        }
        else if(dataType == 'datetime'){
            return 'date';
        }
        return DataType;
    }

    /*
    @Method Name: getListViews
    @Description:Sprint 20.09 , P2OB-6724 ,Returns recent Accounts listveiew id for bread crumbs in viewall state
    @Author:SFO Team (Sravanthi)
    */
    @AuraEnabled
    public static ListView getListViews(String sobjectTypeName , String listviewDeveloperName) {
        ListView accListview ;
        try{
            accListview = [SELECT Id, Name FROM ListView WHERE SobjectType = :sobjectTypeName  and DeveloperName = :listviewDeveloperName LIMIT 1];
        }
        catch(Exception e){
            System.debug('FilterContactsController Class --- getListViews Method --- Exception' + e);
        }
        return accListview;
    }
    /*
    @Method Name: checkcreateConaccess
    @Description:Sprint 20.10 , EDGE-151592 , Check if the partner is elgible to create a Contact
    @Author:Alexandria Team (Purushottam)
    */
    private static void checkcreateConaccess(Id accountId,DataAndColumns response){
        
        Boolean isPartner = FeatureManagement.checkPermission('Partner_User');
        Boolean canCreateContact = (!isPartner && schema.sobjecttype.contact.iscreateable()) ? true : false;
        if(isPartner){
            User userRecord=[select id,accountid from user where id=:UserInfo.getUserId()];
            Boolean isPOR=getPORs.isPOR(userRecord.accountid,accountId,'Active');          
            canCreateContact = ( isPOR && schema.sobjecttype.contact.iscreateable())? true:false;
            response.isPOR=(isPOR) ? true:false;
        }else response.isPOR=true;
        response.createConaccess=canCreateContact;
        String Contact_Layout_Record_Type = system.label.Contact_layout_record_type;
        response.recordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Contact_Layout_Record_Type).getRecordTypeId();
    }
    /*
    @Method Name: ColumnProperties	
    @Description:Sprint 20.03 , P2OB-4620 ,Wrapper class for all column properties used in Lightning Datatable.
    @Author:SFO Team (Sravanthi)
    */
    public class ColumnProperties {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean sortable  {get;set;}
        @AuraEnabled
        public Boolean editable {get;set;}
        public ColumnProperties(string label,string fieldName,string type,Boolean editable,Boolean sortable ){
            this.label = label;
            this.fieldName=fieldName;
            this.type=type;
            this.editable = editable;
            this.sortable = sortable ;
        }
    }
    /*
    @Method Name: DataAndColumns
    @Description:Sprint 20.03 , P2OB-4620 ,Wrapper class for column properties and list of sobjects.
                SFO 20.06 :P2OB-5883 Added Create contact access to enable/disable new button
    @Author:SFO Team (Sravanthi)
    */
    public class DataAndColumns {
        @AuraEnabled
        public list<ColumnProperties> ColumnProperties {get;set;}
        @AuraEnabled
        public list<String> listFieldsToQuery {get;set;}
        @AuraEnabled
        public List<sObject> lstTableData {get;set;}
        @AuraEnabled
        public Boolean createConaccess {get;set;}
        @AuraEnabled
        public Boolean isPOR {get;set;}
        @AuraEnabled
        public Id recordTypeId {get;set;}
        public DataAndColumns(){
            ColumnProperties = new List<ColumnProperties>();
            lstTableData = new List<sObject>();
        }    
    }


    /*
    @Method Name: CustomExceptionData
    @Description:Sprint 20.03 , P2OB-4620 ,Wrapper class for exceptions while performing dml.
    @Author:SFO Team (Sravanthi)
    */
    public class CustomExceptionData {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public String code {get;set;}
    
        public CustomExceptionData(String name, String message, String code) {
            this.name = name;
            this.message = message;
            this.code = code;
        }
    }
}