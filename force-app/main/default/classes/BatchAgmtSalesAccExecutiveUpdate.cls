/*
AUTHOR : Maq
DESCRIPTION : As a Telstra contract manager WHEN account owner field of an account changes
THEN I can see that the Sales account executive field on account's agreement records(only for records in status = Request, In Authoring) is updated to show same value as Account owner.
*/

global Without sharing class BatchAgmtSalesAccExecutiveUpdate implements Database.Batchable<SObject> {
    
    public static Boolean isSalesAccExecutiveJob = false;
    
    /**
    * @description gets invoked when the batch job starts
    * @param context contains the job ID
    * @returns the record set as a QueryLocator object that will be batched for execution
    */ 
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, Name, OwnerId, CIDN__c, TCM_MasterID__c, Portfolio_Code__c FROM Account WHERE CIDN__c != null and TCM_MasterID__c != null');
    }
    
    /**
    * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
    * @param context contains the job ID
    * @param scope contains the batch of records to process.
    */ 
    global void execute(Database.BatchableContext context, List<Account> scope) {
        isSalesAccExecutiveJob = true;
        List<Apttus__APTS_Agreement__c> agmtToUpdate = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> relatedAgreement = [SELECT Id, Name, Apttus__Account__c, APTPS_Sales_Account_Executive__c, Apttus__Account__r.ownerId FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__c != NULL AND Apttus__Account__c IN : scope]; 
        System.debug('RelatedAgreement'+relatedAgreement);
        for(Apttus__APTS_Agreement__c agmt : relatedAgreement){
            if(agmt.APTPS_Sales_Account_Executive__c != agmt.Apttus__Account__r.ownerId){
                agmt.APTPS_Sales_Account_Executive__c = agmt.Apttus__Account__r.ownerId;
                agmtToUpdate.add(agmt);
            }
        }
        //Condition updated for EDGE-91424 :: Sales AE batch job update for Agreement
        if(!agmtToUpdate.isEmpty()){
            Database.update(agmtToUpdate, false);
        }
    }
    
    /**
    * @description gets invoked when the batch job finishes. Place any clean up code in this method.
    * @param context contains the job ID
    */ 
    global void finish(Database.BatchableContext context) {
        
    }
}