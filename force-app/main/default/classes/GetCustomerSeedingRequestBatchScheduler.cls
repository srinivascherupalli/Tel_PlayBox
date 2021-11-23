/*************************************************************************************************
Name : GetCustomerSeedingRequestBatchScheduler
Description : Scheduler class to run the batch class GetCustomerSeedingRequestBatch

***************************************************************************************************/

global class GetCustomerSeedingRequestBatchScheduler implements Schedulable {
   global Integer batchId; 
   //batch size configurable in BatchSize custom metadata
   global Integer batchSize= Integer.valueOf([Select Size_Value__c from Batch_Size__mdt where DeveloperName='getCustomerSeedingBatch'].Size_Value__c);
   global void execute(SchedulableContext sc) {
      GetCustomerSeedingRequestBatch bch = new GetCustomerSeedingRequestBatch(batchId);
           database.executebatch(bch,batchSize);
              
   }

}