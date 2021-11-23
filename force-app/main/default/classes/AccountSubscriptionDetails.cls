/* Added by Ramya - EDGE-125950 : Enable Partner details within the subscription so that Assurance agents can make an informed decision.
Class to fetch and display partner details on subscription page. Refered in LWC : partnerDetails */

public without sharing class AccountSubscriptionDetails {
    
    @AuraEnabled(cacheable=true)
    //public static List<csord__Subscription__c> getPartnerDetails(String subscriptionId) {
    public static String getPartnerDetails(String subscriptionId) {
        
        try {
          // return [SELECT id, csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccount.Name, csord__Order__r.csordtelcoa__Opportunity__r.Owner.Name 
          // FROM csord__Subscription__c WHERE id = :subscriptionId];

          csord__Subscription__c subscriptionRecord =  [SELECT id, csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccount.Name, csord__Order__r.csordtelcoa__Opportunity__r.Owner.Name 
          FROM csord__Subscription__c WHERE id = :subscriptionId LIMIT 1];
          if(subscriptionRecord != null){
            String subscriptionJson = JSON.serialize(subscriptionRecord);
            SubscriptionWrapper sub1 = new SubscriptionWrapper();
            sub1.partnerAccountName = subscriptionRecord.csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccount.Name;
            sub1.partnerAccountId = subscriptionRecord.csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccount.id;
            sub1.opportunityOwnerName = subscriptionRecord.csord__Order__r.csordtelcoa__Opportunity__r.Owner.Name;
            sub1.opportunityOwnerId = subscriptionRecord.csord__Order__r.csordtelcoa__Opportunity__r.Owner.Id;
            return JSON.serialize(sub1);
          }
          return null;
        }
    
        catch(Exception e) {
          System.debug(Logginglevel.ERROR, e.getMessage());
          throw new AuraHandledException(e.getMessage());
            }
   
      }

      public class SubscriptionWrapper{
        String opportunityOwnerId;
        String opportunityOwnerName;
        String partnerAccountName;
        String partnerAccountId;
      }
}