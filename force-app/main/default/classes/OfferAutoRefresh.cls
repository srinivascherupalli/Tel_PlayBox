public with sharing class OfferAutoRefresh {

        public static void offerRefresh(String typeOfOffer) {
            
            OpportunityProductType productType = OpportunityProductType.getProductTypeInstance(typeOfOffer);
            List<ID> pcIds = New List<ID>();
            List<cscfga__Product_Configuration__c> configIds;

            if (null != productType)
                configIds = productType.refreshOffer(typeOfOffer); 
                
            if(null != configIds && !configIds.isEmpty()){
                System.debug('------------Updating Offers-----------------');  
                for (cscfga__Product_Configuration__c configFinalIds : configIds) {
                    pcIds.add(configFinalIds.Id);
                    configFinalIds.cscfga__Configuration_Status__c = Label.Valid;   
                }
                cfgug1.ProductConfigurationUpgrader.upgradeConfigurations(pcIds);
                update configIds;
            }
        }
    }