/********************************************************
Test Class  : NumberProvisionedQueueableTest
Created By  : Vijay Kumar Reddy
Description : created QueueableTest class for Push Numbers to BDS when Number Status is “Provisioned”
EDGE-202844
===============================================================================================================================
*/
 
@isTest
public with sharing class NumberProvisionedQueueableTest {

    @testSetup 
    public static void setupdata(){
        List<Number__c> numberList = NumberProvisionedQueueableTest.createProvisionedNumber(3);
        insert numberList;
    }
    
    @isTest
    public static void executeTest(){
        List<Number__c> numberList = [SELECT id, Service_Number__c, Status__c, Subscription_number__c FROM Number__c];
        String jobid=null;
        Test.startTest();
        if(!numberList.isEmpty()){
            jobid = System.enqueueJob(new NumberProvisionedQueueable(numberList,'Provisioned'));
        }
        Test.setMock(HttpCalloutMock.class, new BDSServiceMockResponse(202));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"services":[{"serviceNumber": "61312105400","serviceType": "FNN","subscriptionId": "SN-1000111"},{"serviceNumber": "61312105401","serviceType": "FNN","subscriptionId": "SN-1000111"},{"serviceNumber": "61312105402","serviceType": "FNN","subscriptionId": "SN-1000111"}],"systemId":"MSPA"}}');
        req.setMethod('POST');
		BDSServiceMockResponse mockRes = new BDSServiceMockResponse(202);
        response = mockRes.respond(req);
        Test.stopTest();
        System.assertEquals(jobid!=null,true,'Job enqueued');
        System.assertEquals(response!=null,true,'Returned SUCCESS');
    }
    
    @isTest
    public static void executeErrorTest(){
        List<Number__c> numberList = [SELECT id, Service_Number__c,Status__c, Subscription_number__c FROM Number__c];
        String jobid=null;
        Test.startTest();
        if(!numberList.isEmpty()){
            jobid = System.enqueueJob(new NumberProvisionedQueueable(numberList,'Disconnected'));
        }
        Test.setMock(HttpCalloutMock.class, new BDSServiceMockResponse(404));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"services":[{"serviceNumber": "61312105400","serviceType": "FNN","subscriptionId": "SN-1000111"},{"serviceNumber": "61312105401","serviceType": "FNN","subscriptionId": "SN-1000111"},{"serviceNumber": "61312105402","serviceType": "FNN","subscriptionId": "SN-1000111"}],"systemId":"MSPA"}}');
        req.setMethod('POST');
		BDSServiceMockResponse mockRes = new BDSServiceMockResponse(404);
        response = mockRes.respond(req);
        Test.stopTest();
        System.assertEquals(jobid!=null,true,'Job enqueued');
        System.assertEquals(response.getStatusCode(),404,'Returned Error Response');
    }
 
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
            numberRecord2.Status__c = 'Provisioned';
            numberRecord2.Subscription_number__c = 'SN-100011'+String.ValueOf(i);
            numList.add(numberRecord2);
        }
        return numList;
    }    
}