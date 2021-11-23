/*
===============================================================================================================================
Class : OrderEmailServiceWrapperHelper
Developer Name :Anand Shekhar
Test Class : OrderEmailServiceWrapperHelperTest
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
===============================================================================================================================
*/
public with sharing class OrderEmailServiceWrapperHelper {

    static String featureLevel = BDS_Notify_Settings__c.getValues('Feature Level').Value__c;
    static String technicalSupport = BDS_Notify_Settings__c.getValues('Technical Support').Value__c;
    
    public static Map<String, List<csord__Subscription__c>> ordersSeperation(List<Id> orderIds) {
        //Query will be implemented in a different class
		List<Id> filteredIds = new List<Id>();
        for(csord__Order__c ord : [select Id,csordtelcoa__Opportunity__c,csordtelcoa__Opportunity__r.Type from csord__Order__c where Id IN :orderIds]){
            if( ord.csordtelcoa__Opportunity__c == null || (ord.csordtelcoa__Opportunity__c !=null && ord.csordtelcoa__Opportunity__r.Type != 'Migration')){
                filteredIds.add(ord.Id);
            }
        }
        //DIGI-19162 : Calling Model_Subscription class to fetch the subscription list
        List<csord__Subscription__c> listOfSubscriptions = Model_Subscription.getListOfSubscriptions(filteredIds);
        List<csord__Subscription__c> orderNotifyOfferSubsList = new List<csord__Subscription__c>();
        List<csord__Subscription__c> nonSi5OrderSubscriptions = new List<csord__Subscription__c>();
        Map<String, List<csord__Subscription__c>> seperatedMap = new Map<String, List<csord__Subscription__c>>();
        Map<String,BDS_Notify_Settings__c> notifysettings = OrderEmailServiceWrapperHelper.fetchNotifySettingsOfferCheck();
        
		for (csord__Subscription__c eachSubscription : listOfSubscriptions) {
            //SI5 MArketable Offers will be maintained in a custom settings
            //DIGI-19162
            if (notifysettings.containsKey(eachSubscription.MarketableOffer__r.Offer_ID__c)) {
                orderNotifyOfferSubsList.add(eachSubscription);
            } else {
                nonSi5OrderSubscriptions.add(eachSubscription);
            }
        }
        seperatedMap.put('OtherOrders', nonSi5OrderSubscriptions);
        seperatedMap.put('BDSNotifyOrders', orderNotifyOfferSubsList);
        return seperatedMap;
    }
 //DIGI-19162 Commented as part of the story
    /*public static boolean isSi5Order(csord__Subscription__c subscription){

        List<BDS_Notify_Settings__c> allBDSNotifySettings = BDS_Notify_Settings__c.getall().values();
        for(BDS_Notify_Settings__c bdsNotifySetting : allBDSNotifySettings){
            if((bdsNotifySetting.Value__c == subscription.MarketableOffer__r.Offer_ID__c) && (bdsNotifySetting.Is_SI5_Offer__c)){
                return true;
            }
        }
        return false;
    }*/

    public Static Map<String, Partner_of_Record__c> createPORMap(List<csord__Subscription__c> subscriptionList) {
        
        Set<String> accountIdSet = new Set<String>();
        for (csord__Subscription__c subscription : subscriptionList){
            accountIdSet.add(subscription.csord__Account__r.Id);
        }
         //DIGI-19162 : Added filter condition status__c = Active
        List<Partner_of_Record__c> listOfPOR =[SELECT Id, Partner_Signatories__r.Name, Partner_Signatories__r.Email, Partner_Signatories__r.Phone, Customer__c  
        FROM Partner_of_Record__c WHERE Customer__c IN :accountIdSet AND status__c = 'Active'];

        Map<String, Partner_of_Record__c> porMap = new Map<String, Partner_of_Record__c>();
        for(csord__Subscription__c subscription : subscriptionList) {
            for(Partner_of_Record__c por : listOfPOR){
                if(subscription.csord__Account__r.Id == por.Customer__c){
                    porMap.put(subscription.Id, por);
                    break;
                }
            }
        }
        return porMap;
    }

    public Static Map<String, String> createAttributeMap(List<csord__Subscription__c> subscriptionList) {

        Set<String> pcID = new Set<String>();
        for(csord__Subscription__c subscription : subscriptionList){
            pcId.add(subscription.csordtelcoa__Product_Configuration__r.Id);
        }

        List<cscfga__Attribute__c> attributesList = [SELECT Id, Name, cscfga__Display_Value__c, cscfga__Product_Configuration__c, cscfga__Product_Configuration__r.Name
        FROM cscfga__Attribute__c WHERE cscfga__Product_Configuration__c IN :pcId AND Name IN (:featureLevel, :technicalSupport)];

        Map<String, String> attributeMap = new Map<String, String>();
        String featureLevelShadow = '';
        String technicalSupportShadow = '';
        for(csord__Subscription__c subscription : subscriptionList){
            List<cscfga__Attribute__c> filteredAttributeList = new List<cscfga__Attribute__c>();
            for(cscfga__Attribute__c attribute : attributesList) {
                System.debug('attribute :: ' + attribute);
                System.debug('subscription :: ' + subscription);
                if(subscription.csordtelcoa__Product_Configuration__r.Id == attribute.cscfga__Product_Configuration__c) {
                    if(attribute.Name == featureLevel){
                        featureLevelShadow = attribute.cscfga__Display_Value__c;
                    }
                    if(attribute.Name == technicalSupport){
                        technicalSupportShadow = attribute.cscfga__Display_Value__c;
                    }
                }
            }
            System.debug('AttributeMap Value :: ' + subscription.csordtelcoa__Product_Configuration__r.Name + ' - ' + featureLevelShadow + ' - ' + technicalSupportShadow);
            attributeMap.put(subscription.Id, subscription.csordtelcoa__Product_Configuration__r.Name + ' - ' + featureLevelShadow + ' - ' + technicalSupportShadow);
        }
        return attributeMap;

    }

    public Static List<csord__Subscription__c> fetchReplacedSubscription(List<Id> subscriptionIds){

        return [SELECT ID, csordtelcoa__Product_Configuration__r.Id, csordtelcoa__Product_Configuration__r.Name, TenancyID__c
        FROM csord__Subscription__c WHERE Id IN :subscriptionIds AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' ];

    }

    public Static Map<Id, csord__Service__c> createServiceMap(List<csord__Subscription__c> listOfSubscription){
        Set<Id> subscriptionIds = (new Map<Id,csord__Subscription__c>(listOfSubscription)).keySet();
        List<csord__Service__c> listOfServices =[SELECT Id, Initial_Activation_Date__c, csord__Subscription__r.Id 
        FROM csord__Service__c WHERE csord__Subscription__r.Id in :subscriptionIds AND csord__Status__c='Connected'];

        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
        for(csord__Service__c service : listOfServices) {
            serviceMap.put(service.csord__Subscription__r.Id, service);
        }

        return serviceMap;
    }

    public Static cspmb__Discount_Level__c fetchApplicableDiscount(String discountLevelId){
        
        return [SELECT ID, cspmb__duration__c FROM cspmb__Discount_Level__c WHERE Business_ID__c = :discountLevelId];

    }

    public Static List<csord__Subscription__c> fetchSubscriptionsMO(String marketableOfferId){

       return [SELECT Id, csord__Account__r.Id, MarketableOffer__r.Offer_ID__c, MarketableOffer__r.Name, TenancyID__c, Billing_Account__r.Billing_Account_Number__c, Billing_Account__r.BillCycleday__c FROM csord__Subscription__c WHERE MarketableOffer__r.Offer_ID__c =:marketableOfferId AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent'];

    }

    public Static Map<String, List<csord__Service__c>> fetchServicesPS(String productSpecification){

        Map<String, List<csord__Service__c>> servicemap = new Map<String, List<csord__Service__c>>();
        List<csord__Service__c> services = [SELECT Id, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, csord__Order__r.csord__Account__c, serviceMSISDN__c, csord__Order__r.csord__Order_Number__c, csord__Subscription__r.MarketableOffer__r.Offer_ID__c, csord__Subscription__r.MarketableOffer__r.Name, csord__Subscription__r.Billing_Account__r.Billing_Account_Number__c, csord__Subscription__r.Billing_Account__r.BillCycleday__c, Initial_Activation_Date__c,  csord__Subscription__r.serviceMSISDN__c  FROM csord__Service__c where csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :productSpecification AND csord__Subscription__r.Billing_Account__c != null AND csord__Status__c='Connected'];
        for (csord__Service__c service : services )
        {
            String key = service.csord__Subscription__r.Billing_Account__r.Billing_Account_Number__c;
            if (!servicemap.containsKey( key ))
                servicemap.put( key, new List<csord__Service__c> ());
            servicemap.get( key ).add( service );
        }

       return servicemap;

    }
//DIGI-19162 : New method to query BDSNotify custom setting and forming a MAP
    //START
    public static Map<String,BDS_Notify_Settings__c> fetchNotifySettingsOfferCheck(){
        Map<String,BDS_Notify_Settings__c> offerOrderNotifySettingMap= new Map<String,BDS_Notify_Settings__c>();
        List<BDS_Notify_Settings__c> bdsNotifyList = new List<BDS_Notify_Settings__c>([SELECT Id,OfferID__c,triggerOrderNotifications__c,useSettingFor__c,Is_SI5_Offer__c,Value__c
                                                                                       FROM BDS_Notify_Settings__c
                                                                                       WHERE triggerOrderNotifications__c = true 
                                                                                       AND useSettingFor__c = 'offerIdCheck']);
       system.debug(bdsNotifyList+'checkList'); 
        if(!bdsNotifyList.isEmpty()){
            for(BDS_Notify_Settings__c bds:bdsNotifyList ){
                offerOrderNotifySettingMap.put(bds.OfferID__c,bds);
            } 
        }
        
        return offerOrderNotifySettingMap;
    }
    //END
}