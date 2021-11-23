public with sharing class SiteSubscriptionHelper
{   
     public static void updateSiteAttributesFromService(List<Id> subscriptionIdList)
    {
        //for each subscription, fetch the associated service object record for IP Site. fetch contract term, serviceability location fields from IP Site service object record and populate contract term, serviceability location fields in subscription object record. 
                
        List<csord__Service__c> ipSiteServList = [select id, name, csord__Subscription__r.name, contract_term__c, Serviceability_Location__c from csord__Service__c where name = 'IP Site' AND csord__Subscription__c in: subscriptionIdList];
        
        List<csord__Subscription__c> lstUpdateSubscription = new List<csord__Subscription__c>();
        
        for(csord__Service__c updateAtt : ipSiteServList)
        {            
            lstUpdateSubscription.add(new csord__Subscription__c(Id=updateAtt.csord__Subscription__c,Contract_Term__c=updateAtt.contract_term__c, Serviceability_Location__c = updateAtt.Serviceability_Location__c));
        }
        
        if(!lstUpdateSubscription.isEmpty())
        update lstUpdateSubscription;       
    }
    
    public static void updateOffer(List<Id> subscriptionIdList)
    {
        //for each subscription - get the reference to associated basket. Based on basket get the reference of associated offer. Update offer lookup field with offer object record id. 
            
        List<csord__Subscription__c> offerList = [select id, name, Offer__c, csordtelcoa__Product_Configuration__c, 
                                                    csordtelcoa__Product_Configuration__r.Offer_Reference__c 
                                                    from csord__Subscription__c where csordtelcoa__Product_Configuration__c != NULL AND id in: subscriptionIdList];
        
        List<csord__Subscription__c> lstUpdateSub = new List<csord__Subscription__c>();
        
        for(csord__Subscription__c updateAtt : offerList)
        {
            lstUpdateSub.add(new csord__Subscription__c(Id=updateAtt.id,Offer__c = updateAtt.csordtelcoa__Product_Configuration__r.Offer_Reference__c));
        }
        if(!lstUpdateSub.isEmpty())
        update lstUpdateSub;
    }
    
    public static void updateContractAttibutes(List<Id> subscriptionIdList)
    {
        //fetch the reference of Contract object from subscription based on Contract lookup field. Fetch contract start date field value from Contract object reference and populate that value in contract start date field in subscription.
        
        List<csord__Subscription__c> contractList = [select id, name, ContractJunction__c, ContractJunction__r.Contract_Start_Date__c, 
                                                        Contract_Start_Date__c from csord__Subscription__c where
                                                         ContractJunction__c != NULL AND id in: subscriptionIdList];
        
        List<csord__Subscription__c> lstUpdateSub = new List<csord__Subscription__c>();
        
        for(csord__Subscription__c updateAtt : contractList)
        {
            lstUpdateSub.add(new csord__Subscription__c(Id=updateAtt.id, Contract_Start_Date__c = updateAtt.ContractJunction__r.Contract_Start_Date__c));
        }
        
        if(!lstUpdateSub.isEmpty())
        update lstUpdateSub;        
    }
    
/*  
    //Method that combines updateOffer & updateContractAttibutes methods
    
    public static void updateOfferAndContract(List<Id> subscriptionIdList)
    {
        //for each subscription - get the reference to associated basket. Based on basket get the reference of associated offer. Update offer lookup field with offer object record id. 
        
        //fetch the reference of Contract object from subscription based on Contract lookup field. Fetch contract start date field value from Contract object reference and populate that value in contract start date field in subscription.    
        
        List<csord__Subscription__c> offerContractList = [select id, name, Offer__c, csordtelcoa__Product_Configuration__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__originating_offer__c, ContractJunction__c, 
                                                    ContractJunction__r.Contract_Start_Date__c, Contract_Start_Date__c 
                                                    from csord__Subscription__c where csordtelcoa__Product_Configuration__c != NULL AND id in: subscriptionIdList];
        
        List<csord__Subscription__c> lstUpdateSub = new List<csord__Subscription__c>();
        
        for(csord__Subscription__c updateAtt : offerContractList)
        {
            lstUpdateSub.add(new csord__Subscription__c(Id=updateAtt.id,Offer__c = updateAtt.csordtelcoa__Product_Configuration__r.cscfga__originating_offer__c,Contract_Start_Date__c = updateAtt.ContractJunction__r.Contract_Start_Date__c));
        }
        if(!lstUpdateSub.isEmpty())
        update lstUpdateSub;
    }
*/
    
    
}