/*****************************************************************
@Name: CS_SubscriptionAcctBasketTest
@Author: Purushottam Sahu
@CreateDate: 1/12/2020 
@Description: This is the Test class for CS_SubscriptionAcctBasket
@Jira Story Ref :EDGE-120711
@createdBy  	:Purushottama Sahu, Orlando
******************************************************************/ 
@isTest
public class CS_SubscriptionAcctBasketTest {
    @testsetup static void CS_SubscriptionAcctBasketTestDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('Test Name');
        insert acc;
        cscrm__Address__c address = AccountTestFactory.buildAddress('AddressID-1');
        insert address;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        
       	cscfga__Product_Definition__c Product_DefinitionT= [select id,product_Specification__c from cscfga__Product_Definition__c];
        Product_DefinitionT.product_Specification__c='DMCAT_ProductSpecification_000537';
        update Product_DefinitionT;
        
        cscfga__Product_Configuration__c pc=[select id from cscfga__Product_Configuration__c];
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.csordtelcoa__Product_Configuration__c=pc.id;
        sub.csord__Status__c = System.label.Active;
        update sub;
    }
    static testmethod void doLookupSearchTest()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        Map<String, String> searchFields= new Map<String, String>();
        searchFields.put('basketId',basket.Id);
        searchFields.put('NetworkServiceOffer','DMCAT_ProductSpecification_000537');
        searchFields.put('searchValue','');
        CS_SubscriptionAcctBasket conFromAccBas = new CS_SubscriptionAcctBasket();
        string str = conFromAccBas.getRequiredAttributes();
        List<csord__Subscription__c> lstCon = (List<csord__Subscription__c>)conFromAccBas.doLookupSearch(searchFields, null, null, null, null);
        system.assert(lstCon.size()!=null);
    }
    static testmethod void doLookupSearchTest2()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        Map<String, String> searchFields= new Map<String, String>();
        searchFields.put('basketId',basket.Id);
        CS_SubscriptionAcctBasket conFromAccBas = new CS_SubscriptionAcctBasket();
        string str = conFromAccBas.getRequiredAttributes();
        List<csord__Subscription__c> lstCon = (List<csord__Subscription__c>)conFromAccBas.doLookupSearch(searchFields, null, null, null, null);
        system.assert(lstCon==null);
    }
}