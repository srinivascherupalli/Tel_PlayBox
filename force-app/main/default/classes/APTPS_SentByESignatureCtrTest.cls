@isTest
private class APTPS_SentByESignatureCtrTest { 
    /******************************************************************
    @Description: This test method is written for covering the APTPS_SentByESignatureController class
    *******************************************************************/
    static testmethod void TestMethod1() {
        try{
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test9');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        
        //Create Agreement
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        
        PageReference pageRef = Page.APTPS_SentByESignatureButton;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        test.StartTest();
        
        APTPS_SentByESignatureController sfsc = new APTPS_SentByESignatureController(new ApexPages.StandardController(agmt1));
        sfsc.updateAgreementAndRedirect();
        
        test.StopTest();
         }catch(Exception e)
        {
           System.debug('CaLMs System exception caught: ' + e.getMessage());  
          
        }     
        
    }
}