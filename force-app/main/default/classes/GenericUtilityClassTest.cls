/********************************************************************
   EDGE        : 200438,205509
   Class       : GenericUtilityClass
   Description : Test clas of GenericUtilityClass
   Author      : Kamlesh Kumar
********************************************************************/

@isTest
public class GenericUtilityClassTest
{
    @testSetup static void createTestData() {
        Account acc = ProductTestService.getNewAccount('Test Account');
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Account__c = acc.id;
        billingAccount.Status__c = 'final';
        insert billingAccount;
        
        Contact cont = new Contact(FirstName='Test',LastName='Test',Email='test@test.com',AccountId=acc.id,Phone='');
        insert cont;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'IoT Basket';
        basket.Device_Care_Contact__c = cont.Id;
        basket.cscfga__Basket_Status__c = 'valid';
        basket.Order_Requester__c =cont.Id;
        basket.csordtelcoa__Basket_Stage__c ='Draft';
        basket.sync_job_Id__c = '[{"name":"syncJobId","id":"123"}]';
        basket.csbb__Synchronised_with_Opportunity__c =false;
        insert basket;
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Name = 'IoT Basket';
        basket1.Device_Care_Contact__c = cont.Id;
        basket1.cscfga__Basket_Status__c = 'valid';
        basket1.Order_Requester__c =cont.Id;
        basket1.csordtelcoa__Basket_Stage__c ='Draft';
        basket1.csbb__Synchronised_with_Opportunity__c =false;
        basket1.sync_job_Id__c = '{"name":"syncJobId","id":"123"}';
        insert basket1;



        Utility_Settings__c utilSettings                    =   new Utility_Settings__c();
        utilSettings.Batch_size_for_CoBA__c                 =   200;
        utilSettings.Use_Batch_Mode_For_CoBA__c             =   true;
        utilSettings.Subscription_Statuses_Allowing_CoBA__c = 'Active,Suspended';
        insert utilSettings;
        
		/*****************************************************************************************
		 * Added Product Definition, Product Configuration, Order, Subscription, Service Records *
		 * ***************************************************************************************/
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c cwProdDef = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace', Is_Hardware__c = true, Refund_Duration__c = '5');
        pdList.add(cwProdDef);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication', Eligible_For_Hardware_Refund__c = true,Refund_Duration__c = '8');
        pdList.add(ucePD);
        cscfga__Product_Definition__c ipNetPD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network',Refund_Duration__c = '2');
        pdList.add(ipNetPD);
        cscfga__Product_Definition__c mobPD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility',product_Specification__c='DMCAT_ProductSpecification_000420');
        pdList.add(mobPD);
        // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - Created IOT Susbcription Product Definition record
        cscfga__Product_Definition__c iotPD = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription',product_Specification__c='DMCAT_ProductSpecification_000965');
        pdList.add(iotPD);
        insert pdList;
       

        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = basket.Id;
        testConfig.cscfga__Product_Definition__c=cwProdDef.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = basket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.cscfga__Product_Basket__c = basket.Id;
        testConfig2.cscfga__Product_Definition__c=ipNetPD.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.cscfga__Product_Basket__c = basket.Id;
        testConfig3.cscfga__Product_Definition__c=mobPD.id;
        prodconfigList.add(testConfig3); 
        // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - added Product Configuration record
        cscfga__Product_Configuration__c testConfig4 = new cscfga__Product_Configuration__c();
        testConfig4.Name = 'IOT Susbcription';
        testConfig4.cscfga__Product_Basket__c = basket.Id;
        testConfig4.cscfga__Product_Definition__c=iotPD.id;
        prodconfigList.add(testConfig4); 
        insert prodconfigList;

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = acc.Id;
        testOrder.csordtelcoa__Opportunity__c = Opp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        testOrder.isMSISDNHeld__c = false;
        insert testOrder;

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;

        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = acc.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        testSubscription.Suspension_reason__c='fraudLight';
        testSubscription.Suspension_reason_summary__c='fraudLight,fraudHeavy'; //DPG-4542 Jenish

        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = acc.Id;
        testSubscription2.csord__Order__c = testOrder.Id;
        testSubscription2.csord__Identification__c = 'test2';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription2.csord__Status__c = 'Pending';

        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = acc.Id;
        testSubscription3.csord__Order__c = testOrder.Id;
        testSubscription3.csord__Identification__c = 'test3';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription3.csord__Status__c = null;

        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = acc.Id;
        testSubscription4.csord__Order__c = testOrder.Id;
        testSubscription4.csord__Identification__c = 'test';
        testSubscription4.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription4.csord__Status__c = 'Suspended';
        testSubscription4.Suspension_reason_summary__c='Requested by Telstra,Requested by Customer';  //DPG-4542 Jenish
        
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = acc.Id;
        testSubscription5.csord__Order__c = testOrder.Id;
        testSubscription5.csord__Identification__c = 'test';
        testSubscription5.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription5.csord__Status__c = 'Closed Replaced';

        csord__Subscription__c testSubscription6 = new csord__Subscription__c();
        testSubscription6.Name = 'TestSubsforTest6';
        testSubscription6.csord__Account__c = acc.Id;
        testSubscription6.csord__Order__c = testOrder.Id;
        testSubscription6.csord__Identification__c = 'test';
        testSubscription6.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription6.csord__Status__c = 'Active';
        
        // DPG-1891 Suspend IoT Services - Created Subscription record to be Suspend
        csord__Subscription__c testSubscription7 = new csord__Subscription__c();
        testSubscription7.Name = 'TestSubsforTest7';
        testSubscription7.csord__Account__c = acc.Id;
        testSubscription7.csord__Order__c = testOrder.Id;
        testSubscription7.csord__Identification__c = 'test';
        testSubscription7.csordtelcoa__Product_Configuration__c = testConfig4.Id;
        testSubscription7.csord__Status__c = 'Active';
        
        // DPG-1892 Resume IoT Services - Created Subscription record to be resume
        csord__Subscription__c testSubscription8 = new csord__Subscription__c();
        testSubscription8.Name = 'TestSubsforTest8';
        testSubscription8.csord__Account__c = acc.Id;
        testSubscription8.csord__Order__c = testOrder.Id;
        testSubscription8.csord__Identification__c = 'test';
        testSubscription8.csordtelcoa__Product_Configuration__c = testConfig4.Id;
        testSubscription8.csord__Status__c = 'Suspended';
        
         List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2,testSubscription3,testSubscription4,testSubscription5,testSubscription6,testSubscription7,testSubscription8};
        insert testSubsList;
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='testService_4';
        serv1.csord__Identification__c  = 'testIdentify_4';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = testSubscription.Id;
        serv1.csord__Status__c = 'Created';
        serv1.substage__c = 'Product Requirements Validation';
        serv1.TechnologyType__c= 'Mobile Access';
        insert serv1;
        
        //Replaced Subscription
        cscfga__Product_Configuration__c testConfigReplaced = new cscfga__Product_Configuration__c();
        testConfigReplaced.Id = prodconfigList[1].Id;
        testConfigReplaced.Name = System.Label.IP_Network;
        testConfigReplaced.cscfga__Product_Basket__c = basket.Id;
        testConfigReplaced.cscfga__Product_Definition__c=ucePD.id;
        testConfigReplaced.csordtelcoa__replaced_subscription__c = testSubsList[0].Id;
        update testConfigReplaced;
    }
    @isTest
    public static void fetchGroupTypeDetailsTest()
    {
        Test.startTest();
        //Creating Group
        Group testGroup = new Group(Name='QUEUE NAME', Type='Queue');
        insert testGroup;
            
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
        insert testQueue;
        
        List<Group> groupList = GenericUtilityClass.fetchGroupTypeDetails('','');
        System.assertEquals(false,groupList.size()>0);
        Test.stopTest(); 
    }
    
    @isTest
    public static void ayncJobDetailsDetailsTest()
    {
        Test.startTest();
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        Set<String> setProductBasketId = new Set<String>();
        setProductBasketId.add(basket.id);
        Id jobId = database.executeBatch(new createOLIsBatch(setProductBasketId));
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.id = basket.id;
        basket1.sync_job_Id__c = '[{"name":"syncJobId","isCompleted":true,"id":"'+jobId+'","error":false}]';
        update basket1;
        List<String>jobIdList = new List<String>();
        jobIdList.add(jobId);
        Map <String,AsyncApexJob> jobMap = GenericUtilityClass.ayncJobDetails(jobIdList);
        System.assertEquals(true,jobMap.size()>0);
        Test.stopTest(); 
    }
    
    @isTest
    public static void createSyncJobMessageTest()
    {
        Test.startTest();
        String jobSyncMessage = '[{"name":"syncJobId","isCompleted":false,"id":"7072N00000L8FF2QAN","error":false}]';
        String jobName = 'syncJobId';
        String jobMessage = GenericUtilityClass.createSyncJobMessage(jobSyncMessage,jobName,true,false);
        System.assertEquals(true,String.isNotBlank(jobMessage ));
        Test.stopTest(); 
    }



    @isTest
    public static void logExceptionTest(){
    	
        Test.startTest();
        	GenericUtilityClass.logException('myClassName','myMethodName','Ref123','Corr123','ErrorMsg','BusinessDes',null);
       		Exception_Log__c exp = [select id from Exception_Log__c limit 1];
        	system.assertEquals(True, exp.id != null);
        Test.stopTest();
        
    }

    @isTest
    public static void getfilteredQueryResultTest() {
        Map<String, Object> inputMap    =   new Map<String, Object>{'Name'=>'=\'Test Account\''};
        List<String> fieldsList         =   new List<String>{'Id','Name'};
        Test.startTest();
            List<Account> accList       =   GenericUtilityClass.getfilteredQueryResult(inputMap, fieldsList, 'Account');
            System.assertEquals(1, accList.size(), 'Error is method getfilteredQueryResult');
        Test.stopTest();
    }

    @isTest
    public static void getSubscriptionStatusAllowingCoBA() {
        Test.startTest();
            List<String> statusList = GenericUtilityClass.getSubscriptionStatusAllowingCoBA();
            System.assertEquals(2, statusList.size(), 'Error is method getSubscriptionStatusAllowingCoBA');
        Test.stopTest();
    }

    @isTest
    public static void retrieveEligibleActionTypes_Test1() {
        MACD_Order_Options__mdt macdOrderTypeMtd;
        List<String> fieldList     =   new List<String>{'Id','MasterLabel','DeveloperName','Action_Types_for_Active_POR__c',
                    'Action_Types_for_Insolvency_Consultants__c','Action_Types_in_General__c','Profile_User__c',
                    'Profile_User__r.Salesforce_Id__c','Profile_User__r.DeveloperName'};
        Test.startTest();
            macdOrderTypeMtd = GenericUtilityClass.retrieveEligibleActionTypes('','',fieldList);
        Test.stopTest();
        System.assert(macdOrderTypeMtd.Action_Types_in_General__c!=null);            
    }

    @isTest
    public static void retrieveEligibleActionTypes_Test2() {
        MACD_Order_Options__mdt macdOrderTypeMtd;
        List<String> fieldList     =   new List<String>{'Id','MasterLabel','DeveloperName','Action_Types_for_Active_POR__c',
                    'Action_Types_for_Insolvency_Consultants__c','Action_Types_in_General__c','Profile_User__c',
                    'Profile_User__r.Salesforce_Id__c','Profile_User__r.DeveloperName'};
        Test.startTest();
            macdOrderTypeMtd = GenericUtilityClass.retrieveEligibleActionTypes(UserInfo.getUserId(),UserInfo.getProfileId(),fieldList);
        Test.stopTest();
        System.assert(macdOrderTypeMtd.Action_Types_in_General__c!=null);
        System.assert(macdOrderTypeMtd.Action_Types_for_Active_POR__c!=null);
        System.assert(macdOrderTypeMtd.Action_Types_for_Insolvency_Consultants__c!=null);            
    }
    
    @isTest
    public static void filterSubcriptionCoBARequestTest(){
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>();
        testSubsList = [SELECT Id,Name, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Eligible_For_Hardware_Refund__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Refund_Duration__c FROM csord__Subscription__c WHERE Name IN ('TestSubsforTest','TestSubsforTest2','TestSubsforTest3','TestSubsforTest4','TestSubsforTest5','TestSubsforTest6','TestSubsforTest7','TestSubsforTest8')];

        Test.startTest();
        List<csord__Subscription__c> sublist =  GenericUtilityClass.filterSubcriptionCoBARequest(testSubsList);
        Test.stopTest();
        //asserting
        system.assertNotEquals(null,sublist);
        system.assert(!sublist.isEmpty());
    }

    @isTest
    public static void parallelChangeValidationForNonCommMACDTest(){
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>();
        testSubsList = [SELECT Id,Name, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Eligible_For_Hardware_Refund__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Refund_Duration__c FROM csord__Subscription__c WHERE Name IN ('TestSubsforTest','TestSubsforTest2','TestSubsforTest3','TestSubsforTest4','TestSubsforTest5','TestSubsforTest6','TestSubsforTest7','TestSubsforTest8')];
        List<string> subIds = new List<String>();
        for(csord__Subscription__c sub : testSubsList){
            subIds.add(sub.Id);
        }  
        
        Test.startTest();
        parallelChangeValidationResponse para = new parallelChangeValidationResponse();
        para = GenericUtilityClass.parallelChangeValidationForNonCommMACD(subIds);
        Test.stopTest();
		//asserting
		system.assertNotEquals(null,para);       
    }
        

}