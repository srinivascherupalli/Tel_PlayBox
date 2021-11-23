@isTest(seeAllData=false)
public class DataHandlerConstantsTest {
    static testMethod void testConstants(){
        
        Test.startTest();
        DataHandlerConstants constant=new DataHandlerConstants();
        String AdpSpec=DataHandlerConstants.ADAPTIVE_MOBILITY_SPECID ;
 
       system.assertEquals(DataHandlerConstants.ADAPTIVE_MOBILITY_SPECID ,'DMCAT_Offer_001231');
        Test.stopTest();
    }

}