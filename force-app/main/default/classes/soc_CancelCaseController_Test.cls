/*****************************************************************************
@Author: Kritika Bhati
@CreateDate: 25 march 2019
@Description: Test class for soc_CancelCaseController
@References
Epic :EDGE- 54391: As A Requestor i need to be reminded if i have missed submitting a SFD Request

*******************************************************************************/
@isTest
public class soc_CancelCaseController_Test {
	
     @isTest
    public  static void test_CancelCase(){

        
       	List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
        
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.stage__c = 'Request Review';
        caseObj.OpportunityId__c = oppLine[0].OpportunityId;
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        caseObj.Requestor__c = UserInfo.getUserId();
        
        Test.startTest();
        insert caseObj;
        soc_CancelCaseController.updateCase(caseObj.id);
        Case cs = [Select Id, Status, soc_SFD_Sub_Status__c from Case where Id =: caseObj.id];
        System.assertEquals('Withdrawn', cs.Status);
        Test.stopTest();
	}
}