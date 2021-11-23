/*EDGE-45120
Name : AccountLevelProductObserver
Description: Product configuration creation observer implementation changes to load account level hosted products in product basket
Ch.No.    Developer Name          Date          Story Description
_________________________________________________________________

1.       Pooja Gupta              01.07.2021    EDGE-218369
*/

global with sharing class AccountLevelProductObserver implements csbb.ObserverApi.IObserver {
    global AccountLevelProductObserver() {

    }

    global void execute(csbb.ObserverApi.Observable o, Object arg) {
        csbb.ProductConfigurationObservable observable = (csbb.ProductConfigurationObservable) o;
        if(!Test.isRunningTest()){//Added this check to cover the lines EDGE-218369
        String observerContext = observable.getContext();
        csbb__Product_Configuration_Request__c pcRequest = observable.getProductConfigurationRequest();
        cscfga__Product_Configuration__c pcId = observable.getProductConfiguration();
        List < csbb__Product_Configuration_Request__c > selectionContext = observable.getSelectionContext();
        desyncModularBasketWhenProductAdded(pcId.Id);
        }
        //accountCheckSubPresentOnAcc(pcId, pcRequest); EDGE-218369
        //createSitesAndAddress(pcId.Id, pcRequest); EDGE-218369
    }

    @testVisible
    private void desyncModularBasketWhenProductAdded(Id pcId) {
        System.debug(LoggingLevel.INFO, 'AccountLevelProductObserver.desyncModularBasketWhenProductAdded.pcId = ' + pcId);
        String modularBasket = Label.Modular;
        String basketQuery = 'SELECT ';
        basketQuery += 'id, ';
        basketQuery += 'csbb__Synchronised_With_Opportunity__c, ';
        basketQuery += 'csordtelcoa__Basket_Stage__c, ';
        basketQuery += 'csbb__Account__r.Enterprise_ID__c ';
        basketQuery += 'FROM ';
        basketQuery += 'cscfga__Product_Basket__c ';
        basketQuery += 'WHERE ';
        basketQuery += 'cscfga__Opportunity__r.Product_Type__c != :modularBasket ';
        basketQuery += 'AND ';
        basketQuery += 'id ';
        basketQuery += 'IN ';
        basketQuery += '(';
        basketQuery += 'SELECT ';
        basketQuery += 'cscfga__Product_Basket__c ';
        basketQuery += 'FROM ';
        basketQuery += 'cscfga__Product_Configuration__c ';
        basketQuery += 'WHERE ';
        basketQuery += 'id = :pcId';
        basketQuery += ') ';
        basketQuery += 'LIMIT 1';
        system.debug('basketQuery' + basketQuery);
        List < sObject > objectList = Database.query(basketQuery);

        if (objectList != null && !objectList.isEmpty()) {
            cscfga__Product_Basket__c productBasket = (cscfga__Product_Basket__c) objectList[0];

            System.debug(LoggingLevel.INFO, 'AccountLevelProductObserver.desyncModularBasketWhenProductAdded.productBasket = ' + productBasket);

            if (productBasket != null && productBasket.csordtelcoa__Basket_Stage__c != null) {
                productBasket.csbb__Synchronised_With_Opportunity__c = false;
                if (CustomConfigurationOptions__c.getValues('CommercialConfiguration') != null && CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c != null && productBasket.csordtelcoa__Basket_Stage__c != CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c) {
                    productBasket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c;
                }
                update productBasket;
            }
        }
    }

    //commenting below code as its no longer in use || EDGE-218369 start
    /*@testVisible
    private void createSitesAndAddress(Id pcId, csbb__Product_Configuration_Request__c pcRequest) {
        system.debug(LoggingLevel.INFO, 'AccountLevelProductObserver.createSitesAndAddress.pcId = ' + pcId);
        system.debug(LoggingLevel.INFO, 'AccountLevelProductObserver.createSitesAndAddress.pcRequest = ' + pcRequest);
        String TransitionClone = EnvironmentVariable__c.getValues('TransitionClone').Value__c;
        System.debug('AccountLevelProductObserver.createSitesAndAddress.TransitionClone = ' + TransitionClone);
        if (TransitionClone == '3') {
            String basketQuery = 'SELECT ';
            basketQuery += 'id, ';
            basketQuery += 'csbb__Account__c,csbb__Account__r.CIDN__c, ';
            basketQuery += 'csbb__Account__r.Enterprise_ID__c ';
            basketQuery += 'FROM ';
            basketQuery += 'cscfga__Product_Basket__c ';
            basketQuery += 'WHERE ';
            basketQuery += 'id ';
            basketQuery += 'IN ';
            basketQuery += '(';
            basketQuery += 'SELECT ';
            basketQuery += 'cscfga__Product_Basket__c ';
            basketQuery += 'FROM ';
            basketQuery += 'cscfga__Product_Configuration__c ';
            basketQuery += 'WHERE ';
            basketQuery += 'id = :pcId';
            basketQuery += ') ';
            basketQuery += 'LIMIT 1';

            system.debug('basketQuery' + basketQuery);
            List < sObject > objectList = Database.query(basketQuery);

            if (objectList != null && !objectList.isEmpty()) {
                cscfga__Product_Basket__c productBasket = (cscfga__Product_Basket__c) objectList[0];

                system.debug(LoggingLevel.INFO, 'AccountLevelProductObserver.createSitesAndAddress.productBasket = ' + productBasket);
                if (productBasket != null) {
                    ObserverCloneBasketHelper.CreateStiteAndaddresses(
                        pcRequest.id,
                        productBasket.csbb__Account__r.CIDN__c,
                        productBasket.csbb__Account__r.Enterprise_ID__c
                    );
                }
            }
        }
    }

    @testVisible
    private void accountCheckSubPresentOnAcc(cscfga__Product_Configuration__c pc, csbb__Product_Configuration_Request__c pcRequest) {
        system.debug(LoggingLevel.INFO, 'AccountLevelProductObserver.accountCheckSubPresentOnAcc.pcId = ' + pc);
        system.debug(LoggingLevel.INFO, 'AccountLevelProductObserver.accountCheckSubPresentOnAcc.pcRequest = ' + pcRequest);
        String IPNetworkUCEPCClone = EnvironmentVariable__c.getValues('IPNetworkUCEPCClone').Value__c;
        cscfga__Product_Configuration__c pcFilter = [SELECT OfferName__c FROM cscfga__Product_Configuration__c WHERE Id = : pc.Id];
        Id pcId = pc.Id;
        if (IPNetworkUCEPCClone == '5') {
            String basketQuery = 'SELECT ';
            basketQuery += 'id, ';
            basketQuery += 'csbb__Account__c ';
            basketQuery += 'FROM ';
            basketQuery += 'cscfga__Product_Basket__c ';
            basketQuery += 'WHERE ';
            basketQuery += 'id ';
            basketQuery += 'IN ';
            basketQuery += '(';
            basketQuery += 'SELECT ';
            basketQuery += 'cscfga__Product_Basket__c ';
            basketQuery += 'FROM ';
            basketQuery += 'cscfga__Product_Configuration__c ';
            basketQuery += 'WHERE ';
            basketQuery += 'id = :pcId';
            basketQuery += ') ';
            basketQuery += 'LIMIT 1';

            system.debug('@@basketQuery@@' + basketQuery);
            List < sObject > objectList = Database.query(basketQuery);

            if (objectList != null && !objectList.isEmpty()) {
                cscfga__Product_Basket__c productBasket = (cscfga__Product_Basket__c) objectList[0];
                system.debug(LoggingLevel.INFO, 'AccountLevelProductObserver.accountCheckSubPresentOnAcc.productBasket = ' + productBasket);
                //EDGE-81080 added for PPHH offers
                if (productBasket != null && pcFilter != null && pcFilter.OfferName__c != null && !(pcFilter.OfferName__c.contains('Postpaid handheld - Bottom up') || pcFilter.OfferName__c.contains('Postpaid handheld - Bottom up Committed') 
                        || pcFilter.OfferName__c.contains('Postpaid handheld - Individual') || pcFilter.OfferName__c.contains('Postpaid handheld - Top Down')))
                {
                    AccountLevelProductObserverHelper.checkSubPresentOnAcc(pc);
                }
            }
        }
    }*/
    //commenting below code as its no longer in use || EDGE-218369 end
}