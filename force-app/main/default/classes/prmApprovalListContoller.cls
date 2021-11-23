/*******************************************************************
Created By          :   Bhargava / Uday
Created Date        :   
Desc                :   This is used by the lighting component Opportunity for Approval in home page tab in portal
Date            Version             Modified By             Desc
26-july-2018        1                   Uday K  
11-Sept-2018        1.1                 Saran               Added Recall method
29-Apr-2020         1.2                 Vivian (Hawaii)     P2OB: 5535: Updated reCallRecord method to handle bulk operation
12-May-2020         1.3                 Ritika Jaiswal      Team Hawaii : P2OB-6027 : Commentted for handling partner-account-id and partner__c update in process-builder 'PRM Submit to Partner' 

25-Feb-2021         1.4                 Vivian Charlie      Team Hawaii : P2OB-12530 I should be able to recall the opportunity before it has been accepted/ rejected by the Partner

***********************************************************************/
/*
 * Modified By : Team Hawaii
 * Modified Date : 30/3/2020
 * Jira : P2OB-5535
 * Description : modified 'reCallRecord'method to handle recall action for lead.Initially this class handle logic only for Opportunity
*/
public without sharing class prmApprovalListContoller {
    @auraenabled
    public string sComments {get; set;}
    /**
    * Gets the approval list.
    *
    * @return The approval list.
    */
    @auraenabled
    public static list<approvalWrapperClass> getApprovalList() {
        String accountId = [Select id, AccountId from user where id = :Userinfo.getUserid()][0].AccountId;
        Set<String> setuserId = new Set<String>();
        for (User eachuser : [Select Id, contact.AccountId from user
                              where AccountId = : accountId and AccountId!=null]) {
            setuserId.add(eachuser.Id);
        }
        list<ProcessInstanceWorkitem> processItems = [SELECT Id, ActorId, ProcessInstance.id,
                                      ProcessInstance.TargetObjectId,
                                      ProcessInstance.SubmittedById
                                      FROM ProcessInstanceWorkitem
                                      where ProcessInstance.TargetObject.Type = 'Opportunity'
                                              and ProcessInstance.Status = 'Pending'
                                                      AND ActorId in:setuserId];
        // WHERE actorid = :userinfo.getUserid()];
        list<id> approvalIds = new list<id>();
        list<id> approvalIdUser = new list<id>();
        set<id> sprocessItms = new set<id>();
        if (!processItems.isEmpty()) {
            for (ProcessInstanceWorkitem obj : processItems) {
                sprocessItms.add(obj.ProcessInstance.id);
            }
        }
        set<id> sPIDs = new set<id>();
        if (!sprocessItms.isEmpty()) {
            List<ProcessInstance> lst = [select id from ProcessInstance
                                         where id in:sprocessItms
                                        ];
            For(ProcessInstance objPI : lst) {
                sPIDs.add(objPI.id);
            }
        }
        List<ProcessInstanceStep> lstProcessInstances = new List<ProcessInstanceStep>();
        if (!sPIDs.isEmpty()) {
            lstProcessInstances  = [select id, Comments, ProcessInstanceId
                                    from ProcessInstanceStep
                                    where ProcessInstanceId in:sPIDs];
        }
        map<id, ProcessInstanceWorkitem> processInstanceMap = new map<id, processInstanceWorkitem>();
        list<approvalWrapperClass> listToReturn = new list<approvalWrapperClass>();
        for (ProcessInstanceWorkitem pwi : processItems) {
            if ((pwi.ProcessInstance.TargetObjectId) != null) {
                approvalIds.add(pwi.ProcessInstance.TargetObjectId);
                processInstanceMap.put(pwi.ProcessInstance.TargetObjectId, pwi);
            }
        }
        for (opportunity opp : [select id, name, CloseDate, Amount, Account.Name
                                from opportunity
                                where id IN:approvalIds]) {
            listToReturn.add(new approvalWrapperClass(opp,opp.name, 
                                                      processInstanceMap.get(opp.id).id, 
                                                      opp.Amount, 
                                                      opp.CloseDate, 
                                                      opp.Account.Name, 
                                                      'Test Comments',
                                                     null));
        }
        return listToReturn;
    }
    /**
    * Approve / reject Records with comments
    *
    * @param      workItemId  The work item identifier
    *
    * @return     { description_of_the_return_value }
    */
    @auraenabled
    public static list<ApprovalWrapperClass> handleApprovalAction(string workItemId,
            String sComments,
            String sApprovalType,
            String opptyId) {
        list<approvalWrapperClass> listToReturn = new list<approvalWrapperClass>();
        try {
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(sComments);
            req2.setAction(sApprovalType.equalsIgnoreCase('Approve') 
                           ? PRMConstants.PRM_Approval_Status 
                           : PRMConstants.PRM_Rejected_Staus);
            req2.setWorkitemId(workItemId);
            //Approval.ProcessResult[] result2 =  Approval.process(req2);
            Approval.process(req2);
            system.debug('***Telstra:prmApprovalListController:handleApprovalAction:opptyId@@'+opptyId);
            Opportunity oppty= [Select id,account.ownerid,DCHOwner__c,Opportunity_Sharing_Id__c,Ownerid from Opportunity where Id=:opptyId];
            system.debug('***Telstra:prmApprovalListController:handleApprovalAction:oppty@@'+oppty);
            oppty.ownerId=userinfo.getUserId();
            update oppty;
            system.debug('***Telstra:prmApprovalListController:handleApprovalAction:Opportunity Sharing Id'+oppty.Opportunity_Sharing_Id__c);
           list<OpportunityShare> oppsharedeletelist=[select id from OpportunityShare where id=:oppty.Opportunity_Sharing_Id__c];
            system.debug('***Telstra:prmApprovalListController:handleApprovalAction:oppsharedeletelist'+oppsharedeletelist);
            if(oppsharedeletelist.size()>0)
                delete oppsharedeletelist; 
            listToReturn = getApprovalList();
        } catch (Exception e) {
            System.debug('***Telstra:prmApprovalListController:handleApprovalAction:Exception:'+e.getStackTraceString());
            //return e.getStackTraceString();
            listToReturn.add(new ApprovalWrapperClass(null,null,null,null,null,null,null,e.getStackTraceString()));
        }
        return listToReturn;
    }  
    /* Method : ApproveRecord
     * Description : This method will invoke the approval process and will update the status to Approved*/
    @auraenabled
    public static list<approvalWrapperClass> approveRecord(string workItemId,string sComments){
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments(sComments);
        req2.setAction(PRMConstants.PRM_Approval_Status);
        req2.setWorkitemId(workItemId);       
        Approval.process(req2);
        return getApprovalList();
    }
     /* Method : rejectRecord
     * Description : This method will invoke the approval process and will update the status to Rejected*/
    @auraenabled
    public static list<approvalWrapperClass> rejectRecord(string workItemId,string sComments){
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments(sComments);
        req2.setAction(PRMConstants.PRM_Rejected_Staus); 
        req2.setWorkitemId(workItemId);
        Approval.process(req2);
        return getApprovalList();
    }
    /* Method : recallRecord 
     * Description : This method will invoke the approval process and will recall 
    */
    //Team Hawaii : P20B- 5535 modified method to handle recall action for lead.Initially this class handle logic only for Opportunity 
    //This action is called from Process Builder 'EDGE PRM Opportunity SLA source is TELSTRA','PRM Lead Submit to Partner'.OpptyId variable 
    //take both oppty id or Lead Id.We are not going to change variable name as this method is called in schedule action and after deployment
    //existing schedule action fail if existing opptyId Variable not found.
    @InvocableMethod
    public static void reCallRecord(List<string> opptyId){
    //P2OB - 5535 : method variables
    map<Id,Opportunity> mapOpportunity = new map<Id,Opportunity>();
    map<Id,Lead> mapLead = new map<Id,Lead>();
    List<String> oppIds = new List<String>(); 
    List<String> leadIds = new List<String>();
    list<Opportunity> lstOpportunityToUpdate = new list<Opportunity>();
    list<Lead> lstLeadToUpdate = new list<Lead>();
    list<Approval.ProcessWorkitemRequest> lstProcessItems = new list<Approval.ProcessWorkitemRequest>();
    //P2OB - 5535 : Opp and Lead ids are separated from inputList
    for(String strId : opptyId){
        if(strId.startsWith('006'))
            oppIds.add(strId);       //P2OB - 5535 : Add opportunityId to list of Opportunities
        else if(strId.startsWith('00Q'))
            leadIds.add(strId);      //P2OB - 5535 : Add leadId to list of Leads
    }
        if(opptyId != Null && opptyId.size() > 0){
        System.debug('***Telstra:prmApprovalListController:reCallRecord:InputSize:'+ opptyId.size() + ' inputList:'+opptyId);
            //P2OB - 5535: Execute query based on list of records of different objects            
            if(oppIds.size() > 0){
            // if opportunity id is passed then this query will return result 
                mapOpportunity = new map<Id,Opportunity>([Select id,Ownerid,name,SubmittoPartnerStatus__c,PartnerAccountId,Partner__c,CreatedById 
                                                      from Opportunity where Id IN : oppIds]);}
            if(leadIds.size() > 0){
            // if Lead id is passed then this query will return result
                mapLead = new map<Id,Lead>([Select Id,Share_with_Partner_Status__c,Shared_By__c,SLA_date__c,Partner_Principal_Contact__c 
                                                         from Lead Where Id IN : leadIds ]);}
            try{
                for(ProcessInstanceWorkitem processItems : [ SELECT Id, ActorId, ProcessInstance.id,
                                              ProcessInstance.TargetObjectId,
                                              ProcessInstance.SubmittedById
                                              FROM ProcessInstanceWorkitem
                                              where ProcessInstance.TargetObjectId IN : opptyId
                                                               and ProcessInstance.Status = 'Pending']){
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments(PRMConstants.PRM_Recall_Comments);
                    req2.setAction(PRMConstants.PRM_Recall_Action); 
                    req2.setWorkitemId(processItems.Id);
                    lstProcessItems.add(req2); // adding to list of approval items to process
                    //Approval.process(req2);
                    system.debug('***Telstra:prmApprovalListController:handleApprovalAction:ProcessInstance.TargetObjectId**************'+processItems.ProcessInstance.TargetObjectId);
                    /* v1.4 following portion is not required, is handled in standard Approval recall action
                    if(String.valueOf(processItems.ProcessInstance.TargetObjectId).startsWith('006')){
                        //EDGE-71787 Replacing the custom field Partner_Account__c with salesforce OOTB field PartnerAccountId
                        system.debug('***Telstra:prmApprovalListController:reCallRecord:OPPORTUNITY USE CASE**********');
                        // fetch the opportunity from mapOpportunity
                        //Opportunity oppty= mapOpportunity.get(processItems.ProcessInstance.TargetObjectId); // v1.4
                        //oppty.SubmittoPartnerStatus__c = PRMConstants.PRM_SubmittoPartnerStatus_Recalled; // v1.4

                        //oppty.PartnerAccountId = null; 
                        //oppty.Partner__c = null; 
                        //lstOpportunityToUpdate.add(oppty); // adding to list of opportunities to process // v1.4
                    }else 
                    */
                    if(String.valueOf(processItems.ProcessInstance.TargetObjectId).startsWith('00Q')){

                        system.debug('***Telstra:prmApprovalListController:reCallRecord:LEAD USE CASE**********');
                        // fetch the Lead from mapLead
                        Lead lead = mapLead.get(processItems.ProcessInstance.TargetObjectId);
                        lead.Share_with_Partner_Status__c = PRMConstants.PRM_SubmittoPartnerStatus_Recalled;
                        lstLeadToUpdate.add(lead); // adding to list of leads to process
                    }
                } // end of for loop for iterating aproval records
                Approval.process(lstProcessItems, false); // process all approval items together
                // if opportunity list is not empty update opportunities
                /* //v1.4
                if(!lstOpportunityToUpdate.isEmpty()){
                    update lstOpportunityToUpdate;
                }
                */
                // if leads list is not empty update leads
                if(!lstLeadToUpdate.isEmpty()){
                    update lstLeadToUpdate;
                }
            }catch(Exception e){
                 System.debug('***Telstra:prmApprovalListController:reCallRecord:Exception:'+e.getStackTraceString());
            }    
        }
    }
}