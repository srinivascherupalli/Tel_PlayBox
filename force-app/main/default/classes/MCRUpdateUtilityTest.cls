/******************************************************************************************************
    *Class Name     : MCRUpdateUtilityTest
    *Decription     : This class is to update the source Account Name
        
   Sr.No.      Developer Name          Date            Story           Description
    1.            Gokul        22/2/21            EDGE-219537    This class is to update the source Account Name
    ********************************************************************************************************/

    @isTest
    public with sharing class MCRUpdateUtilityTest {
        
        @TestSetup
        static void createTestData(){
            
            Account acc = TestDataFactory.generateAccount();
            
            Migration_Change_Request__c mcr = new Migration_Change_Request__c();
            mcr.account_id__c = acc.id;
            insert mcr;
        }
        @isTest
        static void updateSourceAccountTest(){
    
            list<Migration_Change_Request__c> mcrList = new list<Migration_Change_Request__c>();
            mcrList = [select id,Source_Account_Name__c,account_id__c from Migration_Change_Request__c limit 1];
            Test.startTest();
                MCRUpdateUtility.updateSourceAccount(mcrList);
                system.assertequals(true,mcrList[0].Source_Account_Name__c!= null);
            Test.stopTest();
            
        }
    }