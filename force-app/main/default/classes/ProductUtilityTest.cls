/**
* 
Class Name      :   ProductUtilityTest
Main Class      :   ProductUtility
===============================================================================================================================
1.      Initial Class
2.      Laxmi Rahate       10/04/2020    EDGE-133414 Added test methods and increased coverage
3.      Laxmi Rahate       14/04/2020    EDGE-144345 Technical Debt - added start, stop and run as
4.      Ankit Goswami      10/12/2020  ` EDGE-173495  Device Transition configuration
************************************************************************************/

@isTest
public class ProductUtilityTest 
{   
    static String PROD_CONFIGURATION_TYPE_NEW = 'New';
    static String PROD_CONFIGURATION_STATUS_INVALID = 'Incomplete';
    static String PROD_CONFIGURATION_STATUS_VALID = 'Valid';
    static String PRODUCT_BASKET_STAGE = 'Contract Accepted';
     
    @testSetup
    static void testdata(){

        Account testAccount = AccountTestFactory.buildAccount ('testAccount');
        // Laxmi - EDGE-133414 added below record type code ode to satisfy partner type condition
        RecordType recType = [Select id, name From RecordType Where sObjectType = 'Account' and Name = 'Partner'];
        testAccount.RecordTypeID = recType.id;
        // EDGE-133414 changes end
        insert testAccount;
        
        //EDGE-144345  changed to use ProductTestFactory
        Opportunity testOpp = ProductTestFactory.getOpportunityBasic (testAccount);
        testOpp.Account = testAccount;
        testOpp.Product_Type__c = 'Modular';
        insert testOpp;

        cscfga__Product_Basket__c testBasket = ProductTestFactory.buildEmptyBasket();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
       // testBasket.csordtelcoa__Change_Type__c = 'Upgrade';
        insert testBasket;
        
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
        pd1.Name = 'IP Network';
        pd1.cscfga__Description__c = 'Description';
        insert pd1;
       
        List <cscfga__Product_Configuration__c> listTestConfig = new List <cscfga__Product_Configuration__c>();
 
        //EDGE-144345  changed to use ProductTestFactory
        cscfga__Product_Configuration__c testConfig = ProductTestFactory.buildProductConfig (pd1.id );
        testConfig.Name = 'IP Network1';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Family__c = 'Modular';
        testConfig.Quantity_Product_Configuration__c = 1;
        testConfig.cscfga__Contract_Term__c = 12;
        testConfig.cscfga__Product_Definition__c =pd1.id ;
        testConfig.Quantity_Product_Configuration__c = 6;
        testConfig.cscfga__discounts__c = '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        testConfig.cscfga__total_recurring_charge__c = 100;
        testConfig.cscfga__total_one_off_charge__c = 10;
        listTestConfig.add (testConfig);
    
        
        // Added as part of EDGE-133414
        cscfga__Product_Configuration__c testConfigCancel = ProductTestFactory.buildProductConfig (pd1.id );
        testConfigCancel.Name = 'IP Network';
        testConfigCancel.cscfga__Product_Basket__c = testBasket.Id;
        testConfigCancel.cscfga__Product_Family__c = 'Modular';
        testConfigCancel.Quantity_Product_Configuration__c = 1;
        testConfigCancel.cscfga__Contract_Term__c = 12;
        testConfigCancel.Type__c ='Cancel';
        testConfigCancel.cscfga__discounts__c = '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        testConfigCancel.Quantity_Product_Configuration__c = 6;
        testConfig.cscfga__total_recurring_charge__c = 100;
        testConfig.cscfga__total_one_off_charge__c = 10;
        listTestConfig.add (testConfigCancel);

        insert listTestConfig;
           
        // EDGE-133414 Changes END
        List <cscfga__Attribute__c> listTestAttribute = new List <cscfga__Attribute__c>();

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'EarlyTerminationCharge';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        testAttribute.cscfga__Is_Line_Item__c = true;
        testAttribute.cscfga__is_active__c = true;
        //testAttribute.cscfga__Product_Configuration__r =  testConfig;
        testAttribute.cscfga__Line_Item_Description__c = 'Test';        
        testAttribute.cscfga__Recurring__c = true;
        testAttribute.cscfga__Price__c = 100;
        listTestAttribute.add (testAttribute); // Added as part of EDGE-133414

        cscfga__Attribute__c testChargeAttribute = new cscfga__Attribute__c();
        testChargeAttribute.Name = 'RC';
        testChargeAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        testChargeAttribute.cscfga__Is_Line_Item__c = true;
        testChargeAttribute.cscfga__is_active__c = true;
        //testAttribute.cscfga__Product_Configuration__r =  testConfig;
        testChargeAttribute.cscfga__Line_Item_Description__c = 'Test';        
        testChargeAttribute.cscfga__Recurring__c = true;
        testChargeAttribute.cscfga__Price__c = 59.09;
        testChargeAttribute.cscfga__Value__c = '59.09';
        testChargeAttribute.cscfga__List_Price__c = 59.09;
        testChargeAttribute.cscfga__Discount_Type__c = 'amount';

        
        listTestAttribute.add (testChargeAttribute); // Added as part of EDGE-185438
    
        // Added as part of EDGE-133414
        cscfga__Attribute__c testAttributeETC =  ProductTestFactory.buildPriceAttribute ('ETCCancel','100',testConfigCancel.Id,true,100); 
        testAttributeETC.cscfga__Is_Line_Item__c = true;
        testAttributeETC.cscfga__is_active__c = true;
        testAttributeETC.cscfga__Line_Item_Description__c = 'Test Cancel';        
       
        listTestAttribute.add (testAttributeETC);
        insert listTestAttribute; 
        // EDGE-133414  Changes END

        // EDGE-185438 Insert Incremental Revenue for RC
        cscfga__Attribute_Field__c testIncRevAttribute = new cscfga__Attribute_Field__c();
        testIncRevAttribute.cscfga__Attribute__c = testChargeAttribute.Id;
        testIncRevAttribute.Name = 'IncrementalRevenue';
        testIncRevAttribute.cscfga__Value__c = '709.08';
        insert testIncRevAttribute;

          //EDGE-173495 :|| start
        List<cscfga__Attribute_Field__c> attrFieldList= new  List<cscfga__Attribute_Field__c>();
        cscfga__Attribute_Field__c attrField=new cscfga__Attribute_Field__c();
        attrField.name ='IncrementalRevenue';
        attrField.cscfga__Attribute__c=testAttribute.id;
        attrField.cscfga__Value__c='0';
        attrFieldList.add(attrField);
        
        cscfga__Attribute_Field__c attrField1=new cscfga__Attribute_Field__c();
        attrField1.name ='TechTransRevenue';
        attrField1.cscfga__Attribute__c=testAttributeETC.id;
        attrField1.cscfga__Value__c='0';
        attrFieldList.add(attrField1);
        insert attrFieldList;
        
        Product2 prodct2=new Product2();
        prodct2.Family='Modular'; 
        prodct2.IsActive=true;
        prodct2.Name='Test';
        prodct2.ProductCode='test';
        insert prodct2;
         //EDGE-173495 :|| end

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        insert testOrder;

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;
        
        Marketable_Offer__c marOff = new Marketable_Offer__c();
        marOff.Name = 'Enterprise Mobility Managed Service';
        marOff.Offer_ID__c = 'DMCAT_Offer_000854';
        insert marOff;

        List <csord__Subscription__c> listTestSubscription = new List <csord__Subscription__c>(); // Added as part of 133414 as multiple inserts were done

        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'IP Network';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        testSubscription.MarketableOffer__c = marOff.id; 
        listTestSubscription.add (testSubscription);
        
        
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'Unified Communication Enterprise';
        testSubscription1.csord__Account__c = testAccount.Id;
        testSubscription1.csord__Order__c = testOrder.Id;
        testSubscription1.csord__Identification__c = 'test';
        testSubscription1.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription1.csord__Status__c = 'Active';
        testSubscription1.MarketableOffer__c = marOff.id; 
        listTestSubscription.add (testSubscription1);

        insert listTestSubscription; // Changed as part of EDGE-133414 - Inserted list instead of multiple inserts
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='User - Fixed Seat';
        serv2.csordtelcoa__Product_Configuration__c = testConfig.id;
        serv2.csord__Identification__c  = 'testIdentify_2';
        serv2.csord__Subscription__c = testSubscription.Id;
        insert serv2; 
     
        //Added as part of EDGE-144345  
        List <User> userList = new List <User>();
        Profile testProfile = [select id from profile where name =:Label.Profile_SalesEnterprise];  
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingProdUtil', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = testProfile.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');     
        userList.add (sales);
        
             
        Profile testProfileAdmin = [select id from profile where name =:Label.Profile_SystemAdmin];  
        User admin = new User(alias = 'standt',email='admin@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdmin', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = testProfileAdmin.id,
                              timezonesidkey='Australia/Sydney',
                              username='admin@testsales.com',phone='+121231231256');   
        userList.add(admin);
        insert userList;
        
        // Changes End EDGE-144345  

    }
    
    @istest 
    public static void CreateOLIsTest(){
       //  EDGE-144345  - Added Run as , test.startTest(),test.stopTest() and changed the assertNot equal to Null to actual expected
  

        User admin = [ select name,id, lastname from  User where lastname = 'TestingAdmin' ];
        System.runAS (admin){  
            
            cscfga__Product_Basket__c basketTest = [Select csordtelcoa__Synchronised_with_Opportunity__c, id from cscfga__Product_Basket__c Limit 1];
            test.startTest();
            set<string> setUnSyncedProductBasketId = new set<string>();
            setUnSyncedProductBasketId.add(basketTest.id);      
            ProductUtility.CreateOLIs(setUnSyncedProductBasketId);
            Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
            test.stopTest();
            System.assertEquals(5,opp1.Opportunity_Line_Item_Count__c);
        }
    }
            @istest 
      public static void CreateOLIsAsyncTest(){
            cscfga__Product_Basket__c basketTest = [Select csordtelcoa__Synchronised_with_Opportunity__c, id from cscfga__Product_Basket__c Limit 1];
        Test.startTest();
            set<string> setUnSyncedProductBasketId = new set<string>();
            setUnSyncedProductBasketId.add(basketTest.id);
            ProductUtility.createOLIsAsync(setUnSyncedProductBasketId);
            Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
            Test.stopTest();
            System.assertNotEquals(null,opp1.Id);
        }

//   @istest 
//         private static void populateOppLineItemTest(){
//         //  EDGE-144345  - Added Run as , test.startTest(),test.stopTest() and changed the assertNot equal to Null to actual expected
        
//         User sales = [ select name,id, lastname from  User where lastname = 'TestingProdUtil' ];
//         System.runAS (sales){           
//             test.startTest();
//             // OpportunityLineItem tmpOpportunityLineItem  = ProductUtility.populateOppLineItem();        
//             //System.assertNotEquals(null, tmpOpportunityLineItem);  
            
//             cscfga__Attribute__c att = new cscfga__Attribute__c(Name = 'RC');
//             att.cscfga__Price__c = 2;
//             att.cscfga__Recurring__c = true;
//             // tmpOpportunityLineItem = ProductUtility.getTmpOpportunityLineItem(tmpOpportunityLineItem, att, true);
//             test.stopTest();
//             // System.assertEquals(tmpOpportunityLineItem.Recurring_Price__c,2); 
//         }
//     }
    
     
//     //Added as part of EDGE-133414 to cover Cancel  Scenario

//     @istest 
//     public static void populateOppLineItemTestCancelNegative(){
//         User sales = [ select name,id, lastname from  User where lastname = 'TestingProdUtil' ];
//         System.runAS (sales){   
//         test.startTest();

//         // OpportunityLineItem tmpOpportunityLineItem  = ProductUtility.populateOppLineItem();        
//         //System.assertNotEquals(null, tmpOpportunityLineItem);  
//         cscfga__Attribute__c att1 = [Select id, name,cscfga__Price__c,
//                                     cscfga__Attribute__c.cscfga__Product_Configuration__r.cscfga__Contract_Term__c,
//                                     cscfga__Is_Line_Item__c,
//                                     cscfga__Line_Item_Sequence__c,
//                                     cscfga__is_active__c,cscfga__Line_Item_Description__c,cscfga__Recurring__c ,
//                                     cscfga__Product_Configuration__r.cscfga__Product_Family__c,
//                                     cscfga__Product_Configuration__r.cscfga__Product_Basket__c,
//                                     cscfga__Product_Configuration__r.Name,
//                                     cscfga__Product_Configuration__r.cscfga__Quantity__c,
//                                     cscfga__Product_Configuration__r.Quantity_Product_Configuration__c,
//                                     cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
//                                     cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.Mobile_Code__c,
//                                     cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.Name,
//                                     cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c,
//                                     cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.RecordType.DeveloperName,
//                                     cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c,
//                                     cscfga__Product_Configuration__r.Type__c,
//                                     cscfga__Attribute__c.cscfga__Value__c
//                                     from  cscfga__Attribute__c where name = 'ETCCancel']; 
//         // tmpOpportunityLineItem = ProductUtility.getTmpOpportunityLineItem(tmpOpportunityLineItem, att1, true);
//         test.stopTest();

//         // System.assertEquals(tmpOpportunityLineItem.Recurring_Price__c,0);       
//         }
//     }
    
//     @istest 
//     private static void DeleteHardOLIsTest(){
        
//             //  EDGE-144345  - Added Run as , test.startTest(),test.stopTest() and changed the assertNot equal to Null to actual expected
//             User admin = [ select name,id, lastname from  User where lastname = 'TestingAdmin' ];
//             System.runAS (admin){   
//             //OpportunityLineItem tmpOpportunityLineItem  = ProductUtility.populateOppLineItem();        
     
//             cscfga__Attribute__c att = new cscfga__Attribute__c(Name = 'RC');
//             att.cscfga__Price__c = 2;
//             att.cscfga__Recurring__c = true;
//             //tmpOpportunityLineItem = ProductUtility.getTmpOpportunityLineItem(tmpOpportunityLineItem, att, true);
            
//             cscfga__Product_Basket__c basketTest = [Select csordtelcoa__Synchronised_with_Opportunity__c, id from cscfga__Product_Basket__c Limit 1];
//             set<string> setUnSyncedProductBasketId = new set<string>();
//             setUnSyncedProductBasketId.add(basketTest.id);
//             test.startTest(); // Added Test.start & Test.stop
//             ProductUtility.CreateOLIs(setUnSyncedProductBasketId);
//             ProductUtility.DeleteHardOLIs(setUnSyncedProductBasketId);
//             Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
//             test.stopTest();
//             System.assertEquals(0,opp1.Opportunity_Line_Item_Count__c);
//         }
//     }   
}