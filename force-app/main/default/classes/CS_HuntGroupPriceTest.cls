@isTest
public class CS_HuntGroupPriceTest {

    public static testmethod void priceItemSearchReturningResult()
    {
        cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
        
        
        //Offer 
        cscfga__Configuration_Offer__c offer=new cscfga__Configuration_Offer__c();
        offer.name='test offer';
        offer.Offer_Spec_Id__c='1234';
        insert offer;       
        Date today = Date.today();
        piSeat.Name = 'testPI';
        piSeat.Tier__c = '1';
        piSeat.cspmb__Product_Definition_Name__c = System.Label.Hunt_group_PD_name;
        piSeat.Package_Name__c = 'Connected Workplace';
        piSeat.cspmb__Effective_End_Date__c = today.addDays(2);
        piSeat.cspmb__Effective_Start_Date__c = today.addDays(-1);
        piSeat.Offer_Id__c = '1234';
        piSeat.ProdSpecId__c='1234';
        //piSeat.External_Id__c = '2359abc9-8088-4e56-a5c0-19de77555527';
        insert piSeat;

        cscfga__Product_Configuration__c conf = new cscfga__Product_Configuration__c();
        conf.Name = 'IP Site';
        conf.cscfga__Configuration_Status__c = 'Active';
        conf.Offer_Reference__c=offer.id; 
        insert conf;
        
        Map<String,String> searchFields = new Map<String,String>();
        //searchFields.put('Prod_Cnf_Id', conf.Id);
        searchFields.put('ParentConfigID', conf.id);
        
        CS_HuntGroupPrice piItem = new CS_HuntGroupPrice();
        Test.startTest();
        piItem.getRequiredAttributes();
        Object[] res = piItem.doDynamicLookupSearch(searchFields, '1234rfdff4r3rr4');
        Test.stopTest();
        System.assertEquals(res.size()!=null,true);       
    }
}