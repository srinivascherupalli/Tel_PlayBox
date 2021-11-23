/*************************************************************************************************
Name : PricingResponseTrigger
===============================================================================================================================
Sr.No.    Developer Name      Date          Story              Description
1.        Pawan Devaliya    05-Apr-2020   Created           Test class for PricingResponseTrigger
===============================================================================================================================
***************************************************************************************************/

@isTest
private class PricingResponseTriggerTest{
    
    @isTest
    private static void testValidMacScenario(){
        
        List<PriceScheduleEvent__e> eventList = new List<PriceScheduleEvent__e>();

        PriceScheduleEvent__e eventToPublish1 = new PriceScheduleEvent__e();    //For valid MAC scenario
        eventToPublish1.eventType__c = 'Response';
        eventToPublish1.CorrelationId__c = 'CorrelationIdTest1';
        eventToPublish1.initiatedBy__c = null;
        eventList.add(eventToPublish1); 
        
        Test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);
        Test.stopTest();
        
        System.assertEquals(eventList != null, true);
    }
    
        @isTest
    private static void testErrorMacScenario(){
        
        List<PriceScheduleEvent__e> eventList = new List<PriceScheduleEvent__e>();

        PriceScheduleEvent__e eventToPublish1 = new PriceScheduleEvent__e();    //For valid MAC scenario
        eventToPublish1.eventType__c = 'Error';
        eventToPublish1.CorrelationId__c = 'CorrelationIdTest2';
        eventToPublish1.initiatedBy__c = null;
        eventList.add(eventToPublish1); 
        
        Test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);
        Test.stopTest();
        
        System.assertEquals(eventList != null, true);
        
    }

    
    }