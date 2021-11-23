/*
AUTHOR : Abhishek Rao K
DESCRIPTION : EDGE-93284 
			  1. Update Agreement when Primary contact is BLANK or NULL.
			  2. Update Agreement when Primary Conact -> AccountId (NOT EQUAL TO) Agreement -> AccountId
*/

global Without sharing class BatchCustomerPrimaryContactAssignment implements Database.Batchable<SObject> {
    
    global static Boolean isCustomerPrimaryContactJob = false;
    
    /**
* @description gets invoked when the batch job starts
* @param context contains the job ID
* @returns the record set as a QueryLocator object that will be batched for execution
*/ 
    global Database.QueryLocator start(Database.BatchableContext context) {
         return Database.getQueryLocator('SELECT Id, Name,Apttus__Account__c, APTPS_Customer_Primary_Contact__c,APTPS_Customer_Primary_Contact__r.AccountId from Apttus__APTS_Agreement__c where Apttus__Account__r.CIDN__c != null and Apttus__Account__r.TCM_MasterID__c != null');
    }
    
    /**
* @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
* @param context contains the job ID
* @param scope contains the batch of records to process.
*/ 
    global void execute(Database.BatchableContext context, List<Apttus__APTS_Agreement__c> scope) {
        BatchAgmtSalesAccExecutiveUpdate.isSalesAccExecutiveJob= true;
        isCustomerPrimaryContactJob = true;
        //Map<Id,Apttus__APTS_Agreement__c> mapOfAgreements = new Map<Id,Apttus__APTS_Agreement__c>([select Id, Name,Apttus__Account__c, APTPS_Customer_Primary_Contact__c,APTPS_Customer_Primary_Contact__r.AccountId from Apttus__APTS_Agreement__c where Apttus__Account__r.CIDN__c != null and Apttus__Account__r.TCM_MasterID__c != null]);
		Map<Id,Apttus__APTS_Agreement__c> mapOfAgreements = new Map<Id,Apttus__APTS_Agreement__c>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> listOfAgreementIdsToBeUpdate = new Set<Id>();
        Map<Id,Id> accountContactIdMap = new Map<Id,Id>();
        List<Apttus__APTS_Agreement__c> listOfAgreements = new List<Apttus__APTS_Agreement__c>();
		for(Apttus__APTS_Agreement__c agreement: scope){
			mapOfAgreements.put(agreement.Id,agreement); 
		}
        for(Apttus__APTS_Agreement__c agreement : mapOfAgreements.values()){
            if(agreement.APTPS_Customer_Primary_Contact__c == null || agreement.Apttus__Account__c != agreement.APTPS_Customer_Primary_Contact__r.AccountId){
                listOfAgreementIdsToBeUpdate.add(agreement.Id);
                accountIds.add(agreement.Apttus__Account__c);
               }
        }
        for(Contact contactObj : [select Id, AccountId from Contact where AccountId in :accountIds and Email != null]){
            accountContactIdMap.put(contactObj.AccountId,contactObj.Id);
        }
        for(Id agreementIds : listOfAgreementIdsToBeUpdate){
            Id agremeentAccountId = mapOfAgreements.get(agreementIds).Apttus__Account__c;
            mapOfAgreements.get(agreementIds).APTPS_Customer_Primary_Contact__c = accountContactIdMap.get(agremeentAccountId);
            listOfAgreements.add(mapOfAgreements.get(agreementIds));
        }
        if(!listOfAgreements.isEmpty()){
            Database.update(listOfAgreements, false);
        }
    }
    
    /**
* @description gets invoked when the batch job finishes. Place any clean up code in this method.
* @param context contains the job ID
*/ 
    global void finish(Database.BatchableContext context) {
        
    }
}