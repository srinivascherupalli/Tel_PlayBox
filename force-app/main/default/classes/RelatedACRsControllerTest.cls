/*****************************************************************************
@Name: RelatedACRsControllerTest
@Author: Sri Chittoori(Team SFO)
@CreateDate: 29/05/2019
@Description: Sprint 19.07 , EDGE-85148 :: This is a TEST class for RelatedACRsController
*******************************************************************************/
@isTest
public class RelatedACRsControllerTest {
    @isTest
    static void viewACRsTest(){
        Test.StartTest();
        Account testAcc = new Account(Name='testAcc',Customer_Status__c='ACTIVE');
        Insert testAcc;
        Contact con = new Contact(LastName='testCon',AccountId=testAcc.Id);
        insert con;
        System.assertEquals(con.LastName, 'testCon'); 
        RelatedACRsController.viewACRs(con.id);
        Test.StopTest();
    }
    @isTest
    static void viewACRsExceptionTest(){
        Test.StartTest();
 
        Contact con = new Contact(LastName='testCon');
        insert con;
		System.assertEquals(con.LastName, 'testCon'); 
        delete con;
        RelatedACRsController.viewACRs(con.id);

        Test.StopTest();  
    }
}