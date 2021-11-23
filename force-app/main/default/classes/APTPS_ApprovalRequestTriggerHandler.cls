/*************************************************************************************************************************
 @Name: APTPS_ApprovalRequestTriggerHandler
 @Author: Shishir Bose
 @Created Date: 07/22/2016
 @Descripton: This class is the handler for Approval request trigger
 @Used By: APTPS_ApprovalRequestTrigger
*************************************************************************************************************************/
public with sharing class APTPS_ApprovalRequestTriggerHandler
{
    /*************************************************************************************************************************
     @Name: handleAfterUpdateEvents
     @Author: Shishir Bose
     @Created Date: 07/22/2016
     @Descripton: This method handles all the after update events of Approval request
    *************************************************************************************************************************/
    public void handleAfterUpdateEvents(List<Apttus_Approval__Approval_Request__c> approvalRequestList
                                        , Map<id,Apttus_Approval__Approval_Request__c > mapOldApprovalRequest )
    {
        Map<Id,Id> agreementLegalMap = new Map<Id,Id>();
        for(Apttus_Approval__Approval_Request__c approvalRequest : approvalRequestList)
        { 
		   if((!mapOldApprovalRequest.isEmpty()) 
                && mapOldApprovalRequest.Get(approvalRequest.Id) != null 
                && mapOldApprovalRequest.Get(approvalRequest.Id).Apttus_Approval__Approval_Status__c != 'Approved' 
                && approvalRequest.Apttus_Approval__Approval_Status__c == 'Approved'
                && approvalRequest.Apttus_Approval__Assigned_To_Type__c == 'Queue'
                && approvalRequest.Apttus_Approval__Assigned_To_Link__c.Contains ('Legal Queue')
                )
            {
               //Creating the map of agreements and legal user if the approval request is assigned to legal queue and approved by legal queue user
                agreementLegalMap.put(approvalRequest.Apttus_Approval__Related_Agreement__c, approvalRequest.Apttus_Approval__Actual_Approver__c);
            }
        }
        
        
        updateAgreementLegalUser(agreementLegalMap);
    }
   
    /*************************************************************************************************************************
     @Name: updateAgreementLegalUser
     @Author: Shishir Bose
     @Created Date: 07/22/2016
     @Descripton: This method sets the Legal User field for agreement when 1. The agreement approval is sent to Legal queue and approved 
     by legal queue user
     2. If the agreement does not have legal user assigned
    *************************************************************************************************************************/
    private void updateAgreementLegalUser(Map<Id,Id> agreementLegalMap)
    {
        if(agreementLegalMap.size() == 0)
        {
            return;
        }
       
        Map<Id, Apttus__APTS_Agreement__c> agreementsMap = new Map<Id, Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> agreementsToBeUpdated = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreementRecord;
            
        for(Apttus__APTS_Agreement__c agreement : [select Id, APTPS_Legal_User__c from Apttus__APTS_Agreement__c where Id in : agreementLegalMap.keySet()])
        {
            agreementsMap.put(agreement.Id, agreement);
        }
        
        if(agreementLegalMap.size() > 0)
        {
            for(Id agreementId : agreementLegalMap.keySet())
            {
                agreementRecord = agreementsMap.get(agreementId);
                if(agreementRecord != null && agreementRecord.APTPS_Legal_User__c == null)
                {
                    agreementRecord.APTPS_Legal_User__c = agreementLegalMap.get(agreementId);
                    agreementRecord.APTPS_Is_Custom_Update__c = true;
                    agreementsToBeUpdated.add(agreementRecord);
                }
            }
        }
        
        
        if(agreementsToBeUpdated.size() > 0)
        {
            update agreementsToBeUpdated;
            for(Apttus__APTS_Agreement__c agmt : agreementsToBeUpdated){
                agmt.APTPS_Is_Custom_Update__c = false;
            }
            update agreementsToBeUpdated;
        }
    }
 
}