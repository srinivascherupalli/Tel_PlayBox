/*
ClassName : SigmaDataInterfaceUtilityTest
Description:Test Class for SigmaDataInterfaceUtility
*/

@isTest
private class SigmaDataInterfaceUtilityTest 
{
    static testMethod void testSigmaDataInterfaceUtility()
	{
        Test.startTest();
		Boolean flag = SigmaDataInterfaceUtility.isPriceChangeOnly();
        system.assertEquals(flag,false);
        Test.stopTest();        
    } 
}