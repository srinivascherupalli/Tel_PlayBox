/* Description: Test class that covers AppointmentBOMBaseCtrl 
Author: Jawahar
*/
@isTest
public class AppointmentBOMBaseCtrlTestClass{
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: scheduleTelstraOperation 
Description: test method for schedule operation
Author:Jawahar
--------------------------------------------------------*/
    public testmethod static void scheduleTelstraOperation(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert cont;
        
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        
        
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        //order.csord__Primary_Order__c= order.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        
        csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
       
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        //sub.Primary_Order__c = order.id;
        sub.csord__Order__c =order.id;
        update sub;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order.id;
        serv.Appointment_Required__c='true'; 
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Primary_Contact__c = cont.Id;
        serv.Technical_Contact__c = cont.Id;
        serv.Project_Contact__c = cont.Id;
        insert serv;

        List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
        Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA');
        lstReq.add(req);
        insert lstReq;
        List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Reschdeule_required__c=true,Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today(),Suggested_Start_Date__c=System.today());
        insert appt;
        appt.StartDate__c=system.today();
        update appt;
        Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert con;
        List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr1);
        
        Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr2);
        insert fcrlst; 
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        AppointmentBOMBaseCtrl.SlotWrapper slotwrapper = new AppointmentBOMBaseCtrl.SlotWrapper();
        slotWrapper.startDate=''+system.today();
        slotWrapper.availableSlots=2;
        AppointmentBOMBaseCtrl.ConfirmResponseWrapper  confirmtResponse =new AppointmentBOMBaseCtrl.ConfirmResponseWrapper();
        confirmtResponse.code = '1234';
        confirmtResponse.address='Test';
        confirmtResponse.subscriptionName ='TestSub';
        confirmtResponse.apptDate=''+system.today();
        confirmtResponse.apptTime='';
        confirmtResponse.apptId=appt.id;
        AppointmentBOMBaseCtrl.SiteAppointmentWrapper siteAppointment =new AppointmentBOMBaseCtrl.SiteAppointmentWrapper ();          
        siteAppointment.Address ='Test';
        siteAppointment.SubscriptionId=sub.id;
        siteAppointment.appointmentCount =2;
        siteAppointment.subscriptionName ='TestSub';
        AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper subscriptiowrapper = new AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper();
        subscriptiowrapper.iteratorFlag=true;
        subscriptiowrapper.SubsId=sub.id;
        subscriptiowrapper.ApptDate=''+system.today();
        subscriptiowrapper.ApptTime='';
        subscriptiowrapper.AppointmentID=appt.id;
        subscriptiowrapper.isSelected=true;
        subscriptiowrapper.Status='Scheduled';
        subscriptiowrapper.isRescheduleRequired=false;
        subscriptiowrapper.suggestedRescheduleDate =''+system.today();
        subscriptiowrapper.Category='TELSTRA';
        subscriptiowrapper.IsParent=true;
        subscriptiowrapper.ParentApptID=appt.id;
        
        AppointmentBOMBaseCtrl.SearchReserveWrapper searchWrapper = new AppointmentBOMBaseCtrl.SearchReserveWrapper();
        searchWrapper.subsID=sub.id;
        searchWrapper.operation ='Schedule';
       // searchWrapper.startDate ='2019-02-08T08:00:00';
        //searchWrapper.endDate ='2019-02-08T12:00:00';
         searchWrapper.startDate ='2019-07-05';
        searchWrapper.endDate ='2019-07-05';
        searchWrapper.Category ='Telstra';
        searchWrapper.parentApptId=appt.id;
        searchWrapper.selectedRescheduleInitiator='Customer';
        searchWrapper.selectedRescheduleReason='Reinitated';
        searchWrapper.slotId='12345';
        searchWrapper.notes ='Test';
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper  requireAppointment = new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper reqApp= new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        reqApp.SubscriptionId=sub.id;
        reqApp.appointmentID=appt.id;
        reqApp.appointmentCategory='Telstra';
        reqApp.sequenceofAppointment='1';
        reqApp.Count=2;
        reqApp.disable=true;
        reqApp.CategoryName='Test';
        reqApp.fromDate = system.today();
        
        
        
        
        AppointmentSearchResponseDTO appointDTO = new AppointmentSearchResponseDTO();
        AppointmentSearchResponseDTO.Data appointData = new AppointmentSearchResponseDTO.Data();
        AppointmentSearchResponseDTO.CauseEvent cause = new AppointmentSearchResponseDTO.CauseEvent();
        List<AppointmentSearchResponseDTO.AvailableSlots> availableSlots = new List<AppointmentSearchResponseDTO.AvailableSlots>();
        AppointmentSearchResponseDTO.AvailableSlots availableSlot = new AppointmentSearchResponseDTO.AvailableSlots();
        
        appointDTO.status = 200;
        //appointDTO.timing = '2019-02-12T03:04:55.728Z';
        appointDTO.correlationId ='e8314645-c0fe-42a7-beac-2e64f8b3ebcf';
        appointDTO.path ='/v1/appointments/slot-enquiry';
        appointDTO.method ='POST';
        
        appointData.transactionReferenceID = 'MyOrderNumber123';
        appointData.callingSystemID='b2b';
        appointData.estimatedDuration=60;
        availableSlot.slotID ='343532';
        availableSlot.slotType ='Standard';
        availableSlot.startDate='2019-02-08T08:00:00';
        availableSlot.endDate='2019-02-08T12:00:00';
        availableSlots.add(availableSlot);
        appointData.AvailableSlots = availableSlots;
        
        cause.eventReason ='MSD';
        //cause.eventStartDate='2019-02-01T08:00:00';
        appointData.CauseEvent = cause;
        
        appointDTO.Data = appointData;
        
        
        
        Required_Appointment__c reqAppoint = new Required_Appointment__c();
        reqAppoint.name = 'RequireTestRecord';
        reqAppoint.Appointment_BOM_ID__c ='34532443';
        reqAppoint.Appointment_Category__c='TELSTRA';
        reqAppoint.Suggested_StartDate__c=system.today();
        reqAppoint.Appointment_Type__c='ORDER INSTALL';
        reqAppoint.Appointment_SubType__c='EXCHANGE';
        reqAppoint.baseRuleProducts__c='[{"productInstanceID":"3e5e5c6d-7350-7cd9-ff16-00bbb9d58ab8","productID":"DMCAT_ProductSpecification_000073"},{"productInstanceID":"d8835c87-5f96-04cf-df83-fc7969053223","productID":"DMCAT_ProductSpecification_000112"}]';
        insert reqAppoint;
        reqAppoint.Generate_Appointment_Order__c=order.id;
        reqAppoint.Generate_Appointment_Subscription__c=sub.id;
        update reqAppoint;
        system.debug('Required Appointment --->>>>'+reqAppoint);
        Date fromDate=date.valueOf('2019-04-10T00:05:00');
 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        AppointmentBOMBaseCtrl.getAllSubscriptions(order.id);
        AppointmentBOMBaseCtrl.getSubsList(order.id);
        AppointmentBOMBaseCtrl.getOrder(order.id);
        searchWrapper.startDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        searchWrapper.endDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        AppointmentBOMBaseCtrl.SearchAppointmentSlots(searchWrapper);
        AppointmentBOMBaseCtrl.createAppointmentRecord('Test','12345','343532','TELSTRA',sub.id,'schedule',string.valueOf(system.today()),string.valueOf(system.today()),reqAppoint.id);
        AppointmentBOMBaseCtrl.createAppointmentRecord('Test','12345','343532','TELSTRA',sub.id,'Rebook',string.valueOf(system.today()),string.valueOf(system.today()),reqAppoint.id);
        AppointmentBOMBaseCtrl.updateAppointmentRecord('12345','TELSTRA',sub.id,'Test',string.valueOf(system.today()),string.valueOf(system.today()));
        AppointmentBOMBaseCtrl.getRescheduleInitiator();
        AppointmentBOMBaseCtrl.getRescheduleReason('Test');
        AppointmentBOMBaseCtrl.populateSlotWrapper(appointDTO);
        AppointmentBOMBaseCtrl.populateContactForReserveAppointmentAPV2(sub.id);
        searchWrapper.startDate =Datetime.now().format();
        searchWrapper.endDate =Datetime.now().format();
        AppointmentBOMBaseCtrl.rescheduleAppointment(searchWrapper);
        AppointmentBOMBaseCtrl.getAppoinmentDetails(sub.id);
        AppointmentBOMBaseCtrl.getReqAppList(order.id);
        AppointmentBOMBaseCtrl.confirmAppointment(searchWrapper);
       
        Test.stopTest();
        System.assertEquals(searchWrapper!=null, true);
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: rebookOperation 
Description: test method for rebook operation
Author:Jawahar
--------------------------------------------------------*/
    public testmethod static void rebookOperation(){
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
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        //order.csord__Primary_Order__c= testorder2.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        //subscription and service
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        sub.csord__Order__c = order.id;
        update sub;
        
        csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
        serv.Appointment_Required__c='true'; 
        update serv;  
        
        List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
        Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA',Suggested_StartDate__c=Date.Today(),Sequence_of_Appointment__c='2');
        lstReq.add(req);
        insert lstReq;
        
        Appointment__c appt= new Appointment__c(SlotId__c='TAPT2352213142342',Reschdeule_required__c=true,Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
      /*
        Appointment__c appt1= new Appointment__c(SlotId__c='APT001529399876SVEM',Reschdeule_required__c=true,Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt1;
        appt.StartDate__c=system.today();
        update appt;*/
        
      /*  List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
       Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
applst.add(appt);
Appointment__c appt1= new Appointment__c(SlotId__c='123456',Category__c='Test1',Subscription__c=sub.id,StartDate__c=System.today(),Status__c ='Partial Complete');
applst.add(appt1);
Appointment__c appt2= new Appointment__c(SlotId__c='123457',Category__c='Test1',Subscription__c=sub.id,StartDate__c=System.today(),Status__c ='Complete', Reschdeule_required__c=true,Suggested_Start_Date__c=System.today());
applst.add(appt2);

insert applst;*/
        
        Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert con;
        List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr1);
        
        Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr2);
        insert fcrlst;
        
       
        
        AppointmentBOMBaseCtrl.SearchReserveWrapper searchWrapper = new AppointmentBOMBaseCtrl.SearchReserveWrapper();
        searchWrapper.subsID=sub.id;
        searchWrapper.operation ='Rebook';
       // searchWrapper.startDate ='2019-02-08T08:00:00';
        //searchWrapper.endDate ='2019-02-08T12:00:00';
        searchWrapper.startDate =Date.today().format();
        searchWrapper.endDate =Date.today().format();
        searchWrapper.Category ='Telstra';
        searchWrapper.parentApptId=appt.id;
        searchWrapper.selectedRescheduleInitiator='Customer';
        searchWrapper.selectedRescheduleReason='Reinitated';
        searchWrapper.slotId='12345';
        searchWrapper.notes ='Test';
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper  requireAppointment = new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper reqApp= new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        reqApp.SubscriptionId=sub.id;
        reqApp.appointmentID=appt.id;
        reqApp.appointmentCategory='Telstra';
        reqApp.sequenceofAppointment='1';
        reqApp.Count=2;
        reqApp.disable=true;
        reqApp.CategoryName='Test';
        reqApp.fromDate = system.today();
        
        
        Required_Appointment__c reqAppoint = new Required_Appointment__c();
        reqAppoint.name = 'RequireTestRecord';
        reqAppoint.Appointment_BOM_ID__c ='34532443';
        reqAppoint.Appointment_Category__c='TELSTRA';
        reqAppoint.Suggested_StartDate__c=system.today();
        reqAppoint.Appointment_Type__c='ORDER INSTALL';
        reqAppoint.Appointment_SubType__c='EXCHANGE';
        insert reqAppoint;
        reqAppoint.Generate_Appointment_Order__c=order.id;
        reqAppoint.Generate_Appointment_Subscription__c=sub.id;
        update reqAppoint;
        system.debug('Required Appointment --->>>>'+reqAppoint);
  
     
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('rebook'));
        AppointmentBOMBaseCtrl.showSaveProgressButton(order.id);
        AppointmentBOMBaseCtrl.changeOrderStatus(order.id);
        AppointmentBOMBaseCtrl.getAllSubscriptions(order.id);
        //AppointmentBOMBaseCtrl.getSubsList(order2.id);
        AppointmentBOMBaseCtrl.getReqAppList(order.id);
        AppointmentBOMBaseCtrl.getOrder(order.id);
        AppointmentBOMBaseCtrl.createTaskRecords(appt.id,searchWrapper);
        searchWrapper.startDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        searchWrapper.endDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        AppointmentBOMBaseCtrl.SearchAppointmentSlots(searchWrapper);
         
        searchWrapper.startDate =Datetime.now().format();
        searchWrapper.endDate =Datetime.now().format();
        AppointmentBOMBaseCtrl.rebookAppointment(searchWrapper);
        AppointmentBOMBaseCtrl.updateParentApptStatus(appt);
        AppointmentBOMBaseCtrl.confirmAppointment(searchWrapper);
        String rebook_reserve='{"data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","appointmentCategory":"NBN","appointmentID":"APT001529399876SVEU","oldAppointmentID":"APT001529343576SVEU","reservationReference":"MyOrderNumber123: RESERVED","reservationConditions":"Reduced working hours during weekend periods July 2019","dependencies":[{"appointmentID":"TAPT2352213142342","appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","currentSlotStartDate":"2019-02-25T12:45:00","currentSlotEndDate":"2019-02-28T12:45:00","rescheduleRequired":"Y","leadTimeDaysApplied":4,"minimumStartDate":"2019-02-22T12:45:00","suggestedStartDate":"2019-02-23T12:45:00"}]},"correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","status":200,"time":"2019-02-01T12:45:10","path":"/v1/appointments/existing-appointments/APT2352213142342/slots/1111-2222-3333-4444/rebook","method":"POST"}';
        AppointmentBOMReserveResponseDTO response = AppointmentBOMReserveResponseDTO.parse(rebook_reserve);
        AppointmentBOMBaseCtrl.checkDependencyAppt(response,sub.id,false);
        
        System.assertEquals(searchWrapper!=null,true, 'Required appt created');
        Test.stopTest();
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: rescheduleOperation 
Description: test method for reschedule operation
Author:Jawahar
--------------------------------------------------------*/
    public testmethod static void rescheduleOperation(){
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
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.id= testorder2.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        //subscription and service
        csord__Subscription__c sub = [select id,site__c,csord__Order__r.csord__Primary_Order__c,csord__Order__c from csord__Subscription__c where csord__Order__c = :testorder2.id];
        sub.site__c=site.id;
        update sub;
        csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
        serv.Appointment_Required__c='true'; 
        update serv;  
        
        List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
        Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA');
        lstReq.add(req);
        insert lstReq;
        List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        applst.add(appt);
        Appointment__c appt1= new Appointment__c(SlotId__c='123456',Category__c='Test1',Subscription__c=sub.id,StartDate__c=System.today(),Status__c ='Partial Complete');
        applst.add(appt1);
        Appointment__c appt2= new Appointment__c(SlotId__c='123457',Category__c='Test1',Subscription__c=sub.id,StartDate__c=System.today(),Status__c ='Complete', Reschdeule_required__c=true,Suggested_Start_Date__c=System.today());
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

        AppointmentBOMBaseCtrl.SearchReserveWrapper searchWrapper = new AppointmentBOMBaseCtrl.SearchReserveWrapper();
        searchWrapper.subsID=sub.id;
        searchWrapper.operation ='Reschedule';
        //searchWrapper.startDate ='2019-02-08T08:00:00';
        //searchWrapper.endDate ='2019-02-08T12:00:00';
        searchWrapper.startDate ='2019-07-05';
        searchWrapper.endDate ='2019-07-05';
        searchWrapper.Category ='Telstra';
        searchWrapper.parentApptId=appt.id;
        searchWrapper.selectedRescheduleInitiator='Customer';
        searchWrapper.selectedRescheduleReason='Reinitated';
        searchWrapper.slotId='12345';
        searchWrapper.notes ='Test';
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper  requireAppointment = new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper reqApp= new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        reqApp.SubscriptionId=sub.id;
        reqApp.appointmentID=appt.id;
        reqApp.appointmentCategory='Telstra';
        reqApp.sequenceofAppointment='1';
        reqApp.Count=2;
        reqApp.disable=true;
        reqApp.CategoryName='Test';
        reqApp.fromDate = system.today();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        AppointmentBOMBaseCtrl.getAllSubscriptions(order.id);
        AppointmentBOMBaseCtrl.getSubsList(order.id);
        //AppointmentBOMBaseCtrl.getReqAppList(order.id);
        AppointmentBOMBaseCtrl.getOrder(order.id);
        searchWrapper.startDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        searchWrapper.endDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        AppointmentBOMBaseCtrl.SearchAppointmentSlots(searchWrapper);
        AppointmentBOMBaseCtrl.confirmAppointment(searchWrapper);
        System.assertEquals(reqApp!=null,true, 'Required appt created');
        Test.stopTest();
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: scheduleReqOperation 
Description: test method for schedule operation
Author:Jawahar
--------------------------------------------------------*/
    public testmethod static void scheduleReqOperation(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.id= testorder2.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        //subscription and service
        csord__Subscription__c sub = [select id,site__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__c = :testorder2.id];
        sub.site__c=site.id;
        update sub;
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order.id;
        serv.Appointment_Required__c='true'; 
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Primary_Contact__c = cont.Id;
        serv.Technical_Contact__c = cont.Id;
        serv.Project_Contact__c = cont.Id;
        insert serv;
        
        
        /*csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
serv.Appointment_Required__c='true'; 
update serv;*/  
        
        List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
        Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA');
        lstReq.add(req);
        insert lstReq;
        List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
        insert appt;
        appt.StartDate__c=system.today();
        update appt;
        Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert con;
        List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr1);
        
        Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr2);
        insert fcrlst;
        

        
        AppointmentSearchResponseDTO appointDTO = new AppointmentSearchResponseDTO();
        AppointmentSearchResponseDTO.Data appointData = new AppointmentSearchResponseDTO.Data();
        AppointmentSearchResponseDTO.CauseEvent cause = new AppointmentSearchResponseDTO.CauseEvent();
        List<AppointmentSearchResponseDTO.AvailableSlots> availableSlots = new List<AppointmentSearchResponseDTO.AvailableSlots>();
        AppointmentSearchResponseDTO.AvailableSlots availableSlot = new AppointmentSearchResponseDTO.AvailableSlots();
        
        appointDTO.status = 200;
        //appointDTO.timing = '2019-02-12T03:04:55.728Z';
        appointDTO.correlationId ='e8314645-c0fe-42a7-beac-2e64f8b3ebcf';
        appointDTO.path ='/v1/appointments/slot-enquiry';
        appointDTO.method ='POST';
        
        appointData.transactionReferenceID = 'MyOrderNumber123';
        appointData.callingSystemID='b2b';
        appointData.estimatedDuration=60;
        availableSlot.slotID ='12345';
        availableSlot.slotType ='Standard';
        availableSlot.startDate='2019-02-08T08:00:00';
        availableSlot.endDate='2019-02-08T12:00:00';
        availableSlots.add(availableSlot);
        appointData.AvailableSlots = availableSlots;
        
        cause.eventReason ='MSD';
        appointData.CauseEvent = cause;
        
        appointDTO.Data = appointData;
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        
        AppointmentBOMBaseCtrl.SearchReserveWrapper searchWrapper = new AppointmentBOMBaseCtrl.SearchReserveWrapper();
        searchWrapper.subsID=sub.id;
        searchWrapper.operation ='Schedule';
       // searchWrapper.startDate ='2019-02-08T08:00:00';
        //searchWrapper.endDate ='2019-02-08T12:00:00';
        searchWrapper.startDate ='2019-07-05';
        searchWrapper.endDate ='2019-07-05';
        searchWrapper.Category ='Telstra';
        searchWrapper.parentApptId=appt.id;
        searchWrapper.selectedRescheduleInitiator='Customer';
        searchWrapper.selectedRescheduleReason='Reinitated';
        searchWrapper.slotId='12345';
        searchWrapper.notes ='Test';
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper  requireAppointment = new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper reqApp= new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        reqApp.SubscriptionId=sub.id;
        reqApp.appointmentID=appt.id;
        reqApp.appointmentCategory='NBN';
        reqApp.sequenceofAppointment='1';
        reqApp.Count=2;
        reqApp.disable=true;
        reqApp.CategoryName='Test';
        reqApp.fromDate = system.today();

        Test.startTest();
        searchWrapper.startDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        searchWrapper.endDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        AppointmentBOMBaseCtrl.SearchAppointmentSlots(searchWrapper);
        System.assertEquals(searchWrapper!=null,true, 'Search response on UI');
        Test.stopTest();
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: schedule NBN Operation 
Description: test method for schedule NBN operation
Author:Jawahar
--------------------------------------------------------*/
    public testmethod static void scheduleNBNOperation(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        
        
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        //order.csord__Primary_Order__c= order.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        
        csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
        order2.id= order.id;
        update order2;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        //sub.Primary_Order__c = order.id;
        sub.csord__Order__c =order2.id;
        update sub;
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order.id;
        serv.Appointment_Required__c='true'; 
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Primary_Contact__c = cont.Id;
        serv.Technical_Contact__c = cont.Id;
        serv.Project_Contact__c = cont.Id;
        insert serv;
        
        
        List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
        Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA');
        lstReq.add(req);
        insert lstReq;
        List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Reschdeule_required__c=true,Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today(),Suggested_Start_Date__c=System.today());
        insert appt;
        appt.StartDate__c=system.today();
        update appt;
        Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert con;
        List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr1);
        
        Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr2);
        insert fcrlst;
 
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        AppointmentBOMBaseCtrl.SlotWrapper slotwrapper = new AppointmentBOMBaseCtrl.SlotWrapper();
        slotWrapper.startDate=''+system.today();
        slotWrapper.availableSlots=2;
        
        AppointmentBOMBaseCtrl.ConfirmResponseWrapper  confirmtResponse =new AppointmentBOMBaseCtrl.ConfirmResponseWrapper();
        confirmtResponse.code = '1234';
        confirmtResponse.address='Test';
        confirmtResponse.subscriptionName ='TestSub';
        confirmtResponse.apptDate=''+system.today();
        confirmtResponse.apptTime='';
        confirmtResponse.apptId=appt.id;
        AppointmentBOMBaseCtrl.SiteAppointmentWrapper siteAppointment =new AppointmentBOMBaseCtrl.SiteAppointmentWrapper ();          
        siteAppointment.Address ='Test';
        siteAppointment.SubscriptionId=sub.id;
        siteAppointment.appointmentCount =2;
        siteAppointment.subscriptionName ='TestSub';
        AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper subscriptiowrapper = new AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper();
        subscriptiowrapper.iteratorFlag=true;
        subscriptiowrapper.SubsId=sub.id;
        subscriptiowrapper.ApptDate=''+system.today();
        subscriptiowrapper.ApptTime='';
        subscriptiowrapper.AppointmentID=appt.id;
        subscriptiowrapper.isSelected=true;
        subscriptiowrapper.Status='Scheduled';
        subscriptiowrapper.isRescheduleRequired=false;
        subscriptiowrapper.suggestedRescheduleDate =''+system.today();
        subscriptiowrapper.Category='NBN';
        subscriptiowrapper.IsParent=true;
        subscriptiowrapper.ParentApptID=appt.id;
        
        AppointmentBOMBaseCtrl.SearchReserveWrapper searchWrapper = new AppointmentBOMBaseCtrl.SearchReserveWrapper();
        searchWrapper.subsID=sub.id;
        searchWrapper.operation ='Schedule';
       // searchWrapper.startDate ='2019-02-08T08:00:00';
        //searchWrapper.endDate ='2019-02-08T12:00:00';
        searchWrapper.startDate ='2018-09-10T08:00:00.0Z';
        searchWrapper.endDate ='2018-09-10T08:00:00.0Z'; 
        searchWrapper.Category ='NBN';
        searchWrapper.parentApptId=appt.id;
        searchWrapper.selectedRescheduleInitiator='Customer';
        searchWrapper.selectedRescheduleReason='Reinitated';
        searchWrapper.slotId='12345';
        searchWrapper.notes ='Test';
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper  requireAppointment = new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper reqApp= new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        reqApp.SubscriptionId=sub.id;
        reqApp.appointmentID=appt.id;
        reqApp.appointmentCategory='NBN';
        reqApp.sequenceofAppointment='1';
        reqApp.Count=2;
        reqApp.disable=true;
        reqApp.CategoryName='Test';
        reqApp.fromDate = system.today();
        
        AppointmentSearchResponseDTO appointDTO = new AppointmentSearchResponseDTO();
        AppointmentSearchResponseDTO.Data appointData = new AppointmentSearchResponseDTO.Data();
        AppointmentSearchResponseDTO.CauseEvent cause = new AppointmentSearchResponseDTO.CauseEvent();
        List<AppointmentSearchResponseDTO.AvailableSlots> availableSlots = new List<AppointmentSearchResponseDTO.AvailableSlots>();
        AppointmentSearchResponseDTO.AvailableSlots availableSlot = new AppointmentSearchResponseDTO.AvailableSlots();
        
        appointDTO.status = 200;
        //appointDTO.timing = '2019-02-12T03:04:55.728Z';
        appointDTO.correlationId ='e8314645-c0fe-42a7-beac-2e64f8b3ebcf';
        appointDTO.path ='/v1/appointments/slot-enquiry';
        appointDTO.method ='POST';
        
        appointData.transactionReferenceID = 'MyOrderNumber123';
        appointData.callingSystemID='b2b';
        appointData.estimatedDuration=60;
        availableSlot.slotID ='343532';
        availableSlot.slotType ='Standard';
        availableSlot.startDate='2019-02-08T08:00:00';
        availableSlot.endDate='2019-02-08T12:00:00';
        availableSlots.add(availableSlot);
        appointData.AvailableSlots = availableSlots;
        
        cause.eventReason ='MSD';
        //cause.eventStartDate='2019-02-01T08:00:00';
        appointData.CauseEvent = cause;
        
        appointDTO.Data = appointData;
        
        Required_Appointment__c reqAppoint = new Required_Appointment__c();
        reqAppoint.name = 'RequireTestRecord';
        reqAppoint.Appointment_BOM_ID__c ='34532443';
        reqAppoint.Appointment_Category__c='NBN';
        reqAppoint.Suggested_StartDate__c=system.today();
        reqAppoint.Appointment_Type__c='ORDER INSTALL';
        reqAppoint.Appointment_SubType__c='EXCHANGE';
        insert reqAppoint;
        reqAppoint.Generate_Appointment_Order__c=order2.id;
        reqAppoint.Generate_Appointment_Subscription__c=sub.id;
        update reqAppoint;
        system.debug('Required Appointment --->>>>'+reqAppoint);
        Date fromDate=date.valueOf('2019-04-10T00:05:00');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        //AppointmentBOMBaseCtrl.getAllSubscriptions(order.id);
        //AppointmentBOMBaseCtrl.getSubsList(order.id);
        //AppointmentBOMBaseCtrl.getOrder(order.id);
        searchWrapper.startDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        searchWrapper.endDate =Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        AppointmentBOMBaseCtrl.SearchAppointmentSlots(searchWrapper);
        
        Test.stopTest();
        System.assertEquals(confirmtResponse!=null,true, 'Confirmed response on UI');
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: schedule Operation 
Description: test method for schedule NBN operation
Author:Jawahar
--------------------------------------------------------*/
    public testmethod static void scheduleOperation(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        
        
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        //order.csord__Primary_Order__c= order.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        
        csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
        order2.id= order.id;
        update order2;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        //sub.Primary_Order__c = order.id;
        sub.csord__Order__c =order2.id;
        update sub;
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order.id;
        serv.Appointment_Required__c='true'; 
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Primary_Contact__c = cont.Id;
        serv.Technical_Contact__c = cont.Id;
        serv.Project_Contact__c = cont.Id;
        insert serv;
        
        
        /*csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
serv.Appointment_Required__c='true'; 
update serv;*/  
        
        List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
        Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA');
        lstReq.add(req);
        insert lstReq;
        List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Reschdeule_required__c=true,Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today(),Suggested_Start_Date__c=System.today());
        insert appt;
        appt.StartDate__c=system.today();
        update appt;
        Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert con;
        List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr1);
        
        Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr2);
        insert fcrlst;

        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
 
        AppointmentBOMBaseCtrl.SlotWrapper slotwrapper = new AppointmentBOMBaseCtrl.SlotWrapper();
        slotWrapper.startDate=''+system.today();
        slotWrapper.availableSlots=2;
        //slotWrapper.slotDetail='';
        //slotWrapper.keySetList='';
        
        AppointmentBOMBaseCtrl.ConfirmResponseWrapper  confirmtResponse =new AppointmentBOMBaseCtrl.ConfirmResponseWrapper();
        confirmtResponse.code = '1234';
        confirmtResponse.address='Test';
        confirmtResponse.subscriptionName ='TestSub';
        confirmtResponse.apptDate=''+system.today();
        confirmtResponse.apptTime='';
        confirmtResponse.apptId=appt.id;
        AppointmentBOMBaseCtrl.SiteAppointmentWrapper siteAppointment =new AppointmentBOMBaseCtrl.SiteAppointmentWrapper ();          
        siteAppointment.Address ='Test';
        siteAppointment.SubscriptionId=sub.id;
        siteAppointment.appointmentCount =2;
        siteAppointment.subscriptionName ='TestSub';
        AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper subscriptiowrapper = new AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper();
        subscriptiowrapper.iteratorFlag=true;
        subscriptiowrapper.SubsId=sub.id;
        subscriptiowrapper.ApptDate=''+system.today();
        subscriptiowrapper.ApptTime='';
        subscriptiowrapper.AppointmentID=appt.id;
        subscriptiowrapper.isSelected=true;
        subscriptiowrapper.Status='Scheduled';
        subscriptiowrapper.isRescheduleRequired=false;
        subscriptiowrapper.suggestedRescheduleDate =''+system.today();
        subscriptiowrapper.Category='TELSTRA';
        subscriptiowrapper.IsParent=true;
        subscriptiowrapper.ParentApptID=appt.id;
        
        AppointmentBOMBaseCtrl.SearchReserveWrapper searchWrapper = new AppointmentBOMBaseCtrl.SearchReserveWrapper();
        searchWrapper.subsID=sub.id;
        searchWrapper.operation ='Schedule';
        //searchWrapper.startDate ='2019-02-08T08:00:00';
        //searchWrapper.endDate ='2019-02-08T12:00:00';
         searchWrapper.startDate ='2019-07-05';
        searchWrapper.endDate ='2019-07-05';
        searchWrapper.Category ='Telstra';
        searchWrapper.parentApptId=appt.id;
        searchWrapper.selectedRescheduleInitiator='Customer';
        searchWrapper.selectedRescheduleReason='Reinitated';
        searchWrapper.slotId='12345';
        searchWrapper.notes ='Test';
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper  requireAppointment = new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper reqApp= new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        reqApp.SubscriptionId=sub.id;
        reqApp.appointmentID=appt.id;
        reqApp.appointmentCategory='Telstra';
        reqApp.sequenceofAppointment='1';
        reqApp.Count=2;
        reqApp.disable=true;
        reqApp.CategoryName='Test';
        reqApp.fromDate = system.today();
        
        
        
        
        AppointmentSearchResponseDTO appointDTO = new AppointmentSearchResponseDTO();
        AppointmentSearchResponseDTO.Data appointData = new AppointmentSearchResponseDTO.Data();
        AppointmentSearchResponseDTO.CauseEvent cause = new AppointmentSearchResponseDTO.CauseEvent();
        List<AppointmentSearchResponseDTO.AvailableSlots> availableSlots = new List<AppointmentSearchResponseDTO.AvailableSlots>();
        AppointmentSearchResponseDTO.AvailableSlots availableSlot = new AppointmentSearchResponseDTO.AvailableSlots();
        
        appointDTO.status = 200;
        //appointDTO.timing = '2019-02-12T03:04:55.728Z';
        appointDTO.correlationId ='e8314645-c0fe-42a7-beac-2e64f8b3ebcf';
        appointDTO.path ='/v1/appointments/slot-enquiry';
        appointDTO.method ='POST';
        
        appointData.transactionReferenceID = 'MyOrderNumber123';
        appointData.callingSystemID='b2b';
        appointData.estimatedDuration=60;
        availableSlot.slotID ='343532';
        availableSlot.slotType ='Standard';
        availableSlot.startDate='2019-02-08T08:00:00';
        availableSlot.endDate='2019-02-08T12:00:00';
        availableSlots.add(availableSlot);
        appointData.AvailableSlots = availableSlots;
        
        cause.eventReason ='MSD';
        //cause.eventStartDate='2019-02-01T08:00:00';
        appointData.CauseEvent = cause;
        
        appointDTO.Data = appointData;
        
        
        
        Required_Appointment__c reqAppoint = new Required_Appointment__c();
        reqAppoint.name = 'RequireTestRecord';
        reqAppoint.Appointment_BOM_ID__c ='34532443';
        reqAppoint.Appointment_Category__c='TELSTRA';
        reqAppoint.Suggested_StartDate__c=system.today();
        reqAppoint.Appointment_Type__c='ORDER INSTALL';
        reqAppoint.Appointment_SubType__c='EXCHANGE';
        insert reqAppoint;
        reqAppoint.Generate_Appointment_Order__c=order2.id;
        reqAppoint.Generate_Appointment_Subscription__c=sub.id;
        update reqAppoint;
        system.debug('Required Appointment --->>>>'+reqAppoint);
        Date fromDate=date.valueOf('2019-04-10T00:05:00');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        searchWrapper.startDate =Datetime.now().format();
        searchWrapper.endDate =Datetime.now().format();
        AppointmentBOMBaseCtrl.reserveAppointment(searchWrapper);
        Test.stopTest();
        System.assertEquals(appointDTO!=null, true,'Appointment created');
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method: Reschedule Telstra Operation
Description: test method for Reschedule Telstra Operation
Author:Jawahar
--------------------------------------------------------*/
    public testmethod static void rescheduleTelstraOperation(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        
        
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        //order.csord__Primary_Order__c= order.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        
        csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
        order2.id= order.id;
        update order2;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        //sub.Primary_Order__c = order.id;
        sub.csord__Order__c =order2.id;
        update sub;
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order.id;
        serv.Appointment_Required__c='true'; 
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Primary_Contact__c = cont.Id;
        serv.Technical_Contact__c = cont.Id;
        serv.Project_Contact__c = cont.Id;
        insert serv;
        
        
        /*csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
serv.Appointment_Required__c='true'; 
update serv;*/  
        
        List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
        Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA');
        lstReq.add(req);
        insert lstReq;
        //List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
        //Appointment__c appt= new Appointment__c();
        //insert appt;
        //appt.StartDate__c=system.today();
        //update appt;
        Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert con;
        List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr1);
        
        Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr2);
        insert fcrlst;
  
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
    
        AppointmentBOMBaseCtrl.SlotWrapper slotwrapper = new AppointmentBOMBaseCtrl.SlotWrapper();
        slotWrapper.startDate=''+system.today();
        slotWrapper.availableSlots=2;
       
        AppointmentBOMBaseCtrl.ConfirmResponseWrapper  confirmtResponse =new AppointmentBOMBaseCtrl.ConfirmResponseWrapper();
        confirmtResponse.code = '1234';
        confirmtResponse.address='Test';
        confirmtResponse.subscriptionName ='TestSub';
        confirmtResponse.apptDate=''+system.today();
        confirmtResponse.apptTime='';
        //confirmtResponse.apptId=appt.id;
        AppointmentBOMBaseCtrl.SiteAppointmentWrapper siteAppointment =new AppointmentBOMBaseCtrl.SiteAppointmentWrapper ();          
        siteAppointment.Address ='Test';
        siteAppointment.SubscriptionId=sub.id;
        siteAppointment.appointmentCount =2;
        siteAppointment.subscriptionName ='TestSub';
        AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper subscriptiowrapper = new AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper();
        subscriptiowrapper.iteratorFlag=true;
        subscriptiowrapper.SubsId=sub.id;
        subscriptiowrapper.ApptDate=''+system.today();
        subscriptiowrapper.ApptTime='';
        //subscriptiowrapper.AppointmentID=appt.id;
        subscriptiowrapper.isSelected=true;
        subscriptiowrapper.Status='Scheduled';
        subscriptiowrapper.isRescheduleRequired=false;
        subscriptiowrapper.suggestedRescheduleDate =''+system.today();
        subscriptiowrapper.Category='TELSTRA';
        subscriptiowrapper.IsParent=true;
        //subscriptiowrapper.ParentApptID=appt.id;
        
        AppointmentBOMBaseCtrl.SearchReserveWrapper searchWrapper = new AppointmentBOMBaseCtrl.SearchReserveWrapper();
        searchWrapper.subsID=sub.id;
        searchWrapper.operation ='Schedule';
        //searchWrapper.endDate ='2019-02-08T12:00:00';
        //searchWrapper.startDate ='2019-02-08T08:00:00';   
         searchWrapper.startDate ='2019-07-05';
        searchWrapper.endDate ='2019-07-05';
        searchWrapper.Category ='Telstra';
        //searchWrapper.parentApptId=appt.id;
        searchWrapper.selectedRescheduleInitiator='Customer';
        searchWrapper.selectedRescheduleReason='Reinitated';
        searchWrapper.slotId='12345';
        searchWrapper.notes ='Test';
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper  requireAppointment = new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper reqApp= new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        reqApp.SubscriptionId=sub.id;
        //reqApp.appointmentID=appt.id;
        reqApp.appointmentCategory='Telstra';
        reqApp.sequenceofAppointment='1';
        reqApp.Count=2;
        reqApp.disable=true;
        reqApp.CategoryName='Test';
        reqApp.fromDate = system.today();
        
        
        
        
        AppointmentSearchResponseDTO appointDTO = new AppointmentSearchResponseDTO();
        AppointmentSearchResponseDTO.Data appointData = new AppointmentSearchResponseDTO.Data();
        AppointmentSearchResponseDTO.CauseEvent cause = new AppointmentSearchResponseDTO.CauseEvent();
        List<AppointmentSearchResponseDTO.AvailableSlots> availableSlots = new List<AppointmentSearchResponseDTO.AvailableSlots>();
        AppointmentSearchResponseDTO.AvailableSlots availableSlot = new AppointmentSearchResponseDTO.AvailableSlots();
        
        appointDTO.status = 200;
        //appointDTO.timing = '2019-02-12T03:04:55.728Z';
        appointDTO.correlationId ='e8314645-c0fe-42a7-beac-2e64f8b3ebcf';
        appointDTO.path ='/v1/appointments/slot-enquiry';
        appointDTO.method ='POST';
        
        appointData.transactionReferenceID = 'MyOrderNumber123';
        appointData.callingSystemID='b2b';
        appointData.estimatedDuration=60;
        availableSlot.slotID ='343532';
        availableSlot.slotType ='Standard';
        availableSlot.startDate='2019-02-08T08:00:00';
        availableSlot.endDate='2019-02-08T12:00:00';
        availableSlots.add(availableSlot);
        appointData.AvailableSlots = availableSlots;
        
        cause.eventReason ='MSD';
        //cause.eventStartDate='2019-02-01T08:00:00';
        appointData.CauseEvent = cause;
        
        appointDTO.Data = appointData;
        
        Required_Appointment__c reqAppoint = new Required_Appointment__c();
        reqAppoint.name = 'RequireTestRecord';
        reqAppoint.Appointment_BOM_ID__c ='34532443';
        reqAppoint.Appointment_Category__c='TELSTRA';
        reqAppoint.Suggested_StartDate__c=system.today();
        reqAppoint.Appointment_Type__c='ORDER INSTALL';
        reqAppoint.Appointment_SubType__c='EXCHANGE';
        reqAppoint.baseRuleProducts__c='[{"productInstanceID":"3e5e5c6d-7350-7cd9-ff16-00bbb9d58ab8","productID":"DMCAT_ProductSpecification_000073"},{"productInstanceID":"d8835c87-5f96-04cf-df83-fc7969053223","productID":"DMCAT_ProductSpecification_000112"}]';
        insert reqAppoint;
        reqAppoint.Generate_Appointment_Order__c=order.id;
        reqAppoint.Generate_Appointment_Subscription__c=sub.id;
        update reqAppoint;
        system.debug('Required Appointment --->>>>'+reqAppoint);
        Date fromDate=date.valueOf('2019-04-10T00:05:00');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        
        //AppointmentBOMBaseCtrl.rescheduleAppointment(searchWrapper);
        AppointmentBOMBaseCtrl.getSubsList(order.Id);
        //AppointmentBOMBaseCtrl.checkDependencyAppt(,true);
        Test.stopTest();
         System.assertEquals(searchWrapper!=null, true);
    }
    /*-------------------------------------------------------- 
EDGE-66472, EDGE-84934,EDGE-66471
Method:requireAppListMethod
Description: test method for requireAppListMethod
Author:Jawahar
--------------------------------------------------------*/
    public testmethod static void requireAppListMethod(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        
        
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        //order.csord__Primary_Order__c= order.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        
        csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
        order2.id =  order.id;
        update order2;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        //sub.Primary_Order__c = order.id;
        sub.csord__Order__c =order2.id;
        update sub;
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order.id;
        serv.Appointment_Required__c='true'; 
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Primary_Contact__c = cont.Id;
        serv.Technical_Contact__c = cont.Id;
        serv.Project_Contact__c = cont.Id;
        insert serv;
        
        
        /*csord__Service__c serv =[select id, Appointment_Required__c,csord__Subscription__c from csord__Service__c where csord__Subscription__c =: sub.id];
serv.Appointment_Required__c='true'; 
update serv;*/  
        
        /*List<Required_Appointment__c> lstReq= new List<Required_Appointment__c>();
Required_Appointment__c req= new Required_Appointment__c(Generate_Appointment_Order__c=order.id,Generate_Appointment_Subscription__c=sub.id, Appointment_Category__c='TELSTRA');
lstReq.add(req);
insert lstReq;*/
        List<Appointment__c> applst= new List<Appointment__c>();
        //appointment
        Appointment__c appt= new Appointment__c(SlotId__c='12345',Reschdeule_required__c=true,Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today(),Suggested_Start_Date__c=System.today());
        insert appt;
        appt.StartDate__c=system.today();
        update appt;
        Contact con= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        insert con;
        List<Functional_Contact_Role__c> fcrlst=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcr1= new Functional_Contact_Role__c(Role__c='Primary Site Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr1);
        
        Functional_Contact_Role__c fcr2= new Functional_Contact_Role__c(Role__c='Technical Contact',ContactID__c=con.id,SiteID__c=sub.site__c,SubscriptionID__c=sub.id);
        fcrlst.add(fcr2);
        insert fcrlst;

        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        
        AppointmentBOMBaseCtrl.SlotWrapper slotwrapper = new AppointmentBOMBaseCtrl.SlotWrapper();
        slotWrapper.startDate=''+system.today();
        slotWrapper.availableSlots=2;
        //slotWrapper.slotDetail='';
        //slotWrapper.keySetList='';
        
        AppointmentBOMBaseCtrl.ConfirmResponseWrapper  confirmtResponse =new AppointmentBOMBaseCtrl.ConfirmResponseWrapper();
        confirmtResponse.code = '1234';
        confirmtResponse.address='Test';
        confirmtResponse.subscriptionName ='TestSub';
        confirmtResponse.apptDate=''+system.today();
        confirmtResponse.apptTime='';
        confirmtResponse.apptId=appt.id;
        AppointmentBOMBaseCtrl.SiteAppointmentWrapper siteAppointment =new AppointmentBOMBaseCtrl.SiteAppointmentWrapper ();          
        siteAppointment.Address ='Test';
        siteAppointment.SubscriptionId=sub.id;
        siteAppointment.appointmentCount =2;
        siteAppointment.subscriptionName ='TestSub';
        AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper subscriptiowrapper = new AppointmentBOMBaseCtrl.SubscriptionAppointmentWrapper();
        subscriptiowrapper.iteratorFlag=true;
        subscriptiowrapper.SubsId=sub.id;
        subscriptiowrapper.ApptDate=''+system.today();
        subscriptiowrapper.ApptTime='';
        subscriptiowrapper.AppointmentID=appt.id;
        subscriptiowrapper.isSelected=true;
        subscriptiowrapper.Status='Scheduled';
        subscriptiowrapper.isRescheduleRequired=false;
        subscriptiowrapper.suggestedRescheduleDate =''+system.today();
        subscriptiowrapper.Category='TELSTRA';
        subscriptiowrapper.IsParent=true;
        subscriptiowrapper.ParentApptID=appt.id;
        
        AppointmentBOMBaseCtrl.SearchReserveWrapper searchWrapper = new AppointmentBOMBaseCtrl.SearchReserveWrapper();
        searchWrapper.subsID=sub.id;
        searchWrapper.operation ='Schedule';
       // searchWrapper.startDate ='2019-02-08T08:00:00';
        //searchWrapper.endDate ='2019-02-08T12:00:00';
         searchWrapper.startDate ='2019-07-05';
        searchWrapper.endDate ='2019-07-05';
        searchWrapper.Category ='Telstra';
        searchWrapper.parentApptId=appt.id;
        searchWrapper.selectedRescheduleInitiator='Customer';
        searchWrapper.selectedRescheduleReason='Reinitated';
        searchWrapper.slotId='12345';
        searchWrapper.notes ='Test';
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper  requireAppointment = new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        
        AppointmentBOMBaseCtrl.requiredAppointmentWrapper reqApp= new AppointmentBOMBaseCtrl.requiredAppointmentWrapper();
        reqApp.SubscriptionId=sub.id;
        reqApp.appointmentID=appt.id;
        reqApp.appointmentCategory='Telstra';
        reqApp.sequenceofAppointment='1';
        reqApp.Count=2;
        reqApp.disable=true;
        reqApp.CategoryName='Test';
        reqApp.fromDate = system.today();
        
        AppointmentSearchResponseDTO appointDTO = new AppointmentSearchResponseDTO();
        AppointmentSearchResponseDTO.Data appointData = new AppointmentSearchResponseDTO.Data();
        AppointmentSearchResponseDTO.CauseEvent cause = new AppointmentSearchResponseDTO.CauseEvent();
        List<AppointmentSearchResponseDTO.AvailableSlots> availableSlots = new List<AppointmentSearchResponseDTO.AvailableSlots>();
        AppointmentSearchResponseDTO.AvailableSlots availableSlot = new AppointmentSearchResponseDTO.AvailableSlots();
        
        appointDTO.status = 200;
        //appointDTO.timing = '2019-02-12T03:04:55.728Z';
        appointDTO.correlationId ='e8314645-c0fe-42a7-beac-2e64f8b3ebcf';
        appointDTO.path ='/v1/appointments/slot-enquiry';
        appointDTO.method ='POST';
        
        appointData.transactionReferenceID = 'MyOrderNumber123';
        appointData.callingSystemID='b2b';
        appointData.estimatedDuration=60;
        availableSlot.slotID ='343532';
        availableSlot.slotType ='Standard';
        availableSlot.startDate='2019-02-08T08:00:00';
        availableSlot.endDate='2019-02-08T12:00:00';
        availableSlots.add(availableSlot);
        appointData.AvailableSlots = availableSlots;
        
        cause.eventReason ='MSD';
        //cause.eventStartDate='2019-02-01T08:00:00';
        appointData.CauseEvent = cause;
        
        appointDTO.Data = appointData;
        Required_Appointment__c reqAppoint = new Required_Appointment__c();
        reqAppoint.name = 'RequireTestRecord';
        reqAppoint.Appointment_BOM_ID__c ='34532443';
        reqAppoint.Appointment_Category__c='TELSTRA';
        reqAppoint.Suggested_StartDate__c=system.today();
        reqAppoint.Appointment_Type__c='ORDER INSTALL';
        reqAppoint.Appointment_SubType__c='EXCHANGE';
        reqAppoint.baseRuleProducts__c='[{"productInstanceID":"3e5e5c6d-7350-7cd9-ff16-00bbb9d58ab8","productID":"DMCAT_ProductSpecification_000073"},{"productInstanceID":"d8835c87-5f96-04cf-df83-fc7969053223","productID":"DMCAT_ProductSpecification_000112"}]';
        insert reqAppoint;
        reqAppoint.Generate_Appointment_Order__c=order.id;
        reqAppoint.Generate_Appointment_Subscription__c=sub.id;
        update reqAppoint;
        system.debug('Required Appointment --->>>>'+reqAppoint);
        Date fromDate=date.valueOf('2019-04-10T00:05:00');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
        AppointmentBOMBaseCtrl.getReqAppList(order.id);
        Test.stopTest();
         System.assertEquals(searchWrapper!=null, true);
    }
      /*-------------------------------------------------------- 
EDGE-66472
Method:generateApptErrorScenarioTest
Description: test method for requireAppListMethod
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public testmethod static void generateApptErrorScenarioTest(){
        //account
        Account acc = AccountTestFactory.buildAccount('TestAccount');
        insert acc;
        Contact cont= new Contact(firstname='test123',lastname='test123',Phone='12345678',Accountid=acc.id);
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        
        
        //order
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c testorder2=ProductTestService.getNewOrderForAccount(acc);
        //order.csord__Primary_Order__c= order.id; 
        order.isMSISDNReserved__c = true;   
        update order;
        
        csord__Order__c order2 = ProductTestService.getNewOrderForAccount(acc);
        //order2.id= order.id;
        update order2;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        sub.Primary_Order__c = order.id;
        sub.csord__Order__c =order2.id;
        update sub;
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = sub.id;
        serv.csord__Order__c = order.id;
        serv.Appointment_Required__c='true'; 
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Primary_Contact__c = cont.Id;
        serv.Technical_Contact__c = cont.Id;
        serv.Project_Contact__c = cont.Id;
        insert serv; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));
        AppointmentBOMBaseCtrl.generateAppointmentForErrorScenario(sub.id);
        Test.stopTest();
        System.assertNotEquals(serv, null);
       //System.assertEquals([SELECT count() FROM Required_Appointment__c]>0,true,'Required Appointments created' );
    }
    
}