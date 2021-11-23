public with sharing class LinkAgreementSubscription {
    public static void assignSubscriptionToAgreement( List<Id> serviceIds){
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
        Map<Id,Id> subsBasketMap = new Map<Id,Id>();
        try{
            serviceList = [SELECT id, csord__Subscription__c, csordtelcoa__Product_Basket__c from csord__Service__c where id IN: serviceIds];
            for(csord__Service__c serv: serviceList){
                subsBasketMap.put(serv.csord__Subscription__c,serv.csordtelcoa__Product_Basket__c);
            }for(String sub : subsBasketMap.keySet()){
                String basketId = subsBasketMap.get(sub);
                String agreementId = null;
                for(Apttus__APTS_Agreement__c agreement : [select id, name, related_basket__c from Apttus__APTS_Agreement__c where related_basket__c =:basketId and recordType.Name=: Label.PrimaryAgreementRecordType]){
                    agreementId = agreement.id;
                    break;
                }
                if(agreementId!=null){
                    for(csord__Subscription__c subscription : [select id, Agreement__c from csord__Subscription__c where id =:sub]){
                    	subscription.Agreement__c = agreementId;
                     	subsList.add(subscription);
                        break;
                    }
                }
            }
            if(subsList!=null && !subsList.isEmpty()){
                update subsList;
            }
        }
    	catch(Exception e){
        	system.debug('Exception in assignSubscriptionToAgreement method ' + e);
    	}
    }
}