/*******************************************************************************************************************
Class Name : Model_QueriedLineItems
Test Class : Model_QueriedLineItemsTest
Description :  Model class for Queried Line Items
====================================================================================================================
Sr.No.    Developer Name               Date          Story Description
1.        Vamsi Krishna Vaddipalli    02/06/2021      Edge-219120
2.         Shubhi            		  02-06-2021       EDGE-216407
3.        Aman Soni                   08/06/2021      EDGE-207869 
====================================================================================================================
********************************************************************************************************************/
@isTest
public class Model_QueriedLineItemsTest {
    
        @testsetup static void setup(){

        //Added by Aman Soni for EDGE-207869  || Start
        Profile billConsultantPF = [select id from profile where name = 'Billing Consultant'];
        Profile asaPF = [select id from profile where name = 'Assurance Service Agent'];
        List<User> userList = new List<User>();
        User billConsUser = new User(alias = 'standt',email='billinguser@testbc.com',emailencodingkey='UTF-8',IsActive =true,
            lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
            profileid = billConsultantPF.id,
            timezonesidkey='Australia/Sydney',
            username='billinguser@testbc.com',phone='+121231231234');
        userList.add(billConsUser);

        User asaUser = new User(alias = 'standt',email='assuranceuser@testasa.com',emailencodingkey='UTF-8',IsActive =true,
            lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
            profileid = asaPF.id,
            timezonesidkey='Australia/Sydney',
            username='assuranceuser@testasa.com',phone='+121231231234');
        userList.add(asaUser);
        insert userList;
        //Added by Aman Soni for EDGE-207869  || End
       
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
		insert caseList;  
        
        Invoice__c invdata= new Invoice__c(Name='123434',Aria_Invoice_Number__c='1232');
		insert invdata;
        
        Invoice_Line_Item__c iLI=new Invoice_Line_Item__c(Invoice__c=invdata.id,Invoice_Line_Number__c=13432233, Charge_Excluding_GST__c = 1214,Charge_Type__c= 'RecurringCharge',Invoice_Transaction_ID__c=26022460,Line_Item_Identifier__c='43242342',charge_identifier__c=12453);
		insert iLI;
        
        Queried_Line_Item__c qli = new Queried_Line_Item__c(Case__c = caseData.Id,Invoice_Line_Item__c = ILI.Id,processedByMS__c = -1,Queried_Amount__c=10.05);
        insert qli;
}
    
    @isTest static void testQLIwithInvoicePositive()
    {
        Test.startTest();
        Case caseData=[Select id from case where Status = 'New']; 
       List<Queried_Line_Item__c> qliList = Model_QueriedLineItems.getQLIwithInvoiceItems(caseData.id);
         Test.stopTest();
         System.assert(qliList.size()>0);
    }

   //  EDGE-216407 start---------------

   @isTest static void getQLINotProcessedByMsPositive()
   {
        Test.startTest();
        Map<id,Case> caseDatamap=new Map<id,Case>([Select id from case]); 
        List<Queried_Line_Item__c> qliList = Model_QueriedLineItems.getQLINotProcessedByMs(caseDatamap.keyset());
        System.assert(qliList[0].processedByMS__c!=1);
        Test.stopTest();
   }
   @isTest static void getQLINotProcessedByMsNegative()
   {
        Test.startTest();
        List<Queried_Line_Item__c> qliList = Model_QueriedLineItems.getQLINotProcessedByMs(new Set<Id>());
        System.assert(qliList.size()==0);
        Test.stopTest();
   }

   @isTest static void getQLIforGetMaxPositive()
   {
        Test.startTest();
        List<Id> caseIds=new List<Id>();
        Map<id,Case> caseDatamap=new Map<id,Case>([Select id from case]); 
        caseIds.addAll(caseDatamap.keySet());
        List<Queried_Line_Item__c> qliList = Model_QueriedLineItems.getQLIforGetMax(caseIds);
        System.assert(qliList.size()>0);
        Test.stopTest();
   }
   @isTest static void getQLIforGetMaxNegative()
   {
        Test.startTest();
        List<Queried_Line_Item__c> qliList = Model_QueriedLineItems.getQLIforGetMax(new List<Id>());
        System.assert(qliList.size()==0);
        Test.stopTest();
   }
   //  EDGE-216407end----------------

   /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207869(21.08)
    Method        : getExistingQlisPos
    Author        : Aman Soni
    ------------------------------------------------------------------*/
   @isTest static void getExistingQlisPos()
   {
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];

        Test.startTest();
            Case caseRec = [Select id,Subject,Description from Case];
            Queried_Line_Item__c qli = [Select id,Queried_Amount__c from Queried_Line_Item__c];
            String caseId = caseRec.id;
            List<Queried_Line_Item__c> qliList = new List<Queried_Line_Item__c>();
            
            System.runAS(billUser){
                qliList = Model_QueriedLineItems.getExistingQlis(caseId, '123434');
                if(!qliList.isEmpty()){
                    System.assertEquals(qli.Queried_Amount__c,qliList[0].Queried_Amount__c);
                }
            }
            System.runAS(asaUser){
                qliList = Model_QueriedLineItems.getExistingQlis(caseId, '123434');
                if(!qliList.isEmpty()){
                    System.assertEquals(qli.Queried_Amount__c,qliList[0].Queried_Amount__c);
                }
            }       
        Test.stopTest();
   }

   /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207869(21.08)
    Method        : NoExistingQlis
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void NoExistingQlis(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        Test.startTest();
        List<Queried_Line_Item__c> qliList = new List<Queried_Line_Item__c>();
            System.runAS(billUser){
                qliList = Model_QueriedLineItems.getExistingQlis('','');
                System.assertEquals(true,qliList.isEmpty());
            }
            System.runAS(asaUser){
                qliList = Model_QueriedLineItems.getExistingQlis('','');
                System.assertEquals(true,qliList.isEmpty());
            }
        Test.stopTest();
    }

}