/***************************************************************************************
EDGE -115888
Name: SubscriptionTab
Description: Display Subscription Number As a link on Number object,
It Navigates to Subscription Detail Page which is in "Active" status.
Author:Syed 
*************************************************************************************/

public with sharing class SubscriptionController {
    @AuraEnabled
    public static csord__Subscription__c getSubscriptionValue(Id recordId){
        List<csord__Subscription__c> subsRec;
        List<Number__c> numberRec = [SELECT Subscription_number__c,Service_Number__c FROM Number__c WHERE Id = :recordId];
        
        //INC000095698976 - Modified SOQL query as part of production incident
        if(!numberRec.isEmpty()){
          subsRec = [SELECT id,csordtelcoa__Subscription_Number__c,serviceMSISDN__c,csord__Status__c  
                     FROM csord__Subscription__c 
                     WHERE csordtelcoa__Subscription_Number__c = :numberRec[0].Subscription_number__c order by createddate desc LIMIT 1];            
        }
        if(!subsRec.isEmpty()){
            return subsRec[0];
            
        }else{
            throw new AuraHandledException('No Active Subscription found');
        }
        
    }
	
    
}