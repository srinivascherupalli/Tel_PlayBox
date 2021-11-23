/**
* Developer: Nilima Borse
* Team: Jaipur
* Sprint: 19.16
* Date: 11/22/2019
* modified by: Shreyansh Sharma
* modification date : 11/14/2020, 20.15
* Description: Test class updated to accomodate modify solution button functionality P2OB:10467
**/
@isTest(seeAllData=false)
public class cusdl_orbApprovalControllerTest {
    
    public static Bid__c bidObj;
    public static Case caseObj;
    public static Opportunity testOpp; 
    //Test Method for onLoad Success
    static testMethod void caseWithRelatedRecTest(){
        Test.startTest();
        Case cs = [Select id,OpportunityId__c,cusdl_Bid_Status__c,Stage__c,cusdl_Techscore__c,OpportunityId__r.OwnerId,cusdl_Opty_been_Identified_Qualifieds__c,subject,cusdl_The_Compelling_Events__c,cusdl_Win_Strategy_And_Why_Telstra__c,cusdl_Customer_s_current_environment__c,
                   cusdl_Technical_or_service_issues__c,cusdl_Key_Deliverables_and_Milestones__c,cusdl_Billing_Requirements__c,cusdl_Third_Party_Engagement__c,cusdl_Carriage_and_standard_product__c,cusdl_Third_parties__c,cusdl_Once_off_costs__c,
                   cusdl_Telstra_services__c,cusdl_Pricing_Type__c,cusdl_Benchmarking_Requirements__c,cusdl_Details__c,cusdl_non_standard_contract_pricing_oct__c,cusdl_Proposal_Due_Date__c FROM Case where subject ='Custom Deal TestC'];
        String caseValue = cusdl_orbApprovalController.getCaseValues(cs.id,'onLoad');
        system.assert(caseValue==System.label.cusdl_Bid_record_success);
        Test.stopTest();
    }
    //Test Method for onLoad Failiure/negative scenario
    static testMethod void caseWithOnLoadFail(){
        Test.startTest();
        Case cs = [Select id,OpportunityId__c,cusdl_Bid_Status__c,Stage__c,cusdl_Techscore__c,OpportunityId__r.OwnerId,cusdl_Opty_been_Identified_Qualifieds__c,subject,cusdl_The_Compelling_Events__c,cusdl_Win_Strategy_And_Why_Telstra__c,cusdl_Customer_s_current_environment__c,
                   cusdl_Technical_or_service_issues__c,cusdl_Key_Deliverables_and_Milestones__c,cusdl_Billing_Requirements__c,cusdl_Third_Party_Engagement__c,cusdl_Carriage_and_standard_product__c,cusdl_Third_parties__c,cusdl_Once_off_costs__c,
                   cusdl_Telstra_services__c,cusdl_Pricing_Type__c,cusdl_Benchmarking_Requirements__c,cusdl_Details__c,cusdl_non_standard_contract_pricing_oct__c,cusdl_Proposal_Due_Date__c FROM Case where subject ='Custom Deal TestC'];
        Case cs1 = new Case(id=cs.id,cusdl_Bid_Status__c='Pending DRB Approval');
        update cs1;
        String caseValue = cusdl_orbApprovalController.getCaseValues(cs1.id,'onLoad');
        system.assert(caseValue=='Bid');
        Test.stopTest();
    }
    //Test Method for onClick handle
    static testMethod void caseWithoutRelatedRecTest(){
        Test.startTest();
        Case cs = [Select id,OpportunityId__c,cusdl_Bid_Status__c,Stage__c,cusdl_Techscore__c,OpportunityId__r.OwnerId,cusdl_Opty_been_Identified_Qualifieds__c,subject,cusdl_The_Compelling_Events__c,cusdl_Win_Strategy_And_Why_Telstra__c,cusdl_Customer_s_current_environment__c,
                   cusdl_Technical_or_service_issues__c,cusdl_Key_Deliverables_and_Milestones__c,cusdl_Billing_Requirements__c,cusdl_Third_Party_Engagement__c,cusdl_Carriage_and_standard_product__c,cusdl_Third_parties__c,cusdl_Once_off_costs__c,
                   cusdl_Telstra_services__c,cusdl_Pricing_Type__c,cusdl_Benchmarking_Requirements__c,cusdl_Details__c,cusdl_non_standard_contract_pricing_oct__c,cusdl_Proposal_Due_Date__c FROM Case where subject ='Custom Deal TestC'];
        
        String caseValue = cusdl_orbApprovalController.getCaseValues(cs.id,'onClick');
        system.assert(caseValue==System.label.cusdl_Required_field_message);
        Test.stopTest();
    }
    //TEST METHOD FOR captureSolutionDetails
    // method to generate error message
    static testMethod void caseForcaptureSolutionDetails(){
        Test.startTest();
        Case cs = [Select id,OpportunityId__c,cusdl_Pricing_Approval_Date__c,cusdl_Pricing_Expiry_Date__c,cusdl_SBC_Approval_Date__c,cusdl_Board_Review_Date__c,
                   cusdl_Quality_Approval_Date__c,cusdl_Pricing_Approver__c,cusdl_Quality_Approver__c,cusdl_Quality_Approval_Link__c,
                   cusdl_Pricing_Approval_Link__c FROM Case where subject ='Custom Deal TestC'];
        String caseValue = cusdl_orbApprovalController.getCaseValues(cs.id,'onClickModifySol');
        system.assert(caseValue==System.label.cusdl_Required_field_message);
        Test.stopTest();
        
    }
    //method to generate success message on modify solution button click
    static testMethod void caseForcaptureSolutionDetails1(){
        Test.startTest();
        Case cs = [Select id,OpportunityId__c,AccountId,cusdl_Pricing_Approval_Date__c,cusdl_Pricing_Expiry_Date__c,cusdl_SBC_Approval_Date__c,cusdl_Board_Review_Date__c,
                   cusdl_Quality_Approval_Date__c,cusdl_Pricing_Approver__c,cusdl_Quality_Approver__c,cusdl_Quality_Approval_Link__c,
                   cusdl_Pricing_Approval_Link__c FROM Case where subject ='Custom Deal TestC'];
      
         Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('cusdl_Custom_Deal').getRecordTypeId();

        Case cs1 =new Case();
        cs1.recordTypeId = recordTypeId;
        cs1.OpportunityId__c = cs.OpportunityId__c;
        cs1.AccountId = cs.AccountId;
        cs1.Stage__c = 'Proposed';
        cs1.cusdl_Pricing_Approval_Link__c = 'a';
        cs1.cusdl_Quality_Approval_Link__c = 'a';
        cs1.cusdl_Quality_Approver__c = 'Rob Forsyth';
        cs1.cusdl_Pricing_Approver__c = 'Milan Jindia';
        cs1.cusdl_SBC_Approval_Date__c = date.today();
        cs1.cusdl_Pricing_Expiry_Date__c = date.today();
        cs1.cusdl_Pricing_Approval_Date__c = date.today();
        cs1.cusdl_Quality_Approval_Date__c = date.today();
        cs1.cusdl_Board_Review_Date__c = date.today();
        insert cs1;
        String caseValue = cusdl_orbApprovalController.getCaseValues(cs1.id,'onClickModifySol');
        system.assert(caseValue== 'modifySolButton');
        Test.stopTest();
    }
    
    //Setup Test data
    @testSetup static void setupTestData() {
        Account acct = new Account(Name='Acme corp', Customer_Status__c='ACTIVE');
        insert acct;
        
        testOpp = new Opportunity();
        testOpp.Account = acct;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Qualify';
        testOpp.BidStatus__c = 'Bid Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.Proposal_Required_Date__c = System.Date.today();
        insert testOpp;
        
        caseObj= new Case(Subject='Custom Deal TestC',
                          AccountId=acct.id,
                          Description='Test',
                          OpportunityId__c=testOpp.id,
                          cusdl_Opty_been_Identified_Qualifieds__c='test option',
                          cusdl_Bid_Status__c = 'BRM Review ',
                          Stage__c = 'New',
                          cusdl_The_Compelling_Events__c='test',
                          cusdl_Win_Strategy_And_Why_Telstra__c='test',
                          cusdl_Customer_s_current_environment__c='test option',
                          cusdl_Technical_or_service_issues__c='test',
                          cusdl_Key_Deliverables_and_Milestones__c='test',
                          cusdl_Billing_Requirements__c='test option',
                          cusdl_Third_Party_Engagement__c='test',
                          cusdl_Carriage_and_standard_product__c=100,
                          cusdl_Third_parties__c=100,
                          cusdl_Once_off_costs__c=30,
                          cusdl_Telstra_services__c=50,
                          cusdl_Pricing_Type__c='firm',
                          cusdl_Benchmarking_Requirements__c='Yes',
                          cusdl_Details__c='test',  
                          cusdl_non_standard_contract_pricing_oct__c='OCT Pricing'                          
                         );
        insert caseObj;   
    }
    
}