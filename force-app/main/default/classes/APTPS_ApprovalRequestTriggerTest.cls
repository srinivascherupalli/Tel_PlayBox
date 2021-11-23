@isTest
private class APTPS_ApprovalRequestTriggerTest {
    
    /******************************************************************
    @Description:This testMethod covers APTPS_ApprovalRequestTrigger and APTPS_ApprovalRequestTriggerHandler classes.
    *******************************************************************/  
    static testMethod void testMethod1()    {
        
        // Get Legal Queue ID
        Group LegalQueue = [select Id from Group where Name = 'Legal Queue' and Type = 'Queue' Limit 1];
        
        //Create Profile
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        //Create System Administrator User
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id, 'test4');
        
        //Create Account
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1230771898');
        
        //Create Agreement
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct.id);
        
        //Create Approval Request
        Apttus_Approval__Approval_Request__c approvalRqst1 = new Apttus_Approval__Approval_Request__c();
        approvalRqst1.Apttus_Approval__Related_Agreement__c = agmt1.Id;
        approvalRqst1.Apttus_Approval__Actual_Approver__c = UserSA.ID;
        approvalRqst1.Apttus_Approval__Approval_Status__c = 'Submitted';
        insert approvalRqst1;
        
        Apttus_Approval__Approval_Request__c approvalRqst2 = new Apttus_Approval__Approval_Request__c();
        approvalRqst2.Apttus_Approval__Related_Agreement__c = agmt1.Id;
        approvalRqst2.Apttus_Approval__Approval_Status__c = 'Approved';
        insert approvalRqst2;
        
        // update data for Approval Request
        approvalRqst1.Apttus_Approval__Approval_Status__c = 'Approved';
        approvalRqst1.Apttus_Approval__Assigned_To_Type__c = 'Queue';
        approvalRqst1.Apttus_Approval__Assigned_To_Name__c = 'Legal Queue';
        approvalRqst1.Apttus_Approval__Assigned_To_Id__c = String.valueof(LegalQueue.ID);
        
        approvalRqst2.Apttus_Approval__Approval_Status__c = 'Submitted';
        
        Test.startTest();
        
        update approvalRqst1;
        update approvalRqst2;
        
        Test.stopTest();
        System.assertNotEquals(null, agmt1.APTPS_Is_Custom_Update__c);
    }
}