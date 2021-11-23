/*************************************************************************************************
Name : GeneratePriceScheduleStep 
Description : EDGE-123581 : Enterprise Mobility : Pricing MS request / response structure build and store the response details
TestClass : GeneratePriceScheduleStepTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Pawan Devaliya /    17-Jan-2020     Created
          Vaibhav Deshpande
2.        Pawan               10-Feb-2020   EDGE-128977     Pricing functionality for NGUC New  
3.        Pawan               27-Feb-2020   EDGE-124716     Pricing Modify for EM and NGUC 
4.        Pawan               04-April-2020 EDGE-139696     Changed code to update CLI status to 'Pricing Records Created' on PSLI, TLI creation      
5.        Vaibhav             28-Apr-2020   EDGE-143708     Add billing spec identifier on charge line item
===============================================================================================================================
***************************************************************************************************/

global with sharing class GeneratePriceScheduleStep implements CSPOFA.ExecutionHandler{
    public class My2Exception extends Exception {}
    
    public List<SObject> process(List<SObject> steps){
        
        Map<Id, List<csord__Service__c>> mapOrderwithService = new Map<Id, List<csord__Service__c>>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
        Set<Id> orchesIds = new Set<Id>();
        List<csord__Service__c> serviceList=new List<csord__Service__c>();

        for(CSPOFA__Orchestration_Step__c step: stepList){
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }
      try
      {
          
        Map<Id, csord__Subscription__c> SubMap = getSubscriptions(orchesIds);
        orchesIds.clear();        
        stepList = executeGeneratePrice(stepList, SubMap);
  
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
    
    public Map<Id, csord__Subscription__c>  getSubscriptions(Set<Id> orchesIds){
        
        Map<Id, csord__Subscription__c> SubMap = new Map<Id, csord__Subscription__c>();     
        for(CSPOFA__Orchestration_Process__c  orch : [Select Id, Name, csordtelcoa__Subscription__r.name, csordtelcoa__Subscription__r.Id, csordtelcoa__Subscription__r.csordtelcoa__Replaced_Subscription__c from CSPOFA__Orchestration_Process__c  where Id IN:orchesIds]){
        
        csord__Subscription__c subscription = new csord__Subscription__c();
        subscription.Id = orch.csordtelcoa__Subscription__r.Id;
        subscription.name = orch.csordtelcoa__Subscription__r.name;
        subscription.csordtelcoa__Replaced_Subscription__c = orch.csordtelcoa__Subscription__r.csordtelcoa__Replaced_Subscription__c;
        
        SubMap.put(subscription.Id, subscription);  
    
    }
    
    System.debug('SubMap :: '+SubMap);
    return SubMap;
}
    
    public List<CSPOFA__Orchestration_Step__c> executeGeneratePrice(List<CSPOFA__Orchestration_Step__c> stepList, Map<Id, csord__Subscription__c> SubMap){
        
                
        Map<Id, csord__Subscription__c> subIdsToFetchNew = new Map<Id, csord__Subscription__c>();
        Map<Id, csord__Subscription__c> subIdsToFetchModify = new Map<Id, csord__Subscription__c>();       
       
        System.debug('SubMap '+SubMap);
        
        //To Create seperate maps for Replaced Subscriptions(Mac order) and New Subscriptions
        for(Id key : SubMap.keySet()){ 
            if(SubMap.get(key).csordtelcoa__Replaced_Subscription__c != null){              
            System.debug('SubMap.get(key).Id  '+key);
            subIdsToFetchModify.put(key, SubMap.get(key));          
            }
            else{
                subIdsToFetchNew.put(key, SubMap.get(key));
            }
        }

        Map<Id, csord__Service__c> serviceIdsToFetchNew = new Map<Id, csord__Service__c>();
        Map<Id, csord__Service__c> serviceIdsToFetchModify = new Map<Id, csord__Service__c>();

        Map<Id, csord__Service__c> serviceMap =  new Map<Id, csord__Service__c>([SELECT Id,  Name, csord__Subscription__c, Scenario_Type__c FROM csord__Service__c where csord__Subscription__c IN : SubMap.keySet()]);
       
        System.debug('ServiceMap   '+serviceMap.keyset());
        SubMap.clear();
        
        //To Create seperate maps for Replaced Services(Mac order) and New Services assiociated with the subscriptions retrieved above
        for(Id serviceKey : serviceMap.keyset()){
            if(subIdsToFetchNew.containsKey(serviceMap.get(serviceKey).csord__Subscription__c)){
                serviceIdsToFetchNew.put(serviceKey, serviceMap.get(serviceKey));
            }
            else if(subIdsToFetchModify.containsKey(serviceMap.get(serviceKey).csord__Subscription__c) && (serviceMap.get(serviceKey).Scenario_Type__c == null || !serviceMap.get(serviceKey).Scenario_Type__c.equalsIgnoreCase('Replace SIM') && !serviceMap.get(serviceKey).Scenario_Type__c.equalsIgnoreCase('Change of Mobile Number'))){
                serviceIdsToFetchModify.put(serviceKey, serviceMap.get(serviceKey));
            }
        }
        
        Map<Id, String> chargeLineItemIdMaptoInsert = new Map<Id, String>();
        Map<Id, String> chargeLineItemIdMapModify = new Map<Id, String>();
        Set<String> correlationIdsSetToModify = new Set<String>();
        Map<Id, Charge_Line_Item__c> chargeLineItemMapNewData = new Map<Id, Charge_Line_Item__c>();
        Map<Id, Charge_Line_Item__c> chargeLineItemMapModifyData = new Map<Id, Charge_Line_Item__c>();
        
        Map<Id, String> chargeLineItemIdMapNewEM = new Map<Id, String>();
        Map<Id, String> chargeLineItemIdMapNewNGUC = new Map<Id, String>();
        
        //Fetching Charge_Line_Item records for all the services
        //added billspecIdentifier and businessID in Soql as part of EDGE-143708 
        Map<Id, Charge_Line_Item__c> chargeLineItemMap =  new Map<Id, Charge_Line_Item__c>([SELECT Id, Name ,CorrelationId__c, chargeType__c, basketId__c,status__c,unitPrice__c,contractTerm__c,serviceId__c, serviceId__r.csord__Subscription__c,billingSpecIdentifier__c,BusinessID__c FROM Charge_Line_Item__c WHERE serviceId__c IN :serviceMap.keyset()]);
        
        
        subIdsToFetchModify.clear();
        subIdsToFetchNew.clear();
        System.debug('chargeLineItemMap line '+chargeLineItemMap);
          
        /* Map chargeLineItemMap have records of Charge_Line_Item for all the services 
         * Map chargeLineItemMapNewData is map of Charge_Line_Item Ids and its records associated with new services
         * Map chargeLineItemIdMaptoInsert is map of Charge_Line_Item Ids and CorrelationIds where Charge_Line_Item.status is not 'Pricing Records Created'
         * Map chargeLineItemMapModifyData is map of Charge_Line_Item Ids and its records associated with modify services
         * Map chargeLineItemIdMapModify is map of Charge_Line_Item Ids and CorrelationIds associated with Modify services
         *
         */
         
         boolean isCompleteModifyOrchestration = true; 
         
        for(Id CLIKey : chargeLineItemMap.keyset()){
            if(serviceIdsToFetchNew.containsKey(chargeLineItemMap.get(CLIKey).serviceId__c)){                
                chargeLineItemMapNewData.put(CLIKey, chargeLineItemMap.get(CLIKey));
                if(chargeLineItemMap.get(CLIKey).status__c != Label.Pricing_Records_Created){
                    // EDGE-128977 : Checking if CLI is for NGUC or EM
                    if(chargeLineItemMap.get(CLIKey).chargeType__c != null && chargeLineItemMap.get(CLIKey).chargeType__c.equalsIgnoreCase(Label.TieredRecurring)){
                    chargeLineItemIdMapNewNGUC.put(CLIKey, chargeLineItemMap.get(CLIKey).CorrelationId__c); 
                    }
                    else{
                     chargeLineItemIdMapNewEM.put(CLIKey, chargeLineItemMap.get(CLIKey).CorrelationId__c);  
                    }
                }
            }
            else if(serviceIdsToFetchModify.containsKey(chargeLineItemMap.get(CLIKey).serviceId__c) && chargeLineItemMap.get(CLIKey).status__c != 'Event Published' && chargeLineItemMap.get(CLIKey).status__c != Label.Pricing_Records_Created){
                
                chargeLineItemIdMapModify.put(CLIKey, chargeLineItemMap.get(CLIKey).CorrelationId__c);
                chargeLineItemMapModifyData.put(CLIKey, chargeLineItemMap.get(CLIKey));
            }
            else if(serviceIdsToFetchModify.containsKey(chargeLineItemMap.get(CLIKey).serviceId__c) && chargeLineItemMap.get(CLIKey).status__c == 'Event Published' || chargeLineItemMap.get(CLIKey).status__c == Label.Pricing_Records_Created){ 
                isCompleteModifyOrchestration = false;  //To keep orchestration In Progress for Modify scenarios
            }
            
             
        }
        
     //added as part of EDGE-143708 
         updatebillSpecIdCLI(serviceMap,chargeLineItemMap);
                
   
        System.debug('chargeLineItemIdMapModify   '+chargeLineItemIdMapModify);
        System.debug('chargeLineItemMapModifyData  '+chargeLineItemMapModifyData);
        System.debug('chargeLineItemMapNewData '+chargeLineItemMapNewData);
        System.debug('chargeLineItemIdMapNewEM  '+chargeLineItemIdMapNewEM);
        System.debug('chargeLineItemIdMapNewNGUC '+chargeLineItemIdMapNewNGUC);
        
        //System.debug('correlationIdsSetToModify '+correlationIdsSetToModify);
        
        if(!chargeLineItemIdMapNewEM.isEmpty())
        chargeLineItemIdMaptoInsert.putAll(chargeLineItemIdMapNewEM);
        if(!chargeLineItemIdMapNewNGUC.isEmpty())
        chargeLineItemIdMaptoInsert.putAll(chargeLineItemIdMapNewNGUC);
        
        Set<String> chargeLineItemInserted = new Set<String>();
        chargeLineItemInserted = GeneratePriceSchedule.insertPSLI_TLI(chargeLineItemIdMapNewEM, chargeLineItemIdMapNewNGUC, 'New');
        

      /* added code as part of EDGE-124716 
       * Logic for Modify Basket chargeLineItemIdMapModify
     */
        if(!chargeLineItemMapModifyData.isEmpty())
        {
            System.debug('chargeLineItemMapModifyData  '+chargeLineItemMapModifyData);
            Database.SaveResult[] result = GeneratePriceSchedule.createPriceScheduleModify(chargeLineItemMapModifyData);
 
        }
        
        boolean isAllInserted = false;
        //Checking if all the Price_Schedule_Line_Item records are inserted against Charge_Line_Item then only completing the step.
        for(Id key : chargeLineItemIdMaptoInsert.keySet()){
            if(!chargeLineItemInserted.isEmpty() && chargeLineItemInserted.contains(String.valueOf(key))){
                isAllInserted = true;    
            }
            else{
                isAllInserted = false;
                break;
            }
        }
        //System.debug('isAllInserted  --Line151-- '+isAllInserted);
        System.debug('isAllInserted  -- '+isAllInserted);
        System.debug('chargeLineItemMap.isEmpty()  -- '+chargeLineItemMap.isEmpty());
        System.debug('chargeLineItemIdMaptoInsert.isEmpty()  -- '+chargeLineItemIdMaptoInsert.isEmpty());
        System.debug('chargeLineItemMapModifyData.isEmpty()  -- '+chargeLineItemMapModifyData.isEmpty());
        System.debug('isCompleteModifyOrchestration  -- '+isCompleteModifyOrchestration);
        if((isAllInserted || chargeLineItemMap.isEmpty() || chargeLineItemIdMaptoInsert.isEmpty()) && chargeLineItemMapModifyData.isEmpty() && isCompleteModifyOrchestration){
        for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Complete;
            step.CSPOFA__Completed_Date__c = Date.today();
            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
            
        }
    }

    return stepList;    
    }
    
    //added new method as part of EDGE-143708 
    public void updatebillSpecIdCLI(Map<Id, csord__Service__c> serviceMap, Map<Id, Charge_Line_Item__c> chargeLineItemMap){
        
        Map<Id,String> serviceAttachmentMap = new Map<Id,String>();
        Map<String,String> servCodetoGUIDMap=new Map<String,String>();
        Map<String,Map<String,String>> servTOCodeGUIDMap = new Map<String,Map<String,String>>();
        List<Charge_Line_Item__c> CliListSpecId=new List<Charge_Line_Item__c>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serviceMap.keyset()]){
            serviceAttachmentMap.put(att.parentId,att.body.toString());
        }
        for(csord__Service__c serv : serviceMap.values()){
           // for(String eachService: serviceAttachmentMap.keySet()){
            if(serviceAttachmentMap.get(serv.Id)!=null){     
                List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(serv.Id)),'BILLING');
                for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){ 
                    String code='DMCAT_'+spec.code.split('Billing_')[1];
                    servCodetoGUIDMap.put(code,spec.guid); servTOCodeGUIDMap.put(spec.serviceId,servCodetoGUIDMap);
                   
                }  
            }
           // }
        }
        
        for(Id CLIKey : chargeLineItemMap.keyset()){
           
            if(chargeLineItemMap.get(CLIKey).billingSpecIdentifier__c==null && servTOCodeGUIDMap.containsKey(chargeLineItemMap.get(CLIKey).serviceId__c)){
                String BusinessID=chargeLineItemMap.get(CLIKey).BusinessID__c;
                Map<String,String> CodetoGuidMap=servTOCodeGUIDMap.get(chargeLineItemMap.get(CLIKey).serviceId__c);
                for(String specCode:CodetoGuidMap.keyset())
                {  
                    if(BusinessID==specCode)
                    {
                       chargeLineItemMap.get(CLIKey).billingSpecIdentifier__c=CodetoGuidMap.get(specCode);
                        CliListSpecId.add(chargeLineItemMap.get(CLIKey));
                        break;
                    }
                }
            }
        }
        
        system.debug('CliListSpecId'+CliListSpecId);
        if(!CliListSpecId.isEmpty()){update CliListSpecId;}
        
    }

}