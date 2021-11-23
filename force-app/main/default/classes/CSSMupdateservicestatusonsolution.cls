/**************************************************************
    Author: Venkata Ramanan G
    Description : To update the status of the Service & Subscription for the main solution record.Identified using the ServiceSpecification records.
    Invokation : Invoked from the   Service Fulfilment Process - Orchestration Process
  *******************************************************************/
global  with sharing class CSSMupdateservicestatusonsolution{
    
    global class UpdateServiceStatusConnected implements CSPOFA.ExecutionHandler{
  /**************************************************************
    Name: process
    Parameters: List<SObject> steps
    Return Type: List<SObject>
    Description: Class to update ServiceSpecs->Services statuses
  *******************************************************************/
      public List<SObject> process(List<SObject> steps){
          List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
          List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
          List<Id> serviceIds = new List<Id>();
          List<Id> orchesIds= new List<Id>();
      
          for(CSPOFA__Orchestration_Step__c step: stepList)
              orchesIds.add(step.CSPOFA__Orchestration_Process__c);
          
          system.debug(orchesIds);
          List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Service__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
          System.debug('orchList ::'+orchList);
          for(CSPOFA__Orchestration_Process__c  orch : orchList)
              serviceIds.add(orch.csordtelcoa__Service__c);
      
          system.debug('serviceIds ::'+serviceIds);
          
          updateservicesubscriptionstatus(serviceIds, Label.MO_status_in_progress);
      
          for(CSPOFA__Orchestration_Step__c step : stepList){
              step.CSPOFA__Status__c = Label.Complete;
              step.CSPOFA__Completed_Date__c=Date.today();
              step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
              result.add(step);
          }
          return result;
      }
    
        
    public void updateservicesubscriptionstatus(List<Id> serviceIds, String targetStatus){
        //List<Id> servidoriginallst = new List<Id>{'a4e5O0000000LiHQAU'};
 Set<Id> servidupdlst = new Set<Id>();
 Set<Id> subupdlst = new Set<Id>();
 List<sObject> sobjupdlst = new List<sObject>();
        servidupdlst.addAll(serviceIds);
       // List<Attachment> arlst = new List<Attachment>([select id,Name,ParentId from Attachment where ParentId in :serviceIds and name like '%ServiceSpecifications%']);


          List<Attachment> arlst = new List<Attachment>([select id,Name,ParentId from Attachment where name like '%ServiceSpecifications%' and ParentId not in(select Id from csord__Service__c where Id in:serviceIds and ((Name Like '%Bandwidth Clip On%')))]);  


        if(!arlst.isempty()){
    for(Attachment a : arlst)
    {        
            system.debug('ar.ParentId'+a.ParentId);
            servidupdlst.remove(a.ParentId);
    }
    
}

system.debug('servidupdlst'+servidupdlst);

for(csord__Service__c serv: [select id,csord__Subscription__c,csord__Status__c, csord__Subscription__r.csord__Status__c  from csord__Service__c where id in :servidupdlst])
{
    serv.csord__Status__c ='Connected'; 
      sobjupdlst.add(serv);
      subupdlst.add(serv.csord__Subscription__c);
}
for (csord__Subscription__c sub: [select Name,id,csord__Status__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c from csord__Subscription__c where id in: subupdlst])
{
    if(sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
    sub.csord__Status__c='Provisioned';
    sobjupdlst.add(sub);
    }else if(sub.Name.equalsIgnoreCase('Unified Communication Tenancy Solution')){
    sub.csord__Status__c='Active';
    sobjupdlst.add(sub);
    }
   
}

if(!sobjupdlst.isempty())
    {
        system.debug(sobjupdlst);
        database.update(sobjupdlst,true);
    }
    }
    }
}