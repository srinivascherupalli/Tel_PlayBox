/* 
Name        Date           Description
Divya       12/15/2020      EDGE-173035 validation to avoid mix basket
*/
public with sharing class SCProductCatalogueFilterUtility {

    /*-------------------------------------------------------- 
EDGE-173035
Description: Method to  validate in order to avoid mix basket
Author:Lavish
--------------------------------------------------------*/
    public static list<Marketable_Offer__c> getMarketableOffer(String basketId){
        
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        String contractType ; 
        
        //fetching product configuration records based on the product basket id
        prodConfigList = [SELECT id,Name,csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Basket__r.Name,Type__c,
                        cscfga__Product_Basket__r.csbb__Account__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,
                        Marketable_Offer__r.Offer_ID__c,Marketable_Offer__r.Name, cscfga__Product_Basket__c,Marketable_Offer__r.OfferDefinationName__c,Marketable_Offer__r.Contract_Type__c,
                        cscfga__Product_Basket__r.cscfga__Opportunity__r.Opportunity_Record_Type__c,OfferName__c
                        from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=: basketId LIMIT 1];       
                        
        System.debug('prodConfigList'+prodConfigList);        
        //fetching the contract type
        for(cscfga__Product_Configuration__c pc :prodConfigList){
              contractType =  pc.Marketable_Offer__r.Contract_Type__c; 
            }
        
       List<Marketable_Offer__c>  marOfferList= new List<Marketable_Offer__c>();
        System.debug('contractType'+contractType);
        if(contractType != null && contractType != ''){
        //fetching records from marketable offer based on contract type
        marOfferList = [SELECT Name,Contract_Type__c,Solution_Template__c,Offer_ID__c FROM Marketable_Offer__c WHERE Contract_Type__c !=: contractType ];
        
        system.debug('marOfferList'+marOfferList);
        
        }
        return marOfferList;

    }
}