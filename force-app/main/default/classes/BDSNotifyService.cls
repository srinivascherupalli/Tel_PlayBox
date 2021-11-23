/*
===============================================================================================================================
Class : BDSNotifyService
Developer Name :Anand Shekhar
Test Class : BDSNotifyServiceTest
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
4. 		Nikhil Sharma		30/08/2021	 DIGI-4694 | Fire BDS_Notification_Event platform event for DMS.
5.      Akshay Gujar                     DIGI-25281 | Enable Intune | P2O | Notifications for New, Modify, Cancel
===============================================================================================================================
*/
public with sharing class BDSNotifyService {

    @testVisible
    static List<BDS_Notification_Event__e> notifyEvents = new List<BDS_Notification_Event__e>();
    private static String correlationId = GuidUtil.NewGuid();
    private static final String CONST_INTERFACENAME = 'BDSNotifyService';

    public static void triggerPlatformEvent(List<csord__Subscription__c> subscriptions, String orderStatus){

        Map<String, Partner_of_Record__c> porMap = OrderEmailServiceWrapperHelper.createPORMap(subscriptions);
        Map<String, String> attributeMap = OrderEmailServiceWrapperHelper.createAttributeMap(subscriptions);
        Set<String> orderIdSet = new Set<String>();
        List<csord__Subscription__c> nonAMMSSubscriptionList = new List<csord__Subscription__c>();
        for (csord__Subscription__c subscription :subscriptions){
            System.debug('Offer Id :: ' + subscription.MarketableOffer__r.Offer_ID__c);
            System.debug('Type :: ' + subscription.csordtelcoa__Product_Configuration__r.Type__c);
            //DIGI-25281
            if(FeatureToggle__mdt.getInstance('enableTED217').EnableForAll__c == false){
                if(subscription.MarketableOffer__r.Offer_ID__c == BDS_Notify_Settings__c.getValues('Adaptive Mobility Managed Services').Value__c){
					orderIdSet.add(subscription.csord__Order__c);                    
                }else {
                    nonAMMSSubscriptionList.add(subscription);
                }               
            }else{
                if(subscription.MarketableOffer__r.Offer_ID__c == BDS_Notify_Settings__c.getValues('Adaptive Mobility Managed Services').Value__c
                  || subscription.MarketableOffer__r.Offer_ID__c == BDS_Notify_Settings__c.getValues('Intune Management').Value__c) { //DIGI-25281
                    orderIdSet.add(subscription.csord__Order__c);
                }else {
                    nonAMMSSubscriptionList.add(subscription);
                }                
            }
        }
        System.debug('Id :: '+orderIdSet);
        System.debug('nonAMMSSubscriptionList' + nonAMMSSubscriptionList);
        Map<String, List<csord__Subscription__c>> subscriptionOrderMap = new Map<String, List<csord__Subscription__c>>();
        for (String orderId: orderIdSet) {
            System.debug('orderId :: ' + orderId);
            List<csord__Subscription__c> filteredSub = new List<csord__Subscription__c> ();
            for (csord__Subscription__c subscription :subscriptions){
                //DIGI-25281
                if(FeatureToggle__mdt.getInstance('enableTED217').EnableForAll__c == false){
                	if((subscription.csord__Order__c == orderId) && (subscription.MarketableOffer__r.Offer_ID__c == BDS_Notify_Settings__c.getValues('Adaptive Mobility Managed Services').Value__c)) {
                    	System.debug('subscription :: ' + subscription);
                    	filteredSub.add(subscription);                    
                	}
                }else{
                	if((subscription.csord__Order__c == orderId) && (subscription.MarketableOffer__r.Offer_ID__c == BDS_Notify_Settings__c.getValues('Adaptive Mobility Managed Services').Value__c)) {
                    	System.debug('subscription :: ' + subscription);
                    	filteredSub.add(subscription);
                    	//DIGI-25281
                	}else if ((orderStatus == 'Completed') && (subscription.csord__Order__c == orderId) && (subscription.MarketableOffer__r.Offer_ID__c == BDS_Notify_Settings__c.getValues('Intune Management').Value__c)) {
                    	System.debug('Intune subscription :: ' + subscription);
                    	filteredSub.add(subscription);
                	}
            	}
            }
            System.debug('filteredSub :: ' + filteredSub);
            subscriptionOrderMap.put(orderId, filteredSub);
        }
        System.debug('subscriptionMap :: '+ subscriptionOrderMap);

        notifyEvents.addAll(nonAMMSFlow(nonAMMSSubscriptionList, orderStatus, porMap));
        notifyEvents.addAll(ammsFlow(subscriptionOrderMap, orderStatus, attributeMap, porMap));
        
        //Added by Nikhil as part of DIGI-4694
        if(!notifyEvents.isEmpty()){
            createBDSPlatformEvent(notifyEvents);
        }
    }

    public static List<BDS_Notification_Event__e> nonAMMSFlow(List<csord__Subscription__c> nonAMMSSubscriptionList, String orderStatus, Map<String, Partner_of_Record__c> porMap) {
//DIGI-19162 : Declaring the List and Map
List<BDS_Notify_Settings__c> bdsNotifyList = new List<BDS_Notify_Settings__c>([SELECT Id,OfferID__c,triggerOrderNotifications__c,
useSettingFor__c,Is_SI5_Offer__c,Value__c FROM 
BDS_Notify_Settings__c 
WHERE useSettingFor__c = 'offerIdCheck']);
Map<String,BDS_Notify_Settings__c> offerOrderNotifySettingMap= new Map<String,BDS_Notify_Settings__c>();
        List<BDS_Notification_Event__e> notifyEvents = new List<BDS_Notification_Event__e>();
        for(BDS_Notify_Settings__c bds:bdsNotifyList ){
            offerOrderNotifySettingMap.put(bds.OfferID__c,bds);
        } 
        for (csord__Subscription__c subscription : nonAMMSSubscriptionList) {
            Partner_of_Record__c por = porMap.get(subscription.Id);
            
            System.debug('Marketable Offer Id :: ' + subscription.MarketableOffer__r.Offer_ID__c);
            System.debug('Adaptive Mobility Care :: ' + BDS_Notify_Settings__c.getValues('Adaptive Mobility Care').Value__c);
            System.debug('Professional  Services - TMDM :: ' + BDS_Notify_Settings__c.getValues('Professional Services - TMDM').Value__c);

            if((subscription.MarketableOffer__r.Offer_ID__c == offerOrderNotifySettingMap.get('DMCAT_Offer_001251').OfferID__c ) 
                    && (subscription.csordtelcoa__Product_Configuration__r.Type__c == 'New')
                    && (orderStatus == 'Complete') ) {
                        System.debug('Before amcNewComplete');
                notifyEvents.add(amcNewComplete(subscription, por));
            }
            else if((subscription.MarketableOffer__r.Offer_ID__c == offerOrderNotifySettingMap.get('DMCAT_Offer_001251').OfferID__c ) 
                    && (subscription.csordtelcoa__Product_Configuration__r.Type__c == 'Cancel')
                    && (orderStatus == 'Complete') ) {
                notifyEvents.add(amcCancelComplete(subscription, por));
            }
            else if((subscription.MarketableOffer__r.Offer_ID__c == offerOrderNotifySettingMap.get('DMCAT_Offer_000750').OfferID__c ) 
                    && (subscription.csordtelcoa__Product_Configuration__r.Type__c == 'New')
                    && (orderStatus == 'InProgress') ) {
                notifyEvents.add(tmdmNewInProgress(subscription, por));
            }
            else if((subscription.MarketableOffer__r.Offer_ID__c == offerOrderNotifySettingMap.get('DMCAT_Offer_000750').OfferID__c ) 
                    && (subscription.csordtelcoa__Product_Configuration__r.Type__c == 'New')
                    && (orderStatus == 'Complete') ) {
                notifyEvents.add(tmdmNewComplete(subscription, por));
            }
 //DIGI-19162 : Adding new condition for LifeCycleManagement
 else if((subscription.MarketableOffer__r.Offer_ID__c == offerOrderNotifySettingMap.get('DMCAT_Offer_001551').OfferID__c ) 
 && ((subscription.csordtelcoa__Product_Configuration__r.Type__c == 'New')||
 (subscription.csordtelcoa__Product_Configuration__r.Type__c == 'Cancel'))
 && (orderStatus == 'Complete')){
     notifyEvents.add(lifecycleComplete(subscription, por));
 }

        }
        return notifyEvents;

    }
    //DIGI-19162 : Added a new method for lifecycle Offer
    //START
    public static BDS_Notification_Event__e lifecycleComplete(csord__Subscription__c subscription, Partner_of_Record__c por){
        BDS_Notification_Event__e event = commonValues(subscription);
        if(subscription.csordtelcoa__Product_Configuration__r.Type__c == 'New'){
            event.Event_Type__c = 'ORDER_NEW_COMPLETE';
        }
        else if(subscription.csordtelcoa__Product_Configuration__r.Type__c == 'Cancel'){
            event.Event_Type__c = 'ORDER_CANCEL_COMPLETE';
        }        
        event.Event_Details__c = createAmsJson(subscription, por);        
        System.debug('Inside lifecycleComplete');
        System.debug('event : '+ event);
        return event;  
    }
    //END
    public static List<BDS_Notification_Event__e> ammsFlow(Map<String, List<csord__Subscription__c>> subscriptionOrderMap, String orderStatus, Map<String, String> attributeMap, Map<String, Partner_of_Record__c> porMap) {

        List<BDS_Notification_Event__e> notifyEvents = new List<BDS_Notification_Event__e>();
        
        for(String key : subscriptionOrderMap.keySet()){
            List<csord__Subscription__c> subscriptionList = subscriptionOrderMap.get(key);
            String orderType = subscriptionList.get(0).csordtelcoa__Product_Configuration__r.Type__c;
            Partner_of_Record__c por = porMap.get(subscriptionList.get(0).Id);
            
            if((orderType == 'New') && (orderStatus == 'Complete')) {
                notifyEvents.add(ammsNewComplete(subscriptionList, por, attributeMap));
            }
            else if((orderType == 'New') && (orderStatus == 'InProgress')) {
                notifyEvents.add(ammsNewInProgress(subscriptionList, por, attributeMap));
            }
            else if((orderType == 'Cancel') && (orderStatus == 'Complete')) {
                notifyEvents.add(ammsCancelComplete(subscriptionList, por, attributeMap));
            }
            else if((orderType == 'Modify') && (orderStatus == 'InProgress')) {
                notifyEvents.add(ammsModifyInProgress(subscriptionList, por, attributeMap));
            }
            else if((orderType == 'Modify') && (orderStatus == 'Complete')) {
                notifyEvents.add(ammsModifyComplete(subscriptionList, por, attributeMap));
            }
        }
        return notifyEvents;

    }

    public static BDS_Notification_Event__e amcNewComplete(csord__Subscription__c subscription, Partner_of_Record__c por) {

        BDS_Notification_Event__e event = commonValues(subscription);

        event.Event_Type__c = 'ORDER_NEW_COMPLETE';
        event.Event_Details__c = createAmsJson(subscription, por);
        
        System.debug('Inside amcNewComplete');
        System.debug('event : '+ event);

        return event;
    }

    public static BDS_Notification_Event__e amcCancelComplete(csord__Subscription__c subscription, Partner_of_Record__c por) {

        BDS_Notification_Event__e event = commonValues(subscription);

        event.Event_Type__c = 'ORDER_CANCEL_COMPLETE';
        event.Event_Details__c = createAmsJson(subscription, por);

        System.debug('Inside amcCancelComplete');
        System.debug('event : '+ event);
        
        return event;
    }

    public static BDS_Notification_Event__e tmdmNewInProgress(csord__Subscription__c subscription, Partner_of_Record__c por) {

        BDS_Notification_Event__e event = commonValues(subscription);

        event.Event_Type__c = 'ORDER_NEW_INPROGRESS';
        event.Event_Details__c = createTmdmJson(subscription, por);
        
        System.debug('Inside tmdmNewInProgress');
        System.debug('event : '+ event);
       
        return event;
    }

    public static BDS_Notification_Event__e tmdmNewComplete(csord__Subscription__c subscription, Partner_of_Record__c por) {

        BDS_Notification_Event__e event = commonValues(subscription);
        
        event.Event_Type__c = 'ORDER_NEW_COMPLETE';
        event.Event_Details__c = createTmdmJson(subscription, por);
        
        System.debug('Inside tmdmNewComplete');
        System.debug('event : '+ event);
        
        return event;
    }

    public static BDS_Notification_Event__e ammsNewInProgress(List<csord__Subscription__c> subscriptionList, Partner_of_Record__c por, Map<String, String> attributeMap) {

        BDS_Notification_Event__e event = commonValues(subscriptionList.get(0));
        
        event.Event_Type__c = 'ORDER_NEW_INPROGRESS';
        event.Event_Details__c = createAmmsJson(subscriptionList, por, attributeMap);
        
        System.debug('Inside ammsNewInProgress');
        System.debug('event : '+ event);
        
        return event;
    }

    public static BDS_Notification_Event__e ammsNewComplete(List<csord__Subscription__c> subscriptionList, Partner_of_Record__c por, Map<String, String> attributeMap) {

        BDS_Notification_Event__e event = commonValues(subscriptionList.get(0));
        
        event.Event_Type__c = 'ORDER_NEW_COMPLETE';
        event.Event_Details__c = createAmmsJson(subscriptionList, por, attributeMap);
        
        System.debug('Inside ammsNewComplete');
        System.debug('event : '+ event);
        
        return event;
    }

    public static BDS_Notification_Event__e ammsCancelComplete(List<csord__Subscription__c> subscriptionList, Partner_of_Record__c por, Map<String, String> attributeMap) {

        BDS_Notification_Event__e event = commonValues(subscriptionList.get(0));
        
        event.Event_Type__c = 'ORDER_CANCEL_COMPLETE';
        event.Event_Details__c = createAmmsJson(subscriptionList, por, attributeMap);
        
        System.debug('Inside ammsCancelComplete');
        System.debug('event : '+ event);
        
        return event;
    }

    public static BDS_Notification_Event__e ammsModifyInProgress(List<csord__Subscription__c> subscriptionList, Partner_of_Record__c por, Map<String, String> attributeMap) {

        BDS_Notification_Event__e event = commonValues(subscriptionList.get(0));
        
        event.Event_Type__c = 'ORDER_MODIFY_INPROGRESS';
        event.Event_Details__c = createAmmsModifyInProgressJson(subscriptionList, por, attributeMap);
        
        System.debug('Inside ammsModifyInProgress');
        System.debug('event : '+ event);
        
        return event;
    }

    public static BDS_Notification_Event__e ammsModifyComplete(List<csord__Subscription__c> subscriptionList, Partner_of_Record__c por, Map<String, String> attributeMap) {

        BDS_Notification_Event__e event = commonValues(subscriptionList.get(0));
        
        event.Event_Type__c = 'ORDER_MODIFY_COMPLETE';
        event.Event_Details__c = createAmmsJson(subscriptionList, por, attributeMap);
        
        System.debug('Inside ammsModifyComplete');
        System.debug('event : '+ event);
        
        return event;
    }

    public static BDS_Notification_Event__e commonValues(csord__Subscription__c subscription) {

        BDS_Notification_Event__e event = new BDS_Notification_Event__e();
        
        event.Business_Entity__c = 'Account';
        event.Offer_Name__c = subscription.MarketableOffer__r.Name;
        event.Offer_ID__c = subscription.MarketableOffer__r.Offer_ID__c;
        event.Entity_ID__c = subscription.csord__Account__r.Id;
        event.CorrelationId__c = IntegrationRecordHandlerUtil.getCorrelationId();

        return event;

    }

    public static Map<String, String> createNameValuePair(String name, String value) {
        return new Map<String, String>{'value' => value, 'name' => name};

    }

    public static String createAmsJson(csord__Subscription__c subscription, Partner_of_Record__c por) {

        return JSON.serialize(
            new List<Map<String, String>> {createNameValuePair('Agreement_Reference__c', subscription.ContractJunction__r.Contract_Number__c),
                createNameValuePair('Order_Number__c', subscription.csord__Order__r.csord__Order_Number__c),
                createNameValuePair('Billing_Account_Number__c', subscription.Billing_Account__r.Billing_Account_Number__c),
                createNameValuePair('POR_Name__c', por.Partner_Signatories__r.Name),
                createNameValuePair('POR_Phone__c', por.Partner_Signatories__r.Phone),
                createNameValuePair('POR_Email__c', por.Partner_Signatories__r.Email)}
          );
    }

    public static String createTmdmJson(csord__Subscription__c subscription, Partner_of_Record__c por) {

        return JSON.serialize(
            new List<Map<String, String>> {createNameValuePair('Agreement_Reference__c', subscription.ContractJunction__r.Contract_Number__c),
                createNameValuePair('Order_Number__c', subscription.csord__Order__r.csord__Order_Number__c),
                createNameValuePair('Billing_Account_Number__c', subscription.Billing_Account__r.Billing_Account_Number__c),
                createNameValuePair('Tenancy_Id__c', subscription.TenancyID__c),
                createNameValuePair('POR_Name__c', por.Partner_Signatories__r.Name),
                createNameValuePair('POR_Phone__c', por.Partner_Signatories__r.Phone),
                createNameValuePair('POR_Email__c', por.Partner_Signatories__r.Email)}
          );
    }

    public static String createAmmsJson(List<csord__Subscription__c> subscriptionList, Partner_of_Record__c por, Map<String, String> attributeMap) {
        
        String platformManagement = '';
        String userSupport = '';
        
        System.debug('attributeMap :: inside createAmmsJson :: ' + attributeMap);

        for(csord__Subscription__c subscription : subscriptionList){

            if(subscription.csordtelcoa__Product_Configuration__r.Name.Contains(BDS_Notify_Settings__c.getValues('User Support').Value__c)){
                userSupport = attributeMap.get(subscription.Id);
            } else if(subscription.csordtelcoa__Product_Configuration__r.Name.Contains(BDS_Notify_Settings__c.getValues('Platform Management').Value__c)) {
                platformManagement = attributeMap.get(subscription.Id);
            }

        }

        csord__Subscription__c subscription = subscriptionList.get(0);        
        
        return JSON.serialize(
            new List<Map<String, String>> {createNameValuePair('Agreement_Reference__c', subscription.ContractJunction__r.Contract_Number__c),
                createNameValuePair('Order_Number__c', subscription.csord__Order__r.csord__Order_Number__c),
                createNameValuePair('Billing_Account_Number__c', subscription.Billing_Account__r.Billing_Account_Number__c),
                createNameValuePair('POR_Name__c', por.Partner_Signatories__r.Name),
                createNameValuePair('POR_Phone__c', por.Partner_Signatories__r.Phone),
                createNameValuePair('POR_Email__c', por.Partner_Signatories__r.Email),
                createNameValuePair('Tenancy_Id__c', subscription.TenancyID__c),
                createNameValuePair('Platform_Mgmt__c', platformManagement),
                createNameValuePair('User_Support__c', userSupport)}
          );
    }

    public static String createAmmsModifyInProgressJson(List<csord__Subscription__c> subscriptionList, Partner_of_Record__c por, Map<String, String> attributeMap) {

        String platformManagementFrom = '';
        String userSupportFrom = '';
        String platformManagementTo = '';
        String userSupportTo = '';

        List<Id> subscriptionIdsFrom = new List<Id>();

        for(csord__Subscription__c subscription : subscriptionList){
            System.debug('subscription createAmmsModifyInProgressJson :: ' + subscription);

            if(subscription.csordtelcoa__Product_Configuration__r.Name.Contains(BDS_Notify_Settings__c.getValues('User Support').Value__c)){
                userSupportTo = attributeMap.get(subscription.Id);
            } else if(subscription.csordtelcoa__Product_Configuration__r.Name.Contains(BDS_Notify_Settings__c.getValues('Platform Management').Value__c)){
                platformManagementTo = attributeMap.get(subscription.Id);
            }
            System.debug('subscription :: ' + subscription.csordtelcoa__Replaced_Subscription__r.Id);
            subscriptionIdsFrom.add(subscription.csordtelcoa__Replaced_Subscription__r.Id);

        }

        System.debug('subscriptionIdsFrom :: ' + subscriptionIdsFrom);
        List<csord__Subscription__c> subscriptionsFrom = OrderEmailServiceWrapperHelper.fetchReplacedSubscription(subscriptionIdsFrom);
        System.debug('subscriptionsFrom :: ' + subscriptionsFrom);
        
        Map<String, String> attributeMapFrom = OrderEmailServiceWrapperHelper.createAttributeMap(subscriptionsFrom);

        for(csord__Subscription__c subscription : subscriptionsFrom){

            if(subscription.csordtelcoa__Product_Configuration__r.Name.contains(BDS_Notify_Settings__c.getValues('User Support').Value__c)){
                userSupportFrom = attributeMapFrom.get(subscription.Id);
            } else if(subscription.csordtelcoa__Product_Configuration__r.Name.contains(BDS_Notify_Settings__c.getValues('Platform Management').Value__c)) {
                platformManagementFrom = attributeMapFrom.get(subscription.Id);
            }

        }

        csord__Subscription__c subscription = subscriptionList.get(0);
        csord__Subscription__c subscriptionFrom = subscriptionList.get(0);
        
        if(subscriptionsFrom.size() > 0){
            subscriptionFrom = subscriptionsFrom.get(0);            
        }        
        
        return JSON.serialize(
            new List<Map<String, String>> {createNameValuePair('Agreement_Reference__c', subscription.ContractJunction__r.Contract_Number__c),
                createNameValuePair('Order_Number__c', subscription.csord__Order__r.csord__Order_Number__c),
                createNameValuePair('Billing_Account_Number__c', subscription.Billing_Account__r.Billing_Account_Number__c),
                createNameValuePair('POR_Name__c', por.Partner_Signatories__r.Name),
                createNameValuePair('POR_Phone__c', por.Partner_Signatories__r.Phone),
                createNameValuePair('POR_Email__c', por.Partner_Signatories__r.Email),
                createNameValuePair('Tenancy_Id_From__c', subscriptionFrom.TenancyID__c),
                createNameValuePair('Tenancy_Id_To__c', subscription.TenancyID__c),
                createNameValuePair('Platform_Mgmt_From__c', platformManagementFrom),
                createNameValuePair('Platform_Mgmt_To__c', platformManagementTo),
                createNameValuePair('User_Support_From__c', userSupportFrom),
                createNameValuePair('User_Support_To__c', userSupportTo)}
          );
    }

    public static List<BDS_Notification_Event__e> triggerTimeBoundPlatformEvent() {

        List<TimeBased_Notification_Settings__c> tbnSettingsList = getTBNSettings();
        List<BDS_Notification_Event__e> bdsNotificationEventList = new List<BDS_Notification_Event__e>();

        for(TimeBased_Notification_Settings__c tbnSettings : tbnSettingsList) {
            Boolean isMarketableOffer = checkForMarketableOffer(tbnSettings);

            List<BDS_Notification_Event__e> bdsNotificationEvents = new List<BDS_Notification_Event__e>();

            if(isMarketableOffer) {
                List<csord__Subscription__c> subscriptionList = OrderEmailServiceWrapperHelper.fetchSubscriptionsMO(tbnSettings.Specification_Id__c);
                bdsNotificationEvents = createNotifyEventMO(subscriptionList, tbnSettings);

            } else {
                Map<String, List<csord__Service__c>> serviceMap = OrderEmailServiceWrapperHelper.fetchServicesPS(tbnSettings.Specification_Id__c);
                bdsNotificationEvents = createNotifyEventPS(serviceMap, tbnSettings);
            }
            
            for(BDS_Notification_Event__e event : bdsNotificationEvents){
                bdsNotificationEventList.add(event);
            }
        }
        return bdsNotificationEventList;

    }

    public static List<BDS_Notification_Event__e> createNotifyEventMO(List<csord__Subscription__c> subscriptions, TimeBased_Notification_Settings__c tbnSettings) {
        
        Boolean isFreqTypeMonthly = checkFrequencyTypeMonthly(tbnSettings);
        
        Map<Id, csord__Service__c> serviceMap = OrderEmailServiceWrapperHelper.createServiceMap(subscriptions);
        List<BDS_Notification_Event__e> bdsNotificationEvents = new List<BDS_Notification_Event__e>();

        for (csord__Subscription__c subscription : subscriptions) {
            csord__Service__c service = serviceMap.get(subscription.Id);
            
            if((null != service) && (null != service.Initial_Activation_Date__c)) {
    
                Date intermediateTrialEndDate = calculateIntermediateExpiryDate(service.Initial_Activation_Date__c, isFreqTypeMonthly, Integer.valueOf(tbnSettings.Promotion_Frequency_Value__c));
                Date finalTrialEndDate = calculateFinalExpiryDate(intermediateTrialEndDate, tbnSettings.Promotion_Cycle_Type__c, Integer.valueOf(subscription.Billing_Account__r.BillCycleday__c));
                Integer numberOfDaysDiff = Date.today().daysBetween(finalTrialEndDate);

                if(platformEventToBeTrigerred(numberOfDaysDiff, tbnSettings.Mail_Trigger_Duration__c) && isBillCycleDatePopulated(tbnSettings.Promotion_Cycle_Type__c, Integer.valueOf(subscription.Billing_Account__r.BillCycleday__c))){
                    BDS_Notification_Event__e event = commonValues(subscription);

                    event.CorrelationId__c = IntegrationRecordHandlerUtil.getCorrelationId();
                    event.Entity_ID__c = subscription.csord__Account__r.Id;
                    event.Event_Details__c = createTimeBoundJson(subscription, Integer.valueOf(tbnSettings.Promotion_Frequency_Value__c), finalTrialEndDate, service);
                   // This is specific to TMDM
                    event.Event_Type__c = 'ORDER_TRIAL_NOTIFY';
                    
                        
                        
                    bdsNotificationEvents.add(event);

                }
    
            }
        }
        return bdsNotificationEvents;

    }

    public static String createTimeBoundJson(csord__Subscription__c subscription, Integer promotionFrequencyValue, Date finalTrialEndDate, csord__Service__c service) {
        
        //Date trialEndDate = finalTrialEndDate.addDays(promotionFrequencyValue - 1);
        
        Integer d = finalTrialEndDate.day();
        Integer mo = finalTrialEndDate.month();
        Integer yr = finalTrialEndDate.year();
        DateTime trialEndDateTime = DateTime.newInstance(yr, mo, d);
                
        return JSON.serialize(
            new List<Map<String, String>> {createNameValuePair('Billing_Account_Number__c', subscription.Billing_Account__r.Billing_Account_Number__c),
                createNameValuePair('Tenancy_Id__c', subscription.TenancyID__c),
                createNameValuePair('Free_trial_days__c', String.valueof(promotionFrequencyValue)),
                createNameValuePair('Trial_end_date__c', String.valueof(trialEndDateTime))}
          );
    }
    
    public static void createBDSPlatformEvent(List<BDS_Notification_Event__e> bdsNotificationEvents) {
        List<Database.SaveResult> results = EventBus.publish(bdsNotificationEvents);
        
        String handlerName = 'BDSNotify';
        String statusCode = '';
        String errorMssg = '';
        Logger2 logger = Logger2.getLogger(handlerName);
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    statusCode = statusCode + ','  + err.getStatusCode();
                    errorMssg = errorMssg + ',' + err.getMessage();
                    logger.logMessages('BDS Notify Event', 'Error', '', '', String.valueOf(err.getStatusCode()), err.getMessage(), false, false );
                }
            }
        }
        logger.logMessages(JSON.serialize(bdsNotificationEvents), JSON.serialize(results), '', 'Functional', statusCode, errorMssg, false, false, null,null,null,null);
        logger.exitLogger();	
    }

    public static List<TimeBased_Notification_Settings__c> getTBNSettings(){

        Map<String, TimeBased_Notification_Settings__c> TBNSettingMap = TimeBased_Notification_Settings__c.getAll();
        System.debug(TBNSettingMap);
        List<TimeBased_Notification_Settings__c> TBNSettingList = new List<TimeBased_Notification_Settings__c>();
        
        for(String name : TBNSettingMap.keySet()) {
        
            TimeBased_Notification_Settings__c tbn = TBNSettingMap.get(name);
            TBNSettingList.add(tbn);
            System.debug('bds  :: ' + tbn);
        }
        
        return TBNSettingList;

    }

    public static Boolean checkForMarketableOffer(TimeBased_Notification_Settings__c tbnSettings){
        if (tbnSettings.Specification_Type__c == 'MARKETABLE_OFFER'){
            return true;
        } else {
            return false;
        }

    }

    public static Boolean checkFrequencyTypeMonthly(TimeBased_Notification_Settings__c tbnSettings){
        if (tbnSettings.Promotion_Frequency_Type__c == 'MONTHLY'){
            return true;
        } else {
            return false;
        }
    }

    public static Date calculateIntermediateExpiryDate(Date activationDate, Boolean isMonthly, Integer frequencyValue){

        if(isMonthly){
            return activationDate.addMonths(frequencyValue);
        } else {
            return activationDate.addDays(frequencyValue);
        }

    }

    public static Date calculateFinalExpiryDate(Date intermediateTrialEndDate, String promotionCycleType, Integer billingCycleDate){

        if((null != billingCycleDate) && (promotionCycleType == 'BILLING_CYCLE')){
            return getBillingEndDate(intermediateTrialEndDate, billingCycleDate);
        } else {
            return intermediateTrialEndDate;
        }

    }

    public static Date getBillingEndDate(Date intermediateTrialEndDate, Integer billingCycleDate) {

        Integer d = intermediateTrialEndDate.day();
        Integer mo = intermediateTrialEndDate.month();
        Integer yr = intermediateTrialEndDate.year();

        if(d > billingCycleDate){
            mo = mo + 1;
            if(mo == 13){
                mo = 1;
                yr = yr + 1;
            }
        }
        return Date.newInstance(yr, mo, billingCycleDate);

    }

    public static boolean platformEventToBeTrigerred(Integer numberOfDaysDiff, String mailTriggerDurationString){

        List<String> mailTriggerDurationList = mailTriggerDurationString.split(',');
        for(String mailTriggerDuration : mailTriggerDurationList){
            if(numberOfDaysDiff == Integer.valueOf(mailTriggerDuration)){
                return true;
            }
        }
        return false;

    }

    public static Boolean isBillCycleDatePopulated(String promotionCycleType, Integer billingCycleDate){
        if((promotionCycleType == 'BILLING_CYCLE') && (null == billingCycleDate)) {
            return false;
        }
        return true;

    }

    public static List<BDS_Notification_Event__e> createNotifyEventPS(Map<String, List<csord__Service__c>> serviceMap, TimeBased_Notification_Settings__c tbnSettings) {
    
        List<BDS_Notification_Event__e> bdsNotificationEvents = new List<BDS_Notification_Event__e>();
        Boolean isFreqTypeMonthly = checkFrequencyTypeMonthly(tbnSettings);
        for(String billingAccNumber : serviceMap.keySet()){
            //List<csord__Service__c> serviceList = serviceMap.get(key);
            Map<Date, List<csord__Service__c>>serviceMapDate = fetchServicesActivationDate(serviceMap.get(billingAccNumber));
            for(Date activationDate : serviceMapDate.keySet()){

                List<csord__Service__c> serviceList = serviceMapDate.get(activationDate);
                csord__Service__c firstService =  serviceList.get(0);
                Date intermediateTrialEndDate = calculateIntermediateExpiryDate(activationDate, isFreqTypeMonthly, Integer.valueOf(tbnSettings.Promotion_Frequency_Value__c));
                Date finalTrialEndDate = calculateFinalExpiryDate(intermediateTrialEndDate, tbnSettings.Promotion_Cycle_Type__c, Integer.valueOf(firstService.csord__Subscription__r.Billing_Account__r.BillCycleday__c));
                Integer numberOfDaysDiff = Date.today().daysBetween(finalTrialEndDate);

                if(platformEventToBeTrigerred(numberOfDaysDiff, tbnSettings.Mail_Trigger_Duration__c) && isBillCycleDatePopulated(tbnSettings.Promotion_Cycle_Type__c, Integer.valueOf(firstService.csord__Subscription__r.Billing_Account__r.BillCycleday__c))){
                    BDS_Notification_Event__e event = commonValuesPS(firstService);

                    event.Event_Details__c = createTimeBoundJsonPS(serviceList, Integer.valueOf(tbnSettings.Promotion_Frequency_Value__c), finalTrialEndDate, tbnSettings.Promotion_Name__c, billingAccNumber);
                    //event.Event_Type__c = 'ORDER_TRIAL_NOTIFY';
                     event.Event_Type__c = system.label.eventNotification;
                        
                        
                    bdsNotificationEvents.add(event);

                }
            }
        }

        return bdsNotificationEvents;

    }   

    public static BDS_Notification_Event__e commonValuesPS(csord__Service__c service) {

        BDS_Notification_Event__e event = new BDS_Notification_Event__e();
        
        event.Business_Entity__c = 'Account';
        event.Offer_Name__c = service.csord__Subscription__r.MarketableOffer__r.Name;
        event.Offer_ID__c = service.csord__Subscription__r.MarketableOffer__r.Offer_ID__c;
        event.Entity_ID__c = service.csord__Order__r.csord__Account__c;
        event.CorrelationId__c = IntegrationRecordHandlerUtil.getCorrelationId();

        return event;

    }

    public Static Map<Date, List<csord__Service__c>> fetchServicesActivationDate(List<csord__Service__c> serviceList){

        Map<Date, List<csord__Service__c>> servicemap = new Map<Date, List<csord__Service__c>>();
        for (csord__Service__c service : serviceList )
        {
            Date key = service.Initial_Activation_Date__c;
            if (!servicemap.containsKey( key ))
                servicemap.put( key, new List<csord__Service__c> ());
            servicemap.get( key ).add( service );
        }

       return servicemap;

    }

    

    public static String createTimeBoundJsonPS(List<csord__Service__c> services, Integer promotionFrequencyValue, Date finalTrialEndDate, String promotionName, String billingAccNumber) {
        
        //Date trialEndDate = service.Initial_Activation_Date__c.addDays(promotionFrequencyValue - 1);
        
        Integer d = finalTrialEndDate.day();
        Integer mo = finalTrialEndDate.month();
        Integer yr = finalTrialEndDate.year();
        DateTime trialEndDateTime = DateTime.newInstance(yr, mo, d);

        String serviceList = createServiceList(services);
                
        return JSON.serialize(
            new List<Map<String, String>> {createNameValuePair('Billing_Account_Number__c', billingAccNumber),
                createNameValuePair('Free_trial_days__c', String.valueof(promotionFrequencyValue)),
                createNameValuePair('Promotion_name__c', String.valueof(promotionName)),
                createNameValuePair('Trial_end_date__c', String.valueof(trialEndDateTime)),
                createNameValuePair('Service_list__c', String.valueof(serviceList))}
          );
    }

    public static String createServiceList(List<csord__Service__c> services){
        String serviceList = '';
        Integer index = 0;

        for(csord__Service__c service : services){
            serviceList = serviceList + service.csord__Subscription__r.serviceMSISDN__c + ':' + service.csord__Order__r.csord__Order_Number__c;
            index = index + 1;
            if(index < services.size()){
                serviceList = serviceList + ',';
            }
        }
        return serviceList;
    }
    
    /***************************************************************************************
    * Method Name     - notifyEventsForSubscriptions
    * Developer Name  - Nikhil Sharma
    * Story           - DIGI-4694
    * Description     - This method is used to fire BDS_Notification_Event
    * 				    platform event for DMS.
    ****************************************************************************************/
    public static void notifyEventsForSubscriptions(Map<Id,csord__Subscription__c> mapOfDMSSubscriptions){
        List<BDS_Notification_Event__e> notifyEvents = new List<BDS_Notification_Event__e>();
        try{
            for(csord__Subscription__c subscription : mapOfDMSSubscriptions.values()){
                //fill commonValues from subcriptions
                BDS_Notification_Event__e event = commonValues(subscription);
                //fill Order status 
                String orderStatus = subscription.csord__Status__c?.equalsIgnoreCase(C2O_OrderConstants.STATUS_PROVISIONING_IN_PROGRESS) ? 'INPROGRESS' : 'COMPLETE';
                //fill event type
                event.Event_Type__c = getEventType(subscription.csordtelcoa__Product_Configuration__r.Type__c,orderStatus);
                event.Event_Details__c = JSON.serialize(
                    new List<Map<String, String>> {createNameValuePair('Agreement_Reference__c', subscription.ContractJunction__r?.Contract_Number__c),
                        createNameValuePair('Order_Number__c', subscription.csord__Order__r.csord__Order_Number__c),
                        createNameValuePair('Billing_Account_Number__c', subscription.Billing_Account__r.Billing_Account_Number__c)});
                notifyEvents.add(event);
            }
            if(!notifyEvents.isEmpty()){
                //called method to  fire platform event
                createBDSPlatformEvent(notifyEvents);
            }
        }catch(Exception e){
            //Exception log
            logException('notifyEventsForSubscriptions','',correlationId, e.getMessage(), 'creation of BDS Platform Event for DMS as failed.',CONST_INTERFACENAME);
        }
    }
    
     /***************************************************************************************
    * Method Name    -  getEventType
    * Developer Name -  Nikhil Sharma
    * Story          -  DIGI-4694
    * Description    -  This method is used to get event type based on 
    * 				    product configuration type and order Status.
    ****************************************************************************************/
    public static String getEventType(String productConfigurationType, String orderStatus){
        String eventType =  'ORDER_'+productConfigurationType+'_'+orderStatus;
        return eventType.toUpperCase();
    }
    
    /*----------------------------------------------------------------
    Method     : logException
    Description: Method to create log exceptions
    Author     : Nikhil Sharma
    Story      : DIGI-4694 
    -------------------------------------------------------------------------------------*/ 
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription,String CONST_INTERFACENAME){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
}