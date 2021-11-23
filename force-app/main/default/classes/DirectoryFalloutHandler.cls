/**************************************************************
Name: DirectoryFalloutHandler
Description: Class to Implement the error handling/fallback scenarios for Directory Management Interface
Story Number: EDGE-49676
**************************************************************/

global with sharing class DirectoryFalloutHandler {
    
    global class FailedDirectoryListing implements CSPOFA.ExecutionHandler{
        public List<SObject> process(List<SObject> steps){
            List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
            
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
            List<Id> orderIds = new List<Id>();
            List<Id> orchesIds= new List<Id>();
            for(CSPOFA__Orchestration_Step__c step: stepList)
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            
            system.debug(orchesIds);
            List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
            System.debug('orchList ::'+orchList);
            for(CSPOFA__Orchestration_Process__c  orch : orchList)
                orderIds.add(orch.Order__c);
            
            system.debug('orderIds ::'+orderIds);
            
             DirectoryFalloutNumbers(orderIds);
            for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = Label.Complete;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
                result.add(step);
            }
            Return result;
        }
        
        public Map<String,Map<String,String>> DirectoryFalloutNumbers(List<Id> orderIds){
            
            List<csord__Order__c> orderList = [select id,csord__Order_Number__c from csord__Order__c where id In : orderIds];
            List<String> orderNumber = new List<String>();
             Map<String,Map<String,String>> fnnmap = new Map<String,Map<String,String>>();
            for(csord__Order__c ord :orderList)
            {   
                orderNumber.add(ord.csord__Order_Number__c);
            }
            System.debug('orderNumber::' + orderNumber);
            
            List<ApplicationLog__c> appLogList = [Select Id,Status_Code__c,Reference_Info__c,CAC__c,Request_Message__c,Message__c,createdDate from ApplicationLog__c where Reference_Info__c = 'SingleFNNListingHandler' AND CAC__c IN : orderNumber];
            
           
            Map<String,String>fnndetailsMap = new Map<String,String>();
            List<String> successStatusCodeList= new List<String>();
            List<String> failedStatusCodeList= new List<String>();
            for(ApplicationLog__c log :appLogList){
                
                EDISSingleRequestDTO edisSingleDTO = EDISSingleRequestDTO.parse(log.Request_Message__c);
                if(log.Status_Code__c == '200'){
                    successStatusCodeList.add(edisSingleDTO.data.listingDetails.listingFNN);
                }
                //System.debug(' successStatusCodeList::' + successStatusCodeList);
                else
                {failedStatusCodeList.add(edisSingleDTO.data.listingDetails.listingFNN);}
                
                for(String failedNum :failedStatusCodeList){
                    if(edisSingleDTO.data.serviceOrderDetails.orderID != NULL ){
                    
                    if(! successStatusCodeList.contains(failedNum))
                    {   
                        fnndetailsMap.put('listingFNN',edisSingleDTO.data.listingDetails.listingFNN);
                        fnndetailsMap.put('orderID',edisSingleDTO.data.serviceOrderDetails.orderID);
                        fnndetailsMap.put('type',edisSingleDTO.data.type);
                        fnndetailsMap.put('listCode',edisSingleDTO.data.serviceOrderDetails.listCode);
                        fnndetailsMap.put('order',orderList[0].id);
                        fnnmap.put(failedNum,fnndetailsMap);
                    }
                    
                }
                    
                }
               
            }
           
            System.debug('fnnmap::' + fnnmap);
        
        return fnnmap;
      }
    }   
    
    global class ResendFailedDirectoryListing implements CSPOFA.ExecutionHandler{
        
        public List<SObject> process(List<SObject> steps){
            List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
            
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
            List<Id> orderIds = new List<Id>();
            List<Id> orchesIds= new List<Id>();
            for(CSPOFA__Orchestration_Step__c step: stepList)
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            
            system.debug(orchesIds);
            List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
            System.debug('orchList ::'+orchList);
            for(CSPOFA__Orchestration_Process__c  orch : orchList)
                orderIds.add(orch.Order__c);
            
            system.debug('orderIds ::'+orderIds);
            resendFailedDirectoryList(orderIds);
             
            for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = Label.Complete;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
                result.add(step);
            }
            Return result;
        }
         public void resendFailedDirectoryList( List<Id> orderIds){
            Map<String,Map<String,String>> failedFnnMap = new Map<String,Map<String,String>>();
            DirectoryFalloutHandler.FailedDirectoryListing  failedDir = new DirectoryFalloutHandler.FailedDirectoryListing();
             failedFnnMap =failedDir.DirectoryFalloutNumbers(orderIds);
             //EDISSingleManager.buildEDISForFailedNumbers(failedFnnMap);
             EDISSingleManagerUsingNumber.buildEDISForFailedNumbers(failedFnnMap); //EDGE-117567
             
             
    }
}
}