@isTest(SeeAllData=false)
private class APTPS_IssuesWrapperTest {
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_IssuesWrapper class
    *******************************************************************/
    static testMethod void testMethod1()    {
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '3217778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt.Apttus__Status_Category__c = 'Request';
        agmt.Apttus__Status__c = 'Request';
        agmt.Apttus__Agreement_Category__c = 'Global';
        update agmt;
        
        Apttus_SRM__Issue__c srmIssue = new Apttus_SRM__Issue__c();
        srmIssue.Apttus_SRM__Status__c = '';
        srmIssue.APTPS_Area_of_Risk_Impact__c = '';
        srmIssue.APTPS_Risk_Summary__c = '';
        srmIssue.APTPS_Impact__c = '';
        srmIssue.APTPS_Implications__c = '';
        srmIssue.APTPS_Party_Raising_Risk__c = '';
        srmIssue.APTPS_Inherent_Risk_Rating__c = '';
        srmIssue.APTPS_Impact_of_Risk__c = '';
        srmIssue.APTPS_Likelihood_of_Eventuation__c = '';
        srmIssue.APTPS_Action_Status__c = 'In Progress';

        insert srmIssue;
   
        Test.startTest();
        
        APTPS_IssuesWrapper isw = new APTPS_IssuesWrapper(srmIssue);
   
        System.assertEquals(isw.Status, srmIssue.Apttus_SRM__Status__c);
        System.assertEquals(isw.AreaofRiskImpact, srmIssue.APTPS_Area_of_Risk_Impact__c);
        System.assertEquals(isw.RiskSummary, srmIssue.APTPS_Risk_Summary__c);
        System.assertEquals(isw.Impact, srmIssue.APTPS_Impact__c);
      
        Test.stopTest();
    }
}