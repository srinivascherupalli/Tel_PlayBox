/*************************************************************************************************
Name 		: AllocatedBillingAccountCleanupTest
Description : Test class for AllocatedBillingAccountCleanup
Author		: Veena Putta
Story		: EDGE-170032
***************************************************************************************************/

@isTest
public class AllocatedBillingAccountCleanupTest {
    
    @TestSetup public static void testSetup(){
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount';
        
        Account acc1 = new Account();
        acc1.Name = 'ParentTestAcc';
        
        accList.add(acc);
        accList.add(acc1);
        insert accList;

        
        Contact con = new Contact();
        con.LastName = 'TestContact';
        con.AccountId = acc1.Id;
        con.Pref_Comm_Method__c = 'Phone';
        con.Authority__c = 'Non-Authorised';
        
        insert con;
        
        Billing_Account__c bAcc = new Billing_Account__c();
        bAcc.Billing_Account_Owner__c = con.Id;
        bAcc.Account__c = acc.Id;
		bAcc.Status__c = 'Allocated';
        bAcc.Billing_Account_Number__c = '000000000002';
        bAcc.CreatedDate = system.today()-2;
        
        insert bAcc;
    }
    
    public static testMethod void allocatedAccount(){  
        Billing_Account__c billingAcc = [SELECT Id FROM Billing_Account__c LIMIT 1];
        
        Test.startTest();
        AllocatedBillingAccountCleanup a = new AllocatedBillingAccountCleanup();
        Id batchId = Database.executeBatch(a);
        System.assert(batchId != null);
        Test.stopTest();
        
        List<Billing_Account__c> delRecs = [SELECT Id,Name FROM Billing_Account__c WHERE Status__c = 'Allocated' AND Createddate <= YESTERDAY];
        system.assert(delRecs.isEmpty());        
    }
    
    public static testmethod void nonAllocatedAcc(){   
        Billing_Account__c nonABAcc = [SELECT Id FROM Billing_Account__c LIMIT 1];
        nonABAcc.Status__c = 'Created';
        update nonABAcc;
        
        Test.startTest();
        AllocatedBillingAccountCleanup a1 = new AllocatedBillingAccountCleanup();
        Id batchId = Database.executeBatch(a1);
        System.assert(batchId != null);
        Test.stopTest();
        
        List<Billing_Account__c> delRecs = [SELECT Id,Name FROM Billing_Account__c WHERE Createddate <= YESTERDAY];
        system.assert(!delRecs.isEmpty());
    }
}