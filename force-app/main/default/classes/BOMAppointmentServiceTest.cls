@isTest
public class BOMAppointmentServiceTest {          
    /* @testsetup
public static void dataSetup(){
Environment_Configurations__c ec = new Environment_Configurations__c(Custom_Logging__c = true);
insert ec;
EnvironmentVariable.put('access_token', '1234');
//EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6/avaliable-slots');
EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6/slot-enquiry');
EnvironmentVariable.put('okapi_east_url', '/?');
EnvironmentVariable.put('okapi_client_id', '1234');
EnvironmentVariable.put('okapi_client_secret', '1234');
EnvironmentVariable.put('okapi_token_url', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
}*/
    
    @isTest static void testGetInstance()
    {
        BOMAppointmentService.getInstance();
        system.assertNotEquals(null,BOMAppointmentService.getInstance());
    }
    
    @istest static void testAppointQuerySuccessResponse(){
        AppointmentSearchRequestDTO apptDTO = new AppointmentSearchRequestDTO();
        AppointmentSearchRequestDTO.data apptdata = new AppointmentSearchRequestDTO.data();
        //AppointmentSearchRequestDTO.Appointment appoint  = new AppointmentSearchRequestDTO.Appointment();
        AppointmentSearchRequestDTO.Place place  = new AppointmentSearchRequestDTO.Place();
        AppointmentSearchRequestDTO.Appointment appointmentData = new AppointmentSearchRequestDTO.Appointment();
        apptdata.transactionReferenceID = '43214'; 
        apptdata.bomID='554446';
        appointmentData.searchStartDate = '2018-09-10T08:00:00.0Z';
        appointmentData.searchEndDate = '2018-12-10T08:00:00.0Z';
        appointmentData.appointmentCategory ='TELSTRA';
        appointmentData.appointmentType = 'ORDER INSTALL';
        appointmentData.appointmentSubType = 'EXCHANGE';
        appointmentData.priority ='STANDARD';
        place.id = '123453253';
        place.type = 'ADBOR_ID';
        appointmentData.Place=place;
        apptdata.Appointment=appointmentData;
        apptDTO.data = apptdata;
        Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentSearchResponseDTO result = BOMAppointmentService.searchAppointment(apptDTO);
        system.debug('result=='+result);
        Test.stopTest();
        System.assertNotEquals(null,result);
    }
    
    @istest static void testAppointRebookQuerySuccessResponse(){
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
        csord__Order__c Testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.csord__Primary_Order__c= Testorder2.id;     
        update order;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        sub.Primary_Order__c = order.id;
        update sub;
        Appointment__c appt = new Appointment__c();
        appt.name ='a7M2O0000003Cui';
        appt.Category__c ='Telstra Installation';
        appt.StartDate__c = Datetime.now();
        appt.EndDate__c = DateTime.now();
        appt.Subscription__c = sub.id;
        appt.Notes__c ='test';
        appt.SlotId__c='TAP123';
        //appt.Status ='SCHEDULED';
        insert appt; 
        
        AppointmentBOMRebookSearchRequestDTO apptDTO = new AppointmentBOMRebookSearchRequestDTO();
        AppointmentBOMRebookSearchRequestDTO.data apptdata = new AppointmentBOMRebookSearchRequestDTO.data();
        AppointmentBOMRebookSearchRequestDTO.Reason reason  = new AppointmentBOMRebookSearchRequestDTO.Reason();
        AppointmentBOMRebookSearchRequestDTO.Appointment appointmentData = new AppointmentBOMRebookSearchRequestDTO.Appointment();
        apptdata.transactionReferenceID = '43214'; 
        appointmentData.searchStartDate = '2018-09-10T08:00:00.0Z';
        appointmentData.searchEndDate = '2018-12-10T08:00:00.0Z';
        appointmentData.appointmentCategory ='TELSTRA';
        appointmentData.priority ='STANDARD';
        reason.rebookReasonCode = '01';
        reason.note = 'Customer was not happy to open the cabinet at that time';
        apptdata.Reason=reason;
        apptdata.Appointment=appointmentData;
        apptDTO.data = apptdata;
        
        Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentSearchResponseDTO result = BOMAppointmentService.searchRebookAppointment(apptDTO,appt.id);
        system.debug('result=='+result);
        Test.stopTest();
        System.assertNotEquals(null,result);
    }
    
    @istest static void testAppointReschedulesQuerySuccessResponse(){
        
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
        csord__Order__c Testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.csord__Primary_Order__c= Testorder2.id;     
        update order;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        sub.Primary_Order__c = order.id;
        update sub;
        Appointment__c appt = new Appointment__c();
        appt.name ='a7M2O0000003Cui';
        appt.Category__c ='Telstra Installation';
        appt.StartDate__c = Datetime.now();
        appt.EndDate__c = DateTime.now();
        appt.Subscription__c = sub.id;
        appt.Notes__c ='test';
        appt.SlotId__c='TAP123';
        //appt.Status ='SCHEDULED';
        insert appt; 
        AppointmentSearchRequestDTO apptDTO = new AppointmentSearchRequestDTO();
        AppointmentSearchRequestDTO.data apptdata = new AppointmentSearchRequestDTO.data();
        //AppointmentSearchRequestDTO.Appointment appoint  = new AppointmentSearchRequestDTO.Appointment();
        AppointmentSearchRequestDTO.Place place  = new AppointmentSearchRequestDTO.Place();
        AppointmentSearchRequestDTO.Appointment appointmentData = new AppointmentSearchRequestDTO.Appointment();
        apptdata.transactionReferenceID = '43214'; 
        apptdata.bomID='554446';
        appointmentData.searchStartDate = '2018-09-10T08:00:00.0Z';
        appointmentData.searchEndDate = '2018-12-10T08:00:00.0Z';
        appointmentData.appointmentCategory ='TELSTRA';
        appointmentData.appointmentType = 'ORDER INSTALL';
        appointmentData.appointmentSubType = 'EXCHANGE';
        appointmentData.priority ='STANDARD';
        place.id = '123453253';
        place.type = 'ADBOR_ID';
        appointmentData.Place=place;
        apptdata.Appointment=appointmentData;
        apptDTO.data = apptdata;
        Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentSearchResponseDTO result = BOMAppointmentService.searchReschedAppointment(apptDTO,appt.id);
        system.debug('result=='+result);
        Test.stopTest();
        System.assertNotEquals(null,result);
    }
    
    @istest static void testAppointReschedulesSearchQuerySuccessResponse(){
        
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
        csord__Order__c Testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.csord__Primary_Order__c= Testorder2.id;     
        update order;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        sub.Primary_Order__c = order.id;
        update sub;
        Appointment__c appt = new Appointment__c();
        appt.name ='a7M2O0000003Cui';
        appt.Category__c ='Telstra Installation';
        appt.StartDate__c = Datetime.now();
        appt.EndDate__c = DateTime.now();
        appt.Subscription__c = sub.id;
        appt.Notes__c ='test';
        appt.SlotId__c='TAP123';
        //appt.Status ='SCHEDULED';
        insert appt; 
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        //AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        List<AppointmentBOMReserveRequestDTO.RelatedParty > relatedPartyList = null;
        AppointmentBOMReserveRequestDTO.RelatedParty relatedParty = new AppointmentBOMReserveRequestDTO.RelatedParty();
        AppointmentBOMReserveRequestDTO.Note note = new AppointmentBOMReserveRequestDTO.Note();
        
        //AppointmentBOMReserveRequestDTO.Customer acc = new AppointmentBOMReserveRequestDTO.Customer();
        //acc.name ='EDGE TEST CUSTOMER TEST';
        //acc.customerclass ='Sole Trader';
        
        List<AppointmentBOMReserveRequestDTO.Contacts> contcts = new List<AppointmentBOMReserveRequestDTO.Contacts>();
        AppointmentBOMReserveRequestDTO.Contacts contct = new AppointmentBOMReserveRequestDTO.Contacts();
        contct.fullName = 'Gary Legend';
        contct.phoneNumber ='0435435035';
        contct.role = 'Primary';
        contcts.add(contct);
        note.text ='Testing';
        appoint.Note =note;
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        appoint.contacts = contcts;
        //data.customer = acc;
        //data.ticketDetails = ticketdtl;
        //data.orderDetails = ordDetails;
        
        //data.taskItems = taskItems;
        reserveDTO.Data = data;
        Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentBOMReserveResponseDTO result = BOMAppointmentService.rescheduleAppointment(reserveDTO,appt.SlotId__c,appt.id);
        system.debug('result=='+result);
        Test.stopTest();
        System.assertNotEquals(null,result);
    }
    @istest static void testAppointRebookReserveSuccessResponse(){
        
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
        csord__Order__c Testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.csord__Primary_Order__c= Testorder2.id;     
        update order;
        
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Site__c =site.id;
        sub.Primary_Order__c = order.id;
        update sub;
        Appointment__c appt = new Appointment__c();
        appt.name ='a7M2O0000003Cui';
        appt.Category__c ='Telstra Installation';
        appt.StartDate__c = Datetime.now();
        appt.EndDate__c = DateTime.now();
        appt.Subscription__c = sub.id;
        appt.Notes__c ='test';
        appt.SlotId__c='TAP123';
        //appt.Status ='SCHEDULED';
        insert appt; 
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        List<AppointmentBOMReserveRequestDTO.RelatedParty > relatedPartyList = null;
        AppointmentBOMReserveRequestDTO.RelatedParty relatedParty = new AppointmentBOMReserveRequestDTO.RelatedParty();
        AppointmentBOMReserveRequestDTO.Note note = new AppointmentBOMReserveRequestDTO.Note();
        
        //AppointmentBOMReserveRequestDTO.Customer acc = new AppointmentBOMReserveRequestDTO.Customer();
        //acc.name ='EDGE TEST CUSTOMER TEST';
        //acc.customerclass ='Sole Trader';
        
        
        reserveDTO.Data = data;
        Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentBOMReserveResponseDTO result = BOMAppointmentService.rebookAppointment(reserveDTO,appt.SlotId__c,appt.id);
        system.debug('result=='+result);
        Test.stopTest();
        //System.assertNotEquals(null,result.data);
        System.assertEquals(null,result.data);
    }
    @istest static void testAppointQuerySuccessErrorResponse(){
        AppointmentSearchRequestDTO apptDTO = new AppointmentSearchRequestDTO();
        AppointmentSearchRequestDTO.data apptdata = new AppointmentSearchRequestDTO.data();
        //AppointmentSearchRequestDTO.Appointment appoint  = new AppointmentSearchRequestDTO.Appointment();
        AppointmentSearchRequestDTO.Place place  = new AppointmentSearchRequestDTO.Place();
        AppointmentSearchRequestDTO.Appointment appointmentData = new AppointmentSearchRequestDTO.Appointment();
        apptdata.transactionReferenceID = '43214'; 
        apptdata.bomID='554446';
        appointmentData.searchStartDate = '2018-09-10T08:00:00.0Z';
        appointmentData.searchEndDate = '2018-12-10T08:00:00.0Z';
        appointmentData.appointmentCategory ='TELSTRA';
        appointmentData.appointmentType = 'ORDER INSTALL';
        appointmentData.appointmentSubType = 'EXCHANGE';
        appointmentData.priority ='STANDARD';
        place.id = '123453253';
        place.type = 'ADBOR_ID';
        appointmentData.Place=place;
        apptdata.Appointment=appointmentData;
        apptDTO.data = apptdata;
        Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(400, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentSearchResponseDTO result = BOMAppointmentService.searchAppointment(apptDTO);
        Test.stopTest();
        System.assertEquals(null,result.data);
    }
    
    
    
    
    public static AppointmentBOMReserveRequestDTO.Data getReserveRequestDTO(){
        
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        //AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        AppointmentBOMReserveRequestDTO.Appointment appoint = new AppointmentBOMReserveRequestDTO.Appointment();
        List<AppointmentBOMReserveRequestDTO.RelatedParty > relatedPartyList = null;
        AppointmentBOMReserveRequestDTO.RelatedParty relatedParty = new AppointmentBOMReserveRequestDTO.RelatedParty();
        AppointmentBOMReserveRequestDTO.Note note = new AppointmentBOMReserveRequestDTO.Note();
        
        //AppointmentBOMReserveRequestDTO.Customer acc = new AppointmentBOMReserveRequestDTO.Customer();
        //acc.name ='EDGE TEST CUSTOMER TEST';
        //acc.customerclass ='Sole Trader';
        
        List<AppointmentBOMReserveRequestDTO.Contacts> contcts = new List<AppointmentBOMReserveRequestDTO.Contacts>();
        AppointmentBOMReserveRequestDTO.Contacts contct = new AppointmentBOMReserveRequestDTO.Contacts();
        contct.fullName = 'Gary Legend';
        contct.phoneNumber ='0435435035';
        contct.role = 'Primary';
        contcts.add(contct);
        note.text ='Testing';
        appoint.Note =note;
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        appoint.contacts = contcts;
        //data.customer = acc;
        //data.ticketDetails = ticketdtl;
        //data.orderDetails = ordDetails;
        
        //data.taskItems = taskItems;
        reserveDTO.Data = data;
        return data;
    }
    
    @istest static void testAppointReserveSuccessResponse(){
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = getReserveRequestDTO();
        String slotId = 'S-200';
        reserveDTO.data = data;
        Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(200, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentBOMReserveResponseDTO result = BOMAppointmentService.reserveAppointment(reserveDTO, slotId);
        //system.debug('result=='+result.getBody());
        Test.stopTest();
        System.assertNotEquals(null,slotId);
    }
    
    @istest static void testAppointReserveError400Response(){
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = new AppointmentBOMReserveRequestDTO.Data();
        String slotId = 'S-400';
        reserveDTO.data = data;
        Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(400, 'ERROR', null, new Map<String, String>()));
        Test.startTest();
        AppointmentBOMReserveResponseDTO result = BOMAppointmentService.reserveAppointment(reserveDTO, slotId);
        // system.debug('result=='+result.getBody());
        Test.stopTest();
        System.assertNotEquals(null,slotId);
    }
    
    @istest static void testAppointReserveError422Response(){
        AppointmentBOMReserveRequestDTO reserveDTO = new AppointmentBOMReserveRequestDTO();
        AppointmentBOMReserveRequestDTO.Data data = getReserveRequestDTO();
        String slotId = 'S-422';
        reserveDTO.data = data;
        Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(422, 'ERROR', null, new Map<String, String>()));
        Test.startTest();
        AppointmentBOMReserveResponseDTO result= BOMAppointmentService.reserveAppointment(reserveDTO, slotId);
        //system.debug('result=='+result.getBody());
        Test.stopTest();
        System.assertNotEquals(null,slotId);
    }
}