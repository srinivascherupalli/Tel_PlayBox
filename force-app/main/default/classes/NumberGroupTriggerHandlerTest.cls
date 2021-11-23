@isTest
private class NumberGroupTriggerHandlerTest {
     
    @TestSetup static void dataSetup() { 
        Account acc = new Account(); 
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
		
		List<BDS_Notify_Settings__c> csList = new List<BDS_Notify_Settings__c>(); //EDGE-170552	
        BDS_Notify_Settings__c bdscustomSetting1 = new BDS_Notify_Settings__c();	
        bdscustomSetting1.name='Feature Level';	
        bdscustomSetting1.Value__c ='FeatureLevelShadow';	
        bdscustomSetting1.Is_SI5_Offer__c =true;	
        csList.add(bdscustomSetting1);	
        BDS_Notify_Settings__c bdscustomSetting2 = new BDS_Notify_Settings__c(); //EDGE-170552	
        bdscustomSetting2.name='Technical Support';	
        bdscustomSetting2.Value__c ='TechnicalSupportShadow';	
        bdscustomSetting2.Is_SI5_Offer__c =true;	
        csList.add(bdscustomSetting2);	
        insert csList;
        
        csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        order.csord__Order_Request__c = ordReq.Id;
		order.Scenario_Type__c = 'Manage Fixed Numbers';	
        order.csord__Status2__c = 'Completed';
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
		Number_Group__c newNumberGroup = new Number_Group__c();	
        newNumberGroup.Subscription_number__c = 'Sub5678';	
        newNumberGroup.OrderId__c = order.Id;	
        insert newNumberGroup;	
        
        
    }

    @isTest
    static void testhandleBeforeUpdate(){
        /*Number_Group__c newNumberGroup = new Number_Group__c();
        newNumberGroup.Subscription_number__c = 'Sub5678';
        insert newNumberGroup;*/

        Number_Group__c ng = [Select Id, Subscription_number__c, Service_Instance_Id__c from Number_Group__c where Subscription_number__c = 'Sub5678'];
        csord__Subscription__c sub = [select Id, csordtelcoa__Subscription_Number__c from csord__Subscription__c];
        
        Test.startTest();
        ng.Subscription_number__c = sub.csordtelcoa__Subscription_Number__c;
        update ng;
        Test.stopTest();
        ng = [Select Id, Subscription_number__c, Service_Instance_Id__c from Number_Group__c where Subscription_number__c =: sub.csordtelcoa__Subscription_Number__c];
        System.debug('ng.Service_Instance_Id__c'+ng.Service_Instance_Id__c);
        System.assertNotEquals(ng.Service_Instance_Id__c, Null, 'Service_Instance_Id__c is null');
    }

    @isTest
    static void testhandleBeforeInsert(){
        csord__Subscription__c sub = [select Id, csordtelcoa__Subscription_Number__c from csord__Subscription__c];
        
        Test.startTest();
        Number_Group__c newNumberGroup = new Number_Group__c();
        newNumberGroup.Subscription_number__c = sub.csordtelcoa__Subscription_Number__c;
        insert newNumberGroup;
        Test.stopTest();
        Number_Group__c ng = [Select Id, Service_Instance_Id__c from Number_Group__c where Subscription_number__c =: sub.csordtelcoa__Subscription_Number__c];
        System.debug('ng.Service_Instance_Id__c'+ng.Service_Instance_Id__c);
        System.assertNotEquals(ng.Service_Instance_Id__c, Null, 'Service_Instance_Id__c is null');
    }
	
      @isTest	
    static void testhandleAfterUpdate(){	
        Number_Group__c ng = [Select Id, Subscription_number__c, Service_Instance_Id__c from Number_Group__c where Subscription_number__c = 'Sub5678'];	
        ng.status__c = 'Provisioned';	
		csord__Order__c orderObj = [select Id,csord__End_Date__c,telstra_ord_Start_DateTime__c from csord__Order__c where Scenario_Type__c = 'Manage Fixed Numbers' limit 1];	

        orderObj.Scenario_Type__c = 'Manage Fixed Numbers';	
        Test.startTest();  	
        update ng;	
        Test.stopTest();	
        //System.assertEquals(orderObj.csord__End_Date__c,Date.today());	
    }
}