/*
===============================================================================================================================
Class : PCRTriggerHandler
Test Class : PCRTriggerHandlerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia 9/4/2018        EDGE-53878 + EDGE-69095(bug fix)
2.        Shubhi Vijayvergia 12/6/2018       EDGE-91796(bug)
===============================================================================================================================
*/public with sharing class PCRTriggerHandler {//added with sharing for vulnerability

    /*public static void updateRollUpFieldsOnProductBasket(List<csbb__Product_Configuration_Request__c> prodReqs, Map<Id, csbb__Product_Configuration_Request__c> oldMap) {
        Set<Id> basketIds = new Set<Id>();

        if (Trigger.isDelete) {
            prodReqs = Trigger.old;
        }
        for (csbb__Product_Configuration_Request__c newProdReq : prodReqs) {
            csbb__Product_Configuration_Request__c oldProdReq = oldMap == null ? null : oldMap.get(newProdReq.Id);

            if (Trigger.isDelete || Trigger.isUndelete || oldProdReq == null
                || (oldProdReq.csbb__Total_OC__c != newProdReq.csbb__Total_OC__c)
                || (oldProdReq.csbb__Total_MRC__c != newProdReq.csbb__Total_MRC__c)) {
                    basketIds.add(newProdReq.csbb__Product_Basket__c);
                }
        }

        if  (!basketIds.isEmpty()) {
            List<cscfga__Product_Basket__c> baskets = [ SELECT Id,
                                                       (SELECT Id, csbb__Product_Configuration__r.cscfga__total_contract_value__c
                                                        FROM csbb__Product_Configuration_Requests__r)
                                                       FROM cscfga__Product_Basket__c
                                                       WHERE Id IN :basketIds];

            for (cscfga__Product_Basket__c basket : baskets) {
                basket.cscfga__total_contract_value__c = 0;
                for (csbb__Product_Configuration_Request__c prodReq : basket.csbb__Product_Configuration_Requests__r) {
                    basket.cscfga__total_contract_value__c += prodReq.csbb__Product_Configuration__r.cscfga__total_contract_value__c == null ? 0 : prodReq.csbb__Product_Configuration__r.cscfga__total_contract_value__c;
                }
            }
            update baskets;
        }
    }*/
    /*//code added to check if SQ callout is triggered - before trigger
    public static void checkSQCallout(List <csbb__Product_Configuration_Request__c> prodConfigReqList)
    {
        SQCalloutCheckAtPCRCreation.updateSQCheck(prodConfigReqList);
    }

    //code added to check if SQ callout is triggered - after trigger
    public static void checkSQCallout2(List <csbb__Product_Configuration_Request__c> prodConfigReqList)
    {
        SQCalloutCheckAtPCRCreation.updateSQCheck2(prodConfigReqList);
    }*/ // commented for deployment

    //code added to throw error on delete of synced pcrs
    public static void deleteErrorOnSync(List <csbb__Product_Configuration_Request__c> prodConfigReqList) {
        DeleteErrorOnSyncedProducts.deleteError(prodConfigReqList);

    }
    //code added to change stage on Delete of All pcrs under a basket to Draft stage
    public static void stageChangeOnDelete(List <csbb__Product_Configuration_Request__c> prodConfigReqList) {
        Set<Id> basketIdSet = new Set<Id>();
        for (csbb__Product_Configuration_Request__c pcr : prodConfigReqList) {
            basketIdSet.add(pcr.csbb__Product_Basket__c);
        }

        //Code for changing basket stage back to Draft as soon as products are deleted

        List<cscfga__Product_Basket__c> prodBasketStageUpdateDeleteList = [
                    Select id, csordtelcoa__Basket_Stage__c, (Select id from cscfga__Product_Configurations__r)
                    from cscfga__Product_Basket__c
                    where id in :basketIdSet
                ];

        for (cscfga__Product_Basket__c basket : prodBasketStageUpdateDeleteList) {
            System.debug('****' + basket.cscfga__Product_Configurations__r.size());
            if (basket.cscfga__Product_Configurations__r.size() == 0 && CustomConfigurationOptions__c.getValues('Draft') != null && CustomConfigurationOptions__c.getValues('Draft').Enrichment_Basket_Stage__c != null) {
                basket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('Draft').Enrichment_Basket_Stage__c;
            }
        }
        update prodBasketStageUpdateDeleteList;
    }

    //code added to update basket field values when PCRs are created and not PCs
    public static void updateBasketFieldsAfterPCRCreation(List <csbb__Product_Configuration_Request__c> prodConfigReqList) {
        UpdateBasketFieldsAfterPCRCreation.updateSyncFlagAndStage(prodConfigReqList);
    }

    /* Gnana : Commented as part of Spring'20 Upgrade Activity
    public static void updateLegacyFlagOnBasket(List<csbb__Product_Configuration_Request__c> prodConfigReqList) {
        UpdateLegacyFlagOnBasketHelper.updateBasketLegacyStatusAfterPCRCreation(prodConfigReqList);
    }
	*/
 
    /* Gnana : Commented as part of Spring'20 Upgrade Activity
    public static void updateLegacyFlagOnBasketOnDelete(List<csbb__Product_Configuration_Request__c> prodConfigReqList) {
        updateLegacyFlagOnBasketHelper.updateBasketLegacyStatusAfterPCRDeletion(prodConfigReqList);

    }
	*/
    
    //@Author: Pooja, Modified Date: 16/July/2020 
    //This is commented as part of CS Spring'20 Release Update.
    /*public static void clearAddress(List<csbb__Product_Configuration_Request__c> prodConfRequests) {
        System.debug('***Entered trigger:PCRTrigger, method:clearAddress***');
        if (StaticUtilForRecursion.runOnceBeforeUpdatePCR()) {
            try {
                Boolean isCorrectConfigId = true;
                Map<Id, csbb__Product_Configuration_Request__c> prodConfRequestMap = new Map<Id, csbb__Product_Configuration_Request__c>();

                for (csbb__Product_Configuration_Request__c prodConfRequest : prodConfRequests) {
                    if (prodConfRequest.csbb__Product_Configuration__c == null) {
                        isCorrectConfigId = false;
                    } else {
                        prodConfRequestMap.put(prodConfRequest.csbb__Product_Configuration__c, prodConfRequest);
                    }
                }
                if (isCorrectConfigId) {
                    if (prodConfRequestMap.keySet().size() > 0) {
                        Map<Id, cscfga__Product_Definition__c> productDefinitions = new Map<Id, cscfga__Product_Definition__c> (
                            [
                                SELECT Id
                                FROM cscfga__Product_Definition__c  WHERE
                                (Site_Agnostic__c = true OR name = : System.Label.Mobility)
                            ]
                        );
                        Map<Id, cscfga__Product_Configuration__c> prodConfigurations =  new Map<Id, cscfga__Product_Configuration__c>(
                            [
                                SELECT Id,
                                Name,
                                cscfga__Product_Definition__r.name
                                FROM cscfga__Product_Configuration__c
                                WHERE Id IN : prodConfRequestMap.keySet()
                                AND cscfga__Product_Definition__c IN : productDefinitions.keySet()
                            ]
                        );

                        //Sr 1. added to fetch service id attribute for mobility
                        Map<Id, cscfga__Attribute__c> AttributeToConfigurationmap = new Map<Id, cscfga__Attribute__c>();
                        if (prodConfigurations.keyset().size() > 0) 
						{
                            for (cscfga__Attribute__c att : [Select id,
                                                             Name,
                                                             cscfga__Value__c,
                                                             cscfga__Product_Configuration__c
                                                             from cscfga__Attribute__c where
                                                             cscfga__Product_Configuration__c IN: prodConfigurations.keyset()
                                                             AND cscfga__Product_Configuration__r.cscfga__Product_Definition__r.name = : System.Label.Mobility
                                                                     AND Name = : System.Label.CustomerFacingServiceId]) {
                                                                         //added label for Edge: 91796 
                                AttributeToConfigurationmap.put(att.cscfga__Product_Configuration__c, att);
                                                                         system.debug('AttributeToConfigurationmap-->'+AttributeToConfigurationmap);
                            }
                        }

                        for (csbb__Product_Configuration_Request__c prodConfRequest : prodConfRequests) {
                            if (prodConfigurations.containsKey(prodConfRequest.csbb__Product_Configuration__c)) {
								system.debug('PCR inside if --->'+prodConfRequest);
                                if (prodConfigurations.get(prodConfRequest.csbb__Product_Configuration__c).cscfga__Product_Definition__r.name == System.Label.Mobility &&
                                        AttributeToConfigurationmap.containsKey(prodConfRequest.csbb__Product_Configuration__c)) 
								{
									String OptionalJson = prodConfRequest.csbb__Optionals__c; //sr 1. Optional Json on PCR
                                    if (OptionalJson!=null && OptionalJson.contains('selectedAddressDisplay')) {
                                        //added for 91796
                                        PCR_Optionals_DTO optionalLs = (PCR_Optionals_DTO)System.JSON.deserialize(OptionalJson , PCR_Optionals_DTO.class);
                                        optionalLs.selectedAddressDisplay = AttributeToConfigurationmap.get(prodConfRequest.csbb__Product_Configuration__c).cscfga__Value__c; // Sr 1.update the json attribute with service id
                                        prodConfRequest.csbb__Optionals__c = JSON.serialize(optionalLs);
                                    }
                                } else {
									system.debug('PCR inside else --->'+prodConfRequest);
                                    String OptionalJson = prodConfRequest.csbb__Optionals__c;
                                    if (OptionalJson!=null && OptionalJson.contains('selectedAddressDisplay')) {
                                        //added for 91796
                                        PCR_Optionals_DTO optionalLs = (PCR_Optionals_DTO)System.JSON.deserialize(OptionalJson , PCR_Optionals_DTO.class);
                                        optionalLs.selectedAddressDisplay = '';
                                        prodConfRequest.csbb__Optionals__c = JSON.serialize(optionalLs);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    System.debug('csbb__Product_Configuration__c field on Product Configuration Request was empty');
                }
            } catch (Exception ex) {
               System.debug(ex);
           }
        }
    }*/
}