/**
* @Author     :   Rahul
* @Date       :   May 2021
* @Desc       :   This class is written for Aptts Rate Card Record Insertion.
* @Initial US :   EDGE-134661
* @Status     :   Deveopment is still pending.
* 
* 
* */
public with sharing class AgreementApttusRateCardUtilities
{

    public static map<id, id> createApttusRateCard(list<DPR_Rate_Card__c> dprRateCardList )
    {   
            Map<String, DPR_RateCard_Slab__mdt> mapRateCardSlab = DPR_RateCard_Slab__mdt.getAll();
            Map<String,DPR_RateCard_Slab__mdt> mapPlanRateCardSlab = new Map<String,DPR_RateCard_Slab__mdt>();
            map<String,APTPS_Rate_Card__c> checkDuplicate= new map<String,APTPS_Rate_Card__c>();
            map<id,id> dprlineitemwithapttusRateCardMap= new map<id,id>();
            for(String key:mapRateCardSlab.keySet()){
                mapPlanRateCardSlab.put(mapRateCardSlab.get(key).Plan__c,mapRateCardSlab.get(key));
            }
            try{
                        if(dprRateCardList.size()>0){
                            for(DPR_Rate_Card__c dprRateCard:dprRateCardList){
                               if(dprRateCard.Parent_DPR_Rate_Card_ID__c==null && !(dprRateCard.Rate_Card__r.name).contains(DataHandlerConstants.excessCharge)){
                                    APTPS_Rate_Card__c aptpsRateCard = new APTPS_Rate_Card__c ();
                                    checkDuplicate.put(dprRateCard.DPR_Rate_Card_Name__c,aptpsRateCard);
                                    checkDuplicate.get(dprRateCard.DPR_Rate_Card_Name__c).name=dprRateCard.DPR_Rate_Card_Name__c;
                                    checkDuplicate.get(dprRateCard.DPR_Rate_Card_Name__c).DPR_Offer_Line_Item__c=dprRateCard.Parent_DPR_OLI_id__c;
                                    system.debug('plannameValue'+checkDuplicate);
                                }
                                if(checkDuplicate.size()>0 ){
                                    if(dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c != 'IoT Connectivity'){
                                    if(checkDuplicate.get(dprRateCard.Rate_Card__r.name).name!=null){
                                    system.debug('dprRateCard.DPR_Rate_Card_Name__c'+dprRateCard.DPR_Rate_Card_Name__c);

                                        if(dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                            system.debug('dprRateCard.Parent_DPR_Rate_Card_ID__c'+dprRateCard.Parent_DPR_Rate_Card_ID__c);
                                            system.debug('dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c'+dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c);
                                            system.debug('mapRateCardSlab'+mapRateCardSlab.get((dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c).replaceAll(' ','_') ).level1__c);
                                            if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapRateCardSlab.get((dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c).replaceAll(' ','_') ).level1__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                             system.debug('level1_Slab_tariff__c');
                                             checkDuplicate.get(dprRateCard.Rate_Card__r.name).level1_Slab_tariff__c=dprRateCard.id;
                                            }

                                            if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapRateCardSlab.get((dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c).replaceAll(' ','_')).level2__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                             system.debug('level2_Slab_tariff__c');
                                             checkDuplicate.get(dprRateCard.Rate_Card__r.name).level2_Slab_tariff__c=dprRateCard.id;
                                            }

                                            if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapRateCardSlab.get((dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c).replaceAll(' ','_')).level3__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                             system.debug('level3_Slab_tariff__c');
                                             checkDuplicate.get(dprRateCard.Rate_Card__r.name).level3_Slab_tariff__c=dprRateCard.id;
                                            }

                                            if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapRateCardSlab.get((dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c).replaceAll(' ','_')).level4__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                             system.debug('level4_Slab_tariff__c');
                                             checkDuplicate.get(dprRateCard.Rate_Card__r.name).level4_Slab_tariff__c=dprRateCard.id;
                                            }

                                            if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapRateCardSlab.get((dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c).replaceAll(' ','_')).level5__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                             system.debug('level5_Slab_tariff__c');
                                             checkDuplicate.get(dprRateCard.Rate_Card__r.name).level5_Slab_tariff__c=dprRateCard.id;
                                            }

                                            if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapRateCardSlab.get((dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c).replaceAll(' ','_')).level6__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                             system.debug('level6_Slab_tariff__c');
                                             checkDuplicate.get(dprRateCard.Rate_Card__r.name).level6_Slab_tariff__c=dprRateCard.id;
                                            }
                                        }

                                    }
                                }else{
                                    if(dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c == 'IoT Connectivity'  && !(dprRateCard.Rate_Card__r.name).contains(DataHandlerConstants.excessCharge)){

                                        String planVariant = '';	
                                        String planType = dprRateCard.Rate_Card__r.name;
                                        if(planType.contains(DataHandlerConstants.IOt_LTE)){
                                        planVariant = DataHandlerConstants.IOt_LTE;
                                        } else if (planType.contains(DataHandlerConstants.IOt_LPWAN)){
                                            planVariant = DataHandlerConstants.IOt_LPWAN;
                                        } else if (planType.contains(DataHandlerConstants.IOT_Utilities)){
                                            planVariant = DataHandlerConstants.IOT_Utilities;
                                        }
                                        if(checkDuplicate.get(dprRateCard.Rate_Card__r.name).name!=null){
        
                                                if(dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                                    if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapPlanRateCardSlab.get(planVariant).level1__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                                     system.debug('level1_Slab_tariff__c');
                                                     checkDuplicate.get(dprRateCard.Rate_Card__r.name).level1_Slab_tariff__c=dprRateCard.id;
                                                    }
        
                                                    if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapPlanRateCardSlab.get(planVariant).level2__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                                     system.debug('level2_Slab_tariff__c');
                                                     checkDuplicate.get(dprRateCard.Rate_Card__r.name).level2_Slab_tariff__c=dprRateCard.id;
                                                    }
        
                                                    if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapPlanRateCardSlab.get(planVariant).level3__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                                     system.debug('level3_Slab_tariff__c');
                                                     checkDuplicate.get(dprRateCard.Rate_Card__r.name).level3_Slab_tariff__c=dprRateCard.id;
                                                    }
        
                                                    if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapPlanRateCardSlab.get(planVariant).level4__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                                     system.debug('level4_Slab_tariff__c');
                                                     checkDuplicate.get(dprRateCard.Rate_Card__r.name).level4_Slab_tariff__c=dprRateCard.id;
                                                    }
        
                                                    if(dprRateCard.DPR_Rate_Card_Name__c ==dprRateCard.Rate_Card__r.name+' '+ mapPlanRateCardSlab.get(planVariant).level5__c && dprRateCard.Parent_DPR_Rate_Card_ID__c!=null){
                                                     system.debug('level5_Slab_tariff__c');
                                                     checkDuplicate.get(dprRateCard.Rate_Card__r.name).level5_Slab_tariff__c=dprRateCard.id;
                                                    }
                                                }
        
                                            }

                                    }
                                }   
                                }

                            }
                            system.debug('ApptsRatecard'+checkDuplicate);
                        }
                        if(checkDuplicate.size()>0){
                            insert checkDuplicate.values();
                                for(APTPS_Rate_Card__c aptsRateCard:checkDuplicate.values()){
                                    dprlineitemwithapttusRateCardMap.put(aptsRateCard.DPR_Offer_Line_Item__c,aptsRateCard.id);
                                }
                                system.debug('dprlineitemwithapttusRateCardMap'+dprlineitemwithapttusRateCardMap);
                        }
                    return dprlineitemwithapttusRateCardMap;
            }
            catch(Exception ex)
            {
                
                 System.debug('***Telstra:AgreementApttusRateCardUtilities:exception:'+ex.getLineNumber()+' '+ex.getMessage()) ;
                return dprlineitemwithapttusRateCardMap;
            }
    }
}