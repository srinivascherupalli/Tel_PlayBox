@istest
public class ManageBillingSubsNotificationUtilTest {

    @Testsetup
    static void dataSetup(){
        
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='EnableHV';
        csSite.value__c='True';
        insert csSite;
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
               
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
    List<csord__Order_Request__c> ordRequestList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordRequestList.add(ordReq);
        
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        ordRequestList.add(ordReq1);
     
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        ordRequestList.add(ordReq2);
    
    csord__Order_Request__c ordReq3 = ProductTestFactory.buildOrderRequest();
        ordRequestList.add(ordReq3);
    
    csord__Order_Request__c ordReq4 = ProductTestFactory.buildOrderRequest(); //EDGE-170552
        ordRequestList.add(ordReq4);
    insert ordRequestList;
        
    List<csord__Order__c> orderlist = new List<csord__Order__c>();
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq1.id);
        primaryOrd.csord__Order_Request__c = ordReq1.Id;
        primaryOrd.csordtelcoa__Opportunity__c = opp.Id;
        orderlist.add(primaryOrd);        
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        ord.csord__Primary_Order__c = primaryOrd.id;
        orderlist.add(ord);
    
        insert orderlist;
        
        
     List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.csord__Status__c='Pending';
        subs.csordtelcoa__Subscription_Number__c ='SN-12345';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subList.add(subs);
       
        
        csord__Subscription__c subsBilling=new csord__Subscription__c();
        subsBilling.name  = 'test subs 2';
        subsBilling.csord__Identification__c = 'test identity';
        subsBilling.csord__Order__c = ord.Id;
        subsBilling.csord__Status__c='Pending';
        subsBilling.csordtelcoa__Subscription_Number__c ='SN-12346';
        subsBilling.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subList.add(subsBilling);
        
        csord__Subscription__c subsBilling2=new csord__Subscription__c();
        subsBilling2.name  = 'test subs 3';
        subsBilling2.csord__Identification__c = 'test identity1';
        subsBilling2.csord__Order__c = ord.Id;
        subsBilling2.csord__Status__c='Pending';
        subsBilling2.csordtelcoa__Subscription_Number__c ='SN-12347';
        subsBilling2.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subList.add(subsBilling2);
    
        insert subList;
        system.debug('subsList...'+subList);
        
        List<Number__c> numList = new List<Number__c>();
        
        Number__c num=new Number__c();
         num.name='Num test';
         num.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
         num.Type__c='New';
         num.Service_Number__c='61474850546';
         num.Status__c='Bill Readiness In Progress';
         num.Product_ID__c='gb58-89jk-yuit-fr46';
        numList.add(num);
        
         Number__c num4=new Number__c();
         num4.name='Num test4';
         num4.Subscription_number__c=subsBilling.csordtelcoa__Subscription_Number__c;
         num4.Type__c='New';
         num4.Service_Number__c='61474850547';
         num4.Status__c='Bill Readiness In Progress';
         num4.Product_ID__c='gb58-89jk-yuit-fr46';
        numList.add(num4);
         
        Number__c num5=new Number__c();
         num5.name='Num test4';
         num5.Subscription_number__c=subsBilling2.csordtelcoa__Subscription_Number__c;
         num5.Type__c='New';
         num5.Service_Number__c='61474850548';
         num5.Status__c='Active';
         num5.Product_ID__c='gb58-89jk-yuit-fr46';
        numList.add(num5);
     insert numList;
        system.debug('numList...'+numList);
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
    List<cscfga__Product_Configuration__c> listofPC = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        listofPC.add(userPC);
    
    insert listofPC;
    
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = 'svc-1235645';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c =  ord.Id;
        serv.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(serv);
        insert servs;
        
        List<Case> caseList = new List<Case>();
        Id objectRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Change of Billing Account').getRecordTypeId();
        Case testCase1 = new Case();
        testCase1.Status = 'New';
        testCase1.subject = 'TestCase';
        testCase1.Description = 'TestCaseDesc';
        testCase1.RecordTypeId = objectRecordTypeId;
        caseList.add(testCase1);
        Insert caseList;
        
        List<Subscriptions_to_Case_Association__c> subsToCaseList = new List<Subscriptions_to_Case_Association__c>();
        Subscriptions_to_Case_Association__c subToCase1 = new Subscriptions_to_Case_Association__c(Case__c=testCase1.Id,csord_Subscription__c=subs.Id,Status__c='In Progress',Billing_Account__c=billingAccount.Id);
        subsToCaseList.add(subToCase1);
        Subscriptions_to_Case_Association__c subToCase2 = new Subscriptions_to_Case_Association__c(Case__c=testCase1.Id,csord_Subscription__c=subsBilling.Id,Status__c='In Progress',Billing_Account__c=billingAccount.Id);
        subsToCaseList.add(subToCase2);
        Subscriptions_to_Case_Association__c subToCase3 = new Subscriptions_to_Case_Association__c(Case__c=testCase1.Id,csord_Subscription__c=subsBilling2.Id,Status__c='In Progress',Billing_Account__c=billingAccount.Id);
        subsToCaseList.add(subToCase3);
        Insert subsToCaseList;
        
		List<Attachment> attachmentList = Orchestration_TestUtility.buildAttachment(false, 1, servs, userPC.id);
        Attachment attprdchr= new Attachment();
        attprdchr.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.id+'","specifications":[{"additionalAttributes":{"CustomerFacingServiceId":"61474663325","parentSpec":"dd7a2442-bd58-20e6-891a-2fd078b3d210","IMSI":"5286475123"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL","PlanType":"Voice and Data"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"d5291cc4-f4a6-114e-de4d-369bcdf080f8","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","chargeId":"DMCAT_NonRecurringCharge_000601"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"20e0d4f9-d12d-d5f4-7478-b424f5a34f1e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"dd7a2442-bd58-20e6-891a-2fd078b3d210","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currency":"AUD","quantity":"1","chargeId":"DMCAT_RecurringCharge_000669","rateExcludeGST":13.63,"type":null,"frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"International call pack - premium","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","description":"Mobility_Billing_RecurringCharge_000669","endDate":"","guid":"39075166-8924-2c0b-e8e9-2adfa9cb48fb","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_669","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"40","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_PLAN-S","billingSpecId":"BSUSG001_CB","billDescription":"Includes 40 GB Domestic Data+Unlimited Standard Voice+SMS+MMS","chargeId":"DMCAT_Allowance_000637"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ed810ffb-a419-74b6-867e-c10f0baab01d","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"50.00","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4911","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"27b89bb2-431c-16cd-bd54-650f33dde86e","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium","chargeId":"DMCAT_Allowance_000643"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"7e8d7df0-ecdc-1e49-03ff-d08eda855fdd","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass","chargeId":"DMCAT_Allowance_000606"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"2dd0a1d6-8ed3-edf5-652f-26a3b296d1df","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup","chargeId":"DMCAT_Allowance_000607"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"88684d27-205d-528a-488e-151d84b4503e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"0a4f2805-1d50-7767-fa82-8ff9435913e7"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"a08b1510-b8b6-4d1d-6899-14bf513d68e4","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"0a4f2805-1d50-7767-fa82-8ff9435913e7","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"c67e4144-dc39-6bd2-85b1-a8a40673cb31","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"}]}');
        attprdchr.Name = 'ServiceSpecifications.json';
        attprdchr.ParentId = serv.Id;
        attachmentList.add(attprdchr);    
        insert attachmentList;
        
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('BillingAccountLookup', null, userPC.id);
        attList.add(attr1);
        insert attList;
    }
    
    @isTest
    static void testprocessNotification(){
        List<csord__Subscription__c> listOfSubs = [SELECT Id,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE csordtelcoa__Subscription_Number__c!=NULL];
        List<NotificationParameters>paramsList = new List<NotificationParameters>();
        Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
        
        Test.startTest();
        List<Number__c> listOfNum = [SELECT Id,Subscription_number__c FROM Number__c];
        for(integer i=0;i<listOfNum.size();i++){
            listOfNum[i].Subscription_number__c = listOfSubs[i]!=NUll?listOfSubs[i].csordtelcoa__Subscription_Number__c:NULL;
        }
        Update listOfNum;
        NotificationParameters  notif = new NotificationParameters();
        notif.externalOrderId = '3c47ad62-0a2f-4080-942d-ff4e037f329a';
        notif.eventTimestamp = '2018-02-24T06:08+10:00';
        notif.orderItemId = '3c47ad62-0a2f-4080-942d-ff4e037f329a';
        notif.notificationAttributes = '"attributes":[{"name":"status","value":"Success"}]';
        notif.subscriptionDetails = '[{"responseCode":"500","responsesDescription":"Internal Server Error","subscriptionId":"'+listOfSubs[0].csordtelcoa__Subscription_Number__c+'"},{"responseCode":"200","responsesDescription":"Success","subscriptionId":"'+listOfSubs[1].csordtelcoa__Subscription_Number__c+'"},{"responseCode":"422","responsesDescription":"Subscription b8905354-a164-b480-9fb2-75c2d1a8498a is already active in Billing systems","subscriptionId":"'+listOfSubs[2].csordtelcoa__Subscription_Number__c+'"}]';
        notif.eventType = 'subscriptionNotification';
        notif.orderItemVersion = 1;
        notif.sourceSystem = 'Billing';
        paramsList.add(notif);
        orderItemIdNotifMap.put(notif.orderItemId,paramsList);
        
        ManageBillingSubsNotificationHelper.processSubscriptionNotification(orderItemIdNotifMap,paramsList);
        Test.stopTest();
        List<csord__Subscription__c> subList = [SELECT Id, csord__Status__c FROM csord__Subscription__c WHERE csordtelcoa__Subscription_Number__c!=NULL];
        for(csord__Subscription__c subs : subList){
             System.assertEquals(subs.csord__Status__c,'Active');
        }
        
        List<Subscriptions_to_Case_Association__c> subToCaseList = [SELECT Id, Billing_Account__c,Status__c FROM Subscriptions_to_Case_Association__c];
        System.assertEquals(subToCaseList[0].Status__c,'Failed');
        System.assertEquals(subToCaseList[1].Status__c,'Completed');
        
        List<Case> caseList = [SELECT Id,Status FROM Case];
        for(Case subsCase : caseList){
            System.assertEquals(subsCase.Status,'Closed');
        }
        
        List<cscfga__Attribute__c> attList = [SELECT Name,cscfga__Value__c,cscfga__Display_Value__c FROM cscfga__Attribute__c];
        System.debug('Name...'+attList[0].Name+'....'+attList[0].cscfga__Value__c+'....'+attList[0].cscfga__Display_Value__c);
        for(cscfga__Attribute__c att : attList){
            System.assertEquals(subToCaseList[0].Billing_Account__c, att.cscfga__Value__c);
        }
    }
    
    @isTest
    static void testprocessNotification_Exception(){
        List<csord__Subscription__c> listOfSubs = [SELECT Id,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE csordtelcoa__Subscription_Number__c!=NULL];
        List<NotificationParameters>paramsList = new List<NotificationParameters>();
        Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
        
        Test.startTest();
        List<Number__c> listOfNum = [SELECT Id,Subscription_number__c FROM Number__c];
        for(integer i=0;i<listOfNum.size();i++){
            listOfNum[i].Subscription_number__c = listOfSubs[i]!=NUll?listOfSubs[i].csordtelcoa__Subscription_Number__c:NULL;
        }
        Update listOfNum;
        NotificationParameters  notif = new NotificationParameters();
        notif.externalOrderId = '3c47ad62-0a2f-4080-942d-ff4e037f329a';
        notif.eventTimestamp = '2018-02-24T06:08+10:00';
        notif.orderItemId = '3c47ad62-0a2f-4080-942d-ff4e037f329a';
        notif.notificationAttributes = '"attributes":[{"name":"status","value":"Success"}]';
        notif.subscriptionDetails = '[{"respo,"responsesDescription":"Internal Server Error","subscriptionId":"'+listOfSubs[0].csordtelcoa__Subscription_Number__c+'"},{"responseCode":"200","responsesDescription":"Success","subscriptionId":"'+listOfSubs[1].csordtelcoa__Subscription_Number__c+'"},{"responseCode":"422","responsesDescription":"Subscription b8905354-a164-b480-9fb2-75c2d1a8498a is already active in Billing systems","subscriptionId":"'+listOfSubs[2].csordtelcoa__Subscription_Number__c+'"}]';
        notif.eventType = 'subscriptionNotification';
        notif.orderItemVersion = 1;
        notif.sourceSystem = 'Billing';
        paramsList.add(notif);
        orderItemIdNotifMap.put(notif.orderItemId,paramsList);
        
        ManageBillingSubsNotificationHelper.processSubscriptionNotification(orderItemIdNotifMap,paramsList);
        Test.stopTest();
        
        List<Case> caseList = [SELECT Id,Status FROM Case];
        for(Case subsCase : caseList){
            System.assertEquals(subsCase.Status,'New');
        }
    }
}