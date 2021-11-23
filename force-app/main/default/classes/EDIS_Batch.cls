/********************************************************
    Class Name : EDIS_Batch
    ===============================================================================================================================
    Change.No.    Developer Name          Date              Story Description
    1.             Pawan                 05/07/2021          DIGI-869
    **********************************************************/
    global with sharing class EDIS_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
      public Database.QueryLocator start(Database.BatchableContext BC){
        Environment_Configurations__c ec = Environment_Configurations__c.getOrgDefaults();
            integer noOfDaysDataDataToRetrieve = 1;
             if(ec.EDIS_Batch_NoOfDays_DataToRetrieve__c != null && ec.EDIS_Batch_NoOfDays_DataToRetrieve__c != 0){
            noOfDaysDataDataToRetrieve = Integer.valueOf(ec.EDIS_Batch_NoOfDays_DataToRetrieve__c); 
             }      
        DateTime last_hr_updated = Datetime.now().addDays(-noOfDaysDataDataToRetrieve);

        String query  = 'select id,'; 
               query += ' Status__c,';
               query += ' Service_Number__c,';
               query += ' Service_Id__c,';
               query += ' Type__c,';        
               query += ' DL_API_response_msg__c,';
               query += ' Status_LastModifiedDate__c,';
               query += ' DL_API_response_code__c,';
               query += ' Mobile__c,';
               query += ' Directory_Listing_DateTime__c';
               query += ' from Number__c';
               query += ' WHERE Status_LastModifiedDate__c >= :last_hr_updated AND (DL_API_response_code__c = null AND DL_API_response_msg__c = null AND Directory_Listing_DateTime__c = null)';
            system.debug('query ' + query);
            return Database.getQueryLocator(query);
      }
        
      global void execute(Database.BatchableContext BC, List<Number__c> scope){
          EDISSingleManagerHelper.buildingMaps(scope); 
         }
      
      global void finish(Database.BatchableContext BC){
      }



    }