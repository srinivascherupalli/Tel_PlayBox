@isTest
public class AccountContactRelationDomainTest {
    
    @isTest
    public static void AccountContactRelationDomainTest1(){
        account acct=new account(name='TestAccount',CIDN__c='12345',ABN__c='1234');
        insert acct;
        ID id=acct.Id;
        contact con=new contact(lastname='TestContact1',accountId=id);
        insert con;
        AccountContactRelation acr1=NEW AccountContactRelation(Account=acct, Contact=con);  
        List<AccountContactRelation> listAccSelector = new List<AccountContactRelation>();
        listAccSelector.add(acr1);
        test.startTest();
        AccountContactRelationDomain newAccRelList = new AccountContactRelationDomain(listAccSelector);
        System.assertNotEquals(NUll, newAccRelList);
        test.stopTest();
    }
    
    @isTest
    public static void constructorTest(){
        AccountContactRelationDomain.Constructor obj = new AccountContactRelationDomain.Constructor();
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
}