/****************************************************************************
@Name: OrlandoFLITriggerHandler.
@Author: Orlando/Purushottam
@Sprint 20.01 [EDGE-128934]
@CreateDate: 01/18/2020.
@Description: This Class is for Fulfillineitem Trigger 
Note : Implemented Trigger FrameWork 
********************************************************************************/
public  without sharing class OrlandoFLITriggerHandler  extends ATF_AbstractDomainHandler {
    
    public override void handleBeforeUpdate (Map<id,SObject> oldTagetsObjectMap){
        Map<Id, FulfillmentLineItem__c> fulfillmentLineMap = new Map<Id, FulfillmentLineItem__c>([select id,(select id,Tenancy_ID__c FROM Functional_Contact_Roles__r) FROM FulfillmentLineItem__c WHERE id IN :Trigger.new]);
        
        Map<Id, List<Functional_Contact_Role__c>> FunctionalCntctRoleMap= new Map<Id, List<Functional_Contact_Role__c>>();
        for(FulfillmentLineItem__c fli:fulfillmentLineMap.values() ){
		List<Functional_Contact_Role__c> FunctionalCntctRoleList= new List<Functional_Contact_Role__c>();
		for(Functional_Contact_Role__c fcr: fli.Functional_Contact_Roles__r){
				if(fcr.Tenancy_ID__c != null)
				FunctionalCntctRoleList.add(fcr);
			}
			if(FunctionalCntctRoleList.size() != 0)
			FunctionalCntctRoleMap.put(fli.id, FunctionalCntctRoleList);
        }
        
        for(FulfillmentLineItem__c targetRec:(List<FulfillmentLineItem__c>) trigger.new)
        {	 FulfillmentLineItem__c fromQuery = fulfillmentLineMap.get(targetRec.Id);
         if( targetRec.Status__c=='Completed' && fromQuery.Functional_Contact_Roles__r.size()!=0 && FunctionalCntctRoleMap.values().size()==0){
             targetRec.addError('Function Contact Role Subscription Tenancy or Network Service ID is required for this Case.');
         }
        }
    }    
}