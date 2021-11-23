/*
** @Author   :   Maqsood Alam
** @Date     :   June 2020
** @Desc     :   Class to Capture all the environment Vairable - Test Clas
**
*/
@isTest
public class AllCQEnvironmentVariableTest {
    private void setup() {
        Environment_Configurations__c environmentConfig = New Environment_Configurations__c();
        environmentConfig.No_Triggers__c = true;
        insert environmentConfig;

    }
    
    @isTest static void getValueAsListTest() {
        Test.startTest();
        AllCQEnvironmentVariable QnC = New AllCQEnvironmentVariable();
        //Cover -ve condition 
        AllCQEnvironmentVariable.getValueAsList('');
        list < String > getList = AllCQEnvironmentVariable.getValueAsList('productFamiliesQC');
        Test.stopTest();
        System.assert(getList != null);
        System.assert(getList.size() > 0);
    }
    
    @isTest static void getValueAsSetTest() {
        Test.startTest();
        AllCQEnvironmentVariable QnC = New AllCQEnvironmentVariable();
        AllCQEnvironmentVariable.getValueAsSet('');
        set < String > getSet = AllCQEnvironmentVariable.getValueAsSet('productFamiliesQC');
        Test.stopTest();
        System.assert(getSet != null);
        System.assert(getSet.size() > 0);
    }
}