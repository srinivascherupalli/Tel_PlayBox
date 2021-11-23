/*************************************************************************************************
Name : Model_ProductBasketTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Ankit             03-Nov-2020       EDGE-181979 (New class)
2.     shubhi v      15/01/2020      EDGE-170016
3.        Shubhi            9/02/2021           EDGE-193068
4.      Aman Soni          02-Mar-2021          EDGE-191138 
===============================================================================================================================
***************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_ProductBasketTest{
   @TestSetup
   public static void testSetup(){
    //CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE',CIDN__c = 'ABC1234560');
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
         basket3.Project_Complexity__c='Simplex';
        basket3.Project_ID__c = 'basket3';
        basket3.BasketType__c = 'Outgoing';
        insert new List<cscfga__Product_Basket__c>{basket1,basket2,basket3};
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
    
    @isTest
     static void Model_ProductBasketTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
         System.runAs(sales){
        cscfga__Product_Basket__c productBasket=[Select id,Project_Complexity__c,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
        cscfga__Product_Basket__c pbobj=Model_ProductBasket.getProductBasket(productBasket.id);
        System.assertEquals(productBasket.Project_Complexity__c, pbobj.Project_Complexity__c);
        }
        Test.stopTest();
    }
    @isTest
     static  void Model_ProductBasketTestNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
         cscfga__Product_Basket__c pbobj=Model_ProductBasket.getProductBasket('');
        System.assertEquals(false, pbobj==null);
        }
        Test.stopTest();
    }
    //EDGE-170016 start----------------------------
    @isTest
    static void getProductBasketonLoadSolutionTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
         System.runAs(sales){
        cscfga__Product_Basket__c productBasket=[Select id,Name,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
        cscfga__Product_Basket__c pbobj=Model_ProductBasket.getProductBasketonLoadSolution(productBasket.id);
        System.assertEquals(productBasket.name, pbobj.name);
        }
        Test.stopTest();
    }
    @isTest
     static void getProductBasketonLoadSolutionNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
         cscfga__Product_Basket__c pbobj=Model_ProductBasket.getProductBasketonLoadSolution('');
        System.assertEquals(false, pbobj==null);
        }
        Test.stopTest();
    }
    //EDGE-170016 end----------------------------
    //Added by Shubhi for EDGE-193068 on 9/2/2021 starts
        @isTest
     static void Model_ProductBasketAccountCIDNTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
         System.runAs(sales){
            cscfga__Product_Basket__c productBasket=[Select id,Project_Complexity__c,csbb__Account__c,csbb__Account__r.CIDN__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
            Set<String> basketIdSet=new Set<String>();
            basketIdSet.add(productBasket.id);
            List<cscfga__Product_Basket__c> pbobj=Model_ProductBasket.getProductBasketAccount(basketIdSet);
            System.assertEquals(productBasket.csbb__Account__r.CIDN__c , pbobj[0].csbb__Account__r.CIDN__c);
        }
        Test.stopTest();
    }
    
    @isTest
     static  void Model_ProductBasketAccountCIDNNegativeTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
            Set<String> basketIdSet=new Set<String>();
            //basketIdSet.add(productBasket.id);
            List<cscfga__Product_Basket__c> pbobj=new List<cscfga__Product_Basket__c>();
            pbobj=Model_ProductBasket.getProductBasketAccount(basketIdSet);
            System.assertEquals(false, pbobj==null);
        }
        Test.stopTest();
    }
     //Added by Shubhi for EDGE-193068 on 9/2/2021 ends
    //EDGE-170016 end----------------------------
    
    //Added by Aman Soni for EDGE-191138 || Positive Scenario
    @isTest static void getbasketForChownPositiveTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
         System.runAs(sales){
            cscfga__Product_Basket__c productBasket=[Select id,BasketType__c,Project_Complexity__c,csbb__Account__c,csbb__Account__r.CIDN__c from cscfga__Product_Basket__c where Project_ID__c='basket3' limit 1];
            Set<Id> basketIdSet=new Set<Id>();
            basketIdSet.add(productBasket.id);
            Set<cscfga__Product_Basket__c> basketSet = new Set<cscfga__Product_Basket__c>();
            if(!basketIdSet.isEmpty()){
                basketSet = Model_ProductBasket.getbasketForChown(basketIdSet);
            }
            for(cscfga__Product_Basket__c basket : basketSet){
                System.assertEquals(basket.BasketType__c, 'Outgoing');
            }
        }
        Test.stopTest();
    }
    
    //Added by Aman Soni for EDGE-191138 || Negative Scenario
    @isTest static void getbasketForChownNegativeTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
         System.runAs(sales){
            Set<Id> basketIdSet=new Set<Id>();
            Set<cscfga__Product_Basket__c> basketSet = Model_ProductBasket.getbasketForChown(basketIdSet);
            System.assertEquals(basketSet.size(), 0);
        }
        Test.stopTest();
    }

}