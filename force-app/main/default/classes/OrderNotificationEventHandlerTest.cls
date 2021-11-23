/*********************************************************************************************************************************
*Class Name      :   OrderNotificationEventHandler
Test Class : OrderNotificationEventHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vaibhav Deshpande       7/10/2019      EDGE-115930
2.            Prajakta Patil          4/02/2020       EDGE-142214
3.            Pawan                   30/11/2020    EDGE-170548
*********************************************************************************************************************************
*/
 
@isTest
public class OrderNotificationEventHandlerTest {
    @TestSetup static void dataSetup(){
         Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
       EnvironmentVariable__c tokenCustomSetting = new EnvironmentVariable__c();         
      tokenCustomSetting.Name = 'EnableThrowException';        
       tokenCustomSetting.Value__c = 'false';        
      insert tokenCustomSetting;    
    
    RecordType RT = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Enterprise - Standard' Limit 1];
        Opportunity opp = new Opportunity( Name = 'test opportunity', AccountId= acc.Id, Product_Domain__c = 'MOBILES', StageName='Develop', Description='Test Opp', Pricing_Method__c='PET', Contract_Type__c='BSA',Billing_Solution__c='Standard', recordtypeId=RT.id);   //Updated recordType id from hardcorded value to actual value
        opp.CloseDate = system.today();
        insert opp;
    
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
    
     csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        insert ord;
    
       csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9b0a915c-cf98-4ba4-83ee-507027d1d99b';
        subs.csord__Status__c='Active';
        subs.Suspension_reason__c='Requested by Customer';
        insert subs;
    
      cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
    insert userPD;
    
    cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
    
          List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
    serv.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '4';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord.Id;
        servs.add(serv1);
    insert servs;
    
     Appointment__c app = new Appointment__c();
        app.name = 'app1';
        app.SlotId__c='1234';
        insert app;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Disconnect","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","instanceId":"","guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"metadata":{},"includeBilling":false,"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);
    
    insert atts;
        
    }
    
     @isTest
    static void testEventHandler(){
        Test.startTest();
        
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<NotificationParameters> parameters = new List<NotificationParameters>();
        NotificationParameters evt=new NotificationParameters();
        
        EventMSCallBackDTO eventMS = new EventMSCallBackDTO();
         List<EventMSCallBackDTO> EventMSCallBackList = new List<EventMSCallBackDTO>();
        
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        notif.externalOrderVersion__c = 1;
        insert notif;
        
        
         Notification__c notif1 = new Notification__c();
        notif1.externalOrderId__c = 'dummyon123';
        notif1.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif1.orderItemId__c = 'dummyon123'+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif1.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif1.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
        notif1.eventType__c = 'statusNotification';
        notif1.orderItemVersion__c = 1;
        notif1.sourceSystem__c = 'Fulfilment';
        notif1.Status__c = 'Pending';
        notif1.externalOrderVersion__c = 1;
        insert notif1;
        
        
      
        evt.orderItemId=(string)notif.orderItemId__c;
        evt.notificationAttributes=(string)notif.notificationAttributes__c;
    evt.eventType=(string)notif.eventType__c;
        evt.orderItemDetails=(string)notif.orderItemDetails__c;
        evt.sourceSystem=(string)notif.sourceSystem__c;
        evt.errorDetails='Na';  
        evt.externalOrderId = ord.csord__Order_Number__c;
        parameters.add(evt);
        
          NotificationParameters evt1=new NotificationParameters();
         evt1.orderItemId=(string)notif1.orderItemId__c;
        evt1.notificationAttributes=(string)notif1.notificationAttributes__c;
       evt1.eventType=(string)notif1.eventType__c;
        evt1.orderItemDetails=(string)notif1.orderItemDetails__c;
        evt1.sourceSystem=(string)notif1.sourceSystem__c;
        evt1.errorDetails='Na';  
        evt1.externalOrderId = (string)notif1.externalOrderId__c;
        parameters.add(evt1);
        
        List<NotificationParameters> tempNotifList = new List<NotificationParameters>();
        tempNotifList.add(evt);
        
        Map < String, List<NotificationParameters >> orderItemIdNotifMap = new Map < String, List<NotificationParameters >>();
        orderItemIdNotifMap.put(evt.orderItemId,tempNotifList);
        
        OrderNotificationEventHandler.sort(parameters);
        OrderNotificationEventHandler.EventHandler(parameters);
        
        eventMS.msCorrelationId =notif.msCorrelationId__c;
        eventMS.orderItemId =(string)notif.orderItemId__c;
        eventMS.status = 'completed';
        EventMSCallBackList.add(eventMS);
        EventMSCallBack__e EventMSobj = new EventMSCallBack__e ();
        EventMSobj.eventresponse__c = JSON.serialize(EventMSCallBackList);
       // insert EventMSobj;
      
        
      
       // insert eventMS;
       
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
       
        System.assertEquals('tst service', svc.Name);
        
    }
     @isTest
    static void testpublishEventCallbackMS(){
        Test.startTest();
        
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<NotificationParameters> parameters = new List<NotificationParameters>();
        NotificationParameters evt=new NotificationParameters();
        
        EventMSCallBackDTO eventMS = new EventMSCallBackDTO();
         List<EventMSCallBackDTO> EventMSCallBackList = new List<EventMSCallBackDTO>();
        
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Completed';
        insert notif;
        evt.orderItemId=(string)notif.orderItemId__c;
        evt.notificationAttributes=(string)notif.notificationAttributes__c;
    evt.eventType=(string)notif.eventType__c;
        evt.orderItemDetails=(string)notif.orderItemDetails__c;
        evt.sourceSystem=(string)notif.sourceSystem__c;
        evt.errorDetails='Na';  
        parameters.add(evt);
        
        List<NotificationParameters> tempNotifList = new List<NotificationParameters>();
        tempNotifList.add(evt);
        
        Map<string,string> orderItemIdstatusMap = new Map<string,string>();
        orderItemIdstatusMap.put(notif.orderItemId__c,notif.Status__c);
        //Map < String, List<NotificationParameters >> orderItemIdNotifMap = new Map < String, List<NotificationParameters >>();
       // orderItemIdNotifMap.put(evt.orderItemId,tempNotifList);
        
        OrderNotificationEventHandler.publishEventCallbackMS(tempNotifList,orderItemIdstatusMap);
        
        Test.stopTest();
         System.assertNotEquals(null,tempNotifList);
    }
    
    
     @isTest
    static void testEventHandlerSubStage(){
        String orderItemId,notificationAttributes,eventType,orderItemDetails,sourceSystem,errorDetails,notificationId;
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<NotificationParameters> parameters = new List<NotificationParameters>();
        NotificationParameters evt=new NotificationParameters();
      
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
        notif.eventType__c = 'subStageNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        evt.orderItemId=(string)notif.orderItemId__c;
        evt.notificationAttributes=(string)notif.notificationAttributes__c;
    evt.eventType=(string)notif.eventType__c;
        evt.orderItemDetails=(string)notif.orderItemDetails__c;
        evt.sourceSystem=(string)notif.sourceSystem__c;
        evt.errorDetails='Na';  
        parameters.add(evt);
        
        OrderNotificationEventHandler.EventHandler(parameters);
        NotificationParameters.testdata();
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
       
        System.assertEquals('tst service', svc.Name);
        
    }

    @isTest
    static void testbillingNotificationHandler(){
        Test.startTest();
        List<NotificationParameters> parameters = new List<NotificationParameters>();
                 csord__Subscription__c subs=[select id,eventId__c,csord__Order__r.Name from csord__Subscription__c where name  ='test subs' AND csord__Order__r.Name= 'TestOrder' LIMIT 1];
                 
        Notification__c notif9 = new Notification__c();
        notif9.Name='Notif1';
        notif9.externalOrderId__c = (String)subs.eventId__c;
        notif9.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif9.orderItemId__c = (String)subs.eventId__c;
        notif9.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif9.eventType__c = 'statusNotification';
        notif9.orderItemVersion__c = 1;
        notif9.sourceSystem__c = 'Billing';
        notif9.Status__c = 'Completed';
        insert notif9;
         
        NotificationParameters evt = new NotificationParameters();
        evt.orderItemId=(String)subs.eventId__c;
        evt.notificationAttributes='"attributes":[{"name":"status","value":"Complete"}]';
        evt.externalOrderId = (String)subs.eventId__c;
        evt.eventType='statusNotification';
        evt.sourceSystem='Billing';
        parameters.add(evt);
         
        
        OrderNotificationEventHandler.billingNotificationHandler(parameters);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
       
        System.assertEquals('tst service', svc.Name);
    }
    
    //added for EDGE-170548
    @isTest
    static void createNotificationParameterListTest(){
        
        OrderNotification__e event = new OrderNotification__e();
        
        event.errorDetails__c = null;
        event.notificationAttributes__c = '"attributes":[{"name":"telstraCommittedDate","value":"2018-12-27T05:56:03+11:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-02-20T05:40:54+11:00"}, {"name":"productCompletionDate","value":"2020-02-20T05:39:54+11:00"}, {"name":"status","value":"In Progress"}]';
        event.orderItemDetails__c = '"product":{"productId": "7200c94d-ad78-0078-c8d3-b5c586d50313","status": "In Progress","attributes": [],"childProduct": [{"productId": "fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","status": "In Progress","attributes": []}]}';
        event.eventType__c = 'OrderNotification';
        event.orderItemId__c = 'ON12345' +'|'+'SVC123456'+'|'+'7200c94d-ad78-0078-c8d3-b5c586d50313';
        event.sourceSystem__c = 'Fulfilment';
        event.sequence__c = 1;
        event.msCorrelationId__c = '5463873930';
        event.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event.externalOrderId__c = 'ON12345';
        event.externalOrderVersion__c = 2;
        
         NotificationParameters notificationParameters = OrdsNotifTriggerHelper.createNotificationParameterList(event);
         System.assertEquals(2,notificationParameters.externalOrderVersion);
        
    }   

}