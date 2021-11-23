@isTest
public class SubscriptionControllerTest{
    public static testMethod void insertData(){
        
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.csord__Identification__c='abcdeee';
        sub.csord__Status__c = 'Active';
        sub.serviceMSISDN__c='0123456789';
        insert sub;      
        
        //INC000095698976 - Modified test class as part of production incident 
		List<csord__Subscription__c> subVal = [SELECT Id,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c Where Id =: sub.Id ];	
        
        Number__c num = new Number__c();
        num.Name='dsffdfdg';         
        num.Subscription_number__c= !subVal.isEmpty()? subVal[0].csordtelcoa__Subscription_Number__c: '';
        num.Service_Number__c='0123456789';
        insert num;
        system.debug('@V@'+subVal[0].csordtelcoa__Subscription_Number__c); 
        system.debug('@V@ Sub' +num.Subscription_number__c);
		system.debug('@V@ subVal' +[SELECT Id,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c Where csordtelcoa__Subscription_Number__c =: num.Subscription_number__c ]);
        Test.startTest();
        csord__Subscription__c subs = SubscriptionController.getSubscriptionValue(num.id);
        Test.stopTest();
        System.assertEquals(num.Service_Number__c, subs.serviceMSISDN__c);
        
    }
}