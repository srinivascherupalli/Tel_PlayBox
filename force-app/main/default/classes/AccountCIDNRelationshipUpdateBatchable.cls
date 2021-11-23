global class AccountCIDNRelationshipUpdateBatchable implements Database.Batchable<sObject>,Schedulable, Database.stateful{
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id, CIDN__c, ParentId, Parent_CIDN__c,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c FROM Account where (Parent_CIDN__c != null AND ParentId = null) OR (Ultimate_Parent_CIDN__c != null AND Ultimate_Parent_Account__c = null)';
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
       MaintainAccountCIDNRelationship.createCIDNRelationships(scope);
    }

    global void execute(SchedulableContext sc)
    {
        AccountCIDNRelationshipUpdateBatchable batchClass = new AccountCIDNRelationshipUpdateBatchable();
        Database.executeBatch(batchClass, 50);
    }

    global void finish(Database.BatchableContext BC) {

    }
}