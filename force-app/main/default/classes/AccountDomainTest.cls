@isTest
public class AccountDomainTest {
    
    @isTest
    public static void constructorTest(){
        AccountDomain.Constructor obj = new AccountDomain.Constructor();
        Account acct = new Account(name='testAccount',CIDN__c='12345',ABN__c='1234');
        insert acct;
        ID acctId = acct.Id;
        Contact cont = new Contact(lastName='TestContact',AccountId=acctId);
        insert cont;
        AccountContactRelation acr1=NEW AccountContactRelation(Account=acct, Contact=cont);
        List < AccountContactRelation > sObjectList = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acct.id and ContactId=:cont.Id];    
        sObjectList.add(acr1);
        test.startTest();
        fflib_SObjectDomain ref = obj.construct(sObjectList);
        System.assertNotEquals(NULL, ref);
        test.stopTest();
    }
    
    @isTest
    public static void getAllParentIdsInvalidfieldApiNameTest(){
        Account newParentAcct= new Account(name='TestParentAccount',CIDN__c='123467',ABN__c='12323',Parent_CIDN__c='123');
        Insert newParentAcct;
        Account newAccount = new Account(name='ParentChildHirerchyAccount', ParentID=newParentAcct.id);
        insert newAccount;
        list<Account> acctList = new list<Account>();
        acctList.add(newAccount);
        AccountDomain controller = new AccountDomain(acctList);
        Map<String, Object> treeData = new Map<String, Object>();
        test.startTest();
        treeData= controller.getAllParentIds();
        System.debug('treeData' +treeData);
        System.assertNotEquals(Null, treeData);
        test.stopTest();
    }
    
    @isTest
    public static void getAllParentIdsTest(){
        list<Account> acctList = new list<Account>();
        Account newParentAcct= new Account(name='TestParentAccount',CIDN__c='1234',ABN__c='123');
        insert newParentAcct;
        Account newAccount = new Account(name='TestParentChildHirerchyAccount', ParentID=newParentAcct.Id,Parent_CIDN__c='123' );
        insert newAccount;
        acctList.add(newAccount);
        AccountDomain controller = new AccountDomain(acctList);
        Map<String, Object> treeDataTest = new Map<String, Object>();
        test.startTest();
        treeDataTest= controller.getAllParentIds();
        System.debug('treeDataTest' +treeDataTest); 
        
        //If SOQL Limit has reached
        ObjectHierarchy_Utility.SOQLLimitReached = true;
        treeDataTest= controller.getAllParentIds();
        System.debug('treeDataTest' +treeDataTest);
        test.stopTest();
        System.assertNotEquals(Null, treeDataTest);
        
    }
    
    @isTest
    private static void validateFieldExceptionTest(){
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'StandardUser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        user testUser = new User(
            Alias = 'standT', 
            Email='standarduser@testorg.com',
            emailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            localeSidKey='en_US', 
            ProfileId = testProfile.Id,
            timeZoneSidKey='America/Los_Angeles',
            userName=uniqueUserName);
        
        System.runAs(testUser) {
            // The following code runs as user 'testUser'
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            Account newParentAcct= new Account(name='TestParentAccount',CIDN__c='123467',ABN__c='12323',Parent_CIDN__c='123');
            insert newParentAcct;
            Account newAccount = new Account(name='TestParentChildHirerchyAccount', ParentID=newParentAcct.Id);
        	insert newAccount;
            list<Account> acctList = new list<Account>();
            
            test.startTest();
            //Validate Name Field
            Account newAccount1 = [SELECT ID,CIDN__c from Account where name = 'TestParentAccount'];
            acctList.add(newAccount1);
            AccountDomain controller = new AccountDomain(acctList);
            Map<String, Object> treeData = new Map<String, Object>();
            treeData= controller.getAllParentIds();
            System.debug('treeData' +treeData);
            
            //Validate Parent Field
            list<Account> acctList2 = new list<Account>();
            Account newAccount2 = [SELECT ID,ParentId from Account where name = 'TestParentAccount'];
            System.debug('newAccount2' +newAccount2);
            acctList2.add(newAccount);
            System.debug('acctList2' +acctList2);
            AccountDomain controller1 = new AccountDomain(acctList2);
            Map<String, Object> treeData1 = new Map<String, Object>();
            treeData1= controller1.getAllParentIds();
            System.debug('treeData1' +treeData1);
            test.stopTest();
            System.assertNotEquals(Null, treeData1);
            
        }
        
    }
}