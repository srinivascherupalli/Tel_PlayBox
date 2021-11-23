@isTest
public class ProposalRealtedListControllerTests {
	@testSetup 
    static void testDataSetup() {
       SharePoint_Proposal_URL_Prefix__c prefix = new SharePoint_Proposal_URL_Prefix__c();
        prefix.Name = 'Non Prod URL Prefix';
        prefix.Prefix_URL__c = 'https://Test.com';
        insert prefix;
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opp';
        testOpportunity.StageName = 'Develop';
        testOpportunity.CloseDate = System.today();
        testOpportunity.Proposal_Documents__c = '"[ {"filename": "Data and IP Proposal-BT000-217-957.docx", "fileUrl": "/sites/SF-0014Y0000087GXNQA2/A00394840/Proposal/Data and IP Proposal-BT000-217-957.docx","ModifiedDate": "2021-04-30T12:48:40Z" }]"';
    	insert testOpportunity;
    }
    
    @IsTest
    static void testGetOpportunityFromId() {
        Opportunity testOpp = [SELECT Id FROM Opportunity];
        Test.startTest();
        	List<ProposalRelatedListController.ProposalListWrapper> listOfProposal = ProposalRelatedListController.getOpportunityFromId(testOpp.Id);
        Test.stopTest();
        
        System.assertNotEquals(listOfProposal, null, 'List should not be null');
    }
    
    @IsTest
    static void testGetOpportunity() {
        Opportunity testOpp = [SELECT Id FROM Opportunity];
        Test.startTest();
        	Opportunity opp = ProposalRelatedListController.getOpportunity(testOpp.Id);
        Test.stopTest();
        
        System.assertNotEquals(opp, null, 'Opportunity should not be null');
    }
    
    @IsTest
    static void testGetProposal() {
        Opportunity testOpp = [SELECT Id FROM Opportunity];
        Test.startTest();
        	List<ProposalRelatedListController.ProposalListWrapper> listOfProposal = ProposalRelatedListController.getProposal(1,5,testOpp.Id);
        Test.stopTest();
        
        System.assertNotEquals(listOfProposal, null, 'List should not be null');
    }

    @isTest
    static void testCompareTo() {
        ProposalRelatedListController.ProposalListWrapper objPODA = new ProposalRelatedListController.ProposalListWrapper();
        ProposalRelatedListController.ProposalListWrapper obj = new ProposalRelatedListController.ProposalListWrapper();
        Test.startTest();
            Integer i = objPODA.compareTo(obj);
        Test.stopTest();
        System.assertEquals(0, i, 'Value should be 0');
    }
    
    @isTest
    static  void  testCompareToWhenModifiedDateIsLess() {
        ProposalRelatedListController.ProposalListWrapper objPODA = new ProposalRelatedListController.ProposalListWrapper();
        objPODA.ModifiedDate = System.Now();
        ProposalRelatedListController.ProposalListWrapper obj = new ProposalRelatedListController.ProposalListWrapper();
        obj.ModifiedDate = System.Now().addDays(5);
        Test.startTest();
        	Integer i = objPODA.compareTo(obj);
        Test.stopTest();
        System.assertEquals(1, i, 'Value should be 1');
    }
    
    @isTest
    static  void  testCompareToWhenModifiedDateIsGreater() {
        ProposalRelatedListController.ProposalListWrapper objPODA = new ProposalRelatedListController.ProposalListWrapper();
        objPODA.ModifiedDate = System.Now().addDays(5);
        ProposalRelatedListController.ProposalListWrapper obj = new ProposalRelatedListController.ProposalListWrapper();
        obj.ModifiedDate = System.Now();
        Test.startTest();
        	Integer i = objPODA.compareTo(obj);
        Test.stopTest();
        System.assertEquals(-1, i, 'Value should be -1');
    }
}