/*
* @Author  : Mukta Wadhwani
* @Date    : 30-03-2021
* @Desc    : Test Class For RemoveNumberNGUCController
* @Jira    : 
*/

@isTest
public class RemoveNumberNGUCControllerTest {
 @TestSetup static void dataSetup() {
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
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
        subs.csord__Status__c = 'Active';
        insert subs;
        
        //service  
        csord__Service__c serv = new csord__Service__c(); 
        serv.name ='testService';
        serv.csord__Identification__c  = 'testIdentify_4';
        serv.csordtelcoa__Service_Number__c = 'Serv123';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Created';
        serv.substage__c = 'Product Requirements Validation';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = subs.csord__Order__c;
        insert serv;
        
        //////ServiceSubscription.json
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        List<Number_Group__c> numberGropList = new List<Number_Group__c>();
        Number_Group__c ng1 = new Number_Group__c();
        ng1.Subscription_number__c = subs.csordtelcoa__Subscription_Number__c;
        numberGropList.add(ng1);
        Number_Group__c ng = new Number_Group__c();
        ng.Subscription_number__c = subs.csordtelcoa__Subscription_Number__c;
        numberGropList.add(ng);
        Number_Group__c ng2 = new Number_Group__c();
        ng2.Subscription_number__c = subs.csordtelcoa__Subscription_Number__c;
     	ng2.Pattern_Type__c='Number';
        numberGropList.add(ng2);
        insert numberGropList;
        List<Number__c> numberList = new List<Number__c>();
        Number__c numberObj = new Number__c();
        numberObj.Number_Group__c = ng1.Id;
        numberObj.Status__c = 'Active';
        numberObj.Service_Number__c = '61244547317';
        numberObj.Subscription_number__c = subs.csordtelcoa__Subscription_Number__c;
        numberList.add(numberObj);
        Number__c numberObj1 = new Number__c();
        numberObj1.Number_Group__c = ng.Id;
        numberObj.Service_Number__c = '61474706731';
        numberObj.Status__c = 'Active';
        numberObj.Subscription_number__c = subs.csordtelcoa__Subscription_Number__c;
        numberList.add(numberObj1);
        Number__c numberObj2 = new Number__c();
        numberObj2.Number_Group__c = ng2.Id;
        numberObj2.Service_Number__c = '61474706732';
        numberObj2.Status__c = 'Active';
     	numberObj2.Mobile__c='Mobile';
        numberObj2.Subscription_number__c = [SELECT csordtelcoa__Subscription_Number__c FROM csord__Subscription__c where id=:subs.Id][0].csordtelcoa__Subscription_Number__c;
        numberList.add(numberObj2);
        insert numberList;

    }
    public static testMethod void fetchNumbersPositiveTest(){
        List<csord__Subscription__c> subList = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c];
        List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
        numberList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numberList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numberList;
        test.startTest();
        String csvJosn = JSON.serializePretty('Phone Number\r\n61244547317\r\n61474706731\r\n');
        List<RemoveNumberNGUCController.numberWrapper> wrapList = RemoveNumberNGUCController.fetchNumbers('61244547317,61474706731',new List<String>{subList[0].Id});
        RemoveNumberNGUCController.fetchNumberFromCSV(new List<String>{subList[0].Id},csvJosn);
        system.assert(wrapList.size()>0);
        
        test.stopTest();
    }
     public static testMethod void fetchNumbersNegativeTest(){
        List<csord__Subscription__c> subList = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c];
        List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
        numberList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numberList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numberList;
        test.startTest();
        String csvJosn = JSON.serializePretty('Phone Number\r\n61244547317\r\n61474706731\r\n');
        List<RemoveNumberNGUCController.numberWrapper> wrapList = RemoveNumberNGUCController.fetchNumbers('',new List<String>{subList[0].Id});
        RemoveNumberNGUCController.fetchNumberFromCSV(new List<String>{subList[0].Id},csvJosn);
        system.assert(wrapList.size() == 0);
        test.stopTest();
    }
     public static testMethod void createAndSubmitOrderTest(){
        Account accObj = [select id from Account limit 1];
        String conId = [select Id from Contact limit 1].Id;
        List<csord__Subscription__c> subList = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c];
        List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c,Mobile__c from Number__c]; 
        numberList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        numberList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
        update numberList;        
        test.startTest();
        RemoveNumberNGUCController.createOrderAndRemoveNumbers('[{"numberId":'+'\"'+numberList[0].Id+'\"'+',"phoneNumber":"61244547317","recordCount":1,"status":"RESERVED"}]',accObj.Id,null,conId);
        for(Number__c num:numberList){
            if(num.Mobile__c=='Mobile'){
                RemoveNumberNGUCController.createOrderAndRemoveNumbers('[{"numberId":'+'\"'+num.Id+'\"'+',"phoneNumber":"'+num.Service_Number__c+'","recordCount":1,"status":"RESERVED","numberType":"Number"}]',accObj.Id,null,conId);
                break;
            }
            
        }
        RemoveNumberNGUCController.createOrderAndRemoveNumbers('',accObj.Id,new List<String>{subList[0].Id},conId);
        List<csord__Order__c> orderList = [select id,csord__Order_Number__c,csord__Status__c from csord__Order__c where csord__Identification__c like '%_MACD_Order%'];
        for(csord__Order__c ord:orderList){
            RemoveNumberNGUCController.submitOrder(ord.Id);
        }
        system.assertEquals(orderList.size(),2);
        test.stopTest();
    }
    public static testMethod void createAndSubmitOrderNegativeTest(){
        Account accObj = [select id from Account limit 1];
        String conId = [select Id from Contact limit 1].Id;
        List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
        
        test.startTest();
        RemoveNumberNGUCController.createOrderAndRemoveNumbers('',accObj.Id,null,conId); 
        List<csord__Order__c> orderList = [select id,csord__Order_Number__c,csord__Status__c from csord__Order__c where csord__Identification__c like '%_MACD_Order%'];
        RemoveNumberNGUCController.submitOrder('');
        system.assertNotEquals(orderList.size(), 1);  
        test.stopTest();
    }
   
}