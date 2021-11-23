/*
* @Author : Ritika Jaiswal
* @Date : 1 April 2019
* @Desc : Test class for covering DisconnectOrderHandler class
* @Jira : EDGE - 66139 
*/

@isTest
public class DisconnectOrderHandlerTest {
    @testsetup static void setup() { 
        List<csord__Subscription__c> insertSubscriptions = new List<csord__Subscription__c>();
        csord__Subscription__c lockedSubscription=new csord__Subscription__c(csord__Status__c=Label.Subscription_status_for_PortOut, serviceMSISDN__c='1234556877', csord__Identification__c='subscription');
        csord__Subscription__c unlockedSubscription=new csord__Subscription__c(csord__Status__c='Active', serviceMSISDN__c='1234556878', csord__Identification__c='subscription');
        insertSubscriptions.add(lockedSubscription);
        insertSubscriptions.add(unlockedSubscription);
        
        insert insertSubscriptions;
    }
    
    @isTest
    Public static void testSuccess(){
        csord__Subscription__c testRecord = [Select csord__Status__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where csord__Status__c=:Label.Subscription_status_for_PortOut limit 1];
        DisconnectOrderRequestDTO disconnectRequestdto = new DisconnectOrderRequestDTO();
        disconnectRequestdto.data = New DisconnectOrderRequestDTO.Data();
        disconnectRequestdto.Data.serviceMSISDN ='1234556877';
        disconnectRequestdto.Data.originatingSystem = 'TRAMAS';
        disconnectRequestdto.Data.requestReason = 'Automated Port Out transaction for customer switching carrier';
        disconnectRequestdto.Data.requestedDate = '2019-03-25T00:00:00+11:00';
        disconnectRequestdto.Data.correlationID= '3247862345-43543-2342';
        disconnectRequestdto.Data.subscriptionID= testRecord.id;
        RestContext.request = new RestRequest(); 
        RestContext.request.requestBody = Blob.valueOf('');
        RestContext.response = new RestResponse();
        DisconnectOrderHandler handler = new DisconnectOrderHandler();
        handler.getSubcriptionDetailsForDisconnectRequest(disconnectRequestdto);
        List<DisconnectionRequest__c> requestRecordList = [Select id from DisconnectionRequest__c where E2ECorrelationID__c =:disconnectRequestdto.Data.correlationID];       
        System.assert(requestRecordList.size()>0);
    }
    
     @isTest
    Public static void testError(){
        csord__Subscription__c testRecord = [Select csord__Status__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where csord__Status__c='Active' limit 1];
        DisconnectOrderRequestDTO disconnectRequestdto = new DisconnectOrderRequestDTO();
        disconnectRequestdto.data = New DisconnectOrderRequestDTO.Data();
        disconnectRequestdto.Data.serviceMSISDN ='1234556878';
        disconnectRequestdto.Data.originatingSystem = 'TRAMAS';
        disconnectRequestdto.Data.requestReason = 'Automated Port Out transaction for customer switching carrier';
        disconnectRequestdto.Data.requestedDate = '2019-03-25T00:00:00+11:00';
        disconnectRequestdto.Data.correlationID= '3247862345-43543-2343';
        disconnectRequestdto.Data.subscriptionID= testRecord.id;
        RestContext.request = new RestRequest(); 
        RestContext.request.requestBody = Blob.valueOf('');
        RestContext.response = new RestResponse();
        DisconnectOrderHandler handler = new DisconnectOrderHandler();
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Test.startTest();
        handler.getSubcriptionDetailsForDisconnectRequest(disconnectRequestdto);
        List<DisconnectionRequest__c> requestRecordList = [Select id from DisconnectionRequest__c where E2ECorrelationID__c =:disconnectRequestdto.Data.correlationID];       
        Test.stopTest();
        System.assert(requestRecordList.size()==0);
    }

}