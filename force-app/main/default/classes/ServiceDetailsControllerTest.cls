@isTest
public class ServiceDetailsControllerTest {
    @isTest
    static void initFlow_WillGiveValidPageRef_WhenDataIsValid() {
        Test.startTest();
        //TriggerTestHelper.disableTrigger('SubscriptionTrigger');
        Account acc = AccountTestFactory.buildAccount('TestbuildAcc');
        insert acc;
        csord__service__c ser = ProductTestService.getNewServiceForAccount(acc);
        Test.stopTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ser);
        ServiceDetailsController controller = new ServiceDetailsController(sc);
        PageReference ref = controller.initFlow();
        System.assert(ref.getUrl().contains('customConfiguration'));
        System.assert(ref.getUrl().contains(ser.id));
    }
}