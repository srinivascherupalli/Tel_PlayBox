@isTest
public class CS_ContactfromCustmrAcctBasketTest {
    @testsetup static void CS_ContactfromCustmrAcctBasketTestDataSetup()
    {
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact con = AccountTestFactory.buildContact(acc,'TestContact');
        insert con;
        AccountContactRelation acr = [Select id , Roles from AccountContactRelation where ContactId =: con.id limit 1];
        acr.Roles = 'Full Authority';
        update acr;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
    }
    static testmethod void doLookupSearchTest()
    {
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        Map<String, String> searchFields= new Map<String, String>();
        searchFields.put('basketId',basket.Id);
        searchFields.put('searchValue','');
        searchFields.put('CommercialPDName','BroadsoftTenancy');
        CS_ContactfromCustmrAcctBasket conFromAccBas = new CS_ContactfromCustmrAcctBasket();
        string str = conFromAccBas.getRequiredAttributes();
        List<Contact> lstCon = (List<Contact>)conFromAccBas.doLookupSearch(searchFields, null, null, null, null);
        system.assert(lstCon.size()!=null);
    }
}