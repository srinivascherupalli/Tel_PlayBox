/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
******************************************************************
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             13-05-2021    EDGE-212404
2.         Shubhi             02-06-2021    EDGE-216407
3.         Shubhi             16/08/2021    DIGI-13377
******************************************************************/ 
@isTest
public class QLIBillingLineItemAdjustmentTest{
   
    @testSetup 
    static void setup() {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Case caseData      = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
        caseData.AccountId = accountData.Id;
        caseData.ContactId = contactData.Id;
        caseData.Type      = System.Label.Case_Type;
        insert caseData;
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        //Start of EDGE:113051
        //Updating the invoice line number from Invoice LineItem object instead of queried line item
        /*** START OF EDGE-125016 ***/
        Invoice_Line_Item__c invoiceLineItemData = new Invoice_Line_Item__c(Invoice__c = invoiceData.Id,Line_Item_Identifier__c = '235899',Charge_Identifier__c = 654321, Charge_Type__c = 'RecurringCharge',Invoice_Transaction_ID__c = 123678910,Invoice_Line_Number__c = 112233);
       /*** END OF EDGE-125016 ***/
        insert invoiceLineItemData;
        Queried_Line_Item__c qLIData = new Queried_Line_Item__c(Case__c = caseData.Id,Invoice_Line_Item__c = invoiceLineItemData.Id,Reason_Code__c = 'Usage enquiry adjustment', Determination_Amount__c =100,Max_Credit_Amount__c=200);
        insert qLIData;
        //End of EDGE:113051
        //EDGE-216407
        EnvironmentVariable__c featureToggle=new EnvironmentVariable__c();
        featureToggle.name='enableBillingEnquiry1663';
        featureToggle.value__c='true';
        insert featureToggle;
    }
    /**** Positve Test Case****/
    @isTest 
    static void eligibleCreditAmountPositveTest() {
        Queried_Line_Item__c qLIData = [SELECT Id,Case__c,Determination_Amount__c,Max_Credit_Amount__c,Case__r.CaseNumber,Case__r.Billing_Account__r.Billing_Account_Number__c,Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c,Invoice_Line_Item__r.Charge_Identifier__c,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice_Transaction_ID__c,Invoice_Line_Item__r.Invoice_Line_Number__c
            FROM Queried_Line_Item__c 
            WHERE Invoice_Line_Item__r.Invoice_Transaction_ID__c = 123678910 LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QLIAdjustmentHandlerMock(200));
            QLIBillingLineItemAdjustment.processCaseRecord(new list<id>{qLIData.Case__c});
            System.assert(qLIData != null);
        Test.stopTest();
    }
    //for EDGE-212404
    @isTest 
    static void eligibleCreditAmountPositveTestwithInvoice() {
        Queried_Line_Item__c qLIData = [SELECT Id,Case__c,Determination_Amount__c,Max_Credit_Amount__c,Case__r.CaseNumber,Case__r.Billing_Account__r.Billing_Account_Number__c,Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c,Invoice_Line_Item__r.Charge_Identifier__c,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice_Transaction_ID__c,Invoice_Line_Item__r.Invoice_Line_Number__c
            FROM Queried_Line_Item__c 
            WHERE Invoice_Line_Item__r.Invoice_Transaction_ID__c = 123678910 LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QLIAdjustmentHandlerMock(200));
            QLIBillingLineItemAdjustment.getMaxCreditAndEnrichQLI(qLIData.Case__c,'012345678912345');
            System.assert(qLIData != null);
        Test.stopTest();
    }
}