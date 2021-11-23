@isTest
private class APTPS_ComponentsTriggerTest {
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_ComponentsTrigger class
    *******************************************************************/
    Static testMethod void TestMethod1() {
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test5');
        Account acct ;
        //Create Account
        try{
         acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        }catch(Exception e)
        {
           System.debug('CaLMs System exception caught: ' + e.getMessage());  
          
        }  
        
        Product2 prod1 = new Product2();
        prod1.Name = 'test';
        prod1.Description = 'test';
        prod1.Family = 'test';
        insert prod1;
        
        //Create Agreement
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus__AgreementLineItem__c agreementLI = APTPS_TestClassData.agreementLineItemRecord(agmt1.ID, prod1.ID);
        
        APTPS_Component__c componet1 = new APTPS_Component__c();
        componet1.Agreement_Line_Item__c = agreementLI.ID;
        insert componet1;
        
        componet1.Value__c = 'test';
        update componet1;
        System.assertNotEquals(null, componet1.Agreement_Line_Item__c);
        delete componet1;
    }
    
}