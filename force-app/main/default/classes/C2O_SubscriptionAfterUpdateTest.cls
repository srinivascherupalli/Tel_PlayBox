//Created by P.M

@isTest
public class C2O_SubscriptionAfterUpdateTest {
    @testSetup
    static void setupTestData() {
        Contact testContact;
        
        User enterpriseUser = SYS_TestDataFactory.createUser('Sales-Enterprise-Unified', 'Agribusiness');
        insert enterpriseUser;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            Account testFirstAccount = SYS_TestDataFactory.createAccount('test', 'Partner');
            testFirstAccount.Imported__c = true;
            testFirstAccount.OwnerId = enterpriseUser.Id;
            Account testSecondAccount = SYS_TestDataFactory.createAccount('testNew');
            insert new List<Account>{testFirstAccount, testSecondAccount};
                
                testContact = SYS_TestDataFactory.createContact(testFirstAccount.Id, 'Partner Contact');
            testContact.Contact_Status__c = 'Active';
            testContact.Onboarding_Status__c = OpptyConstants.ONBOARDING_ACTIVE;
            testContact.Partner_Role__c = OpptyConstants.PARTNER_SM;
            insert testContact;
            
            testFirstAccount.isPartner = true;
            update testFirstAccount;
            
            Opportunity testFirstOpp = SYS_TestDataFactory.createOpportunity(testFirstAccount.Id);
            testFirstOpp.Product_Type__c = 'Modular';
            testFirstOpp.Type = 'Price Review';
            testFirstOpp.Billing_Solution__c= 'In Contract';
            
            Opportunity testSecondOpp = SYS_TestDataFactory.createOpportunity(testSecondAccount.Id);
            testSecondOpp.OwnerId = enterpriseUser.Id;
            testSecondOpp.Product_Type__c = 'Modular';
            testSecondOpp.Type = 'Price Review';
            testSecondOpp.Billing_Solution__c= 'In Contract';
            
            insert new List<Opportunity>{testFirstOpp, testSecondOpp};
                
                PRMUtilityClass.OpportunityContactRoleDTO oppConRole= new PRMUtilityClass.OpportunityContactRoleDTO();
            oppConRole.OpportunityId = testFirstOpp.Id;
            oppConRole.ContactId = testContact.Id;
            oppConRole.Role = 'Decision Maker';
            oppConRole.IsPrimary = true;
            PRMUtilityClass.getOpportunityContactRole(oppConRole);
            
            Map<String,String> mapOwd = PRMUtilityClass.getOwdId();
            Map<String,EmailTemplate> template = PRMUtilityClass.getEmailTemplateDetails();
            PRMUtilityClass.EmailParameter emailParam = new PRMUtilityClass.EmailParameter();
            emailParam.targetObjectId = testFirstOpp.Id;
            emailParam.owdId = mapOwd.get(PRMUtilityClass.OWD_DO_NOT_REPLY);
            emailParam.whatId = UserInfo.getUserId();
            emailParam.templateId = template.get(PRMUtilityClass.GES_TEMPLATE).Id;
            emailParam.htmlBody = template.get(PRMUtilityClass.GES_TEMPLATE).HtmlValue;
            emailParam.htmlSubject = template.get(PRMUtilityClass.GES_TEMPLATE).Subject;
            emailParam.toAddressList = new List<String>{'test@test.com'};
                PRMUtilityClass.assignEmail(emailParam);
            
            cscfga__Product_Basket__c productBasket = SYS_TestDataFactory.createProductBasket(testFirstAccount.Id, testFirstOpp.Id);
            insert productBasket;
            
            cscfga__Product_Definition__c productDefinition = SYS_TestDataFactory.createProductDefinition('Mobility', Label.Adaptive_Care_Product_Specification);
            insert productDefinition;
            
            cscfga__Product_Configuration__c productConfig = SYS_TestDataFactory.createProductDefinition('Operational User', productBasket.Id, productDefinition.Id);
            productConfig.ConfigurationType1__c = 'Test';
            productConfig.Type__c = 'New';
            insert productConfig;
            
            cscfga__Product_Configuration__c productConfigCancel = SYS_TestDataFactory.createProductDefinition('Operational User', productBasket.Id, productDefinition.Id);
            productConfigCancel.ConfigurationType1__c = 'Test';
            productConfigCancel.Type__c = 'New';
            insert productConfigCancel;
            
            cscfga__Attribute__c testAttribute = SYS_TestDataFactory.createAttribute('Operational User', productConfig.Id);
            insert testAttribute;
            
            csord__Order__c firstOrder = SYS_TestDataFactory.createOrder(testFirstAccount.Id, testFirstOpp.Id);
            firstOrder.OwnerId = enterpriseUser.Id;
            csord__Order__c secondOrder = SYS_TestDataFactory.createOrder(testSecondAccount.Id, testSecondOpp.Id);
            secondOrder.OwnerId = enterpriseUser.Id;
            insert new List<csord__Order__c>{firstOrder, secondOrder};
                List<csord__Subscription__c> listofSubscription = new List<csord__Subscription__c>();
            Marketable_Offer__c marketableOfferDMS = SYS_TestDataFactory.createMarketableOffer('DMCAT_Offer_001540');
            insert marketableOfferDMS;
            for(Integer i=0; i<8; i++) {
                if(i == 0) {
                    listofSubscription.add(SYS_TestDataFactory.createSubscription('TestSubscription'+i, testFirstAccount.Id, firstOrder.Id, productConfig.Id));
                } else if(i == 1) {
                    listofSubscription.add(SYS_TestDataFactory.createSubscription('TestSubscription'+i, testSecondAccount.Id, secondOrder.Id, productConfig.Id));
                } else if(i == 2) {
                    listofSubscription.add(SYS_TestDataFactory.createSubscription('TestSubscription'+i, testSecondAccount.Id, firstOrder.Id, productConfig.Id));
                }else if(i == 3){
                    listofSubscription.add(SYS_TestDataFactory.createSubscription('TestSubscriptionDMS'+i, testFirstAccount.Id, firstOrder.Id, productConfig.Id));
                    listofSubscription[3].MarketableOffer__c = marketableOfferDMS.Id;
                } else if(i == 4){
                    listofSubscription.add(SYS_TestDataFactory.createSubscription('TestSubscriptionDMSCancel', testFirstAccount.Id, firstOrder.Id, productConfigCancel.Id));
                    listofSubscription[4].MarketableOffer__c = marketableOfferDMS.Id;
                }else {
                    listofSubscription.add(SYS_TestDataFactory.createSubscription('TestSubscription'+i, testFirstAccount.Id, secondOrder.Id, productConfig.Id));
                }
            }
            insert listofSubscription;
        }
        
        Test.startTest();
        
        User testPortalUser = SYS_TestDataFactory.createCommunityUser('PRM Admin - Australia',testContact.Id);
        insert testPortalUser;
        
        testPortalUser.IsPrmSuperUser = true;
        update testPortalUser;
        
        Test.stopTest();
    }
    
    @isTest static void testSubscriptionEvents() {
        test.starttest();
           BypassTrigger.incompleteOrderCounter = 2; 
        List<csord__Subscription__c> listOfSubscription = [SELECT id FROM csord__Subscription__c LIMIT 2];
        listOfSubscription[0].csord__Status__c = C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS;
        listOfSubscription[1].csord__Status__c = C2O_OrderConstants.STATUS_PROVISIONED;
        update listOfSubscription;
        
        test.stoptest();
    }
    
    @isTest static void testCancelContract() {
        List<csord__Subscription__c> listOfSubscription = [SELECT Id, csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Subscription__c LIMIT 1];
           BypassTrigger.incompleteOrderCounter = 2; 
        EnvironmentVariable__c customSetting = (EnvironmentVariable__c) SYS_TestDataFactory.createCustomSetting(EnvironmentVariable__c.sObjectType);
        customSetting.Name = 'Cancel_Contract_With_Agreement';
        customSetting.Value__c = 'False';
        insert customSetting;
        
        ContractJunction__c contractJunctionRec = SYS_TestDataFactory.createContractJunction(listOfSubscription[0].csord__Order__r.csordtelcoa__Opportunity__c);
        insert contractJunctionRec;
        
        Apttus__APTS_Agreement__c agreement = SYS_TestDataFactory.createAgreement('TestAgreement');
        insert agreement;
        
        test.starttest();
        
        listOfSubscription[0].csord__Status__c = C2O_OrderConstants.STATUS_CLOSED_REPLACED;
        listOfSubscription[0].ContractJunction__c = contractJunctionRec.Id;
        listOfSubscription[0].Agreement__c = agreement.Id;
        update listOfSubscription;
        
        test.stoptest();
    }
    
    @isTest static void testTenacyIdUpdate() {
        
        test.starttest();
           BypassTrigger.incompleteOrderCounter = 2; 
        Marketable_Offer__c marketableOfferFirst = SYS_TestDataFactory.createMarketableOffer(C2O_OrderConstants.DMCAT_OFFER_000750);
        Marketable_Offer__c marketableOfferSecond = SYS_TestDataFactory.createMarketableOffer(C2O_OrderConstants.DMCAT_OFFER_000681);
        insert new List<Marketable_Offer__c>{marketableOfferFirst, marketableOfferSecond};
            
            List<csord__Subscription__c> listOfSubscription = [SELECT Id FROM csord__Subscription__c LIMIT 2];
        listOfSubscription[0].MarketableOffer__c = marketableOfferFirst.Id;
        listOfSubscription[0].csord__Status__c= C2O_OrderConstants.STATUS_ACTIVE;
        listOfSubscription[1].MarketableOffer__c = marketableOfferSecond.Id;
        listOfSubscription[1].TenancyID__c = '123456780';
        
        update listOfSubscription;
        
        test.stoptest();
        
    }
    
    @isTest static void testAdaptiveCareChatter() {
           BypassTrigger.incompleteOrderCounter = 2; 
        
        Marketable_Offer__c marketableOffer = SYS_TestDataFactory.createMarketableOffer(Label.Adaptive_Care_Marketable_Offer);
        insert marketableOffer;
        
        test.starttest();
        
        List<csord__Subscription__c> listOfSubscription = [SELECT Id, csord__Account__c FROM csord__Subscription__c LIMIT 2];
        
        Partner_of_Record__c partnerOfrecord = SYS_TestDataFactory.createPOR(listOfSubscription[0].csord__Account__c);
        insert partnerOfrecord;
        
        listOfSubscription[0].MarketableOffer__c = marketableOffer.Id;
        listOfSubscription[0].csord__Status__c = C2O_OrderConstants.STATUS_PROVISIONED;
        listOfSubscription[0].csordtelcoa__Replaced_Subscription__c = listOfSubscription[1].Id;
        update listOfSubscription;
        
        test.stoptest();
        
    }
    
    @isTest static void testDelayNotification() {
        
        test.starttest();
           BypassTrigger.incompleteOrderCounter = 2; 
        List<csord__Subscription__c> listOfSubscription = [SELECT Id FROM csord__Subscription__c LIMIT 1];
        
        csord__Service__c service = SYS_TestDataFactory.createService(listOfSubscription[0].Id);
        service.Telstra_Committed_Date__c = date.today();
        service.Forecasted_Delivery_Date__c = date.today().addDays(1);
        insert service;
        
        test.stoptest();
    }
    
    @isTest static void testOrderReceivedChatter() {
           BypassTrigger.incompleteOrderCounter = 2; 
        callOrderNotification(C2O_OrderConstants.STAGE_OREDR_RECEIVED);
    }
    
    @isTest static void testOrderBeingFulfilledChatter() {
           BypassTrigger.incompleteOrderCounter = 2; 
        callOrderNotification(C2O_OrderConstants.STAGE_BEING_FULFILLED);
    }
    
    @isTest static void testOrderReadyForUseChatter() {
           BypassTrigger.incompleteOrderCounter = 2; 
        callOrderNotification(C2O_OrderConstants.STAGE_READY_FOR_USE);
    }
    
    private static void callOrderNotification(String stage) {
           BypassTrigger.incompleteOrderCounter = 2; 
        List<sObject> listOfsObjectToUpdate = new List<sObject>();
        Map<Id,String> mapSubIdVsNotificationType = new Map<Id,String>();
        Boolean accountOwnerUpdate = false, opportnityOwnerUpdate = false;
        Id ownerId;
        
        for(User usr : [SELECT Id, Profile.Name FROM User]) {
            if(usr.Profile.Name == 'PRM Admin - Australia') {
                ownerId = usr.Id;
                break;
            }
        }
        
        Test.starttest();
        
        List<csord__Subscription__c> testSubscriptionlst = [SELECT Id, csord__Status__c, csord__Account__c, csord__Account__r.cidn__c,
                                                            csord__Order__r.csordtelcoa__Opportunity__c, csord__Account__r.Owner.Profile.Name,
                                                            csord__Order__r.csordtelcoa__Opportunity__r.Owner.Profile.Name FROM csord__Subscription__c];
        
        for(csord__Subscription__c subscription : testSubscriptionlst) {
            if(subscription.csord__Account__r.cidn__c == 'testNew' && !accountOwnerUpdate) {
                accountOwnerUpdate = true;
                listOfsObjectToUpdate.add(new Account(Id = subscription.csord__Account__c, OwnerId = ownerId));
            }
            if(subscription.csord__Order__r.csordtelcoa__Opportunity__r.Owner.Profile.Name == 'System Administrator' && !opportnityOwnerUpdate) {
                opportnityOwnerUpdate = true;
                listOfsObjectToUpdate.add(new Opportunity(Id = subscription.csord__Order__r.csordtelcoa__Opportunity__c, OwnerId = ownerId));
            }
            subscription.stage__c = stage;
            mapSubIdVsNotificationType.put(subscription.Id, stage);
        }
         
        update listOfsObjectToUpdate;
        
        C2O_SubscriptionTriggerHelper.doChainJob = false;
        update testSubscriptionlst;
        
        C2O_SubscriptionTriggerHelper.doChainJob = true;
        System.enqueueJob(new C2O_SubscriptionTriggerHelper.OrderNotification(mapSubIdVsNotificationType, true));
        
        test.stoptest();
    }
     
    @isTest static void testCreateAndUpdate1() {
        Test.startTest();
        BypassTrigger.isRunningTestCheck = true; 
        List<csord__Subscription__c> listOfSubscription = [SELECT id FROM csord__Subscription__c LIMIT 2];
        listOfSubscription[0].csord__Status__c = C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS;
        listOfSubscription[1].csord__Status__c = C2O_OrderConstants.STATUS_PROVISIONED;
        update listOfSubscription;
        Test.stopTest();
    }   
    //Added by Nikhil as part of DIGI-4694 
    @isTest static void testSendOrderNotificationForDMS() {
        Test.starttest();
           BypassTrigger.incompleteOrderCounter = 2; 
        BDS_Notify_Settings__c bds = new BDS_Notify_Settings__c();
        bds.Name = 'DMS';
        bds.Value__c = 'DMCAT_Offer_001540';
        bds.Is_SI5_Offer__c = true;
        bds.Is_Sub_Offer__c = true;
        bds.EventType_Complete__c = 'New';
        bds.EventType_InProgress__c = 'New,Cancel';
        insert bds;
        
        List<csord__Subscription__c> listOfSubscription = [SELECT Id FROM csord__Subscription__c WHERE 
                                                           MarketableOffer__r.Offer_ID__c = 'DMCAT_Offer_001540'];
        listOfSubscription[0].csord__Status__c= C2O_OrderConstants.STATUS_ACTIVE;
        update listOfSubscription;
        
        // Coverd Exception log
        C2O_SubscriptionTriggerHelper.logException('sendOrderNotificationForDMS','','123', 'Error', 'Send order notification for DMS failed.','C2O_SubscriptionTriggerHelper');
        List<Exception_Log__c> logExceptionList = [SELECT ID FROM Exception_Log__c];
        System.assert(logExceptionList.size() > 0, 'There should be atleast one log in the list' );
        Test.stoptest();
    }
    //Added by Nikhil as part of DIGI-4694 
    @isTest static void testSendCancelOrderNotificationForDMS() {
        
        Test.starttest();
        BypassTrigger.incompleteOrderCounter = 2; 
        BDS_Notify_Settings__c bds = new BDS_Notify_Settings__c();
        bds.Name = 'DMS';
        bds.Value__c = 'DMCAT_Offer_001540';
        bds.Is_SI5_Offer__c = true;
        bds.Is_Sub_Offer__c = true;
        bds.EventType_Complete__c = 'New';
        bds.EventType_InProgress__c = 'New,Cancel';
        insert bds;
        
        List<csord__Subscription__c> listOfSubscription = [SELECT Id FROM csord__Subscription__c WHERE Name = 'TestSubscriptionDMSCancel'
                                                           AND MarketableOffer__r.Offer_ID__c = 'DMCAT_Offer_001540'];
        listOfSubscription[0].csord__Status__c= C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS;
        update listOfSubscription;
        List<ApplicationLog__c> bdslog = [SELECT id from ApplicationLog__c WHERE Reference_Info__c = 'BDSNotify'];
        System.assert(bdslog.size() == 0 , 'No log should be created' );
        listOfSubscription[0].csord__Status__c= C2O_OrderConstants.STATUS_INACTIVE;
        update listOfSubscription;
        // Coverd Exception log
        C2O_SubscriptionTriggerHelper.logException('sendOrderNotificationForDMS','','123', 'Error', 'Send order notification for DMS failed.','C2O_SubscriptionTriggerHelper');
        List<Exception_Log__c> logExceptionList = [SELECT ID FROM Exception_Log__c];
        System.assert(logExceptionList.size() > 0, 'There should be atleast one log in the list' );
        Test.stoptest();
    }
}