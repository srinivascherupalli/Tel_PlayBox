@isTest
private class APTPS_AmendmentViewControllerTest {
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_AmendmentViewController class
    *******************************************************************/
    static testMethod void testMethod1()    {
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test2');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1111118898');
        
        //Create Agreement
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        
        //create related agreement
        Apttus__APTS_Related_Agreement__c relatedagmt1 = new Apttus__APTS_Related_Agreement__c();
        relatedagmt1.Name = 'Test';
        relatedagmt1.Apttus__APTS_Contract_From__c = agmt1.ID;
        relatedagmt1.Apttus__APTS_Contract_To__c = agmt1.ID;
        insert relatedagmt1;
        
        PageReference pageRef = Page.APTPS_Init_AmendmentView;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        Test.startTest();
        
        APTPS_AmendmentViewController sfsc = new APTPS_AmendmentViewController(new ApexPages.StandardController(agmt1));
        sfsc.ListOfAggrement = agmtList;
        sfsc.CurrentAgreement = agmt1;
        sfsc.View = '';
        sfsc.View1();
        sfsc.View2();
        sfsc.GoBack();
        sfsc.ListOfParentAggrements = agmtList;
        sfsc.getAgreements();
        
        Test.stopTest();
    }
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_AmendmentViewController class
    *******************************************************************/
    static testMethod void testMethod2()    {
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test3');
        Account acct = new Account(Name = 'accName',Type = 'Customer', ABN__c = '1234', CIDN__c = '1237778898');
        
        insert acct;
       
        //Create Agreement
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c agmt2 = APTPS_TestClassData.agreementRecord(acct.id);
        
        //create related agreement
        Apttus__APTS_Related_Agreement__c relatedagmt1 = new Apttus__APTS_Related_Agreement__c();
        relatedagmt1.Name = 'Test';
        relatedagmt1.Apttus__APTS_Contract_From__c = agmt2.ID;
        relatedagmt1.Apttus__APTS_Contract_To__c = agmt1.ID;
        insert relatedagmt1;
        
        PageReference pageRef = Page.APTPS_Init_AmendmentView;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        Test.startTest();
        
        APTPS_AmendmentViewController sfsc = new APTPS_AmendmentViewController(new ApexPages.StandardController(agmt1));
        sfsc.ListOfAggrement = agmtList;
        sfsc.CurrentAgreement = agmt1;
        sfsc.View = '';
        sfsc.View1();
        sfsc.View2();
        sfsc.GoBack();
        sfsc.ListOfParentAggrements = agmtList;
        sfsc.getAgreements();
        
        Test.stopTest();
    }
}