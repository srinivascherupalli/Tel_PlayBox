public with sharing class ObserverImplSubscriptionHelper {
    public static void associateContractJunctionRecord(List<String> SubscriptionIds)
    {
        if(!SubscriptionIds.isEmpty())
        {
            List<csord__Subscription__c> subscriptionList = [select id,ContractJunction__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c from csord__Subscription__c where id in : SubscriptionIds];
            if(!subscriptionList.isEmpty())
            {
                Set<String> basketIdSet = new Set<String>();
                for(csord__Subscription__c sub : subscriptionList)
                {
                    basketIdSet.add(sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c);
                }
                List<ContractJunction__c> contJunctionList = [select Id, Related_Basket__c from ContractJunction__c where Related_Basket__c in :basketIdSet];
                if(!contJunctionList.isEmpty())
                {
                    for(csord__Subscription__c sub : subscriptionList)
                    {
                        sub.ContractJunction__c = contJunctionList[0].Id;
                    }
                    update subscriptionList;
                }
            }
        }
    }
}