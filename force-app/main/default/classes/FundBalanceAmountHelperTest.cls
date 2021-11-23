/**************************************************************************************
 * Author      : Vishal Arbune
 * Class Name  : FundBalanceAmountHelperTest
 * Related Class : FundBalanceAmountHelper 
 * Description : Test class for the class FundBalanceAmountHelper. 
 * Story       : EDGE-113083 - Show available OneFund balance from CIDN at the time of basket creation
 **************************************************************************************/
@isTest
public class FundBalanceAmountHelperTest {
    @testsetup 
    static void testdata() { 
        //Create Account
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE');
        insert acc;
        System.assertNotEquals(null,acc);
        
        //Create Opportunity
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        System.assertNotEquals(null,opp);
        
        Id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
        Id oneFundAccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
        
        //Create OneFund
        OneFund__c oneFund = new OneFund__c(RecordTypeId = flexibleRecordId, CIDN__c=acc.id, OneFund_Accrual_Frequency__c='Monthly', OneFund_Status__c='Active');
        insert oneFund;
        System.assertNotEquals(null,oneFund);
                
        OneFund_Transactions__c oneFundTransaction = new OneFund_Transactions__c(RecordTypeId = oneFundAccrualRecordId, OneFund__c=oneFund.id, Transaction_Status__c='Active', Transaction_Amount__c=9300.00, Expiry_Date__c = system.today(),Comments__c = 'added expiry');
        insert oneFundTransaction;
        System.assertNotEquals(null,oneFund);
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'BT000-098-729';
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert basket; 
                
        //Create Product Configuration
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.Name = System.Label.Label_CMP;
        config.cscfga__Description__c = 'Test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.Type__c = 'New';
        update config;   
        
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
        inputMap.put('GetBasket', basket.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = FundBalanceAmountHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetBasket'));        
    }

    /**********************************************************************************************
    * Method Name : testRunWithBasket
    * Description : Used to simulate and test the Onefund amount.
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    @isTest 
    static void testRunWithBasket() {
        cscfga__Product_Basket__c basketId = [SELECT id, Name FROM cscfga__Product_Basket__c LIMIT 1];
                  
        Test.startTest();
            
        Double fundBalance = FundBalanceAmountHelper.getCurrentFundBalanceAmt(basketId.Name);
        Test.stopTest();   
        System.assertNotEquals(null, fundBalance);
        
    }   
     
}