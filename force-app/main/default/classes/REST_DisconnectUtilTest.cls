/*
* @Author : Ritika Jaiswal
* @Date : 15 Mar 2019
* @Desc : Test class for covering DisconnectOrderServiceUtil API
* @Jira : EDGE - 66139 
*/

@isTest
public class REST_DisconnectUtilTest {
    @testsetup static void setup() { 
        List<csord__Subscription__c> insertSubscriptions = new List<csord__Subscription__c>();
        csord__Subscription__c lockedSubscription=new csord__Subscription__c(csord__Status__c=Label.Subscription_status_for_PortOut, serviceMSISDN__c='1234556877', csord__Identification__c='subscription');
        csord__Subscription__c unlockedSubscription=new csord__Subscription__c(csord__Status__c='Active', serviceMSISDN__c='1234556878', csord__Identification__c='subscription');
        insertSubscriptions.add(lockedSubscription);
        insertSubscriptions.add(unlockedSubscription);
        
        insert insertSubscriptions;
    }
    @isTest
    Public static void testSuccess_PortOutDisconnectRequest(){
        csord__Subscription__c testRecord = [Select csord__Status__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where csord__Status__c=:Label.Subscription_status_for_PortOut limit 1];
        Test.startTest();
        string body = '{ "data":{ "serviceMSISDN" : "1234556877","originatingSystem":"TRAMAS","requestReason" : "Automated Port Out transaction for customer switching carrier","requestedDate":"2019-03-25T00:00:00+11:00","correlationID" : "3247862345-43543-2342","subscriptionNumber":"'+testRecord.csordtelcoa__Subscription_Number__c+'"}}';
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/DisconnectUtil';  
        request.requestBody = Blob.valueOf(body);        
        request.HttpMethod='POST';
        RestContext.request = request;
        RestContext.response = response;
        REST_DisconnectOrderServiceUtil.doPost();
        Test.stopTest();
        System.assert(response.statusCode==200);
    }
    
    @isTest
    Public static void testUnlockedSubscription_PortOutDisconnectRequest(){
        csord__Subscription__c testRecord = [Select csord__Status__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where csord__Status__c='Active' limit 1];
        Test.startTest();
        string body = '{ "data":{ "serviceMSISDN" : "1234556878","originatingSystem":"TRAMAS","requestReason" : "Automated Port Out transaction for customer switching carrier","requestedDate":"2019-03-25T00:00:00+11:00","correlationID" : "3247862345-43543-2342","subscriptionNumber":"'+testRecord.csordtelcoa__Subscription_Number__c+'"}}';
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/DisconnectUtil';  
        request.requestBody = Blob.valueOf(body);
        request.HttpMethod='POST';        
        RestContext.request = request;
        RestContext.response = response;
        REST_DisconnectOrderServiceUtil.doPost();
        Test.stopTest();
        System.assert(response.statusCode==404);
    }
    
    @isTest
    Public static void testInvalidMSISDN_PortOutDisconnectRequest(){
    csord__Subscription__c testRecord = [Select csord__Status__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where csord__Status__c='Active' limit 1];
        Test.startTest();
        string body = '{ "data":{ "serviceMSISDN" : "1234556879","originatingSystem":"TRAMAS","requestReason" : "Automated Port Out transaction for customer switching carrier","requestedDate":"2019-03-25T00:00:00+11:00","correlationID" : "3247862345-43543-2342","subscriptionNumber":"'+testRecord.csordtelcoa__Subscription_Number__c+'"}}';
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/DisconnectUtil';  
        request.requestBody = Blob.valueOf(body);
        request.HttpMethod='POST';        
        RestContext.request = request;
        RestContext.response = response;
        REST_DisconnectOrderServiceUtil.doPost();
        Test.stopTest();
        System.assert(response.statusCode==405);
    }
    
     @isTest
    Public static void testBlankMSISDN_PortOutDisconnectRequest(){
    csord__Subscription__c testRecord = [Select csord__Status__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where csord__Status__c='Active' limit 1];
        Test.startTest();
        string body = '{ "data":{ "serviceMSISDN" : "","originatingSystem":"TRAMAS","requestReason" : "Automated Port Out transaction for customer switching carrier","requestedDate":"2019-03-25T00:00:00+11:00","correlationID" : "3247862345-43543-2342","subscriptionNumber":"'+testRecord.csordtelcoa__Subscription_Number__c+'"}}';
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/DisconnectUtil';  
        request.requestBody = Blob.valueOf(body);
        request.HttpMethod='POST';        
        RestContext.request = request;
        RestContext.response = response;
        REST_DisconnectOrderServiceUtil.doPost();
        Test.stopTest();
        System.assert(response.statusCode==500);
    }
}