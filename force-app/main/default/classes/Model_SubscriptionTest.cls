/****************************************************************************************************************************************************
Main Class : Model_Subscription
Test Class : Model_SubscriptionTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story          Sprint               Description
1.        Aman Soni           07/07/2020      EDGE-147513    20.09(New Class)     To cover Model_Subscription functionality
2.        Aman Soni           03/03/2021      EDGE-191138    21.03                Added new test methods
3.        Aman Soni           25/03/2021      EDGE-199911    21.04                Added new test methods
=====================================================================================================================================================
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_SubscriptionTest{
   @TestSetup
   public static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    
    String str1 = '';
    String str2 = '';
    String statusValues=System.Label.BillingAccountStatus;
    Set<String> billingAccStatusSet=new Set<String>(statusValues.split(','));
    if(billingAccStatusSet.contains('Pending Finalisation'))
    str1 = 'Pending Finalisation';

    if(billingAccStatusSet.contains('Final'))
    str2 = 'Final';
    
    List<csord__Solution__c> solLst = new List<csord__Solution__c>();
    csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
    solLst.add(sol1);
    
    csord__Solution__c sol2= PricingTestDataFactory.generateSolution('nextgenEM_negative');
    solLst.add(sol2);
    insert solLst;
    
    List<Billing_Account__c> billAccLst= new List<Billing_Account__c>();
    Billing_Account__c bilAcc1 = new Billing_Account__c();
    bilAcc1.Billing_Account_Number__c = '700000567151';
    bilAcc1.Status__c = str1;
    billAccLst.add(bilAcc1);
    
    Billing_Account__c bilAcc2 = new Billing_Account__c();
    bilAcc2.Billing_Account_Number__c = '700000567152';
    bilAcc2.Status__c = str2;
    billAccLst.add(bilAcc2);
    insert billAccLst;
    
    //Added by Aman Soni for EDGE-199911 || Start
    List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>();
    cscfga__Product_Definition__c prodDefMS = new cscfga__Product_Definition__c();
    prodDefMS.product_Specification__c ='DMCAT_ProductSpecification_000420';
    prodDefMS.cscfga__Description__c ='Mobile Subscription';
    prodDefList.add(prodDefMS);
    insert prodDefList;
    //Added by Aman Soni for EDGE-199911 || End
    
    //Added by Aman Soni for EDGE-191138 || Start
    List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();         
    basket.name = 'Test Basket';
    basketLst.add(basket);
    insert basketLst;
    
    List<cscfga__Product_Configuration__c> configLst = new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();         
    config.name = 'Test Config';
    config.cscfga__Product_Basket__c = basket.Id;
    config.ConfigurationType1__c = '';
    configLst.add(config);
    
    //Added by Aman Soni for EDGE-199911 || Start
    cscfga__Product_Configuration__c configMS = new cscfga__Product_Configuration__c();         
    configMS.name = 'Test Config';
    configMS.cscfga__Product_Basket__c = basket.Id;
    configMS.cscfga__Product_Definition__c = prodDefMS.Id;
    configLst.add(configMS);
    //Added by Aman Soni for EDGE-199911 || End
    insert configLst;
    
    //Added by Aman Soni for EDGE-191138 || End
    List<csord__Order__c> orderList = new List<csord__Order__c>();
    csord__Order__c order = new csord__Order__c();  
    order.Name = 'Test Incoming Order';
    order.csord__Identification__c = 'Order_0';
    order.Product_Basket__c = basket.Id;
    orderList.add(order);
    insert orderList;
    
    List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
    csord__Subscription__c sub1 = new csord__Subscription__c();         
    sub1.Billing_Account__c = bilAcc1.id;
    sub1.cssdm__solution_association__c = sol1.id;
    sub1.csord__Identification__c = 'Subscription_0';
    sub1.csord__Order__c = order.id;
    sub1.csordtelcoa__Product_Configuration__c = config.id;//Added by Aman Soni for EDGE-191138 
    sub1.name = 'Test CHOWN Subscription';
    subList.add(sub1);
    
    csord__Subscription__c sub2 = new csord__Subscription__c();         
    sub2.Billing_Account__c = bilAcc2.id;
    sub2.cssdm__solution_association__c = sol2.id;
    sub2.csord__Identification__c = 'Subscription_1';
    sub2.csord__Order__c = order.id;
    sub2.csordtelcoa__Product_Configuration__c = config.id;//Added by Aman Soni for EDGE-191138 
    subList.add(sub2);
    
    //Added by Aman Soni for EDGE-199911 || Start
    csord__Subscription__c subMS = new csord__Subscription__c();
    subMS.csord__Identification__c = 'Subscription_2';
    subMS.csord__Order__c = order.id;
    subMS.csordtelcoa__Product_Configuration__c = configMS.id;//Added by Aman Soni for EDGE-191138 
    subList.add(subMS);
    //Added by Aman Soni for EDGE-199911 || End
    insert subList;

   }
    @isTest static void getSubscriptionsbasedonBillaccStatusPositive(){
        List<csord__Solution__c> solLst = [SELECT id, Name FROM csord__Solution__c];
        List<String> solStrLst = new List<String>();        
        for(csord__Solution__c sol :solLst){
            solStrLst.add(sol.id);
        }       
        Set<String> solStrSet = new Set<String>(solStrLst);
        
        List<Billing_Account__c> billAccLst = [SELECT id, Billing_Account_Number__c, Status__c FROM Billing_Account__c];
        List<String> billAccStrLst = new List<String>();
        for(Billing_Account__c billAcc :billAccLst){
            billAccStrLst.add(billAcc.id);
        }
        Set<String> billAccStrSet = new Set<String>(billAccStrLst);
        
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            Map<String,csord__Subscription__c> subMap = Model_Subscription.getSubscriptionsbasedonBillaccStatus(solStrSet, billAccStrSet);
            System.assert(true, !subMap.isEmpty()); 
        }       
        Test.stopTest();
    }
    @isTest static void getSubscriptionsbasedonBillaccStatusPositiveNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            Map<String,csord__Subscription__c> subMap = Model_Subscription.getSubscriptionsbasedonBillaccStatus(null, null);
            System.assert(true, subMap.isEmpty()); 
        }
        Test.stopTest();
    }
    @isTest static void getSubscriptionsTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            csord__Subscription__c sub=[Select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c limit 1];
            csord__Subscription__c sub1 = Model_Subscription.getSubscriptionNumer(sub.id);
            System.assertEquals(sub.id, sub1.id); 
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-191138 || Positive Scenario 
    @isTest static void getSubscriptionsPositiveTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
        System.runAs(sales){
            cscfga__Product_Basket__c basketRec = [select id,name from cscfga__Product_Basket__c limit 1];
            Id basketId = basketRec.id; 
            List<Id> subIds = new List<Id>();
            List<csord__Subscription__c> subList = [SELECT Id,name,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c from csord__Subscription__c where name ='Test CHOWN Subscription' limit 1];
            if(!subList.isEmpty()){
                for(csord__Subscription__c subRec : subList){
                    subIds.add(subRec.id);
                }   
            }           
            List<csord__Subscription__c> subslist = Model_Subscription.getSubscriptions(subIds);
            for(csord__Subscription__c sub : subslist){
                System.assertEquals(sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, basketId);
            }            
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-191138 || Negative Scenario
    @isTest static void getSubscriptionsNegativeTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];        
        System.runAs(sales){
            List<Id> subIds = new List<Id>();
            List<csord__Subscription__c> subslist = Model_Subscription.getSubscriptions(subIds);
            System.assertEquals(subslist.size(), 0);           
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-191138 || Positive Scenario 
    @isTest static void getCHOWNSubscriptionPositiveTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
        System.runAs(sales){
            List<Id> basketIdLst = new List<Id>();
            List<csord__Subscription__c> subslist = new List<csord__Subscription__c>();
            List<cscfga__Product_Basket__c> basketList = [select id,name from cscfga__Product_Basket__c limit 1];
            if(!basketList.isEmpty()){
                for(cscfga__Product_Basket__c basket : basketList){
                    basketIdLst.add(basket.id);
                }
            }           
            subslist = Model_Subscription.getCHOWNSubscription(basketIdLst);
            for(csord__Subscription__c sub : subslist){
                System.assertEquals(sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, null);
            }       
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-191138 || Negative Scenario
    @isTest static void getCHOWNSubscriptionNegativeTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];        
        System.runAs(sales){
            List<Id> basketIds = new List<Id>();
            List<csord__Subscription__c> subslist = Model_Subscription.getCHOWNSubscription(basketIds);
            System.assertEquals(subslist.size(), 0);           
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-191138 || Positive Scenario 
    @isTest static void getOrderFromSubscriptionPositiveTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
        System.runAs(sales){
            List<csord__Subscription__c> subslist = new List<csord__Subscription__c>();
            cscfga__Product_Basket__c basket = [select id,name from cscfga__Product_Basket__c limit 1]; 
            csord__Order__c order = [select id,name from csord__Order__c limit 1];  
            String basketId = basket.Id;
            subslist = Model_Subscription.getOrderFromSubscription(basketId);
            for(csord__Subscription__c sub : subslist){
                System.assertEquals(sub.csord__Order__c, order.id);
            }       
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-191138 || Negative Scenario
    @isTest static void getOrderFromSubscriptionNegativeTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];        
        System.runAs(sales){
            List<csord__Subscription__c> subslist = new List<csord__Subscription__c>();
            String basketId = '';
            subslist = Model_Subscription.getOrderFromSubscription(basketId);
            System.assertEquals(subslist.size(), 0);           
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-199911 || Positive Scenario 
    @isTest static void getSubsNicknameForOrderPositiveTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
        System.runAs(sales){
            Set<csord__Subscription__c> subsSet = new Set<csord__Subscription__c>();
            csord__Order__c order = [select id,name from csord__Order__c limit 1];  
            String orderId = order.Id;
            subsSet = Model_Subscription.getSubsNicknameForOrder(orderId);
            for(csord__Subscription__c sub : subsSet){
                System.assertEquals(sub.csord__Order__c, order.id);
            }       
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-199911 || Negative Scenario
    @isTest static void getSubsNicknameForOrderNegativeTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];        
        System.runAs(sales){
            Set<csord__Subscription__c> subsSet = new Set<csord__Subscription__c>();
            String orderId = '';
            subsSet = Model_Subscription.getSubsNicknameForOrder(orderId);
            System.assertEquals(subsSet.size(), 0);           
        }
        Test.stopTest();
    }
     //DIGI-19162 : 
     @isTest static void getListOfSubscriptionTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];        
        System.runAs(sales){
            List<csord__Subscription__c> subsSet = new List<csord__Subscription__c>();
            List<csord__Order__c> orderList = new List<csord__Order__c>([Select Id FROM csord__Order__c]);
            List<Id> orderIdList = new List<Id>();
            for(csord__Order__c order : orderList){
                orderIdList.add(order.Id);
            }
            subsSet = Model_Subscription.getListOfSubscriptions(orderIdList);     
        }
        Test.stopTest();
    }
}