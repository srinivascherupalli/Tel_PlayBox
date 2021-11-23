/**
*  Description of the class method.
*  @name PartnerAdminRoleDetails
*  @description               : This class is used  in  LWC to display the SOW Item details as related list.
*  @param fulfillmentId       : ComponentType - Telstra Collaboration Operations User,Engineering User.
*  @return                    : Json Object 
*  @Jira Story Ref            : EDGE-129805
*  @CreateDate                : 26/02/2020 
*  @createdBy                 : Sri Ramya E, Alexandria
**/

public with sharing class SOWItemDetails {
@AuraEnabled(cacheable = true)
    public static List<SOW_Items__c> getSOWItems(String recordId) {
        system.debug('recordid'+recordId);     
       FulfillmentLineItem__c FLI =[select id,subscription__r.csord__Order__r.csordtelcoa__Opportunity__c,subscription__r.MarketableOffer__r.Offer_ID__c, subscription__r.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Id from FulfillmentLineItem__c where id=:recordId];
/*
                list<SOW_Items__c> SOWItemlist=[Select id,Name,Description__c,Comment__c, SOW__r.Offer_Id__c from SOW_Items__c
                                        WHERE sow__r.Basket__r.Primary_Basket__c=true
                                        
                                        AND Included__c=true];
*/
     
        list<SOW_Items__c> SOWItemlist=[Select id, Name, SOW__r.Offer_Id__c, Description__c, Comment__c from SOW_Items__c
                                        WHERE sow__r.Basket__c =:FLI.subscription__r.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.Id
                                        AND sow__r.Basket__r.Primary_Basket__c=true
                                        AND SOW__r.Offer_Id__c=:FLI.subscription__r.MarketableOffer__r.Offer_ID__c
                                        AND Included__c=true];
       system.debug('SOWItemlist'+SOWItemlist);                                 
        return SOWItemlist; 
//return null;
}

}