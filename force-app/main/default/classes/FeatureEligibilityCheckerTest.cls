@isTest

private class FeatureEligibilityCheckerTest {

    @isTest
    static void determineFeatureEligiblityForHash75FlowTest() {
        User us = SYS_TestDataFactory.createUser('Analytics Cloud Integration User');
        System.runAs(us) {
            boolean result = FeatureEligibilityChecker.determineFeatureEligiblity('NumberManagement','Hash75');
            System.assertNotEquals(null, result);
        }
    }
    
    @isTest
    static void determineFeatureEligiblityForNulltest() {
        User us = SYS_TestDataFactory.createUser('Analytics Cloud Integration User');
        System.runAs(us) {
            boolean result = FeatureEligibilityChecker.determineFeatureEligiblity(null, null);
            System.assertNotEquals(null, result);
        }
    }
    @isTest
    static void determineFeatureEligiblityForNullFlowtest() {
        User us = SYS_TestDataFactory.createUser('Analytics Cloud Integration User');
        System.runAs(us) {
            boolean result = FeatureEligibilityChecker.determineFeatureEligiblity('NumberManagement', null);
            System.assertNotEquals(null, result);
        }
    }
    
    @isTest
    static void determineFeatureEligiblityForNullDeveloperNametest() {
        User us = SYS_TestDataFactory.createUser('Analytics Cloud Integration User');
        System.runAs(us) {
            boolean result = FeatureEligibilityChecker.determineFeatureEligiblity(null, 'Hash75');
            System.assertNotEquals(null, result);
        }
    }
    
    @isTest
    static void determineFeatureEligiblityForWrongFlowtest() {
        User us = SYS_TestDataFactory.createUser('Analytics Cloud Integration User');
        System.runAs(us) {
            boolean result = FeatureEligibilityChecker.determineFeatureEligiblity('NumberManagement', 'abc');
            System.assertNotEquals(null, result);
        }
    }
    
    @isTest
    static void checkUserType_NoPermissionAssignedTest () {
        User u = SYS_TestDataFactory.createUser('Analytics Cloud Integration User');
        insert u;
        string result = FeatureEligibilityChecker.checkUserType(u.Id);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void checkUserType_PS_BVT_TesterTest() {
        User u = SYS_TestDataFactory.createUser('Analytics Cloud Integration User');
        insert u;
        List<PermissionSet> psList = [Select Id from PermissionSet where Name = 'PS_BVT_Tester'];
        PermissionSet ps = new PermissionSet();
        if(psList.isEmpty()){
            ps = new PermissionSet(Label = 'PS_BVT_Tester', Name = 'PS_BVT_Tester');
            insert ps;
        } else {
            ps = psList[0];
        }
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = ps.Id;
        psa.AssigneeId = u.Id;
        insert psa;
        string result = FeatureEligibilityChecker.checkUserType(u.Id);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void checkUserType_PS_EnablePilotFeatureTest () {
        User u = SYS_TestDataFactory.createUser('Analytics Cloud Integration User');
        insert u;
        List<PermissionSet> psList = [Select Id from PermissionSet where Name = 'PS_EnablePilotFeature'];
        PermissionSet ps = new PermissionSet();
        if(psList.isEmpty()){
            ps = new PermissionSet(Label = 'PS_EnablePilotFeature', Name = 'PS_EnablePilotFeature');
            insert ps;
        } else {
            ps = psList[0];
        }
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = ps.Id;
        psa.AssigneeId = u.Id;
        insert psa;
        string result = FeatureEligibilityChecker.checkUserType(u.Id);
        System.assertNotEquals(null, result);
    }
}