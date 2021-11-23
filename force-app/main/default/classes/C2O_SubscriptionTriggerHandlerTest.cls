@isTest
public class C2O_SubscriptionTriggerHandlerTest {
    @testSetup
    static void setupTestData() { 
        List<User> Usrlst = new List<User>();
        
        User sysAdminUsr= SYS_TestDataFactory.createUser('System Administrator', 'Agribusiness');
        Usrlst.add(sysAdminUsr);
        
        insert Usrlst;
        
        System.runAs(Usrlst[0]){
            
            Account testAccount = SYS_TestDataFactory.createAccount('1234565');
            testAccount.Name = 'testAccount';
            testAccount.Customer_Status__c = 'ACTIVE';
            insert testAccount;
            
            Opportunity testOpp = SYS_TestDataFactory.createOpportunity(testAccount.Id);
            testOpp.Name = 'testOpp';
            testOpp.StageName = 'Define';
            testOpp.Product_Type__c = 'Modular';
            testOpp.CloseDate = System.Date.today();
            testOpp.Type = 'Price Review';
            testOpp.Billing_Solution__c= 'In Contract';
            insert testOpp;
            PRMUtilityClass.getListOfOpportunityForPRM(new Set<Id>{testOpp.Id});
            PRMUtilityClass.getOwdId();
            PRMUtilityClass.getEmailTemplateDetails();
            PRMUtilityClass.createOTM(Usrlst[0].Id, 'Account Director', 'Edit', testOpp.Id);
            PRMUtilityClass.updateSLAdate();
            System.assertNotEquals(testOpp.id,null);
            
            cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
            testBasket.csbb__Account__c = testAccount.Id;
            testBasket.Name = 'ShowSubTestBasket';
            testBasket.cscfga__Opportunity__c = testOpp.Id;
            insert testBasket;
            
            List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
            cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
            pdList.add(CW_PD);
            cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
            pdList.add(ucePD);
            cscfga__Product_Definition__c IPNet_PD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
            pdList.add(IPNet_PD);
            cscfga__Product_Definition__c Mob_PD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility',product_Specification__c='DMCAT_ProductSpecification_000420');
            pdList.add(Mob_PD);
            insert pdList;
            
            List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
            cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
            testConfig = SYS_TestDataFactory.createProductConfigurationRec(new Map<String, String>{'Name' => 'Connected Workplace', 'cscfga__Product_Basket__c' => testBasket.Id, 'cscfga__Product_Definition__c' => CW_PD.id });
            prodconfigList.add(testConfig);
            prodconfigList.add(SYS_TestDataFactory.createProductConfigurationRec(new Map<String, String>{'Name' => 'Connected Workplace', 'cscfga__Product_Basket__c' => testBasket.Id, 'cscfga__Product_Definition__c' => ucePD.id }));
            prodconfigList.add(SYS_TestDataFactory.createProductConfigurationRec(new Map<String, String>{'Name' => 'Connected Workplace', 'cscfga__Product_Basket__c' => testBasket.Id, 'cscfga__Product_Definition__c' => IPNet_PD.id }));
            prodconfigList.add(SYS_TestDataFactory.createProductConfigurationRec(new Map<String, String>{'Name' => 'Connected Workplace', 'cscfga__Product_Basket__c' => testBasket.Id, 'cscfga__Product_Definition__c' => Mob_PD.id }));
            
            
            insert prodconfigList;
            
            cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
            testAttribute.Name = 'testAttributeForTest';
            testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
            insert testAttribute;
            
            csord__Order__c testOrder = new csord__Order__c();
            testOrder.csord__Account__c = testAccount.Id;
            testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
            testOrder.Name = 'TestOrderNameForTest';
            testOrder.csord__Identification__c = 'test';
            testOrder.isMSISDNHeld__c = false;
            insert testOrder;
            System.assertNotEquals(testOrder.id,null);
            
            csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
            testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
            testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
            
            insert testOso;
            
            List<csord__Subscription__c> listofSub = new List<csord__Subscription__c>();
            for(Integer i=0;i<6;i++){
                csord__Subscription__c testSubscription = new csord__Subscription__c();
                testSubscription.Name = 'TestSubsforTest'+i;
                testSubscription.csord__Account__c = testAccount.Id;
                testSubscription.csord__Order__c = testOrder.Id;
                testSubscription.csord__Identification__c = 'test';
                testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
                testSubscription.csord__Status__c = 'NA';
                testSubscription.stage__c = 'NA';
                listofSub.add(testSubscription);
            }
            try{
                insert listofSub;
                PRMUtilityClass.addMarkupBeginSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.LIST_TEXT);
                PRMUtilityClass.addMarkupBeginSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.BOLD_TEXT);
                PRMUtilityClass.addMarkupBeginSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.UNDERLINE);
                
                PRMUtilityClass.addMarkupEndSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.LIST_TEXT);
                PRMUtilityClass.addMarkupEndSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.HYPERLINK);
                PRMUtilityClass.addMarkupEndSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.BOLD_TEXT);
                PRMUtilityClass.addMarkupEndSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.UNDERLINE);
            }
            catch(Exception e){
                system.debug('@@Exception from test class:'+e.getMessage());
            }            
        }
        
    }
    @isTest 
    static void testSubscriptionTrigger(){
        
        test.starttest();
        List<csord__Subscription__c> testSubscriptionlst = [select id,csord__Status__c,csordtelcoa__Replaced_Subscription__c,Initial_Activation_DateTime__c,initialActivationDate__c
                                                            from csord__Subscription__c];
        
        
        testSubscriptionlst[0].csord__Status__c = C2O_OrderConstants.ACTIVE;
        testSubscriptionlst[1].csord__Status__c = C2O_OrderConstants.PAID_OUT;
        testSubscriptionlst[2].csord__Status__c = C2O_OrderConstants.INACTIVE;
        testSubscriptionlst[3].csord__Status__c = C2O_OrderConstants.ACTIVE;
        testSubscriptionlst[3].csordtelcoa__Replaced_Subscription__c = testSubscriptionlst[4].Id;
        testSubscriptionlst[5].stage__c = C2O_OrderConstants.STAGE_BEING_FULFILLED;
        update testSubscriptionlst;
        
        test.stoptest();
    }
}