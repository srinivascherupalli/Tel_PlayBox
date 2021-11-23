/*****************************************************************************
@Author: Pravin Sonawane
@CreateDate: 03-Jun-2019
@ModifiedByandDate: 
@Description: This class contains logic which will get called when Omni Channel User gets active and at the same time salesSupport record and its associated sales
child support records will get assigned to him/her.
@References
Epic :EDGE-83268 P2O: Sales Support - Certitude
Story:EDGE-87291 Certitude, Sales Support - Queues & Direct Align Assignment 
*******************************************************************************/
public without sharing class salesup_CertitudeAgentWorkTriggerHandler {
    
    /**
    * This method will get called from Process builder - soc resolve Opportunity Access
    * Pravin S :: EDGE-87291 :: 04-Jun-2019
    */
    @InvocableMethod
    public static void handleRequest(List<Id> workItemIds) {
        system.debug('InvocableMethod>>>>handleRequest');
       // system.debug(workItemIds);
        if(workItemIds != null && workItemIds.size() > 0){
          //  if(String.valueOf(workItemIds[0].getSobjectType())=='Case'){
               //resolveAccesses(workItemIds);              
           // }
        }
    }
    
    
    /**
    * Sales Support and its associated Sales child Support requests get assigned to active omni channel User (Basically Owner of Sales Support request)
    * Pravin S :: EDGE-87291 :: 04-Jun-2019
    */
    /*
    public static void resolveAccesses(List<Id> caseIdLIst){
        List<Case> lstSalesSupportRequests = [Select Id,OwnerId,RecordTypeId,RecordType.DeveloperName,(Select Id,OwnerId,Status From Cases) From Case Where (Id IN :caseIdLIst AND RecordType.DeveloperName = 'salesup_Sales_Support')];
        
        List<Case> lstChildSupportCasesToUpdate = new List<Case>();
        
        if(lstSalesSupportRequests != null && lstSalesSupportRequests.size() > 0){
            for(Case salesSupport : lstSalesSupportRequests){
                for(Case childSupport : salesSupport.Cases){
                    system.debug('childSupport==>'+childSupport.Status);
                    if(childSupport.Status != 'Withdrawn' && childSupport.Status != 'Rejected' && childSupport.Status != 'On Hold' && childSupport.Status != 'Closed'){
                        childSupport.OwnerId = salesSupport.OwnerId;
                        lstChildSupportCasesToUpdate.add(childSupport);
                    }
                }
            }
        }
        
        if(lstChildSupportCasesToUpdate.size() > 0){
            update lstChildSupportCasesToUpdate;
        }        
        
    }
    */

}