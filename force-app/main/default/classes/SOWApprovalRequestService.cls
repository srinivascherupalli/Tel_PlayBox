/*****************************************************************
@Name: SOWApprovalRequestService
@Author: Ravi Shankar
@JIRA Reference: EDGE-136074
@CreateDate: 11/03/2020
@Description: This class is used for invoking SOW Approval Process
******************************************************************/
public without sharing class SOWApprovalRequestService {
    @AuraEnabled
    public static map<string,string> submitAndProcessApprovalRequest(String sowId) {
        System.debug('recordId:'+ sowId);
        Id user1 = UserInfo.getUserId();
        boolean isAutoApproved = true;
        boolean isError = false;
        map<string,string> resMap = new map<string,string>();
        resMap.put('Result', '');
        resMap.put('Reason', '');
        System.debug('Total Number of records that can be queried  in this apex code context: ' +  Limits.getLimitDmlRows());
        System.debug('Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        List<SOW_Items__c> sowItems = [SELECT Id, sow__r.Status__c, Approval_Required__c, Included__c 
                                       FROM SOW_Items__c WHERE Included__c = TRUE AND sow__c = :sowId];
        if(sowItems.size()>0){
            if(sowItems[0].sow__r.Status__c == 'Approval Requested'){                
                isError = true;
                resMap.put('Reason', 'SOW Approval is already requested.');
            }
            else if(sowItems[0].sow__r.Status__c == 'Approved'){
                isError = true;
                resMap.put('Reason', 'SOW is already approved.');
            }
        }
        else{
            isError = true;
            resMap.put('Reason', 'You must select a deliverable');         
        }
        if(isError){
            resMap.put('Result', 'Error');
        }
        else{
            try{
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(sowId);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(user1);
            
            // Submit the record to specific process and skip the criteria evaluation
            //Commented Part of  INC000094478176,EDGE-166250 for Offer Specific Approvers for Professional Service Offers
            //req1.setProcessDefinitionNameOrId('SOW_Approval_Process');
            req1.setSkipEntryCriteria(false);
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            if(result.isSuccess()){
                resMap.put('Result', 'Success');
                resMap.put('Reason', 'Services for inclusion submitted for approval');
            }
            else{
                resMap.put('Result', 'Error');
                resMap.put('Reason', 'Error occurred while submitting the SOW for Approval. Please check with administrator');
            }
            }catch(Exception e){
                resMap.put('Result', 'Error');
                resMap.put('Reason', e.getMessage());
            }
        }
        return resMap;
    }
    
    @AuraEnabled(cacheable=true)
      public static List<SOW_Items__c> fetchsows(String recordId) {
        List<SOW_Items__c> sowitemList = [SELECT Id,Comment__c,Description__c,name,Included__c,Sequence__c from SOW_Items__c where sow__r.Id=:recordId order by Sequence__c asc ];
        return sowitemList;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<Clauses__c> getDeliverables(String recordId){
        
        List<Clauses__c> clausesList = new List<Clauses__c>();
         SOW_Items__c sowItem = [SELECT Id,Comment__c,Description__c,name,Included__c,Sequence__c from SOW_Items__c where  Id=:recordId];
        if(sowItem.Sequence__c != null)
        {
        clausesList= [select id,Description__c,Comment__c from Clauses__c where ParentId__r.Sequence__c= :sowItem.Sequence__c];
        }
        return clausesList;
    }
}