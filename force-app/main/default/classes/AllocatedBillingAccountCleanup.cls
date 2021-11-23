/*************************************************************************************************
Name        : AllocatedBillingAccountCleanup
Description : Deletion of billing account records with the Allocated status and the creation date <= previous date 
Author      : Veena Putta
Story       : EDGE-170032
Test class	: AllocatedBillingAccountCleanupTest
***************************************************************************************************/
public class AllocatedBillingAccountCleanup implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Name FROM Billing_Account__c WHERE Status__c = 'Allocated' AND Createddate <= YESTERDAY]);        
    }
    public void execute(Database.BatchableContext bc, List<Billing_Account__c> scope){
        if(!scope.isEmpty()){
            delete scope;
        }
        
    }
    public void finish(Database.BatchableContext bc){
        
    }
}