@isTest
 
public with sharing class PortOutNumberNGUCControllerTest {

    @TestSetup static void dataSetup() {
    Account acc = new Account();         
    acc.name = 'Test';
    acc.Pref_Comm_Method__c = 'B2B';
    acc.Customer_Status__c = 'ACTIVE';
    insert acc;
    Contact con = new Contact();
    con.FirstName = 'Test Accoun1';
    con.LastName  ='Last 1';
    con.AccountId = acc.Id ;
    insert con;

    csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
    insert ordReq;      

    csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
    order.csord__Order_Request__c = ordReq.Id;
    insert order;
    csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
    ord.csord__Order_Request__c = ordReq.Id;
    ord.csord__Primary_Order__c = order.Id;
    insert ord;

    csord__Subscription__c subs = new csord__Subscription__c();
    subs.Name = 'Business Calling';
    subs.csord__Account__c = acc.Id;
    subs.csord__Order__c = ord.Id;
    subs.csord__Identification__c = 'test';
    subs.csord__Status__c = 'Locked';
    subs.csordtelcoa__Subscription_Number__c = 'SN-000229898';
    insert subs;

    List<Number_Group__c> numberGroupList = new List<Number_Group__c>();
    Number_Group__c ng1 = new Number_Group__c();
    ng1.Subscription_number__c = subs.csordtelcoa__Subscription_Number__c;
    ng1.Scenario_Type__c='Port Out';
    numberGroupList.add(ng1); 
    insert numberGroupList;

    List<Number__c> numberList = new List<Number__c>();
    Number__c num = new Number__c();
    num.Service_Number__c = '61260452045';         
    num.Status__c = 'Locked';
    num.Locked_By__c ='Phoenix UI';         
    num.Account__c = acc.Id ;
    num.Mobile__c ='Fixed';
    num.Account__c = acc.Id ;
    num.Subscription_number__c ='SN-000229898';
    insert num; 

    List<NumberWrap> wrap=new List<NumberWrap>();
    }

    @isTest      
 public static  void fetchNumbersTest(){
    List<csord__Subscription__c> subList = [select csordtelcoa__Subscription_Number__c,customerFacingServiceId__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c  ];
    List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
    numberList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
    // numberList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
    update numberList;
    test.startTest();         
    List<PortOutNumberNGUCController.NumberWrap> wrapList = PortOutNumberNGUCController.fetchNumbers( new List<String>{subList[0].Id});
    system.assert(wrapList.size()>0);        
    test.stopTest();
}
@isTest
public static void createPortOutOrderTest(){
    List<PortOutNumberNGUCController.NumberWrap> wrapList = PortOutNumberNGUCController.fetchNumbers( null);
    List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
    Account  accObj = [select id from Account limit 1];
    String conId = [select Id from Contact limit 1].Id ;
    String subscription='[{"billingAccount":"700001268898","createdBy":"Aditya Pareek","createdDate":"07/04/2021 14:01:30","disableRow":false,"isBillStopped":false,"isCWP":true,"MarketOffer":"DMCAT_Offer_000618","OrderNumber":"ON00160457","productDefinitionName":"DMCAT_ProductSpecification_000871","status":"Active","SubscriptionID":"a4g2N0000003JGtQAM","subscriptionName":"Business Calling","subscriptionNumber":"SN-000229898","totalOC":"$ 0.00","totalRC":"$ 0.00"}]';
    String numbersWrapStr = '[{"phoneNumber":"61244547317","recordCount":1,"status":"Locked","numberId":'+'\"'+numberList[0].Id+'\"'+'}]';
    test.startTest();
    String status=PortOutNumberNGUCController.createPortOutOrder(accObj.Id,numbersWrapStr,conId);
    system.assert(String.isNotBlank(status));
    test.stopTest();
}    

@isTest
public static void createPortOutOrderTestException(){
    List<PortOutNumberNGUCController.NumberWrap> wrapList = PortOutNumberNGUCController.fetchNumbers( new List<String>{'123'});
    List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
    Account  accObj = [select id from Account limit 1];
    String conId = [select Id from Contact limit 1].Id ;
    String subscription='[{"billingAccount":"700001268898","createdBy":"Aditya Pareek","createdDate":"07/04/2021 14:01:30","disableRow":false,"isBillStopped":false,"isCWP":true,"MarketOffer":"DMCAT_Offer_000618","OrderNumber":"ON00160457","productDefinitionName":"DMCAT_ProductSpecification_000871","status":"Active","SubscriptionID":"a4g2N0000003JGtQAM","subscriptionName":"Business Calling","subscriptionNumber":"SN-000229897","totalOC":"$ 0.00","totalRC":"$ 0.00"}]';
    String numbersWrapStr = '[{"phoneNumber":"61244547317","recordCount":1,"status":"Locked","numberId":'+'\"'+numberList[0].Id+'\"'+'}]';
    test.startTest();
    String status=PortOutNumberNGUCController.createPortOutOrder(accObj.Id,numbersWrapStr,conId);
    system.assert(String.isNotBlank(status));
    test.stopTest();
}   

@isTest
public static void createPortOutOrderTestExcep(){
    List<PortOutNumberNGUCController.NumberWrap> wrapList = PortOutNumberNGUCController.fetchNumbers( new List<String>{'123'});
    List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
    Account  accObj = [select id from Account limit 1];
    String conId = [select Id from Contact limit 1].Id ;
    String subscription='';
    String numbersWrapStr = '[{"phoneNumber":"61244547317","recordCount":1,"status":"Locked","numberId":'+'\"'+numberList[0].Id+'\"'+'}]';
    test.startTest();
    String status=PortOutNumberNGUCController.createPortOutOrder(accObj.Id,numbersWrapStr,conId);
    system.assert(String.isNotBlank(status));
    test.stopTest();
}   
@isTest
public static void  testUnlockFNN(){
    List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
    String numbersWrapStr = '[{"phoneNumber":"61244547317","recordCount":1,"status":"Locked","numberId":'+'\"'+numberList[0].Id+'\"'+'}]';
    test.startTest();
    PortOutNumberNGUCController.unlockFNN(numbersWrapStr);
    test.stopTest();
    List<Number__c> numberList1 = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c];
    system.assertEquals(numberList1[0].Status__c,'Active');
} 
    

    public class NumberWrap {
    
    
        @AuraEnabled public String serviceNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String numberId;
        @AuraEnabled public String serviceId;
        @AuraEnabled public String range;
        @AuraEnabled public Integer recordCount;
        @AuraEnabled public String subscriptionNumber;
    }

}