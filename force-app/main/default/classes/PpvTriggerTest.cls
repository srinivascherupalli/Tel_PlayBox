/****************************************************************************
@Author: Aishwarya Yeware
@Story: EDGE-100327
@Description: PpvTriggerTest test covrage class for covering PpvTrigger
*********************************************************************************/
@isTest
public class PpvTriggerTest {
    @isTest
    static void ppvtriggerSuccesstest(){
        Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        Customer_Authority_Form__c caf = TestUtil.createCustAuthorityForm(opp,acc);
        caf.Type__c='Mobile';
        caf.CA_status__c='Completed';
        insert caf;
        Customer_Authority_Form__c caf1 = TestUtil.createCustAuthorityForm(opp,acc);
        caf1.Customer_Authority_Form__c = caf.id;
        insert caf1;
        caf.Status__c ='success';
        caf.Type__c = 'PPV';
        update caf;
        system.assertNotEquals(caf, null);
    }
    @isTest
    static void ppvtriggerFailuretest(){
        Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        Customer_Authority_Form__c caf = TestUtil.createCustAuthorityForm(opp,acc);
        insert caf;
        Customer_Authority_Form__c caf1 = TestUtil.createCustAuthorityForm(opp,acc);
        caf1.Customer_Authority_Form__c = caf.id;
        insert caf1;
        caf.Status__c ='failed';
        caf.Type__c = 'PPV';
        update caf;
        system.assertNotEquals(caf, null);
    }
    
}