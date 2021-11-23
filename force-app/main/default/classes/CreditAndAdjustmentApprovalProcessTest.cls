/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-119565
******************************************************************/ 
@isTest
public class CreditAndAdjustmentApprovalProcessTest {

     @testsetup static void CreditAndAdjustmentApprovalProcessDataSetup(){
         
        //Creating Account
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        //Creating Contact
        Contact con = AccountTestFactory.buildContact(acc,'Smith'+System.today());
        con.FirstName = 'ABC'+System.today();
        con.Email = 'test@team.telstra.com';
        insert con;
        
        //Creating BillingAccount
        Billing_Account__c billingAccount = new Billing_Account__c(Account__c = acc.id,Billing_Account_Owner__c = con.id,Billing_Account_Number__c = '123456789012');
        insert billingAccount;
        
        //Creating case
        Case case1 = new Case(Status = System.Label.Case_Status_Approval,Origin = 'Email',Type = 'Billing Enquiry',Subject = 'testbill',AccountID = acc.Id,ContactID = con.ID);
        List<Case> caseList = new List<Case>();
        caseList.add(case1);
        Case case3 = new Case(Status = 'New',Origin = 'Email',Type = 'Billing Enquiry',Subject = 'testbill',AccountID = acc.Id,ContactID = con.ID);
        caseList.add(case3);
        insert caseList;
        test.StartTest();
        //converting case record id to list of string
        String str1 = case1.id;
        List<String> listString = new List<String>();
        listString.add(str1);
        
        //Creating QueriedLineItem
        Queried_Line_Item__c queriedLineItem = new Queried_Line_Item__c(Case__c = caseList.get(0).id,Determination_Amount__c = 900,Max_Credit_Amount__c = 90000,Reason_Code__c = 'Usage enquiry adjustment',Credit_Adjustment__c = null);
        insert queriedLineItem;
        
        //Creating CreditAndAdjustment
        Credits_and_Adjustments__c creditAndAdjustment = new Credits_and_Adjustments__c();
        creditAndAdjustment.Billing_Account_Number_BAN__c = billingAccount.id;
        creditAndAdjustment.reason_Code__c = 'Goodwill Credits – Goodwill Credit';
        creditAndAdjustment.Date_when_credit_was_given_to_customer__c   = Date.today();
        creditAndAdjustment.Credit_Change_Amount__c = 100;
        creditAndAdjustment.Case_Number__c = caseList.get(0).id;
        insert creditAndAdjustment;
        Case case4  = new Case(Status = 'New',Origin = 'Email',Type = 'Billing Enquiry',Subject = 'testbill',AccountID = acc.Id,ContactID = con.ID);
        insert case4;
        case4.status = System.Label.Case_Status_Approval;
        update case4;
         test.StopTest();
    }
    /*** START of EDGE - 89741  
OSAKA Team:EDGE-89741
Sprint: 19.12
Developer: Sasidhar Devarapalli
Test method to cover getQueriedLineItems method written in CreditAndAdjustmentApprovalProcess class
***/
    @isTest
    static void getQueriedLineItemsTest(){	 
        //Creating Account
       /* Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        //Creating Contact
        Contact con = AccountTestFactory.buildContact(acc, 'Smith');
        con.FirstName = 'test1';
        con.Email = 'test1@team.telstra.com';
        insert con;
        
        //Creating BillingAccount
        Billing_Account__c billingAccount = new Billing_Account__c(Account__c = acc.id,Billing_Account_Owner__c = con.id,Billing_Account_Number__c = '123456789012');
        insert billingAccount;
        
        //Creating case
        Case case1 = new Case(Status = System.Label.Case_Status_Approval,Origin = 'Email',Type = 'Billing Enquiry',Subject = 'testbill',AccountID = acc.Id,ContactID = con.ID);
        List<Case> caseList = new List<Case>();
        caseList.add(case1);
        Case case3 = new Case(Status = 'New',Origin = 'Email',Type = 'Billing Enquiry',Subject = 'testbill',AccountID = acc.Id,ContactID = con.ID);
        caseList.add(case3);
        insert caseList;
        
        //converting case record id to list of string
        String str1 = case1.id;
        List<String> listString = new List<String>();
        listString.add(str1);
        
        //Creating QueriedLineItem
        Queried_Line_Item__c queriedLineItem = new Queried_Line_Item__c(Case__c = caseList.get(0).id,Determination_Amount__c = 900,Max_Credit_Amount__c = 90000,Reason_Code__c = 'Usage enquiry adjustment',Credit_Adjustment__c = null);
        insert queriedLineItem;
        
        //Creating CreditAndAdjustment
        Credits_and_Adjustments__c creditAndAdjustment = new Credits_and_Adjustments__c();
        creditAndAdjustment.Billing_Account_Number_BAN__c = billingAccount.id;
        creditAndAdjustment.reason_Code__c = 'Goodwill Credits – Goodwill Credit';
        creditAndAdjustment.Date_when_credit_was_given_to_customer__c   = Date.today();
        creditAndAdjustment.Credit_Change_Amount__c = 100;
        creditAndAdjustment.Case_Number__c = caseList.get(0).id;
        insert creditAndAdjustment;
        Case case4  = new Case(Status = 'New',Origin = 'Email',Type = 'Billing Enquiry',Subject = 'testbill',AccountID = acc.Id,ContactID = con.ID);
        insert case4;
        case4.status = System.Label.Case_Status_Approval;
        update case4;*/
        Contact con= [Select Id,Email from Contact where Email='test@team.telstra.com' LIMIT 1];
        con.Email = null;
        update con;
        Credits_and_Adjustments__c creditAndAdjustment = new Credits_and_Adjustments__c();
        List<Case> caseList=[Select Id from Case where Subject='testbill'];
        List<Case> sourceCaseList = [SELECT id,type,status,Total_Determination__c,Billing_Account__c,(SELECT id,Determination_Amount__c  FROM Queried_Line_Items__r) FROM Case 
                                     WHERE ID = : caseList.get(0).id
                                     AND Status = :System.Label.Case_Status_Approval];
			test.StartTest();
            CreditAndAdjustmentApprovalProcess.getQueriedLineItems(sourceCaseList);
            //System.assertEquals(queriedLineItem.Credit_Adjustment__r.Name,creditAndAdjustment.Name);
            System.assertEquals(sourceCaseList.size()>0,true);
        test.StopTest();
    }
    /*** END of EDGE -  89741 ***/
    
    /*** START OF EDGE-119565  ***/
    @isTest
    static void processCaseRecordTest(){        
        Case caseData = new Case(Status = System.Label.Case_Status_Approval,Origin = 'Email',Type = 'Billing Enquiry',Subject = 'test');
        insert caseData;
        Queried_Line_Item__c queriedLineItem = new Queried_Line_Item__c(Case__c = caseData.id,Determination_Amount__c = 900,Max_Credit_Amount__c = 90000,Reason_Code__c = 'Usage enquiry adjustment',Credit_Adjustment__c = null);
        insert queriedLineItem;
		test.StartTest();
        CreditAndAdjustmentApprovalProcess.processCaseRecord(new List<Id>{caseData.id});
        Credits_and_Adjustments__c creditAjustment = [SELECT ID FROM Credits_and_Adjustments__c WHERE Case_Number__c = :caseData.id];
         System.assert(creditAjustment != null);
        test.StopTest();
         
    }

    /*** END OF EDGE-119565  ***/
}