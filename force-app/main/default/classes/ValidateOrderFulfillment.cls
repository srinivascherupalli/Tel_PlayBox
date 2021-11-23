/**
 * This class is written for story EDGE-118623.
* This class is used in Order Fulfillment Orchestraction Process.
* @JIRA STORY : EDGE-118623
**/
//Purushottama Sahu: 29/04/2020  EDGE-137134  Added fflib_SObjectUnitOfWork Framework in ManualFulfillment

global with sharing class ValidateOrderFulfillment implements CSPOFA.ExecutionHandler{

    public List<sObject> process(List<sObject> data){
    
        List<Id> orderIds = new List<Id>();
        List<Id> orchesIds= new List<Id>();
        Map<Id,String> scenerioTypeOrderMap = new Map<Id,String>();
        //List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
       system.debug('stepList+' +stepList);
        try{ 
        

        for(CSPOFA__Orchestration_Step__c step: stepList){
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);    
        }

            system.debug('orchesIds+' +orchesIds);
        //get the Order Id from the orchestraction Process
        List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Service__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
        system.debug('orchList+' +orchList);
        for(CSPOFA__Orchestration_Process__c  orch : orchList){
           orderIds.add(orch.Order__c);
        }
        
            system.debug('orderIds+' +orderIds);
        // Call Fulfillment case for the orders , Update the Specification_c =TRUE if "SOMOPENAIR" in the basket configration
        ManualFulfillment manualFulfillment = new ManualFulfillment();
        List<csord__Subscription__c> subscriptionList =  manualFulfillment.getSubscriptionByOrderId(orderIds);
        system.debug('subscriptionList+' +subscriptionList);
            manualFulfillment.isFulfillmentRequired(subscriptionList);
        manualFulfillment.fulfillmentByCASE(subscriptionList);
       manualFulfillment.updateRTSAdaptive(subscriptionList); //DPG-1914: Update RTS for Adaptive Care
        manualFulfillment.commitWork();//EDGE-137134 >> +
         manualFulfillment.processAdaptiveCare(subscriptionList);//DPG-1914: Update RTB for Managed service
     
      for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = Label.complete;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
                //result.add(step);
            }
      }catch(Exception e){
        for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c =  Label.Error;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = e.getMessage();
                //result.add(step);
            }
      }
        return stepList;
        
    }
  
/**************************************  
Name:  updateTenancyId
Description: Update Tenancy Id for MS & PS with TMDM 
Stor: DPG-2579
Author: Ila
/******************************************/ 
    @InvocableMethod
    public static void updateSubsForPSFulfillment(List<String> param) {
        /*
        List<String> parameter = param[0].split(':::');
            String orderId;
        	String subIdPS;
        
            if(parameter != null){
                orderId = parameter[0];
                subIdPS = parameter[1];
            }
        List<csord__Subscription__c> subsList=new List<csord__Subscription__c>();
        system.debug('orderId' +orderId);
        system.debug('subIdPS' +subIdPS);
        Boolean flag;
        Set<Id> psSet = new Set<Id>();
        Boolean individualFlag =false;

        
        if(orderId!=null){
        subsList=[Select Id,MarketableOffer__r.Offer_ID__c from csord__Subscription__c where csord__Order__c=:orderId];
        }
            system.debug('subsList' +subsList);
        if(!subsList.isEmpty()){
        for(csord__Subscription__c sub: subsList){
            system.debug('sub.MarketableOffer__r.Offer_ID__c' +sub.MarketableOffer__r.Offer_ID__c);
            if(sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000854'){ //Check for MS 
                
                flag=true;
            }
            if(sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000750'){
                psSet.add(sub.id);
            }
        }
        if (flag==true){
            List<csord__Subscription__c> subscription = [Select Id, csord__Status__c,triggerBill_RTB__c from csord__Subscription__c where Id IN: psSet];
            for(csord__Subscription__c subs:subscription){
            if(subs.csord__Status__c!='Provisioned' && subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent'){
                subs.csord__Status__c = 'Provisioned';
                subs.triggerBill_RTB__c=true;
                individualFlag=true;

            }
            
            } 
           update subscription;
            
            for(csord__Subscription__c subs:subscription){
            if(individualFlag=true && subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent'){
                subs.csord__Status__c = 'Provisioned';
                subs.triggerBill_RTB__c=true;
            	}
            
            } 
           update subscription;
            
            
        }
    }*/
    }
    
 /**************************************  
Name:  FlowInputs
Description: Get OrderId and TenancyID from ProcessBuilder 
Stor: DPG-2579
Author: Ila
/******************************************/ 
     /*  public class FlowInputs{
    
        @InvocableVariable
        public String ordId;
        
        @InvocableVariable
        public String subId;
        
    }   */

}