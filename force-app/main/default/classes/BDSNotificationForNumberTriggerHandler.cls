/*********************************************************************************************************************************
Class Name : BDSNotificationForNumberTriggerHandler
Test Class : SubscriptionCustomTriggerHandlerTest
Created By : Nikhil Sharma
Created On : 23 June 2021
===============================================================================================================================
*/
public class BDSNotificationForNumberTriggerHandler {
    public static void handleAfterInsert(Map<Id, BDSNotificationForNumber__e > mapOfBDSNotificationForNumber){
        Set<String> setOfSubscriptionNumber = new Set<String>();
        Set<String> setOfNGUCSubscriptionNumber = new Set<String>();
        Logger2 logger = Logger2.getLogger('BDSNotificationForNumberTriggerHandler');
        try{
            for(BDSNotificationForNumber__e eve : mapOfBDSNotificationForNumber.values()){
                setOfSubscriptionNumber.add(eve.SubscriptionNumber__c);
            }
            Offer_Id__mdt offerIdMdt = Offer_Id__mdt.getInstance('Telstra_Collaboration') ;
            for(csord__Subscription__c subscription : [SELECT Id,csord__Status__c ,csordtelcoa__Subscription_Number__c
                                                       FROM csord__Subscription__c WHERE 
                                                       csordtelcoa__Subscription_Number__c In : setOfSubscriptionNumber
                                                       AND MarketableOffer__r.Offer_ID__c =: offerIdMdt.Label]){
                setOfNGUCSubscriptionNumber.add(subscription.csordtelcoa__Subscription_Number__c);
            }
            
            if(setOfNGUCSubscriptionNumber.size() > 0){
                List<Number__c> listOfNumbers = new List<Number__c>();
                for(Number__c num : [SELECT Id,Invoke_BDS_Notification__c FROM number__c 
                                     WHERE Subscription_number__c In : setOfNGUCSubscriptionNumber
                                     AND Mobile__c = 'Fixed']){
                                         num.Invoke_BDS_Notification__c = true;
                                         listOfNumbers.add(num);
                }
                if(!listOfNumbers.isEmpty()){
                    update listOfNumbers;
                }
            }
        }catch(Exception e){
            logger.logMessages(JSON.serialize(mapOfBDSNotificationForNumber.values()), JSON.serialize(e.getMessage()), '', 'Functional', '', '', false, false, null,null,null,null);
            logger.exitLogger();
        }
    }
}