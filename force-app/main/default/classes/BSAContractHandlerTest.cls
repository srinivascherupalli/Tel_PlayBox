/************************************************************ 
 * @version      - 0.1
 * @createdBy    - Pradeep Bhumi
 * @team         - OSAKA
 * @jirastoryRef - EDGE-136960
 * @Description  - This class will make Express Order field Conditionally editable based on BSA Contract Flag  
 ******************************************************************/

@IsTest
public class BSAContractHandlerTest {

    @testSetup
    static void setupTestData() {

        Account acc = AccountTestFactory.buildAccount('TestAcc');
        insert acc;

        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        opp.AccountId = acc.id;
        insert opp;

        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.BSA_Generated__c = false;
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;

        ContractJunction__c contractJunction = new ContractJunction__c();
        contractJunction.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contractJunction.Related_Basket__c = basket.id;
        contractJunction.CongaStatus__c = 'NotStarted';
        contractJunction.Status__c = 'Initiated';
        contractJunction.Account__c = basket.csbb__Account__c;
        contractJunction.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        contractJunction.Contract_Activated_Date__c = System.today();
        contractJunction.Contract_Term_Months__c = 36;
        contractJunction.BSA_Generated__c = true;
        contractJunction.GPTVersion__c = 1.2;
        contractJunction.OFTVersion__c = 1.4;
        contractJunction.BSAVersion__c = 1.3;
        contractJunction.Account__c = acc.id;
        insert contractJunction;
    }

    @isTest
    static void updateBSACheckFlagPostive() {

        setupTestData();
        Test.startTest();
        cscfga__Product_Basket__c prodBask = [SELECT id, BSA_Generated__c from cscfga__Product_Basket__c LIMIT 1];
        List < id > productBasket = new List < id > ();
        productBasket.add(prodBask.id);
        BSAContractHandler.updateBSACheckFlag(productBasket);
        Test.stopTest();
        system.assertEquals(prodBask.BSA_Generated__c, false);

    }


    @isTest
    static void updateBSACheckFlagNegative() {

        Test.startTest();
        cscfga__Product_Basket__c prodBask = [SELECT id, BSA_Generated__c from cscfga__Product_Basket__c LIMIT 1];
        List < id > productBasket = new List < id > ();
        productBasket.add(prodBask.id);
        BSAContractHandler.updateBSACheckFlag(productBasket);
        Test.stopTest();
        system.assertEquals(prodBask.BSA_Generated__c, false);

    }

}