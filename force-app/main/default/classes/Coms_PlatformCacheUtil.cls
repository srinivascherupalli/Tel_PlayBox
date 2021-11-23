/*************************************************************************************************************
 * @name            Coms_PlatfornCacheUtli
 * @author          BLR\rohit.pal <rohit.pal@crmit.com>
 * @created         06 / 08 / 2021
 * @description     This Class is used to insert the Order orchestration record data to platfrom cache.
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2021-08-06      BLR\rohit.pal           Changes desription
 *
**************************************************************************************************************/
public with sharing class Coms_PlatformCacheUtil {

    public static final string methodName = Coms_PlatformConstants.STRING_ADDSESSIONDATA;

    /**
    * @description : Common method to create the session 
    * @author Rohit Pal | 08-06-2021 
    * @param correlationId 
    * @param methodName 
    * @param flow 
    * @return Boolean 
    **/
    public static Boolean createSession(set<String> correlationId, Map<String, Object> flow) {
        boolean boolIsSessionCreated = OC_SessionPayloadValidation.createSessionOrderOrchestration(correlationId, methodName, flow);
        System.debug('boolIsSessionCreated ---> ' + boolIsSessionCreated);
        return boolIsSessionCreated;
    }

    /**
    * @description : Check before inserting any data to platform cache if Session exist or not.
    * @author Rohit Pal | 08-06-2021 
    * @param correlationId 
    * @return Boolean 
    **/
    public static Boolean sessionExists(string correlationId) {        
        boolean boolIsSessionExists = OC_SessionPayloadValidation.sessionExistsOrder(correlationId);
        System.debug('boolIsSessionExists ---> ' + boolIsSessionExists);
        return boolIsSessionExists;
    }

    /**
    * @description : insert / update the platform cache data using this method
    * @author Rohit Pal | 08-06-2021
    * @param correlationId 
    * @param methodName 
    * @param values 
    * @return Boolean 
    **/
    public static Boolean addSessionData(set<string> correlationId, Map<String, object> values) {
        boolean boolAddSessionData = OC_SessionPayloadValidation.addSessionDataOrder(correlationId, methodName, values);
        System.debug('boolAddSessionData ---> ' + boolAddSessionData);
        return boolAddSessionData;
    }

    /**
    * @description : get the data from the platform cache for order orchestration
    * @author Rohit Pal | 08-06-2021 
    * @param correlationId 
    * @param methodName 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getSessionData(set<string> setCorrelationId) {
        Map<String, Object> mapGetSessionData = OC_SessionPayloadValidation.getSessionDataOrder(setCorrelationId, methodName);
        System.debug('Coms_PlatfornCacheUtli ::getSessionData found  mapGetSessionData ---> ' + mapGetSessionData);
        return mapGetSessionData;
    }
    /**
    * @description : Single method to insert order orchestration records to platform cache (Order , service , subscriptions).
    * @author Rohit Pal | 08-13-2021 
    * @param idOrderRecordId 
    **/
    public static void insertOrderSubscriptionAndServicesToCache(id idOrderRecordId , boolean isOnlyOrder){
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnOrderSubscriptionAndServices(new set<id>{idOrderRecordId} , isOnlyOrder,true);
        insertSobjectsToPlatformCache(listObject);
    }

    /**
    * @description : Insert all the subscriptions related to specific order to cache.
    * @author Rohit Pal | 08-13-2021 
    * @param idOrderRecordId
    **/
    public static void insertSubscriptionToCache(id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId} ,true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnSubscriptions(mapOrders ,true);
        insertSobjectsToPlatformCache(listObject);
    }

    /**
    * @description 
    * @author Rohit Pal | 11-16-2021 
    * @param idOrderRecordId 
    **/
    public static void insertNumberToCache(id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId} ,true);
        Map<id,csord__Subscription__c> mapSubscription = Coms_CorrelationIdGeneration.getSubscriptionWithCorrelationid(mapOrders ,true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnNumber(mapSubscription, true);
        insertSobjectsToPlatformCache(listObject);
    }
    /**
    * @description : Insert all the services related to specific order to cache.
    * @author Rohit Pal | 08-13-2021 
    * @param idOrderRecordId 
    **/
    public static void insertServicesToCache(id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnServices(mapOrders,true);
        insertSobjectsToPlatformCache(listObject);
    }

    /**
    * @description : Insert OrchestrationTechnical object To Cache.
    * @author Rohit Pal | 08-16-2021 
    * @param idOrderRecordId 
    **/
    public static void insertOrchestrationTechnicalToCache(set<id> setServiceId , id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},true);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateOrchestrationTechnicals(mapServices,true);
        System.debug('Coms_CorrelationIdGeneration :: insertOrchestrationTechnicalToCache :: Found listObject ---> ' + listObject);
        insertSobjectsToPlatformCache(listObject);
    }

    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param idOrderRecordId 
    **/
    public static void insertChargeLineItemsToCache(id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},true);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnChargeLineItem(mapServices,true);
        insertSobjectsToPlatformCache(listObject);
    }
    
    /**
    * @description 
    * @author Rohit Pal | 09-07-2021 
    * @param idOrderRecordId 
    **/
    public static void insertPriceScheduleLineItemToCache(id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},true);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,true);
        Map<Id, Charge_Line_Item__c> mapChargeLineItem =Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnPriceScheduleLineItem(mapChargeLineItem,true);
        insertSobjectsToPlatformCache(listObject);
    }

    /**
    * @description 
    * @author Rohit Pal | 11-16-2021 
    * @param idOrderRecordId 
    **/
    public static void insertPriceScheduleDiscountAssociationToCache(id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},true);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,true);
        Map<Id, Charge_Line_Item__c> mapChargeLineItem =Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,true);
        Map<Id, Price_Schedule_Line_Item__c> mapPriceScheduleLineItem = Coms_CorrelationIdGeneration.getPriceScheduleLineItemWithCorrelationid(mapChargeLineItem , true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnPriceScheduleDiscountAssociation(mapPriceScheduleLineItem,true);
        insertSobjectsToPlatformCache(listObject);
    }

    /**
    * @description 
    * @author Rohit Pal | 11-16-2021 
    * @param idOrderRecordId 
    **/
    public static void insertTierLineItemToCache(id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},true);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,true);
        Map<Id, Charge_Line_Item__c> mapChargeLineItem =Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,true);
        Map<Id, Price_Schedule_Line_Item__c> mapPriceScheduleLineItem = Coms_CorrelationIdGeneration.getPriceScheduleLineItemWithCorrelationid(mapChargeLineItem , true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnTierLineItem(mapPriceScheduleLineItem,true);
        insertSobjectsToPlatformCache(listObject);
    }

    /**
    * @description 
    * @author Rohit Pal | 09-08-2021 
    * @param idOrderRecordId 
    **/
    public static void insertDiscountLineItemToCache(id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},true);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,true);
        Map<Id, Charge_Line_Item__c> mapChargeLineItem =Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnDiscountLineItem(mapChargeLineItem,true);
        insertSobjectsToPlatformCache(listObject);
    }

    /**
    * @description 
    * @author Rohit Pal | 08-26-2021 
    * @param setOrchestrationTechnical 
    **/
    public static void insertTechnicalChildAttribute(set<id> setOrchestrationTechnical , id idOrderRecordId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},true);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,true);
        Map<id,Orchestration_Technical__c> mapOrchestrationTechnical = Coms_CorrelationIdGeneration.getOrchestrationTechnicalsWithCorrelationid(mapServices,true);
        List<sobject> listObject = Coms_CorrelationIdGeneration.updateCorrelationIdOnTechnicalChildAttribute(mapOrchestrationTechnical,true);
        insertSobjectsToPlatformCache(listObject);
    }


    /**
    * @description 
    * @author Rohit Pal | 08-26-2021 
    * @param mapServicesAttachments 
    **/
    public static void insertServicesAndOrchestrationTechnicalToCache( Map<id,csord__Service__c> mapServicesAttachments){
        System.debug('Coms_PlatfornCacheUtli :: getCacheRecordInformation :: found setServiceIds ---> ' + mapServicesAttachments);
        set<id> setOrderId = new set<id>();
        List<sobject> listObject = new List<sobject>();
        if(!mapServicesAttachments.isEmpty()){
            for(csord__Service__c iterator : mapServicesAttachments.values()){
                setOrderId.add(iterator.csord__Order__c);
            }
            Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderId,true);
            System.debug('Coms_PlatfornCacheUtli :: getCacheRecordInformation :: found mapOrders ---> ' + mapOrders);
            Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,true);
            System.debug('Coms_PlatfornCacheUtli :: getCacheRecordInformation :: found mapServices ---> ' + mapServices);
            listObject.addAll(new List<sobject>(Coms_CorrelationIdGeneration.updateCorrelationIdOnServices(mapOrders,true)));
            Map<id,Orchestration_Technical__c> mapOrchestrationTechnical = Coms_CorrelationIdGeneration.getOrchestrationTechnicalsWithCorrelationid(mapServices,true);
            System.debug('Coms_PlatfornCacheUtli :: getCacheRecordInformation :: found mapOrchestrationTechnical ---> ' + mapOrchestrationTechnical);
            listObject.addAll(new List<sobject>(Coms_CorrelationIdGeneration.updateCorrelationIdOnTechnicalChildAttribute(mapOrchestrationTechnical,true)));
            insertSobjectsToPlatformCache(listObject);
        }
    }

    /**
    * @description : 
    * @author Rohit Pal | 08-28-2021 
    * @param setCorrelationId 
    * @param sObject 
    **/
    // coms_Step_PE
    public static void insertSobjectsToPlatformCache(list<sobject> listSObject){
        Map<string, Object> mapCorrelationSobject = new Map<string, Object>();
        Set<string> setSessionExistsData = new Set<string>();
        Set<string> setNewSessionData = new Set<string>();
        Map<string, Object> mapNewSession = new Map<string, Object>();
        Map<string, Object> mapNameSessionExists = new Map<string, Object>();
        if(!listSObject.isEmpty()){
            for(sobject iterator : listSObject){
                System.debug('Coms_PlatfornCacheUtli :: insertSobjectsToPlatformCache :: found iterator ---> ' + iterator);
                    if(sessionExists((String) iterator.get('CorrelationId__c'))){
                        mapNameSessionExists.put((String) iterator.get('CorrelationId__c') , iterator);
                        setSessionExistsData.add((String) iterator.get('CorrelationId__c'));
                    }else if(!sessionExists((String) iterator.get('CorrelationId__c'))){
                        setNewSessionData.add((String) iterator.get('CorrelationId__c'));
                        mapNewSession.put((String) iterator.get('CorrelationId__c') , iterator);
                    }
                    System.debug('Coms_PlatfornCacheUtli :: insertSobjectsToPlatformCache :: found setSessionExistsData ---> ' + setSessionExistsData);
                    System.debug('Coms_PlatfornCacheUtli :: insertSobjectsToPlatformCache :: found setNewSessionData ---> ' + setNewSessionData);
            }
            if(!setSessionExistsData.isEmpty()){
                System.debug('Coms_PlatfornCacheUtli :: insertSobjectsToPlatformCache :: found mapNameSessionExists ---> ' + mapNameSessionExists);
                addSessionData(setSessionExistsData , mapNameSessionExists);
            }
            if(!setNewSessionData.isEmpty()){
                createSession(setNewSessionData,mapNewSession);
                addSessionData(setNewSessionData , mapNewSession);
                System.debug('Coms_PlatfornCacheUtli :: insertSobjectsToPlatformCache :: found mapNewSession ---> ' + mapNewSession);
            }
        }
    }

    /**
    * @description : retrive the data from the patform cache with the unqiue correlation Id.
    * @author Rohit Pal | 08-09-2021 
    * @param correlationId  
    * @param strRecordId 
    * @return Map<Id, Orchestration_Technical__c> 
    **/
    public static List<sobject> getCacheRecordInformation(string idRecord , string strSobjectName){
        Map<string, Object> mapObject = new Map<string, Object>();
        object objNewInstance;
        List<sobject> listSobjectType = new List<sobject>();
        if(string.isNotBlank(idRecord)){
            Map<String, Object> mapGetSessionData =getSessionData(new set<string>{idRecord});
            System.debug('Coms_PlatfornCacheUtli :: getCacheRecordInformation :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                objNewInstance = string.valueof(JSON.serialize(mapGetSessionData.get(idRecord)));
                System.debug('Coms_PlatfornCacheUtli :: getCacheRecordInformation :: found objNewInstance ---> ' + objNewInstance);
                if(objNewInstance instanceof SObject){
                    System.debug('The Value of return is object Type');
                }else{
                    listSobjectType.addAll(parseCacheData(mapGetSessionData , strSobjectName));
                }
            }
        }
        return listSobjectType;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-28-2021 
    * @param setOrderIds 
    * @return list<sobject> 
    **/
    public static list<sobject> getOrderFromCache(set<id> setOrderIds){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderIds,false);
        Map<string , csord__Order__c> mapOrdersWithCorrelation = new Map<string , csord__Order__c>();
        Map<id , csord__Order__c> mapMissingCache = new Map<id , csord__Order__c>();
        set<string> setCorrelationId = new Set<string>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Order__c iterator : mapOrders.values()){
            if(iterator.CorrelationId__c != null && setOrderIds.contains(iterator.id)){
                setCorrelationId.add(iterator.CorrelationId__c);
                mapOrdersWithCorrelation.put(iterator.CorrelationId__c , iterator);
            }
        }
        System.debug('Coms_PlatfornCacheUtli :: getOrderFromCache :: found setCorrelationId ---> ' + setCorrelationId);
        System.debug('Coms_PlatfornCacheUtli :: getOrderFromCache :: found mapOrders ---> ' + mapOrders);
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapOrdersWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapOrdersWithCorrelation.get(ss).id , mapOrdersWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getOrderFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'csord__Order__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keySet() , 'csord__Order__c');
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getOrderFromCache :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-28-2021 
    * @param setServiceIds 
    * @return list<sobject> 
    **/
    public static list<sobject> getNumberListFromCache(set<id> setSubscriptionIds){
        id idOrderRecordId;
        List<sobject> listSobject = new List<sobject>();
        set<string> setCorrelationId = new Set<string>();
        Map<string , Number__c> mapNumbersWithCorrelation = new Map<string , Number__c>();
        Map<id , Number__c> mapMissingCache = new Map<id , Number__c>();
        Map<string, csord__Subscription__c> mapSubscriptionsNumber = new Map<string, csord__Subscription__c>();
        Map<id, csord__Subscription__c> mapCurrentSubsciprtions = Coms_CorrelationIdGeneration.getSpecificSubscriptions(setSubscriptionIds);
        System.debug('Coms_PlatfornCacheUtli :: getListofServicesFromCache :: found mapCurrentSubsciprtions ---> ' + mapCurrentSubsciprtions);
        for(csord__Subscription__c iterator : mapCurrentSubsciprtions.values()){
            idOrderRecordId =iterator.csord__Order__c;
            break;
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},false);
        Map<id,csord__Subscription__c> mapSubscription = Coms_CorrelationIdGeneration.getSubscriptionWithCorrelationid(mapOrders , false);
        for(csord__Subscription__c iterator : mapSubscription.values()){
            mapSubscriptionsNumber.put(iterator.csordtelcoa__Subscription_Number__c , iterator);
        }
        Map<Id, Number__c> mapNumber = Coms_CorrelationIdGeneration.getNumberWithCorrelationid(mapSubscription,false);
        for(Number__c iterator : mapNumber.values()){
            if(iterator.CorrelationId__c != null && mapSubscriptionsNumber.containsKey(iterator.Subscription_number__c)){
                setCorrelationId.add(iterator.CorrelationId__c);
                mapNumbersWithCorrelation.put(iterator.CorrelationId__c , iterator);
            }
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapNumbersWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapNumbersWithCorrelation.get(ss).id , mapNumbersWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getServicesFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'Number__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keySet() , 'Number__c');
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getServicesFromCache :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-31-2021 
    * @param idOrderRecordId 
    * @return list<sobject>
    **/
    public static list<sobject> getServicesFromCache(id idOrderRecordId , set<id> setServices){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        Map<string , csord__Service__c> mapServicesWithCorrelation = new Map<string , csord__Service__c>();
        Map<id , csord__Service__c> mapMissingCache = new Map<id , csord__Service__c>();
        set<string> setCorrelationId = new Set<string>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Service__c iterator : mapServices.values()){
            if(iterator.CorrelationId__c != null && setServices.contains(iterator.id)){
                setCorrelationId.add(iterator.CorrelationId__c);
                mapServicesWithCorrelation.put(iterator.CorrelationId__c , iterator);
            }
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapServicesWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapServicesWithCorrelation.get(ss).id , mapServicesWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getServicesFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'csord__Service__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(setServices , 'csord__Service__c');
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getServicesFromCache :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-09-2021 
    * @param setServices 
    * @return list<sobject> 
    **/
    public static list<sobject> getListofServicesFromCache(set<id> setServices){
        id orderId;
        List<sobject> listSobject = new List<sobject>();
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getSpecificCSordServices(setServices);
        System.debug('Coms_PlatfornCacheUtli :: getListofServicesFromCache :: found mapServices ---> ' + mapServices);
        for(csord__Service__c iterator : mapServices.values()){
            orderId =iterator.csord__Order__c;
            break;
        }
        System.debug('Coms_PlatfornCacheUtli :: getListofServicesFromCache :: found mapServices ---> ' + orderId);
        if(orderId != null && !setServices.isEmpty()){
            listSobject.addAll(getServicesFromCache(orderId , setServices));
        }
        System.debug('Coms_PlatfornCacheUtli :: getListofServicesFromCache :: found listSobject ---> ' + listSobject);
        return listSobject;
    }
    /**
    * @description 
    * @author Rohit Pal | 08-31-2021 
    * @param idOrderRecordId 
    * @return list<sobject> 
    **/
    public static list<sobject> getAllServicesFromCache(set<id> setOrderId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderId,false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        Map<string , csord__Service__c> mapServicesWithCorrelation = new Map<string , csord__Service__c>();
        Map<id , csord__Service__c> mapMissingCache = new Map<id , csord__Service__c>();
        set<string> setCorrelationId = new set<string>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Service__c iterator : mapServices.values()){
            if(iterator.CorrelationId__c != null){
                setCorrelationId.add(iterator.CorrelationId__c);
            }
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapServicesWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapServicesWithCorrelation.get(ss).id , mapServicesWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getAllServicesFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'csord__Service__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'csord__Service__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getAllServicesFromCache :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-02-2021 
    * @param idOrderRecordId 
    * @param setServices 
    * @return list<object> 
    **/
    public static list<sobject> getTechnicalObjectFromCache(id idOrderRecordId , set<id> setServices){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        List<sobject> listSobject = new List<sobject>();
        Map<string , Orchestration_Technical__c> mapOrchestrationTechnicalWithCorrelation = new Map<string , Orchestration_Technical__c>();
        Map<id , Orchestration_Technical__c> mapMissingCacheOrchestrationTechnical = new Map<id , Orchestration_Technical__c>();
        // Map<string , Technical_Child_Attribute__c> mapTechnicalChildWithCorrelation = new Map<string , Technical_Child_Attribute__c>();
        // Map<id , Technical_Child_Attribute__c> mapMissingCacheTechnicalChild = new Map<id , Technical_Child_Attribute__c>();
        for(csord__Service__c iterator : mapServices.values()){
            if(!setServices.contains(iterator.id)){
                mapServices.remove(iterator.Id);
            }
        }
        Map<id,Orchestration_Technical__c> mapOrchestrationTechnical = Coms_CorrelationIdGeneration.getOrchestrationTechnicalsWithCorrelationid(mapServices,false);
        for(Orchestration_Technical__c iterator : mapOrchestrationTechnical.values()){
            setCorrelationId.add(iterator.CorrelationId__c);
            mapOrchestrationTechnicalWithCorrelation.put(iterator.CorrelationId__c , iterator);
        }
        // Map<id,Technical_Child_Attribute__c> mapTechnicalChildAttribute= Coms_CorrelationIdGeneration.getTechnicalChildAttributeWithCorrelationid(mapOrchestrationTechnical,false);
        // for(Technical_Child_Attribute__c iterator : mapTechnicalChildAttribute.values()){
        //     setCorrelationId.add(iterator.CorrelationId__c);
        //     mapTechnicalChildWithCorrelation.put(iterator.CorrelationId__c , iterator);
        // }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapOrchestrationTechnicalWithCorrelation.containsKey(ss)){
                    mapMissingCacheOrchestrationTechnical.put(mapOrchestrationTechnicalWithCorrelation.get(ss).id , mapOrchestrationTechnicalWithCorrelation.get(ss));
                }
                // if(mapGetSessionData.get(ss) == null && mapTechnicalChildWithCorrelation.containsKey(ss)){
                //     mapMissingCacheTechnicalChild.put(mapTechnicalChildWithCorrelation.get(ss).id , mapTechnicalChildWithCorrelation.get(ss));
                // }
            }
            
            System.debug('Coms_PlatfornCacheUtli :: getTechnicalObjectFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData ,'Orchestration_Technical__c'));
            }else if(!mapMissingCacheOrchestrationTechnical.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCacheOrchestrationTechnical.keyset() , 'Orchestration_Technical__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
            // else if(!mapMissingCacheTechnicalChild.isEmpty()){
            //     List<sobject> returnRecord = getRecordFromDataBase(mapMissingCacheTechnicalChild.keyset() , 'Technical_Child_Attribute__c');
            //     listSobject.addAll(returnRecord);
            //     insertSobjectsToPlatformCache(returnRecord);
            // }
            System.debug('Coms_PlatfornCacheUtli :: getTechnicalObjectFromCache :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-02-2021 
    * @param idOrderRecordId 
    * @param setServices 
    * @return list<sobject> 
    **/
    public static list<sobject> getTechnicalChildAttributes(id idOrderRecordId , set<id> setServices){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        List<sobject> listSobject = new List<sobject>();
        Map<string , Orchestration_Technical__c> mapOrchestrationTechnicalWithCorrelation = new Map<string , Orchestration_Technical__c>();
        Map<id , Orchestration_Technical__c> mapMissingCacheOrchestrationTechnical = new Map<id , Orchestration_Technical__c>();
        Map<string , Technical_Child_Attribute__c> mapTechnicalChildWithCorrelation = new Map<string , Technical_Child_Attribute__c>();
        Map<id , Technical_Child_Attribute__c> mapMissingCacheTechnicalChild = new Map<id , Technical_Child_Attribute__c>();
        for(csord__Service__c iterator : mapServices.values()){
            if(!setServices.contains(iterator.id)){
                mapServices.remove(iterator.Id);
            }
        }
        Map<id,Orchestration_Technical__c> mapOrchestrationTechnical = Coms_CorrelationIdGeneration.getOrchestrationTechnicalsWithCorrelationid(mapServices,false);
        Map<id,Technical_Child_Attribute__c> mapTechnicalChildAttribute= Coms_CorrelationIdGeneration.getTechnicalChildAttributeWithCorrelationid(mapOrchestrationTechnical,false);
        for(Technical_Child_Attribute__c iterator : mapTechnicalChildAttribute.values()){
            setCorrelationId.add(iterator.CorrelationId__c);
            mapTechnicalChildWithCorrelation.put(iterator.CorrelationId__c , iterator);
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                // if(mapGetSessionData.get(ss) == null && mapOrchestrationTechnicalWithCorrelation.containsKey(ss)){
                //     mapMissingCacheOrchestrationTechnical.put(mapOrchestrationTechnicalWithCorrelation.get(ss).id , mapOrchestrationTechnicalWithCorrelation.get(ss));
                // }
                if(mapGetSessionData.get(ss) == null && mapTechnicalChildWithCorrelation.containsKey(ss)){
                    mapMissingCacheTechnicalChild.put(mapTechnicalChildWithCorrelation.get(ss).id , mapTechnicalChildWithCorrelation.get(ss));
                }
            }
            
            System.debug('Coms_PlatfornCacheUtli :: getTechnicalObjectFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData ,'Technical_Child_Attribute__c'));
            }
            // else if(!mapMissingCacheOrchestrationTechnical.isEmpty()){
            //     List<sobject> returnRecord = getRecordFromDataBase(mapMissingCacheOrchestrationTechnical.keyset() , 'Orchestration_Technical__c');
            //     listSobject.addAll(returnRecord);
            //     insertSobjectsToPlatformCache(returnRecord);
            // }
            else if(!mapMissingCacheTechnicalChild.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCacheTechnicalChild.keyset() , 'Technical_Child_Attribute__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getTechnicalObjectFromCache :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-09-2021 
    * @param setServices 
    * @return list<object> 
    **/
    public static list<sobject> getListofTechnicalObjectFromCache(set<id> setServices){
        id orderId;
        List<sobject> listSobject = new List<sobject>();
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getSpecificCSordServices(setServices);
        System.debug('Coms_PlatfornCacheUtli :: getListofTechnicalObjectFromCache :: found mapServices ---> ' + mapServices);
        for(csord__Service__c iterator : mapServices.values()){
            if(iterator.csord__Order__c != null){
                orderId =iterator.csord__Order__c;
                break;
            }
        }
        System.debug('Coms_PlatfornCacheUtli :: getListofTechnicalObjectFromCache :: found mapServices ---> ' + orderId);
        if(orderId != null && !setServices.isEmpty()){
            listSobject.addAll(getTechnicalObjectFromCache(orderId , setServices));
        }
        System.debug('Coms_PlatfornCacheUtli :: getListofTechnicalObjectFromCache :: found listSobject ---> ' + listSobject);
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-09-2021 
    * @param setServices 
    * @return list<object> 
    **/
    public static list<sobject> getListOfChargeLineItem(set<id> setSubscription){
        id idOrderRecordId;
        List<sobject> listSobject = new List<sobject>();
        Set<string> setCorrelationId = new Set<string>();
        Map<Id, Charge_Line_Item__c> mapMissingCache = new Map<Id, Charge_Line_Item__c>();
        Map<string, Charge_Line_Item__c> mapChargeLineWithCorrelation = new Map<string, Charge_Line_Item__c>();
        Map<id, csord__Subscription__c> mapSubsciprtions = Coms_CorrelationIdGeneration.getSpecificSubscriptions(setSubscription);
        System.debug('Coms_PlatfornCacheUtli :: getListofTechnicalObjectFromCache :: found mapSubsciprtions ---> ' + mapSubsciprtions);
        for(csord__Subscription__c iterator : mapSubsciprtions.values()){
            if(iterator.csord__Order__c != null){
                idOrderRecordId =iterator.csord__Order__c;
                break;
            }
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},false);
        Map<id,csord__Service__c> mapOrderRelatedServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        for(csord__Service__c iterator : mapOrderRelatedServices.values()){
            if(!mapSubsciprtions.containsKey(iterator.csord__Subscription__c)){
                mapOrderRelatedServices.remove(iterator.id);
            }
        }
        Map<Id, Charge_Line_Item__c> mapChargeLineItem = Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapOrderRelatedServices,false);
        for(Charge_Line_Item__c iterator : mapChargeLineItem.values()){
            setCorrelationId.add(iterator.CorrelationId__c);
            mapChargeLineWithCorrelation.put(iterator.CorrelationId__c ,iterator );
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData = getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapChargeLineWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapChargeLineWithCorrelation.get(ss).id , mapChargeLineWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfChargeLineItem :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'Charge_Line_Item__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'Charge_Line_Item__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
        }
        System.debug('Coms_PlatfornCacheUtli :: getListOfChargeLineItem :: found listSobject ---> ' + listSobject);
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-09-2021 
    * @param setServices 
    * @return list<object> 
    **/
    public static list<sobject> getListOfSubscriptionFromServicesCache(set<id> setServices){
        id idOrderRecordId;
        List<sobject> listSobject = new List<sobject>();
        Set<string> setCorrelationId = new Set<string>();
        Map<Id, csord__Subscription__c> mapMissingCache = new Map<Id, csord__Subscription__c>();
        Map<string, csord__Subscription__c> mapSubscriptionsWithCorrelation = new Map<string, csord__Subscription__c>();
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getSpecificCSordServices(setServices);
        System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromServicesCache :: found mapServices ---> ' + mapServices);
        for(csord__Service__c iterator : mapServices.values()){
            if(iterator.csord__Order__c != null){
                idOrderRecordId =iterator.csord__Order__c;
                break;
            }
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},false);
        Map<id,csord__Subscription__c> mapSubscription = Coms_CorrelationIdGeneration.getSubscriptionWithCorrelationid(mapOrders , false);
        for(csord__Service__c iterator : mapServices.values()){
            if(setServices.contains(iterator.id)){
                setCorrelationId.add(mapSubscription.get(iterator.csord__Subscription__c).CorrelationId__c);
                mapSubscriptionsWithCorrelation.put(mapSubscription.get(iterator.csord__Subscription__c).CorrelationId__c , mapSubscription.get(iterator.csord__Subscription__c));
            }
        }
        System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromServicesCache :: found setCorrelationId ---> ' + setCorrelationId);
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData = getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapSubscriptionsWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapSubscriptionsWithCorrelation.get(ss).id , mapSubscriptionsWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromServicesCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'csord__Subscription__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'csord__Subscription__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
        }
        System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromServicesCache :: found listSobject ---> ' + listSobject);
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-28-2021 
    * @param setServices 
    * @return list<sobject> 
    **/
    public static list<sobject> getListOfSubscriptionFromCache(set<id> setSubscriptions){
        id idOrderRecordId;
        List<sobject> listSobject = new List<sobject>();
        Set<string> setCorrelationId = new Set<string>();
        Map<Id, csord__Subscription__c> mapMissingCache = new Map<Id, csord__Subscription__c>();
        Map<string, csord__Subscription__c> mapSubscriptionsWithCorrelation = new Map<string, csord__Subscription__c>();
        Map<id, csord__Subscription__c> mapSubsciprtions = Coms_CorrelationIdGeneration.getSpecificSubscriptions(setSubscriptions);
        System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromCache :: found mapSubsciprtions ---> ' + mapSubsciprtions);
        for(csord__Subscription__c iterator : mapSubsciprtions.values()){
            if(iterator.csord__Order__c != null){
                idOrderRecordId =iterator.csord__Order__c;
                break;
            }
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},false);
        Map<id,csord__Subscription__c> mapSubscription = Coms_CorrelationIdGeneration.getSubscriptionWithCorrelationid(mapOrders , false);
        for(csord__Subscription__c iterator : mapSubscription.values()){
            if(setSubscriptions.contains(iterator.id)){
                setCorrelationId.add(iterator.CorrelationId__c);
                mapSubscriptionsWithCorrelation.put(iterator.CorrelationId__c , iterator);
            }
        }
        System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromCache :: found setCorrelationId ---> ' + setCorrelationId);
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData = getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapSubscriptionsWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapSubscriptionsWithCorrelation.get(ss).id , mapSubscriptionsWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(mapGetSessionData != null && !mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'csord__Subscription__c'));
            }else if(mapMissingCache!= null && !mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'csord__Subscription__c');
                System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromCache :: found returnRecord ---> ' + returnRecord);
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
        }
        System.debug('Coms_PlatfornCacheUtli :: getListOfSubscriptionFromCache :: found listSobject ---> ' + listSobject);
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-09-2021 
    * @param idOrderRecordId 
    * @param setSubscription 
    * @return list<object> 
    **/

    public static list<sobject> getChargeLineItem(set<id> setSubscription){
        Set<id> setOrderIds = new Set<id>();
        Map<id,csord__Subscription__c>  mapSubscription =  Coms_CorrelationIdGeneration.getSpecificSubscriptions(setSubscription);
        for(csord__Subscription__c iterator : mapSubscription.values()){
            if(iterator.csord__Order__c != null){
                setOrderIds.add(iterator.csord__Order__c);
                break;
            }
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderIds,false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        Map<string, Charge_Line_Item__c> mapChargeLineItemWithCorrelation = new Map<string, Charge_Line_Item__c>();
        Map<Id, Charge_Line_Item__c> mapMissingCache = new Map<Id, Charge_Line_Item__c>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Service__c iterator : mapServices.values()){
            if(!setSubscription.contains(iterator.csord__Subscription__c)){
                mapServices.remove(iterator.Id);
            }
        }
        Map<Id, Charge_Line_Item__c> mapChargeLineItem = Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,false);
        for(Charge_Line_Item__c iterator : mapChargeLineItem.values()){
            setCorrelationId.add(iterator.CorrelationId__c);
            mapChargeLineItemWithCorrelation.put(iterator.CorrelationId__c , iterator);
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapChargeLineItemWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapChargeLineItemWithCorrelation.get(ss).id , mapChargeLineItemWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getChargeLineItem :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'Charge_Line_Item__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'Charge_Line_Item__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getChargeLineItem :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-25-2021 
    * @param idOrderRecordId 
    * @param setServices 
    * @return list<sobject> 
    **/
    public static list<sobject> getPriceScheduleLineItem(set<id> setSubscription){
        Set<id> setOrderIds = new Set<id>();
        Map<id,csord__Subscription__c>  mapSubscription =  Coms_CorrelationIdGeneration.getSpecificSubscriptions(setSubscription);
        for(csord__Subscription__c iterator : mapSubscription.values()){
            if(iterator.csord__Order__c != null){
                setOrderIds.add(iterator.csord__Order__c);
                break;
            }
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderIds,false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        Map<string, Price_Schedule_Line_Item__c> mapPriceSchLineItemWithCorrelation = new Map<string, Price_Schedule_Line_Item__c>();
        Map<Id, Price_Schedule_Line_Item__c> mapMissingCache = new Map<Id, Price_Schedule_Line_Item__c>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Service__c iterator : mapServices.values()){
            if(!setSubscription.contains(iterator.csord__Subscription__c)){
                mapServices.remove(iterator.Id);
            }
        }
        Map<Id, Charge_Line_Item__c> mapChargeLineItem = Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,false);
        Map<Id, Price_Schedule_Line_Item__c> mapPriceScheduleLineItem = Coms_CorrelationIdGeneration.getPriceScheduleLineItemWithCorrelationid(mapChargeLineItem , false);
        for(Price_Schedule_Line_Item__c iterator : mapPriceScheduleLineItem.values()){
            setCorrelationId.add(iterator.CorrelationId__c);
            mapPriceSchLineItemWithCorrelation.put(iterator.CorrelationId__c , iterator);
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapPriceSchLineItemWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapPriceSchLineItemWithCorrelation.get(ss).id , mapPriceSchLineItemWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getPriceScheduleLineItem :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'Price_Schedule_Line_Item__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'Price_Schedule_Line_Item__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getPriceScheduleLineItem :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-25-2021 
    * @param setSubscription 
    * @return list<sobject> 
    **/
    public static list<sobject> getListOfTierLineItem(set<id> setSubscription){
        Set<id> setOrderIds = new Set<id>();
        Map<id,csord__Subscription__c>  mapSubscription =  Coms_CorrelationIdGeneration.getSpecificSubscriptions(setSubscription);
        for(csord__Subscription__c iterator : mapSubscription.values()){
            if(iterator.csord__Order__c != null){
                setOrderIds.add(iterator.csord__Order__c);
                break;
            }
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderIds,false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        Map<string, Tier_Line_Item__c> mapTierLineItemWithCorrelation = new Map<string, Tier_Line_Item__c>();
        Map<Id, Tier_Line_Item__c> mapMissingCache = new Map<Id, Tier_Line_Item__c>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Service__c iterator : mapServices.values()){
            if(!setSubscription.contains(iterator.csord__Subscription__c)){
                mapServices.remove(iterator.Id);
            }
        }
        Map<Id, Charge_Line_Item__c> mapChargeLineItem = Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,false);
        Map<Id, Price_Schedule_Line_Item__c> mapPriceScheduleLineItem = Coms_CorrelationIdGeneration.getPriceScheduleLineItemWithCorrelationid(mapChargeLineItem , false);
        Map<Id, Tier_Line_Item__c> mapTierLineItem = Coms_CorrelationIdGeneration.getTierLineItemWithCorrelationid(mapPriceScheduleLineItem , false);
        for(Tier_Line_Item__c iterator : mapTierLineItem.values()){
            setCorrelationId.add(iterator.CorrelationId__c);
            mapTierLineItemWithCorrelation.put(iterator.CorrelationId__c , iterator);
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapTierLineItemWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapTierLineItemWithCorrelation.get(ss).id , mapTierLineItemWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfTierLineItem :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'Tier_Line_Item__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'Tier_Line_Item__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfTierLineItem :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-25-2021 
    * @param setSubscription 
    * @return list<sobject> 
    **/
    public static list<sobject> getListOfDiscountLineItem(set<id> setSubscription){
        Set<id> setOrderIds = new Set<id>();
        Map<id,csord__Subscription__c>  mapSubscription =  Coms_CorrelationIdGeneration.getSpecificSubscriptions(setSubscription);
        for(csord__Subscription__c iterator : mapSubscription.values()){
            if(iterator.csord__Order__c != null){
                setOrderIds.add(iterator.csord__Order__c);
                break;
            }
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderIds,false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        Map<string, Discount_Line_Item__c> mapDiscountLineItemWithCorrelation = new Map<string, Discount_Line_Item__c>();
        Map<Id, Discount_Line_Item__c> mapMissingCache = new Map<Id, Discount_Line_Item__c>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Service__c iterator : mapServices.values()){
            if(!setSubscription.contains(iterator.csord__Subscription__c)){
                mapServices.remove(iterator.Id);
            }
        }
        Map<Id, Charge_Line_Item__c> mapChargeLineItem = Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,false);
        Map<Id, Discount_Line_Item__c> mapDiscountLineItem = Coms_CorrelationIdGeneration.getDiscountLineItemWithCorrelationid(mapChargeLineItem,false);
        for(Discount_Line_Item__c iterator : mapDiscountLineItem.values()){
            setCorrelationId.add(iterator.CorrelationId__c);
            mapDiscountLineItemWithCorrelation.put(iterator.CorrelationId__c , iterator);
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapDiscountLineItemWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapDiscountLineItemWithCorrelation.get(ss).id , mapDiscountLineItemWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfDiscountLineItem :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'Discount_Line_Item__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'Discount_Line_Item__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfDiscountLineItem :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-25-2021 
    * @param setSubscription 
    * @return list<sobject> 
    **/
    public static list<sobject> getListOfPriceScheduleDiscountAssocItem(set<id> setSubscription){
        Set<id> setOrderIds = new Set<id>();
        Map<id,csord__Subscription__c>  mapSubscription =  Coms_CorrelationIdGeneration.getSpecificSubscriptions(setSubscription);
        for(csord__Subscription__c iterator : mapSubscription.values()){
            if(iterator.csord__Order__c != null){
                setOrderIds.add(iterator.csord__Order__c);
                break;
            }
        }
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderIds,false);
        Map<id,csord__Service__c> mapServices = Coms_CorrelationIdGeneration.getServiceWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        Map<string, Price_Schedule_Discount_Association__c> mapPriceScheduleDiscountAssociationWithCorrelation = new Map<string, Price_Schedule_Discount_Association__c>();
        Map<Id, Price_Schedule_Discount_Association__c> mapMissingCache = new Map<Id, Price_Schedule_Discount_Association__c>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Service__c iterator : mapServices.values()){
            if(!setSubscription.contains(iterator.csord__Subscription__c)){
                mapServices.remove(iterator.Id);
            }
        }
        Map<Id, Charge_Line_Item__c> mapChargeLineItem = Coms_CorrelationIdGeneration.getChargeLineItemWithCorrelationid(mapServices,false);
        Map<Id, Price_Schedule_Line_Item__c> mapPriceScheduleLineItem = Coms_CorrelationIdGeneration.getPriceScheduleLineItemWithCorrelationid(mapChargeLineItem , false);
        Map<Id, Price_Schedule_Discount_Association__c> mapPriceScheduleDiscountAssociation = Coms_CorrelationIdGeneration.getPriceScheduleDiscountAssociationWithCorrelationid(mapPriceScheduleLineItem , false);
        for(Price_Schedule_Discount_Association__c iterator : mapPriceScheduleDiscountAssociation.values()){
            setCorrelationId.add(iterator.CorrelationId__c);
            mapPriceScheduleDiscountAssociationWithCorrelation.put(iterator.CorrelationId__c , iterator);
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            for(string ss : mapGetSessionData.keySet()){
                if(mapGetSessionData.get(ss) == null && mapPriceScheduleDiscountAssociationWithCorrelation.containsKey(ss)){
                    mapMissingCache.put(mapPriceScheduleDiscountAssociationWithCorrelation.get(ss).id , mapPriceScheduleDiscountAssociationWithCorrelation.get(ss));
                }
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfPriceScheduleDiscountAssocItem :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'Price_Schedule_Discount_Association__c'));
            }else if(!mapMissingCache.isEmpty()){
                List<sobject> returnRecord = getRecordFromDataBase(mapMissingCache.keyset() , 'Price_Schedule_Discount_Association__c');
                listSobject.addAll(returnRecord);
                insertSobjectsToPlatformCache(returnRecord);
            }
            System.debug('Coms_PlatfornCacheUtli :: getListOfPriceScheduleDiscountAssocItem :: found listSobject ---> ' + listSobject);
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-01-2021 
    * @param idOrderRecordId 
    * @param setSubscriptions 
    * @return list<object> 
    **/
    
    public static list<sobject> getSubscriptionFromCache(id idOrderRecordId , set<id> setSubscriptions){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(new set<id> {idOrderRecordId},false);
        Map<id,csord__Subscription__c> mapSubscription = Coms_CorrelationIdGeneration.getSubscriptionWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Subscription__c iterator : mapSubscription.values()){
            if(iterator.CorrelationId__c != null && setSubscriptions.contains(iterator.id)){
                setCorrelationId.add(iterator.CorrelationId__c);
            }
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            System.debug('Coms_PlatfornCacheUtli :: getServicesFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'csord__Subscription__c'));
            }
        }
        return listSobject;
    }
    /**
    * @description 
    * @author Rohit Pal | 09-01-2021 
    * @param idOrderRecordId 
    * @param setSubscriptions 
    * @return list<object> 
    **/
    public static list<sobject> getAllSubscriptionFromCache(set<id> setOrderId){
        Map<id,csord__Order__c> mapOrders = Coms_CorrelationIdGeneration.getOrderWithCorrelationid(setOrderId,false);
        Map<id,csord__Subscription__c> mapSubscription = Coms_CorrelationIdGeneration.getSubscriptionWithCorrelationid(mapOrders,false);
        set<string> setCorrelationId = new Set<string>();
        List<sobject> listSobject = new List<sobject>();
        for(csord__Subscription__c iterator : mapSubscription.values()){
            if(iterator.CorrelationId__c != null){
                setCorrelationId.add(iterator.CorrelationId__c);
            }
        }
        if(!setCorrelationId.isEmpty()){
            Map<String, Object> mapGetSessionData =getSessionData(setCorrelationId);
            System.debug('Coms_PlatfornCacheUtli :: getServicesFromCache :: found mapGetSessionData ---> ' + mapGetSessionData);
            if(!mapGetSessionData.isEmpty()){
                listSobject.AddAll(parseCacheData(mapGetSessionData,'csord__Subscription__c'));
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-06-2021 
    * @param mapGetSessionData 
    **/
    public static list<sobject> parseCacheData(Map<String, Object> mapGetSessionData , string strObjectName){
        System.debug('Coms_PlatfornCacheUtli :: parseCacheData :: found mapGetSessionData ---> ' + mapGetSessionData);
        list<sobject> listSobject = new list<sobject>();
        if(!mapGetSessionData.isEmpty()){
            // Map<String, Object> mapAcc = new Map<String, Object>();
            // for(string correlationId : mapGetSessionData.keySet()){
            //     String stringAcc = string.valueof(mapGetSessionData.get(correlationId));
            //     mapAcc.putAll((Map<String, Object>)JSON.deserializeUntyped(stringAcc));
            // }
            // if(!mapAcc.isEmpty()){
            //     mapAcc.remove('attributes');
            // }
            // for(object itreator : mapAcc.values()){
            //     listSobject.add(itreator);
            // }
            switch on strObjectName {
                when 'csord__Order__c' {
                    listSobject.addAll(Coms_SobjectUtil.getObjectSobject(mapGetSessionData));
                }	
                when 'csord__Subscription__c' {
                    listSobject.addAll(Coms_SobjectUtil.getSubscriptionSobject(mapGetSessionData));
                }
                when 'csord__Service__c' {
                    listSobject.addAll(Coms_SobjectUtil.getServiceOject(mapGetSessionData));
                }
                when 'Orchestration_Technical__c' {
                    listSobject.addAll(Coms_SobjectUtil.getOrchestrationTechnicalOject(mapGetSessionData));
                }
                when 'Technical_Child_Attribute__c' {
                    listSobject.addAll(Coms_SobjectUtil.getTechnicalChildAttributeOject(mapGetSessionData));
                }
                when 'Billing_Account__c' {
                    listSobject.addAll(Coms_SobjectUtil.getBillingAccountOject(mapGetSessionData));
                }
                when 'Charge_Line_Item__c' {
                    listSobject.addAll(Coms_SobjectUtil.getChargeLineItemOject(mapGetSessionData));
                }
                when 'Discount_Line_Item__c' {
                    listSobject.addAll(Coms_SobjectUtil.getDiscountLineItemOject(mapGetSessionData));
                }
                when 'Price_Schedule_Line_Item__c' {
                    listSobject.addAll(Coms_SobjectUtil.getPriceScheduleLineItemOject(mapGetSessionData));
                }
                when 'Price_Schedule_Discount_Association__c' {
                    listSobject.addAll(Coms_SobjectUtil.getPriceScheduleDiscountAssocItem(mapGetSessionData));
                }
                when 'Tier_Line_Item__c' {
                    listSobject.addAll(Coms_SobjectUtil.getTierLineItem(mapGetSessionData));
                }
                when 'Number__c' {
                    listSobject.addAll(Coms_SobjectUtil.getNumberOject(mapGetSessionData));
                }
            }
        }
        return listSobject;
    }
    
    /**
    * @description : Retieve records from different objects involve in Order orchestration process.
    * @author Rohit Pal | 08-10-2021 
    * @param strRecordId 
    * @return sobject 
    **/
    public static List<sobject> getRecordFromDataBase(set<id> setRecordId  , string sObjName){
        System.debug('Coms_PlatfornCacheUtli :: getRecordFromDataBase :: found objSobject ---> setRecordId' + setRecordId + 'sObjName --> ' + sObjName);
        List<sobject> listSobject;
        SObjectType sobType;
        List<string> fields;
        if(!setRecordId.isEmpty()){
            switch on sObjName {
                when 'csord__Order__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_CSORD_ORDER_API);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_CSORD_ORDER_API , fields , setRecordId);
                }when 'csord__Subscription__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_CSORD_SUBSCRIPTION_API);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_CSORD_SUBSCRIPTION_API , fields , setRecordId);
                }
                when 'csord__Service__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_CSORD_SUBSCRIPTION_API);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_CSORD_SUBSCRIPTION_API , fields , setRecordId);
                }when 'Orchestration_Technical__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_ORCHESTRATION_TECHNICAL);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_ORCHESTRATION_TECHNICAL , fields , setRecordId);
                }when 'Technical_Child_Attribute__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_TECHNICAL_CHILD_ATTRIBUTE);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_TECHNICAL_CHILD_ATTRIBUTE , fields , setRecordId);
                }
                when 'Charge_Line_Item__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_CHARGE_LINE_ITEM_API);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_CHARGE_LINE_ITEM_API , fields , setRecordId);
                }
                when 'Price_Schedule_Line_Item__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_PRICE_SCHEDULE_LINE_ITEM_API);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_PRICE_SCHEDULE_LINE_ITEM_API , fields , setRecordId);
                }
                when 'Price_Schedule_Discount_Association__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_PRICE_SCHEDULE_DISCOUNT_ASSOCIATION_API);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_PRICE_SCHEDULE_DISCOUNT_ASSOCIATION_API , fields , setRecordId);
                }
                when 'Tier_Line_Item__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_TIER_LINE_ITEM_API);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_TIER_LINE_ITEM_API , fields , setRecordId);
                }
                when 'Discount_Line_Item__c' {
                    fields = mdtGetDynamicQueryFields(Coms_PlatformConstants.STRING_DISCOUNT_LINE_ITEM_API);
                    listSobject = getSobjectData(Coms_PlatformConstants.STRING_DISCOUNT_LINE_ITEM_API , fields , setRecordId);
                }
            }
        }
        System.debug('Coms_PlatfornCacheUtli :: getRecordFromDataBase found objSobject ---> ' + listSobject);
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-23-2021 
    * @param recordId 
    * @return string 
    **/
    public static string findSObject(string recordId){
        string sObjName;
        if(recordId.length() > 18 && recordId.contains('Serv') && !recordId.endsWith('TO')){
            sObjName = 'csord__Service__c';
        }else if(recordId.length() > 18 && recordId.contains('Subs')){
            sObjName = 'csord__Subscription__c';
        }
        else if(recordId.length() > 18 && recordId.endsWith('TO')){
            sObjName = 'Orchestration_Technical__c';
        }else if(recordId.length() == 15 || recordId.length() == 18){
            sObjName = Id.valueof(recordId).getSObjectType().getDescribe().getName(); 
        }else{
            sObjName = id.valueof(recordId).getSObjectType().getDescribe().getName(); 
        }
        return sObjName;
    }
    /**
    * @description : get the specific order from database.
    * @author Rohit Pal | 08-12-2021 
    * @param idOrderRecordId 
    * @return csord__Order__c 
    **/
    public static csord__Order__c getCsordOrders(id idOrderRecordId){
        csord__Order__c objcsordOrder = new csord__Order__c();
        SObjectType sobType =  csord__Order__c.SObjectType;
        List<string> fields = mdtGetDynamicQueryFields('csord__Order__c');
        objcsordOrder = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Id =: idOrderRecordId limit 1');
        system.debug('Coms_PlatformCacheUtil :: getCsordOrders :: found objcsordOrder ---> ' + objcsordOrder);
        return objcsordOrder;
    }

    /**
    * @description : get the technical object record data from database.
    * @author Rohit Pal | 08-16-2021 
    * @param idOrderRecordId 
    * @return Orchestration_Technical__c 
    **/
    public static Map<id,Orchestration_Technical__c> getOrchestrationTechnical(set<id> setServiceId){
        List<Orchestration_Technical__c> listOrchestrationTechnical = new List<Orchestration_Technical__c>();
        SObjectType sobType =  Orchestration_Technical__c.SObjectType;
        List<string> fields = mdtGetDynamicQueryFields('Orchestration_Technical__c');
        listOrchestrationTechnical = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Service__c =: setServiceId');
        
        return new Map<id,Orchestration_Technical__c>(listOrchestrationTechnical);
    }
    /**
    * @description 
    * @author Rohit Pal | 08-26-2021 
    * @param setOrchestrationTechnical 
    * @return Map<id, Technical_Child_Attribute__c> 
    **/
    public static Map<id,Technical_Child_Attribute__c> getTechnicalChildAttributes(set<id> setOrchestrationTechnical){
        List<Technical_Child_Attribute__c> listTechnicalChildAttribute = new List<Technical_Child_Attribute__c>();
        SObjectType sobType =  Technical_Child_Attribute__c.SObjectType;
        List<string> fields = mdtGetDynamicQueryFields('Technical_Child_Attribute__c');
        listTechnicalChildAttribute = Database.query(' SELECT ' + String.join(fields, ',')
                                                    + ' FROM ' + sobType
                                                    + ' WHERE  Orchestration_Technical__c =: setOrchestrationTechnical');
        return new Map<id,Technical_Child_Attribute__c>(listTechnicalChildAttribute);
    }
    /**
    * @description : get order related subscriptions
    * @author Rohit Pal | 08-12-2021 
    * @param setSubscriptionId 
    * @return Map<id, csord__Subscription__c> 
    **/
    public static Map<id,csord__Subscription__c> getSubscriptions(id idOrderRecordId){
        List<csord__Subscription__c> listcsordSubscription = new List<csord__Subscription__c>();
        SObjectType sobType =  csord__Subscription__c.SObjectType;
        List<string> fields = mdtGetDynamicQueryFields('csord__Subscription__c');
        listcsordSubscription = Database.query(' SELECT ' + String.join(fields, ',')
                                                + ' FROM ' + sobType
                                                + ' WHERE  csord__Order__c =: idOrderRecordId');
        system.debug('getSubscriptions ---> ' + listcsordSubscription);
        Map<id,csord__Subscription__c> mapSubscription = new Map<id,csord__Subscription__c>(listcsordSubscription);
        return mapSubscription;
    }

    /**
    * @description : get order related services.
    * @author Rohit Pal | 08-12-2021
    * @param setServicesId 
    * @return Map<Id, csord__Service__c> 
    **/
    public static Map<Id,csord__Service__c> getCSordServices(id idOrderRecordId){
        List<csord__Service__c> listcsordService = new List<csord__Service__c>();
        SObjectType sobType =  csord__Service__c.SObjectType;
        List<string> fields = mdtGetDynamicQueryFields('csord__Service__c');
                    listcsordService = Database.query(' SELECT ' + String.join(fields, ',')
                                                        + ' FROM ' + sobType
                                                        + ' WHERE  csord__Order__c =:idOrderRecordId');
        Map<Id,csord__Service__c> mapServices = new Map<Id,csord__Service__c>(listcsordService);
        return mapServices;
    }

    /**
    * @description : This method will help to retrive the data either with record id or Correlation id from database.
    * @author Rohit Pal | 08-17-2021 
    * @param sObjName 
    * @param fields 
    * @param idOrderRecordId 
    * @param isCorrelationId 
    * @return sobject 
    **/
    public static List<sobject> getSobjectData(string sObjName , List<string> fields , set<id> setRecordId){
        List<sobject> objSobject;
        if(!setRecordId.isEmpty()){
            objSobject = Database.query(' SELECT ' + String.join(fields, ',')
                                        + ' FROM ' + sObjName
                                        + ' WHERE  Id =: setRecordId');

            System.debug('Coms_PlatfornCacheUtli :: getSobjectData found objSobject ---> ' + objSobject);
        }
        return objSobject;
    }


    /**
    * @description : metadata which help to retive the field information that involv in order orchestration.
    * @author Rohit Pal | 08-17-2021 
    * @param objectName 
    * @return List<string>
    **/
    public static List<string> mdtGetDynamicQueryFields(string objectName){
        List<string> listFields;
        List<ConstantMetadataUtility__mdt> mdtConstantMetadataUtility = ConstantMetadataUtility__mdt.getAll().values();
        for(ConstantMetadataUtility__mdt iterator : [SELECT MasterLabel,
                                                            QueryFieldNames__c 
                                                    FROM ConstantMetadataUtility__mdt 
                                                    WHERE MasterLabel =: objectName]){
            listFields = new List<string>(string.valueof(iterator.QueryFieldNames__c).Split(','));
        }
        // List<ConstantMetadataUtility__mdt> mdtConstantMetadataUtilityList = ConstantMetadataUtility__mdt.getAll().values();
        // System.debug('Coms_PlatfornCacheUtli :: mdtGetDynamicQueryFields found mdtConstantMetadataUtilityList ---> ' + mdtConstantMetadataUtilityList);
        // for(ConstantMetadataUtility__mdt iterator : mdtConstantMetadataUtilityList){
        //     if(iterator.MasterLabel == objectName){
        //         listFields = new List<string>(string.valueof(iterator.Query_Fields_Names__c).Split(','));
        //     }
        // }
        System.debug('Coms_PlatfornCacheUtli :: mdtGetDynamicQueryFields found listFields ---> ' + listFields);
        return listFields;
    }
}