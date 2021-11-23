/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-106634
******************************************************************/ 
@isTest
private class GetSubscriptionsForAccountUtilTest {
    @isTest 
    static void getSubscriptionsTest() {
       Account acc = TestDataFactory.generateAccount();
       Test.startTest(); 
	   GetSubscriptionsResponse  retval  = GetSubscriptionsForAccountUtil.getSubscriptions(acc.id);
	   GetSubscriptionsForAccountUtil.genErrorResponse('AUTHERR_001');
	   GetSubscriptionsForAccountUtil.genErrorResponse('AUTHERR_001','Request Header parameter emailId not present');
	   Map<String,Object> jsonObj = new Map<String,Object>();
	   Map<String,Object> jsonObjMap1 = new Map<String,Object>();
	   List<Object> jsonObjList = new List<Object>{jsonObjMap1};
	   jsonObj.put('attributes', acc);
	   jsonObj.put('Object', acc);
	   //jsonObj.put('jsonObj', jsonObj);
	   jsonObj.put('jsonObjList', jsonObjList);
	   System.assertEquals(0,retval.subscriptions.size());
	   GetSubscriptionsForAccountUtil.removeAttributes(jsonObj);
	   Test.stopTest();
    }
}