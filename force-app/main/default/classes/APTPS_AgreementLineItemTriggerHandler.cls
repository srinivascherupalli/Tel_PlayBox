//description: Handler class for APTPS_AgreementLineItemTrigger
//createdDate: 22-02-2019
//author: Kunal Dixit
//usedBy: APTPS_AgreementLineItemTrigger
//JIRA : EDGE-63495
//-----------------------------------------------------------------------------------------------------
public with sharing class APTPS_AgreementLineItemTriggerHandler {
	
    public void beforeDeleteEvent(List<Apttus__AgreementLineItem__c> relatedAgmtLineItems){
        
        Map<Id,Apttus__AgreementLineItem__c> parentIdMap=new Map<Id,Apttus__AgreementLineItem__c>();
        APTPS_AgreementLineItemTriggerService aliTriggerService=new APTPS_AgreementLineItemTriggerService();
        for(Apttus__AgreementLineItem__c lineItem:relatedAgmtLineItems){
            if(lineItem.Apttus__AgreementId__c !=null){
                parentIdMap.put(lineItem.Apttus__AgreementId__c,lineItem);
            } 
        }
        if(!parentIdMap.isEmpty()) {
            aliTriggerService.beforeDeleteValidation(parentIdMap);
        }
    }
}