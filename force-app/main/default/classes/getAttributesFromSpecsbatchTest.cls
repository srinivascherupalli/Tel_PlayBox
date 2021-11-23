/*************************************************************************************************
Name : getAttributesFromSpecsbatch
Test Class  : getAttributesFromSpecsbatchTest
Ch no 
1.  18/09/2020      Shubhi Vijayvergia   EDGE-157149 (new )
**************************************************************************************************/
@isTest()
public class getAttributesFromSpecsbatchTest {
    
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Billing_Account_Number__c = '700000449806';
        insert billingAccount;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(testAccount);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        //opp.Type = 'Disconnect';
        insert opp;
        
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = opp.Id;
        insert testBasket;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);     
        insert pdList;
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        insert  prodconfigList;
               
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c testOrder = ProductTestFactory.buildOrder('PrimaryOrder', testAccount.id, 'Created', ordReq.id);
        testOrder.csord__Order_Request__c = ordReq.Id;
        insert testOrder;
        
        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.serviceMSISDN__c='12346789';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = testAccount.Id;
        testSubscription2.csord__Order__c = testOrder.Id;
        testSubscription2.csord__Identification__c = 'test2';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription2.csord__Status__c = 'Pending';
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2};
        insert testSubsList;
         //service
        List<csord__Service__c> servlist=new List<csord__Service__c>();
        List<Attachment> atts = new List<Attachment>();
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c,csord__Order__c FROM csord__Subscription__c])
        {
            csord__Service__c serv = new csord__Service__c();
            serv.name ='testService_'+testSubs.id;
            serv.csord__Identification__c  = 'testIdentify_4';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = testSubs.id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            serv.csord__Order_Request__c = ordReq.Id;
            serv.csord__Order__c = testSubs.csord__Order__c;
            serv.Scenario_Type__c = 'Change of Mobile Number';
            servlist.add(serv);
            
            csord__Service__c serv1 = new csord__Service__c();
            serv1.name ='testService_4';
            serv1.csord__Identification__c  = 'testIdentify_4';
            serv1.csordtelcoa__Service_Number__c = '3';
            serv1.csord__Subscription__c = testSubs.id;
            serv1.csord__Status__c = 'Created';
            serv1.substage__c = 'Product Requirements Validation';
            serv1.Scenario_Type__c = 'Suspend';
            servlist.add(serv1);
        }
        //create service
        insert servlist;
        
        for(csord__Service__c serv:servlist){
            Attachment att1 = new Attachment();       
            att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"DMCAT_ProductSpecification_000263_Billing","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"},"additionalAttributes":{"SuspensionContext":"CUSTOMER"}}],"serviceId":"'+serv.id+'","legacyAttributes":[]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = serv.Id;
            atts.add(att1);
        }
        //create attachment
        insert atts;

    }
    @isTest
    static void excuteTest() {
        Test.StartTest();
            getAttributesFromSpecsbatch batch = new getAttributesFromSpecsbatch();
            Database.executeBatch(batch);
          System.assertEquals(0,batch.count);
        Test.StopTest(); 
        //ApplicationLog__c app=[Select id,Reference_Info__c from ApplicationLog__c limit 1];
        //System.assertNotEquals('getAttributesFromSpecsbatch', app.Reference_Info__c);
    }
    @isTest
    static void excuteTestcatch() {
        Test.StartTest();
            csord__Service__c serv=[Select id from csord__Service__c limit 1];
            Attachment att=new Attachment();
            att=[Select id,body from Attachment where parentid =:serv.id limit 1];
            String body='{"specifications":[}';
            att.body=Blob.valueOf(body);
            update att;
            getAttributesFromSpecsbatch batch = new getAttributesFromSpecsbatch();
            Database.executeBatch(batch);
          System.assertEquals(0,batch.count);
        Test.StopTest(); 
    }
}