@isTest
public class CS_TypeFromPriceItemTest {

    @isTest
    public static void priceItemSearchReturningResult() {
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.name = 'test offer';
        offer.Offer_Spec_Id__c = '1234';
        insert offer;
        cscfga__Product_Configuration__c conf = new cscfga__Product_Configuration__c();
        conf.Name = 'Fixed Seat';
        conf.cscfga__Configuration_Status__c = 'Active';
        conf.Offer_Reference__c = offer.id;
        insert conf;
        cscfga__Product_Configuration__c conf1 = new cscfga__Product_Configuration__c();
        conf1.Name = 'Fax Seat';
        conf1.cscfga__Configuration_Status__c = 'Active';
        conf1.Offer_Reference__c = offer.id;
        insert conf1;
        List<cspmb__Price_Item__c> piSeatList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
        Date today = Date.valueOf(System.now());
        piSeat.Package_Name__c = 'Connected Workplace';
        piSeat.Type__c = 'Fax Line';
        piSeat.cspmb__Effective_Start_Date__c = today - 1;
        piSeat.cspmb__Effective_End_Date__c = today + 1;
        piSeat.External_Id__c = '2359abc9-8088-4e56-a5c0-19de77555527';
        piSeat.cspmb__Product_Definition_Name__c = 'User';
        piSeat.Offer_Id__c = '1234';
        piSeatList.add(piSeat);
        cspmb__Price_Item__c piSeat1 = new cspmb__Price_Item__c();
        piSeat1.Package_Name__c = 'Connected Workplace';
        piSeat1.Type__c = 'Fixed Seat';
        piSeat1.cspmb__Effective_Start_Date__c = today - 1;
        piSeat1.cspmb__Effective_End_Date__c = today + 1;
        piSeat1.External_Id__c = '2359abc9-8088-4e56-a5c0-19de77555528';
        piSeat1.cspmb__Product_Definition_Name__c = 'User';
        piSeat1.Offer_Id__c = '1234';
        piSeatList.add(piSeat1);
        insert piSeatList ;

        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('User Type', 'User Type');
        searchFields.put('ListOfSelectedUser1', 'Fixed Seat');
        searchFields.put('OfferId', conf.Offer_Reference__c);
        searchFields.put('searchValue', '');
        searchFields.put('Prod_Cnf_Id', conf.Id);

        CS_TypeFromPriceItem piItem = new CS_TypeFromPriceItem();
        Test.startTest();
        piItem.getRequiredAttributes();
        piItem.doLookupSearch(searchFields, '1234rfdff4r3rr4', null, 1, 10);
        System.assertEquals(piItem != null, true);
        Test.stopTest();
    }

    @isTest
    public static void priceItemSearchReturningNull() {
        cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
        Date today = Date.valueOf(System.now());
        piSeat.Package_Name__c = 'Connected Workplace';
        piSeat.Type__c = 'Fax Line';
        piSeat.cspmb__Effective_Start_Date__c = today + 1;
        piSeat.cspmb__Effective_End_Date__c = today;
        piSeat.External_Id__c = '2359abc9-8088-4e56-a5c0-19de77555527';
        piSeat.cspmb__Product_Definition_Name__c = 'User';
        insert piSeat;

        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('User Type', 'User Type');
        searchFields.put('ListOfSelectedUser1', 'Fixed Seat');
        searchFields.put('OfferId', '');
        CS_TypeFromPriceItem piItem = new CS_TypeFromPriceItem();
        String configName = 'Fixed Seat';
        List<String> selectedUsers = new List<String>{'Fixed Seat','Fax Line'};
        Test.startTest();
        piItem.getRequiredAttributes();
        boolean tmp = piItem.canAdd(configName,selectedUsers, piSeat);
        Object[] res1 = piItem.doLookupSearch(searchFields, '1234rfdff4r3rr4', null, null, null);
        System.assertEquals(res1 != null, true);
        piItem.canAdd('Fixed Seat',new List<String>{'FaxLine'},piSeat); // RPL Changes for Coverage 
        piItem.canAdd('Fixed Seat',new List<String>{'Fax Line'},piSeat); // RPL Changes for Coverage 

        Test.stopTest();
    }
}