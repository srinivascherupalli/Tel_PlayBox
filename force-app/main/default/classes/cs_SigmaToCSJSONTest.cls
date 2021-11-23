/*Story number: EDGE-206
Description: Test class for cs_SigmaToCSJSON 	
*/

@isTest
private class cs_SigmaToCSJSONTest {
    static blob b = [select body from staticResource where name = 'SigmaCS_JSON'].body;
    static String sigmaJSON = b.toString();
    static testMethod void testParse() {
        Test.startTest();
        cs_SigmaToCSJSON sigmaCSObj = cs_SigmaToCSJSON.parse(sigmaJSON);  
        system.assertEquals('Connected Workplace', sigmaCSObj.productOffering.name);
        Test.stopTest();
    }
    
}