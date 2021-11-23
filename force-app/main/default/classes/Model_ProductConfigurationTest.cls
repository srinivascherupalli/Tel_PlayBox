/*************************************************************************************************
Name : Model_ProductConfigurationTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             1-july-2020        EDGE-147513 (New class)
2.         Aman Soni          6-Oct-2020         EDGE-176693
3.         Shubhi             12-11-2020         EDGE-181979
5.         Aman Soni          05-01-2021         EDGE-196842(Defect)
===============================================================================================================================
***************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_ProductConfigurationTest{
   @TestSetup
   public static void testSetup(){
    //CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE');
        insert acc;
        //CREATE CONTACT 
        Contact con1 = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
         );
        insert con1;    
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        
        insert pbe;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Project_ID__c = 'basket1';
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
        basket2.cscfga__Opportunity__c = opp.id;
        basket2.Project_ID__c = 'basket2';
        cscfga__Product_Basket__c basket3 = ProductTestFactory.buildEmptyBasket();
        basket3.csbb__Account__c = acc.id;
        basket3.cscfga__Opportunity__c = opp.id;
        basket3.Project_ID__c = 'basket3';
        
        //Added by Aman Soni for EDGE-176693 || Start
        cscfga__Product_Basket__c basket4 = ProductTestFactory.buildEmptyBasket();
        basket4.csbb__Account__c = acc.id;
        basket4.cscfga__Opportunity__c = opp.id;
        basket4.Project_ID__c = 'basket4';      
        basket4.cscfga__Basket_Status__c = 'Valid';     
        insert new List<cscfga__Product_Basket__c>{basket1,basket2,basket3,basket4};
        
        List<cscfga__Product_Configuration__c> transitionConfigs = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c();
        pc1.subType__c = 'Transition';
        pc1.cscfga__product_basket__c = basket4.id;
        transitionConfigs.add(pc1);
        insert transitionConfigs;
        //Added by Aman Soni for EDGE-176693 || End
        
        csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
        csord__Solution__c sol2= PricingTestDataFactory.generateSolution('nextgenEM_negative');
        insert new List<csord__Solution__c>{sol1,sol2};
        cscfga__Product_Configuration__c pc1_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','Modify',basket1.id,sol1.id,'');
        cscfga__Product_Configuration__c pc1_new= PricingTestDataFactory.generateProductConfiguration('','New',basket1.id,sol1.id,'');
        cscfga__Product_Configuration__c pc2_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','Modify',basket2.id,sol2.id,'');
        cscfga__Product_Configuration__c pc2_cancel= PricingTestDataFactory.generateProductConfiguration('','Cancel',basket2.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','New',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_modify= PricingTestDataFactory.generateProductConfiguration('','Modify',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_new= PricingTestDataFactory.generateProductConfiguration('','New',basket3.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_cancel= PricingTestDataFactory.generateProductConfiguration('','Cancel',basket3.id,sol2.id,'');

        insert new List<cscfga__Product_Configuration__c>{pc1_sol,pc1_new,pc2_sol,pc2_cancel,pc3_sol,pc3_modify,pc3_new,pc3_cancel};
         //Biiling accs
        Billing_Account__c billAcc1=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=con1.Id, status__c='Created',Account__c=acc.id);
        Billing_Account__c billAcc2=new Billing_Account__c(Billing_Account_Number__c='123456789013',Billing_Account_Owner__c=con1.Id,status__c='Final',Account__c=acc.id);
        insert new List<Billing_Account__c>{billAcc1,billAcc2};
        //attributes
        cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc1.id , pc1_sol.id);
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc2_sol.id);
        cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc3_sol.id);
        insert new List<cscfga__Attribute__c>{attr0,attr1,attr2};
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales; 
   }
    static testmethod void getConfigMap_positive(){      
        Test.startTest();
         User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1]; 
        Set<String> attNameFilterSet=new Set<String>{String.valueOf(System.Label.BillingAccountAttName)};       
        Map<String,cscfga__Product_Configuration__c> pcmap=Model_ProductConfiguration.getConfigMap(productBasket.id,attNameFilterSet);
        System.assertEquals(4, pcmap.size());
        Test.stopTest();
    }
    static testmethod void getDeviceTypeNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket2' limit 1];
        Set<String> attNameFilterSet=new Set<String>();
        Map<String,cscfga__Product_Configuration__c> pcmap=Model_ProductConfiguration.getConfigMap(productBasket.id,attNameFilterSet);
        System.assertEquals(0, pcmap.size());
        Test.stopTest();
    }
     static testmethod void getConfigListTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
         System.runAs(sales){
        cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
       list<cscfga__Product_Configuration__c> pcmap=Model_ProductConfiguration.getConfigList(productBasket.id);
        System.assertEquals(4, pcmap.size());
        }
        Test.stopTest();
    }
     static testmethod void getConfigListTestNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
         list<cscfga__Product_Configuration__c> pcmap=Model_ProductConfiguration.getConfigList('');
        System.assertEquals(0, pcmap.size());
        }
        Test.stopTest();
    }
    
    //Added by Aman Soni for EDGE-176693 || Start
    //Description :: Positive scenario for getConfigListForTTRUpdate
    static testmethod void getConfigListForTTRUpdateTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        cscfga__Product_Basket__c productBasket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket4' limit 1];
        Map<Id, cscfga__Product_Configuration__c> pcMap=Model_ProductConfiguration.getConfigListForTTRUpdate(productBasket.id,'Transition');
        System.assertEquals(1, pcMap.size());
        }
        Test.stopTest();
    }
    
    //Description :: Negative scenario for getConfigListForTTRUpdate
     static testmethod void getConfigListForTTRUpdateTestNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        Map<Id, cscfga__Product_Configuration__c> pcMap=Model_ProductConfiguration.getConfigListForTTRUpdate('', '');
        System.assertEquals(null, pcMap);//Modified for EDGE-196842 by Aman Soni 
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-176693 || End
    //Added by Shubhi for  EDGE-185011 || Start
    //Description :: Positive scenario for getConfig
    static testmethod void getConfigTestPositive(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        cscfga__Product_Configuration__c pc=[Select id from cscfga__Product_Configuration__c limit 1];
        cscfga__Product_Configuration__c pc1=Model_ProductConfiguration.getConfig(pc.id);
        System.assertEquals(pc.id, pc1.id);
        }
        Test.stopTest();
    }
    
    //Description :: Negative scenario for getConfig
     static testmethod void getConfigTestTestNegative(){
       Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
        cscfga__Product_Configuration__c pc=[Select id from cscfga__Product_Configuration__c limit 1];
        cscfga__Product_Configuration__c pc1=Model_ProductConfiguration.getConfig('');
            System.assertEquals(new cscfga__Product_Configuration__c(), pc1);
        }
        Test.stopTest();
    }
    //Added by Shubhi for EDGE-185011 || End
}