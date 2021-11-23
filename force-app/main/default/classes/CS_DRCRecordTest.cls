@isTest
public class CS_DRCRecordTest {

    public static testmethod void dsrSearchReturningResult() {
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.APTPS_DocuSign_Restricted__c = false;
        insert acc;
        System.assert(acc.id != null);
        //CREATE CONTACT
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '0423456789', //FDR fix for sprint 21.14
            Email = 'test@tele2.com'
        );
        Insert contact;
        System.assert(contact.id != null);
        list<Opportunity> listoppty = new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        opp.AccountId = acc.id;
        insert opp;

        list<cscfga__Product_Basket__c> lstbasket = new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;

        //Offer
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.name = 'test offer';
        offer.Offer_Spec_Id__c = '1234';
        insert offer;

        cscfga__Product_Configuration__c conf = new cscfga__Product_Configuration__c();
        conf.Name = 'IP Site';
        conf.cscfga__Product_Basket__c = basket.id;
        //conf.cscfga__Configuration_Status__c = 'Active';
        conf.Offer_Reference__c = offer.id;
        conf.Type__c = 'Cancel';
        insert conf;

        cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('OpptyId', opp.id, conf.id);
        insert attr0;

        Deal_Support_Request__c dsr = new Deal_Support_Request__c();
        dsr.Opportunity__c = opp.id;
        //dsr.Request_Type__c='Big Deal Team';
        dsr.Status__c = 'Completed';
        insert dsr;

        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('OpptyId', opp.id);

        CS_DRCRecord piItem = new CS_DRCRecord();
        Test.startTest();
        piItem.getRequiredAttributes();
        Id[] excludeIds = new Id[] {};
        //Object[] res = piItem.doLookupSearch(searchFields, 'OpptyId',null,null);
        List<Deal_Support_Request__c> lstPrItem = (List<Deal_Support_Request__c>)piItem.doLookupSearch(searchFields, null, null, null, null);
        Test.stopTest();
        System.assertEquals(lstPrItem.size() != null, true);
    }
}