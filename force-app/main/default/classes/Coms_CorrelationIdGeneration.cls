/*************************************************************************************************************
 * @name            Coms_CorrelationIdGeneration
 * @author          BLR\rohit.pal <rohit.pal@crmit.com>
 * @created         12 / 08 / 2021
 * @description     This is utility class to generate the correlation unique ids to order and its related objects.
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2021-08-12      BLR\rohit.pal           Changes desription
 *
**************************************************************************************************************/
public with sharing class Coms_CorrelationIdGeneration {
    
    /**
    * @description : update correlation ids dynaically on Order --> subscriptions --> services --> technical objects
        i.e. if order id is AABBCC then related subscription id would be AABBCCSubs0 ,AABBCCSubs1, AABBCCSubs2 ...n.
        same for Services AABBCCServ0,AABBCCServ1,AABBCCServ2 .....n.
    * @author Rohit Pal | 08-12-2021 
    * @param orderId 
    * @param setSubscriptionId 
    * @param setServiceId 
    **/
    public static List<sobject> updateCorrelationIdOnOrderSubscriptionAndServices(set<id> orderIdSet , boolean isOnlyOrder , boolean boolStampTime){
        Map<id,csord__Order__c> mapCSordOrder = new Map<id,csord__Order__c>();
        List<sobject> listsobject = new List<sobject>();
        if(!orderIdSet.isEmpty()){
            mapCSordOrder = getOrderWithCorrelationid(orderIdSet,boolStampTime);
            if(!mapCSordOrder.isEmpty()){
                listsobject.addAll(mapCSordOrder.values());
            }
            if(!listsobject.isEmpty()){
                System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnOrderSubscriptionAndServices :: Found mapCSordOrder ---> ' + mapCSordOrder);
                if(!isOnlyOrder){
                    List<sobject> listSubscription = new List<sobject>();
                    listSubscription = updateCorrelationIdOnSubscriptions(mapCSordOrder,boolStampTime);
                    System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnOrderSubscriptionAndServices :: Found listSubscription ---> ' + listSubscription);
                    List<sobject> listServices = new List<sobject>();
                    listServices = updateCorrelationIdOnServices(mapCSordOrder,boolStampTime);
                    listsobject.addAll(listSubscription);
                    listsobject.addAll(listServices);
                }
            }
        }
        return listsobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-31-2021 
    * @param orderIdSet 
    * @return Map<id, csord__Order__c> 
    **/
    public static Map<id,csord__Order__c> getOrderWithCorrelationid(set<id> orderIdSet , boolean boolStampTime){
        System.debug('Coms_CorrelationIdGeneration :: getOrderWithCorrelationid :: Found orderIdSet ---> ' + orderIdSet);
        Map<id,csord__Order__c> mapCSordOrder = new Map<id,csord__Order__c>();
        List<sobject> listsobject = new List<sobject>();
        if(orderIdSet != null){
            mapCSordOrder = getCsordOrders(orderIdSet);
            for(csord__Order__c iterator : mapCSordOrder.values()){
                iterator.CorrelationId__c = iterator.id;
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapCSordOrder.put(iterator.id , iterator);
            }
        }
        return mapCSordOrder;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-16-2021 
    * @param mapCSordOrder 
    * @param boolStampTime 
    * @return List<sobject> 
    **/
    public static List<sobject> updateCorrelationIdOnBillingAccounts(set<id> orderIdSet,boolean boolStampTime){
        Map<id,Billing_Account__c> mapBillingAccount = new Map<id,Billing_Account__c>();
        List<sobject> listsobject = new List<sobject>();
        mapBillingAccount = getBillingAccountsWithCorrelationid(orderIdSet,boolStampTime);
        if(!mapBillingAccount.isEmpty()){
            listsobject.addAll(mapBillingAccount.values());
        }
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnSubscriptions :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-16-2021 
    * @param orderIdSet 
    * @param boolStampTime 
    * @return Map<id, Billing_Account__c> 
    **/
    public static Map<id,Billing_Account__c> getBillingAccountsWithCorrelationid(set<id> orderIdSet , boolean boolStampTime){
        Map<id,Billing_Account__c> mapBillingAccount = new Map<id,Billing_Account__c>();
        List<sobject> listsobject = new List<sobject>();
        if(!orderIdSet.isEmpty()){
            mapBillingAccount = getBillingAccounts(orderIdSet);
            for(Billing_Account__c iterator : mapBillingAccount.values()){
                iterator.CorrelationId__c = iterator.id;
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapBillingAccount.put(iterator.id , iterator);
            }
        }
        return mapBillingAccount;
    }

    /**
    * @description : Update correlation id on only subscription object.
    * @author Rohit Pal | 08-12-2021 
    * @param setSubscriptionId 
    **/
    public static List<sobject> updateCorrelationIdOnSubscriptions(Map<id,csord__Order__c> mapCSordOrder,boolean boolStampTime){
        Map<id,csord__Subscription__c> mapSubscription = new Map<id,csord__Subscription__c>();
        List<sobject> listsobject = new List<sobject>();
        mapSubscription = getSubscriptionWithCorrelationid(mapCSordOrder,boolStampTime);
        if(!mapSubscription.isEmpty()){
            listsobject.addAll(mapSubscription.values());
        }
        List<sobject> listNumber = new List<sobject>();
        listNumber = updateCorrelationIdOnNumber(mapSubscription , true);
        listsobject.addAll(listNumber);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnSubscriptions :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }
    
    /**
    * @description 
    * @author Rohit Pal | 08-31-2021 
    * @param orderIdSet 
    * @return Map<id, csord__Order__c> 
    **/
    public static Map<id,csord__Subscription__c> getSubscriptionWithCorrelationid(Map<id,csord__Order__c> mapCSordOrder,boolean boolStampTime){
        Map<id,csord__Subscription__c> mapSubscription = new Map<id,csord__Subscription__c>();
        integer i=1;
        if(!mapCSordOrder.isEmpty()){
            mapSubscription = getSubscriptions(mapCSordOrder.keySet());
            for(csord__Subscription__c iterator : mapSubscription.values()){
                iterator.CorrelationId__c = string.valueOf(mapCSordOrder?.get(iterator.csord__Order__c)?.CorrelationId__c+'Subs'+i);
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapSubscription.put(iterator.id , iterator);
                i++;
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getSubscriptionWithCorrelationid :: Found mapSubscription ---> ' + mapSubscription);
        return mapSubscription;
    }
    /**
    * @description : Update correlation id on only services object.
    * @author Rohit Pal | 08-12-2021 
    * @param setServiceId 
    **/
    public static List<sobject> updateCorrelationIdOnServices(Map<id,csord__Order__c> mapCSordOrder , boolean boolStampTime){
        Map<Id,csord__Service__c> mapServices = new Map<Id,csord__Service__c>();
        List<sobject> listsobject = new List<sobject>();
        mapServices = getServiceWithCorrelationid(mapCSordOrder,boolStampTime);
        if(!mapServices.isEmpty()){
            listsobject.addAll(mapServices.values());
        }        
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnServices :: Found listsobject ---> ' + listsobject);
        List<sobject> listOrchestrationTechnical = new List<sobject>();
        listOrchestrationTechnical = updateOrchestrationTechnicals(mapServices,boolStampTime);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnServices :: Found listOrchestrationTechnical ---> ' + listOrchestrationTechnical);
        listsobject.addAll(listOrchestrationTechnical);
        List<sobject> listChargeLineItem = new List<sobject>();
        listChargeLineItem = updateCorrelationIdOnChargeLineItem(mapServices,boolStampTime);
        listsobject.addAll(listChargeLineItem);
        return listsobject;
    }
    
    /**
    * @description 
    * @author Rohit Pal | 08-31-2021 
    * @param orderIdSet 
    * @return Map<id, csord__Order__c> 
    **/
    public static Map<id,csord__Service__c> getServiceWithCorrelationid(Map<id,csord__Order__c> mapCSordOrder , boolean boolStampTime){
        Map<Id,csord__Service__c> mapServices = new Map<Id,csord__Service__c>();
        integer i=1;
        if(!mapCSordOrder.isEmpty()){
            mapServices = getCSordServices(mapCSordOrder.keySet());
            for(csord__Service__c iterator : mapServices.values()){
                iterator.CorrelationId__c = string.valueOf(mapCSordOrder?.get(iterator.csord__Order__c)?.CorrelationId__c+'Serv'+i);
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapServices.put(iterator.id , iterator);
                i++;
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getSubscriptionWithCorrelationid :: Found mapServices ---> ' + mapServices);
        return mapServices;
    }
    /**
    * @description : Update correlation id on only Technical object.
    * @author Rohit Pal | 08-18-2021 
    * @param setServices 
    **/
    public static List<sobject> updateOrchestrationTechnicals(Map<Id,csord__Service__c> mapServices,boolean boolStampTime){
        Map<Id, Orchestration_Technical__c> mapOrchestrationTechnical = new Map<Id, Orchestration_Technical__c>();
        List<sobject> listsobject = new List<sobject>();
        mapOrchestrationTechnical = getOrchestrationTechnicalsWithCorrelationid(mapServices,boolStampTime);
            if(!mapOrchestrationTechnical.isEmpty()){ 
                listsobject.addAll(mapOrchestrationTechnical.values());
            }
            //Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(setServices);
            System.debug('Coms_CorrelationIdGeneration :: updateOrchestrationTechnicals :: Found listsobject ---> ' + listsobject);
            List<sobject> listChildAttribute = new List<sobject>();
            listChildAttribute = updateCorrelationIdOnTechnicalChildAttribute(mapOrchestrationTechnical,boolStampTime);
            listsobject.addAll(listChildAttribute);
        return listsobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-31-2021 
    * @param orderIdSet 
    * @return Map<id, csord__Order__c> 
    **/
    public static Map<id,Orchestration_Technical__c> getOrchestrationTechnicalsWithCorrelationid(Map<Id,csord__Service__c> mapServices,boolean boolStampTime){
        Map<Id, Orchestration_Technical__c> mapOrchestrationTechnical = new Map<Id, Orchestration_Technical__c>();
        integer i=1;
        if(!mapServices.isEmpty()){
            mapOrchestrationTechnical = getOrchestrationTechnicals(mapServices.keySet());
            for(Orchestration_Technical__c iterator : mapOrchestrationTechnical.values()){
                if(mapServices.get(iterator.service__c).CorrelationId__c != null){
                    iterator.CorrelationId__c = string.valueOf(mapServices?.get(iterator.service__c)?.CorrelationId__c+'TO'+i);
                    if(boolStampTime){
                        iterator.Platform_Cache_Timestamp__c = system.now();
                    }
                    mapOrchestrationTechnical.put(iterator.id , iterator);
                    i++;
                }
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getOrchestrationTechnicalsWithCorrelationid :: Found mapOrchestrationTechnical ---> ' + mapOrchestrationTechnical);
        return mapOrchestrationTechnical;
    }

    /**
    * @description
    * @author Rohit Pal | 08-26-2021 
    * @param setOrchestrationTechnical 
    **/
    public static List<sobject> updateCorrelationIdOnTechnicalChildAttribute(Map<Id, Orchestration_Technical__c> mapOrchestrationTechnical,boolean boolStampTime){
        Map<Id, Technical_Child_Attribute__c> mapTechnicalChildAttribute = new Map<Id, Technical_Child_Attribute__c>();
        List<sobject> listsobject = new List<sobject>();
        mapTechnicalChildAttribute = getTechnicalChildAttributeWithCorrelationid(mapOrchestrationTechnical,boolStampTime);
        if(!mapTechnicalChildAttribute.isEmpty()){
            listsobject.addAll(mapTechnicalChildAttribute.values());
        }
        //Coms_PlatfornCacheUtil.insertOrchestrationTechnicalToCache(setServices);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnTechnicalChildAttribute :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }
    /**
    * @description 
    * @author Rohit Pal | 08-31-2021 
    * @param orderIdSet 
    * @return Map<id, csord__Order__c> 
    **/
    public static Map<id,Technical_Child_Attribute__c> getTechnicalChildAttributeWithCorrelationid(Map<Id, Orchestration_Technical__c> mapOrchestrationTechnical,boolean boolStampTime){
        Map<Id, Technical_Child_Attribute__c> mapTechnicalChildAttribute = new Map<Id, Technical_Child_Attribute__c>();        
        integer i=1;
        if(!mapOrchestrationTechnical.isEmpty()){
            mapTechnicalChildAttribute = getTechnicalChildAttribute(mapOrchestrationTechnical.keySet());
            for(Technical_Child_Attribute__c iterator : mapTechnicalChildAttribute.values()){
                iterator.CorrelationId__c = string.valueOf(mapOrchestrationTechnical?.get(iterator.Orchestration_Technical__c)?.CorrelationId__c+'CA'+i);
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapTechnicalChildAttribute.put(iterator.id , iterator);
                i++;
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getTechnicalChildAttributeWithCorrelationid :: Found mapTechnicalChildAttribute ---> ' + mapTechnicalChildAttribute);
        return mapTechnicalChildAttribute;
    }

    
    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param mapServices 
    * @return List<sobject> 
    **/
    public static List<sobject> updateCorrelationIdOnChargeLineItem(Map<Id,csord__Service__c> mapServices,boolean boolStampTime){
        Map<Id, Charge_Line_Item__c> mapChargeLineItem = new Map<Id, Charge_Line_Item__c>();
        List<sobject> listsobject = new List<sobject>();
        mapChargeLineItem = getChargeLineItemWithCorrelationid(mapServices,boolStampTime);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnChargeLineItem :: Found mapChargeLineItem ---> ' + mapChargeLineItem);
        if(!mapChargeLineItem.isEmpty()){
            listsobject.addAll(mapChargeLineItem.values());
            list<sobject> listSobjectPriceScheduleLine = new list<sobject>();
            listSobjectPriceScheduleLine = updateCorrelationIdOnPriceScheduleLineItem(mapChargeLineItem, true);
            listsobject.addAll(listSobjectPriceScheduleLine);
            System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnChargeLineItem :: Found listSobjectPriceScheduleLine ---> ' + listSobjectPriceScheduleLine);
            //listsobject.addAll(updateCorrelationIdOnDiscountLineItem(mapChargeLineItem, true));
        }
        //Coms_PlatfornCacheUtil.insertOrchestrationTechnicalToCache(setServices);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnChargeLineItem :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }

    
    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param mapServices 
    * @return Map<id, Charge_Line_Item__c> 
    **/
    public static Map<id,Charge_Line_Item__c> getChargeLineItemWithCorrelationid(Map<Id, csord__Service__c> mapServices,boolean boolStampTime){
        Map<Id, Charge_Line_Item__c> mapChargeLineItem = new Map<Id, Charge_Line_Item__c>();        
        integer i=1;
        if(!mapServices.isEmpty()){
            mapChargeLineItem = getChargeLineItem(mapServices.keySet());
            for(Charge_Line_Item__c iterator : mapChargeLineItem.values()){
                iterator.CorrelationId__c = string.valueOf(mapServices?.get(iterator.serviceId__c)?.CorrelationId__c+'CLI'+i);
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapChargeLineItem.put(iterator.id , iterator);
                i++;
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getChargeLineItemWithCorrelationid :: Found mapChargeLineItem ---> ' + mapChargeLineItem);
        return mapChargeLineItem;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param mapChargeLineItem 
    * @return List<sobject> 
    **/
    public static List<sobject> updateCorrelationIdOnPriceScheduleLineItem( Map<id,Charge_Line_Item__c> mapChargeLineItem,boolean boolStampTime){
        Map<Id, Price_Schedule_Line_Item__c> mapPriceScheduleLineItem = new Map<Id, Price_Schedule_Line_Item__c>();
        List<sobject> listsobject = new List<sobject>();
        mapPriceScheduleLineItem = getPriceScheduleLineItemWithCorrelationid(mapChargeLineItem,boolStampTime);
        if(!mapPriceScheduleLineItem.isEmpty()){
            listsobject.addAll(mapPriceScheduleLineItem.values());
        }
        List<sobject> listPriceScheduleDiscountAssociation = new List<sobject>();
        listPriceScheduleDiscountAssociation = updateCorrelationIdOnPriceScheduleDiscountAssociation(mapPriceScheduleLineItem , boolStampTime);
        listsobject.addAll(listPriceScheduleDiscountAssociation);
        List<sobject> listTierLineItem = new List<sobject>();
        listTierLineItem = updateCorrelationIdOnTierLineItem( mapPriceScheduleLineItem, boolStampTime);
        listsobject.addAll(listTierLineItem);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnPriceScheduleLineItem :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param mapChargeLineItem 
    * @return Map<id, Price_Schedule_Line_Item__c> 
    **/
    public static Map<id,Price_Schedule_Line_Item__c> getPriceScheduleLineItemWithCorrelationid(Map<id,Charge_Line_Item__c> mapChargeLineItem,boolean boolStampTime){
        Map<Id, Price_Schedule_Line_Item__c> mapPriceScheduleLineItem = new Map<Id, Price_Schedule_Line_Item__c>();        
        integer i=1;
        if(!mapChargeLineItem.isEmpty()){
            mapPriceScheduleLineItem =  getPriceScheduleLineItem(mapChargeLineItem.keySet());
            for(Price_Schedule_Line_Item__c iterator : mapPriceScheduleLineItem.values()){
                iterator.CorrelationId__c = string.valueOf(mapChargeLineItem?.get(iterator.chargeInstance__c)?.CorrelationId__c+'PSLI'+i);
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapPriceScheduleLineItem.put(iterator.id , iterator);
                i++;
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getChargeLineItemWithCorrelationid :: Found mapPriceScheduleLineItem ---> ' + mapPriceScheduleLineItem);
        return mapPriceScheduleLineItem;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-12-2021 
    * @param mapPriceScheduleLineItem 
    * @param boolStampTime 
    * @return List<sobject> 
    **/
    public static List<sobject> updateCorrelationIdOnPriceScheduleDiscountAssociation( Map<id,Price_Schedule_Line_Item__c> mapPriceScheduleLineItem,boolean boolStampTime){
        Map<Id, Price_Schedule_Discount_Association__c> mapPriceScheduleDiscountAssociation = new Map<Id, Price_Schedule_Discount_Association__c>();
        List<sobject> listsobject = new List<sobject>();
        mapPriceScheduleDiscountAssociation = getPriceScheduleDiscountAssociationWithCorrelationid(mapPriceScheduleLineItem,boolStampTime);
        if(mapPriceScheduleDiscountAssociation !=null && !mapPriceScheduleDiscountAssociation.isEmpty()){
            listsobject.addAll(mapPriceScheduleDiscountAssociation.values());
        }
        //Coms_PlatfornCacheUtil.insertOrchestrationTechnicalToCache(setServices);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnPriceScheduleDiscountAssociation :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }
    /**
    * @description 
    * @author Rohit Pal | 10-12-2021 
    * @param mapPriceScheduleLineItem 
    * @param boolStampTime 
    * @return Map<id, Price_Schedule_Discount_Association__c> 
    **/
    public static Map<id,Price_Schedule_Discount_Association__c> getPriceScheduleDiscountAssociationWithCorrelationid(Map<id,Price_Schedule_Line_Item__c> mapPriceScheduleLineItem,boolean boolStampTime){
        Map<Id, Price_Schedule_Discount_Association__c> mapPriceScheduleDiscountAssociation = new Map<Id, Price_Schedule_Discount_Association__c>();        
        integer i=1;
        if(!mapPriceScheduleLineItem.isEmpty()){
            mapPriceScheduleDiscountAssociation =  getPriceScheduleDiscountAssociation(mapPriceScheduleLineItem.keySet());
            if(mapPriceScheduleDiscountAssociation != null){
                for(Price_Schedule_Discount_Association__c iterator : mapPriceScheduleDiscountAssociation.values()){
                    iterator.CorrelationId__c = string.valueOf(mapPriceScheduleLineItem?.get(iterator.priceScheduleInstance__c	)?.CorrelationId__c+'PSDA'+i);
                    if(boolStampTime){
                        iterator.Platform_Cache_Timestamp__c = system.now();
                    }
                    mapPriceScheduleDiscountAssociation.put(iterator.id , iterator);
                    i++;
                }
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getPriceScheduleDiscountAssociationWithCorrelationid :: Found mapPriceScheduleDiscountAssociation ---> ' + mapPriceScheduleDiscountAssociation);
        return mapPriceScheduleDiscountAssociation;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-12-2021 
    * @param mapPriceScheduleLineItem 
    * @param boolStampTime 
    * @return List<sobject> 
    **/
    public static List<sobject> updateCorrelationIdOnTierLineItem( Map<id,Price_Schedule_Line_Item__c> mapPriceScheduleLineItem,boolean boolStampTime){
        Map<Id, Tier_Line_Item__c> mapTierLineItem = new Map<Id, Tier_Line_Item__c>();
        List<sobject> listsobject = new List<sobject>();
        mapTierLineItem = getTierLineItemWithCorrelationid(mapPriceScheduleLineItem,boolStampTime);
        if(!mapTierLineItem.isEmpty()){
            listsobject.addAll(mapTierLineItem.values());
        }
        //Coms_PlatfornCacheUtil.insertOrchestrationTechnicalToCache(setServices);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnTierLineItem :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }
    /**
    * @description 
    * @author Rohit Pal | 10-12-2021 
    * @param mapChargeLineItem 
    * @param boolStampTime 
    * @return Map<id, Tier_Line_Item__c> 
    **/
    public static Map<id,Tier_Line_Item__c> getTierLineItemWithCorrelationid(Map<id,Price_Schedule_Line_Item__c> mapPriceScheduleLineItem,boolean boolStampTime){
        Map<Id, Tier_Line_Item__c> mapTierLineItem = new Map<Id, Tier_Line_Item__c>();        
        integer i=1;
        if(!mapPriceScheduleLineItem.isEmpty()){
            mapTierLineItem =  getTierLineItem(mapPriceScheduleLineItem.keySet());
            for(Tier_Line_Item__c iterator : mapTierLineItem.values()){
                iterator.CorrelationId__c = string.valueOf(mapPriceScheduleLineItem?.get(iterator.PSLIInstance__c	)?.CorrelationId__c+'TLI'+i);
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapTierLineItem.put(iterator.id , iterator);
                i++;
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getTierLineItemWithCorrelationid :: Found mapTierLineItem ---> ' + mapTierLineItem);
        return mapTierLineItem;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param mapChargeLineItem 
    * @return List<sobject> 
    **/
    public static List<sobject> updateCorrelationIdOnDiscountLineItem( Map<id,Charge_Line_Item__c> mapChargeLineItem,boolean boolStampTime){
        Map<Id, Discount_Line_Item__c> mapDiscountLineItem = new Map<Id, Discount_Line_Item__c>();
        List<sobject> listsobject = new List<sobject>();
        mapDiscountLineItem = getDiscountLineItemWithCorrelationid(mapChargeLineItem,boolStampTime);
        if(!mapDiscountLineItem.isEmpty()){
            listsobject.addAll(mapDiscountLineItem.values());
        }
        //Coms_PlatfornCacheUtil.insertOrchestrationTechnicalToCache(setServices);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnPriceScheduleLineItem :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param mapChargeLineItem 
    * @return Map<id, Discount_Line_Item__c> 
    **/
    public static Map<id,Discount_Line_Item__c> getDiscountLineItemWithCorrelationid(Map<id,Charge_Line_Item__c> mapChargeLineItem,boolean boolStampTime){
        Map<Id, Discount_Line_Item__c> mapDiscountLineItem = new Map<Id, Discount_Line_Item__c>();        
        integer i=1;
        if(!mapChargeLineItem.isEmpty()){
            mapDiscountLineItem =  getDiscountLineItem(mapChargeLineItem.keySet());
            for(Discount_Line_Item__c iterator : mapDiscountLineItem.values()){
                iterator.CorrelationId__c = string.valueOf(mapChargeLineItem?.get(iterator.chargeInstance__c)?.CorrelationId__c+'DLI'+i);
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapDiscountLineItem.put(iterator.id , iterator);
                i++;
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getChargeLineItemWithCorrelationid :: Found mapDiscountLineItem ---> ' + mapDiscountLineItem);
        return mapDiscountLineItem;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param mapSubscription 
    * @return List<sobject> 
    **/
    public static List<sobject> updateCorrelationIdOnNumber(Map<id,csord__Subscription__c> mapSubscription,boolean boolStampTime){
        Map<Id, Number__c> mapNumber = new Map<Id, Number__c>();
        List<sobject> listsobject = new List<sobject>();
        mapNumber = getNumberWithCorrelationid(mapSubscription,boolStampTime);
        if(!mapNumber.isEmpty()){
            listsobject.addAll(mapNumber.values());
        }
        //Coms_PlatfornCacheUtil.insertOrchestrationTechnicalToCache(setServices);
        System.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnNumber :: Found listsobject ---> ' + listsobject);
        return listsobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param mapSubscription 
    * @return Map<id, Number__c>
    **/
    public static Map<id,Number__c> getNumberWithCorrelationid(Map<id,csord__Subscription__c> mapSubscription,boolean boolStampTime){
        Map<Id, Number__c> mapNumber = new Map<Id, Number__c>();
        Map<string, csord__Subscription__c> mapSubscriptionNumber = new Map<string, csord__Subscription__c>();        
        integer i=1;
        if(!mapSubscription.isEmpty()){
            for(csord__Subscription__c iterator : mapSubscription.values()){
                mapSubscriptionNumber.put(iterator.csordtelcoa__Subscription_Number__c , iterator);
            }
            mapNumber =  getNumber(mapSubscriptionNumber.keySet());
            for(Number__c iterator : mapNumber.values()){
                iterator.CorrelationId__c = string.valueOf(mapSubscriptionNumber?.get(iterator.Subscription_number__c)?.CorrelationId__c+'Num'+i);
                if(boolStampTime){
                    iterator.Platform_Cache_Timestamp__c = system.now();
                }
                mapNumber.put(iterator.id , iterator);
                i++;
            }
        }
        System.debug('Coms_CorrelationIdGeneration :: getNumberWithCorrelationid :: Found mapDiscountLineItem ---> ' + mapNumber);
        return mapNumber;
    }

    /**
    * @description : get Order Correlation id.
    * @author Rohit Pal | 08-12-2021 
    * @param idOrderRecordId 
    * @return csord__Order__c 
    **/
    public static Map<id,csord__Order__c> getCsordOrders(set<id> setOrderRecordId){
        List<csord__Order__c> listCSOrder = new List<csord__Order__c>();
        SObjectType sobType =  csord__Order__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('csord__Order__c');
        listCSOrder = Database.query(' SELECT ' + String.join(fields, ',')
                                                + ' FROM ' + sobType
                                                + ' WHERE  Id =: setOrderRecordId');
        system.debug('Coms_CorrelationIdGeneration :: getCsordOrders found listCSOrder ---> ' + listCSOrder);
        return new Map<id,csord__Order__c>(listCSOrder);
    }

    /**
    * @description 
    * @author Rohit Pal | 09-16-2021 
    * @param setOrderRecordId 
    * @return Map<id, Billing_Account__c> 
    **/
    public static Map<id,Billing_Account__c> getBillingAccounts(set<id> setOrderRecordId){
        List<Billing_Account__c> listBillingAccounts = new List<Billing_Account__c>();
        SObjectType sobType =  Billing_Account__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Billing_Account__c');
        listBillingAccounts = Database.query(' SELECT ' + String.join(fields, ',')
                                                + ' FROM ' + sobType
                                                + ' WHERE  Id IN : (SELECT Billing_Account__c FROM csord__Order__c WHERE Id=:setOrderRecordId)');
        system.debug('Coms_CorrelationIdGeneration :: getBillingAccounts found listCSOrder ---> ' + listBillingAccounts);
        return new Map<id,Billing_Account__c>(listBillingAccounts);
    }

    // public static List<sobject> updateCorrelationIdOnSubsandRealatedObject(set<id> setOrderRecordId , boolean boolStampTime ){
    //     List<sobject> listSobjectAndRelatedObjects = new List<sobject>();
    //     listSobjectAndRelatedObjects.addAll(sperateSubscriptionData(setOrderRecordId));
    //     system.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnSubsandRealatedObject found listSobjectAndRelatedObjects ---> ' + listSobjectAndRelatedObjects);
    //     List<ConstantMetadataUtility__mdt> mdtConstantMetadataUtilityList = Coms_PlatformCacheUtil.mdtGetDynamicQueryFieldsByOrder('csord__Subscription__c');
    //     Map<string ,ConstantMetadataUtility__mdt> mapConstantMetadataUtilityMdt = new Map<string , ConstantMetadataUtility__mdt>();
    //     for(ConstantMetadataUtility__mdt iterator : mdtConstantMetadataUtilityList){
    //         mapConstantMetadataUtilityMdt.put(iterator.masterLabel , iterator);
    //     }
    //     system.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnSubsandRealatedObject found mapConstantMetadataUtilityMdt ---> ' + mapConstantMetadataUtilityMdt);
    //     // mapName.put(1 , order);
    //     // mapName.put(2 , Subscription1);
    //     // mapName.put(3 , Subscription2);
    //     // mapName.put(4 , services1);
    //     // mapName.put(5 , services2);
    //     // mapName.put(6 , services3);
    //     // Order id = a4b2N000000jCM3 totla 10 - Correlation Sequence 1
    //     // Subscription1   = a4b2N000000jCM3 + 'Subscription__c'+1;  Correlation Sequence 2
    //     // Subscription 2= a4b2N000000jCM3 + 'Subscription__c'+2;
    //     // Subscription 3 = a4b2N000000jCM3 + 'Subscription__c'+3;
    //     // Subscription 4 = a4b2N000000jCM3 + 'Subscription__c'+4;
    //     // services1  = a4b2N000000jCM3 + 'Service__c'+1
    //     // services2  = a4b2N000000jCM3 + 'Service__c'+2
    //     // OT   === a4b2N000000jCM3TO (service+TO) we can give api name to make it gneraic
    //     // TCA== TO+CA1 (a4b2N000000 + CA) (OT + CA1)
    //     //  TCA== TO+CA1 (a4b2N000000 + CA) (OT + CA2)
    //     listSobjectAndRelatedObjects.sort();
    //     Map<integer , List<sobject>> mapCorrelationSequenceAndObjects = new Map<integer , List<sobject>>();

    //     for (integer i = 0; i <listSobjectAndRelatedObjects.size(); i++) {
    //         //mapCorrelationSequenceAndObjects.put(i , listSobjectAndRelatedObjects[i]);
    //         String sobjectType = listSobjectAndRelatedObjects[i].id.getSObjectType().getDescribe().getName();
    //         system.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnSubsandRealatedObject found sobjectType ---> ' + sobjectType);
    //         if(mapConstantMetadataUtilityMdt.containsKey(sobjectType)  &&
    //             mapCorrelationSequenceAndObjects.containsKey(Integer.valueOf(mapConstantMetadataUtilityMdt.get(sobjectType).Correlation_Sequence__c)) 
    //             ){
    //             List<sobject> listCurrentSobject = mapCorrelationSequenceAndObjects.get(Integer.valueOf(mapConstantMetadataUtilityMdt.get(sobjectType).Correlation_Sequence__c));
    //             listCurrentSobject.add(listSobjectAndRelatedObjects[i]);
    //             mapCorrelationSequenceAndObjects.put(Integer.valueOf(mapConstantMetadataUtilityMdt.get(sobjectType).Correlation_Sequence__c) , listCurrentSobject);
    //         }else if(mapConstantMetadataUtilityMdt.containsKey(sobjectType)  
    //                 &&
    //                 !mapCorrelationSequenceAndObjects.containsKey(Integer.valueOf(mapConstantMetadataUtilityMdt.get(sobjectType).Correlation_Sequence__c)) ){
    //             mapCorrelationSequenceAndObjects.put(Integer.valueOf(mapConstantMetadataUtilityMdt.get(sobjectType).Correlation_Sequence__c) , new List<sobject>{listSobjectAndRelatedObjects[i]});
    //         }
    //         // String sobjectType = listSobjectAndRelatedObjects[i].id.getSObjectType().getDescribe().getName();
    //         // if(!mapCorrelationSequenceAndObjects.containsKey(i) && mapConstantMetadataUtilityMdt.containsKey(sobjectType) && mapConstantMetadataUtilityMdt.get(sobjectType).Correlation_Sequence__c == i){
    //         //     mapCorrelationSequenceAndObjects.put( i , listSobjectAndRelatedObjects[i]);
    //         //     i++;
    //         // }else if(mapCorrelationSequenceAndObjects.containsKey(i) 
    //         //         && mapConstantMetadataUtilityMdt.containsKey(sobjectType) 
    //         //         && mapConstantMetadataUtilityMdt.get(sobjectType).Correlation_Sequence__c == i) {
                
    //         // }
    //         system.debug('Coms_CorrelationIdGeneration :: updateCorrelationIdOnSubsandRealatedObject found mapCorrelationSequenceAndObjects ---> ' + mapCorrelationSequenceAndObjects);
    //     }

    //     return null;
    // }
  
    // public static List<sobject> sperateSubscriptionData(set<id> setOrderRecordId){
    //     List<sobject> listAlltheRelatedRecord = new List<sobject>();
    //     List<sobject> listAlltheRelatedRecordAll = new List<sobject>();
    //     List<csord__Subscription__c> listcsordSubscription = new List<csord__Subscription__c>();
    //     List<ConstantMetadataUtility__mdt> mdtConstantMetadataUtilityList = Coms_PlatformCacheUtil.mdtGetDynamicQueryFieldsByOrder('csord__Subscription__c');
    //     Map<string , Id> mp = new Map<string , id>();
    //     List<string>fields;
    //     for (Integer i = 0; i < mdtConstantMetadataUtilityList.size(); i++) {
    //         fields = new List<string>();
    //         if(mdtConstantMetadataUtilityList[i].Order_Of_Execution__c == 1){
    //             SObjectType sobType =  csord__Subscription__c.SObjectType;
    //             fields = string.valueof(mdtConstantMetadataUtilityList[i].Query_Fields_Names__c).Split(',');
    //             listAlltheRelatedRecord =  Database.query(' SELECT ' + String.join(fields, ',')
    //                                                         + ' FROM ' + sobType
    //                                                         + ' WHERE  csord__Order__c =: setOrderRecordId ORDER BY csordtelcoa__Subscription_Number__c ASC');
    //                                                         listAlltheRelatedRecordAll.addAll(listAlltheRelatedRecord);
    //         system.debug('Coms_CorrelationIdGeneration :: sperateSubscriptionData found 1 listAlltheRelatedRecord  ---> ' + listAlltheRelatedRecord);
    //         }
    //     }
    //     // The API name of the relation and actual object can be different
    //     // no such method to check the contains key in sobject.
    //     // will the child relationship name would be the same. 
    //     for(sobject iterator : listAlltheRelatedRecord){
    //         for(ConstantMetadataUtility__mdt iteratormdt : mdtConstantMetadataUtilityList){
    //             if(iteratormdt.Value__c != null 
    //                 && 
    //                 string.valueOf(iteratormdt.Value__c).contains('__c') 
    //                 && iteratormdt.Value__c != 'Marketable_Offer__c'
    //                 && iteratormdt.Type__c == 'Parent'){
    //                 //
    //                 mp.put(iteratormdt.Value__c , (id) iterator.get(iteratormdt.Value__c));
    //                 //
    //             }else if(iteratormdt.Value__c != null 
    //                 && 
    //                 string.valueOf(iteratormdt.Value__c).contains('__c') 
    //                 && iteratormdt.Value__c != 'Marketable_Offer__c'
    //                 && iteratormdt.Type__c == 'Child'){
                    
    //                 mp.put('csord__Subscription__c' , (id) iterator.get('csord__Subscription__c'));
    //             }
    //         }
    //         mp.put('Marketable_Offer__c' , (id) iterator.get('MarketableOffer__c'));
    //         //mp.put('Marketable_Offer__c' , 'aAP2N0000001Qf1WAE');
    //     }
    //     System.debug('mp --> ' + mp);
    //     for (Integer i = 1; i <mdtConstantMetadataUtilityList.size(); i++) {
    //             // From csord__Order__c WHERE csord__Order__c IN : listAlltheRelatedRecord
    //             fields = string.valueof(mdtConstantMetadataUtilityList[i].Query_Fields_Names__c).Split(',');
    //             id objId = mp.get(mdtConstantMetadataUtilityList[i].Value__c);
    //             listAlltheRelatedRecord =  Database.query(' SELECT ' + String.join(fields, ',')
    //                                                         + ' FROM ' + mdtConstantMetadataUtilityList[i].Value__c
    //                                                         + ' WHERE Id = :objId');
    //             listAlltheRelatedRecordAll.addAll(listAlltheRelatedRecord);
    //             system.debug('Coms_CorrelationIdGeneration :: sperateSubscriptionData found 2 listAlltheRelatedRecord  ---> ' + listAlltheRelatedRecord);
    //     }
    //     return listAlltheRelatedRecordAll;
    // }
    
    /**
    * @description : get subscription Correlation id.
    * @author Rohit Pal | 08-12-2021 
    * @param setSubscriptionId 
    * @return Map<id, csord__Subscription__c> 
    **/
    public static Map<id,csord__Subscription__c> getSubscriptions(set<id> setOrderRecordId){
        List<csord__Subscription__c> listcsordSubscription = new List<csord__Subscription__c>();
        SObjectType sobType =  csord__Subscription__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('csord__Subscription__c');
        listcsordSubscription = Database.query(' SELECT ' + String.join(fields, ',')
                                                + ' FROM ' + sobType
                                                + ' WHERE  csord__Order__c =: setOrderRecordId ORDER BY csordtelcoa__Subscription_Number__c ASC');
        system.debug('Coms_CorrelationIdGeneration :: getSubscriptions found listcsordSubscription---> ' + listcsordSubscription);
        return new Map<id,csord__Subscription__c>(listcsordSubscription);
    }

    /**
    * @description 
    * @author Rohit Pal | 09-28-2021 
    * @param setSubscriptions 
    * @return Map<id, csord__Subscription__c> 
    **/
    public static Map<id,csord__Subscription__c> getSpecificSubscriptions(set<id> setSubscriptions){
        List<csord__Subscription__c> listcsordSubscription = new List<csord__Subscription__c>();
        SObjectType sobType =  csord__Subscription__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('csord__Subscription__c');
        listcsordSubscription = Database.query(' SELECT ' + String.join(fields, ',')
                                                + ' FROM ' + sobType
                                                + ' WHERE  Id =: setSubscriptions ORDER BY csordtelcoa__Subscription_Number__c ASC');
        system.debug('Coms_CorrelationIdGeneration :: getSubscriptions found listcsordSubscription---> ' + listcsordSubscription);
        return new Map<id,csord__Subscription__c>(listcsordSubscription);
    }

    /**
    * @description : get services obect Correlation id.
    * @author Rohit Pal | 08-12-2021 
    * @param setServicesId 
    * @return Map<Id, csord__Service__c> 
    **/
    public static Map<Id,csord__Service__c> getCSordServices(set<id> setOrderRecordId){
        List<csord__Service__c> listcsordService = new List<csord__Service__c>();
        SObjectType sobType =  csord__Service__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('csord__Service__c');
        listcsordService = Database.query(' SELECT ' + String.join(fields, ',')
                                            + ' FROM ' + sobType
                                            + ' WHERE  csord__Order__c =: setOrderRecordId ORDER BY csordtelcoa__Service_Number__c ASC');
        system.debug('Coms_CorrelationIdGeneration :: getCSordServices found listcsordService---> ' + listcsordService);
        return new Map<Id,csord__Service__c>(listcsordService);
    }

    
    /**
    * @description 
    * @author Rohit Pal | 09-09-2021 
    * @param setOrderRecordId 
    * @return Map<Id, csord__Service__c> 
    **/
    public static Map<Id,csord__Service__c> getSpecificCSordServices(set<id> setOrderRecordId){
        List<csord__Service__c> listcsordService = new List<csord__Service__c>();
        SObjectType sobType =  csord__Service__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('csord__Service__c');
        listcsordService = Database.query(' SELECT ' + String.join(fields, ',')
                                            + ' FROM ' + sobType
                                            + ' WHERE  Id =: setOrderRecordId ORDER BY csordtelcoa__Service_Number__c ASC');
        system.debug('Coms_CorrelationIdGeneration :: getCSordServices found listcsordService---> ' + listcsordService);
        return new Map<Id,csord__Service__c>(listcsordService);
    }

    /**
    * @description : get Technical object Correlation id.
    * @author Rohit Pal | 08-18-2021 
    * @param setServices 
    * @return Map<Id, Orchestration_Technical__c> 
    **/
    public static Map<Id,Orchestration_Technical__c> getOrchestrationTechnicals(set<Id> setServices){
        List<Orchestration_Technical__c> listOrchestrationTechnical = new List<Orchestration_Technical__c>();
        SObjectType sobType =  Orchestration_Technical__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Orchestration_Technical__c');
        listOrchestrationTechnical = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Service__c =: setServices');
        system.debug('Coms_CorrelationIdGeneration :: getOrchestrationTechnicals found listOrchestrationTechnical---> ' + listOrchestrationTechnical);

        return new Map<id,Orchestration_Technical__c>(listOrchestrationTechnical);
    }

    /**
    * @description 
    * @author Rohit Pal | 08-30-2021 
    * @param setOrchestrationTechnical 
    * @return Map<id, Technical_Child_Attribute__c> 
    **/
    public static Map<id,Technical_Child_Attribute__c> getTechnicalChildAttribute(set<id> setOrchestrationTechnical){
        List<Technical_Child_Attribute__c> listTechnicalChildAttribute = new List<Technical_Child_Attribute__c>();
        SObjectType sobType =  Technical_Child_Attribute__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Technical_Child_Attribute__c');
        listTechnicalChildAttribute = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Orchestration_Technical__c =: setOrchestrationTechnical ORDER BY Name ASC');
        system.debug('Coms_CorrelationIdGeneration :: getTechnicalChildAttribute found listTechnicalChildAttribute---> ' + listTechnicalChildAttribute);
        return new Map<id,Technical_Child_Attribute__c>(listTechnicalChildAttribute);
    }


    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param setServices 
    * @return Map<id, Charge_Line_Item__c> 
    **/
    public static Map<id,Charge_Line_Item__c> getChargeLineItem(set<Id> setServices){
        List<Charge_Line_Item__c> listTechnicalChildAttribute = new List<Charge_Line_Item__c>();
        SObjectType sobType =  Charge_Line_Item__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Charge_Line_Item__c');
        listTechnicalChildAttribute = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  serviceId__c =: setServices');
        system.debug('Coms_CorrelationIdGeneration :: getChargeLineItem :: found listTechnicalChildAttribute---> ' + listTechnicalChildAttribute);
        return new Map<id,Charge_Line_Item__c>(listTechnicalChildAttribute);
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param setChargeLineItem 
    * @return Map<id, Price_Schedule_Line_Item__c> 
    **/
    public static Map<id,Price_Schedule_Line_Item__c> getPriceScheduleLineItem(set<Id> setChargeLineItem){
        List<Price_Schedule_Line_Item__c> listPriceScheduleLineItem = new List<Price_Schedule_Line_Item__c>();
        SObjectType sobType =  Price_Schedule_Line_Item__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Price_Schedule_Line_Item__c');
       /* listPriceScheduleLineItem = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Charge_Line_Item__c =: setChargeLineItem');*/
        listPriceScheduleLineItem = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  chargeInstance__c =: setChargeLineItem');
        system.debug('Coms_CorrelationIdGeneration :: getPriceScheduleLineItem :: found listPriceScheduleLineItem---> ' + listPriceScheduleLineItem);
        return new Map<id,Price_Schedule_Line_Item__c>(listPriceScheduleLineItem);
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param setChargeLineItem 
    * @return Map<id, Discount_Line_Item__c> 
    **/
    public static Map<id,Discount_Line_Item__c> getDiscountLineItem(set<Id> setChargeLineItem){
        List<Discount_Line_Item__c> listDiscountLineItem = new List<Discount_Line_Item__c>();
        SObjectType sobType =  Discount_Line_Item__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Discount_Line_Item__c');
       /* listDiscountLineItem = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Charge_Line_Item__c =: setChargeLineItem');*/
        listDiscountLineItem = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  chargeInstance__c =: setChargeLineItem');
        system.debug('Coms_CorrelationIdGeneration :: getDiscountLineItem :: found listDiscountLineItem---> ' + listDiscountLineItem);
        return new Map<id,Discount_Line_Item__c>(listDiscountLineItem);
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021
    * @param setChargeLineItem 
    * @return Map<id, Number__c> 
    **/
    public static Map<id,Number__c> getNumber(set<string> setSubscriptionNumber){
        List<Number__c> listNumber = new List<Number__c>();
        SObjectType sobType =  Number__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Number__c');
        listNumber = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Subscription_number__c =: setSubscriptionNumber');
        system.debug('Coms_CorrelationIdGeneration :: getNumber :: found listNumber---> ' + listNumber);
        return new Map<id,Number__c>(listNumber);
    }

 
    /**
    * @description 
    * @author Rohit Pal | 10-12-2021 
    * @param setPriceScheduleLineItem 
    * @return Map<id, Price_Schedule_Discount_Association__c> 
    **/
    public static Map<id,Price_Schedule_Discount_Association__c> getPriceScheduleDiscountAssociation(set<id> setPriceScheduleLineItem){
        List<Price_Schedule_Discount_Association__c> listPriceScheduleDiscountAssociation = new List<Price_Schedule_Discount_Association__c>();
        SObjectType sobType =  Price_Schedule_Discount_Association__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Price_Schedule_Discount_Association__c');
        listPriceScheduleDiscountAssociation = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  priceScheduleInstance__c =: setPriceScheduleLineItem');
        system.debug('Coms_CorrelationIdGeneration :: getPriceScheduleDiscountAssociation :: found listPriceScheduleDiscountAssociation---> ' + listPriceScheduleDiscountAssociation);
        return new Map<id,Price_Schedule_Discount_Association__c>(listPriceScheduleDiscountAssociation);
    }

    /**
    * @description 
    * @author Rohit Pal | 10-12-2021 
    * @param setPriceScheduleLineItem 
    * @return Map<id, Tier_Line_Item__c> 
    **/
    public static Map<id,Tier_Line_Item__c> getTierLineItem(set<id> setPriceScheduleLineItem){
        List<Tier_Line_Item__c> listTierLineItem = new List<Tier_Line_Item__c>();
        SObjectType sobType =  Tier_Line_Item__c.SObjectType;
        List<string> fields = Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('Tier_Line_Item__c');
        listTierLineItem = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  PSLIInstance__c =: setPriceScheduleLineItem');
        system.debug('Coms_CorrelationIdGeneration :: getTierLineItem :: found listTierLineItem---> ' + listTierLineItem);
        return new Map<id,Tier_Line_Item__c>(listTierLineItem);
    }
}