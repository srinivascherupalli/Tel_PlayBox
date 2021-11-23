/******************************************************************************************************
*Class Name     : CreateMACDBskSolObserver
*Test Class     : CreateMACDBskSolObserverTest

Ch.No.    Developer Name          Date          Story Description
_________________________________________________________________
1.       Rajiv Singh            23.09.2021      DIGI-11609 - Create a Listener for Solution Processing Async CS APIs, and Respond to MS with Record Ids
******************************************************************************************************/

global with sharing class CreateMACDBskSolObserver implements csordcb.ObserverApi.IObserver {
    global CreateMACDBskSolObserver() {
	system.debug('this class is calling');
    }

   global void execute(csordcb.ObserverApi.Observable obj_observable, Object arg) {
   /*     system.debug('This method is calling');
        csordtelcoa.ChangeRequestObservable  obj_crobs = (csordtelcoa.ChangeRequestObservable ) obj_observable;
        List<Id> productConfigIdList = obj_crobs.getProductConfigurationIds();
        system.debug('productconfig'+productConfigIdList);
        List<cscfga__Product_Configuration__c> prodConfigList = [SELECT Id,cscfga__product_basket__c,csordtelcoa__Solution__c,cscfga__product_basket__r.correlation_id__c FROM cscfga__Product_Configuration__c WHERE cscfga__product_basket__r.channelFrom__c = 'TED-81 onlineAPI' AND Id IN :productConfigIdList];
        if(prodConfigList.size() > 0){
            String correlationId = prodConfigList[0].cscfga__product_basket__r.correlation_id__c;
            system.debug('This if condition is calling');
            String basketId = prodConfigList[0].cscfga__product_basket__c;
            String solutionId = [select id from csord__Solution__c where cssdm__product_basket__c =: prodConfigList[0].cscfga__product_basket__c][0].Id;
           String mainConfigId = cssmgnt.API_1.postSelectiveMACDProcessing(prodConfigList[0].cscfga__product_basket__c,solutionId);
          orderDMLController.Pl_Event_records_CRU(mainConfigId,solutionId,basketId,correlationId,true);
        }else{
          orderDMLController.Pl_Event_records_CRU('','','','',false);
        }
        */
    }

}