/*************************************************************************************************
Name 		: InlineLookUpController
Description : This test is covered InlineLookUpController
Author		: Abinash Barik
Story		: 
Revision	: 
***************************************************************************************************/
@isTest
public class InlineLookUpControllerTest {
    @isTest
    public static void findRecordsTest(){
        Account acc = new Account(Name = 'testAccountDiscount');
          acc.Customer_Status__c='Active';
        
        insert acc;
		Test.startTest();

        String filter = ' AND Customer_Status__c = \'Active\'';
        	List<sobject> lstdata = InlineLookUpController.findRecords('test','Account',filter);
        	sObject rec = InlineLookUpController.findRecordOnLoad('Account',acc.id);
        	System.assertEquals(lstdata.size() == 1,true);
        	System.assertEquals(rec != null,true);
        Test.stopTest();
    }

}