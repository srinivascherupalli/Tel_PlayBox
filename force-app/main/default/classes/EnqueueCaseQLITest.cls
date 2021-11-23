/*******************************************************************************************************************
Class Name : EnqueueCaseQLITest
Description :  When ever user clicks on Invoice Callout quick action in case it will enqueue the job with caseId and set of invoices.
====================================================================================================================
Sr.No.    Developer Name               Date          Story Description
1.        Vamsi Krishna Vaddipalli    02/06/2021      Edge-219120
====================================================================================================================
********************************************************************************************************************/
@isTest
public class EnqueueCaseQLITest {
    
    @testsetup static void setup(){
       
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
		Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
		contactData.email='abc@gmail.com';
		insert contactData;
        
		Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
		insert billingAccountData;
        
		List<Case> caseList = new List<Case>();
        Case caseData  = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
		caseData.AccountId = accountData.Id;
		caseData.ContactId = contactData.Id;
		caseData.Type      = System.Label.Case_Type;
        caseList.add(caseData);

        Case caseData1  = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'In Progress',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
		caseData1.AccountId = accountData.Id;
		caseData1.ContactId = contactData.Id;
		caseData1.Type      = System.Label.Case_Type;
        caseList.add(caseData1);
		insert caseList;  
        
        Invoice__c invdata= new Invoice__c(Name='123434',Aria_Invoice_Number__c='1232');
		insert invdata;
        
        Invoice_Line_Item__c iLI=new Invoice_Line_Item__c(Invoice__c=invdata.id,Invoice_Line_Number__c=13432233, Charge_Excluding_GST__c = 1214,Charge_Type__c= 'RecurringCharge',Invoice_Transaction_ID__c=26022460,Line_Item_Identifier__c='43242342',charge_identifier__c=12453);
		insert iLI;
        
        Queried_Line_Item__c qli = new Queried_Line_Item__c(Case__c = caseData.Id,Invoice_Line_Item__c = ILI.Id,processedByMS__c = -1);
        insert qli;
}
   
    
    @isTest static void testenqueueQLIUsingCaseIdWithQLI()
    {
        Test.startTest();
        Case caseData=[Select id from case where Status = 'New']; 
        Boolean isSuccess = EnqueueCaseQLI.enqueueQLI(caseData.Id);
         Test.stopTest();
         System.assertEquals(isSuccess,true,'Positive scenario passed');
        
        
    }

    @isTest static void testenqueueQLIUsingCaseIdWithoutQLI()
    {
        Test.startTest();
        Case caseData=[Select id from case where Status = 'In Progress']; 
        Boolean isSuccess = EnqueueCaseQLI.enqueueQLI(caseData.Id);
         Test.stopTest();
         System.assertEquals(isSuccess,false,'Negative Scenario Passed');
        
        
    }
    
    
}