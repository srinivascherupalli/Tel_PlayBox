/*
* Created By: Sanjay Thakur
* Reason: Test class to Cover salesup_Submit_for_ApprovalClass
* Story: P2OB-5940   
*/


@isTest(seeAllData=false)

public class salesup_Submit_for_ApprovalClassTest {
 		//Test method start
 		//P2OB-5994 - Fetches case status from case ID.
    	static testMethod void fetchCaseStatusTest(){
        Case caseObj = new Case();
        caseObj.subject = 'Test Case Record';				  //creating test data
        caseObj.Status = 'Approval Pending';
        caseObj.description = 'Test Case description';
        test.StartTest();
        insert caseObj;										  //insert data
        System.assert(caseObj.id!= NULL);
        test.StopTest();             
        salesup_Submit_for_ApprovalClass.getCaseValue(caseObj.id); // calling class method by providing case Id parametr
       	
    }
}