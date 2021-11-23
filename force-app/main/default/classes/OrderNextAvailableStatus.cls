global with sharing class OrderNextAvailableStatus implements CSPOFA.ExecutionHandler {
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
        
        //Commenting out primary order query as secondary order will not be createed with upgraded O&S package
        /*Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>([Select Id, Name, csord__Primary_Order__c, csord__Order_Request__c, csordtelcoa__Opportunity__c,isMSISDNRequired__c, isMSISDNReserved__c, isAppointmentCompleted__c from csord__Order__c where Id IN:orderIdList OR csord__Primary_Order__c IN:orderIdList]);
        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([Select Id, Name, csord__Service__c, SiteId__c,modelChange__c, csord__Subscription__c,Serviceability_Location__c,Contract_Term__c, Appointment_Required__c, TechnologyType__c, csord__Order_Request__c, csordtelcoa__Replaced_Service__c, csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.isMSISDNRequired__c, csord__Order__r.isMSISDNReserved__c, csord__Order__r.isAppointmentCompleted__c,csord__Order__r.csord__Primary_Order__r.isAppointmentCompleted__c   from csord__Service__c where csord__service__c = null and csord__Order__r.csord__Primary_Order__c IN:orderIdList]);
        */
        Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>([Select Id, Name, csord__Primary_Order__c, csord__Order_Request__c, csordtelcoa__Opportunity__c,isMSISDNRequired__c, isMSISDNReserved__c, isAppointmentCompleted__c from csord__Order__c where Id IN:orderIdList]);
        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([Select Id, Name, csord__Service__c, SiteId__c,modelChange__c, csord__Subscription__c,Serviceability_Location__c,Contract_Term__c, Appointment_Required__c, TechnologyType__c, csord__Order_Request__c, csordtelcoa__Replaced_Service__c, csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.isMSISDNRequired__c, csord__Order__r.isMSISDNReserved__c, csord__Order__r.isAppointmentCompleted__c  from csord__Service__c where csord__service__c = null and csord__Order__c IN:orderIdList]);
        //OrderStatusHandler.changeOrderStatus(orderIdList);
        OrderStatusHelper.OrderFieldUpdateExecute(serviceMap, orderMap, orderRecordTypeNameToIdMap, false);
        for(CSPOFA__Orchestration_Step__c step : stepList){
             
            step.CSPOFA__Status__c = 'Complete';
            step.CSPOFA__Completed_Date__c=Date.today();
            step.CSPOFA__Message__c = 'Completed';
            result.add(step);
        }
        return result;
    }
     
}