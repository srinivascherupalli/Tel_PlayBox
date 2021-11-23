/*****************************************************************
@Name: CS_SitefromAcctBasketTest
@Author: Purushottam Sahu
@CreateDate: 12/02/2019 
@Description: This is the Test class for CS_SitefromAcctBasket
*************************************** CHANGE LOG ***************************************
   SL NO.   DeveloperName   Date            Description
   1.       Pooja Bhat      12-OCT-2021     DIGI-11869: Added new method doLookupSearchTest3()
******************************************************************/ 
@isTest
public class CS_SitefromAcctBasketTest {
    @testsetup static void CS_ContactfromAcctBasketTestDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('Test Name');
        insert acc;
        cscrm__Address__c address = AccountTestFactory.buildAddress('AddressID-1');
        insert address;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        cscrm__Site__c site = AccountTestFactory.buildSite(address.id, acc.id);
        insert site;
        
    }
    static testmethod void doLookupSearchTest()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        Map<String, String> searchFields= new Map<String, String>();
        searchFields.put('basketId',basket.Id);
        searchFields.put('searchValue','');
        CS_SitefromAcctBasket conFromAccBas = new CS_SitefromAcctBasket();
        string str = conFromAccBas.getRequiredAttributes();
        List<cscrm__Site__c> lstCon = (List<cscrm__Site__c>)conFromAccBas.doLookupSearch(searchFields, null, null, null, null);
        system.assert(lstCon.size()!=null);
    }
    static testmethod void doLookupSearchTest2()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        Map<String, String> searchFields= new Map<String, String>();
        searchFields.put('basketId',basket.Id);
        CS_SitefromAcctBasket conFromAccBas = new CS_SitefromAcctBasket();
        string str = conFromAccBas.getRequiredAttributes();
        List<cscrm__Site__c> lstCon = (List<cscrm__Site__c>)conFromAccBas.doLookupSearch(searchFields, null, null, null, null);
        system.assert(lstCon.size()!=null);
    }
    static testmethod void doLookupSearchNegativeTest2()
    {   
        Account acc = AccountTestFactory.buildAccount('Test Name23');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        Map<String, String> searchFields= new Map<String, String>();
        searchFields.put('basketId',basket.id);
        CS_SitefromAcctBasket conFromAccBas = new CS_SitefromAcctBasket();
        string str = conFromAccBas.getRequiredAttributes();
        List<cscrm__Site__c> lstCon = (List<cscrm__Site__c>)conFromAccBas.doLookupSearch(searchFields, null, null, null, null);
        system.assert(lstCon==null);
    }
    //Start:DIGI-11869
    static testmethod void doLookupSearchTest3()
    {
        cscfga__Product_Basket__c basket = [select id, csbb__Account__c from cscfga__Product_Basket__c];
        system.debug('CS_SitefromAcctBasketTest basket details***' + basket);
        Map<String, String> searchFields= new Map<String, String>();
        searchFields.put('basketId',basket.Id);
        searchFields.put('OfferId','DMCAT_Offer_001477');
        CS_SitefromAcctBasket conFromAccBas = new CS_SitefromAcctBasket();
        string str = conFromAccBas.getRequiredAttributes();
        system.debug('CS_SitefromAcctBasketTest str***' + str);
        system.debug('CS_SitefromAcctBasketTest searchFields***' + searchFields);
        List<cscrm__Site__c> lstCon = (List<cscrm__Site__c>)conFromAccBas.doLookupSearch(searchFields, null, null, null, null);
        system.debug('CS_SitefromAcctBasketTest lstCon***' + lstCon);
        system.assert(lstCon.size()!=null);
    }
    //End:DIGI-11869
}