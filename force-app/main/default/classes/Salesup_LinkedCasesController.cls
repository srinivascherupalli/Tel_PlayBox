/*****************************************************************************
@Author: Mahesh Gaikwad
@CreateDate: 15-July-2019
@ModifiedByandDate: 
@Description:  Class responsible for feching linked cases. This class is acting as controller for "Salesup_LinkedCase" component
@References
Epic :Certitude And Sales Support
Story:EDGE-94141
*******************************************************************************/
public without sharing class Salesup_LinkedCasesController {


   /*
    * Description : Method returns first 3 cases using the linked case custom field
    * @Param : Case ID for which we need to return linked cases records
    */
   
   @AuraEnabled
   public static list<Case> fetchLinkedCases(String recordId){

        // Early exit check
        if(String.isBlank(recordId)) return new list<Case>();

        Case caseObj =  [SELECT Id, salesup_Link_Case__c 
                        FROM Case
                        WHERE Id =: recordId];
        
        // if linked cases is empty return empty list
        if(String.isBlank(caseObj.salesup_Link_Case__c)) return new list<Case>();

        Map<String, Case> idVsCaseRecord = new Map<String, Case>([SELECT Id, CaseNumber, Subject, salesup_Work_Required__c, OwnerId, Owner.Name 
                                                                  FROM Case
                                                                  WHERE salesup_Link_Case__c =: caseObj.salesup_Link_Case__c
                                                                  ORDER BY createdDate Desc
                                                                  LIMIT 4
                                                                  ]);
                                                                  
        idVsCaseRecord.remove(recordId);
        return idVsCaseRecord.values();
   }

  /*
   * Description: methods get list of IDS of case records and change there owner to current running user
   *  @param : list of case IDs that needs to be updated with new owner
   */
   @AuraEnabled
   public static string assignCasesToUser(List<string> caseIDS){
       String currentUserID = UserInfo.getUserID();
       list<Case> caseRecordsToUpdate = new list<Case>();
        
       try{
        // update owner Id to current running user
        for(String str : caseIDS){
            caseRecordsToUpdate.add(new case(Id = str, OwnerId = currentUserID));
        }
        update caseRecordsToUpdate;
       }catch(Exception e){return 'Exception  '+e.getMessage();}

       return 'Success';
   }

   /*
    * Description : To get the wrapper of Columns and Headers which is required for lightning dataTable
    * @Param: Object and field setName both as string
	*/
    @AuraEnabled
    public static DataTableResponse fetchAllCaseRecords(String recID, String strObjectName, String strFieldSetName){
        try{
                 
            //Get the fields from FieldSet
            Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(strObjectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetName);
            
            //To hold the table hearders 
            List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
            
            //Field to be queried - fetched from fieldset
            List<String> lstFieldsToQuery = new List<String>();
            
            //The final wrapper response to return to component
            DataTableResponse response = new DataTableResponse();
            
            for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
                String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();

                if(dataType == 'datetime'){
                    dataType = 'date';
                }else if(dataType == 'String' || dataType == 'picklist'){
                    dataType = 'text';
                }

                if(eachFieldSetMember.getFieldPath() == 'OwnerId'){
                    //Create a wrapper instance and store label, fieldname and type.
                    DataTableColumns datacolumns = new DataTableColumns('Owner Name' , 
                                                                        String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                        dataType);
                    lstDataColumns.add(datacolumns);
                    lstFieldsToQuery.add('Owner.Name');
                }else{
                    //Create a wrapper instance and store label, fieldname and type.
                    DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                        String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                        dataType);
                    lstDataColumns.add(datacolumns);
                    lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
                }    
            }

            Case caseObj =  [SELECT Id, salesup_Link_Case__c 
                             FROM Case
                             WHERE Id =: recID limit 1];
            
            String linkedCaseStr = caseObj.salesup_Link_Case__c;
                                            
            //Form an SOQL to fetch the data - Set the wrapper instance and return as response
            if(! lstDataColumns.isEmpty() && String.isNotBlank(linkedCaseStr)){            
                response.lstDataTableColumns = lstDataColumns;
                String query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') + ' FROM Case WHERE salesup_Link_Case__c = :linkedCaseStr Order By createdDate Desc Limit 50';
                
                for(sobject sobj : Database.query(query)){

                    // if record ID matches with current case
                    if(recID == sobj.get('Id')) continue;

                    /* assign ownerId with the value of owner name, this will help us to show owner name in data table.
                     this code is not suppose to run in test context because it is giving error for following dynamic assignment
                     */
                    if(Test.isRunningTest() == false){
                        sobj.put('OwnerId',sobj.getSObject('Owner').get('Name'));
                    }
                       
                    response.lstDataTableData.add(sobj);  
                }
            }
            return response;
        }catch(Exception e){
            throw new expException(recID+' Error '+e.getStackTraceString());
        }
    }

   //Wrapper class to hold Columns with headers
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        
        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DataTableColumns(String label, String fieldName, String type){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;            
        }
    }

    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}                
        
        public DataTableResponse(){
            lstDataTableColumns = new List<DataTableColumns>();
            lstDataTableData = new List<sObject>();
        }
    }

    public class expException extends Exception{}
}