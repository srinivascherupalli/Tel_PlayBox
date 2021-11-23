@isTest
public class GenerateRec_CreateCaseTest {
	
    @isTest
    public static void test(){
        Account acct = new Account(Name='Acme corp', Customer_Status__c='ACTIVE');
        insert acct;
        
        Opportunity testOpp = new Opportunity(); 
        testOpp.Account = acct;
        testOpp.AccountId = acct.Id;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Qualify';
        testOpp.BidStatus__c = 'Bid Created';
        testOpp.Product_Domain__c = 'DATA & IP';
        testOpp.CloseDate = System.Date.today();
        testOpp.Proposal_Required_Date__c = System.Date.today();
        insert testOpp;
		Id devRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Presales_Solution').getRecordTypeId();
        
        Case caseObj = new Case();
        caseObj= new Case(Subject='CPE Test',
                          AccountId=acct.id,
                          Description='Test',
                          OpportunityId__c=testOpp.id,
                          salesup_Support_Type__c = 'CPE Hardware And Services',
                          salesup_Work_Required__c = 'HW&S Quote Support',
                          srvsup_Categories__c='Pricing And Quote Support',
                          cpe_Quote_Status__c='Awaiting Approval',
                          RecordTypeId = devRecordTypeId,
                          Additional_Domains__c = 'DATA & IP'
                         );
        insert caseObj;
        GenerateRec_CreateCase gc = new GenerateRec_CreateCase();
        List<String> caseIdList = new List<String>();
        caseIdList.add(caseObj.Id);
        System.AssertEquals(caseIdList.size(),1);
        GenerateRec_CreateCase.getRecommendations(caseIdList);
    }
}