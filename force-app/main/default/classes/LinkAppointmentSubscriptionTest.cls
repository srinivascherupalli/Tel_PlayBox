@isTest
private class LinkAppointmentSubscriptionTest {

    @Testsetup
	static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
       	csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
		insert ordReq;
        
    	cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        insert productConfig;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subs1';
        subs1.csord__Identification__c = 'test identity';
        subs1.csord__Order__c = ord.Id;
        subs1.Sub_status__c = 'Active';
        subs1.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs1;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs;
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
		csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csordtelcoa__Product_Configuration__c = productConfig.id;
        servs.add(serv);
        insert servs;
        
  
        
        Appointment__c app = new Appointment__c();
		app.name = 'app1';
		app.Product_Configuration__c = productConfig.id;
        insert app;
        
    }
    
    @isTest
    public static void assignSubscriptionToAppointmentTest() {
    	csord__Service__c serv = [SELECT id from csord__Service__c where name = 'tst service'];
        
    	Test.startTest();
		LinkAppointmentSubscription.assignSubscriptionToAppointment(new List<ID> {serv.id});
		Test.stopTest();
		
		csord__Subscription__c subs = [select id FROM csord__Subscription__c where name = 'test subs'];
		
		Appointment__c app = [SELECT id,Subscription__c from Appointment__c where name= 'app1'];
		System.assertEquals(subs.id, app.Subscription__c);
    	
    }
}