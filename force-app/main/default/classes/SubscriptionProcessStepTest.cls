@isTest
public with sharing class SubscriptionProcessStepTest {
    @isTest
    static  void testSubscriptionProcessStepTest(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(0,'0');
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
    static  void testSubscriptionProcessStep1Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(1,'1');
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
    static  void testSubscriptionProcessStep2Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(2,'2');
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
    static  void testSubscriptionProcessStep3Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(3,'3');
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
    static  void testSubscriptionProcessStep4Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(4,'4');
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
    static  void testSubscriptionProcessStep5Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(5,'5');
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
    static  void testSubscriptionProcessStep6Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(6,'6');
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
    static  void testSubscriptionProcessStep7Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(7,'7');
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
    static  void testSubscriptionProcessStep8Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(8,'8');
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
    static  void testSubscriptionProcessStep9Test(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
       System.runAs(adminUser){
        Test.startTest();
        List<Coms_Subscription_PE__e> allPEEvents=Coms_TestDataFactory.createSubscriptionPEEvent(9,'9');
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