/********************************************************
Class Name      :   BillingOrderServiceTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Shreya Jaiswal      	15/10/19      	EDGE-107514
2.			  Prajakta Patil		22/10/19        EDGE-81140
3.			  Pratyush Mishra		21/11/19        EDGE-113536 Header Map changes, added Correlation-Id as order Number
4.            vaibhav Deshpande     23/01/2020      EDGE-120128
5. 		      Prajakta Patil        11/03/2020      EDGE-137876
**********************************************************
*/

@isTest
    public class BillingOrderServiceTest {      
        @testsetup 
        public static void dataSetup(){
            Environment_Configurations__c ec = new Environment_Configurations__c(Custom_Logging__c = true);
            insert ec;
            EnvironmentVariable.put('access_token', '1234');
            EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6/allocateBan');
            EnvironmentVariable.put('okapi_east_url', '/?');
            EnvironmentVariable.put('okapi_client_id', '1234');
            EnvironmentVariable.put('okapi_client_secret', '1234');
            EnvironmentVariable.put('okapi_token_url', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
            
            Account acc = new Account();
            acc.Name = 'test Account' ;
            acc.Type = 'Competitor' ;
            insert acc;
            
            cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
            insert addr;
            Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
            insert contact;
            cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
            site.Primary_Contact__c = contact.Id;
            site.cscrm__Installation_Address__r = addr;
            insert site;
            
            Billing_Account__c bac=new Billing_Account__c();
            bac.billing_account_number__c='123456789632';
            bac.Billing_Account_Name__c ='test_bill';
            bac.Billing_Address__c=addr.id;
            bac.Billing_Account_Owner__c=contact.id;
            insert bac;
            
            csord__Order__c ord = new csord__Order__c();
            ord.csord__Identification__c = 'test identification';
            ord.csord__Account__c = acc.id;
            ord.csord__Order_Type__c = 'test order' ;
            ord.Billing_Account__c=bac.id;
            insert ord;
            
            csord__Order__c ord1 = new csord__Order__c();
            ord1.csord__Identification__c = 'test identification';
            ord1.csord__Account__c = acc.id;
            ord1.csord__Order_Type__c = 'test order' ;
            ord1.Billing_Account__c=bac.id;
            insert ord1;
            
            csord__Order__c secOrd = new csord__Order__c();
            secOrd.csord__Identification__c = 'test identification';
            secOrd.csord__Account__c = acc.id;
            secOrd.csord__Order_Type__c = 'test order' ;
            secOrd.Billing_Account__c=bac.id;
            secOrd.csord__Primary_Order__c = ord.id;
            insert secOrd;
            
            cscfga__Configuration_Offer__c OriginatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer');
            insert OriginatingOffer;
            
            cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
            productConfig.Offer_Reference__c = OriginatingOffer.id;
            productConfig.Type__c='New';
            insert productConfig;
            
            csord__Subscription__c subs=new csord__Subscription__c();
            subs.name  = 'test subs';
            subs.csord__Identification__c = 'test identity';
            subs.Site__c = site.Id;
            subs.Billing_Account__c=bac.id;
            subs.csord__Status__c='Subscription Created';
            subs.csord__Order__c = secOrd.Id;
            subs.csordtelcoa__Product_Configuration__c = productConfig.id;
            insert subs;
            
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csord__Subscription__c  = subs.id;
            serv.csord__Order__c = ord.id;
            serv.csordtelcoa__Service_Number__c = '3';
            insert serv;
            
            csord__Subscription__c subs1=new csord__Subscription__c();
            subs1.name  = 'test subs1';
            subs1.csord__Identification__c = 'test identity';
            subs1.Site__c = site.Id;
            subs1.Billing_Account__c=bac.id;
            subs1.csord__Status__c='Subscription Created';
            subs1.csord__Order__c = ord1.Id;
            subs1.csordtelcoa__Product_Configuration__c = productConfig.id;
            insert subs1;
            
            csord__Service__c serv1 = new csord__Service__c();
            serv1.name ='tst service1';
            serv1.csord__Identification__c  = 'test identify';
            serv1.csord__Subscription__c  = subs1.id;
            serv1.csord__Order__c = ord.id;
            serv1.csordtelcoa__Service_Number__c = '3';
            serv1.csordtelcoa__Product_Configuration__c=productConfig.id;
            insert serv1;
            
            Charge_Line_Item__c cli= new Charge_Line_Item__c();
            cli.Name='test';
            cli.CorrelationId__c='1234566';
            cli.status__c='new';
            cli.serviceId__c=serv1.id;
            cli.BusinessID__c='DMCAT_Billing_000420';
            insert cli;
            
            Price_Schedule_Line_Item__c psli=new Price_Schedule_Line_Item__c();
            psli.fromPeriod__c='0';
            psli.toPeriod__c='20';
            psli.status__c='new';
            psli.chargeInstance__c=cli.id;
            psli.unitPrice__c=20.0;
            insert psli;
            

            //List<Attachment> atts = new List<Attachment>();
            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000074","attributes" : {"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","unitPrice" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "description" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000074","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = serv.Id;
            insert att1;
            
              
        }
        
        @isTest static void testGetInstance()
        {
            BillingOrderService.getInstance();
            system.assertNotEquals(null,BillingOrderService.getInstance());
        }
        
        @isTest static void testGetInstanceUtil()
        {
            BillingOrderUtil.getInstance();
            system.assertNotEquals(null,BillingOrderUtil.getInstance());
        }
        
        @istest static void testRequestBillingAccountAllocation200(){
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', null, new Map<String, String>()));
            Test.startTest();
            String billAccount = BillingOrderService.requestBillingAccountAllocation();
            Test.stopTest();
            System.assertnotEquals(billAccount,'123456789321');
        }
        @isTest static void testRequestBillingAccountAllocation201() {
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(201, 'OK', '', new Map<String, String>()));
            Test.startTest();
            string billAccount_1 = BillingOrderService.requestBillingAccountAllocation();
            Test.stopTest();
            System.assertnotEquals(billAccount_1,'123456789321');
        }
        
        @isTest static void testRequestBillingAccountAllocation400() {
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(400, 'OK', '', new Map<String, String>()));
            Test.startTest();
            string billAccount = BillingOrderService.requestBillingAccountAllocation();        
            Test.stopTest();
            System.assertnotEquals(billAccount,null);
        }
        
        @isTest static void testRequestBillingAccountAllocation404() {
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(404, 'OK', '', new Map<String, String>()));
            Test.startTest();
            string billAccount = BillingOrderService.requestBillingAccountAllocation();        
            Test.stopTest();
            System.assertnotEquals(billAccount,null);
        }
        @isTest static void testRequestBillingAccountAllocation600() {
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(400, 'OK', '', new Map<String, String>()));
            Test.startTest();
            string billAccount = BillingOrderService.requestBillingAccountAllocation();        
            Test.stopTest();
            System.assertnotEquals(billAccount,null);
        }
        @istest static void testRequestBillingAccountCreate202(){
            BillingAccountDTO billDto = new BillingAccountDTO();
           // billDto.Correlation-Id= '328fdbb9-a4e5-4c4c-b72f-0be6b9422917';
            BillingAccountDTO.billingAccount billAcc = new BillingAccountDTO.billingAccount();
                billAcc.billingAccountNumber = 123456789;
                billAcc.billCycleDay = 7;
                billAcc.paymentTerms = 14;
                billAcc.language='English';
                billAcc.currencyCode='AUD';
                billAcc.rouCode='1234';
                billAcc.companyName = 'Company';
                
            BillingAccountDTO.BillingAddress billAdd = new BillingAccountDTO.BillingAddress();
                billAdd.address = 'LostmyWay'; 
                billAdd.locality = 'Sydney';
                billAdd.postcode = '2000';
                billAdd.state = 'NSW';
                billAdd.country = 'Aus';
                
            /*BillingAccountDTO.BillingContact billCon = new BillingAccountDTO.BillingContact();
                billCon.firstName = 'Joe';
                billCon.lastName = 'Blogg';
                billCon.companyName = 'Company';
                billCon.abn='1234';
                billDto.BillingAccount=billAcc;
                billDto.BillingAccount.BillingAddress=billAdd;
                billDto.BillingAccount.billingAccountOwner=billCon;*/
            
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(202, 'OK', '{"code":201,"status":201,"message":"Success"}', new Map<String, String>()));
            Test.startTest();
            String result = BillingOrderService.requestBillingAccountCreate(billDto);
            Test.stopTest();
            System.assertEquals('Created',result);
        }
        
        @isTest static void testRequestBillingAccountCreate400() {
            BillingAccountDTO billDto = new BillingAccountDTO();
            //billDto.Correlation-Id= '328fdbb9-a4e5-4c4c-b72f-0be6b9422917';
            BillingAccountDTO.billingAccount billAcc = new BillingAccountDTO.billingAccount();
                billAcc.billingAccountNumber = 12345678;
                billAcc.billCycleDay = 7;
                billAcc.companyName = 'Company';
            BillingAccountDTO.BillingAddress billAdd = new BillingAccountDTO.BillingAddress();
                billAdd.address = 'LostmyWay';
                billAdd.locality = 'Sydney';
                billAdd.postcode = '2000';
                billAdd.state = 'NSW';
                billAdd.country = 'Aus';
            /*BillingAccountDTO.BillingContact billCon = new BillingAccountDTO.BillingContact();
               
                billCon.firstName = 'Joe';
                billCon.lastName = 'Blogg';
                billCon.companyName = 'Company';*/
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(400, 'OK', '', new Map<String, String>()));
            Test.startTest();
            String result = BillingOrderService.requestBillingAccountCreate(billDto);
            Test.stopTest();
            System.assertEquals('Error',result);
            
        }
        /*@isTest static  void testCatch()
        {
            test.startTest();
            String result = BillingOrderService.requestBillingAccountCreate(null);
            test.stopTest();
            System.assertEquals('Created',result);
        }*/
        
        @isTest static void testRequestBillingAccountCreate404() {
            BillingAccountDTO billDto = new BillingAccountDTO();
          //  billDto.Correlation-Id= '328fdbb9-a4e5-4c4c-b72f-0be6b9422917';
            BillingAccountDTO.billingAccount billAcc = new BillingAccountDTO.billingAccount();
                billAcc.billingAccountNumber = 12345678;
                billAcc.billCycleDay = 7;
                billAcc.companyName = 'Company';
             BillingAccountDTO.BillingAddress billAdd = new BillingAccountDTO.BillingAddress();
                billAdd.address = 'LostmyWay';
                billAdd.locality = 'Sydney';
                billAdd.postcode = '2000';
                billAdd.state = 'NSW';
                billAdd.country = 'Aus';
            /*BillingAccountDTO.BillingContact billCon = new BillingAccountDTO.BillingContact();
               
                billCon.firstName = 'Joe';
                billCon.lastName = 'Blogg';
                billCon.companyName = 'Company';*/
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(404, 'OK', '', new Map<String, String>()));
            Test.startTest();
            String result = BillingOrderService.requestBillingAccountCreate(billDto);
            Test.stopTest();
            System.assertEquals('Error',result);
            
        }
       /* @isTest static void testPostSubscription400() {
        List<csord__Subscription__c> subsList = [select id,Name from csord__Subscription__c LIMIT 1];
            List<String> subIds = new List<String>();
            for(csord__Subscription__c subs :subsList){
                subIds.add(subs.id);
            }       
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(400, 'OK', '', new Map<String, String>()));
            Test.startTest();
            BillingOrderService.sendBillingOrder(subIds);
            Test.stopTest();
            List<csord__Subscription__c> subList = [select Id, Name, csord__Status__c from csord__Subscription__c WHERE Name ='test subs' LIMIT 1];
            if(!subsList.isEmpty())
                System.assertEquals('Subscription Created',subList[0].csord__Status__c);
        }*/
        @isTest static void test_postSubscription_404() {
        List<csord__Subscription__c> subsList = [select id, Name from csord__Subscription__c where Name='test subs' LIMIT 1];
            List<String> subIds = new List<String>();
             Map<Id,CSPOFA__Orchestration_Step__c>subscriptionIdStepMap= new Map<Id,CSPOFA__Orchestration_Step__c>();
            CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
            step.CSPOFA__Status__c ='Error';
            for(csord__Subscription__c subs :subsList){
                subIds.add(subs.id);
                subscriptionIdStepMap.put(subs.id,step);
            }       
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(404, 'OK', '', new Map<String, String>()));
            Test.startTest();
            Boolean isIncludeSolution = false;
            boolean isProductActionExpire = false;
           
            BillingOrderService.sendBillingOrder(subIds,isIncludeSolution,isProductActionExpire);
            Test.stopTest();
            List<csord__Subscription__c> subList = [select Id, Name, csord__Status__c from csord__Subscription__c WHERE Name ='test subs' LIMIT 1];
            if(!subsList.isEmpty())
                System.assertNotEquals(null,subList[0].csord__Status__c);
        }
         @isTest static void testPostSubscription202() {
            List<csord__Subscription__c> subsList = [select id,Name from csord__Subscription__c where Name='test subs' LIMIT 1];
            List<String> subIds = new List<String>();
              CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
             step.CSPOFA__Status__c ='Complete';
             Map<Id,CSPOFA__Orchestration_Step__c>subscriptionIdStepMap= new Map<Id,CSPOFA__Orchestration_Step__c>();
            for(csord__Subscription__c subs :subsList){
                subIds.add(subs.id);
                subscriptionIdStepMap.put(subs.id,step);
            }       
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(202, 'ACCEPTED', '', new Map<String, String>()));
            Test.startTest();
             Boolean isIncludeSolution = false;
             boolean isProductActionExpire = false;
             
            BillingOrderService.sendBillingOrder(subIds,isIncludeSolution,isProductActionExpire);
            Test.stopTest();
            List<csord__Subscription__c> subList = [select Id, Name, csord__Status__c from csord__Subscription__c WHERE Name ='test subs' LIMIT 1];
            if(!subsList.isEmpty())
                System.assertNotEquals(null,subList[0].csord__Status__c);
        }
        
        @isTest static void test_postSubscription_333() {
        List<csord__Subscription__c> subsList = [select id,Name from csord__Subscription__c where Name='test subs' LIMIT 1];
            List<String> subIds = new List<String>();
             CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
            step.CSPOFA__Status__c ='Error';
             Map<Id,CSPOFA__Orchestration_Step__c>subscriptionIdStepMap= new Map<Id,CSPOFA__Orchestration_Step__c>();
            for(csord__Subscription__c subs :subsList){
                subIds.add(subs.id);
                subscriptionIdStepMap.put(subs.id,step);
            }       
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(333, 'OK', '', new Map<String, String>()));
            Test.startTest();
            Boolean isIncludeSolution = false;
            boolean isProductActionExpire = false;
            
            BillingOrderService.sendBillingOrder(subIds,isIncludeSolution,isProductActionExpire);
            Test.stopTest();
            List<csord__Subscription__c> subList = [select Id, Name, csord__Status__c from csord__Subscription__c WHERE Name ='test subs' LIMIT 1];
            if(!subsList.isEmpty())
                System.assertNotEquals(null,subList[0].csord__Status__c);
        }
        
        @isTest static void test_requestBillingAccountDetails_200_201() {
           List<Billing_Account__c> bill= [select billing_account_number__c,Name,Billing_Address__c FROM Billing_Account__c WHERE Billing_Account_Name__c='test_bill'LIMIT 1];
            String ban =String.valueOf(bill[0].billing_account_number__c);
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', '', new Map<String, String>()));
            Test.startTest();
            BillingOrderService.requestBillingAccountDetails(ban);
            Test.stopTest();
            System.assertEquals('123456789632',ban);
                   
        }
        @isTest static void test_requestBillingAccountDetails_404() {
           List<Billing_Account__c> bill= [select billing_account_number__c,Name,Billing_Address__c FROM Billing_Account__c WHERE Billing_Account_Name__c='test_bill'LIMIT 1];
            String ban =String.valueOf(bill[0].billing_account_number__c);
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(404, 'OK', '', new Map<String, String>()));
            Test.startTest();
            BillingOrderService.requestBillingAccountDetails(ban);
            Test.stopTest();
            System.assertEquals('123456789632',ban);
                   
        }
         @isTest static void test_requestBillingAccountDetails_600() {
           List<Billing_Account__c> bill= [select billing_account_number__c,Name,Billing_Address__c FROM Billing_Account__c WHERE Billing_Account_Name__c='test_bill'LIMIT 1];
            String ban =String.valueOf(bill[0].billing_account_number__c);
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(600, 'OK', '', new Map<String, String>()));
            Test.startTest();
            BillingOrderService.requestBillingAccountDetails(ban);
            Test.stopTest();
            System.assertEquals('123456789632',ban);
                   
        }
//added as part of EDGE-120128        
        @isTest static void testPSLI() {
            List<csord__Subscription__c> subsList = [select id,Name from csord__Subscription__c where Name='test subs1' LIMIT 1];
            List<String> subIds = new List<String>();
            for(csord__Subscription__c subs :subsList){
                subIds.add(subs.id);
            }       
            Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(202, 'ACCEPTED', '[{"correlationId":"328fdbb9-a4e5-4c4c-b72f-0be6b9422917","code":"202","status":"202","message":"Approved","eventId":"328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}]', new Map<String, String>()));
            Test.startTest();
             Boolean isIncludeSolution = false;
             boolean isProductActionExpire = false;
            BillingOrderService.sendBillingOrder(subIds,isIncludeSolution,isProductActionExpire);
            Test.stopTest();
            List<csord__Subscription__c> subList = [select Id, Name, csord__Status__c from csord__Subscription__c WHERE Name ='test subs' LIMIT 1];
            if(!subsList.isEmpty())
                System.assertNotEquals(null,subList[0].csord__Status__c);
        }
     
    }