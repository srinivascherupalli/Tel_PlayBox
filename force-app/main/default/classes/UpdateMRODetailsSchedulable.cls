/* class Name: UpdateMRODetailsSchedulable
* Test class Name :UpdateMRODetailsSchedulableTest
* Description: Class to enable a daily batch process to update final MRO commercial details as received from Replicator in staging object
1.  Prajakta          16/10/2020          EDGE-179345
================================================================================================================================*/

//EDGE-179345: Enable a daily batch process to update final MRO commercial details as received from Replicator in staging object onto required order/product inventory components
global with sharing class UpdateMRODetailsSchedulable implements Database.Batchable<SObject>,Database.Stateful,  Database.AllowsCallouts{
    
    global Map<String,Service_Add_On__c> instanceIdaddonMap = new Map<String,Service_Add_On__c>();
    global Map<String,Service_Add_On__c> instanceIdaddonMapWithNoMicaDependency = new Map<String,Service_Add_On__c>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        Datetime dtTime = (Datetime)system.today()-1; 
        String status = 'Processed';
        system.debug( 'query'+ Database.getQueryLocator('SELECT id,Instance_Id__c,Final_Remaining_Amount__c,Final_Remaining_Term__c,Status__c,Monthly_Amount__c,Device_Id__c FROM Service_Add_On__c WHERE Status__c =: status AND LastModifiedDate >=:dtTime'));
        if(Test.isRunningTest()){
            return Database.getQueryLocator('SELECT id,Instance_Id__c,Final_Remaining_Amount__c,Final_Remaining_Term__c,Status__c,Monthly_Amount__c,Device_Id__c,isMicaDependency__c FROM Service_Add_On__c');
        }
        return Database.getQueryLocator('SELECT id,Instance_Id__c,Final_Remaining_Amount__c,Final_Remaining_Term__c,Status__c,Monthly_Amount__c,Device_Id__c,isMicaDependency__c FROM Service_Add_On__c WHERE Status__c =: status ');
    }
    
    
    global void execute(Database.BatchableContext BC, List<Service_Add_On__c> scope) {
        system.debug('scope:'+scope);
        for(Service_Add_On__c addon :scope){
          //Start-EDGE-208435-Dheeraj Bhatt-Enhance Subscription orchestration process steps to hold Right to Bill trigger for migration MRO subscription.
            if(addon.isMicaDependency__c==false){
                instanceIdaddonMapWithNoMicaDependency.put(addon.Instance_Id__c,addon); 
            }
            else {
                instanceIdaddonMap.put(addon.Instance_Id__c,addon);  
            }
        }
        if(!instanceIdaddonMap.isEmpty()){
            UpdateMRODetailsUtility.updateMRODetails(instanceIdaddonMap);
        }
        if(!instanceIdaddonMapWithNoMicaDependency.isEmpty()){
            UpdateMRODetailsUtility.triggerRTBForNonMicaDependecy(instanceIdaddonMapWithNoMicaDependency); 
        }
        //End-EDGE-208435
    }
    
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email   FROM AsyncApexJob where Id =:BC.getJobId()];
        
        If(a.NumberOfErrors >0 ||Test.isRunningTest()){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { Label.DLToBeReceived };
                mail.setToAddresses(toAddresses);
            mail.setSubject('Alert: Transition device batch process failure ' + a.Status  + 'Batch ID : '+BC.getJobId());
            mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 
    }
    
}