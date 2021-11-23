/*************************************************************************************************
Name : GetCustomerSeedingRequestBatch
Description : Used to run the batch of CustomerSeedingRequest records with pending status based
			  on Batch Id or Seeding date and process them

***************************************************************************************************/
global class GetCustomerSeedingRequestBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

	global Integer batchId;
    global GetCustomerSeedingRequestBatch(Integer batchId) {
        this.batchId = batchId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        String status ='Pending';
        if(batchId==null) {
         query = 'SELECT Id, CIDN__c, Seeding_Date__c, Status__c,Notes__c,Code__c,Batch_ID__c FROM Customer_Seeding_Request__c WHERE Seeding_Date__c = TODAY and Status__c =:status ORDER BY Batch_ID__c';
        }
        else {
         query = 'SELECT Id, CIDN__c, Seeding_Date__c, Status__c,Notes__c,Code__c,Batch_ID__c FROM Customer_Seeding_Request__c WHERE Batch_ID__c =: batchId and Status__c =:status ORDER BY Batch_ID__c' ;
        }

        system.debug('query****'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Seeding_Request__c> scope) {

        try {
       for(Customer_Seeding_Request__c csr:scope) {
           System.debug('-------------> csr : ' + csr.CIDN__c);
           ImportTCMCustomerByCIDN importTest=new ImportTCMCustomerByCIDN();
		   ImportTCMCustomerResult result = importTest.importCustomerAndContactbyCIDN(csr.CIDN__c, ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
           csr.Status__c = result.errorCode;
           csr.Code__c = result.errorCode != null ? result.errorCode : '';
           csr.Notes__c = result.errorDescription != null ? result.errorDescription : '';
           csr.Actual_Seeding_Timestamp__c = System.now();
       }
       update scope;
        } catch (Exception e) {
            System.debug('----------> ERROORRR ' + e.getStackTraceString());

        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}