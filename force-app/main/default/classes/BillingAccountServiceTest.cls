@isTest
public class BillingAccountServiceTest {
    
    @testSetup // datasetup
    public static void testData(){
         //Test class fix for P2OB-12615 validation on AccountContactRelation , Contacts related accounts should be from same hierarchy.
        Account parentAcc=new Account(name='testParentAccount',CIDN__c='1234512',Parent_CIDN__c='1234',Ultimate_Parent_CIDN__c='1234');
        insert parentAcc;
        Account childAcc = new Account(name='testChildAccount',ParentId=parentAcc.id,CIDN__c='123',Parent_CIDN__c='1234',Ultimate_Parent_CIDN__c='1234');
        insert childAcc;
        Account parentAcc1=new Account(name='testParentAccount1',CIDN__c='1234');
        insert parentAcc1;
        Contact cont = new Contact(lastName='DTestContact', AccountId=parentAcc1.id,Sales_Contact_Status__c ='Eligible',Raise_Billing_Disputes__c = true );
        insert cont;
    }
    
    @isTest
    public static void fetchAccountOperationAccountIdTest(){
        Account parentAcc = [SELECT ID FROM Account WHERE name='testParentAccount'];
        Account childAcc = [SELECT ID FROM Account WHERE name ='testChildAccount'];
        Contact cont = [SELECT ID FROM Contact WHERE lastName='DTestContact'];
        Boolean isAllCon = false;
        List<AccountContactRelation> lstOfAccountContactRel = new List<AccountContactRelation>();
        AccountContactRelation acrChild = new AccountContactRelation(AccountId=parentAcc.id, ContactId=cont.id, Job_Description__c='None', Seniority_Level__c='None',Roles= 'Full Authority');
        insert acrChild;
        List<AccountContactRelation> lstOfAccountContactRelRet = BillingAccountService.fetchAccountOperation('t', parentAcc.id,lstOfAccountContactRel,isAllCon);
        Test.startTest();
        lstOfAccountContactRel.add(acrChild);        
        System.assertNotEquals(NULL, lstOfAccountContactRelret);
        Test.stopTest();
    }
    
    @isTest
    public static void fetchAccountOperationParentIdNotNullTest(){
        Account parentAcct=[SELECT ID FROM Account WHERE name='testParentAccount'];
        Account childAcct = [SELECT ID FROM Account WHERE name ='testChildAccount'];
        Contact childCont= [SELECT ID FROM Contact WHERE lastName='DTestContact'];
        AccountContactRelation acr2=NEW AccountContactRelation(AccountId=childAcct.id,  ContactId=childCont.id, Job_Description__c='None', Seniority_Level__c='None',Roles= 'Non-Authorised');
        insert acr2;
        Boolean isAllCon = false;
        List <AccountContactRelation> lstOfSecondaryContact1 = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId =:childAcct.id and ContactId=:childCont.Id];
               
        Test.startTest();
        list <AccountContactRelation> acrList2=BillingAccountService.fetchAccountOperation('T',childAcct.id,lstOfSecondaryContact1,isAllCon);
        System.assertNotEquals(NULL, acrList2);
        list <AccountContactRelation> acrList3=BillingAccountService.fetchAccountOperation('%',childAcct.id,lstOfSecondaryContact1,isAllCon);
        System.assertNotEquals(NULL, acrList3);
        Test.stopTest();
    }
}