global with sharing class UpdateFnnDetails implements CSPOFA.ExecutionHandler {
    public List<sObject> process(List<sObject> data){
        List<Id> orchesIds= new List<Id>();
        List<sObject> result = new List<sObject>();
        List<Id> orderIdList = new List<Id>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
        system.debug('stepList=='+stepList);
        List<RecordType> orderRecordTypeList =[SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c'];
        Map<String, Id> orderRecordTypeNameToIdMap = new Map<String, Id>();
        for(RecordType recTypeInstance : orderRecordTypeList){
            orderRecordTypeNameToIdMap.put(recTypeInstance.Name, recTypeInstance.Id);      
        }
        
        for(CSPOFA__Orchestration_Step__c step: stepList)
        {
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }
        for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
        {
            orderIdList.add(orch.Order__c);
        }
        udpateNumberDetails(orderIdList);
        for(CSPOFA__Orchestration_Step__c step : stepList){
            
            step.CSPOFA__Status__c = 'Complete';
            step.CSPOFA__Completed_Date__c=Date.today();
            step.CSPOFA__Message__c = 'Completed';
            result.add(step);
        }
        return result;
    }
    
    public static void udpateNumberDetails(List<id> orderIdList){
        Map<id,csord__Service__c> serviceList;
        //Map<String,String> pcToSubsMap = new Map<String,String> ();
        Map<String,csord__Subscription__c> pcToSubsMap1 = new Map<String,csord__Subscription__c> ();
        //Map<String,String> pcToservsMap = new Map<String,String> ();
        Map<String,csord__Service__c> pcToservsMap1 = new Map<String,csord__Service__c> ();
        List<Number__c> numListToUpdate = new List<Number__c>();
        //EDGE-135512 Kalashree Borgaonkar. Added csconta__Billing_Account__c
        Map<id,csord__Subscription__c> subList = new Map<id,csord__Subscription__c> ([SELECT id,Billing_Account__c ,csordtelcoa__Subscription_Number__c,csord__Order__c,csordtelcoa__Product_Configuration__c, csconta__Billing_Account__c FROM csord__Subscription__c WHERE csord__Order__c In :orderIdList]);
        System.debug('subList: '+subList);
        try{
            if(!subList.keyset().isEmpty()){
                serviceList = new Map<id,csord__Service__c> ([SELECT id,csordtelcoa__Service_Number__c,csord__Subscription__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,csordtelcoa__Product_Configuration__r.Marketable_Offer__c	
                                                              FROM csord__Service__c WHERE csord__Subscription__c In :subList.keyset()]);
                List<String> pcList = new  List<String>();
                for(String serviceId:serviceList.keyset()){
                    pcList.add(serviceList.get(serviceId).csordtelcoa__Product_Configuration__c);
                    // pcToservsMap.put(serviceList.get(serviceId).csordtelcoa__Product_Configuration__c,serviceList.get(serviceId).csordtelcoa__Service_Number__c);
                    pcToservsMap1.put(serviceList.get(serviceId).csordtelcoa__Product_Configuration__c,serviceList.get(serviceId));
                }
                System.debug('pcToservsMap1: '+pcToservsMap1);
                    
                for(String subId:subList.keyset()){
                    //pcToSubsMap.put(subList.get(subId).csordtelcoa__Product_Configuration__c,subList.get(subId).csordtelcoa__Subscription_Number__c);
                    pcToSubsMap1.put(subList.get(subId).csordtelcoa__Product_Configuration__c,subList.get(subId));
                }
                System.debug('pcToSubsMap1: '+pcToSubsMap1);
                List<Number__c> numList =  [SELECT id,Product_Configuration__c,Service_Id__c,Subscription_number__c  FROM Number__c WHERE Product_Configuration__c IN :pcList];
                
                if(!numList.isEmpty()){
                    for(Number__c num: numList){
                        if(num.Product_Configuration__c!=null){
                            if(!pcToservsMap1.keyset().isEmpty()){
                                num.Service_Id__c= pcToservsMap1.get(num.Product_Configuration__c).csordtelcoa__Service_Number__c;
                                num.Product_ID__c = pcToservsMap1.get(num.Product_Configuration__c).csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                                num.Offer__c =pcToservsMap1.get(num.Product_Configuration__c).csordtelcoa__Product_Configuration__r.Marketable_Offer__c;
                            }
                            if(!pcToSubsMap1.keyset().isEmpty()){
                                //EDGE-108230:New Billing account field added
                                num.Billing_Accounts__c = pcToSubsMap1.get(num.Product_Configuration__c).csconta__Billing_Account__c;
                                num.Subscription_number__c=pcToSubsMap1.get(num.Product_Configuration__c).csordtelcoa__Subscription_Number__c;
                            }	
                            numListToUpdate.add(num);
                            System.debug('num: '+num);
                        }  
                    }	
                }
                if(!numListToUpdate.isEmpty()){
                    update numListToUpdate;
                }
            }
            System.debug('numListToUpdate: '+numListToUpdate);
        }
        catch(Exception e){
            System.debug('Exception in udpateNumberDetails:'+e.getStackTraceString());
        }   
    } 
}