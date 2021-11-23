@isTest
public class AppointmentSitePageHandlerTestClass {

     public testmethod static void unitTest1(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        cscrm__Address__c address = new cscrm__Address__c();
         address.name = 'LonsdaleUnconfiremed VIC 3002(1013101610)';
         address.Address_ID__c = '1013101610';
         address.cscrm__Account__c = acc.id; 
         upsert address;
         
         cscrm__Site__c site = new cscrm__Site__c();
         site.cscrm__Account__c = acc.id;
         site.cscrm__Installation_Address__c = address.id;
         site.name = 'Sydney harbour house123';
         site.Composite_Key__c = '1211013101610';
         upsert site;
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c Testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.csord__Primary_Order__c= Testorder2.id;     
        update order;
        //subscription and service
        csord__Subscription__c sub = [select id,site__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :Testorder2.id];
        sub.site__c=site.id;
        update sub;
        csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
        serv.Appointment_Required__c='true'; 
        update serv;  
        List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
        Appointment__c appt= new Appointment__c(SlotId__c='12345564',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        applst.add(appt);
        Appointment__c appt1= new Appointment__c(SlotId__c='123456333',Category__c='Test1',Subscription__c=sub.id,StartDate__c=System.today(),Status__c ='Partial Complete');
        applst.add(appt1);
        Appointment__c appt2= new Appointment__c(SlotId__c='123456123',Category__c='Test2',Subscription__c=sub.id,StartDate__c=System.today(),Status__c ='Complete');
        applst.add(appt2);
        
        insert applst;
        Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert con;
        List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr1);
        
        Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr2);
        insert fcrlst;
                
        PageReference pageRef = new PageReference('apex/AppointmentSitePage?id='+Testorder2.id);
        Test.setCurrentPage(pageRef); 
        AppointmentSitePageHandler appSpage = new AppointmentSitePageHandler();
        appSpage.SubscriptionId=sub.id;
        appSpage.hasMessageString='true';
        appSpage.AccList=NULL;
        appSpage.displayPopUp=true;
        appSpage.selectedAction='abc';
        appSpage.selectedActionVF='View Details';
        appSpage.displayBookAppointment=true;
        appSpage.displaySaveButton=true;
        appSpage.selectedSite='sa';
        appSpage.bookAppointmentURL='asas';
        //List<csord__Subscription__c> subList =new List<csord__Subscription__c>();
        //subList.add(sub);
        appspage.subDetailsList=new List<csord__Subscription__c>();
        appspage.subDetailsList.add(sub);
        PageReference pageRef1 = new PageReference('apex/AppointmentSitePage?id='+order.id);
        Test.setCurrentPage(pageRef); 
        AppointmentSitePageHandler appSpage1 = new AppointmentSitePageHandler();
        Test.startTest();
        appSpage.closePopup();
        appSpage.setBookAppointmentParams();
        appSpage.setPrimaryOrderID();
        appSpage.getAppDetails();
        appSpage.clearAllOnNoneAction();
        appSpage.pollAppointmentStatus();
           //appSpage.showPopup();
           //appSpage.CancelPopup();
        appSpage.OKPopup();
        appSpage.reRenderApptDetails();
        appSpage.createError(ApexPages.Severity.ERROR,'Appointment should be scheduled for all the sites to proceed.'); 
         // appSpage.hasMessages=true;
         // appSpage.errorMessage='Test 1234';
         // appSpage.alertType='Test 1234';
        PageReference pageRef2 = new PageReference('/'+Testorder2.id);
        appSpage.setPrimaryOrderStatus();
        System.assertEquals('View Details', appSpage.selectedActionVF);
        String parsstring='Test12345677';
        Test.stopTest();
    }
    public testmethod static void unitTest2(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        cscrm__Address__c address = new cscrm__Address__c();
         address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
         address.Address_ID__c = '1010101010';
         address.cscrm__Account__c = acc.id; 
         upsert address;
         
         cscrm__Site__c site = new cscrm__Site__c();
         site.cscrm__Account__c = acc.id;
         site.cscrm__Installation_Address__c = address.id;
         site.name = 'Sydney opera house';
         site.Composite_Key__c = '1211010101010';
         upsert site;
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c Testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.csord__Primary_Order__c= Testorder2.id;     
        update order;
        //subscription and service
        csord__Subscription__c sub = [select id,site__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :Testorder2.id];
        csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
        serv.Appointment_Required__c='true'; 
        update serv;  
        
        PageReference pageRef = new PageReference('apex/AppointmentSitePage?id='+Testorder2.id);
        Test.setCurrentPage(pageRef); 
        AppointmentSitePageHandler appSpage = new AppointmentSitePageHandler();
        appSpage.hasMessageString='true';
        appSpage.AccList=NULL;
        appSpage.displayPopUp=true;
        appSpage.selectedAction='abc';
        appSpage.selectedActionVF='View Details';
        appSpage.displayBookAppointment=true;
        appSpage.displaySaveButton=true;
        appSpage.selectedSite='sa';
        appSpage.bookAppointmentURL='asas';
        //List<csord__Subscription__c> subList =new List<csord__Subscription__c>();
        //subList.add(sub);
        appspage.subDetailsList=new List<csord__Subscription__c>();
        appspage.subDetailsList.add(sub);
        PageReference pageRef1 = new PageReference('apex/AppointmentSitePage?id='+order.id);
        Test.setCurrentPage(pageRef); 
        AppointmentSitePageHandler appSpage1 = new AppointmentSitePageHandler();
        Test.startTest();
        appSpage.closePopup();
        appSpage.setBookAppointmentParams();
        appSpage.setPrimaryOrderID();
        appSpage.getAppDetails();
        appSpage.clearAllOnNoneAction();
        appSpage.pollAppointmentStatus();
           //appSpage.showPopup();
           //appSpage.CancelPopup();
        appSpage.OKPopup();
        appSpage.reRenderApptDetails();
        appSpage.createError(ApexPages.Severity.ERROR,'Appointment should be scheduled for all the sites to proceed.'); 
        PageReference pageRef2 = new PageReference('/'+Testorder2.id);
        appSpage.setPrimaryOrderStatus();
        System.assertEquals('View Details', appSpage.selectedActionVF);
        Test.stopTest();
    }
}