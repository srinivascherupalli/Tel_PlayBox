@isTest
private class OrchestrationProcessTriggerHelperTest {

@isTest static void TestComplete() {
        CSPOFA__Orchestration_Process_Template__c opt = TestUtil.createOPTemplate('Test OPT');
        insert opt;

        CSPOFA__Orchestration_Process__c opParent = TestUtil.createParentOP('Parent', opt.Id);
        insert opParent;

        CSPOFA__Orchestration_Process__c opC1 = TestUtil.createChildOP('Child 1', opParent.Id, opt.Id);
        insert opC1;

        CSPOFA__Orchestration_Process__c opC2 = TestUtil.createChildOP('Child 2', opParent.Id, opt.Id);
        insert opC2;

        Test.startTest();
            opC1.CSPOFA__Status__c = 'Complete';
            update opC1;

            opC2.CSPOFA__Status__c = 'Complete';
            update opC2;
        Test.stopTest();

        CSPOFA__Orchestration_Process__c opParentUpdate = [SELECT Overall_Cancellation_Status__c 
                                                           FROM CSPOFA__Orchestration_Process__c
                                                           WHERE Id = : opParent.Id];

        System.assertEquals('Complete', opParentUpdate.Overall_Cancellation_Status__c, 'Parent status does not equal Complete');
    }   
    
    @isTest static void TestPending() {
        CSPOFA__Orchestration_Process_Template__c opt = TestUtil.createOPTemplate('Test OPT');
        insert opt;

        CSPOFA__Orchestration_Process__c opParent = TestUtil.createParentOP('Parent', opt.Id);
        insert opParent;

        CSPOFA__Orchestration_Process__c opC1 = TestUtil.createChildOP('Child 1', opParent.Id, opt.Id);
        insert opC1;

        CSPOFA__Orchestration_Process__c opC2 = TestUtil.createChildOP('Child 2', opParent.Id, opt.Id);
        insert opC2;
		
        //covering delete methods
        delete opC2;
        Test.startTest();
            opC1.CSPOFA__Status__c = 'Initializing';
            update opC1;

        Test.stopTest();

        CSPOFA__Orchestration_Process__c opParentUpdate = [SELECT Overall_Cancellation_Status__c 
                                                           FROM CSPOFA__Orchestration_Process__c
                                                           WHERE Id = : opParent.Id];

        System.assertEquals('Pending', opParentUpdate.Overall_Cancellation_Status__c, 'Parent status does not equal Pending');
    }
    
}