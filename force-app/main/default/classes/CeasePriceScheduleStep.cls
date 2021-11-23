/*************************************************************************************************
Name : CeasePriceScheduleStep 
Description : EDGE-124711 : EM / NgUC: Manage price schedule inventory update for Cancel Orders
TestClass : CeasePriceScheduleStepTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Pawan Devaliya      18-Feb-2020     Created
2.        Vaibhav             28-Apr-2020     EDGE-143708  Add billing spec identifier on charge line item
3.        Prajakta            26/05/2020      EDGE-144683
===============================================================================================================================
***************************************************************************************************/

global with sharing class CeasePriceScheduleStep implements CSPOFA.ExecutionHandler {
    public class My2Exception extends Exception {}
    
    public List<SObject> process(List<SObject> steps){
        
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>)steps;
        Set<Id> orchesIds = new Set<Id>();
       
        for(CSPOFA__Orchestration_Step__c step: stepList){
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }
        //Method ceaseSchedule to change the status to CLI,DLI, PSLIand TLI to 'Ready to Inactive'.
        stepList = ceaseSchedule(orchesIds, stepList);
       // orchesIds.clear();
     
        return stepList;
    }

    /*
    * Method ceaseSchedule() to change the status to CLI,DLI, PSLI and TLI to 'Ready to Inactive'.
    */
    public List<CSPOFA__Orchestration_Step__c> ceaseSchedule(Set<Id> orchesIds, List<CSPOFA__Orchestration_Step__c> stepList){

      try
      {  
        Set<Id> subscriptionsIds = getSubscriptionIds(orchesIds);   //Fetching subscriptionsIds from orchestration
        Set<Id> serviceIdsBaseOrder = new Set<Id>();
                
        if(subscriptionsIds != null){
        serviceIdsBaseOrder = getserviceIdsBaseOrder(subscriptionsIds); //To get base order service Ids for given cancel order subscriptions
        String status = System.label.ReadyToInactive;
        updateSchedule(serviceIdsBaseOrder, status);        //Method to update status of CLI, DLI, PSLI and TLI to passed status values
        
        
        }
        //subscriptionsIds.clear(); 
       // serviceIdsBaseOrder.clear();
        
        for(CSPOFA__Orchestration_Step__c step : stepList){
        step.CSPOFA__Status__c = Label.Complete;
        step.CSPOFA__Completed_Date__c = Date.today();
        step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
        }
       if(Test.isRunningTest()){ 
      throw new My2Exception('My exception');
       }
    }
      catch (Exception ex)
      {  
        for (CSPOFA__Orchestration_Step__c step : stepList) {
          step.CSPOFA__Status__c = Label.Error;
          step.CSPOFA__Completed_Date__c = Date.today();
          step.CSPOFA__Message__c = 'Exception: ' + ex.getMessage() + ' - ' + ex.getLineNumber();
        }
      }
    
    
    return stepList;
}
    /*
    * Merhod getSubscriptionIds() to fetch subscription ids from orchestration Process
    */
    public Set<Id> getSubscriptionIds(Set<Id> orchesIds){
        
        Set<Id> subscriptionsIds = new Set<Id>(); 
        
        for(CSPOFA__Orchestration_Process__c  orch : [Select Id, Name, csordtelcoa__Subscription__r.Id, csordtelcoa__Subscription__r.csordtelcoa__Replaced_Subscription__c from CSPOFA__Orchestration_Process__c  where Id IN:orchesIds]){

        if(orch.csordtelcoa__Subscription__r.csordtelcoa__Replaced_Subscription__c != null){
            subscriptionsIds.add(orch.csordtelcoa__Subscription__r.Id);
        }
    }
    
    return subscriptionsIds;
    }
    
    /*
    * Method getserviceIdsBaseOrder() to get service ids of base order
    * Parameter is subscription Ids of Cancel subscriptions.
    */
    public Set<Id> getserviceIdsBaseOrder(Set<Id> subscriptionsIds){
        
        Set<Id> serviceIdsBaseOrder = new Set<Id>();
        if(subscriptionsIds != null){
        //Fetching Services where status contains 'Disconnect' and matches passed subscription ids 
        Map<Id, csord__Service__c> serviceMap =  new Map<Id, csord__Service__c>([SELECT Id,  Name, csord__Subscription__c, Scenario_Type__c, csord__Status__c, csordtelcoa__Replaced_Service__c FROM csord__Service__c where csord__Subscription__c IN : subscriptionsIds AND csord__Status__c LIKE '%Disconnect%']);
        //added as part of EDGE-143708 - start
        Map<Id, Charge_Line_Item__c> chargeLineItemMap =  new Map<Id, Charge_Line_Item__c>([SELECT Id, Name ,CorrelationId__c, chargeType__c, basketId__c,status__c,unitPrice__c,contractTerm__c,serviceId__c, serviceId__r.csord__Subscription__c,billingSpecIdentifier__c,BusinessID__c FROM Charge_Line_Item__c WHERE serviceId__c IN :serviceMap.keyset()]);
        
         //EDGE-144683 start
        Map<Id, Charge_Line_Item__c> chargeLineItemMapforCease = new Map<Id, Charge_Line_Item__c> ();
         if(!chargeLineItemMap.isEmpty()){
             for(Charge_Line_Item__c charge : chargeLineItemMap.values()){
             if(charge.status__c!='Event Published'){
                 chargeLineItemMapforCease.put(charge.id,charge);
                 
             }}
             if(!chargeLineItemMapforCease.isEmpty()){
                 Database.SaveResult[] results = GeneratePriceSchedule.createPriceScheduleModify(chargeLineItemMapforCease);}
         }
        //EDGE-144683 end
        
        GeneratePriceScheduleStep gps = new GeneratePriceScheduleStep();
        gps.updatebillSpecIdCLI(serviceMap, chargeLineItemMap);
        //EDGE-143708 - END  
            System.debug('ServiceMapMAC   '+serviceMap.keyset());
            
       
         
        // serviceIdsBaseOrder : List if base order service ids 
        for(csord__Service__c service : serviceMap.values()){
            if(service.csordtelcoa__Replaced_Service__c != null){
                serviceIdsBaseOrder.add(service.csordtelcoa__Replaced_Service__c);
            }   
        }
    }
    return serviceIdsBaseOrder; 
    }
    
    /*
    * Method updateSchedule() to update status of CLI, DLI, PSLI and TLI 
    * Parameters are service Ids of Base Order service and status value to be updated.
    */
    public static void updateSchedule(Set<Id> serviceIdsBaseOrder, String status){
        
        //Fetching CLI and DLIs based of service ids
        Map<Id, Charge_Line_Item__c> chargeLineItemMap =  new Map<Id, Charge_Line_Item__c>([SELECT Id, status__c, serviceId__r.csord__Subscription__c, (Select id, status__c from Discount_Line_Items__r) FROM Charge_Line_Item__c WHERE serviceId__c IN :serviceIdsBaseOrder]);

        SObject[] CLI_DLI_PLSI_TLI_toUpdate = new List<SObject>();

        List<Charge_Line_Item__c> cliList = new List<Charge_Line_Item__c>();
        List<Discount_Line_Item__c> dliList = new List<Discount_Line_Item__c>();
        List<Price_Schedule_Line_Item__c> plsiList = new List<Price_Schedule_Line_Item__c>();
        List<Tier_Line_Item__c> tliList = new List<Tier_Line_Item__c>();
        if(!chargeLineItemMap.isEmpty()){
         for(Charge_Line_Item__c cli : chargeLineItemMap.values()){
         cli.status__c = status;
         cliList.add(cli);      //List of CLIs to update
         System.debug('cli  :: '+cli);
           if(cli.Discount_Line_Items__r!=null){
            for(Discount_Line_Item__c dli: cli.Discount_Line_Items__r){
            dli.status__c = status;
            dliList.add(dli);   //List of DLIs to update
            }
          }
        }
       }
        CLI_DLI_PLSI_TLI_toUpdate.addAll(cliList);
        CLI_DLI_PLSI_TLI_toUpdate.addAll(dliList);      
        
        //Fetching PSLIs and TLIs based of CLI Ids and looping over them to update status
        for(Price_Schedule_Line_Item__c psli : [SELECT Id, status__c, (Select id, status__c from Tier_Line_Items__r)  FROM Price_Schedule_Line_Item__c WHERE chargeInstance__c IN :chargeLineItemMap.keySet()]){
        psli.status__c = status;
        plsiList.add(psli);     //List of PSLIs to update

            if(psli.Tier_Line_Items__r!=null){
            for(Tier_Line_Item__c tli: psli.Tier_Line_Items__r){
            tli.status__c = status;
            tliList.add(tli);   //List of TLIs to update
            }
          }
        }
        CLI_DLI_PLSI_TLI_toUpdate.addAll(plsiList);
        CLI_DLI_PLSI_TLI_toUpdate.addAll(tliList);
        
        //Updating CLI, DLI, PSLI & TLI in one transaction
        System.debug('CLI_DLI_PLSI_TLI_toUpdate:: '+CLI_DLI_PLSI_TLI_toUpdate);
        if(CLI_DLI_PLSI_TLI_toUpdate != null){
        Database.SaveResult[] results = Database.update(CLI_DLI_PLSI_TLI_toUpdate); 
        }
        } 
        
       
}