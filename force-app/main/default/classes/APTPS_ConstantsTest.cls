@isTest(seeAllData=false)
public class APTPS_ConstantsTest {
    static testMethod void testConstants(){
        APTPS_Constants constant=new APTPS_Constants();
        Test.startTest();
        system.assertEquals(APTPS_Constants.ACTIVATED_STATUS,'Activated');
        Test.stopTest();
    }
 
}