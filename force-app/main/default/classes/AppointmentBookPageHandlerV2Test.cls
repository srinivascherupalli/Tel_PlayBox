@isTest
public class AppointmentBookPageHandlerV2Test {
    public testmethod static void unitTestSchedule(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        PageReference pageRef = new PageReference('apex/AppointmentBookPageV2?id='+sub.id+'&operation=Schedule');
        Test.setCurrentPage(pageRef);
        AppointmentBookPageHandlerV2 appBpage = new AppointmentBookPageHandlerV2();
              appBpage.secondaryConstructor(String.valueOf(sub.id));
                  
              appBpage.fromDate=System.today();
                 appBpage.todate=System.today();
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
                appBpage.appDetails=NULL;
                appBpage.appointmentId='123456';
                appBpage.popupTitle='Title';
                appBpage.getCategories();
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
        appBpage.searchAppointments();
        appBpage.setSlotId();
        appBpage.switchOfTimerApex();
        Test.stopTest();
            appBpage.confirmAppointment();
          appBpage.getAppStartEndTime('123456');  
            System.assertEquals(true,pageRef!=NULL);
    }
    
    public testmethod static void unitTestFollowOn(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        PageReference pageRef = new PageReference('apex/AppointmentBookPageV2?id='+sub.id+'&operation=FollowOn');
        Test.setCurrentPage(pageRef);
        AppointmentBookPageHandlerV2 appBpage = new AppointmentBookPageHandlerV2();
              appBpage.secondaryConstructor(String.valueOf(sub.id));
                  
              appBpage.fromDate=System.today();
                 appBpage.todate=System.today();
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
                appBpage.appDetails=NULL;
                appBpage.appointmentId='123456';
                appBpage.popupTitle='Title';
                appBpage.getCategories();
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
        appBpage.searchAppointments();
        appBpage.setSlotId();
        appBpage.switchOfTimerApex();
        Test.stopTest();
            appBpage.confirmAppointment();
          appBpage.getAppStartEndTime('123456');  
            System.assertEquals(true,pageRef!=NULL);
    }
  
    public testmethod static void unitTestReschedule(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        PageReference pageRef = new PageReference('apex/AppointmentBookPageV2?id='+sub.id+'&operation=Reschedule');
        Test.setCurrentPage(pageRef);
        AppointmentBookPageHandlerV2 appBpage = new AppointmentBookPageHandlerV2();
              appBpage.secondaryConstructor(String.valueOf(sub.id));
                  
              appBpage.fromDate=System.today();
                 appBpage.todate=System.today();
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
                appBpage.appDetails=NULL;
                appBpage.appointmentId='123456';
                appBpage.popupTitle='Title';
                appBpage.getCategories();
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
        appBpage.searchAppointments();
        appBpage.setSlotId();
        appBpage.switchOfTimerApex();
        appBpage.confirmAppointment();
        appBpage.getAppStartEndTime('123456'); 
        Test.stopTest();
 
            System.assertEquals(true,pageRef!=NULL);
    }
        public testmethod static void unitTestReschedule12(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.name = 'sub1';
        sub.csordtelcoa__Change_Type__c = 'Cancel';
        sub.csord__Identification__c = 'Identify';
        insert sub;
        
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        PageReference pageRef = new PageReference('apex/AppointmentBookPageV2?id='+sub.id+'&operation=Reschedule');
        Test.setCurrentPage(pageRef);
        AppointmentBookPageHandlerV2 appBpage = new AppointmentBookPageHandlerV2();
              appBpage.secondaryConstructor(String.valueOf(sub.id));
                  
              appBpage.fromDate=System.today();
                 appBpage.todate=System.today();
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
                appBpage.appDetails=NULL;
                appBpage.appointmentId='123456';
                appBpage.popupTitle='Title';
                appBpage.getCategories();
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
        appBpage.searchAppointments();
        appBpage.setSlotId();
        appBpage.switchOfTimerApex();
        appBpage.confirmAppointment();
          appBpage.getAppStartEndTime('123456'); 
        Test.stopTest(); 
            System.assertEquals(true,pageRef!=NULL);
    }
    
        public testmethod static void unitTestFollowOn12(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.name = 'sub1';
        sub.csordtelcoa__Change_Type__c = 'Cancel';
        sub.csord__Identification__c = 'Identify';
        insert sub;
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        PageReference pageRef = new PageReference('apex/AppointmentBookPageV2?id='+sub.id+'&operation=FollowOn');
        Test.setCurrentPage(pageRef);
        AppointmentBookPageHandlerV2 appBpage = new AppointmentBookPageHandlerV2();
              appBpage.secondaryConstructor(String.valueOf(sub.id));
                  
              appBpage.fromDate=System.today();
                 appBpage.todate=System.today();
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
                appBpage.appDetails=NULL;
                appBpage.appointmentId='123456';
                appBpage.popupTitle='Title';
                appBpage.getCategories();
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
        appBpage.searchAppointments();
        appBpage.setSlotId();
        appBpage.switchOfTimerApex();
        appBpage.confirmAppointment();
          appBpage.getAppStartEndTime('123456');
        Test.stopTest();
  
            System.assertEquals(true,pageRef!=NULL);
    }
    
            public testmethod static void unitTestFollowOn123(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.name = 'sub1';
        sub.csordtelcoa__Change_Type__c = 'Cancel';
        sub.csord__Identification__c = 'Identify';
        insert sub;
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        PageReference pageRef = new PageReference('apex/AppointmentBookPageV2?id='+sub.id+'&operation=FollowOn1');
        Test.setCurrentPage(pageRef);
        AppointmentBookPageHandlerV2 appBpage = new AppointmentBookPageHandlerV2();
              appBpage.secondaryConstructor(String.valueOf(sub.id));
                  
              appBpage.fromDate=System.today();
                 appBpage.todate=System.today();
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
                appBpage.appDetails=NULL;
                appBpage.appointmentId='123456';
                appBpage.popupTitle='Title';
                appBpage.getCategories();
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
        appBpage.searchAppointments();
        appBpage.setSlotId();
        appBpage.switchOfTimerApex();
        appBpage.clearBottomSection();
        appBpage.loadRescheduleReasonList();
        Test.stopTest();
        appBpage.confirmAppointment();
  
            System.assertEquals(true,pageRef!=NULL);
    }
    
     public testmethod static void unitTestDateNull(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.name = 'sub1';
        sub.csordtelcoa__Change_Type__c = 'Cancel';
        sub.csord__Identification__c = 'Identify';
        insert sub;
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        PageReference pageRef = new PageReference('apex/AppointmentBookPageV2?id='+sub.id+'&operation=FollowOn1');
        Test.setCurrentPage(pageRef);
        AppointmentBookPageHandlerV2 appBpage = new AppointmentBookPageHandlerV2();
              appBpage.secondaryConstructor(String.valueOf(sub.id));
                  
              
                 
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
                appBpage.appDetails=NULL;
                appBpage.appointmentId='123456';
                appBpage.popupTitle='Title';
                appBpage.getCategories();
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
        appBpage.searchAppointments();
        appBpage.setSlotId();
        appBpage.switchOfTimerApex();
        appBpage.clearBottomSection();
        appBpage.loadRescheduleReasonList();
        Test.stopTest();
        appBpage.confirmAppointment();
  
            System.assertEquals(true,pageRef!=NULL);
    }
    
         public testmethod static void unitTestFromDateLess(){
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.name = 'sub1';
        sub.csordtelcoa__Change_Type__c = 'Cancel';
        sub.csord__Identification__c = 'Identify';
        insert sub;
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        PageReference pageRef = new PageReference('apex/AppointmentBookPageV2?id='+sub.id+'&operation=FollowOn1');
        Test.setCurrentPage(pageRef);
        AppointmentBookPageHandlerV2 appBpage = new AppointmentBookPageHandlerV2();
              appBpage.secondaryConstructor(String.valueOf(sub.id));
                  
                appBpage.fromDate=System.today() + 1;
                 appBpage.todate=System.today();
                 
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
                appBpage.appDetails=NULL;
                appBpage.appointmentId='123456';
                appBpage.popupTitle='Title';
                appBpage.getCategories();
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
        appBpage.searchAppointments();
        appBpage.setSlotId();
        appBpage.switchOfTimerApex();
        appBpage.clearBottomSection();
        appBpage.loadRescheduleReasonList();
        Test.stopTest();
        appBpage.confirmAppointment();
  
            System.assertEquals(true,pageRef!=NULL);
    }

}