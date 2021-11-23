@isTest
public with sharing class AccountCIDNRelationshipUpdBatchableTest {


	static testmethod void TestBatchableInterface(){
     
        List<account> lst=Test.loadData(Account.sObjectType, 'TCM_Acc_ACR');
		List<account> lst2=Test.loadData(Account.sObjectType, 'TCM_Account');
           
        
		Test.startTest();
        Account acc = [select Id, CIDN__c, Parent_CIDN__c, ParentId,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c = '12345'];
        acc.Ultimate_Parent_CIDN__c='1234567';
        update acc;
        
		AccountCIDNRelationshipUpdateBatchable batchClass = new AccountCIDNRelationshipUpdateBatchable();
		Database.executeBatch(batchClass, 50);
		Test.stopTest();
 
		Account parentAccount = [select Id, CIDN__c, Parent_CIDN__c, ParentId,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c = '1234567'];
		Account childAccount = [select Id, CIDN__c, Parent_CIDN__c, ParentId,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c = '12345'];

		System.debug('childAccount.ParentId == ' + childAccount.ParentId + ' parentAccount.Id == ' + parentAccount.Id);
		System.assert(childAccount.Ultimate_Parent_Account__c == parentAccount.Id);
	}

	static testmethod void TestSchedulableInterface(){
        
		List<account> lst=Test.loadData(Account.sObjectType, 'TCM_Acc_ACR');
		List<account> lst2=Test.loadData(Account.sObjectType, 'TCM_Account');
        
		Test.startTest();
        Account acc = [select Id, CIDN__c, Parent_CIDN__c, ParentId,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c = '12345'];
        acc.Ultimate_Parent_CIDN__c='1234567';
        update acc;
        AccountCIDNRelationshipUpdateBatchable schedClass = new AccountCIDNRelationshipUpdateBatchable();
		String sch = '0 0 23 * * ?'; 
		System.schedule('Test-Schedulable', sch, schedClass); 
		schedClass.execute(null);
		Test.stopTest();

		Account parentAccount = [select Id, CIDN__c, Parent_CIDN__c, ParentId,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c = '1234567'];
		Account childAccount = [select Id, CIDN__c, Parent_CIDN__c, ParentId,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c = '12345'];
        
		System.debug('childAccount.ParentId === ' + childAccount.ParentId + ' parentAccount.Id === ' + parentAccount.Id);
		System.assert(childAccount.Ultimate_Parent_Account__c  == parentAccount.Id);
	}
}