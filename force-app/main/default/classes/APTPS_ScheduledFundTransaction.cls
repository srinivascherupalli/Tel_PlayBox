/*************************************************************
@Name: APTPS_ScheduledFundTransaction
@Author: Akanksha Trivedi
@CreateDate: 4nd Feb 2017.
@Description: Schedular for APTPS_YearlyFundTransactionBatch batch
******************************************************************/
global with sharing class APTPS_ScheduledFundTransaction implements Schedulable{
 
   global void execute(SchedulableContext SC) {
      APTPS_YearlyFundTransactionBatch fundTransactionBatch= new APTPS_YearlyFundTransactionBatch();
      ID idBatch = Database.executeBatch(fundTransactionBatch, 50);      
  
  }
 }