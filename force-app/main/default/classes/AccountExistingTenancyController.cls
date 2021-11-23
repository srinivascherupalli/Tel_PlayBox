/*
===============================================================================================================================
Class : AccountExistingTenancyController
Developer Name : Shubhi
Test Class : AccountExistingTenancyControllerTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1          shubhi             18/10/2019      Edge-112555
1          shubhi             7/11/2019       Edge-117563
2.          vivek             07/04/2021      edge-206232
3.         VIVEK              14/06/2021      EDGE-223950 : Adding netwrk service id in query
===============================================================================================================================*/

global with sharing class AccountExistingTenancyController {
    
    @AuraEnabled
    public static List<csord__Subscription__c> getSubscriptions(String accountId,String basketId,String filterByTenancyType, List<String> tenancyTypeProdIdList){ 
        //String tenancySpeification='DMCAT_ProductSpecification_000537';
        List<csord__Subscription__c> subs= new  List<csord__Subscription__c>();//Edge-117563
        if(String.isBlank(accountId) && String.isNotBlank(basketId)){
            cscfga__Product_Basket__c bas = [Select id, csbb__Account__c from cscfga__Product_Basket__c where Id =: basketId];
            accountId=bas.csbb__Account__c;
        }
        system.debug('Account id:-'+accountId);
        system.debug('tenancyTypeProdIdList:-'+tenancyTypeProdIdList);
        if(String.isNotBlank(accountId)){
            subs = [select id , Name , csord__Account__r.name , csordtelcoa__Subscription_Number__c ,NetworkServiceId__c,   TenancyID__c ,csord__Status__c // EDGE-223950 : Added n/w service Id
                                          from csord__Subscription__c where csord__Account__c =:accountId and csord__Status__c = :System.label.Active and ConfigSpecID__c IN:tenancyTypeProdIdList];
            system.debug('All Subs--->'+subs); 
            return subs; 
        }
            return subs;   //Edge-117563
    }



    // EDGE -206232 : START 
    @AuraEnabled
    public static String getActualGUID ( String subscriptionId ) { 
        String tenacyguId = '';
        Map<id,csord__Service__c> serviceMap        =   new Map<id,csord__Service__c>();
        list<csord__Service__c> serviceList          =   [select id from csord__Service__c where csord__Subscription__c  =: subscriptionId];
        
         for(csord__Service__c seer: serviceList){
            serviceMap.put(seer.id,seer);
        }

        for(Attachment att:[select ID, name, body, parentId from Attachment where parentId in: serviceMap.keyset() and name = 'ServiceSpecifications.json']){
            String newServiceAttachmentStr           =  att.body.toString();
            Map<String, Object> updatedResults       =  (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
            List<Object>lstSpecifications            =  (List<Object>)updatedResults.get('specifications');
            List<Object> newlstSpecifications        =  new List<Object>();
            
            for(Object spec:lstSpecifications){
                Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
                if(specificationAttributes!=null ) 
                {
                   if(String.valueOf(specificationAttributes.get('name')).contains(label.Broadsoft_Tenancy_Fulfilment)){
                        tenacyguId = String.valueOf(specificationAttributes.get('guid'));
                   }
                }
            }           
        }
        return tenacyguId;
    }
    // EDGE -206232 : END
    
}