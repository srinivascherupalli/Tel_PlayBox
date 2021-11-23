@isTest
public class soc_AssignAllChildToMe_Test {
      @TestSetup
    public static void createTestData(){
        Account account = soc_TestUtility.CreateAccount();
        List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
		Case caseObj = new Case();
		caseObj.Status = 'New';
		caseObj.stage__c = 'Request Review';
		caseObj.OpportunityId__c = oppLine.get(0).OpportunityId;
		caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId(); 
		caseObj.AccountId = account.Id;
		insert caseObj;
        Case caseObj1 = new Case();
		caseObj1.Status = 'New';
		caseObj1.stage__c = 'Request Review';
		caseObj1.OpportunityId__c = oppLine.get(0).OpportunityId;
		caseObj1.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId(); 
		caseObj1.AccountId = account.Id;
        caseObj1.ParentId = caseObj.Id;
		insert caseObj1;
		Map<String,Object> results=soc_AssignAllChildToMe.initialize(caseObj.id);
		Case cas=(Case)results.get('case');
		System.assert(cas!=null);
        Test.startTest();
        system.debug('LimitSOQL='+Limits.getQueries());
		caseObj.Stage__c='Validate And Assign Order';
		update caseObj;
        system.debug('LimitSOQL='+Limits.getQueries());
        Test.stopTest();
	}
	@isTest
	public  static void test_visible(){ 
		Case caseObj = [SELECT ID, Stage__c,Status,RecordTypeId, OpportunityId__c FROM CASE LIMIT 1];
		 test.startTest();
		Map<String,Object> results1=soc_AssignAllChildToMe.assignAllChildToParentOwner(caseObj.id);
		Object staus = (Object)results1.get('status');
		System.assert(staus!=null);
		Test.stopTest();
	}
}