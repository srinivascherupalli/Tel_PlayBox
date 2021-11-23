@isTest
public class ACRErrorMessagesClass_Test{
@testSetup
static void setup()
{   
     Account acc =TestUtil.createAccount('test');
     insert acc;
     Contact con = TestUtil.createContact(acc.id,'TestFirst','TestLast');
     insert con;

}
static testMethod void ACRErrorMessagesMethod()
{   
    
     AccountContactRelation acr = [Select Id,AccountId,ContactId, Job_Description__c,Seniority_Level__c from AccountContactRelation where Account.Name = 'test' AND Contact.Firstname = 'TestFirst'];
     acr.Seniority_Level__c='Chief Customer Officer';
     acr.Job_Description__c='';
     update acr;
     Contact con= [Select id from contact where Contact.Firstname = 'TestFirst'];
     Test.startTest();
     Apexpages.StandardController stdController = new Apexpages.StandardController(con); 
     ApexPages.currentPage().getParameters().put('id',string.valueof(con.Id));
     ACRErrorMessagesClass AcrClass = new ACRErrorMessagesClass(stdController);
     Test.stopTest();
     system.assertEquals(AcrClass.ACRVer, False);
}
static testMethod void ACRErrorMessagesMethod2()
{ 
  
    AccountContactRelation acr1 = [Select Id,AccountId,ContactId,Contact_Usage__c,Job_Description__c,Seniority_Level__c FROM AccountContactRelation where Account.Name = 'test' AND Contact.Firstname = 'TestFirst'];
    acr1.Seniority_Level__c='Chief Customer Officer';
    acr1.Job_Description__c='Business Development';
    acr1.Contact_Usage__c = 'Business';
    update acr1;
    Contact con= [Select id from contact where Contact.Firstname = 'TestFirst'];
    Test.startTest();
    Apexpages.StandardController stdController = new Apexpages.StandardController(con); 
     ApexPages.currentPage().getParameters().put('id',string.valueof(con.Id));
     ACRErrorMessagesClass AcrClass = new ACRErrorMessagesClass(stdController);
    Test.stopTest();
    system.assertEquals(AcrClass.ACRVer, True);
    system.debug('acr1:::::'+acr1);
}
}