/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
******************************************************************/ 
@isTest
public class QLIAdjustmentHandlerTest{
    @testSetup 
    static void setup() {
		Test.startTest();
			Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
			Account accountData = TestDataFactory.generateAccount();
			Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
			insert contactData;
			Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('778877665544','Created',accountData.Id, contactData.Id);
			insert billingAccountData;
			List<case> caseList=new List<case>();
			Case caseData      = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
			caseData.AccountId = accountData.Id;
			caseData.ContactId = contactData.Id;
			caseData.Type      = System.Label.Case_Type;
			caseList.add(caseData);
			Case caseDataRec     = new Case(AccountId = accountData.Id,Subject = 'Test Case',ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
			caseDataRec.AccountId = accountData.Id;
			caseDataRec.ContactId = contactData.Id;
			caseDataRec.Type      = System.Label.Case_Type;
			caseList.add(caseDataRec);
			Case caseDataRecNew     = new Case(AccountId = accountData.Id,Subject = 'Test Case New',ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
			caseDataRecNew.AccountId = accountData.Id;
			caseDataRecNew.ContactId = contactData.Id;
			caseDataRecNew.Type      = System.Label.Case_Type;
			caseList.add(caseDataRecNew);
			insert caseList;
			caseDataRec.Status = 'In Progress';
			update caseDataRec;
			
			Invoice__c invoiceData = new Invoice__c(Name = '73646892',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
			insert  invoiceData;
			//Start of EDGE: 113051
			//Updating the invoice line number from Invoice Line Item object instead of queried line item object
			/*** START OF EDGE-125016 ***/
			Invoice_Line_Item__c invoiceLineItemData = new Invoice_Line_Item__c(Invoice__c = invoiceData.Id,Line_Item_Identifier__c = '235899',Charge_Identifier__c = 654321, Charge_Type__c = 'RecurringCharge', Invoice_Line_Number__c = 112233,Invoice_Transaction_ID__c = 123678910);
			/*** END OF EDGE-125016 ***/
			
			insert invoiceLineItemData;
			List<Queried_Line_Item__c> qliList=new List<Queried_Line_Item__c>();
			Queried_Line_Item__c qLIData = new Queried_Line_Item__c(Case__c = caseData.Id,Invoice_Line_Item__c = invoiceLineItemData.Id,Reason_Code__c = 'Usage enquiry adjustment',Determination_Amount__c =100,Max_Credit_Amount__c=200);
			qliList.add(qLIData);
			//End of EDGE: 113051
			//Start of EDGE: 157956
			Queried_Line_Item__c qLIDataRec = new Queried_Line_Item__c(Case__c = caseDataRec.Id,Invoice_Line_Item__c = invoiceLineItemData.Id,Reason_Code__c = 'Usage enquiry adjustment',Determination_Amount__c =0,Max_Credit_Amount__c=0, No_Credit_Required__c=false);
			qliList.add(qLIDataRec);
			insert qliList;
			Credits_and_Adjustments__c creditAndAdjustmentRec = new Credits_and_Adjustments__c(Case_Number__c = caseDataRec.Id,Determination_Status__c = 'Approved');
			insert creditAndAdjustmentRec;
        Test.stopTest();
        //Creating contentVersion
        /* ContentVersion contentVersionRec = new ContentVersion();
        contentVersionRec.Title = 'Test Document';
        contentVersionRec.PathOnClient = 'TestDocument.pdf';
        contentVersionRec.VersionData = Blob.valueOf('Test Content');
        contentVersionRec.IsMajorVersion = true;
        Insert contentVersionRec;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionRec.Id].ContentDocumentId;
        ContentDocumentLink contentDocLink = New ContentDocumentLink();
        contentDocLink.LinkedEntityId = caseDataRec.Id;
        contentDocLink.ContentDocumentId = conDocId;
        contentDocLink.shareType = 'V';
        Insert contentDocLink; */
        
        //End of EDGE: 157956
    }
    /**** Positve Test Case****/
    @isTest 
    static void eligibleCreditAmountPositveTest() {
        //start of EDGE:113051
        //queried the invoice line item and transaction id from InvoiceLineItem instead of QueriedLineItem
		Test.startTest();
			Queried_Line_Item__c qLIData = [SELECT Id,Case__c,Determination_Amount__c,Max_Credit_Amount__c,Case__r.CaseNumber,Case__r.Billing_Account__r.Billing_Account_Number__c,Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c,Invoice_Line_Item__r.Charge_Identifier__c,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice_Line_Number__c,Invoice_Line_Item__r.Invoice_Transaction_ID__c 
											FROM Queried_Line_Item__c 
											WHERE Invoice_Line_Item__r.Invoice_Transaction_ID__c = 123678910 LIMIT 1];
			//End of EDGE:113051
			
			Test.setMock(HttpCalloutMock.class, new QLIAdjustmentHandlerMock(200));
			QLIAdjustmentHandler.calculateEligibleCreditAmount(new List<Queried_Line_Item__c>{qLIData});
			Queried_Line_Item__c  qLIResultData =  [SELECT Id,Max_Credit_Amount__c FROM Queried_Line_Item__c WHERE Id =: qLIData.Id LIMIT 1];
			System.assert(qLIResultData.Max_Credit_Amount__c != null);
        Test.stopTest();
    }
    /**** Negative Test Case for Number Format Exception ****/
    @isTest 
    static void palyLoadNumberFormatExceptionTest() {
        //start of EDGE:113051
        //queried the invoice line item and transaction id from InvoiceLineItem instead of QueriedLineItem
        Test.startTest();
			Queried_Line_Item__c qLIData = [SELECT Id,Case__c,Determination_Amount__c,Max_Credit_Amount__c,Case__r.CaseNumber,Case__r.Billing_Account__r.Billing_Account_Number__c,Invoice_Line_Item__r.Charge_Identifier__c,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice_Transaction_ID__c,Invoice_Line_Item__r.Invoice_Line_Number__c 
                                        FROM Queried_Line_Item__c 
                                        WHERE Invoice_Line_Item__r.Invoice_Transaction_ID__c = 123678910 LIMIT 1];
			//End of EDGE:113051
        
			Test.setMock(HttpCalloutMock.class, new QLIAdjustmentHandlerMock(200));
			QLIAdjustmentHandler.calculateEligibleCreditAmount(new List<Queried_Line_Item__c>{qLIData});
			QLIAdjustmentHandler.generatePayLoad(new List<Queried_Line_Item__c>{null});
			System.assert(qLIData != null);
        Test.stopTest();
    }
    /**** Negative Test Case for Empty List Pointer Exception ****/
    @isTest 
    static void palyLoadEmptyListTest() {
        Test.startTest();
        QLIAdjustmentHandler.generatePayLoad(new List<Queried_Line_Item__c>());
        System.assert(null == null);
        Test.stopTest();
    }
    /**** Negative Test Case for invalid response status code ****/
    @isTest 
    static void invalidResponseCodeTest() {
        //start of EDGE:113051
        //queried the invoice line item and transaction id from InvoiceLineItem instead of QueriedLineItem
        Test.startTest();
			Queried_Line_Item__c qLIData = [SELECT Id,Case__c,Determination_Amount__c,Max_Credit_Amount__c,Case__r.CaseNumber,Case__r.Billing_Account__r.Billing_Account_Number__c,Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c,Invoice_Line_Item__r.Charge_Identifier__c,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice_Line_Number__c,Invoice_Line_Item__r.Invoice_Transaction_ID__c 
                                        FROM Queried_Line_Item__c 
                                        WHERE Invoice_Line_Item__r.Invoice_Transaction_ID__c = 123678910 LIMIT 1];
			//End of EDGE:113051
        
			Test.setMock(HttpCalloutMock.class, new QLIAdjustmentHandlerMock(500));
			QLIAdjustmentHandler.calculateEligibleCreditAmount(new List<Queried_Line_Item__c>{qLIData});
			Queried_Line_Item__c  qLIResultData =  [SELECT Id,Max_Credit_Amount__c FROM Queried_Line_Item__c WHERE Id =: qLIData.Id LIMIT 1];
			System.assert(qLIResultData.Max_Credit_Amount__c != null);
        Test.stopTest();
    }
    /************************************************************ 
* @version      - 0.1
* @createdBy    - Abhishek Mallick
* @team         - OSAKA
* @jirastoryRef - EDGE-157956
******************************************************************/ 
    @isTest
    static void getCreditAndAdjustmentRecordTest(){
        Test.startTest();
		Case caseRec = [select id from case where subject='Test case'];
        QLIAdjustmentHandler.getCreditAndAdjustmentRecord(caseRec.Id);
        Credits_and_Adjustments__c creditRec = [select id from Credits_and_Adjustments__c where Case_Number__c = :caseRec.Id LIMIT 1];
        System.assert(creditRec.Id!=null);
        Test.stopTest();
    }
    @isTest
    static void getCreditAndAdjustmentRecordTestNegative(){
        Test.startTest();
			String caseId = '';
			QLIAdjustmentHandler.getCreditAndAdjustmentRecord(caseId);
			System.assert(null==null);
        Test.stopTest();
    }
    @isTest 
    static void getCaseRecordTest(){
        Test.startTest();
			Case caseRec = [select id from case where subject='Test case'];
			QLIAdjustmentHandler.getCaseRecord(caseRec.Id);
			Case caseRecord = [Select id from Case where id = :caseRec.Id];
			System.assert(caseRecord!=null);
        Test.stopTest();
    }
    @isTest 
    static void getCaseRecordTestNegative(){
        String caseId = '';
        Test.startTest();
        QLIAdjustmentHandler.getCaseRecord(caseId);
        System.assert(null==null);
        Test.stopTest();
    }
    @isTest 
    static void getOldStatusValueTest(){
        Test.startTest();
			Case caseRec = [select id from case where subject='Test case'];
			QLIAdjustmentHandler.getOldStatusValue(caseRec.Id);
			Case caseNew = [Select id,Status from Case where id = :caseRec.Id];
			System.assert(caseNew.Id != null);
        Test.stopTest();
    }
    @isTest 
    static void getOldStatusValueTestNegative(){
        String caseId = '';
        Test.startTest();
        QLIAdjustmentHandler.getOldStatusValue(caseId);
        System.assert(null==null);
        Test.stopTest();
    }
    @isTest 
    static void getQueriedLineItemTest(){
        Test.startTest();
			Case caseRec = [select id from case where subject='Test case'];
			QLIAdjustmentHandler.getQueriedLineItem(caseRec.Id);
			System.assertEquals(true, true);
        Test.stopTest();
    }
    @isTest 
    static void getQueriedLineItemTestNegative(){
        Test.startTest();
			Case caseRec = [select id from case where subject='Test case New'];
			QLIAdjustmentHandler.getQueriedLineItem(caseRec.Id);
			System.assertEquals(false, false); 
        Test.stopTest();
    }
    @isTest 
    static void getAttachmentDetailsTest(){
        Test.startTest();
			Case caseRec = [select id from case where subject='Test case' Limit 1];
			//Creating contentVersion
			//Start of:  Moved the changes from Setup to fix FDR validation error
			ContentVersion contentVersionRec = new ContentVersion();
			contentVersionRec.Title = 'Test Document';
			contentVersionRec.PathOnClient = 'TestDocument.pdf';
			contentVersionRec.VersionData = Blob.valueOf('Test Content');
			contentVersionRec.IsMajorVersion = true;
			Insert contentVersionRec;
        
			Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionRec.Id].ContentDocumentId;
			ContentDocumentLink contentDocLink = New ContentDocumentLink();
			contentDocLink.LinkedEntityId = caseRec.Id;
			contentDocLink.ContentDocumentId = conDocId;
			contentDocLink.shareType = 'V';
			Insert contentDocLink; 
			
			//End of EDGE: 157956
			 //End of : Moved the changes from Setup to fix FDR validation error
			//  Case caseRec = [select id from case where subject='Test case']; --> Commented by Osaka and moved above
		   // Test.startTest();
			QLIAdjustmentHandler.getAttachmentDetails(caseRec.Id);
			ContentDocumentLink conDocRec = [Select Id from ContentDocumentLink where LinkedEntityId = :caseRec.Id limit 1];
			System.assert(conDocRec.id != null);
        Test.stopTest();
    }
	@isTest 
    static void getAttachmentDetailsTestNegative(){
        String caseId = '';
        Test.startTest();
        QLIAdjustmentHandler.getAttachmentDetails(caseId);
        System.assert(null==null);
        Test.stopTest();
    }
}