/*****************
Author: Kunal Dixit
Company: Telstra
Description:April 2,2019 
EDGE-77677 changes to reflect CPE delivery date in payload for PRM order
to see changes made, refer development tab in Jira
History : Manish Jha 10-01-2019
Sr.No.    Developer Name          Date          Story Description
1.        Rohit  Tripathi       24/10/2019     EDGE-118261 --> Create Order in First Wave failed with System_Error
2.        Vaibhav Deshpande     03/01/2020     EDGE-124891  -  Refactor Orchestration Processes 
3.        Vaibhav Deshpande     03/06/2020     EDGE-121235    Remove CPE Delivery Date for all product offers
*************/

global with sharing class UpdateSpecificationAttachments implements CSPOFA.ExecutionHandler {
    public class My2Exception extends Exception {}
    public List<sObject> process(List<sObject> data){
        List<Id> orchesIds= new List<Id>();
       // List<sObject> result = new List<sObject>(); EDGE-124891 - commented as part of refactoring
        Set<Id> oppIdSet = new Set<Id>();
        set<Id> accountIdSet =  new set<Id>();
        List<Id> oppIdList = new List<Id>();
         //commented as part of EDGE-121235 
        //List<Id> serviceIds = new List<Id>();
        //List<Id> ordRequestIds=new List<Id>();
        List<Id> ordIds=new List<Id>();
        //commented as part of EDGE-121235 
       // List<csord__Subscription__c> subsList=new List<csord__Subscription__c>();
        //boolean isOpportunity = false;

		Map<Id,String> scenerioTypeServiceMap = new Map<Id,String>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
		try{ //EDGE-124891 - added try - catch block as part of refactoring
        for(CSPOFA__Orchestration_Step__c step: stepList)
        {
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }
        for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c,
                                                      Order__r.csord__Order_Request__c,
                                                      Order__r.csordtelcoa__Opportunity__c, 
                                                      Order__r.csord__Account__c,
                                                      Order__r.id
                                                      ,Order__r.Scenario_Type__c 
                                                      from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
        {
             //EDGE-124891 - commented code as part of refactoring
		    /*if(orch.Order__r.csordtelcoa__Opportunity__c == null){
                isopportunity = true;}
                else{*/ 
                
            if(orch.Order__r.csordtelcoa__Opportunity__c != null){
            //isOpportunity = true;
            oppIdSet.add(orch.Order__r.csordtelcoa__Opportunity__c);
			accountIdSet.add(orch.Order__r.csord__Account__c);
			//ordRequestIds.add(orch.Order__r.csord__Order_Request__c);
			ordIds.add(orch.Order__r.id);
            }
        }
		if(!oppIdSet.isEmpty()){  //EDGE-124891 - added check if oppIdSet set is not empty then only execute below code block
        for(csord__Service__c serviceObj: [SELECT Id,Scenario_Type__c from csord__Service__c WHERE csord__Order__r.id IN : ordIds and Scenario_Type__c!= 'TRANSITION']){
			scenerioTypeServiceMap.put(serviceObj.Id,serviceObj.Scenario_Type__c);
			//serviceIds.add(serviceObj.Id);  commented as part of EDGE-121235 

        }
        
        oppIdList.addAll(oppIdSet);
		
        //if(!oppIdList.isEmpty()){ //EDGE-124891 - commented as part of refactoring
         //code commented as part of EDGE-121235
	    /*if(!ordRequestIds.isEmpty()){  //EDGE-124891 - added isEmpty check for ordRequestIds set
        for(csord__Subscription__c subscription:[select Id from csord__Subscription__c where csord__order__r.csord__Order_Request__c IN : ordRequestIds and site__c!=null ]){
			subsList.add(subscription);
			///EDGE-124891 - commented as part of refactoring 
            //CPEDeliveryDateHelper.modifyCPEDeliveryDate(subscription.Id); //for EDGE-77677/
        }
       }*/
       
       //code commented as part of EDGE-121235
	   /* if(!subsList.isEmpty()) //EDGE-124891 - added isEmpty check and removed above method callout from SOQL for loop
		{
			CPEDeliveryDateHelper.modifyCPEDeliveryDate(subsList);
		}*/
	   
	   
        // Need to write logics for compelete step and OR confition for chaneg of mobile number,Suspend,resume
		// Change 1 -> EDGE-118261 Removed the wrong scenerioTypeServiceMap check
			if(scenerioTypeServiceMap != null && scenerioTypeServiceMap.keySet() != null && !oppIdList.isEmpty() ){	
                
                EDMRelationshipService_V2.createRelationShip(oppIdList);
				UpdateFixedSeatCountOnIPNetwork.getTotalFixedUsersOnAccount(accountIdSet, oppIdSet);
				//CPEDeliveryDateUpdateForMAC_V2.addCPEAttr(serviceIds);  //code commented as part of EDGE-121235
                

            }
		}
        for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Complete;
            step.CSPOFA__Completed_Date__c=Date.today();
            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
            //result.add(step); EDGE-124891 - commented as part of refactoring
        }
            if(Test.isRunningTest()){ 
                throw new My2Exception('My exception');
          }
		}catch(Exception ex) { 
		   for (CSPOFA__Orchestration_Step__c step : stepList) 
		   { 
			step.CSPOFA__Status__c = 'Error'; 
			step.CSPOFA__Completed_Date__c = Date.today(); 
			step.CSPOFA__Message__c = 'Exception: ' + ex.getMessage() + ' - ' + ex.getLineNumber(); 
			} 
		}
		
        return stepList;
    }
    
}