/**
* Author: Yash Rathod
* Description: Service class to handle Email generating for Cancelled Subscriptions.
* Jira US: EDGE-98409
**/


public with sharing class SubEmailService{
    @InvocableMethod
    public static void processSubRecord(List<Id> SubId){
        System.debug('Inside Process Builder@Cancel :: ' + SubId);
        List<csord__Subscription__c> subList =[Select Id, Name,site__c,csord__Status__c,csord__Order__c,csordtelcoa__Product_Configuration__r.Type__c,csordtelcoa__Replaced_Subscription__c,csord__Order_Request__c, offer__r.Offer_Spec_Id__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, csord__Order__r.csord__Status2__c,Cancellation_Date_of_Effect__c,Sub_Status__c,csord__Order__r.csordtelcoa__Opportunity__c from csord__Subscription__c where id in : SubId];
        System.debug('subList::::::'+subList);
        
        Map<String,String> metadataToTemplateMap=new Map<String,String>();
        for(Customer_Notify_Metadata__c custMetadata:[select Id,monitorObjectStatus__c,orderType__c,productDefinitionCode__c,emailTemplate__c from Customer_Notify_Metadata__c where (scenarioType__c='' or scenarioType__c=null) and monitorObject__c='Subscription']){
            String productDefinitionCode=custMetadata.productDefinitionCode__c;
            String key=custMetadata.orderType__c+':'+custMetadata.monitorObjectStatus__c+':'+productDefinitionCode;
            System.debug('Key++'+key);
            System.debug('custMetadata '+custMetadata);
            
            if(metadataToTemplateMap.get(key)==null)
                metadataToTemplateMap.put(key,custMetadata.emailTemplate__c);
        }
        for(csord__Subscription__c sub:subList){
            system.debug('subscription:-->'+sub);
            String toCompare=sub.csordtelcoa__Product_Configuration__r.Type__c+':'+sub.csord__Status__c+':'+sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
            System.debug('toCompare-->'+toCompare);
            String template = metadataToTemplateMap.get(toCompare);
            System.debug('template-->'+template);
            if(sub.csordtelcoa__Product_Configuration__r.Type__c != null && sub.csordtelcoa__Product_Configuration__r.Type__c.equals('Cancel')){
				System.debug('Inside sub Condition-->');
                EmailDTO emailDTO=SubEmailServiceHelper.generateEmailDTO(template,sub);
            	new EmailService().send(emailDTO); 
            }
        }
        
    }
}