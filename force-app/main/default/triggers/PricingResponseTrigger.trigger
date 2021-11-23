/*************************************************************************************************
Name : PricingResponseTrigger 
TestClass : PricingResponseTriggerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story              Description
1.        Pawan Devaliya    05-Apr-2020   Created           Pricing Modify for EM and NGUC : trigger will be invoked when MS publish's Event
===============================================================================================================================
***************************************************************************************************/

trigger PricingResponseTrigger on PriceScheduleEvent__e (after insert) {

    Set<String> corelationIdModify = new Set<String>();
    Set<String> corelationIdError = new Set<String>();
    Map<String,String> corelationIdSubId = new Map<String,String>();
    Map<String,String> corelationIdSubIdError = new Map<String,String>();

   for(PriceScheduleEvent__e event : trigger.new){
      if(Trigger.isInsert && !String.isBlank(event.eventType__c) && String.isBlank(event.initiatedBy__c)){  //Checking for events publised from orchestration
      if((event.eventType__c).equalsIgnoreCase('Response')){    //Handling Modify Scenario
        corelationIdModify.add(event.CorrelationId__c); 
        corelationIdSubId.put(event.CorrelationId__c, event.subscriptionId__c);
      }
      if((event.eventType__c).equalsIgnoreCase('Error')){       //Handling Error Scenario
        corelationIdError.add(event.CorrelationId__c);  
        corelationIdSubIdError.put(event.CorrelationId__c, event.subscriptionId__c);
      }
   }
    }
    
    
    if(corelationIdModify!=null && !corelationIdModify.isEmpty()) {
        GeneratePriceSchedule.generatePriceScheduleModify(corelationIdModify, corelationIdSubId); //To Generate PSLI, TLI
    }

    if(corelationIdError!=null && !corelationIdError.isEmpty()) {
    GeneratePriceScheduleErrorHandling.insertJeopardyCase(corelationIdError, corelationIdSubIdError);   //To Create Case when error is recieved from MS
    }

}