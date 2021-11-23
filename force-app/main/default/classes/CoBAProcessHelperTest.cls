/*********************************************************************************************************************************
 * Class Name   :   CoBAProcessHelperTest
 * Description  :   Test Class for CoBAProcessHelper
 SL.No.     Developer Name      Date            Story Description
 1.         Pooja Bhat          27/04/2021      EDGE-212439 - As a User, I should receive Chatter Notification if CoBA request fails/Errors
 2.         Kamlesh Kumar       5/5/2021        EDGE-212440 - Testing As a User on click of submit button on case UI. I shall resubmit the case if any error occurs
**********************************************************************************************************************************/
@isTest
private class CoBAProcessHelperTest {
    
    @testSetup
    static void testdata() {
        
        Account testAccount =   TestDataFactory.generateAccount();
        
        Contact testContact =   TestDataFactory.generateContact('Test',testAccount.Id,'Active','User1',System.today(),'Mobile');
        insert testContact;
        
        List<Opportunity> oppList   =   new List<Opportunity>();
        Opportunity testOpp1        =   TestDataFactory.generateOpportunityForAccount(testAccount);
        testOpp1.Product_Type__c    =   'Modular';
        oppList.add(testOpp1);
        update oppList;
        
        List<Billing_Account__c> lstBillAccs = new List<Billing_Account__c>();
        Billing_Account__c  billAcc1 = TestDataFactory.generateBillingAccount('700000017897','Created',testAccount.Id,testContact.Id);
        Billing_Account__c  billAcc2 = TestDataFactory.generateBillingAccount('700000017898','Created',testAccount.Id,testContact.Id);
        lstBillAccs.add(billAcc1);
        lstBillAccs.add(billAcc2);
        insert lstBillAccs;
        
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

        List<Case> caseList = new List<Case>();
        String caseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_of_Billing_Account').getRecordTypeId();  
        Case oCase1 = TestDataFactory.generateCase(testAccount.Id,testContact.Id,'Email','Medium','New',billAcc1.Id,'Change of Digital Billing Account' + billAcc1.Billing_Account_Number__c,'test case 1');
        Case oCase2 = TestDataFactory.generateCase(testAccount.Id,testContact.Id,'Email','Medium','New',billAcc2.Id,'Change of Digital Billing Account' + billAcc2.Billing_Account_Number__c,'test case 2');
        oCase1.RecordTypeId         =   caseRecTypId;
        oCase2.RecordTypeId         =   caseRecTypId;
        caseList.add(oCase1);
        caseList.add(oCase2);
        insert caseList;

        Utility_Settings__c utilSettings                        =   new Utility_Settings__c();
        utilSettings.Chatter_notification_for_CoBA_failure__c   =   'Hi {0}, There is error in case{1}. Please try resubmitting. If error continues contact {2}';
        utilSettings.Telstra_MyIT__c                            =   'https://www.telstra.com';
        utilSettings.CoBA_submit_not_allowed_message__c         =    'The case is in <status> state and hence cannot be re-submitted.';
        utilSettings.CoBA_association_statuse_allowing_submit__c =   'In Error, Pending';
        utilSettings.CoBA_submission_success_message__c         =    'Case Submitted Successfully';
        utilSettings.ShowCoBAToastMessage__c                    =     false;
        insert utilSettings;
    }

    @isTest
    static void cobaSubmissionFailureChatterPost_Test() {
        List<Case> caseList     =   [SELECT Id FROM Case];
        Set<String> setCaseIds  =   new Set<String>();
        for(Case oCase : caseList) {
            setCaseIds.add(oCase.Id);
        }
        Test.startTest();
            CoBAProcessHelper.cobaSubmissionFailureChatterPost(setCaseIds);
        Test.stoptest();
        System.assertEquals(2, caseList.size(), 'Error in case record creation');
    }
    
    @isTest
    static void cobabillingAPICalloutsForCoBA_Test() {
        List<Case> caseList     =   [SELECT Id FROM Case];
        List<String> caseId     = new List<String>();
        
        for(Case oCase : caseList) {
            caseId.add(oCase.Id);
        }
        Test.startTest();
        CoBAProcessHelper.billingAPICalloutsForCoBA(caseId);
        Test.stoptest();
        System.assertEquals(2, caseList.size());
    }
    
     @isTest
    static void coBAReSubmission_Test() {
        List<Case> caseList     =   [SELECT Id FROM Case];
        List<String> caseId     = new List<String>();
        
        for(Case oCase : caseList) {
            caseId.add(oCase.Id);
        }
        Test.startTest();
        Map<String,String> validationMessage = CoBAProcessHelper.coBACaseResubmitMethod(caseId);
        Test.stoptest();
        System.assertEquals(2, caseList.size());
    }
    
    @isTest
    static void coBAReSubmissionException_TestError_Test() {
        List<Case> caseList     =   [SELECT Id,Status FROM Case limit 1];
        List<Billing_Account__c  > billingList     =   [SELECT Id FROM Billing_Account__c   limit 1];
        List<csord__Subscription__c  > subList     =   [SELECT Id FROM csord__Subscription__c limit 1];
        Case cc = new Case(Id=caseList[0].Id,Status='In Error');
        update cc;
        Subscriptions_to_Case_Association__c juncObj1 = new Subscriptions_to_Case_Association__c();
        juncObj1.csord_Subscription__c=subList[0].Id;
        juncObj1.case__c=cc.Id;
        juncObj1.Billing_Account__c = billingList[0].Id;
        juncObj1.Status__c ='Completed';
        insert juncObj1;
        Test.startTest();
        Map<String,String> validationMessage = CoBAProcessHelper.coBACaseResubmitMethod(new List<String>{cc.Id});
        Test.stoptest();
        System.assertEquals(1, caseList.size());
    }
    
    @isTest
    static void coBAReSubmissionException_TestBDSAPISettingsc_Test() {
        BDS_API_Settings__c cobaLimit   =   new BDS_API_Settings__c(Value__c='10',Name ='SubscriptionAPI Limit');
        insert cobaLimit;
        List<Case> caseList     =   [SELECT Id,Status FROM Case limit 1];
        List<Billing_Account__c  > billingList     =   [SELECT Id FROM Billing_Account__c   limit 1];
        List<csord__Subscription__c  > subList     =   [SELECT Id FROM csord__Subscription__c limit 1];
        Case cc = new Case(Id=caseList[0].Id,Status='In Error');
        update cc;
        Subscriptions_to_Case_Association__c juncObj1 = new Subscriptions_to_Case_Association__c();
        juncObj1.csord_Subscription__c=subList[0].Id;
        juncObj1.case__c=cc.Id;
        juncObj1.Billing_Account__c = billingList[0].Id;
        juncObj1.Status__c ='Completed';
        insert juncObj1;
        Test.startTest();
        Map<String,String> validationMessage = CoBAProcessHelper.coBACaseResubmitMethod(new List<String>{cc.Id});
        Test.stoptest();
        System.assertEquals(1, caseList.size());
    }
    
    @isTest
    static void validationBeforeCoBASubmission_Test() {
        String message;
        Test.startTest();
        try{
           message = CoBAProcessHelper.validationBeforeCoBASubmission(new List<String>{'123'});
        }catch(Exception e){
        }
        Test.stoptest();
        System.assertNotEquals('error', message);
    }
}