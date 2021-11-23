/*************************************************************************************************************************
 @Name: APTPS_PerformAgreementActivationBatch
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This batch job Activates legacy agreement
 @Used By: APTPS_AgreementTriggerHandler
*************************************************************************************************************************/
global class APTPS_PerformAgreementActivationBatch implements Database.Batchable<sObject>,
Database.AllowsCallouts, Database.Stateful {

    global final String Query;
    global final set<Id> agreementIds;
    public Boolean chainAnotherbatch = false;
    public Id agreementIdToBeRemoved ;
   global APTPS_PerformAgreementActivationBatch(set<Id> agrmntIds){
     
      agreementIds = agrmntIds;    
      Query = 'select Id, Name,createddate, (select Id, Name,createddate from Attachments order by createddate desc ) APTPS_Legacy_Agreement__c '
      + 'from Apttus__APTS_Agreement__c where id in :agreementIds';
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
      for(Sobject s : scope)
      {
         APTPS_AgreementActivationUtil.activateAgreement((Apttus__APTS_Agreement__c)s); 
          
      }
   }

   global void finish(Database.BatchableContext BC){
      
   }
   
   
}