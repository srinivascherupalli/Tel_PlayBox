/************************************************************************************
* Name             : GuidUtilTest
* Description      : Test class for GuidUtil
* Created Date     : 18/Feb/2020
* Created By       : Soujanya Vuyyuru
*************************************************************************************
* Date         Change-Request          Modified By                    Description
*************************************************************************************
**************************************************************************************/

@isTest
public class GuidUtilTest {
 @isTest
static void test()
 {
    Test.startTest();
    String newId = GuidUtil.NewGuid();
    System.assert(newId.length() > 0);
    Test.stopTest(); 
 }
}