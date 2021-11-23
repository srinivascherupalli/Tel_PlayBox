/*
* @Author  : Mukta Wadhwani
* @Date    : 12-03-2021
* @Desc    : Test Class For ManageNumberGroupNotification
* @Jira    : EDGE-141545
*/
@isTest
public class ManageNumberGroupNotificationTest {
    @TestSetup static void dataSetup() {
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='EnableHV';
        csSite.value__c='True';
        insert csSite;
        
        EnvironmentVariable__c tokenCustomSetting = new EnvironmentVariable__c();         
        tokenCustomSetting.Name = 'EnableThrowException';        
        tokenCustomSetting.Value__c = 'true';        
        insert tokenCustomSetting;
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
        ng1.Subscription_number__c = 'Sub5678';
        ng1.OrderId__c = ord.Id;
        ng1.Scenario_Type__c = 'Port Out';
        numberGropList.add(ng1);
        Number_Group__c ng = new Number_Group__c();
        ng.Subscription_number__c = 'Sub5678';
        ng.Scenario_Type__c = 'Port Out';
        ng.OrderId__c = ord.Id;
        numberGropList.add(ng);
        insert numberGropList;
        List<Number__c> numberList = new List<Number__c>();
        Number__c numberObj = new Number__c();
        numberObj.Number_Group__c = ng1.Id;
        numberList.add(numberObj);
        Number__c numberObj1 = new Number__c();
        numberObj1.Number_Group__c = ng.Id;
        numberList.add(numberObj1);
        insert numberList;
        
    }
    public static testMethod void processFulfilmentPositiveTest() {
        List<Number_Group__c> numberGroupList = [select Id,Service_Instance_Id__c,Name,Status__c from Number_Group__c];
        List<csord__Order__c> orderList = [select Id,csord__Order_Number__c from csord__Order__c where Name =: 'testOrder'];
        List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        OrderNotification__e eventObj = new OrderNotification__e();
        eventObj.errorDetails__c = null;
        eventObj.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"},{"name":"status","value":"In Progress"}]';
        eventObj.eventType__c = 'statusNotification';
        eventObj.orderItemId__c = orderList[0].csord__Order_Number__c+'|'+numberGroupList[0].Name+'|'+numberGroupList[0].Service_Instance_Id__c;
        eventObj.sourceSystem__c = 'Fulfilment';
        eventObj.sequence__c = 1;
        eventObj.msCorrelationId__c = '5463873930';
        eventObj.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventObj.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventObj);
        OrderNotification__e eventOb = new OrderNotification__e();
        eventOb.errorDetails__c = null;
        eventOb.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"},{"name":"status","value":"Complete"}]';
        eventOb.eventType__c = 'statusNotification';
        eventOb.orderItemId__c = orderList[0].csord__Order_Number__c+'|'+numberGroupList[1].Name+'|'+numberGroupList[1].Service_Instance_Id__c;
        eventOb.sourceSystem__c = 'Fulfilment';
        eventOb.sequence__c = 1;
        eventOb.msCorrelationId__c = '5463873930';
        eventOb.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventOb.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventOb);
        test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);        
        test.stopTest();
        numberGroupList = [select Id,Service_Instance_Id__c,Name,Status__c from Number_Group__c];
        List<Number__c> numberList = [select Id,Status__c from Number__c];
        //system.assertEquals(numberList[1].Status__c, 'Provisioned');
        //system.assertEquals(numberGroupList[1].Status__c, 'Disconnected');
        
    }
    public static testMethod void processFulfilmentNegativeTest() {
        List<Number_Group__c> numberGroupList = [select Id,Service_Instance_Id__c,Name,Status__c from Number_Group__c];
        List<csord__Order__c> orderList = [select Id,csord__Order_Number__c from csord__Order__c where Name =: 'testOrder'];
        List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        OrderNotification__e eventObj = new OrderNotification__e();
        eventObj.errorDetails__c = null;
        eventObj.orderItemId__c = orderList[0].csord__Order_Number__c+'|NG-0000|'+numberGroupList[0].Service_Instance_Id__c;
        eventObj.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"},{"name":"status","value":"In Progress"}]';
        eventObj.eventType__c = 'statusNotification';
        eventObj.sourceSystem__c = 'Fulfilment';
        eventObj.sequence__c = 1;
        eventObj.msCorrelationId__c = '5463873930';
        eventObj.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventObj.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventObj);
        test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);        
        test.stopTest();
        numberGroupList = [select Id,Service_Instance_Id__c,Name,Status__c from Number_Group__c];
        List<Number__c> numberList = [select Id,Status__c from Number__c];
        system.assertNotEquals(numberList[0].Status__c, 'Provisioning In Progress');
    }
    
    
    public static testMethod void processBiling_Number() {
        
        Number_Group__c ng1 = new Number_Group__c();
        ng1.Subscription_number__c = 'Sub5078';
        ng1.Scenario_Type__c = 'Remove';
        insert ng1;
        
        List<Number__c> numberList = new List<Number__c>();
        Number__c numberObj = new Number__c();
        numberObj.BDS_EventId__c = 'dummyOrderId';
        numberObj.Service_Number__c = '61267983671';
        numberObj.Number_Group__c = ng1.Id;
        
        numberList.add(numberObj);
        Number__c numberObj1 = new Number__c();
        numberObj1.BDS_EventId__c = 'dummyOrderId';
        numberObj1.Service_Number__c = '61267983677';
        numberObj1.Number_Group__c = ng1.Id;
        numberList.add(numberObj1);
        insert numberList;
        
        List<Number_Group__c> numberGroupList = [select Id,Service_Instance_Id__c,Name,Status__c from Number_Group__c];
        List<csord__Order__c> orderList = [select Id,csord__Order_Number__c from csord__Order__c where Name =: 'testOrder'];
        List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        OrderNotification__e eventObj = new OrderNotification__e();
        eventObj.notificationAttributes__c ='"attributes":[{"name":"error","value":"Functional Error"}]';
        eventObj.eventType__c = 'serviceNotification';
        eventObj.orderItemId__c = 'dummyOrderId';
        eventObj.sourceSystem__c = 'Billing';
        eventObj.sequence__c = 1;
        eventObj.errorDetails__c = '"error":[{"errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983669" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983670" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983671" }]';
        eventObj.msCorrelationId__c = '5463873930';
        eventObj.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventObj.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventObj);
        OrderNotification__e eventOb = new OrderNotification__e();
        eventObj.errorDetails__c = '"error":[{"errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983669" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983670" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983671" }]';
        eventOb.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"},{"name":"status","value":"Complete"}]';
        eventOb.eventType__c = 'error';
        eventOb.orderItemId__c = 'dummyOrderId';
        eventOb.sourceSystem__c = 'Billing';
        eventOb.sequence__c = 1;
        eventOb.msCorrelationId__c = '5463873930';
        eventOb.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventOb.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventOb);
        test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);        
        test.stopTest();
        
        List<Number__c> numberList1 = [SELECT Id ,Name,Service_Number__c, BDS_EventId__c , Status__c FROM Number__c where id in : numberList ];
        
        for ( Number__c num : numberList1) {
            if ( num.Service_Number__c != null && num.Service_Number__c != '' &&   num.Service_Number__c != '61267983671'){
                //System.assertEquals( num.Status__c  , 'Active'  , 'The error status should be there');
            }
        }
        
    }
    
    
    public static testMethod void processBiling_Number_erroe() {
        
        Number_Group__c ng1 = new Number_Group__c();
        ng1.Subscription_number__c = 'Sub5078';
        ng1.Scenario_Type__c = 'Remove';
        insert ng1;
        
        List<Number__c> numberList = new List<Number__c>();
        Number__c numberObj = new Number__c();
        numberObj.BDS_EventId__c = 'dummyOrderId';
        numberObj.Service_Number__c = '61267983671';
        numberObj.Number_Group__c = ng1.Id;
        
        numberList.add(numberObj);
        Number__c numberObj1 = new Number__c();
        numberObj1.BDS_EventId__c = 'dummyOrderId';
        numberObj1.Service_Number__c = '61267983677';
        numberObj1.Number_Group__c = ng1.Id;
        numberList.add(numberObj1);
        insert numberList;
        
        List<Number_Group__c> numberGroupList = [select Id,Service_Instance_Id__c,Name,Status__c from Number_Group__c];
        List<csord__Order__c> orderList = [select Id,csord__Order_Number__c from csord__Order__c where Name =: 'testOrder'];
        List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        OrderNotification__e eventObj = new OrderNotification__e();
        eventObj.notificationAttributes__c ='"attributes":[{"name":"error","value":"Functional Error"}]';
        eventObj.eventType__c = 'error';
        eventObj.orderItemId__c = 'dummyOrderId';
        eventObj.sourceSystem__c = 'Billing';
        eventObj.sequence__c = 1;
        eventObj.errorDetails__c = '"error":[{"errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983669" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983670" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983671" }]';
        eventObj.msCorrelationId__c = '5463873930';
        eventObj.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventObj.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventObj);
        OrderNotification__e eventOb = new OrderNotification__e();
        eventObj.errorDetails__c = '"error":[{"errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983669" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983670" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983671" }]';
        eventOb.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"},{"name":"status","value":"Complete"}]';
        eventOb.eventType__c = 'error';
        eventOb.orderItemId__c = 'dummyOrderId';
        eventOb.sourceSystem__c = 'Billing';
        eventOb.sequence__c = 1;
        eventOb.msCorrelationId__c = '5463873930';
        eventOb.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventOb.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventOb);
        test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);        
        test.stopTest();
         
        List<Number__c> numberList1 = [SELECT Id ,Name,Service_Number__c, BDS_EventId__c , Status__c FROM Number__c where id in : numberList ];
        
        for ( Number__c num : numberList1) {
            if ( num.Service_Number__c != null && num.Service_Number__c != '' &&   num.Service_Number__c != '61267983671'){
                //System.assertEquals( num.Status__c  , 'Active'  , 'The error status should be there');
            }
        }
        
    }
    
    
    
    public static testMethod void processBiling_NumberNegative() {
        
        Number_Group__c ng1 = new Number_Group__c();
        ng1.Subscription_number__c = 'Sub5678';
        ng1.Scenario_Type__c = 'Add';
        insert ng1;
        
        List<Number__c> numberList = new List<Number__c>();
        Number__c numberObj = new Number__c();
        numberObj.BDS_EventId__c = 'dummyOrderId';
        numberObj.Service_Number__c = '61267983671';
        numberObj.Number_Group__c = ng1.Id;
        
        numberList.add(numberObj);
        Number__c numberObj1 = new Number__c();
        numberObj1.BDS_EventId__c = 'dummyOrderId';
        numberObj1.Service_Number__c = '61267983677';
        numberObj1.Number_Group__c = ng1.Id;
        
        numberList.add(numberObj1);
        insert numberList;
        
        List<Number_Group__c> numberGroupList = [select Id,Service_Instance_Id__c,Name,Status__c from Number_Group__c];
        List<csord__Order__c> orderList = [select Id,csord__Order_Number__c from csord__Order__c where Name =: 'testOrder'];
        List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        OrderNotification__e eventObj = new OrderNotification__e();
        eventObj.notificationAttributes__c ='"attributes":[{"name":"error","value":"Functional Error"}]';
        eventObj.eventType__c = 'serviceNotification';
        eventObj.orderItemId__c = 'dummyOrderId';
        eventObj.sourceSystem__c = 'Billing';
        eventObj.sequence__c = 1;
        eventObj.errorDetails__c = '"error":[{errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983669" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983670" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983671" }]';
        eventObj.msCorrelationId__c = '5463873930';
        eventObj.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventObj.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventObj);
        OrderNotification__e eventOb = new OrderNotification__e();
        eventObj.errorDetails__c = '"error":[{"errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983669" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983670" },{ "errorCode": 500, "errorDescription": "Internal Server Error", "serviceNumber": "61267983671" }]';
        eventOb.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"},{"name":"status","value":"Complete"}]';
        eventOb.eventType__c = 'statusNotification';
        eventOb.orderItemId__c = 'dummyOrderId';
        eventOb.sourceSystem__c = 'Billing';
        eventOb.sequence__c = 1;
        eventOb.msCorrelationId__c = '5463873930';
        eventOb.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        eventOb.externalOrderId__c = orderList[0].csord__Order_Number__c;
        eventList.add(eventOb);
        test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);        
        test.stopTest();
        
        List<Number__c> numberList1 = [SELECT Id ,Name,Service_Number__c, BDS_EventId__c , Status__c FROM Number__c where id in : numberList ];
        
        for ( Number__c num : numberList1) {
            if ( num.Service_Number__c != null && num.Service_Number__c != '' &&   num.Service_Number__c == '61267983671'){
                //System.assertEquals( num.Status__c  , 'Active'  , 'The error status should not be blank');
            }
        }
        
    }
    //This method is to call all status update methods explictly to maintain the code coverage if feature toggeling is off
    public static testMethod void callO2ANotificationMehtod(){       
    	List<Number_Group__c> numberGroupList = [select Id,Service_Instance_Id__c,Name,Status__c,OrderId__c,Scenario_Type__c from Number_Group__c];
		List<Number__c> numberList = [select Id,Status__c,Number_Group__r.Status__c,Number_Group__r.Scenario_Type__c,External_Id__c from Number__c];
        Map<String, String> statusMap = new Map<String, String>();
        statusMap.put(numberList[0].External_Id__c,'Complete');
        List<NotificationParameters> numNotificationList = new List<NotificationParameters>();
        NotificationParameters numNotification = new NotificationParameters();
        numNotification.orderItemId = numberGroupList[0].OrderId__c +'|'+numberList[0].External_Id__c +'|e82c584e-ad11_ON00043088';
        numNotification.orderItemDetails = '"product":{"productId": "IOT_PLANS_Instance_Id_ON00043088","status": "In Progress","attributes": [{"name":"IMSI","value":"505010085600021"},{"name":"SIMSerialNumber","value":"5833181154036"}],"childProduct": [{"productId": "IOT_PLANS_Instance_Id_ON00043088","status": "In Progress","attributes": []},{"productId": "IOT_DATA_Id_ON00043088","status": "In Progress","attributes": []}]}';
        numNotification.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate","value":"2021-07-27T08:15:14+00:00"}, {"name":"currentForecastedDeliveryDate","value":"2021-07-27T08:13:16+00:00"}, {"name":"status","value":"In Progress"}]';
        numNotificationList.add(numNotification);
        test.startTest();
            ManageNumberGroupNotification.chnageNumbersStatus(numberList[0],'In Progress');
            ManageNumberGroupNotification.chnageNumbersStatus(numberList[0],'Complete');
            ManageNumberGroupNotification.changeNumberGroupStatus(numberGroupList[0],'In Progress');
            ManageNumberGroupNotification.changeNumberGroupStatus(numberGroupList[0],'Complete');     
        	
        	ManageNumberGroupNotification.processFulfilmentNotifications(statusMap,numNotificationList);
        	
        test.stopTest();
        

        
    }
    @isTest 
  static void testProcessFulfilmentNotificationNumberUpdate() {
    List<csord__Order__c> orderList = [select Id,csord__Order_Number__c from csord__Order__c where Name =: 'TestOrder'];
    csord__Subscription__c subsNumUpt=new csord__Subscription__c();
    subsNumUpt.name  = 'test numupdate';
    subsNumUpt.csord__Identification__c = 'test identity';
    subsNumUpt.csord__Order__c = orderList[0].Id;
    subsNumUpt.csord__Status__c='Pending';
    insert subsNumUpt;
    csord__Service__c servNum = new csord__Service__c();
    servNum.name ='tst numupdate';
    servNum.csord__Identification__c  = 'tst numupdate';
    servNum.csordtelcoa__Service_Number__c = '6';
    servNum.Quantity__c=3;
    servNum.csord__Subscription__c = subsNumUpt.Id;
    servNum.csord__Status__c = 'Service Created';
    servNum.csord__Order__c = orderList[0].Id;
    insert servNum;
    csord__Service__c servNum1 = new csord__Service__c();
    servNum1.name ='tst numupdate child';
    servNum1.csord__Identification__c  = 'tst numupdate child';
    servNum1.csord__Service__c=servNum.Id;
    servNum1.csordtelcoa__Service_Number__c = '7';
    servNum1.csord__Subscription__c = subsNumUpt.Id;
    servNum1.csord__Status__c = 'Service Created';
    servNum1.csord__Order__c = orderList[0].Id;
    insert servNum1;
    Number__c num6=new Number__c();
    num6.name='Num numupt';
    num6.Type__c='New';
    num6.Service_Number__c='61474850547';
    num6.Status__c='RESERVED';
    num6.Product_ID__c='gb58-89jk-yuit-fr46';
    num6.Mobile__c = 'Mobile';
    insert num6;
    Number__c num7=new Number__c();
    num7.name='Num numupt';
    num7.Type__c='New';
    num7.Service_Number__c='61474850547';
    num7.Status__c='RESERVED';
    num7.Product_ID__c='gb58-89jk-yuit-fr46';
    num7.Mobile__c = 'Mobile';
    insert num7;
    
    List<csord__Subscription__c> subs=[SELECT Id,Name,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c where Name='test numupdate' limit 1];
    List<csord__Service__c> serv=[SELECT csord__Status__c,Quantity__c FROM csord__Service__c WHERE csord__Subscription__c=:subs[0].Id];
    List<Number__c> nums=[SELECT External_Id__c FROM Number__C where Name='Num numupt'];
    System.debug(nums[0].External_Id__c+'  '+nums[1].External_Id__c);
    Number_Group__c numGrp=new Number_Group__c();
    numGrp.Status__c='Reserved';
    numGrp.Total_Numbers_Completed__c=0;
    numGrp.OrderId__c = orderList[0].Id; 
    numGrp.Subscription_Number__c=subs[0].csordtelcoa__Subscription_Number__c;
    insert numGrp;
    for(Number__c num:nums){
      num.Number_Group__c=numGrp.Id;
      num.Subscription_number__c=subs[0].csordtelcoa__Subscription_Number__c;
    }
    update nums;
    serv[0].Quantity__c=1;
    update serv;
    List<OrderNotification__e> eventList = new List<OrderNotification__e>();
    OrderNotification__e eventObj=new OrderNotification__e();
    eventObj.orderItemId__c= orderList[0].csord__Order_Number__c+'|'+nums[0].External_Id__c+'|e82c584e-ad11_123775';
    eventObj.eventTimestamp__c= '2021-07-20T07:03:50+00:00';
    eventObj.externalOrderId__c= orderList[0].csord__Order_Number__c;
    eventObj.orderItemVersion__c= 1;
    eventObj.eventType__c= 'subStageNotification';
    eventObj.notificationAttributes__c= '\"attributes\":[{\"name\":\"ServiceActivationDate\",\"value\":\"2021-07-20T07:03:26+00:00\"}, {\"name\":\"currentForecastedDeliveryDate\",\"value\":\"2021-07-20T07:11:45+00:00\"}, {\"name\":\"subStage\",\"value\":\"Product Activation and Testing\"}]';
    eventObj.orderItemDetails__c='\"product\":{\"productId\": \"IOT_PLANS_Instance_Id_123775\",\"status\": \"In Progress\",\"attributes\": [{\"name\":\"IMSI\",\"value\":\"505010085600021\"},{\"name\":\"SIMSerialNumber\",\"value\":\"5833181154036\"}],\"childProduct\": [{\"productId\": \"IOT_PLANS_Instance_Id_123775\",\"status\": \"In Progress\",\"attributes\": []},{\"productId\": \"IOT_DATA_Id_123775\",\"status\": \"In Progress\",\"attributes\": []}]}';
    eventList.add(eventObj);
    OrderNotification__e eventObj1=new OrderNotification__e();
    eventObj1.orderItemId__c= orderList[0].csord__Order_Number__c+'|'+nums[1].External_Id__c+'|e82c584e-ad11_123775';
    eventObj1.eventTimestamp__c= '2021-07-20T07:03:50+00:00';
    eventObj1.externalOrderId__c= orderList[0].csord__Order_Number__c;
    eventObj1.orderItemVersion__c= 1;
    eventObj1.eventType__c= 'statusNotification';
    eventObj1.notificationAttributes__c= '\"attributes\":[{\"name\":\"telstraCommittedDate\",\"value\":\"2021-07-27T08:15:14+00:00\"}, {\"name\":\"currentForecastedDeliveryDate\",\"value\":\"2021-07-20T07:05:46+00:00\"}, {\"name\":\"productCompletionDate\",\"value\":\"2021-07-20T07:03:50+00:00\"}, {\"name\":\"status\",\"value\":\"Complete\"}]';
    eventObj1.orderItemDetails__c= '\"product\":{\"productId\": \"IOT_PLANS_Instance_Id_123775\",\"status\": \"Complete\",\"attributes\": [],\"childProduct\": [{\"productId\": \"IOT_DATA_Id_123775\",\"status\": \"Complete\",\"attributes\": []}]}';
    eventList.add(eventObj1);

    test.startTest();
    Database.SaveResult[] result = EventBus.publish(eventList);
    test.stopTest();
    system.assertnotEquals(result, null);
    
   } 
}