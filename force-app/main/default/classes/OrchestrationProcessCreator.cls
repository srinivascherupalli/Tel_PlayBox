/*=============================================================================================================================
Class : OrchestrationProcessCreator
Test Class : OrchestrationProcessCreatorTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1           Abinash            09/25/2019      EDGE-80870 Reverse Logistics
2.       Shreya jaiswal         13/12/19        EDGE-125031
===============================================================================================================================*/
public with sharing class OrchestrationProcessCreator {
    
    private static OrchestrationProcessCreator singleton = null;

    /* A private Constructor prevents any other
    * class from instantiating.
    */
    private OrchestrationProcessCreator() { }

   /* Static 'instance' method */
    public static OrchestrationProcessCreator getInstance( ) {
        if(singleton == null){
            singleton = new OrchestrationProcessCreator();
        }
      return singleton;
    }

    //subsSvcList: can have related list of services, this method will look into the related services and create Orchestration process for them

    public static void createOchestrationProcess(List<csord__Service__c> serviceSubsList){
        list<CSPOFA__Orchestration_Process__c> serviceSubscriptionOrches =  new list<CSPOFA__Orchestration_Process__c>();  
        Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = new Map<String, CSPOFA__Orchestration_Process_Template__c>();
        for(CSPOFA__Orchestration_Process_Template__c orctemp: [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c]){
            orchesTemplates.put(orctemp.Name, orctemp);
        }
        //create orchestration process for all subscriptions
        if(!serviceSubsList.isEmpty() && !orchesTemplates.isEmpty()){
            Set<Id> subscrpList =  new Set<Id>();
            Set<Id> subscrpCeaseSet =  new Set<Id>();
             //EDGE-80870 Start
            boolean isCreateOrchProcess = DeviceReplacementOrchestrationProcess.isDeviceReplacementOrchestrationProcess(serviceSubsList);
            //EDGE-80870 End
            if(isCreateOrchProcess){
                for(csord__Service__c sub : serviceSubsList){
                //EDGE-125031 : Subscription Fulfilment Process should not get generated for legacy subscriptions.
                    if(sub.csord__Subscription__r.legacy_subscription__c == null)
                        subscrpList.add(sub.csord__Subscription__c);
                    system.debug('TBC = '+sub.csord__Subscription__r.toBeCancelled__c);
                    if(sub.csord__Subscription__r.toBeCancelled__c !=null && sub.csord__Subscription__r.toBeCancelled__c.equalsIgnoreCase('true'))
                        subscrpCeaseSet.add(sub.csord__Subscription__c);
                    String orchTemplateName = 'Service Fulfilment Process';
                    system.debug('orchTemplateName Value is :'+orchTemplateName);
                    CSPOFA__Orchestration_Process__c orches = new CSPOFA__Orchestration_Process__c();
                    orches.CSPOFA__State__c = 'Active';
                    orches.csordtelcoa__Service__c = sub.Id;
                    //orches.csordtelcoa__Subscription__c = sub.csord__Subscription__c;
                    if(orchesTemplates.get(orchTemplateName) != null){
                        orches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(orchTemplateName).id;
                        serviceSubscriptionOrches.add(orches);
                    }  
                }    
                String templateName = 'Subscription Fulfilment Process';
                String ceasetemplateName = 'Subscription Cease Process';
                if(!subscrpList.isEmpty() && orchesTemplates.get(templateName) != null){
                    for(Id subcrip : subscrpList){
                        CSPOFA__Orchestration_Process__c orches = new CSPOFA__Orchestration_Process__c();
                        orches.CSPOFA__State__c = 'Active';
                        orches.csordtelcoa__Subscription__c = subcrip;
                        if(subscrpCeaseSet.contains(subcrip)){
                            orches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(ceasetemplateName).id;
                        }else{
                            orches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(templateName).id;
                        }
                        //orches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(templateName).id;
                        serviceSubscriptionOrches.add(orches);
                    }
                }
            }
            /*templateName = 'Subscription Cease Process';
            if(!subscrpList.isEmpty() && orchesTemplates.get(templateName) != null){
                for(Id subcrip : subscrpCeaseSet){
                    CSPOFA__Orchestration_Process__c orches = new CSPOFA__Orchestration_Process__c();
                    orches.CSPOFA__State__c = 'Active';
                    orches.csordtelcoa__Subscription__c = subcrip;
                    orches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(templateName).id;
                    serviceSubscriptionOrches.add(orches);
                }
            }*/
            
        }
       if(!serviceSubscriptionOrches.isEmpty())
            insert serviceSubscriptionOrches;
    }
    public static void createMSISDNOchestrationProcess(List<Id> orderIds){
         String templateName = 'MSISDN Reserve Process';
        List<CSPOFA__Orchestration_Process_Template__c> orchesTemplates = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c where Name = :templateName];
        
         CSPOFA__Orchestration_Process__c orches = new CSPOFA__Orchestration_Process__c();
        if(!orchesTemplates.isEmpty()){
            orches.CSPOFA__State__c = 'Active';
            orches.Order__c = orderIds[0];
            orches.CSPOFA__Orchestration_Process_Template__c =orchesTemplates[0].Id;
        }
                    
        insert orches;
   }
}