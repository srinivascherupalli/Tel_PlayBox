/****************************************************************************
@Name				: ClosedOppCSATSurveyTest
@Author				: SFO/Sri, Mounika
@CreateDate			: 31/10/2019
@Sprint 			: 19.15[P2OB-2999]
@Description		: This Class is for test coverage ClosedOppCSATSurvey - P2OB-2999
@Last Modified      : 07/01/2021 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 
*****************************************************************************/
@isTest
public class ClosedOppCSATSurveyTest {
    
    @testSetup
    static void setup(){
        
        List<Account> acclist = new List<Account>();
        Account acc = TestUtil.createAccount('Test');
        acc.Customer_Status__c = 'Active';
        acclist.add(acc);
        Account accOptOut = TestUtil.createAccount('TestOptOut');
        accOptOut.Customer_Status__c = 'Active';
        accOptOut.Opt_out_of_Surveys__c = true;
        acclist.add(accOptOut);
        insert acclist;
        
        List<Contact> conList = new List<Contact>(); 
        Contact con = TestUtil.createContact(acc.id,'TestFirstName','TestLastName');
        conList.add(con);
        
        List<Opportunity> oppList = new List<Opportunity>(); 
        List<OpportunityContactRole> OCRList = new List<OpportunityContactRole>(); 
        
        for(Integer  i=0; i<10; i++){
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.Product_Type__c = 'Modular';
            opp.Attachment_Count__c=1;
            oppList.add(opp);
        }
        
        //To cover negative scenario
        
        Opportunity oppOptOut   = ProductTestFactory.getOpportunityBasic(accOptOut);
        oppList.add(oppOptOut);
        
        insert oppList;
        Contact conOptOut = TestUtil.createContact(accOptOut.id,'TestFirstName','TestLastName');
        conList.add(conOptOut);
        insert conList;        
        
        for(Opportunity op: oppList){
            OpportunityContactRole ocr = TestUtil.createOCR(con,op);
            OCRList.add(ocr);
        }
        OpportunityContactRole ocrOptOut = TestUtil.createOCR(conOptOut,oppOptOut);
        insert OCRList;
    }
    /****************************************************************************
@Method Name	: createOppSurveyInvitationsTestmethod
@Author			: SFO/Sri, Mounika
@Sprint 		: 19.15[P2OB-2999]
@CreateDate		: 31/10/2019
@Description	: This Method is test coverage ClosedOppCSATSurvey class
******************************************************************************/      
    static testMethod void createOppSurveyInvitationsTestmethod()
    {
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Opt_out_of_Surveys__c = false LIMIT 1];
        Account accOptOut = [SELECT Id FROM Account WHERE Opt_out_of_Surveys__c = true LIMIT 1];
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 20];
        ClosedOppCSATSurvey.getSurveyRelatedInfo(oppList);        
        Test.stopTest();
        
        list<Opportunity> opptyList = [select id from Opportunity where name = 'TestOpp' and AccountID =: acc.id limit 1];
        list<SurveyInvitation> surveyInvIList = [select id from SurveyInvitation where Opportunity__c in :opptyList];        
        
        list<Opportunity> opptyOptOutList = [select id from Opportunity where name = 'TestOptOut' and AccountID =: accOptOut.id limit 1];
        list<SurveyInvitation> noSurveyInvIList = [select id from SurveyInvitation where Opportunity__c in :opptyOptOutList];
        
        
        system.assertEquals(false,surveyInvIList.isEmpty());
        
        system.assertEquals(true,noSurveyInvIList.isEmpty());
        
        
    }
}