/*************************************************************************************************************
 * @name			Coms_SobjectUtil
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			24 / 09 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-24		BLR\rohit.pal			Changes desription
 *
**************************************************************************************************************/
public with sharing class Coms_SobjectUtil {
    
    /**
    * @description :
    * @author Rohit Pal | 09-24-2021
    * @param mapGetSessionData
    * @return List<sobject>
    **/
    public static List<sobject> getObjectSobject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getObjectSobject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found mapOrder  ----> ' + mapOrder);
                string stringOrderRelatedInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringOrderRelatedInfo  ----> ' + stringOrderRelatedInfo);
                Map<String, Object> mapOrderRelatedInfo = (Map<String, Object>)JSON.deserializeUntyped(stringOrderRelatedInfo);
                //
                csord__Order__c objcsordOrder = new csord__Order__c();
                objcsordOrder.put('CorrelationId__c' , ((String)mapOrderRelatedInfo.get('CorrelationId__c')));
                objcsordOrder.put('Id' , ((String)mapOrderRelatedInfo.get('Id')));
                objcsordOrder.put('Name' , ((String)mapOrderRelatedInfo.get('Name')));
                String dtStr=((String)mapOrderRelatedInfo.get('Platform_Cache_Timestamp__c'));
                objcsordOrder.put('Platform_Cache_Timestamp__c' ,(DateTime)json.deserialize(dtStr, datetime.class));//Date.valueOf(((String)mapOrderRelatedInfo.get('Platform_Cache_Timestamp__c'))));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found objcsordOrder  ----> ' + objcsordOrder);
                listSobject.add(objcsordOrder);
                //Coms_PlatformCacheUtil.getCacheRecordInformation('a4b2N000000jCFbQAM','csord__Order__c');
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-24-2021 
    * @param strJson 
    * @return List<sobject> 
    **/
    public static List<sobject> getSubscriptionSobject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getSubscriptionSobject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringAcc = string.valueof(mapGetSessionData.get(iterator));                
                Map<String, Object> mapAcc = (Map<String, Object>)JSON.deserializeUntyped(stringAcc);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found mapAcc  ----> ' + mapAcc);
                string stringAcc1 = JSON.serialize(mapAcc.get(iterator));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringAcc1  ----> ' + stringAcc1);
                Map<String, Object> mapAcc1 = (Map<String, Object>)JSON.deserializeUntyped(stringAcc1);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found CorrelationId__c  ----> ' + ((String)mapAcc1.get('CorrelationId__c')));
                // System.debug('Coms_SobjectUtil :: getOrderSobject :: found objNewInstance  ----> ' + objNewInstance);

                // csord__Subscription__c Data
                csord__Subscription__c objcsordSubscription = new csord__Subscription__c();
                objcsordSubscription.put('CorrelationId__c' , ((String)mapAcc1.get('CorrelationId__c')));
                objcsordSubscription.put('Id' , ((String)mapAcc1.get('Id')));
                objcsordSubscription.put('MarketableOffer__c' , ((String)mapAcc1.get('MarketableOffer__c')));
                objcsordSubscription.put('csord__Account__c' , ((String)mapAcc1.get('csord__Account__c')));
                objcsordSubscription.put('csord__Status__c' , ((String)mapAcc1.get('csord__Status__c')));
                objcsordSubscription.put('csord__Order__c' , ((String)mapAcc1.get('csord__Order__c')));
                objcsordSubscription.put('changeType__c' , ((String)mapAcc1.get('changeType__c')));
                objcsordSubscription.put('legacy_subscription__c' , ((String)mapAcc1.get('legacy_subscription__c')));
                objcsordSubscription.put('triggerBill_RTB__c' , ((boolean)mapAcc1.get('triggerBill_RTB__c')));
                String dtStr='"'+((String)mapAcc1.get('Platform_Cache_Timestamp__c'))+'"';
                objcsordSubscription.put('Platform_Cache_Timestamp__c' , (DateTime)json.deserialize(dtStr, datetime.class));//Date.valueOf(((String)mapAcc1.get('Platform_Cache_Timestamp__c'))));             
                //legacy_subscription__r
                csord__Subscription__c objLegacysubscription = new csord__Subscription__c();
                string stringLegacysubscription =  JSON.serialize((mapAcc1.get('legacy_subscription__r')));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringLegacysubscription  ----> ' +stringLegacysubscription);
                Map<String, Object> mapLegacysubscription = (Map<String, Object>)JSON.deserializeUntyped(stringLegacysubscription);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found mapLegacysubscription  ----> ' +mapLegacysubscription);
                //
                if(mapLegacysubscription != null){
                    objLegacysubscription.put('csord__Status__c' , ((String)mapLegacysubscription.get('csord__Status__c')));
                    objLegacysubscription.put('cssdm__solution_association__c' , ((String)mapLegacysubscription.get('cssdm__solution_association__c')));
                    objLegacysubscription.put('triggerBill_RTB__c' , ((String)mapLegacysubscription.get('triggerBill_RTB__c')));
                    objLegacysubscription.put('csord__Status__c' , ((String)mapLegacysubscription.get('csord__Status__c')));
                }
                //objLegacysubscription.legacy_subscription__r = objLegacysubscription;
                //Marketer
                Marketable_Offer__c objMarketableOffer = new Marketable_Offer__c();
                string stringAcc3 =  JSON.serialize((mapAcc1.get('MarketableOffer__r')));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringAcc3  ----> ' +stringAcc3);
                Map<String, Object> mapAcc2 = (Map<String, Object>)JSON.deserializeUntyped(stringAcc3);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found mapAcc2  ----> ' +mapAcc2);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found Id  ----> ' +((String)mapAcc1.get('Id')));
                //objMarketableOffer.put('Id' , ((String)mapAcc2.get('Id')));
                if(mapAcc2!=null){
                    objMarketableOffer.put('Name' , ((String)mapAcc2.get('Name')));
                    objMarketableOffer.put('Offer_ID__c' , ((String)mapAcc2.get('Offer_ID__c')));
                    objMarketableOffer.put('Type__c' , ((string)mapAcc2.get('Type__c')));
                    objMarketableOffer.put('Config__c' , ((string)mapAcc2.get('Config__c')));
                    //objMarketableOffer.put('CorrelationId__c' , ((string)mapAcc2.get('CorrelationId__c')));
                    //objMarketableOffer.put('Platform_Cache_Timestamp__c' , Date.valueOf(((String)mapAcc2.get('Platform_Cache_Timestamp__c'))));
                    objcsordSubscription.MarketableOffer__r =objMarketableOffer;
                    // System.debug('Coms_SobjectUtil :: getOrderSobject :: found objMarketableOffer  ----> ' +objMarketableOffer);
                    // System.debug('Coms_SobjectUtil :: getOrderSobject :: found objcsordSubscription  ----> ' +objcsordSubscription.MarketableOffer__r);
                }

                //Order
                csord__Order__c objcsord = new csord__Order__c();
                string stringOrderJson =  JSON.serialize((mapAcc1.get('csord__Order__r')));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringOrderJson  ----> ' +stringOrderJson);
                Map<String, Object> mapOrderInformation = (Map<String, Object>)JSON.deserializeUntyped(stringOrderJson);
                if(mapOrderInformation != null){
                objcsord.put('Id' , ((String)mapOrderInformation.get('Id')));
                //read-only field
                // objcsord.put('csord__Order_Number__c' , ((String)mapOrderInformation.get('csord__Order_Number__c')));
                objcsord.put('csord__Status2__c' , ((String)mapOrderInformation.get('csord__Status2__c')));
                objcsord.put('skipFulfillment__c' , ((boolean)mapOrderInformation.get('skipFulfillment__c')));
                objcsord.put('csord__Account__c' , ((String)mapOrderInformation.get('csord__Account__c')));
                objcsord.put('csordtelcoa__Opportunity__c' , ((String)mapOrderInformation.get('csordtelcoa__Opportunity__c')));
                objcsord.put('CorrelationId__c' , ((String)mapOrderInformation.get('CorrelationId__c')));
                //objcsord.put('Platform_Cache_Timestamp__c' , Date.valueOf(((String)mapOrderInformation.get('Platform_Cache_Timestamp__c'))));
                objcsordSubscription.csord__Order__r =objcsord;
                }

                //csord__Account__r
                string stringCSordAccountJson =  JSON.serialize((mapAcc1.get('csord__Account__r')));
                System.debug('  ccountJson  ----> ' +stringCSordAccountJson);
                Map<String, Object> mapCSordAccountInformation = (Map<String, Object>)JSON.deserializeUntyped(stringCSordAccountJson);
                Account objAccount = new Account();
                if(mapCSordAccountInformation != null){
                    objAccount.put('Customer_Status__c' , ((String)mapCSordAccountInformation.get('Customer_Status__c')));
                    objAccount.put('Id' , ((String)mapCSordAccountInformation.get('Id')));
                    objcsordSubscription.csord__Account__r = objAccount;
                }
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found objcsordSubscription  ----> ' + objcsordSubscription);
                listSobject.add(objcsordSubscription);
                // List<FormulaRecalcResult> results = Formula.recalculateFormulas(listSobject);
            }
        }
        //Coms_PlatformCacheUtil.getCacheRecordInformation('a4b2N000000jCFbQAMSubs1','csord__Subscription__c');
        //Coms_PlatformCacheUtil.getCacheRecordInformation('a4g2N0000006oXBQAY','csord__Subscription__c');
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-24-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getServiceOject(Map<String, Object> mapGetSessionData){ 
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getServiceOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getServiceOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringAcc = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapServiceData = (Map<String, Object>)JSON.deserializeUntyped(stringAcc);
                System.debug('Coms_SobjectUtil :: getServiceOject :: found mapServiceData  ----> ' + mapServiceData);
                string strServiceData = JSON.serialize(mapServiceData.get(iterator));
                System.debug('Coms_SobjectUtil :: getServiceOject :: found stringAcc1  ----> ' + strServiceData);
                Map<String, Object> mapRelatedServiceData = (Map<String, Object>)JSON.deserializeUntyped(strServiceData);
                //listSobject.add();
                csord__Service__c objcsordService = new csord__Service__c();
                objcsordService.put('Id' , ((String)mapRelatedServiceData.get('Id')));
                objcsordService.put('Name' , ((String)mapRelatedServiceData.get('Name')));
                objcsordService.put('CorrelationId__c' , ((String)mapRelatedServiceData.get('CorrelationId__c')));
                //objcsordService.put('Platform_Cache_Timestamp__c' , ((DateTime)mapRelatedServiceData.get('Platform_Cache_Timestamp__c')));
                objcsordService.put('csord__Order__c' , ((String)mapRelatedServiceData.get('csord__Order__c')));
                //objcsordService.put('csordtelcoa__Product_Configuration__c' , ((String)mapRelatedServiceData.get('csordtelcoa__Product_Configuration__c')));
                objcsordService.put('csordtelcoa__Replaced_Service__c' , ((String)mapRelatedServiceData.get('csordtelcoa__Replaced_Service__c')));
                //objcsordService.put('toBeCancelled__c' , ((String)mapRelatedServiceData.get('toBeCancelled__c')));
                objcsordService.put('csord__Status__c' , ((String)mapRelatedServiceData.get('csord__Status__c')));
                objcsordService.put('csord__Order_Request__c' , ((String)mapRelatedServiceData.get('csord__Order_Request__c')));
                objcsordService.put('csordtelcoa__Service_Number__c' , ((String)mapRelatedServiceData.get('csordtelcoa__Service_Number__c')));
                objcsordService.put('csord__Subscription__c' , ((String)mapRelatedServiceData.get('csord__Subscription__c')));
                //objcsordService.put('CreatedDate' , ((string)mapRelatedServiceData.get('CreatedDate')));
                objcsordService.put('Scenario_Type__c' , ((String)mapRelatedServiceData.get('Scenario_Type__c')));
                objcsordService.put('Action_Type__c' , ((String)mapRelatedServiceData.get('Action_Type__c')));
                objcsordService.put('changeType__c' , ((String)mapRelatedServiceData.get('changeType__c')));
                objcsordService.put('Sim_Serial_Number__c' , ((String)mapRelatedServiceData.get('Sim_Serial_Number__c')));
                objcsordService.put('csord__Service__c' , ((String)mapRelatedServiceData.get('csord__Service__c')));
                objcsordService.put('Marketable_Offer__c' , ((String)mapRelatedServiceData.get('Marketable_Offer__c')));
                objcsordService.put('csordtelcoa__Product_Configuration__c' , ((String)mapRelatedServiceData.get('csordtelcoa__Product_Configuration__c')));
                // Object csordtelcoa__Product_Configuration__r
                if(mapRelatedServiceData.containsKey('csordtelcoa__Product_Configuration__r')){
                    string stringProductConfigurationJson =  JSON.serialize((mapRelatedServiceData.get('csordtelcoa__Product_Configuration__r')));
                    System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringProductConfigurationJson  ----> ' +stringProductConfigurationJson);
                    Map<String, Object> mapProductConfiguration = (Map<String, Object>)JSON.deserializeUntyped(stringProductConfigurationJson);
                    cscfga__Product_Configuration__c objcsordtelcoaProductConfiguration = new cscfga__Product_Configuration__c();
                    if(mapProductConfiguration != null){
                        objcsordtelcoaProductConfiguration.put('Name' , ((String)mapProductConfiguration.get('Name'))); 
                        objcsordtelcoaProductConfiguration.put('ConfigurationType1__c' , ((String)mapProductConfiguration.get('ConfigurationType1__c'))); 
                        objcsordtelcoaProductConfiguration.put('cscfga__Product_Definition__c' , ((String)mapProductConfiguration.get('cscfga__Product_Definition__c')));
                        objcsordtelcoaProductConfiguration.put('cscfga__Product_Basket__c' , ((String)mapProductConfiguration.get('cscfga__Product_Basket__c')));
                        objcsordService.csordtelcoa__Product_Configuration__r = objcsordtelcoaProductConfiguration;
                    }
                    // object cscfga__Product_Definition__r
                    cscfga__Product_Definition__c objcscfgaProductDefinition = new cscfga__Product_Definition__c();

                    string stringProductDefinitionJson =  JSON.serialize((mapProductConfiguration.get('cscfga__Product_Definition__r')));
                    System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringProductDefinitionJson  ----> ' +stringProductDefinitionJson);
                    Map<String, Object> mapProductDefinition = (Map<String, Object>)JSON.deserializeUntyped(stringProductDefinitionJson);
                    System.debug('Coms_SobjectUtil :: getServiceOject :: found mapProductDefinition  ----> ' + mapProductDefinition);
                    objcscfgaProductDefinition.put('Id' , ((String)mapProductConfiguration.get('Id')));
                    objcscfgaProductDefinition.put('EDMSpecToSuppressInRTB__c' , ((String)mapProductDefinition.get('EDMSpecToSuppressInRTB__c')));
                    objcscfgaProductDefinition.put('product_Specification__c' , ((String)mapProductDefinition.get('product_Specification__c')));
                    objcsordtelcoaProductConfiguration.cscfga__Product_Definition__r = objcscfgaProductDefinition;
                    objcsordService.csordtelcoa__Product_Configuration__r = objcsordtelcoaProductConfiguration;
                    //Coms_PlatformCacheUtil.getCacheRecordInformation('a4b2N000000kOEEQA2Serv4','csord__Service__c');
                }
                //Marketer
                Marketable_Offer__c objMarketableOffer = new Marketable_Offer__c();
                csord__Subscription__c objcsordSubscription = new csord__Subscription__c();
                string stringSubscription =  JSON.serialize((mapRelatedServiceData.get('csord__Subscription__r')));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringSubscription  ----> ' +stringSubscription);
                Map<String, Object> mapSubscription = (Map<String, Object>)JSON.deserializeUntyped(stringSubscription);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found mapAcc2  ----> ' +mapSubscription);
                //
                objcsordSubscription.put('MarketableOffer__c',((String)mapSubscription.get('MarketableOffer__c')));
                string stringAcc3 =  JSON.serialize((mapSubscription.get('MarketableOffer__r')));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringAcc3  ----> ' +stringAcc3);
                Map<String, Object> mapAcc2 = (Map<String, Object>)JSON.deserializeUntyped(stringAcc3);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found mapAcc2  ----> ' +mapAcc2);
                //objMarketableOffer.put('Id' , ((String)mapAcc2.get('Id')));
                if(mapAcc2 != null){
                    objMarketableOffer.put('Name' , ((String)mapAcc2.get('Name')));
                    objMarketableOffer.put('Offer_ID__c' , ((String)mapAcc2.get('Offer_ID__c')));
                    // objMarketableOffer.put('Type__c' , ((string)mapAcc2.get('Type__c')));
                    // objMarketableOffer.put('Config__c' , ((string)mapAcc2.get('Config__c')));
                    //objMarketableOffer.put('CorrelationId__c' , ((string)mapAcc2.get('CorrelationId__c')));
                    //objMarketableOffer.put('Platform_Cache_Timestamp__c' , Date.valueOf(((String)mapAcc2.get('Platform_Cache_Timestamp__c'))));
                    objcsordSubscription.MarketableOffer__r = objMarketableOffer;
                    objcsordService.csord__Subscription__r = objcsordSubscription;
                    // System.debug('Coms_SobjectUtil :: getOrderSobject :: found objMarketableOffer  ----> ' +objMarketableOffer);
                    // System.debug('Coms_SobjectUtil :: getOrderSobject :: found objcsordSubscription  ----> ' +objcsordSubscription.MarketableOffer__r);
                }
                //csordtelcoa__Replaced_Service__c
                string stringRelatedService =  JSON.serialize((mapRelatedServiceData.get('csordtelcoa__Replaced_Service__r')));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringRelatedService  ----> ' +stringRelatedService);
                Map<String, Object> mapRelatedService = (Map<String, Object>)JSON.deserializeUntyped(stringRelatedService);
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found mapRelatedService  ----> ' +mapRelatedService);
                csord__Service__c objcsordtelcoaReplacedService = new csord__Service__c();
                if(mapRelatedService != null){
                    objcsordtelcoaReplacedService.put('Name' , ((String)mapRelatedService.get('Name')));
                    objcsordtelcoaReplacedService.put('Id' , ((String)mapRelatedService.get('Id')));
                    objcsordtelcoaReplacedService.put('CorrelationId__c' , ((string)mapRelatedService.get('CorrelationId__c')));
                    objcsordService.csordtelcoa__Replaced_Service__r = objcsordtelcoaReplacedService;
                }
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found objcsordService  ----> ' + objcsordService.csord__Subscription__r.MarketableOffer__c);
                listSobject.add(objcsordService);
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getOrchestrationTechnicalOject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getOrchestrationTechnicalOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getOrchestrationTechnicalOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getOrchestrationTechnicalOject :: found mapOrder  ----> ' + mapOrder);
                string stringOrchestrationTechnicalInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getOrchestrationTechnicalOject :: found stringOrchestrationTechnicalInfo  ----> ' + stringOrchestrationTechnicalInfo);
                Map<String, Object> mapOrchestrationTechnicalInfo = (Map<String, Object>)JSON.deserializeUntyped(stringOrchestrationTechnicalInfo);
                System.debug('Coms_SobjectUtil :: getOrchestrationTechnicalOject :: found mapOrchestrationTechnicalInfo  ----> ' + mapOrchestrationTechnicalInfo);
                //
                Orchestration_Technical__c objOrchestrationTechnical = new Orchestration_Technical__c();
                objOrchestrationTechnical.put('CorrelationId__c' , ((String)mapOrchestrationTechnicalInfo.get('CorrelationId__c')));
                objOrchestrationTechnical.put('Id' , ((String)mapOrchestrationTechnicalInfo.get('Id')));
                objOrchestrationTechnical.put('Field_1__c' , ((String)mapOrchestrationTechnicalInfo.get('Field_1__c')));
                objOrchestrationTechnical.put('Field_3__c' , ((String)mapOrchestrationTechnicalInfo.get('Field_3__c')));
                objOrchestrationTechnical.put('Field_7__c' , ((String)mapOrchestrationTechnicalInfo.get('Field_7__c')));
                objOrchestrationTechnical.put('Field_13__c' , ((String)mapOrchestrationTechnicalInfo.get('Field_13__c')));
                objOrchestrationTechnical.put('Field_10__c' , ((String)mapOrchestrationTechnicalInfo.get('Field_10__c')));
                objOrchestrationTechnical.put('Field_8__c' , ((String)mapOrchestrationTechnicalInfo.get('Field_8__c')));
                objOrchestrationTechnical.put('Field_14__c' , ((String)mapOrchestrationTechnicalInfo.get('Field_14__c')));
                objOrchestrationTechnical.put('Field_11__c' , ((String)mapOrchestrationTechnicalInfo.get('Field_11__c')));
                objOrchestrationTechnical.put('Service__c' , ((String)mapOrchestrationTechnicalInfo.get('Service__c')));
                //objOrchestrationTechnical.put('Name' , ((String)mapOrchestrationTechnicalInfo.get('Name')));
                String dtStr='"'+((String)mapOrchestrationTechnicalInfo.get('Platform_Cache_Timestamp__c'))+'"';                
                objOrchestrationTechnical.put('Platform_Cache_Timestamp__c' ,(DateTime)json.deserialize(dtStr, datetime.class));// Date.valueOf(((String)mapOrchestrationTechnicalInfo.get('Platform_Cache_Timestamp__c'))));
                System.debug('Coms_SobjectUtil :: getOrchestrationTechnicalOject :: found objOrchestrationTechnical  ----> ' + objOrchestrationTechnical);
                listSobject.add(objOrchestrationTechnical);
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getTechnicalChildAttributeOject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getTechnicalChildAttributeOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getTechnicalChildAttributeOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getTechnicalChildAttributeOject :: found mapOrder  ----> ' + mapOrder);
                string stringTechnicalChildAttributeInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getTechnicalChildAttributeOject :: found stringTechnicalChildAttributeInfo  ----> ' + stringTechnicalChildAttributeInfo);
                Map<String, Object> mapTechnicalChildAttributeInfo = (Map<String, Object>)JSON.deserializeUntyped(stringTechnicalChildAttributeInfo);
                System.debug('Coms_SobjectUtil :: getTechnicalChildAttributeOject :: found mapTechnicalChildAttributeInfo  ----> ' + mapTechnicalChildAttributeInfo);
                Technical_Child_Attribute__c objTechnicalChildAttribute = new Technical_Child_Attribute__c();
                objTechnicalChildAttribute.put('CorrelationId__c' , ((String)mapTechnicalChildAttributeInfo.get('CorrelationId__c')));
                objTechnicalChildAttribute.put('Id' , ((String)mapTechnicalChildAttributeInfo.get('Id')));
                objTechnicalChildAttribute.put('Orchestration_Technical__c' , ((String)mapTechnicalChildAttributeInfo.get('Orchestration_Technical__c')));
                objTechnicalChildAttribute.put('Complex_Attribute_Schema_Id__c' , ((String)mapTechnicalChildAttributeInfo.get('Complex_Attribute_Schema_Id__c')));
                objTechnicalChildAttribute.put('Field_1__c' , ((String)mapTechnicalChildAttributeInfo.get('Field_1__c')));
                objTechnicalChildAttribute.put('Field_5__c' , ((String)mapTechnicalChildAttributeInfo.get('Field_5__c')));
                objTechnicalChildAttribute.put('Field_3__c' , ((String)mapTechnicalChildAttributeInfo.get('Field_3__c')));
                objTechnicalChildAttribute.put('Field_2__c' , ((String)mapTechnicalChildAttributeInfo.get('Field_2__c')));
                objTechnicalChildAttribute.put('Field_4__c' , ((String)mapTechnicalChildAttributeInfo.get('Field_4__c')));
                objTechnicalChildAttribute.put('Field_6__c' , ((String)mapTechnicalChildAttributeInfo.get('Field_6__c')));
                objTechnicalChildAttribute.put('Category__c' , ((String)mapTechnicalChildAttributeInfo.get('Category__c')));
                //objTechnicalChildAttribute.put('Name' , ((String)mapTechnicalChildAttributeInfo.get('Name')));
                String dtStr='"'+((String)mapTechnicalChildAttributeInfo.get('Platform_Cache_Timestamp__c'))+'"';
                objTechnicalChildAttribute.put('Platform_Cache_Timestamp__c' ,(DateTime)json.deserialize(dtStr, datetime.class));//Date.valueOf(((String)mapTechnicalChildAttributeInfo.get('Platform_Cache_Timestamp__c'))));
                //Orchestration_Technical__r
                string stringOrchestrationTechnicalJson =  JSON.serialize((mapTechnicalChildAttributeInfo.get('Orchestration_Technical__r')));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringOrchestrationTechnicalJson  ----> ' +stringOrchestrationTechnicalJson);
                Map<String, Object> mapOrchestrationTechnical = (Map<String, Object>)JSON.deserializeUntyped(stringOrchestrationTechnicalJson);
                System.debug('Coms_SobjectUtil :: getServiceOject :: found mapOrchestrationTechnical  ----> ' + mapOrchestrationTechnical);
                Orchestration_Technical__c objOrchestrationTechnical = new Orchestration_Technical__c();
                objOrchestrationTechnical.put('CorrelationId__c' , ((String)mapOrchestrationTechnical.get('CorrelationId__c')));
                objOrchestrationTechnical.put('Id' , ((String)mapOrchestrationTechnical.get('Id')));
                objOrchestrationTechnical.put('Field_1__c' , ((String)mapOrchestrationTechnical.get('Field_1__c')));
                objOrchestrationTechnical.put('Field_3__c' , ((String)mapOrchestrationTechnical.get('Field_3__c')));
                objOrchestrationTechnical.put('Field_7__c' , ((String)mapOrchestrationTechnical.get('Field_7__c')));
                objOrchestrationTechnical.put('Field_13__c' , ((String)mapOrchestrationTechnical.get('Field_13__c')));
                objOrchestrationTechnical.put('Field_10__c' , ((String)mapOrchestrationTechnical.get('Field_10__c')));
                objOrchestrationTechnical.put('Field_8__c' , ((String)mapOrchestrationTechnical.get('Field_8__c')));
                objOrchestrationTechnical.put('Field_14__c' , ((String)mapOrchestrationTechnical.get('Field_14__c')));
                objOrchestrationTechnical.put('Field_11__c' , ((String)mapOrchestrationTechnical.get('Field_11__c')));
                objOrchestrationTechnical.put('Service__c' , ((String)mapOrchestrationTechnical.get('Service__c')));
                //objOrchestrationTechnical.put('Name' , ((String)mapOrchestrationTechnicalInfo.get('Name')));
                //objOrchestrationTechnical.put('Platform_Cache_Timestamp__c' , Date.valueOf(((String)mapOrchestrationTechnical.get('Platform_Cache_Timestamp__c'))));
                // service Object
                string stringServiceJson =  JSON.serialize((mapOrchestrationTechnical.get('Service__r')));
                System.debug('Coms_SobjectUtil :: getOrderSobject :: found stringServiceJson  ----> ' +stringServiceJson);
                Map<String, Object> mapService = (Map<String, Object>)JSON.deserializeUntyped(stringServiceJson);
                System.debug('Coms_SobjectUtil :: getServiceOject :: found mapService  ----> ' + mapService);
                csord__Service__c objcsordService = new csord__Service__c();
                objcsordService.put('Id' , ((String)mapService.get('Id')));
                objcsordService.put('OrderTransientDataDetails__c' , ((String)mapService.get('OrderTransientDataDetails__c')));
                objOrchestrationTechnical.Service__r = objcsordService;
                objTechnicalChildAttribute.Orchestration_Technical__r = objOrchestrationTechnical;
                System.debug('Coms_SobjectUtil :: getTechnicalChildAttributeOject :: found objTechnicalChildAttribute  ----> ' + objTechnicalChildAttribute.Orchestration_Technical__r.Service__r);
                listSobject.add(objTechnicalChildAttribute);
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getBillingAccountOject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getBillingAccountOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getBillingAccountOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getBillingAccountOject :: found mapOrder  ----> ' + mapOrder);
                string stringBillingAccountInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getBillingAccountOject :: found stringBillingAccountInfo  ----> ' + stringBillingAccountInfo);
                Map<String, Object> mapBillingAccountInfo = (Map<String, Object>)JSON.deserializeUntyped(stringBillingAccountInfo);
                //
                Billing_Account__c objBillingAccount = new Billing_Account__c();
                objBillingAccount.put('CorrelationId__c' , ((String)mapBillingAccountInfo.get('CorrelationId__c')));
                objBillingAccount.put('Id' , ((String)mapBillingAccountInfo.get('Id')));
                //objBillingAccount.put('Name' , ((String)mapBillingAccountInfo.get('Name')));
                String dtStr='"'+((String)mapBillingAccountInfo.get('Platform_Cache_Timestamp__c'))+'"';
                objBillingAccount.put('Platform_Cache_Timestamp__c' ,(DateTime)json.deserialize(dtStr, datetime.class));// Date.valueOf(((String)mapBillingAccountInfo.get('Platform_Cache_Timestamp__c'))));
                System.debug('Coms_SobjectUtil :: getBillingAccountOject :: found objBillingAccount  ----> ' + objBillingAccount);
                listSobject.add(objBillingAccount);
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getChargeLineItemOject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getChargeLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getChargeLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getChargeLineItemOject :: found mapOrder  ----> ' + mapOrder);
                string stringChargeLineItemInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getChargeLineItemOject :: found stringChargeLineItemInfo  ----> ' + stringChargeLineItemInfo);
                Map<String, Object> mapChargeLineItemInfo = (Map<String, Object>)JSON.deserializeUntyped(stringChargeLineItemInfo);
                Charge_Line_Item__c objChargeLineItem = new Charge_Line_Item__c();
                objChargeLineItem.put('CorrelationId__c' , ((String)mapChargeLineItemInfo.get('CorrelationId__c')));
                objChargeLineItem.put('Id' , ((String)mapChargeLineItemInfo.get('Id')));
                String dtStr='"'+((String)mapChargeLineItemInfo.get('Platform_Cache_Timestamp__c'))+'"';
                objChargeLineItem.put('Platform_Cache_Timestamp__c' ,(DateTime)json.deserialize(dtStr, datetime.class));//Date.valueOf(((String)mapChargeLineItemInfo.get('Platform_Cache_Timestamp__c'))));
                objChargeLineItem.put('serviceId__c' , ((String)mapChargeLineItemInfo.get('serviceId__c')));
                objChargeLineItem.put('BusinessID__c' , ((String)mapChargeLineItemInfo.get('BusinessID__c')));
                objChargeLineItem.put('chargeType__c' , ((String)mapChargeLineItemInfo.get('chargeType__c')));
                //serviceId__r
                csord__Service__c objcsordService = new csord__Service__c();
                string stringcsordService = JSON.serialize(mapChargeLineItemInfo.get('serviceId__r'));
                System.debug('Coms_SobjectUtil :: getChargeLineItemOject :: found stringcsordService  ----> ' + stringcsordService);
                Map<String, Object> mapcsordService = (Map<String, Object>)JSON.deserializeUntyped(stringcsordService);
                System.debug('Coms_SobjectUtil :: getChargeLineItemOject :: found mapcsordService  ----> ' + mapcsordService);
                objcsordService.put('Id' , ((String)mapcsordService.get('Id')));
                objcsordService.put('csord__Subscription__c' , ((String)mapcsordService.get('csord__Subscription__c')));
                objcsordService.put('Scenario_Type__c' , ((String)mapcsordService.get('Scenario_Type__c')));
                objChargeLineItem.serviceId__r = objcsordService;
                //csord__Subscription__r
                csord__Subscription__c objcsordSubscription = new csord__Subscription__c();
                string stringcsordSubscription = JSON.serialize(mapcsordService.get('csord__Subscription__r'));
                System.debug('Coms_SobjectUtil :: getChargeLineItemOject :: found stringcsordSubscription  ----> ' + stringcsordSubscription);
                Map<String, Object> mapcsordSubscription = (Map<String, Object>)JSON.deserializeUntyped(stringcsordSubscription);
                System.debug('Coms_SobjectUtil :: getChargeLineItemOject :: found mapcsordSubscription  ----> ' + mapcsordSubscription);
                //
                listSobject.add(objChargeLineItem);
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getDiscountLineItemOject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getDiscountLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getDiscountLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getDiscountLineItemOject :: found mapOrder  ----> ' + mapOrder);
                string stringDiscountLineItemInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getDiscountLineItemOject :: found stringDiscountLineItemInfo  ----> ' + stringDiscountLineItemInfo);
                Map<String, Object> mapDiscountLineItemInfo = (Map<String, Object>)JSON.deserializeUntyped(stringDiscountLineItemInfo);
                Discount_Line_Item__c objDiscountLineItem = new Discount_Line_Item__c();
                objDiscountLineItem.put('CorrelationId__c' , ((String)mapDiscountLineItemInfo.get('CorrelationId__c')));
                objDiscountLineItem.put('Id' , ((String)mapDiscountLineItemInfo.get('Id')));
                objDiscountLineItem.put('Name' , ((String)mapDiscountLineItemInfo.get('Name')));
                String dtStr='"'+((String)mapDiscountLineItemInfo.get('Platform_Cache_Timestamp__c'))+'"';
                objDiscountLineItem.put('Platform_Cache_Timestamp__c' ,(DateTime)json.deserialize(dtStr, datetime.class));// Date.valueOf(((String)mapDiscountLineItemInfo.get('Platform_Cache_Timestamp__c'))));
                System.debug('Coms_SobjectUtil :: getDiscountLineItemOject :: found objDiscountLineItem  ----> ' + objDiscountLineItem);
                listSobject.add(objDiscountLineItem);
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getPriceScheduleLineItemOject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapOrder  ----> ' + mapOrder);
                string stringPriceScheduleLineItemInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found stringPriceScheduleLineItemInfo  ----> ' + stringPriceScheduleLineItemInfo);
                Map<String, Object> mapPriceScheduleLineItemInfo = (Map<String, Object>)JSON.deserializeUntyped(stringPriceScheduleLineItemInfo);
                Price_Schedule_Line_Item__c objPriceScheduleLineItem = new Price_Schedule_Line_Item__c();
                objPriceScheduleLineItem.put('CorrelationId__c' , ((String)mapPriceScheduleLineItemInfo.get('CorrelationId__c')));
                objPriceScheduleLineItem.put('Id' , ((String)mapPriceScheduleLineItemInfo.get('Id')));
                objPriceScheduleLineItem.put('Name' , ((String)mapPriceScheduleLineItemInfo.get('Name')));
                objPriceScheduleLineItem.put('Status__c' , ((String)mapPriceScheduleLineItemInfo.get('Status__c')));
                objPriceScheduleLineItem.put('chargeInstance__c' , ((String)mapPriceScheduleLineItemInfo.get('chargeInstance__c')));
                String dtStr='"'+((String)mapPriceScheduleLineItemInfo.get('Platform_Cache_Timestamp__c'))+'"';
                objPriceScheduleLineItem.put('Platform_Cache_Timestamp__c' ,(DateTime)json.deserialize(dtStr, datetime.class));// Date.valueOf(((String)mapPriceScheduleLineItemInfo.get('Platform_Cache_Timestamp__c'))));
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found objPriceScheduleLineItem  ----> ' + objPriceScheduleLineItem);
                listSobject.add(objPriceScheduleLineItem);
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 10-26-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getPriceScheduleDiscountAssocItem(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapOrder  ----> ' + mapOrder);
                string stringPriceScheduleLineItemInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found stringPriceScheduleLineItemInfo  ----> ' + stringPriceScheduleLineItemInfo);
                Map<String, Object> mapPriceScheduleDiscountAssocItem = (Map<String, Object>)JSON.deserializeUntyped(stringPriceScheduleLineItemInfo);
                Price_Schedule_Discount_Association__c objPriceScheduleDiscountAssocItem = new Price_Schedule_Discount_Association__c();
                objPriceScheduleDiscountAssocItem.put('CorrelationId__c' , ((String)mapPriceScheduleDiscountAssocItem.get('CorrelationId__c')));
                objPriceScheduleDiscountAssocItem.put('Id' , ((String)mapPriceScheduleDiscountAssocItem.get('Id')));
                objPriceScheduleDiscountAssocItem.put('Name' , ((String)mapPriceScheduleDiscountAssocItem.get('Name')));
                objPriceScheduleDiscountAssocItem.put('priceScheduleInstance__c' , ((String)mapPriceScheduleDiscountAssocItem.get('priceScheduleInstance__c')));
                String dtStr='"'+((String)mapPriceScheduleDiscountAssocItem.get('Platform_Cache_Timestamp__c'))+'"';
                objPriceScheduleDiscountAssocItem.put('Platform_Cache_Timestamp__c' , (DateTime)json.deserialize(dtStr, datetime.class));//Date.valueOf(((String)mapPriceScheduleDiscountAssocItem.get('Platform_Cache_Timestamp__c'))));
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found objPriceScheduleDiscountAssocItem  ----> ' + objPriceScheduleDiscountAssocItem);
                listSobject.add(objPriceScheduleDiscountAssocItem);
            }
        }
        return listSobject;
    }
    
    /**
    * @description 
    * @author Rohit Pal | 10-26-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getTierLineItem(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found mapOrder  ----> ' + mapOrder);
                string stringPriceScheduleLineItemInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found stringPriceScheduleLineItemInfo  ----> ' + stringPriceScheduleLineItemInfo);
                Map<String, Object> mapTierLineItem = (Map<String, Object>)JSON.deserializeUntyped(stringPriceScheduleLineItemInfo);
                Tier_Line_Item__c objTierLineItem = new Tier_Line_Item__c();
                objTierLineItem.put('CorrelationId__c' , ((String)mapTierLineItem.get('CorrelationId__c')));
                objTierLineItem.put('Id' , ((String)mapTierLineItem.get('Id')));
                objTierLineItem.put('Name' , ((String)mapTierLineItem.get('Name')));
                objTierLineItem.put('PSLIInstance__c' , ((String)mapTierLineItem.get('PSLIInstance__c')));
                 String dtStr='"'+((String)mapTierLineItem.get('Platform_Cache_Timestamp__c'))+'"';
                objTierLineItem.put('Platform_Cache_Timestamp__c' ,(DateTime)json.deserialize(dtStr, datetime.class));// Date.valueOf(((String)mapTierLineItem.get('Platform_Cache_Timestamp__c'))));
                System.debug('Coms_SobjectUtil :: getPriceScheduleLineItemOject :: found objTierLineItem  ----> ' + objTierLineItem);
                listSobject.add(objTierLineItem);
            }
        }
        return listSobject;
    }

    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    * @param mapGetSessionData 
    * @return List<sobject> 
    **/
    public static List<sobject> getNumberOject(Map<String, Object> mapGetSessionData){
        List<sobject> listSobject = new List<sobject>();
        System.debug('Coms_SobjectUtil :: getNumberOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
        if(!mapGetSessionData.isEmpty()){
            for(String iterator : mapGetSessionData.keySet()){
                System.debug('Coms_SobjectUtil :: getNumberOject :: found mapGetSessionData  ----> ' + mapGetSessionData);
                string stringOrder = string.valueof(mapGetSessionData.get(iterator));
                Map<String, Object> mapOrder = (Map<String, Object>)JSON.deserializeUntyped(stringOrder);
                System.debug('Coms_SobjectUtil :: getNumberOject :: found mapOrder  ----> ' + mapOrder);
                string stringNumberInfo = JSON.serialize(mapOrder.get(iterator));
                System.debug('Coms_SobjectUtil :: getNumberOject :: found stringNumberInfo  ----> ' + stringNumberInfo);
                Map<String, Object> mapNumberInfo = (Map<String, Object>)JSON.deserializeUntyped(stringNumberInfo);
                Number__c objNumber = new Number__c();
                objNumber.put('CorrelationId__c' , ((String)mapNumberInfo.get('CorrelationId__c')));
                objNumber.put('Id' , ((String)mapNumberInfo.get('Id')));
                objNumber.put('Name' , ((String)mapNumberInfo.get('Name')));
                objNumber.put('Service_Number__c' , ((String)mapNumberInfo.get('Service_Number__c')));
                objNumber.put('Status__c' , ((String)mapNumberInfo.get('Status__c')));
                objNumber.put('Subscription_number__c' , ((String)mapNumberInfo.get('Subscription_number__c')));
                objNumber.put('Product_ID__c' , ((String)mapNumberInfo.get('Product_ID__c')));
                String dtStr='"'+((String)mapNumberInfo.get('Platform_Cache_Timestamp__c'))+'"';
                objNumber.put('Platform_Cache_Timestamp__c' , (DateTime)json.deserialize(dtStr, datetime.class));//Date.valueOf(((String)mapNumberInfo.get('Platform_Cache_Timestamp__c'))));
                System.debug('Coms_SobjectUtil :: getNumberOject :: found objNumber  ----> ' + objNumber);
                listSobject.add(objNumber);
            }
        }
        return listSobject;
    }
}