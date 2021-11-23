/************************************************************************
 Name: BasketStageResetObserver
 Description: Implements the ObserverApi interface for changing basket stage to commercial config in case of clone
 ************************************************************************/
global with sharing class BasketStageResetObserver implements csbb.ObserverApi.IObserver {

    global void execute (csbb.ObserverApi.Observable o, Object arg) {
        csbb.ProductConfigurationObservable observable =(csbb.ProductConfigurationObservable) o;
        String context = observable.getContext();
        csbb__Product_Configuration_Request__c pcr =observable.getProductConfigurationRequest();
        system.debug('@@pcr@@'+pcr);
        cscfga__Product_Configuration__c pc =observable.getProductConfiguration();
        system.debug('@@PC ID@@'+pc.id);
        List<csbb__Product_Configuration_Request__c> selectionContext =observable.getSelectionContext();
        String TransitionClone = EnvironmentVariable__c.getValues('TransitionClone').Value__c;
		System.debug('*****cs '+ TransitionClone );
		if(TransitionClone=='3'){
			cscfga__Product_Basket__c ProductBasket=[select id,csbb__Account__c,csbb__Account__r.CIDN__c,csbb__Account__r.Enterprise_ID__c from cscfga__Product_Basket__c where id In (select cscfga__Product_Basket__c from cscfga__Product_Configuration__c where id=:pc.id) limit 1];
			if(ProductBasket!=null){
				system.debug('inside observer clone pc'+ProductBasket+'**'+pc.id);
				ObserverCloneBasketHelper.CreateStiteAndaddresses(pcr.id,ProductBasket.csbb__Account__r.CIDN__c,ProductBasket.csbb__Account__r.Enterprise_ID__c);
			}
		}
    }
}