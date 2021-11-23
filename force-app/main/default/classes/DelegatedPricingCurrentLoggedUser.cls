public class DelegatedPricingCurrentLoggedUser {    
    @AuraEnabled public List<Integer>  retVal{get; set;}
    @AuraEnabled public Delegated_Pricing_Request__c delPriceReq {get; set;}
    @AuraEnabled public User currentDelUser {get; set;}
}