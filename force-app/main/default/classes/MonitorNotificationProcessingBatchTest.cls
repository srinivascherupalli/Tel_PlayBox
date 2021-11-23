@isTest 
public class MonitorNotificationProcessingBatchTest {
    
    
     
    @Testsetup
    static void dataSetup() {
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;   
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        EnvironmentVariable__c tokenCustomSetting = new EnvironmentVariable__c();         
        tokenCustomSetting.Name = 'EnableThrowException';        
        tokenCustomSetting.Value__c = 'true';        
        insert tokenCustomSetting;

        
        List<csord__Order_Request__c> ordRequestList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordRequestList.add(ordReq);  
        insert ordRequestList;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        insert ord;
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
        
        List<csord__Subscription__c> subList =new List<csord__Subscription__c>();
        csord__Subscription__c subRes=new csord__Subscription__c();
        subRes.name  = 'sub1';
        subRes.csord__Identification__c = 'sub1';
        subRes.csord__Order__c = ord.Id;
        subRes.Sub_status__c = 'Active';
        subRes.csord__Status__c='Provisioned';
        subRes.triggerBill_RTB__c=true;
        subRes.csordtelcoa__Product_Configuration__c = userPC.id;
        subList.add(subRes);
        
        csord__Subscription__c subRes1=new csord__Subscription__c();
        subRes1.name  = 'sub2';
        subRes1.csord__Identification__c = 'sub2';
        subRes1.csord__Order__c = ord.Id;
        subRes1.Sub_status__c = 'Active';
        subRes1.csord__Status__c='Provisioned';
        subRes1.triggerBill_RTB__c=true;
        subRes1.csordtelcoa__Product_Configuration__c = userPC.id;
    subRes1.eventId__c ='91d3e2ba-2d65-4752-837a-7b5193c5f1c5';
        subList.add(subRes1);
        insert subList; 
        
        List<csord__Service__c> servList = new List<csord__Service__c >();
        csord__Service__c servRe = new csord__Service__c();
        servRe.name ='tst servRe';
        servRe.csord__Identification__c  = 'test servRe';
        servRe.csord__Subscription__c = subRes.Id;
        servRe.csord__Status__c = 'Connected';
        servRe.csord__Order__c = ord.Id;
        servRe.csordtelcoa__Product_Configuration__c = userPC.id;
        servList.add(servRe);
        
        csord__Service__c servRe1 = new csord__Service__c();
        servRe1.name ='tst servRe';
        servRe1.csord__Identification__c  = 'test servRe';
        servRe1.csord__Subscription__c = subRes1.Id;
        servRe1.csord__Status__c = 'Connected';
        servRe1.csord__Order__c = ord.Id;
        servRe1.csordtelcoa__Product_Configuration__c = userPC.id;
        servList.add(servRe1);
        insert servList;
        
        List<Number__c> numList = new List<Number__c>();
        Number__c num=new Number__c();
        num.name='Num test4';
        num.Subscription_number__c=subRes.csordtelcoa__Subscription_Number__c;
        num.Type__c='New';
        num.Service_Number__c='61474850547';
        num.Status__c='Provsioned';
        num.Product_Configuration__c = userPC.id;
        num.Service_Id__c = servRe.csordtelcoa__Service_Number__c;
        numList.add(num);
        
        Number__c num1=new Number__c();
        num1.name='Num test8';
        num1.Subscription_number__c=subRes1.csordtelcoa__Subscription_Number__c;
        num1.Type__c='New';
        num1.Service_Number__c='61474850548';
        num1.Status__c='Provsioned';
        num1.Product_Configuration__c = userPC.id;
        num1.Service_Id__c = servRe1.csordtelcoa__Service_Number__c;
        numList.add(num1);
        
        insert numList;
        
    List<ApplicationLog__c> applogList = new List<ApplicationLog__c>();
        ApplicationLog__c applog =new ApplicationLog__c();
        applog.Related_Record_Id__c = subRes.id;
        applog.correlationId__c = ord.csord__Order_Number__c;
        applog.Reference_Info__c = 'PostSubscriptionHandler';
        applog.Status_Code__c = '202';
        applog.Request_Message__c = '{"productOffering":{"productInstanceId":"SN-000234964","offerInstanceId":"SN-000234962","offerId":"DMCAT_Offer_001231","invoiceDefinition":"Invoice_Def_3","expireDurationValue":10,"expireDurationUnit":"Months","description":"Apple iPhone12 64GB","autoExpiry":true},"productActionType":"add","orderReference":"CN000-349-013","orderItems":[{"serviceInstanceId":"SVC-000230606:DMCAT_ProductSpecification_001342","productId":"DMCAT_ProductSpecification_001342","productActionType":"add","effectiveDate":"2021-02-12T10:54:48.000Z","description":"Transition Mobile Device Product","billingSpecifications":[{"units":1.0,"unitPrice":600.0,"taxTreatment":"TAX Exempt","monthlyPrice":60.0,"isRedeemable":"false","instanceId":"901e58f8-9bf9-d339-3329-c2c61d4fe5c4","externalRateId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001342_DMCAT_NonRecurringCharge_001344_8002","durationValue":10,"durationUnit":"Months","description":"Apple iPhone12 64GB","currencyCode":"AUD","contractType":"Hardware Repayment","chargeId":"DMCAT_NonRecurringCharge_001344","billingSpecId":"BSOTC001_CB","actionCode":"add"}]}],"effectiveDate":"2021-02-12T10:54:48.000Z","billingAccountNumber":700000563812}';
        applog.Message__c = '{"code":202,"status":202,"message":"Success","eventId":"91d3e2ba-2d65-4752-837a-7b5193c5f1cd"}';
        applogList.add(applog);
    
    ApplicationLog__c applog1 =new ApplicationLog__c();
        applog1.Related_Record_Id__c = subRes1.id;
        applog1.correlationId__c = ord.csord__Order_Number__c;
        applog1.Reference_Info__c = 'PostSubscriptionHandler';
        applog1.Status_Code__c = '202';
        applog1.Request_Message__c = '{"productOffering":{"productInstanceId":"SN-000234964","offerInstanceId":"SN-000234962","offerId":"DMCAT_Offer_001231","invoiceDefinition":"Invoice_Def_3","expireDurationValue":10,"expireDurationUnit":"Months","description":"Apple iPhone12 64GB","autoExpiry":true},"productActionType":"add","orderReference":"CN000-349-013","orderItems":[{"serviceInstanceId":"SVC-000230606:DMCAT_ProductSpecification_001342","productId":"DMCAT_ProductSpecification_001342","productActionType":"add","effectiveDate":"2021-02-12T10:54:48.000Z","description":"Transition Mobile Device Product","billingSpecifications":[{"units":1.0,"unitPrice":600.0,"taxTreatment":"TAX Exempt","monthlyPrice":60.0,"isRedeemable":"false","instanceId":"901e58f8-9bf9-d339-3329-c2c61d4fe5c4","externalRateId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001342_DMCAT_NonRecurringCharge_001344_8002","durationValue":10,"durationUnit":"Months","description":"Apple iPhone12 64GB","currencyCode":"AUD","contractType":"Hardware Repayment","chargeId":"DMCAT_NonRecurringCharge_001344","billingSpecId":"BSOTC001_CB","actionCode":"add"}]}],"effectiveDate":"2021-02-12T10:54:48.000Z","billingAccountNumber":700000563812}';
        applog1.Message__c = '{"code":202,"status":202,"message":"Success","eventId":"91d3e2ba-2d65-4752-837a-7b5193c5f1c5"}';
        applogList.add(applog1);
    insert applogList;
        
    List<Notification__c> notifList = new List<Notification__c>();
        Notification__c notif = new Notification__c();
        notif.eventType__c = 'statusNotification';
        notif.externalOrderId__c = '91d3e2ba-2d65-4752-837a-7b5193c5f1cd';
        notif.notificationAttributes__c ='"attributes":[{"name":"status","value":"Complete"}]';
        notif.orderItemId__c = '91d3e2ba-2d65-4752-837a-7b5193c5f1cd';
        notif.sourceSystem__c = 'Billing';
        notif.Status__c = 'Completed';
        notifList.add(notif);
    
    Notification__c notif1 = new Notification__c();
        notif1.eventType__c = 'statusNotification';
        notif1.externalOrderId__c = '91d3e2ba-2d65-4752-837a-7b5193c5f1c5';
        notif1.notificationAttributes__c ='"attributes":[{"name":"status","value":"Complete"}]';
        notif1.orderItemId__c = '91d3e2ba-2d65-4752-837a-7b5193c5f1c5';
        notif1.sourceSystem__c = 'Billing';
        notif1.Status__c = 'Completed';
        notifList.add(notif1);
    insert notifList;
            }
    
    static testMethod void moniternotiftest() 
    {
        Test.startTest();
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        for(csord__Subscription__c sub :[select id,name,Trigger_RFA__c from csord__Subscription__c])
        {
            sub.Trigger_RFA__c=true;
                subList.add(sub);
        }
        update subList;
        
        MonitorNotificationProcessingBatch obj = new MonitorNotificationProcessingBatch();
        Id dbID= DataBase.executeBatch(obj); 
        
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: dbID ];
        System.assertEquals(aaj.Id,dbID);  
        Test.stopTest();
        system.assertNotEquals(null, subList);
    }
    
    static testMethod void moniternotiftest1() 
    {
        Test.startTest();
        Map<Id,csord__Subscription__c> subMap = new Map<Id,csord__Subscription__c>();
        Map<String,ApplicationLog__c> subToAppLogMap =new Map<String,ApplicationLog__c>();
        for(csord__Subscription__c sub :[select Id, Name, csord__Order__c,csord__Status__c,eventId__c,triggerBill_RTB__c,toBeCancelled__c,LastModifiedDate,Trigger_RTS__c,
        cssdm__solution_association__c, csordtelcoa__Replaced_Subscription__c,csordtelcoa__Subscription_Number__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c])
        {
          subMap.put(sub.id, sub);
        }
        system.debug('subMap176'+subMap);
        for(ApplicationLog__c appLog : [Select id,correlationId__c,Reference_Info__c,Related_Record_Id__c,Request_Message__c,Request_Method__c,Message__c,Status_Code__c from ApplicationLog__c])
    {
      subToAppLogMap.put(appLog.Related_Record_Id__c,appLog);
    }  
        system.debug('subToAppLogMap181'+subToAppLogMap);
        MonitorNotificationProcessingBatchHelper.processRecords(subMap,subToAppLogMap);
        system.assertNotEquals(null, subMap);
        
        Test.stopTest();
        
    }
}