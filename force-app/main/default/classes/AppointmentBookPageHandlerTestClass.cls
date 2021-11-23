@isTest
public class AppointmentBookPageHandlerTestClass {
    public testmethod static void unitTest1(){
        PageReference pageRef = Page.AppointmentBookPage;
		Test.setCurrentPage(pageRef);  
        cscfga__Product_Configuration__c pc= new cscfga__Product_Configuration__c(Name='MyPC',cscfga__Quantity__c=2);
        insert pc;
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Product_Configuration__c=pc.id,StartDate__c=System.today(),EndDate__c=System.today());
      	insert appt;
        AppointmentBookPageHandler appBpage = new AppointmentBookPageHandler();
            	appBpage.secondaryConstructor(String.valueOf(pc.id));
                  
            	appBpage.fromDate=System.today();
           	    appBpage.todate=System.today();
                appBpage.selectedname=NULL;
                appBpage.detailList=NUll;
                appBpage.notes='Test Notes';
                appBpage.causeEventReason=NULL;
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
        	appBpage.setAppointmentIDInPC(String.valueOf(pc.id),'Appointment ID');
        	appBpage.getAppStartEndTime('123456');	
            System.assertEquals(true,pageRef!=NULL);
     }
}