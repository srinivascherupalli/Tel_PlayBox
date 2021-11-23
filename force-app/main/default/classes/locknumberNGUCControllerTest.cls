@isTest
public with sharing class locknumberNGUCControllerTest {
  @TestSetup static void dataSetup() {
    Account acc = new Account();
    acc.Name = 'test Account' ;
    acc.Type = 'Competitor' ;
    insert acc;
    
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
  List<locknumberNGUCController.numberWrapper> wrapList = locknumberNGUCController.fetchNumbers('61244547317,61474706731',new List<String>{subList[0].Id});   
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
  List<locknumberNGUCController.numberWrapper> wrapList = locknumberNGUCController.fetchNumbers('',new List<String>{subList[0].Id});  
  locknumberNGUCController.fetchNumberFromCSV(new List<String>{subList[0].Id},csvJosn);
  system.assert(wrapList.size() == 0);
  test.stopTest();
}

public static testMethod void lockNumbersTest(){
    Account accObj = [select id from Account limit 1];
    List<csord__Subscription__c> subList = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c];
    List<Number__c> numberList = [select Id,Service_Number__c,status__c,Number_Group__c,Subscription_number__c from Number__c]; 
    numberList[0].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
    numberList[1].Subscription_number__c = subList[0].csordtelcoa__Subscription_Number__c;
    update numberList;   
    String csvJosn = JSON.serializePretty('Phone Number\r\n61244547317\r\n61474706731\r\n');     
    test.startTest();
    String status=locknumberNGUCController.lockNumbers('[{"numberId":'+'\"'+numberList[0].Id+'\"'+',"phoneNumber":"61244547317","recordCount":1,"status":"RESERVED"}]',accObj.Id,new List<String>{subList[0].Id},csvJosn);
    system.assertEquals(status,'Number Lock confirmed.');
    test.stopTest();
}
public static testMethod void validateNumbersPartOfRangeTest(){
        List<Number__C> numberList = SYS_TestDataFactory.createNumbers(new List<String>{'61260452045','61260452046'},null);
        for(Number__c num : numberList) {
            num.Start_Range__c = '61260452045';
            num.End_range__c = '61260452046';
        }
        Test.startTest();
        Insert numberList;
        List<Number__C> rangeNumList = [Select Number_Range__c, Service_Number__c from Number__c];
        Map<string, List<Number__c>> status = locknumberNGUCController.validateNumbersPartOfRange(rangeNumList); 
        system.debug(status);
        Test.stopTest();

        system.assertEquals(0, status.get('invalid').size());
        system.assertEquals(numberList.size(), status.get('valid').size());
    }


}