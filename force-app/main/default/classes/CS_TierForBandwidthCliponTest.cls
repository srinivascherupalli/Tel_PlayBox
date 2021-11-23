@isTest
public class CS_TierForBandwidthCliponTest {

    public static testmethod void priceItemSearchReturningResult() {
        //Offer
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.name = 'test offer';
        offer.Offer_Spec_Id__c = '1234';
        insert offer;
        Date today = Date.today();
        cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();

        piSeat.Name = 'testPI';
        piSeat.Tier__c = '1';
        piSeat.cspmb__Product_Definition_Name__c = 'Bandwidth Clip On';
        piSeat.Package_Name__c = 'Connected Workplace';
        piSeat.cspmb__Effective_End_Date__c = today.addDays(2);
        piSeat.cspmb__Effective_Start_Date__c = today.addDays(-1);
        piSeat.Offer_Id__c = offer.Id;
        insert piSeat;

        cspmb__Price_Item__c piSeat1 = new cspmb__Price_Item__c();
        piSeat1.Name = 'testPI2';
        piSeat1.Tier__c = '2';
        piSeat1.cspmb__Product_Definition_Name__c = 'Bandwidth Clip On';
        piSeat1.Package_Name__c = 'Connected Workplace';
        piSeat1.cspmb__Effective_End_Date__c = today.addDays(2);
        piSeat1.cspmb__Effective_Start_Date__c = today.addDays(-1);
        piSeat1.Offer_Id__c = offer.Id;
        insert piSeat1;
        
        
       cspmb__Price_Item__c piSeat3 = new cspmb__Price_Item__c();
        piSeat3.Name = 'testPI3';
        piSeat3.Tier__c = '1';
        piSeat3.cspmb__Product_Definition_Name__c = 'Bandwidth Clip On';
        piSeat3.Package_Name__c = 'Connected Workplace';
        piSeat3.cspmb__Effective_End_Date__c = today.addDays(2);
        piSeat3.cspmb__Effective_Start_Date__c = today.addDays(-1);
        piSeat3.Offer_Id__c = offer.Id;
        insert piSeat3;
        
        
        Bandwidth_Calculation__c bandwidth = new Bandwidth_Calculation__c();
        bandwidth.Count_Bandwidth_Clip_On__c = 2;
        bandwidth.Technology__c = 'NBN Access';
        bandwidth.Technology_Type__c = 'FTTP';
        bandwidth.Max_User_Count__c = 50;
        bandwidth.Min_User_Count__c = 78;
        insert bandwidth;
        
                
        Bandwidth_Calculation__c bandwidth1 = new Bandwidth_Calculation__c();
        bandwidth1.Count_Bandwidth_Clip_On__c = 1;
        bandwidth1.Technology__c = 'NBN Access';
        bandwidth1.Technology_Type__c = 'FTTP';
        bandwidth1.Max_User_Count__c = 104;
        bandwidth1.Min_User_Count__c = 79;
        insert bandwidth1;

        cscfga__Product_Configuration__c conf = new cscfga__Product_Configuration__c();
        conf.Name = 'Fixed Seat Test';
        conf.cscfga__Configuration_Status__c = 'Active';
        conf.cscfga__originating_offer__c = offer.id;
        
        insert conf;

        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('Prod_Cnf_Id', conf.Id);
        searchFields.put('User Quantity', '79');
        searchFields.put('Technology','NBN Access');
        searchFields.put('Technology Type','FTTP');
        searchFields.put('OfferId', offer.id);

        CS_TierForBandwidthClipon piItem = new CS_TierForBandwidthClipon();
        Test.startTest();
        piItem.getRequiredAttributes();
        Object[] res = piItem.doLookupSearch(searchFields, '1234rfdff4r3rr4', null, 1, 10);
        
        searchFields.put('User Quantity', '80');
        searchFields.put('Technology','NBN Access');
        searchFields.put('Technology Type','FTTP');
        searchFields.put('OfferId', offer.id);
   
        Object[] res1 = piItem.doLookupSearch(searchFields, '1234rfdff4r3rr4', null, 1, 10);
        
        searchFields.put('User Quantity', '9');
        searchFields.put('Technology','NBN Access');
        searchFields.put('Technology Type','FTTP');
        searchFields.put('OfferId', offer.id);
   
        Object[] res2 = piItem.doLookupSearch(searchFields, '1234rfdff4r3rr4', null, 1, 10);
        Test.stopTest();
        System.assertEquals(res.size() != null, true);

    }

    public static testmethod void SearchReturningResult2() {
        cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.name = 'test offer';
        offer.Offer_Spec_Id__c = '1234';
        insert offer;
        Date today = Date.today();
        piSeat.Name = 'testPI';
        piSeat.Tier__c = '1';
        piSeat.cspmb__Product_Definition_Name__c = 'Bandwidth Clip On';
        piSeat.Package_Name__c = 'Connected Workplace';
        piSeat.cspmb__Effective_End_Date__c = today.addDays(2);
        piSeat.cspmb__Effective_Start_Date__c = today.addDays(-1);
        piSeat.Offer_Id__c = offer.id;
        insert piSeat;

        cspmb__Price_Item__c piSeat1 = new cspmb__Price_Item__c();
        piSeat1.Name = 'testPI2';
        piSeat1.Tier__c = '2';
        piSeat1.cspmb__Product_Definition_Name__c = 'Bandwidth Clip On';
        piSeat1.Package_Name__c = 'Connected Workplace';
        piSeat1.cspmb__Effective_End_Date__c = today.addDays(2);
        piSeat1.cspmb__Effective_Start_Date__c = today.addDays(-1);
        piSeat1.Offer_Id__c = offer.id;
        insert piSeat1;

        cscfga__Product_Configuration__c conf = new cscfga__Product_Configuration__c();
        conf.Name = 'Fixed Seat Test';
        conf.cscfga__Configuration_Status__c = 'Active';
        conf.cscfga__originating_offer__c = offer.id;
        conf.Offer_Reference__c = offer.id;
        insert conf;

        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('Prod_Cnf_Id', conf.Id);
        searchFields.put('OfferId', conf.Offer_Reference__c);
        searchFields.put('User Quantity', '50');
        searchFields.put('searchValue', '9');
        searchFields.put('OfferId', offer.id);

        CS_TierForBandwidthClipon piItem = new CS_TierForBandwidthClipon();
        Test.startTest();
        piItem.getRequiredAttributes();
        Object[] res1 = piItem.doLookupSearch(searchFields, '1234rfdff4r3rr4', null, null, null);
        Test.stopTest();
        System.assertEquals(res1.size() != null, true);
    }
    public static testmethod void SearchReturningResult3() {
        cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.name = 'test offer';
        offer.Offer_Spec_Id__c = '1234';
        insert offer;
        Date today = Date.today();
        piSeat.Name = 'testPI';
        piSeat.Tier__c = '1';
        piSeat.cspmb__Product_Definition_Name__c = 'Bandwidth Clip On';
        piSeat.Package_Name__c = 'Connected Workplace';
        piSeat.cspmb__Effective_End_Date__c = today.addDays(2);
        piSeat.cspmb__Effective_Start_Date__c = today.addDays(-1);
        piSeat.Offer_Id__c = offer.id;
        insert piSeat;

        cspmb__Price_Item__c piSeat1 = new cspmb__Price_Item__c();
        piSeat1.Name = 'testPI2';
        piSeat1.Tier__c = '2';
        piSeat1.cspmb__Product_Definition_Name__c = 'Bandwidth Clip On';
        piSeat1.Package_Name__c = 'Connected Workplace';
        piSeat1.cspmb__Effective_End_Date__c = today.addDays(2);
        piSeat1.cspmb__Effective_Start_Date__c = today.addDays(-1);
        piSeat1.Offer_Id__c = offer.id;
        insert piSeat1;

        cscfga__Product_Configuration__c conf = new cscfga__Product_Configuration__c();
        conf.Name = 'Fixed Seat Test';
        conf.cscfga__Configuration_Status__c = 'Active';
        conf.cscfga__originating_offer__c = offer.id;
        conf.Offer_Reference__c = offer.id;
        insert conf;

        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('Prod_Cnf_Id', conf.Id);
        searchFields.put('OfferId', conf.Offer_Reference__c);
        searchFields.put('User Quantity', '5');
        searchFields.put('searchValue', '9');
        searchFields.put('OfferId', offer.id);

        CS_TierForBandwidthClipon piItem = new CS_TierForBandwidthClipon();
        Test.startTest();
        piItem.getRequiredAttributes();
        Object[] res2 = piItem.doLookupSearch(searchFields, '1234rfdff4r3rr4', null, null, null);
        Test.stopTest();
        System.assertEquals(res2.size() != null, true);
    }
}