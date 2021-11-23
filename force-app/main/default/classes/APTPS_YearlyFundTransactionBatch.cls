/*************************************************************************************************************************
 @Name: APTPS_YearlyFundTransactionBatch
 @Author: Akanksha Trivedi
 @Created Date: 06/02/2017
 @Descripton: This batch job creates fund transactions
 @Used By: APTPS_ScheduledFundTransaction
*************************************************************************************************************************/
global with sharing class APTPS_YearlyFundTransactionBatch implements Database.Batchable<SObject>, Database.Stateful {
    global String query;
    
    global APTPS_YearlyFundTransactionBatch(){   
      query = 'SELECT Id, Name, APTPS_Start_Date__c,RecordTypeId, APTPS_Current_Fund_Amount__c,APTPS_Accrual_Method__c,APTPS_Annual_Fund_Payment_Yr_1__c,Agreement__c, Annual_Fund_Payment_Yr_2__c, APTPS_Annual_Fund_Payment_Yr_3__c,APTPS_Annual_Fund_Payment_Yr_4__c, APTPS_Annual_Fund_Payment_Yr_5__c,APTPS_Expiry_Date__c FROM Fund__c WHERE APTPS_Accrual_Method__c= \'Annual\' AND (APTPS_Start_Date__c < TODAY and APTPS_Start_Date__c !=null) and APTPS_Expiry_Date__c !=null';
      //query += ' limit 1';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
    } 
    
    
    global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
      for(Sobject s : scope)
      {  
         APTPS_FundTransactionUtil.createFundTransaction((Fund__c)s); 
          
      }
    }
   
     global void finish(Database.BatchableContext bc) {}
}