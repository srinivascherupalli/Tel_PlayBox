@isTest(SeeAllData=false)
public without sharing class APTPS_ObligationWrapperTest {
    
    static testMethod void testMethod1()    {
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '3217778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt.Apttus__Status_Category__c = 'Request';
        agmt.Apttus__Status__c = 'Request';
        agmt.Apttus__Agreement_Category__c = 'Global';
        update agmt;
      
      	User usr = [select Id, Name from User where id=: UserInfo.getUserId() limit 1];
        
        Apttus_SRM__SRMObligation__c srmIssue = new Apttus_SRM__SRMObligation__c();
        srmIssue.APTPS_Status__c = 'Pending';
        srmIssue.APTPS_Customer__c = acct.Id;
        srmIssue.APTPS_Auto_Obligation__c = true;
        srmIssue.Apttus_SRM__Description__c = '';
        srmIssue.APTPS_Due_Date__c = Date.newInstance(2018, 12, 9);
        srmIssue.Apttus_SRM__Comments__c = '';
        srmIssue.Apttus_SRM__Responsible__c = 'Customer';
        srmIssue.Apttus_SRM__Accountable__c = 'test';
        srmIssue.Apttus_SRM__Consulted__c = 'In Progress';
        srmIssue.Apttus_SRM__Informed__c = '';
        srmIssue.Apttus_SRM__AgreementId__c=agmt.id;
        srmIssue.CreatedById=usr.id;
        srmIssue.APTPS_Category__c = 'Audit';
        srmIssue.APTPS_Sub_Category__c='Inspection and Audit of Records';
        srmIssue.APTPS_Responsible__c='Customer';
        srmIssue.APTPS_Due_Date__c = date.today();
        srmIssue.APTPS_Clause_Name__c='test';
        srmIssue.APTPS_Obligation_Frequency__c = 'Once-off';
		srmIssue.APTPS_Approval_Required__c='No Approval Required';
        srmIssue.Apttus_SRM__Active__c = true;

        insert srmIssue;
        
       Test.startTest();
        
        APTPS_ObligationWrapper isw = new APTPS_ObligationWrapper(srmIssue);
         System.assertEquals(isw.Agreement_Clause, srmIssue.APTPS_Clause_Name__c);
        System.assertEquals(isw.Category, srmIssue.APTPS_Category__c);
        System.assertEquals(isw.Sub_Category, srmIssue.APTPS_Sub_Category__c);
        System.assertEquals(isw.Obligation_Frequency, srmIssue.APTPS_Obligation_Frequency__c);
     
        Test.stopTest();
    }

}