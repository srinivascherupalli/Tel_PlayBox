/********************************************************
Test Class  : NumberProvisionedHandlerTest
Created By  : Vijay Kumar Reddy
Description : created a Test class for retry mechanism
EDGE-202844
===============================================================================================================================
*/

@isTest
public with sharing class NumberProvisionedHandlerTest {
	@testSetup 
    public static void setupdata(){
        List<Number__c> numberList = NumberProvisionedHandlerTest.createProvisionedNumber(3);
        insert numberList;
        
    }
    @isTest
    public static void executeWorkTest() {
        List<Number__c> numberList = [SELECT id, Service_Number__c, Subscription_number__c,Mobile__c, BDS_EventId__c, Status__c FROM Number__c];
        BDSServicePayload numberServices = new BDSServicePayload();
        for(Number__c num : numberList){
            NumberPayloadWrapper payload = new NumberPayloadWrapper(num.Service_Number__c,'FNN',num.Subscription_number__c);
            numberServices.services.add(payload);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BDSServiceMockResponse(202));
        
        Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String guid = EncodingUtil.ConvertTohex(b)+'|Provisioned';
            insRec.params__c = guid;
            insRec.paramPayload__c = JSON.serialize(numberServices);
            insRec.handler__c = 'NumberProvisionedHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
         insert insRec;
        
        NumberProvisionedHandler handler = new NumberProvisionedHandler();
        handler.executeWork(new List<String>{insRec.params__c});
        
        Test.stopTest();
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'NumberProvisionedHandler' AND id = :insRec.id];
        System.assertEquals(1, existingRequests.size());
        System.assertEquals('Processed', existingRequests.get(0).status__c);
    }

    //Wrapper class for request body
    public class BDSServicePayload{
        List<NumberPayloadWrapper> services;
        public BDSServicePayload(){
            services = new List<NumberPayloadWrapper>(); 
        }
    }
    public class NumberPayloadWrapper {
        public string serviceNumber; 
        public string subscriptionId; 
        public string serviceType;
    
        public NumberPayloadWrapper(string serviceNumber, string serviceType, string subscriptionId){
            this.serviceNumber = serviceNumber;
            this.serviceType = serviceType;
            this.subscriptionId = subscriptionId;
        }
    }
    
    //202844
    public static List<Number__c> createProvisionedNumber(Integer num){
        List<Number__c> numList = new List<Number__c>();
        for(Integer i=0; i<num; i++){
             Number__c numberRecord = new Number__c();
            Number__c numberRecord2 = new Number__c();
            numberRecord.Service_Number__c =  '6131210540'+String.ValueOf(i);
            numberRecord.Type__c='New';
            numberRecord.Mobile__c = 'Fixed';
            numberRecord.Status__c = 'Provisioned';
            numberRecord.Subscription_number__c = 'SN-100011'+String.ValueOf(i);
            numList.add(numberRecord);
            numberRecord2.Service_Number__c =  '6131210540'+String.ValueOf(i);
            numberRecord2.Type__c='New';
            numberRecord2.Mobile__c = 'Fixed';
            numberRecord2.Status__c = 'Disconnected';
            numberRecord2.Subscription_number__c = 'SN-100011'+String.ValueOf(i);
            numList.add(numberRecord2);
        }
        return numList;
    }
}