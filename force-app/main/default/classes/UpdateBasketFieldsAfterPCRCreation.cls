/*************************************************************************************************
Name : UpdateBasketFieldsAfterPCRCreation
Description : Code to change the basket stage when PCRs are added.
This class changes basket stage on PCR addition and not PC addition to prevent stage change during
enrichment
**************************************************************************************************/

public with sharing class UpdateBasketFieldsAfterPCRCreation {
    
    
    public static void updateSyncFlagAndStage (List <csbb__Product_Configuration_Request__c> prodConfigReqList)
    {
        List<cscfga__Product_Basket__c> prodBasketStageUpdateList = new List<cscfga__Product_Basket__c>();
        Set<Id> basketIdSet = new Set<Id>();
        for(csbb__Product_Configuration_Request__c pcr: prodConfigReqList)
        {
            basketIdSet.add(pcr.csbb__Product_Basket__c);
        }
        
        //Query map holding sync flags on basket which are already synched and whose ids are in basketIdSet
        //Comment existed before code changes of CS Spring'20 upgrade
        /*if(basketIdSet.isNotEmpty()){
            Map<Id,cscfga__Product_Basket__c> bktMap = new Map<Id,cscfga__Product_Basket__c>([Select id,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_With_Opportunity__c from cscfga__Product_Basket__c where id in :basketIdSet and csordtelcoa__Synchronised_with_Opportunity__c =true and csbb__Synchronised_With_Opportunity__c=true]);
        }
        
        
        if(bktMap!=null && bktMap.size()>0)
        {
            for(csbb__Product_Configuration_Request__c pcr: prodConfigReqList)
            {      
                //if the newly created product configurations have basket already synched and the query returns those baskets
                if(bktMap.get(pcr.csbb__Product_Basket__c)!=null)
                {
                    //setting the sync flagd on basket to false
                    cscfga__Product_Basket__c bkt = bktMap.get(pcr.csbb__Product_Basket__c);
                    bkt.csordtelcoa__Synchronised_with_Opportunity__c = false;
                    bkt.csbb__Synchronised_With_Opportunity__c = false;
                }   
                
            }
            //updating the basket values;
            update bktMap.values();
        }
        */  //Comment end before code changes of CS Spring'20 upgrade

        //Code for changing basket stage to Commercial Configuration as soon as products are added
        if(!basketIdSet.isEmpty()){
            if(StaticUtilForRecursion.runOnceAfterInsertPCR())
            {
                //Pooja: CS Spring'20 Upgrade Start. Change - Query condition to run only for Non Modular Opportunity Product Type
                prodBasketStageUpdateList = [SELECT Id,csordtelcoa__Basket_Stage__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Product_Type__c!=:Label.Modular AND Id IN:basketIdSet];    
                //Pooja: CS Spring'20 Upgrade End
            }
        }
        
        for(cscfga__Product_Basket__c basket:prodBasketStageUpdateList)
        {
            if(CustomConfigurationOptions__c.getValues('CommercialConfiguration')!=null && CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c !=null && basket.csordtelcoa__Basket_Stage__c!= CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c){
                basket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c;
            }
            if(basket.csbb__Synchronised_With_Opportunity__c == true || basket.csordtelcoa__Synchronised_with_Opportunity__c == true){
                        system.debug('check auto sync unsync2------');

                basket.csordtelcoa__Synchronised_with_Opportunity__c = false;
                basket.csbb__Synchronised_With_Opportunity__c = false;
            }
            
        }
        if(!prodBasketStageUpdateList.isEmpty()){
                    system.debug('check auto sync unsync33----');

            update prodBasketStageUpdateList;
        }   
    }

    /*EDGE-8185
    * to update basket Legacy flag for Legacy Sites selected
    */
    /*
    public static void updateLegacyFlag(String basketId){
        List<cscfga__Product_Basket__c> basketList = [select id,Legacy__c from cscfga__Product_Basket__c where id = :basketId];
        for(cscfga__Product_Basket__c basket : basketList){
            basket.Legacy__c = true;
        }
        update basketList;
    }
     */
}