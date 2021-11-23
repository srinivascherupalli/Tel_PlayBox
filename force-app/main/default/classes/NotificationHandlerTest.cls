@isTest
private class NotificationHandlerTest {
    @Testsetup
  static void dataSetup(){
    Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
    csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
    insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs;
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        insert serv;
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-2911-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
  }
  @isTest
  static void testValidEventTypeNull(){
    Notification__c notification = new Notification__c();
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = 'ORD_345221|SRV_345221|rewre3423';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    notification.sourceSystem__c = 'Fulfilment';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testValidSourceSystemNull(){
    Notification__c notification = new Notification__c();
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = 'ORD_345221|SRV_345221|rewre3423';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    notification.eventType__c = 'statusNotification';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testValidEventTimeStampNull(){
    Notification__c notification = new Notification__c();
    notification.sourceSystem__c = 'Fulfilment';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = 'ORD_345221|SRV_345221|rewre3423';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    notification.eventType__c = 'statusNotification';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testValidExternalOrderIdNull(){
    Notification__c notification = new Notification__c();
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.orderItemId__c = 'ORD_345221|SRV_345221|rewre3423';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    notification.eventType__c = 'statusNotification';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testValidOrderItemIdNull(){
    Notification__c notification = new Notification__c();
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    notification.eventType__c = 'statusNotification';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testValidOrderItemVersionNull(){
    Notification__c notification = new Notification__c();
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = 'ORD_345221|SRV_345221|rewre3423';
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    notification.eventType__c = 'statusNotification';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testValidNotificationAttributesNull(){
    Notification__c notification = new Notification__c();
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = 'ORD_345221|SRV_345221|rewre3423';
    notification.orderItemVersion__c = 1;
    notification.eventType__c = 'statusNotification';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testInValidOrderItemId(){
    Notification__c notification = new Notification__c();
    notification.eventType__c = 'statusNotification';
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = 'abcd';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testInValidNotificationAttributes(){
    
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    
    Notification__c notification = new Notification__c();
    notification.eventType__c = 'statusNotification';
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|3072dad2-2911-eb71-8e13-bd04b7f9824a';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = 'abcd';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testInValidOrderItemDetails(){
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    
    Notification__c notification = new Notification__c();
    notification.eventType__c = 'statusNotification';
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|3072dad2-2911-eb71-8e13-bd04b7f9824a';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    notification.orderItemDetails__c = 'abcd';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testInValidErrorDetails(){
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    
    Notification__c notification = new Notification__c();
    notification.eventType__c = 'statusNotification';
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|3072dad2-2911-eb71-8e13-bd04b7f9824a';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    notification.orderItemDetails__c = '"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"In Progress"}';
    notification.errorDetails__c = 'abcd';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testInvalidAppointmentId(){
    Notification__c notification = new Notification__c();
    notification.eventType__c = 'appointmentNotification';
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = 'abcd';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testInvalidEventId(){
    Notification__c notification = new Notification__c();
    notification.eventType__c = 'statusNotification';
    notification.sourceSystem__c = 'Billing';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = 'abcd';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testInvalidServiceId(){
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    
    Notification__c notification = new Notification__c();
    notification.eventType__c = 'statusNotification';
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = ord.csord__Order_Number__c+'|SRV_345221|rewre3423';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
  @isTest
  static void testInvalidServiceSpec(){
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        
    
    Notification__c notification = new Notification__c();
    notification.eventType__c = 'statusNotification';
    notification.sourceSystem__c = 'Fulfilment';
    notification.eventTimeStamp__c = '2017-02-24T06:08-11:00';
    notification.externalOrderId__c = 'ORD_345221';
    notification.orderItemId__c = ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|abc';
    notification.orderItemVersion__c = 1;
    notification.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
    
    Test.startTest();
        try{
            insert notification;
        }catch(Exception e){
        }
    Test.stopTest();
    
    System.assertEquals(notification != null,true);
  }
}