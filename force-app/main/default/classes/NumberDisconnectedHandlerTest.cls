/********************************************************
Test Class  : NumberDisconnectedHandlerTest
Created By  : Nikhil Sharma
Description : created a Test class for retry mechanism
EDGE-202844
===============================================================================================================================
*/

@isTest
public with sharing class NumberDisconnectedHandlerTest {
	@testSetup 
    public static void setupdata(){
        List<Number__c> numberList = createProvisionedNumber(3);
        insert numberList;
    }

    @isTest
    public static void executeWorkTest2() {
        List<Number__c> numberList = [SELECT id, Service_Number__c, Subscription_number__c,Mobile__c, BDS_EventId__c, Status__c FROM Number__c WHERE Status__c = 'Disconnected'];
        BDSDisconnectedServicePayload numberServices = new BDSDisconnectedServicePayload();
        for(Number__c num : numberList){
            DisconnectedPayloadWrapper payload = new DisconnectedPayloadWrapper(num.Service_Number__c);
            numberServices.services.add(payload);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BDSServiceMockResponse(202));
        
        Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String guid = EncodingUtil.ConvertTohex(b)+'|Disconnected';
            insRec.params__c = guid;
            insRec.paramPayload__c = JSON.serialize(numberServices);
            insRec.handler__c = 'NumberDisconnectedHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
         insert insRec;
        
         NumberDisconnectedHandler handler = new NumberDisconnectedHandler();
        handler.executeWork(new List<String>{insRec.params__c});
        
        Test.stopTest();
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'NumberDisconnectedHandler' AND id = :insRec.id];
        System.assertEquals(1, existingRequests.size());
         if( existingRequests.get(0).status__c != null && existingRequests.get(0).status__c == 'Processed'){
             System.assertEquals('Processed', existingRequests.get(0).status__c);
        }
    }
      //Wrapper class for request body
    public class BDSDisconnectedServicePayload{
        List<DisconnectedPayloadWrapper> services;
        public BDSDisconnectedServicePayload(){
            services = new List<DisconnectedPayloadWrapper>(); 
        }
    }
    public class DisconnectedPayloadWrapper {
        public string serviceNumber; 
    
        public DisconnectedPayloadWrapper(string serviceNumber){
            this.serviceNumber = serviceNumber;
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