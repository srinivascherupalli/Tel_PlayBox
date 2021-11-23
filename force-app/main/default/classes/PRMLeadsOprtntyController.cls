/*******************************************************************
Created By          :   Garg / Ashish
Created Date        :   
Desc                :   This is used to show lead and opportunity cards data on partner community

Date            Version             Modified By             Desc
25-july-2019        1               Ashish garg                

Date            Version             Modified By             Desc
4-November-2019     2               Paresh Patil            (Team Hawaii)Added additional logic to display share by field as part of Jira - P2OB-3691
2-April-2020        3               Ritika Jaiswal          P2OB - 5611 - Updates to return list of Leads as CardViewList and update lead-record, approval-process when declined by partner
3-April-2020        4               Ritika Jaiswal          P2OB - 5611 - Update mapping of attributes on Card for Lead
14-April-2020       5               Ritika Jaiswal          P2OB - 5611 - Commented out the update-lead functionality, in decline scenario
20-April-2020       6               Ritika Jaiswal          P2OB - 5708 - Update-Lead functionality with Decline Reason and Decline Comments
27-April-2020       7               Ritika Jaiswal          P2OB - 5673 - Adding Campaign Name for Lead's Tile
23-Jun-2020         8               Ritika Jaiswal          P2OB-6903 - Primary Domain for Oppty Tile 
01-Sep-2020         9               Vivian Charlie          P2OB-6901 Updated fields to be displayed
08-Oct-2020         10              Vivian Charlie          P2OB-4465 display opportunity owner as Shared By for Review opportunities
04-Oct-2021         11              Vivian Charlie          DIGI-28337 updated review and new tile condition based on SFO's changes related to 
                                                            removal of Customer_Accepted__c field update removal from Close Opportunity flow
***********************************************************************/

public without sharing class PRMLeadsOprtntyController {
    private static final String LEAD_OBJECT_NAME = 'Lead';
    private static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';
    private static final String PARTNER_USER = 'PowerPartner';
    private static final String APPROVAL_PENDING_STATUS = 'Pending';

/*
*  @JIRA        : P2OB-5611
*  @Description : Method optimized to reuse code between Opportuinity and Lead Views               
*/    
    @AuraEnabled(cacheable=true)
    public static List<PRMLeadsOprntyWrapper> getObjectData(String objectName){
        String query;
        list<PRMLeadsOprntyWrapper> listToReturn = new list<PRMLeadsOprntyWrapper>();
        try{
            
            // query = 'SELECT Id,Name,AccountId,Amount,CloseDate,Account.Name FROM Opportunity LIMIT 100';
            
            //call already exists controller method to get approval list of opportunity. so we will dont have redundant code. 
            //    list<approvalWrapperClass> listOfOpp =  prmApprovalListContoller.getApprovalList();
            
            String accountId = [Select id, AccountId from user where id = :Userinfo.getUserid()][0].AccountId;
            Set<String> setuserId = new Set<String>();
            for (User eachuser : [Select Id, contact.AccountId from user
                                  where AccountId = : accountId and AccountId!=null]) {
                                      setuserId.add(eachuser.Id);
                                  }
            //P2OB-5611 : Updated hardcoded-strings with static literals
            list<ProcessInstanceWorkitem> processItems = [SELECT Id, ActorId, ProcessInstance.id,
                                                          ProcessInstance.TargetObjectId,
                                                          ProcessInstance.SubmittedById,
                                                          CreatedDate
                                                          FROM ProcessInstanceWorkitem
                                                          where ProcessInstance.TargetObject.Type = :objectName
                                                          and ProcessInstance.Status =: APPROVAL_PENDING_STATUS 
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
            for (ProcessInstanceWorkitem pwi : processItems) {
                if ((pwi.ProcessInstance.TargetObjectId) != null) {
                    approvalIds.add(pwi.ProcessInstance.TargetObjectId);
                    processInstanceMap.put(pwi.ProcessInstance.TargetObjectId, pwi);
                }
            }
            System.debug('***Telstra:PRMLeadsOprtntyController:getObjectData:processInstanceMap:'+processInstanceMap);
            Date approvalCreateDate = null;
            String dchOwner = null;
            String tileType = '';
            String CampaignName = null;  //P2OB-5673 : Most recent Campaign on Lead
            //P2OB-5611 : Updated hardcoded-strings with static literals
            if(objectName.equals(OPPORTUNITY_OBJECT_NAME)){ 
                for (opportunity opp : [select id, name, CloseDate, Amount, Account.Name, Owner.Name, DCHOwner__c, DCHOwner__r.Name, DCHOwner__r.UserType, DCHOwner__r.Account.Name, Customer_Accepted__c, Product_Domain__c, Closure_Approver__c 
                                        from opportunity
                                        where id IN:approvalIds]) {
                                            approvalCreateDate =  date.newinstance(processInstanceMap.get(opp.id).CreatedDate.year(), processInstanceMap.get(opp.id).CreatedDate.month(), processInstanceMap.get(opp.id).CreatedDate.day()) ;
                                            // Added addition logic to populate shared by field as part of story P2OB-3691
                                            //P2OB-5611 : Updated hardcoded-strings with static literals
                                            if(opp.Closure_Approver__c != null){ // DIGI-28337 for review opportunities display opportunity owner as Shared By
                                                dchOwner = opp.Owner.Name;
                                            }else if(opp.DCHOwner__c != Null && opp.DCHOwner__r.UserType!=null && opp.DCHOwner__r.UserType.contains(PARTNER_USER)  && opp.DCHOwner__r.AccountId != Null){
                                                dchOwner = opp.DCHOwner__r.Account.Name; 
                                            }else if(opp.DCHOwner__c != Null && opp.DCHOwner__r.UserType!=null && !opp.DCHOwner__r.UserType.contains(PARTNER_USER)){
                                                dchOwner =  opp.DCHOwner__r.Name;
                                            }
                                            tileType = opp.Closure_Approver__c != null ? 'Review' : 'New'; //DIGI-28337
                                            boolean isClosure = opp.Closure_Approver__c != null ? true : false; //DIGI-28337
                                            //P2OB-5708 : Passing campaign as null for opportunity 
                                            //P2OB-6903 - Primary Domain for Oppty Tile  
                                            listToReturn.add(new PRMLeadsOprntyWrapper(opp.name,processInstanceMap.get(opp.id).id,opp.Amount,approvalCreateDate,opp.Account.Name,opp.id,dchOwner,tileType,isClosure,CampaignName,opp.Product_Domain__c)); //DIGI-28337
                                        }
                
                
                //    for(approvalWrapperClass opp : listOfOpp){
                
                //        listOfOppApproval.add(new PRMLeadsOprntyWrapper(opp.oppName,opp.workItemId,opp.Amount,opp.CloseDate,opp.AccountName,opp.oppId));
                
                //    }
                
                
            }else if(objectName.equals(LEAD_OBJECT_NAME)){ //P2OB-5611 : For handling cardListView of Leads
                //P2OB-5611: Get leads which are shared with Partners of this account , P2OB-5673 : Get most recent campaign details from lead-record 
                for (Lead newLeads : [select id, Name,Primary_Domain__c,Customer_Name__r.Name,Contact_Name__r.Name,Shared_By__c,Shared_By__r.Name,Shared_By__r.UserType,Shared_By__r.Account.Name, Share_with_Partner_Status__c,Accepted_Date_Stamp__c,Status,Distributor_Contact__c,Distributor_Contact__r.UserType,Distributor_Contact__r.Account.Name,(select id,Campaign.name,status,LastModifiedDate from CampaignMembers order by LastModifiedDate desc limit 1) from Lead where id IN:approvalIds]) {
                    CampaignName = null; //P2OB-5673 : Variable to store most recent campaign from Lead-record
                    //P2OB-5611: Date on which lead was shared with Partner
                    approvalCreateDate =  date.newinstance(processInstanceMap.get(newLeads.id).CreatedDate.year(), processInstanceMap.get(newLeads.id).CreatedDate.month(), processInstanceMap.get(newLeads.id).CreatedDate.day()) ;
                    //tileType = 'New';
                    //P2OB-5611: Get which user or Partner has shared this lead
                    if(newLeads.Shared_By__c != Null && newLeads.Shared_By__r.UserType!=null && newLeads.Shared_By__r.UserType.contains(PARTNER_USER)  && newLeads.Shared_By__r.AccountId != Null && String.isBlank(newLeads.Distributor_Contact__c)){
                        dchOwner = newLeads.Shared_By__r.Account.Name;  // P2OB-5611 : Lead shared by Direct-Partner 
                    }else if(newLeads.Shared_By__c != Null && newLeads.Shared_By__r.UserType!=null && !newLeads.Shared_By__r.UserType.contains(PARTNER_USER) && String.isBlank(newLeads.Distributor_Contact__c)){
                        dchOwner = newLeads.Shared_By__r.Name; // P2OB-5611 : Lead shared by Telstra
                    }else if(!String.isBlank(newLeads.Distributor_Contact__c) && newLeads.Distributor_Contact__r.UserType!=null && newLeads.Distributor_Contact__r.UserType.contains(PARTNER_USER))
                        dchOwner = newLeads.Distributor_Contact__r.Account.Name; // P2OB-5708 : Lead shared by Distributor-Partner
                    //P2OB-5673: Retrieve Campaign Name
                    if(newLeads.CampaignMembers.size() > 0 ){
                        System.debug('***Telstra:PRMLeadsOprtntyController:getObjectData:Lead:Campaign:'+newLeads.CampaignMembers[0].Campaign.name);
                        CampaignName = newLeads.CampaignMembers[0].Campaign.name;
                    }
                    //P2OB-5611: Add to the list to be return to LWC, P2OB - 5673: Adding param for campaignName, Replaced Lead-name with Lead-Contact-Name, P2OB-6903 - Primary Domain paramater added 
                    //P2OB-6901 adding Replacing Contact Name with Lead Name, adding Primary Domain
                    listToReturn.add(new PRMLeadsOprntyWrapper(newLeads.Name,processInstanceMap.get(newLeads.id).id,0,approvalCreateDate,newLeads.Customer_Name__r.Name,newLeads.id,dchOwner,tileType,true,CampaignName,newLeads.Primary_Domain__c));                   
                }
                System.debug('***Telstra:PRMLeadsOprtntyController:getObjectData:Lead:listToReturn:'+listToReturn);
            }
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            listToReturn.add(new PRMLeadsOprntyWrapper(null,null,null,null,null,null,null,null,null,null,null)); //P2OB - 5673 : Adding param for campaignName, //P2OB-6903 - Primary Domain paramater added  
        }
        return listToReturn;    
    }
    
    @AuraEnabled
    public static List<PRMLeadsOprntyWrapper> getApprovedOppData(String workItemId){
        
        //call already exists controller method to get approval list of opportunity. so we will dont have redundant code. 
        //    list<approvalWrapperClass> listOfOpp =  prmApprovalListContoller.approveRecord(workItemId,null);
        //    list<PRMLeadsOprntyWrapper> listOfOppApproval = new List<PRMLeadsOprntyWrapper>();
        //    for(approvalWrapperClass opp : listOfOpp){
        
        //        listOfOppApproval.add(new PRMLeadsOprntyWrapper(opp.oppName,opp.workItemId,opp.Amount,opp.CloseDate,opp.AccountName,opp.oppId));
        
        //    }
        
        //    return listOfOppApproval;
        try{
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(null);
            req2.setAction(PRMConstants.PRM_Approval_Status);
            req2.setWorkitemId(workItemId);       
            Approval.process(req2);
            
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }
        return getObjectData('Opportunity');    
    }
    
    @AuraEnabled
    public static List<PRMLeadsOprntyWrapper> getDeclinedOppData(String workItemId){
        
        //call already exists controller method to get approval list of opportunity. so we will dont have redundant code. 
        //    list<approvalWrapperClass> listOfOpp =  prmApprovalListContoller.rejectRecord(workItemId,null);
        //    list<PRMLeadsOprntyWrapper> listOfOppApproval = new List<PRMLeadsOprntyWrapper>();
        //    for(approvalWrapperClass opp : listOfOpp){
        
        //        listOfOppApproval.add(new PRMLeadsOprntyWrapper(opp.oppName,opp.workItemId,opp.Amount,opp.CloseDate,opp.AccountName,opp.oppId));
        
        //    }
        
        //    return listOfOppApproval;
        try{
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(null);
            req2.setAction(PRMConstants.PRM_Rejected_Staus); 
            req2.setWorkitemId(workItemId);
            Approval.process(req2);
            
        }catch(Exception e){
            System.debug(e.getStackTraceString());
        }    
        return getObjectData('Opportunity');
        
    }
    
/*
*  @JIRA        : P2OB-5611
*  @Description : Method to update approvalProcess as 'Approved' 
*  @Parameters  : workItemId - ID of related approval-process of Lead record
*/
    @AuraEnabled
    public static List<PRMLeadsOprntyWrapper> getAcceptedLeadData(String workItemId){        
        try{
            //P2OB-5611: Update the lead-record's approval-process to Approved        
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(null);
            req2.setAction(PRMConstants.PRM_Approval_Status);
            req2.setWorkitemId(workItemId);       
            Approval.process(req2);   
        }catch(Exception e){
            System.debug('***Telstra:PRMLeadsOprtntyController:getAcceptedLeadData:Exception'+e.getStackTraceString()+e.getMessage());
            throw new AuraHandledException('Error occurred while accepting the lead.' +e.getMessage());         
        }
        //P2OB-5611: Return updated list of shared-leads, to be displayed in TPC
        return getObjectData('Lead');    
       
    }
    
    /*
*  @JIRA        : P2OB-5611
*  @Description : Method to update lead-record with decline reason and update approvalProcess as 'Rejected'
*  @Parameters  : leadItemData - JSON String of lead-record, selected decline-reason and additional text-content
                : workItemId - ID of related approval-process of Lead record
*/
    
    @AuraEnabled
    public static List<PRMLeadsOprntyWrapper> getDeclinedLeadData(String workItemId, String leadItemData){
      try{
            System.debug('***Telstra:PRMLeadsOprtntyController:getDeclinedLeadData:Input Parameters:Lead'+leadItemData+' WorkItem:'+workItemId);
            //P2OB-5611 : leadDetails are passed by LWC-Component 'declineLeadWithReason'
            Map<String, String> leadDetails = (Map<String, String>)JSON.deserialize(leadItemData,Map<String,String>.class);
            //P2OB-5708: changes start : Update the lead record with decline reasons, passed from LWC-component 
            Lead leadObj = new Lead(id = leadDetails.get('leadrec') , Declined_Reason__c = leadDetails.get('selected'), Declined_Comments__c = leadDetails.get('textEntered'));
            System.debug('***Telstra:PRMLeadsOprtntyController:getDeclinedLeadData:Lead Object to be updated:'+leadObj);
            upsert leadObj;
            //P2OB-5708: changes end
            
            //P2OB-5611: Update the lead-record's approval-process to Rejected
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments(null);
            req2.setAction(PRMConstants.PRM_Rejected_Staus); 
            req2.setWorkitemId(workItemId);
            Approval.process(req2);
           
        }catch(Exception e){
            System.debug('***Telstra:PRMLeadsOprtntyController:getDeclinedLeadData:Exception'+e.getStackTraceString()+e.getMessage());
            throw new AuraHandledException('Error occurred while declining the lead.'+e.getMessage());
        }
        //P2OB-5611: Return updated list of shared-leads, to be displayed in TPC
        return getObjectData('Lead');
    }
    
    
    
    
    
}