/*******************************************************************
   @Author : Rajesh.P / Sayantan.H
   @Description : Lookup Custom class to fo fetch Maretable Offer under AMMS
   @Release : Sprint 21.14 - DIGI-23856
   @Test Class: AMMSMarketableOfferLookupTest

   S.No.  Date         User Story   Owner      Description
   1      12-10-2021   DIGI-23856   Sayantan.H  Created the lookup class as AMMSMarketableOfferLookup
   2.     14-10-2021   DIGI-23856	Rajesh.P    Added the conditions to return offers based on the conditions of DIGI-23856
*******************************************************************/

global with sharing class AMMSMarketableOfferLookup extends cscfga.ALookupSearch {
    public override String getRequiredAttributes()
    {
        return '["OfferId","OfferName","SolutionId","SolutionTemplate","AccountID"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {   String searchValue = '';
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            searchValue = '%' + searchFields.get('searchValue') + '%';
        }
        String offerid = (searchFields.containsKey('OfferId') && searchFields.get('OfferId') != NULL)? searchFields.get('OfferId'):'';
        String AccountID = (searchFields.containsKey('AccountID') && searchFields.get('AccountID') != NULL)? searchFields.get('AccountID'):'';
        String SolutionTemplate = (searchFields.containsKey('SolutionTemplate') && searchFields.get('SolutionTemplate') != NULL)? searchFields.get('SolutionTemplate'):'';
        set<id> setOfofferIds = new set<id>();
        for(csord__Subscription__c subcription : [select id,csord__Account__c,MarketableOffer__c from csord__Subscription__c where csord__Account__c =:AccountID and csord__Status__c = 'Active' and MarketableOffer__r.Offer_ID__c = 'DMCAT_Offer_001562']){
            setOfofferIds.add(subcription.MarketableOffer__r.Offer_ID__c);
        }
        list<Marketable_Offer__c> listOfMarketeableOfferIds = new list<Marketable_Offer__c>();
        listOfMarketeableOfferIds = [SELECT Id,Name,OfferDefinationName__c,Offer_ID__c,OwnerId,Solution_Template__c FROM Marketable_Offer__c WHERE Offer_Id__c NOT IN : setOfofferIds AND Solution_Template__c = :SolutionTemplate];
        return listOfMarketeableOfferIds;
    }
}