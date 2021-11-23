/*********************************************************************************************************
 * Updated by : Sanjay Thakur.
 * Description : Added method "asyncSFDCaseAssignment" for executing Assignment rules for SFD Cases
 * Date : 30/03/2021
 * 
 * *******************************************************************************************************/
global With Sharing Class CaseAssignmentHandler{
    global Static List<Case> LstCase ;
    
    public static String SFDRecordTypeID=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('SFD_Request').getRecordTypeId();
    //This method will be used to call assignment rule while creating recrods from Flows
    @InvocableMethod
    public static List<String> processCaseCreation(List<ScreenInputs> lstScreenInputs){
        List<String> LstStr = new List<String>();
        if(lstScreenInputs[0].isSynchronus){
            // Synchronous Case Create
            LstStr = syncCaseRequest(lstScreenInputs[0].lstCase);
        }
        else{
            List<Case> sfdList = new List<Case>();
            List<Case> cbsList = new List<Case>();
            // Asynchronous Case Create
            Case caseInput = (Case)lstScreenInputs[0].lstCase[0];
                for(Case cse : lstScreenInputs[0].lstCase){
                        cbsList.add(cse);
                        List<String> lstCaseId = createCase(cbsList);
                        asyncCaseRequest(lstCaseId[0], caseInput.OpportunityId__c,lstScreenInputs[0].isGetSupport);
                        return lstCaseId;
                }
                
        }
        
        return LstStr;
    }
    
    static List<String> syncCaseRequest(List<case> lstCase){
        return createCase(lstCase);
        
    }
    //This Method is written to handle the functionality of CBS Case creation and Attachment mapping
    @future(callout=false)
    static void asyncCaseRequest(String lstCaseId,  String OpportunityId, Boolean isGetSupport){
        
        List<Case> cseList = [SELECT id,RecordTypeId FROM Case WHERE ID =: lstCaseId];
        for(Case cse : cseList){
            
            if((lstCaseId != null && cse.RecordTypeId != SFDRecordTypeID) || (isGetSupport && lstCaseId != null))
            {
                CaseAssignmentHelper.linkCBSCase(lstCaseId, OpportunityId);
                CaseAssignmentHelper.attachFileToCBSCase(lstCaseId, OpportunityId); 
            }else if(lstCaseId != null && cse.RecordTypeId == SFDRecordTypeID){
                CaseAssignmentHelper.attachFileToCBSCase(lstCaseId, OpportunityId);
            }
        }
    }
    
    //P2OB-11823 This method is written to execute the assignment rules for SFD Cases.
   /* @future(callout=false)
    static void asyncSFDCaseAssignment(String lstCaseId){
        List<Case> cseList = [SELECT id,OwnerId,salesup_Routing_Enabled__c FROM Case WHERE ID =: lstCaseId];
        //if(cseList.get(0).salesup_Routing_Enabled__c == true){
        Database.DMLOptions dmloptsCaseAssignmentRule = new Database.DMLOptions();
        dmloptsCaseAssignmentRule.assignmentRuleHeader.useDefaultRule = true;
        cseList.get(0).setOptions(dmloptsCaseAssignmentRule);
        update cseList;
    }*/
    
    //This Method is wriiten to Create a Case by accepting the List from flow.
    static List<String> createCase(List<case> lstCase){
        Integer startTime1 = Limits.getCpuTime();
        //List of string to Return
        List<String> LstStr = new List<String>();
        // checking caseList for Null or Empty
        if(lstCase==null || lstCase.size()==0 ){
            LstStr.add('Error :- Case List is Null or Empty');
            return LstStr;
        }
        
        //Creating DML Option record and setting the Default Assignment rule while Record creation only if salesup_Routing_Enabled__c is true on case
        if(lstCase.get(0).salesup_Routing_Enabled__c == true){
            Database.DMLOptions dmloptsCaseAssignmentRule = new Database.DMLOptions();
            dmloptsCaseAssignmentRule.assignmentRuleHeader.useDefaultRule = true;
            
            lstCase.get(0).setOptions(dmloptsCaseAssignmentRule);
            
        }
        
        //Getting all the Field Name and their data type on Case Object
        Map<String, Schema.SobjectField> fieldMap = Case.sObjectType.getDescribe().fields.getMap();
        
        //Getting all the Field Name and their Value of Case record provided to this method
        Map<String,Object> fieldToValue = lstCase.get(0).getPopulatedFieldsAsMap();
        
        //Iterating each field to check for Picklist or Milti-Picklist field
        for (String fieldName : fieldToValue.keySet()){
            String datatype = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());
            
            //skip the iteration if the Field is not Picklist or Multipicklist, if Picklist or Multipicklist check for null.
            if( (datatype !='Picklist' && datatype !='Multipicklist') || fieldToValue.get(fieldName) == null){
                continue;
            }
            
            //get the field value(data)
            String data = String.valueOf(fieldToValue.get(fieldName));
            //remove the '[' , ']' from the field value(data) 
            data= data.removeStart('[').removeEnd(']');
            lstCase.get(0).put(fieldname,data);
        }
        Database.SaveResult SR = Database.insert(lstCase.get(0),false);
        Integer endTime1 = Limits.getCpuTime();
        System.debug('Spent Time Method4'+ (endTime1 - startTime1));
        
        if (SR.isSuccess()){
            LstStr.add(SR.getId());
            return LstStr;
        }
        else{
            Database.Error err= SR.getErrors().get(0);
            LstStr.add('Error :- '+ err.getStatusCode() +' - ' + err.getMessage());
            return LstStr;
        } 
        
        
    }
    
    global class ScreenInputs {
        
        @InvocableVariable(required=true)
        global boolean isSynchronus;
        
        @InvocableVariable(required=false)
        global boolean isGetSupport;
        
        @InvocableVariable(required=true)
        global List<case> lstCase;
        
        @InvocableVariable(required=false)
        global Opportunity oppDetails;           
        
        
    }
}