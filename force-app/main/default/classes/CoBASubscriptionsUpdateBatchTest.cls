/*************************************************************************************************************************************************
* Name         :    CoBASubscriptionsUpdateBatchTest  
* Description  :    Test Class CoBASubscriptionsUpdateBatch

Sr.No.      Developer Name      Date            Story           Description
1.          Pooja               01/04/2021      EDGE-205599     As a user when change of Billing account is submitted system must create case for tracking
**************************************************************************************************************************************************/
@isTest
private class CoBASubscriptionsUpdateBatchTest {
    @testSetup
    static void testdata() {
        
        Account testAccount             =   TestDataFactory.generateAccount();
        testAccount.Customer_Status__c  =   'ACTIVE';
        update testAccount;
        
        Contact testContact         =   TestDataFactory.generateContact('Test',testAccount.Id,'Active','User1',System.today(),'Mobile');
        insert testContact;

        List<Opportunity> oppList   =   new List<Opportunity>();
        Opportunity testOpp1        =   TestDataFactory.generateOpportunityForAccount(testAccount);
        testOpp1.Product_Type__c    =   'Modular';
        oppList.add(testOpp1);
        update oppList;

        List<Billing_Account__c> listBillAcc                    =   new List<Billing_Account__c>();
        Billing_Account__c billAcc1                             =   TestDataFactory.generateBillingAccount('700000017897','Created',testAccount.Id,testContact.Id);
        billAcc1.Include_related_Customer_Account_Contact__c    =   false; 
        billAcc1.Balance_Amount__c                              =   100.00;
        listBillAcc.add(billAcc1);
        Billing_Account__c billAcc2                             =   TestDataFactory.generateBillingAccount('700000017898','Created',testAccount.Id,testContact.Id);
        billAcc2.Include_related_Customer_Account_Contact__c    =   false; 
        billAcc2.Balance_Amount__c                              =   110.00;
        listBillAcc.add(billAcc2);
        insert listBillAcc;
        
        Test.startTest();
           List<cscfga__Product_Configuration__c> prodConfigList = TestDataFactory.generateProductConfigurations(2);
        Test.stopTest();

        csord__Order_Request__c orderReq    =   ProductTestFactory.buildOrderRequest();

        List<csord__Order__c> orderLst      =   new List<csord__Order__c>();
        csord__Order__c order1              =   TestDataFactory.generateOrder(testAccount.id,'Order Submitted','Ready for submit','Order','Order_456',System.today(),'Mobile Device Replacement','Test Order','Device_replace',UserInfo.getUserId());
        order1.csordtelcoa__Opportunity__c  =   testOpp1.id;
        insert orderLst;
        
        List<csord__Subscription__c> subscrptnList      =   new List<csord__Subscription__c>();
        csord__Subscription__c testSub1                 =   ProductTestFactory.buildSubscription('TestSub1', testAccount.Id, order1.Id,orderReq.Id);
        testSub1.csord__Identification__c               =   'test1';
        testSub1.csordtelcoa__Product_Configuration__c  =   prodConfigList[0].Id;
        testSub1.csord__Status__c                       =   'Active';
        testSub1.Billing_Account__c                     =   billAcc1.id; 
        subscrptnList.add(testSub1);
        csord__Subscription__c testSub2                 =   ProductTestFactory.buildSubscription('TestSub2', testAccount.Id, order1.Id,orderReq.Id);
        testSub2.csord__Identification__c               =   'test2';
        testSub2.csordtelcoa__Product_Configuration__c  =   prodConfigList[0].Id;
        testSub2.csord__Status__c                       =   'Active';
        testSub2.Billing_Account__c                     =   billAcc1.id;
        subscrptnList.add(testSub2);
        csord__Subscription__c testSub3                 =   ProductTestFactory.buildSubscription('TestSub3', testAccount.Id, order1.Id,orderReq.Id);
        testSub3.csord__Identification__c               =   'test3';
        testSub3.csordtelcoa__Product_Configuration__c  =   prodConfigList[1].Id;
        testSub3.csord__Status__c                       =   'Active';
        testSub3.Billing_Account__c                     =   billAcc1.id;
        subscrptnList.add(testSub3);
        insert subscrptnList;
        
        List<csord__Service__c> serviceList             =   new List<csord__Service__c>();
        csord__Service__c testServ1                     =   ProductTestFactory.buildService('test service1', order1.Id, testSub1.Id, orderReq.Id);
        testServ1.csord__Identification__c              =   'test identify1';
        testServ1.csordtelcoa__Service_Number__c        =   'svc-1235645';
        testServ1.csord__Status__c                      =   'Service Created';
        testServ1.csordtelcoa__Product_Configuration__c =   prodConfigList[0].Id;
        serviceList.add(testServ1);
        csord__Service__c testServ2                     =   ProductTestFactory.buildService('test service2', order1.Id, testSub2.Id, orderReq.Id);
        testServ2.csord__Identification__c              =   'test identify2';
        testServ2.csordtelcoa__Service_Number__c        =   'svc-1235646';
        testServ2.csord__Status__c                      =   'Service Created';
        testServ2.csordtelcoa__Product_Configuration__c =   prodConfigList[0].Id;
        serviceList.add(testServ2);
        csord__Service__c testServ3                     =   ProductTestFactory.buildService('test service3', order1.Id, testSub3.Id, orderReq.Id);
        testServ3.csord__Identification__c              =   'test identify3';
        testServ3.csordtelcoa__Service_Number__c        =   'svc-1235647';
        testServ3.csord__Status__c                      =   'Service Created';
        testServ3.csordtelcoa__Product_Configuration__c =   prodConfigList[1].Id;
        serviceList.add(testServ3);
        insert serviceList;

        BDS_API_Settings__c cobaLimit   =   new BDS_API_Settings__c(Value__c='10',Name ='SubscriptionAPI Limit');
        insert cobaLimit;
         
        Utility_Settings__c utilSettings                        =   new Utility_Settings__c();
        utilSettings.Batch_size_for_CoBA__c                     =   200;
        utilSettings.Use_Batch_Mode_For_CoBA__c                 =   true;
        utilSettings.Subscription_Statuses_Allowing_CoBA__c     =   'Active,Suspended';
        utilSettings.Chatter_notification_for_CoBA_failure__c   =   'Hi {0}, There is error in case{1}. Please try resubmitting. If error continues contact {2}';
        utilSettings.Telstra_MyIT__c                            =   'https://www.telstra.com';
        insert utilSettings;
       
    }   //End of testdata()    
  
    @isTest
    static void myUnitTest1() {
        String targetBillAccId              =   '';
        String targetBillAccNo              =   '';
        List<String> subIdsLst              =   new List<String>();
        List<Account> accLst                =   [SELECT Id FROM Account Limit 1];
        List<Contact> conLst                =   [SELECT Id FROM Contact Limit 1];
        List<Billing_Account__c> billAccLst =   [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c LIMIT 50000];
        List<csord__Subscription__c> subLst =   [SELECT Id FROM csord__Subscription__c LIMIT 50000];
        for(Billing_Account__c billAcc : billAccLst) {
            if(billAcc.Billing_Account_Number__c == '700000017898') {
                targetBillAccId =   billAcc.Id;
                targetBillAccNo =   billAcc.Billing_Account_Number__c;
            }
        }
        for(csord__Subscription__c oSub : subLst) {
            subIdsLst.add(oSub.Id);
        }
        Test.startTest();
            try {
                CoBASubscriptionsUpdateUtility.submitCoBA(accLst[0].Id, conLst[0].Id, targetBillAccId, 'Customer error(incorrect BAN selected)', subIdsLst);
            } catch(Exception e) {
                System.debug('Exception ' + e);
            }
            List<Case> caseList =   [SELECT Id,Billing_Account__c,Subject FROM Case WHERE Billing_Account__c=:targetBillAccId];
            System.assertEquals(1, caseList.size(), 'Error in case record creation');
            System.assert(caseList[0].Subject.contains(targetBillAccNo));
        Test.stopTest();
    }   //End of myUnitTest1()
}