/*
 *@Created By : Kamlesh Kumar
 *@Created Date : 12/4/2021
 *@Breif :  Test class created for CustomerCommsOnCoBACompletion
 */
@isTest
public class CustomerCommsOnCoBACompletionTest {
    @testSetup
    static void setup()
    {
        Test.starttest();
        Account customerAccount = new Account();
        customerAccount.Name = 'test Account' ;
        customerAccount.Type = 'Competitor' ;
        customerAccount.Account_Status__c='Active';
        customerAccount.Customer_Status__c  = 'Active';
        insert customerAccount;
            
        list<Opportunity> oppList = new list<Opportunity>();
        Opportunity opp =TestUtil.createOpportunity(customerAccount.id);
        opp.Product_Type__c='Modular';
        opp.Opportunity_Type__c='Disconnected';
        opp.Contract_Attachment_Count__c=1;
        opp.Attachment_Count__c=1;
        oppList.add(opp) ;

        Opportunity opp2 =TestUtil.createOpportunity(customerAccount.id);
        opp2.Name='testopporunity1';
        opp2.Product_Type__c='Modular';
        opp2.Opportunity_Type__c='Disconnected';
        opp2.Contract_Attachment_Count__c=1;
        opp2.Attachment_Count__c=1;
        oppList.add(opp2) ;
        insert oppList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;

        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbe1;

        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();

        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,Description='test,test,test,test',PriceBookEntryID=pbe1.id, quantity=4,Domain__c='UNIFIED COMMUNICATIONS', totalprice=200);
        oliList.add(lineItem1) ;

        OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=opp2.id,Description='test,test,test,test',PriceBookEntryID=pbe1.id, quantity=4,Domain__c='UNIFIED COMMUNICATIONS', totalprice=200);
        oliList.add(lineItem2) ;
        insert oliList;
        
        List<Case> caseList = new List<Case>();
        Case caseObj = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('Change_of_Billing_Account').RecordTypeId,customerAccount.id,opplist[1].id,'Parent case');
        caseObj.Reason = 'Requested by Customer';
        caseObj.Status = 'Closed';
        caseList.add(caseObj);

        Case caseChildObj = TestUtil.createCaseEnterprise(Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('Change_of_Billing_Account').RecordTypeId,customerAccount.id,opplist[1].id,'This is child case');
        caseChildObj.ParentId = caseObj.id;
        caseChildObj.Status = 'Closed';
        caseChildObj.Reason = 'Requested by Customer';
        caseList.add(caseChildObj); 
        insert caseList;
        Test.stoptest();   
        
    }
    
    static testMethod void sendCoBACaseClosureEmailTest(){
        Test.starttest();
        Utility_Settings__c tu=new Utility_Settings__c (Template_Name__c = 'CoBA Case Completion');
        insert tu;
        APXTConga4__Conga_Email_Template__c testCongaNew4 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew4.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew4.APXTConga4__Name__c = 'CoBA Case Completion';
        testCongaNew4.APXTConga4__Subject__c = 'This is testing : [CoBASubject]';
        insert testCongaNew4;
        List<Case> caseObjList = [SELECT id, Status FROM case WHERE Status = 'Closed'];
        Set<Id> caseId = new Set<Id>();
        for(Case cc:caseObjList ) {
             caseId.add(cc.id);
         }
        CustomerCommsOnCoBACompletion.sendCoBACaseClosureEmail(caseId);
        System.assertEquals('Closed', caseObjList[0].Status);
        
        Test.stoptest();
    }
}