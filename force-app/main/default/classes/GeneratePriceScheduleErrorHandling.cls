/*************************************************************************************************
Name : GeneratePriceScheduleErrorHandling 
Description : EDGE-124017 : CS <-> Pricing MS Interface error handling
TestClass : GeneratePriceScheduleErrorHandlingTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Gnana               23-Mar-2020     Created
2.        Prajakta            26/05/2020      EDGE-144683
3.        Pawan               19-03-2021      EDGE-189976 : Added in query 'Publish Pricing Event - RFA'
===============================================================================================================================
***************************************************************************************************/

public without sharing class GeneratePriceScheduleErrorHandling {
   // @InvocableMethod(label='Insert Jeopardy Cases' description='Insert Jeopardy Case for Pricing MS Interface Error')
    public static void insertJeopardyCase(Set<String> setOfCorrelationIds, Map<String,String> corelationIdSubId) {
      //  Set<String> setOfCorrelationIds = new Set<String>(correlationIdList);
          Set<String> corelationIdCLIExist = new Set<String>();
          Set<String> corelationIdCLIdoesNotExist = new Set<String>();
          Set<String> subsIdCLIdoesNotExist = new Set<String>();
      for(String correlationId : corelationIdSubId.keySet()){
            if(corelationIdSubId.get(correlationId) != null){
                corelationIdCLIdoesNotExist.add(correlationId);
                subsIdCLIdoesNotExist.add(corelationIdSubId.get(correlationId));                 
             }
            else{
                corelationIdCLIExist.add(correlationId);
            } 
          
      }

        Map<Id, csord__Subscription__c> subscriptionMap =  new Map<Id, csord__Subscription__c>([SELECT Id, Name ,csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE id in :subsIdCLIdoesNotExist]);
        System.debug('subscriptionMap...'+subscriptionMap.values());      
      
  
        System.debug('setOfCorrelationIds...'+setOfCorrelationIds);
        Set<String> setOfBasketIds = new Set<String>();
        Map<Id,cscfga__Product_Basket__c> productBasketMap = new Map<Id,cscfga__Product_Basket__c>();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback').getRecordTypeId();
        System.debug(devRecordTypeId);
        Map<Id, Charge_Line_Item__c> chargeLineItemMap =  new Map<Id, Charge_Line_Item__c>([SELECT Id, Name ,CorrelationId__c, basketId__c,serviceId__c,serviceId__r.csord__Subscription__c,serviceId__r.csord__Subscription__r.csordtelcoa__Subscription_Number__c FROM Charge_Line_Item__c WHERE CorrelationId__c in :corelationIdCLIExist]);
        System.debug('chargeLineItemMap...'+chargeLineItemMap.values());
        Map<Id,String> mapOfBasketIdSubsNum = new Map<Id,String>();
        Set<Id> setOfSubIds = new Set<Id>();
        for(Id CLIKey : chargeLineItemMap.keyset()){
            if(chargeLineItemMap.get(CLIKey).basketId__c != null){
                setOfBasketIds.add(chargeLineItemMap.get(CLIKey).basketId__c);
                if(chargeLineItemMap.get(CLIKey).serviceId__c != null){
                    if(chargeLineItemMap.get(CLIKey).serviceId__r.csord__Subscription__c != null){
                        setOfSubIds.add(chargeLineItemMap.get(CLIKey).serviceId__r.csord__Subscription__c);
                        mapOfBasketIdSubsNum.put(chargeLineItemMap.get(CLIKey).basketId__c, chargeLineItemMap.get(CLIKey).serviceId__r.csord__Subscription__r.csordtelcoa__Subscription_Number__c);
                    }
                }
            }
            
        }
        
      for(csord__Subscription__c sub : subscriptionMap.values()){
            setOfSubIds.add(sub.Id);
            if(sub.csordtelcoa__Product_Configuration__c != null && sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c != null){
                setOfBasketIds.add(sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c);
                    if(sub.csordtelcoa__Subscription_Number__c != null ){
                    mapOfBasketIdSubsNum.put(sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, sub.csordtelcoa__Subscription_Number__c);
                    }
            }
        }       
        
        
        System.debug('setOfBasketIds...'+setOfBasketIds);
        System.debug('mapOfBasketIdSubsNum...'+mapOfBasketIdSubsNum.values());
        productBasketMap =  new Map<Id, cscfga__Product_Basket__c>([SELECT Id, Name ,cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE Id in :setOfBasketIds]);
        System.debug('productBasketMap...'+productBasketMap.values());
        List<Case> listOfJeoperdyCases = new List<Case>();
        for(Id PBKey : productBasketMap.keyset()){
            Case c = new Case();
            c.RecordTypeId = devRecordTypeId;
            c.Subject = 'Error in pricing schedule generation for '+ mapOfBasketIdSubsNum.get(PBKey);
            c.Priority = Constants.CASE_MEDIUM_PRIORITY;
            c.Status = Constants.CASE_NEW_STATUS;
            c.Feedback_Related_Record_ID__c  = productBasketMap.get(PBKey).cscfga__Opportunity__c;
            c.Feedback_Related_to__c = Constants.CASE_RELATED_TO_OPPTY;
            c.Feedback_Category__c  = Constants.CASE_OTHER_CATEGORY;
            c.Description = 'Error Response from MS';
            listOfJeoperdyCases.add(c);
        }
 
        try{
            // Insert Jeopardy Cases
            if(listOfJeoperdyCases!=null && listOfJeoperdyCases.size()>0){
                System.debug('listOfJeoperdyCases...'+listOfJeoperdyCases);
                INSERT listOfJeoperdyCases;
            }
            
            // Error out Orchestration Steps
            if(setOfSubIds!=null && setOfSubIds.size()>0){
                List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
                Set<Id> OrchestrationIds = new Set<Id>();
                for(CSPOFA__Orchestration_Process__c OrchestrationProcess :[SELECT  Id, CSPOFA__Status__c FROM CSPOFA__Orchestration_Process__c WHERE csordtelcoa__Subscription__c IN :setOfSubIds AND CSPOFA__Status__c = 'In Progress' ]){
                    OrchestrationIds.add(OrchestrationProcess.Id);  
                }
                // EDGE-144683 -Cease Price Schedule orch name added
                //EDGE-189976 : Added in query Publish Pricing Event - RFA
                for(CSPOFA__Orchestration_Step__c step : [SELECT id, Name, CSPOFA__Status__c FROM CSPOFA__Orchestration_Step__c where CSPOFA__Orchestration_Process__c in :OrchestrationIds AND(Name ='Generate Price Schedule' OR Name = 'Cease Price Schedule' OR Name = 'Publish Pricing Event' OR Name ='Publish Pricing Event - RFA')AND CSPOFA__Status__c = 'Waiting']){
                        step.CSPOFA__Status__c = 'Error';
                        stepList.add(step);
                }
                if(stepList!=null && stepList.size()>0){
                    update stepList;
                }
            }
        }catch(Exception e){
            System.debug('Exception:' + e.getTypeName() +','+ e.getMessage() +','+  e.getLineNumber());
        }

    }
}