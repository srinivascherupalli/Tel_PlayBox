/********************************************************
Class Name      :   CreateMSISDNSchedulableTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta Patil     	05/12/19      	EDGE-118965
**********************************************************
*/

@isTest
public class CreateMSISDNSchedulableTest {
     @isTest
    static void MSISDNSchedulableTest(){
        Test.startTest();
        ReactivateMSISDNService MSISDNJob;
        CreateMSISDNSchedulable ms = new CreateMSISDNSchedulable(MSISDNJob);
        Test.stopTest();
        System.assertNotEquals(ms,null);
    }
	
}