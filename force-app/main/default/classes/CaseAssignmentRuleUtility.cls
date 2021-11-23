/*
    Class       : CaseAssignmentRuleUtility
    Team        : Team Jaipur
    Author      : Rupendra/Nilima
    Objective   : This class will be called from the Screen Flows to run the Case assignment rule and linking of uploaded attachments with Case
    Test Class  : CaseAssignmentRuleUtility
    Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)
                    Pallavi B ::DIGI-8623  (SFO-Sprint 21.11)

*/
global without Sharing Class CaseAssignmentRuleUtility{
    /* Variable declaration start here */
    global Static List<Case> LstCase ;
    //Added below 2 lines as part of P2OB-14635 (SFO-Sprint 21.10) && DIGI-8623  (SFO-Sprint 21.11)
    global static Id caseOppId;
    global static Boolean attachOpty=false;
    /* Variable declaration end here */
    
    /* Screen Flow to send Input parameters*/
    global class ScreenInputs {
        @InvocableVariable(required=true) 
        global List<case> lstCase; 
        
        @InvocableVariable(required=false) 
        global List<Id> lstFileIds; 
        
        @InvocableVariable(required=true) 
        global Boolean isSynchronus; 
        
        @InvocableVariable(required=false) 
        global String strParentRecordId;
        
        //Added below 2 lines as part of P2OB-14635 (SFO-Sprint 21.10) && DIGI-8623  (SFO-Sprint 21.11). Gets Input from Flow in order to attach files to Opportunity
        @InvocableVariable(required=false) 
        global Boolean attachFilestoOpportunity;
        
    }
    
    /* Screen Flow to handle Output parameters*/
    global class ScreenOutputs {
        @InvocableVariable 
        global Boolean hasSuccess; 
        
        @InvocableVariable 
        global String strCaseId;
        
        @InvocableVariable 
        global String strMessage;
        
        global ScreenOutputs(Boolean hasSuccess, String strCaseId, String strMessage){
            this.hasSuccess = hasSuccess;
            this.strCaseId = strCaseId;
            this.strMessage = strMessage;
        }
    }
    
    /*
    Purpose: Method will be called from the Screen Flow and process the Case creation
    Input Parameters: Collection List<ScreenInputs>
    Output Parameters: Collection List<ScreenOutputs>
    */
    @InvocableMethod
    public static List<ScreenOutputs> processCaseCreation(List<ScreenInputs> lstScreenInputs){
        List<ScreenOutputs> lstCaseResult = new List<ScreenOutputs>();
        //Added below 2 lines as part of P2OB-14635 (SFO-Sprint 21.10) && DIGI-8623  (SFO-Sprint 21.11):: To get Opportunity Id and attachfiles Input from flow
        caseOppId= lstScreenInputs[0].lstCase.get(0).OpportunityId__c; 
        attachOpty= lstScreenInputs[0].attachFilestoOpportunity;
        
        if(lstScreenInputs[0].isSynchronus){
            // Synchronous Case Create
            lstCaseResult = syncCaseRequest(lstScreenInputs[0].lstCase, lstScreenInputs[0].lstFileIds, lstScreenInputs[0].strParentRecordId);
        }
        else{
            // Asynchronous Case Create
            Case caseInput = (Case)lstScreenInputs[0].lstCase[0];
            lstCaseResult = createCase(lstScreenInputs[0].lstCase);
            // Pass the Case Record Id and the FileIds to link          
            asyncCaseRequest(lstCaseResult[0].strCaseId, lstScreenInputs[0].lstFileIds);             
        }
      
        return lstCaseResult;
    }
    
    /*
    Purpose: Process the Synchronous Case creation where Attachment will link with Case and then response will send on screen
    Input Parameters: Collection List<ScreenInputs>
    Output Parameters: Collection List<ScreenOutputs>
    */
        static List<ScreenOutputs> syncCaseRequest(List<case> lstCase, List<Id> lstFileIds, String strParentRecordId){
        String ServiceSupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('srvsup_Service_Support').getRecordTypeId();
        List<ScreenOutputs> lstCaseResult =  createCase(lstCase);
        attachFileToCase(lstCaseResult[0].strCaseId, lstFileIds);
        if(lstCase[0].RecordTypeId != ServiceSupportRecordTypeId) // added to de-link service support and channel care cases 
        	linkToCase(lstCaseResult[0].strCaseId, strParentRecordId);
        return lstCaseResult;
    }
    
    /*
    Purpose: Process the Asynchronous Case creation where response will send on screen after the case creation and attachments will link to case later in future call
    Input Parameters: Collection List<ScreenInputs>
    Output Parameters: Collection List<ScreenOutputs>
    */
    @future(callout=false)
    static void asyncCaseRequest(String lstCaseId, List<Id> lstFileIds){
        if(lstCaseId != null){
            //CaseAssignmentHelper.linkCBSCase(lstCaseId, OpportunityId);
            attachFileToCase(lstCaseId, lstFileIds); 
        }
    }
    
    /*
    Purpose: Link the Files with the Case
    Input Parameters: Case Record Id, Collection of File Ids
    Output Parameters: Nonw
    */
    public static void attachFileToCase(String caseId, List<Id> lstFileIds){
        if(lstFileIds != null){
            List<ContentDocumentLink> lstContDocLink = new List<ContentDocumentLink>();
            for(Id fileId : lstFileIds){
                ContentDocumentLink contentdoclik = new ContentDocumentLink(ContentDocumentId = fileId, LinkedEntityId = caseId);
                lstContDocLink.add(contentdoclik);
                //Starts here ::Added below logic as part of P2OB-14635 (SFO-Sprint 21.10) && DIGI-8623  (SFO-Sprint 21.11) ::Attaches Files to Opportunity
               if(attachOpty!=null && attachOpty && caseOppId!=null){
                     ContentDocumentLink contentdocliks = new ContentDocumentLink(ContentDocumentId = fileId, LinkedEntityId = caseOppId );
                	lstContDocLink.add(contentdocliks);
                } //Ends Here ::Modified as part of P2OB-14635 (SFO-Sprint 21.10)
              
            }
            if(!lstContDocLink.isEmpty())
            insert lstContDocLink;
        }
    }
    
    public static void linkToCase(String strCaseId, String strParentRecordId){
       Case parentCaseRecord = new Case();
       Case childCaseRecord = new Case();
       List<case> caseToUpdate = new List<case>();
       system.debug('strParentRecordId++'+strParentRecordId);
       if(String.IsEmpty(strParentRecordId) || strParentRecordId == ''){
           parentCaseRecord.id = strCaseId;
           parentCaseRecord.salesup_Link_Case__c = strCaseId;
           caseToUpdate.add(parentCaseRecord);
       }else if(!String.IsEmpty(strParentRecordId)){
           childCaseRecord.id = strCaseId;
           childCaseRecord.salesup_Link_Case__c = strParentRecordId;
           caseToUpdate.add(childCaseRecord);
       }
       System.debug('caseToUpdate+++'+ caseToUpdate); 
       if(!caseToUpdate.isEmpty() && caseToUpdate[0].id !=null)
       		update caseToUpdate;
       
    }
    
    /*
    Purpose: Actual case creation along with Case assignment rule execution based on the Case Field Flag salesup_Routing_Enabled__c
    Input Parameters: Collection List<ScreenInputs>
    Output Parameters: Collection List<ScreenOutputs>
    */
    static List<ScreenOutputs> createCase(List<case> lstCase){
        //List of string to Return
        List<ScreenOutputs> lstCaseResult = new List<ScreenOutputs>();
        // checking caseList for Null or Empty
        if(lstCase==null || lstCase.size()==0 ){
            lstCaseResult.add(new ScreenOutputs(false, null,'Error :- Case List is Null or Empty'));
            return lstCaseResult;
        }        

        // Check if case created by agent, if Yes then assign case to agent only
        boolean caseCreatedByAgent = handleCaseNoRouting(lstCase.get(0));
        system.debug('handleCaseNoRouting caseCreatedByAgent=='+caseCreatedByAgent);

        //Creating DML Option record and setting the Default Assignment rule while Record creation only if user is not member of agent queue and salesup_Routing_Enabled__c is true on case
        if(!caseCreatedByAgent && lstCase.get(0).salesup_Routing_Enabled__c == true){
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
        
        if (SR.isSuccess()){
            lstCaseResult.add(new ScreenOutputs(true, SR.getId(),'Success'));
            return lstCaseResult;
        }
        else{
            Database.Error err= SR.getErrors().get(0);
            lstCaseResult.add(new ScreenOutputs(false, null, 'Error :- '+ err.getStatusCode() +' - ' + err.getMessage()));
            return lstCaseResult;
        } 
     
    }

    /*
    Purpose: Logic to check case owner is member of any agent queue or not
    UserStrory : P2OB-14640
    Sprint : 21.09
    Developer : Chandrakant
    Input Parameters: Case newCase
    Output Parameters: boolean UserIsMemberOfAgentQueue, default false
    */
    public static boolean handleCaseNoRouting(case newCase){

        Boolean UserIsMemberOfAgentQueue = false; //default value

        if(newCase != null){
            String userId = System.UserInfo.getUserId(); //Get current user id
            List<String> userQueueIds = new List<String>();
            List<String> agentQueueIds = new List<String>();

            //Query on Group object to get agentQueues starts with 'Salesup_,servsup_,Billing_Enquiry_'
            List<Group> agentQueueList = [select DeveloperName, Type from Group where DeveloperName != 'srvsup_Workflow_Co_ordinator' 
            AND Type ='Queue' AND (DeveloperName LIKE 'salesup_%' OR DeveloperName LIKE 'srvsup_%' OR 
            DeveloperName LIKE 'mm_Enterprise_Mobile_Support_%' OR DeveloperName LIKE 'Billing_Enquiry_%')];

            //Query on GroupMember object to get list of queue who have user queue membership
            List<GroupMember> userQueueList = [select id,GroupId, Group.DeveloperName, UserOrGroupId from GroupMember where UserOrGroupId =: userId];

            for(GroupMember userQueue: userQueueList){
                // If user is member of workflow coordinator queue, return UserIsMemberOfAgentQueue to false
                if(userQueue.Group.DeveloperName =='mm_customer_request_queue' || 
                userQueue.Group.DeveloperName == 'srvsup_Workflow_Co_ordinator'){
                    return UserIsMemberOfAgentQueue;
                }
                userQueueIds.add(userQueue.GroupId);
            }
            
            //create list of agentQueue Ids
            for(Group agentQueue: agentQueueList){
                agentQueueIds.add(agentQueue.Id);
            }

            for(String userQueueId: userQueueIds){
                // check whether user queue membership contains agent queues, if Yes then set UserIsMemberOfAgentQueue to true
                if(agentQueueIds.contains(userQueueId)){
                    system.debug('Yes, User is Agent');
                    UserIsMemberOfAgentQueue = true;
                    break;
                }
            }
        }
        return UserIsMemberOfAgentQueue;        
    }
}