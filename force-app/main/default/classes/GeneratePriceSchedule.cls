/*************************************************************************************************
Name : GeneratePriceSchedule 
Description : EDGE-123581 : Enterprise Mobility : Pricing MS request / response structure build and store the response details
TestClass : GeneratePriceScheduleTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story              Description
1.        Pawan Devaliya /    17/01/2020     Created
Vaibhav Deshpande
2.        Pawan/Vaibhav       29/01/2020    EDGE-132626     Solution Integrity For Pricing Schedule
3.        Pawan               10-Feb-2020   EDGE-128977     Pricing functionality for NGUC New  
4.        Pawan               27-Feb-2020   EDGE-124716     Pricing Modify for EM and NGUC
5.        Pawan               27-Feb-2020   EDGE-135274     Added DiscountAmount filed in junction object for S2P and added applicationDuration in PSLI
6.        Pawan               20-March-2020 EDGE-132626     Changed code to have single JSON structure for EM, NGUC device and Voice
7.        Pawan               05-Apr-2020   EDGE-139696     Added new fields and merged methods for EM and NGUC into a single method.
8.        Pawan               14-Apr-2020   EDGE-132626     Did changes related to Junction Object/S2P.
9.        Prajakta            26/05/2020    EDGE-144683
10.        Pawan               19-03-2021      EDGE-189976 : Added in query 'Publish Pricing Event - RFA'
===============================================================================================================================
***************************************************************************************************/

public with sharing class GeneratePriceSchedule {
    
    /*
    * Updating the status of Charge_Line_Items for which Price_Schedule_Line_Items are inserted successfully
    */
    public Static void updateCLIs(Set<String> CLIsInserted, String type){

            if(!CLIsInserted.isEmpty()){ //added code as part of EDGE-132626 
                //Updating the status of Charge_Line_Items for which Price_Schedule_Line_Items are inserted successfully
                List<Charge_Line_Item__c> cliListToUpdate = new List<Charge_Line_Item__c>();
                for(Charge_Line_Item__c cli : [Select Id, status__c from Charge_Line_Item__c where Id in :CLIsInserted]){
                    if(type.equalsIgnoreCase('New') || type.equalsIgnoreCase('Modify')){
                    cli.status__c = Label.Pricing_Records_Created;
                }
                    else if(type.equalsIgnoreCase('Event Published')){
                    cli.status__c = 'Event Published';
                    }
                    cliListToUpdate.add(cli);
                }        
                update cliListToUpdate;
            }
        
    }   
    /*@parm Map<Id, String> cliCorealtionIdsMap : Map of Charge_Line_Item Ids and thier CorrelationIds 
* Method createPSLIListToInsert : Fetch records from PricingMSResponseObject against the passed Charge_Line_Item Ids and thier CorrelationIds 
*  and return the Map of PricingMSResponseObject record Ids and thier records
*/
    public static Map<Id, PricingMSResponseObject__c> createPSLIListToInsert(Map<Id, String> cliCorealtionIdsMap) {
        
        List<PricingMSResponseObject__c> pricingMSResponseObjectList = new List<PricingMSResponseObject__c>();
        Map<Id, PricingMSResponseObject__c> pricingMSResponseObjectMapforPSLI = new Map<Id, PricingMSResponseObject__c>();
        if(cliCorealtionIdsMap.keySet() != null){
            pricingMSResponseObjectList = [SELECT Id, CLI_Instance_ID__c, CorrelationId__c, ResponsePayload__c FROM PricingMSResponseObject__c where CLI_Instance_ID__c in :cliCorealtionIdsMap.keySet()];
            
            if(!pricingMSResponseObjectList.isEmpty()){
                
                for(PricingMSResponseObject__c pricingMSResponseObject : pricingMSResponseObjectList){
                    
                    if(cliCorealtionIdsMap.get(pricingMSResponseObject.CLI_Instance_ID__c) != null && cliCorealtionIdsMap.get(pricingMSResponseObject.CLI_Instance_ID__c) == pricingMSResponseObject.CorrelationId__c){
                        pricingMSResponseObjectMapforPSLI.put(pricingMSResponseObject.Id, pricingMSResponseObject); 
                    }
                }
            } 
        }   
        return pricingMSResponseObjectMapforPSLI;    
        
    }

    /* EDGE-128977 & EDGE-132626: EM and NGUC new
     * @parm List<PricingMSResponseObject__c> : Accepts response records as param, created by Microservice for CLIs
     * Returns PSLIs and TLIs(for NGVoice) to be created.
     */
    
public Static SObject[] generatePSLI_TLI(List<PricingMSResponseObject__c> pricingMSResponseObjectListforPSLI){
    
        List<Tier_Line_Item__c> tierLineItemList = new List<Tier_Line_Item__c>();
        List<Price_Schedule_Line_Item__c> priceScheduleLineItemList = new List<Price_Schedule_Line_Item__c>();
        List<Price_Schedule_Discount_Association__c>  PriceScheduleDiscountAssociationList = new List<Price_Schedule_Discount_Association__c>(); // Junction object for S2P
        
        for(PricingMSResponseObject__c pricingMSResponseObject : pricingMSResponseObjectListforPSLI){
            if(!String.isBlank(pricingMSResponseObject.ResponsePayload__c)){ 
            System.debug('pricingMSResponseObject.ResponsePayload__c   '+pricingMSResponseObject.ResponsePayload__c);

                ChargeLineItemsDTO chargeLineItemsDTOEM = ChargeLineItemsDTO.parse(pricingMSResponseObject.ResponsePayload__c );
                    
                    if(chargeLineItemsDTOEM.chargeLineItems != null)
                    {                   
                   for(chargeLineItemsDTO.PriceScheduleLineItem priceScheduleLineItem : chargeLineItemsDTOEM.chargeLineItems.PriceScheduleLineItem){
                    Price_Schedule_Line_Item__c priceScheduleLineItemToInsert = new Price_Schedule_Line_Item__c();
                                        
                    priceScheduleLineItemToInsert.fromPeriod__c = String.valueOf(priceScheduleLineItem.fromPeriod);
                    priceScheduleLineItemToInsert.toPeriod__c = String.valueOf(priceScheduleLineItem.toPeriod);
                    priceScheduleLineItemToInsert.applicationDuration__c = priceScheduleLineItem.applicationDuration;
                    priceScheduleLineItemToInsert.chargeInstance__c = pricingMSResponseObject.CLI_Instance_ID__c;
                    priceScheduleLineItemToInsert.status__c= 'New';
                    
                    if(priceScheduleLineItem.TierLineItems.isEmpty()){
                        priceScheduleLineItemToInsert.unitPrice__c = priceScheduleLineItem.unitPrice; //Unit Price will not be applicable for NGUC Voice
                        }
                    
                    String externalId ;
                    if(!priceScheduleLineItem.TierLineItems.isEmpty() || !priceScheduleLineItem.ApplicableDiscounts.isEmpty()){     
                        DateTime now = DateTime.now();                      
                        externalId = String.valueOf(now)+String.valueOf(Math.random());     //External Id field to establish initial relation b/w PSLI and TLI
                        priceScheduleLineItemToInsert.PSLIExternalId__c = externalId;
                        }
                    
                    
                    
                    priceScheduleLineItemList.add(priceScheduleLineItemToInsert);   
                    
                    if(!priceScheduleLineItem.TierLineItems.isEmpty()){        //TLI will be non empty for NGUC Voice            
                        for(ChargeLineItemsDTO.TierLineItems tierLineItems : priceScheduleLineItem.TierLineItems){

                            Tier_Line_Item__c tierLineItemToInsert = new Tier_Line_Item__c();
           
                           tierLineItemToInsert.Discounted_Price__c = Decimal.valueOf(tierLineItems.Discounted_Price);
                           tierLineItemToInsert.FromUnit__c = tierLineItems.fromUnit;
                           tierLineItemToInsert.status__c = 'New';
                           tierLineItemToInsert.ToUnit__c = tierLineItems.toUnit;
                           tierLineItemToInsert.fromPeriod__c = String.valueOf(priceScheduleLineItem.fromPeriod);
                           tierLineItemToInsert.toPeriod__c = String.valueOf(priceScheduleLineItem.toPeriod);
                           tierLineItemToInsert.PSLIInstance__r = new Price_Schedule_Line_Item__c(PSLIExternalId__c = externalId);
                           tierLineItemToInsert.appliedDiscountAmount__c = Decimal.valueOf(tierLineItems.appliedDiscountAmount);   //Added for EDGE-139696
                           tierLineItemToInsert.rateCardLineIdentifier__c = String.valueOf(tierLineItems.rateCardLineIdentifier);      //Added for EDGE-139696
                           
                           tierLineItemList.add(tierLineItemToInsert);
                    
                   }    
                   }
                                    
               // EDGE-135274 Start : : Populate Junction object b/w PSLI and DLIs 
                if(!priceScheduleLineItem.ApplicableDiscounts.isEmpty()){
                for(ChargeLineItemsDTO.ApplicableDiscounts applicableDiscounts : priceScheduleLineItem.ApplicableDiscounts){
                    Price_Schedule_Discount_Association__c priceScheduleDiscountAssociation = new Price_Schedule_Discount_Association__c();
                    
                    priceScheduleDiscountAssociation.discountInstance__c = applicableDiscounts.id;
                    priceScheduleDiscountAssociation.priceScheduleInstance__r = new Price_Schedule_Line_Item__c(PSLIExternalId__c = externalId);
                    priceScheduleDiscountAssociation.isActive__c = true;
                    if(applicableDiscounts.appliedDiscountAmount != null){
                    priceScheduleDiscountAssociation.appliedDiscountAmount__c = applicableDiscounts.appliedDiscountAmount;
                    }
                    PriceScheduleDiscountAssociationList.add(priceScheduleDiscountAssociation); 
                }
                }
                // EDGE-135274 End
                }

            }
                System.debug('priceScheduleLineItemList ::  '+priceScheduleLineItemList);
                System.debug('tierLineItemList ::  '+tierLineItemList);
                System.debug('PriceScheduleDiscountAssociationList ::  '+PriceScheduleDiscountAssociationList);
                
           } 
            
        }
        
        SObject[] PSLI_TLI_ToInsert = new List<SObject>();
        if(priceScheduleLineItemList != null){
            PSLI_TLI_ToInsert.addAll(priceScheduleLineItemList);                
            }
        if(tierLineItemList != null){
            PSLI_TLI_ToInsert.addAll(tierLineItemList); 
        }
        if(PriceScheduleDiscountAssociationList != null){
            PSLI_TLI_ToInsert.addAll(PriceScheduleDiscountAssociationList); 
        }
        
        return PSLI_TLI_ToInsert;   

    }           
    
    
     
    /* added code as part of EDGE-124716 
     * Method CreatePriceScheduleModify : Publish event to MS in case of Modify
     */
    public Static Database.SaveResult[] createPriceScheduleModify(Map<Id, Charge_Line_Item__c> chargeLineItemMapModifyData){

        Map<Id, List<Charge_Line_Item__c>> subCLIsMap = new Map<Id, List<Charge_Line_Item__c>>();
        Set<String> CLIsPublised = new Set<String>();
        
       for(Charge_Line_Item__c cli:chargeLineItemMapModifyData.values())
       {
       if(cli.serviceId__r.csord__Subscription__c != null){
           if(subCLIsMap.get(cli.serviceId__r.csord__Subscription__c) != null){
            List<Charge_Line_Item__c> cliList = new List<Charge_Line_Item__c>();
            cliList = subCLIsMap.get(cli.serviceId__r.csord__Subscription__c);
            cliList.add(cli);   
            subCLIsMap.put(cli.serviceId__r.csord__Subscription__c, cliList);
           }
           else{
           List<Charge_Line_Item__c> cliList = new List<Charge_Line_Item__c>();
           cliList.add(cli);
           subCLIsMap.put(cli.serviceId__r.csord__Subscription__c, cliList);               
           }
       } 
       } 
        
        List<Charge_Line_Item__c> cliListToUpdate = new List<Charge_Line_Item__c>();
        List<PriceScheduleEvent__e> eventList = new List<PriceScheduleEvent__e>();
        
    
        for(List<Charge_Line_Item__c> cliList : subCLIsMap.values()){
            String corelationId = IntegrationRecordHandlerUtil.getCorrelationId(); //IntegrationRecordHandlerUtil.getCorrelationId();
            boolean containsTieredCharges = false;
            for(Charge_Line_Item__c cli : cliList){
                cli.CorrelationId__c = corelationId;
                CLIsPublised.add(String.valueOf(cli.Id));
                cliListToUpdate.add(cli);
                if(!String.isBlank(cli.chargeType__c) && cli.chargeType__c.equalsIgnoreCase(Label.TieredRecurring)){        //If any of the CLI is NGVoice then setting containsTieredCharges to true
                    containsTieredCharges = true;
                }
            }
            System.debug('corelationId:: '+corelationId);
            PriceScheduleEvent__e eventToPublish = new PriceScheduleEvent__e();
            eventToPublish.eventType__c = 'Request';
            eventToPublish.CorrelationId__c = corelationId;
            eventToPublish.containsTieredCharges__c = containsTieredCharges;
            eventList.add(eventToPublish);
        }
        
        update cliListToUpdate;
        
        Database.SaveResult[] result = EventBus.publish(eventList);

        if(CLIsPublised != null)
        updateCLIs(CLIsPublised, 'Event Published');    

        return result;

    }    
    
     /* added code as part of EDGE-124716 
     * Method generatePriceScheduleModify called from trigger if any event is publised by MS : To create PSLI and TLI
     */
   // @InvocableMethod
    public Static void generatePriceScheduleModify(Set<String> corelationId, Map<String,String> corelationIdSubId){
        Map<Id, String> chargeLineItemIdMapEM_Modify = new Map<Id, String>();
        Map<Id, String> chargeLineItemIdMapNGUC_Modify = new Map<Id, String>();
        Set<id> subIdToCompleteOrchStep = new Set<id>();
        Map<Id, Charge_Line_Item__c> chargeLineItemsToProcess = new Map<Id, Charge_Line_Item__c>();

        Map<Id, Charge_Line_Item__c> chargeLineItemMap =  new Map<Id, Charge_Line_Item__c>([SELECT Id, Name ,CorrelationId__c, chargeType__c, basketId__c,status__c,unitPrice__c,contractTerm__c,serviceId__c, serviceId__r.csord__Subscription__c FROM Charge_Line_Item__c WHERE CorrelationId__c in :corelationIdSubId.keyset()]);
        
        for(String correlationId : corelationIdSubId.keySet()){
            boolean isCorrelationIdExist = false;
                 for(Charge_Line_Item__c cli : chargeLineItemMap.values()){
                     if(correlationId.equals(cli.CorrelationId__c)){
                        isCorrelationIdExist = true; 
                        chargeLineItemsToProcess.put(cli.Id, cli);
                        //break;
                     }
                 }
                 if(!isCorrelationIdExist){
                     if(corelationIdSubId.get(correlationId) != null){
                        subIdToCompleteOrchStep.add(corelationIdSubId.get(correlationId));               
                     }
                    }
            
        }       
        

    for(Id CLIKey : chargeLineItemsToProcess.keyset()){
        if(chargeLineItemsToProcess.get(CLIKey).status__c != Label.Pricing_Records_Created){
            //Checking if CLI is for NGUC or EM
            if(chargeLineItemsToProcess.get(CLIKey).chargeType__c != null && chargeLineItemsToProcess.get(CLIKey).chargeType__c.equalsIgnoreCase(Label.TieredRecurring)){
                chargeLineItemIdMapNGUC_Modify.put(CLIKey, chargeLineItemsToProcess.get(CLIKey).CorrelationId__c); 
            }
            else{
                chargeLineItemIdMapEM_Modify.put(CLIKey, chargeLineItemsToProcess.get(CLIKey).CorrelationId__c);  
            }
        }  
    }
       
    Set<String> chargeLineItemInserted = new Set<String>();
    chargeLineItemInserted = insertPSLI_TLI(chargeLineItemIdMapEM_Modify, chargeLineItemIdMapNGUC_Modify, 'Modify');

  //Start : Code to complete the steps  
   // Set<Id> subIds = new Set<Id>();
    for(Charge_Line_Item__c cli:chargeLineItemsToProcess.values())
   {
   if(cli.serviceId__r.csord__Subscription__c != null){
  // subIds.add(cli.serviceId__r.csord__Subscription__c);
     subIdToCompleteOrchStep.add(cli.serviceId__r.csord__Subscription__c);
   } 
   }   
   System.debug('subIdToCompleteOrchStep   :  '+subIdToCompleteOrchStep);
   
   Set<Id> OrchestrationIds = new Set<Id>();

for(CSPOFA__Orchestration_Process__c OrchestrationProcess :[SELECT  Id, CSPOFA__Status__c FROM CSPOFA__Orchestration_Process__c WHERE csordtelcoa__Subscription__c IN :subIdToCompleteOrchStep AND CSPOFA__Status__c = 'In Progress' ]){
    
    OrchestrationIds.add(OrchestrationProcess.Id);  
}

List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
// EDGE-144683 -Cease Price Schedule orch name added
//EDGE-189976 : Added in query 'Publish Pricing Event - RFA'
for(CSPOFA__Orchestration_Step__c step : [SELECT id, Name, CSPOFA__Status__c FROM CSPOFA__Orchestration_Step__c where CSPOFA__Orchestration_Process__c in :OrchestrationIds AND(Name = 'Generate Price Schedule' OR Name = 'Cease Price Schedule' OR Name = 'Publish Pricing Event' OR Name ='Publish Pricing Event - RFA')]){
    if(step.CSPOFA__Status__c.equalsIgnoreCase('Waiting')){
        step.CSPOFA__Status__c = 'Complete';
        stepList.add(step);
    }
}

    update stepList;
 //End : Code to complete the steps
   } 

    public static Set<String> insertPSLI_TLI(Map<Id, String> chargeLineItemIdMapEM, Map<Id, String> chargeLineItemIdMapNGUC, String type){
        
        Set<String> chargeLineItemInserted = new Set<String>();
        Map<Id, String> chargeLineItemIdMaptoInsert = new Map<Id, String>();
        
        if(!chargeLineItemIdMapEM.isEmpty() || !chargeLineItemIdMapNGUC.isEmpty())
        {
            //Logic for New Basket
            
            //Merging NGUC and EM CLIs to fetch response data in a single query
            if(!chargeLineItemIdMapEM.isEmpty())
            chargeLineItemIdMaptoInsert.putAll(chargeLineItemIdMapEM);
            if(!chargeLineItemIdMapNGUC.isEmpty())
            chargeLineItemIdMaptoInsert.putAll(chargeLineItemIdMapNGUC);
            
             System.debug('chargeLineItemIdMapNew  '+chargeLineItemIdMaptoInsert);
            
           // List<Id> pricingMSResponseObjectIdListforPSLI = new List<Id>();
            Map<Id, PricingMSResponseObject__c> pricingMSResponseObjectMapforPSLI = createPSLIListToInsert(chargeLineItemIdMaptoInsert);
            
            Map<Id, PricingMSResponseObject__c> pricingMSResponseObjectMapforPSLI_EM = new Map<Id, PricingMSResponseObject__c>();
            Map<Id, PricingMSResponseObject__c> pricingMSResponseObjectMapforPSLI_NGUC = new Map<Id, PricingMSResponseObject__c>();
            // EDGE-128977 : Seperate response object records for NGUC and EM
            for(Id msResponseId : pricingMSResponseObjectMapforPSLI.keySet()){
                if(chargeLineItemIdMapEM.get(pricingMSResponseObjectMapforPSLI.get(msResponseId).CLI_Instance_ID__c) != null){

                    pricingMSResponseObjectMapforPSLI_EM.put(msResponseId, pricingMSResponseObjectMapforPSLI.get(msResponseId));
                }
                else{
                    
                    pricingMSResponseObjectMapforPSLI_NGUC.put(msResponseId, pricingMSResponseObjectMapforPSLI.get(msResponseId));
                }
            }
            
            System.debug('pricingMSResponseObjectMapforPSLI_EM  '+pricingMSResponseObjectMapforPSLI_EM);
            System.debug('pricingMSResponseObjectMapforPSLI_NGUC '+pricingMSResponseObjectMapforPSLI_NGUC);
            
            SObject[] sObjectToInsert = new List<SObject>();
            
            // EDGE-128977 : Generating PSLI for EM
            if(pricingMSResponseObjectMapforPSLI_EM != null){
            SObject[] priceScheduleLineItemListToInsert = new List<SObject>();  
            priceScheduleLineItemListToInsert = generatePSLI_TLI(pricingMSResponseObjectMapforPSLI_EM.values());
             sObjectToInsert.addAll(priceScheduleLineItemListToInsert);                 
            }
            
            // EDGE-128977 : Generating PSLI and TLI for NGUC
            if(pricingMSResponseObjectMapforPSLI_NGUC != null){
                SObject[] PSLI_TLI_ToInsertNGUC = new List<SObject>();
               PSLI_TLI_ToInsertNGUC =  generatePSLI_TLI(pricingMSResponseObjectMapforPSLI_NGUC.values());
               sObjectToInsert.addAll(PSLI_TLI_ToInsertNGUC);
            }
            
            // EDGE-128977 : Inserting PSLI for EM and PSLI, TLI for NGUC in a single transaction
           Database.SaveResult[] results = Database.insert(sObjectToInsert);
            
            //Ids of Charge_Line_Item for which Price_Schedule_Line_Item are inserted
            for(Id key : pricingMSResponseObjectMapforPSLI.keySet()){
                    chargeLineItemInserted.add(pricingMSResponseObjectMapforPSLI.get(key).CLI_Instance_ID__c);
            }
        
        // Updating CLIs status to 'Pricing Records Created'
        System.debug('chargeLineItemInserted :: '+chargeLineItemInserted);
        updateCLIs(chargeLineItemInserted, type);
        
        //EDGE-132626 : Populate Junction object b/w PSLI and DLIs
       //  populatePriceScheduleDiscountAssociation(chargeLineItemInserted);
        }
    
    return chargeLineItemInserted;  
    }    
    
}