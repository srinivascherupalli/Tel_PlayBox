/**************************************************************************************
 * Author      : Romil Anand
 * Class Name  : BasketRedemptionHelperTest
 * Related Class : BasketRedemptionHelper 
 * Description : Test class for the class BasketRedemptionHelper. 
 * Story       : EDGE-113091 and EDGE-112717 - Show available OneFund balance from CIDN at the time of basket creation
 **************************************************************************************/
@isTest
public class BasketRedemptionHelperTest {
 
    @testsetup 
    static void testdata() { 
        //Create Account
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE');
        insert acc;

        //Create Opportunity
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        
        Id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
        Id oneFundAccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
        Id redemptionRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Redemptions').getRecordTypeId();
        //Create OneFund
        OneFund__c oneFund = new OneFund__c(RecordTypeId = flexibleRecordId, CIDN__c=acc.id, OneFund_Accrual_Frequency__c='Monthly', OneFund_Status__c='Active');
        insert oneFund;
                
        OneFund_Transactions__c oneFundTransaction = new OneFund_Transactions__c(RecordTypeId = oneFundAccrualRecordId, OneFund__c=oneFund.id, Transaction_Status__c='Active', Transaction_Amount__c=9300.00, Expiry_Date__c = system.today(),Comments__c = 'added expiry');
        insert oneFundTransaction;
        
        OneFund_Transactions__c oneFundTransactionre = new OneFund_Transactions__c(RecordTypeId = redemptionRecordId, OneFund__c=oneFund.id, Transaction_Status__c='Active', Transaction_Amount__c=9300.00, Expiry_Date__c = system.today(),Comments__c = 'added expiry');
        insert oneFundTransactionre;
        
        //Create Product Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.name='BT000-076-437';
        basket.csordtelcoa__Basket_Stage__c='Contract Rejected';
        basket.csbb__Synchronised_With_Opportunity__c=true;
        insert basket;

        //Create Product Configuration
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.Name = System.Label.Label_CMP;
        config.cscfga__Description__c = 'Test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.Type__c = 'New';
        update config;  
        
        //create Attribute
        List<cscfga__Attribute__c> attribute = new List<cscfga__Attribute__c>();
        attribute.add(new cscfga__Attribute__c(Name='RedeemFund',cscfga__Value__c = '55.00',cscfga__Product_Configuration__c=config.id));
        //attribute.add(new cscfga__Attribute__c(Name='RedeemFund',cscfga__Value__c = '25.00',cscfga__Product_Configuration__c=configre.id));
        insert attribute;
       
    
        }
    /**********************************************************************************************
    * Method Name : GetBasketTest
    * Description : Used to simulate and test the logic of GetBasket method.
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void getBasketTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        inputMap.put('GetBasket', basket.Name);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = BasketRedemptionHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals(true, inputMap.size()>0,'No Information about this basket');        
    }
     
    /**********************************************************************************************
    * Method Name : testRunWithBasket For Redemption
    * Description : Used to simulate and test the Basket Redemption amount.
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    @isTest 
    static void testRunWithBasketRedemption() {
        cscfga__Product_Basket__c basketId = [SELECT id, Name, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where csordtelcoa__Basket_Stage__c='Contract Rejected' LIMIT 1];
        Test.startTest();
        Double sumOfbasketRedemp = BasketRedemptionHelper.getBasket(basketId.Name);
           Test.stopTest(); 
        System.assertNotEquals(Null, sumOfbasketRedemp,'Basket Redemption amount is equal to null');
 
    }    
    /**********************************************************************************************
    * Method Name : testRunWithInflightCancelPC For Redemption
    * Description : Used to simulate and test the Basket Redemption amount.
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    @isTest 
    static void testRunWithInflightCancelPC() {
        cscfga__Product_Basket__c basketId = [SELECT id, Name, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where csordtelcoa__Basket_Stage__c='Contract Rejected' LIMIT 1];
        //Create Product Configuration
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basketId.id;
        config.Name = System.Label.Label_CMP;
        config.cscfga__Description__c = 'Test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.Type__c = 'New';
        config.subType__c = 'Inflight Cancel';
        update config;  
        
        //create Attribute
        List<cscfga__Attribute__c> attribute = new List<cscfga__Attribute__c>();
        attribute.add(new cscfga__Attribute__c(Name='RedeemFund',cscfga__Value__c = '55.00',cscfga__Product_Configuration__c=config.id));
        insert attribute;
                
        Test.startTest();
        Double sumOfbasketRedemp = BasketRedemptionHelper.getBasket(basketId.Name);
           Test.stopTest(); 
        System.assertNotEquals(Null, sumOfbasketRedemp,'Basket Redemption amount is equal to null');
 
    }   
}