/*
===============================================================================================================================
Test Class : CS_HandSTypeFromPriceItemTest
Class : CS_HandSTypeFromPriceItem
===============================================================================================================================
===========================================================================================================================
*/

@isTest
public class CS_HandSTypeFromPriceItemTest {
    @testsetup static void CS_HandSTypeFromPriceItemTestDataSetup() {
        Profile pf = [select Id, Name from profile where name = 'Sales Manager - Enterprise'];
        //CREATE USER
        User usr = new User(Alias = 'standt', Email = 'standarduser@telestra.com',
                            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', ProfileId = pf.Id,
                            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@telestra.com');

        insert usr;
        System.runAs(usr) {
            cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
            Date today = Date.valueOf(System.now());
            piSeat.Name = 'Price Item';
            piSeat.Contract_Type__c = 'Test Contract';
            piSeat.Package_Name__c = 'Connected Workplace';
            piSeat.Type__c = 'Accessory';
            piseat.cspmb__Recurring_Charge__c = 300;
            piseat.cspmb__One_Off_Charge__c = 300;
            piseat.Vendor__c = 'Cisco';
            piSeat.cspmb__Effective_Start_Date__c = today.addDays(-1);
            piSeat.cspmb__Effective_End_Date__c = today.addDays(2);
            piSeat.External_Id__c = '2359abc9-8088-4e56-a5c0-19de77555589';
            piSeat.cspmb__Product_Definition_Name__c = 'Handset and Accessories';
            insert piSeat;
        }
    }
    static testmethod void testDoLookupSearchForSalesManagerEnterprise() {
        User usr = [select Id, UserName from User where UserName = 'standarduser@telestra.com'];
        System.runAs(usr) {
            Test.startTest();
            CS_HandSTypeFromPriceItem handPriItem = new CS_HandSTypeFromPriceItem();
            Map<String, String> searchFields = new Map<String, String>();
            //Offer
            cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
            offer.name = 'test offer';
            offer.Offer_Spec_Id__c = '1234';
            insert offer;
            cscfga__Product_Configuration__c conf = new cscfga__Product_Configuration__c();
            conf.Name = 'Fixed Seat Test';
            conf.cscfga__Configuration_Status__c = 'Active';
            conf.cscfga__originating_offer__c = offer.id;
            insert conf;
            searchFields.put('Prod_Cnf_Id', conf.Id);
            String prodConfId = handPriItem.getRequiredAttributes();
            List<cspmb__Price_Item__c> lstPrItem = (List<cspmb__Price_Item__c>)handPriItem.doLookupSearch(searchFields, null, null, null, null);
            system.assertNotEquals(lstPrItem, null);
            Test.stopTest();
        }
    }

}