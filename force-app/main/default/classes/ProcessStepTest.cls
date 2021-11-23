@isTest
public with sharing class ProcessStepTest {
    @isTest
    static  void testProcessStepTest(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(0,'0');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep1Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(1,'1');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep2Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(2,'2');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep3Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(3,'3');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep4Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(4,'4');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep5Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(5,'5');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep6Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(6,'6');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep7Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(7,'7');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep8Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(8,'8');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
    @isTest
    static  void testProcessStep9Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Step_PE__e> allPEEvents=Coms_TestDataFactory.createStepPEEvent(9,'9');
       // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(allPEEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        Test.stopTest();
        System.assertEquals(10, 10);
       }
    }
}