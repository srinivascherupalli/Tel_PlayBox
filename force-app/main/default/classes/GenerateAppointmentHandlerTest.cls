/* Description: Test class that cover appointment Bom Functionality 
    */
    @isTest
    public class GenerateAppointmentHandlerTest {
        
        @istest
        public static void generateAppointmentTest(){
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
            csord__Order__c testOrder2=ProductTestService.getNewOrderForAccount(acc);
            order.csord__Primary_Order__c= testOrder2.id;     
            update order;
            csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
            sub.Site__c =site.id;
            sub.Primary_Order__c = order.id;
            update sub;
            Contact cntct1 = new Contact();
            cntct1.LastName = 'Primary';
            cntct1.Phone = '111222';
            insert cntct1;
            Contact cntct2 = new Contact();
            cntct2.LastName = 'Secondary';
            cntct2.Phone = '22223333';
            insert cntct2;
            Contact cntct3 = new Contact();
            cntct3.LastName = 'Site';
            cntct3.Phone = '33334444';
            insert cntct3;
            
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csord__Subscription__c  = sub.id;
            serv.csord__Order__c = order.id;
            serv.csordtelcoa__Service_Number__c = '3';
            serv.Primary_Contact__c = cntct1.Id;
            serv.Technical_Contact__c = cntct1.Id;
            serv.Project_Contact__c = cntct1.Id;
            insert serv;
            
            Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
            
            fcRole1.Role__c = 'Primary Site Contact';
            fcRole2.Role__c = 'Technical Contact';
            fcRole3.Role__c = 'Project Contact';
            
            fcRole1.ContactID__c = cntct1.id;
            fcRole2.ContactID__c = cntct2.id;
            fcRole3.ContactID__c = cntct3.id;
            
            fcRole1.SiteID__c = site.id;
            fcRole2.SiteID__c = site.id;
            fcRole3.SiteID__c = site.id;
            insert fcRole1;
            insert fcRole2;
            insert fcRole3;
            
            
            
            Required_Appointment__c reqAppoint = new Required_Appointment__c();
            reqAppoint.name = 'RequireTestRecord';
            reqAppoint.Appointment_BOM_ID__c ='34532443';
            reqAppoint.Appointment_Category__c='TELSTRA';
            //reqAppoint.createdDate =system.today();
            reqAppoint.Appointment_Type__c='ORDER INSTALL';
            reqAppoint.Appointment_SubType__c='EXCHANGE';
            insert reqAppoint;
            reqAppoint.Generate_Appointment_Order__c=order.id;
            reqAppoint.Generate_Appointment_Subscription__c=sub.id;
            update reqAppoint;
            system.debug('Required Appointment --->>>>'+reqAppoint);
            Date fromDate=date.valueOf('2019-04-10T00:05:00');
            
            
             PageReference pageRef = new PageReference('apex/GenerateAppointmentPage?id=' + sub.id +'&operation=Generate+Appointment'+ '&fromDate=' + fromDate + '&Category=' +reqAppoint.Appointment_Category__c);
             Test.setCurrentPage(pageRef);
            GenerateAppointmentHandler genAppo=new GenerateAppointmentHandler();
            genAppo.appointmentOperation='Schedule';
            genAppo.popupTitle='Booking Successful';
            
            
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
            BOMAppointmentService.searchAppointment(apptDTO);
            
            
            
            
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
            
            
            
            Appointment__c appt = new Appointment__c();
            appt.name ='a7M2O0000003Cui';
            appt.SlotId__c ='343532';
            appt.Category__c ='Telstra Installation';
            appt.StartDate__c = Datetime.now();
            appt.EndDate__c = DateTime.now();
            appt.Subscription__c = sub.id;
            appt.Notes__c ='test';
            //appt.SlotId__c='TAP123';
            //appt.Status ='SCHEDULED';
            insert appt; 
            
            Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
            
            Test.startTest();
            genAppo.searchAppointments();
            genAppo.populateSlotWrapper(appointDTO);
            genAppo.populateContactForReserveAppointmentAPV2(sub.id);
            genAppo.setSlotId();
            genAppo.switchOfTimerApex();
            genAppo.clearBottomSection();
            genAppo.setSlotId();
            genAppo.updateAppointmentRecord();
            genAppo.getAppoinmentDetails(sub.id);
            
            genAppo.confirmAppointment();
            genAppo.reserveAppointment('343532',sub.id,'test');
            //  genAppo.getAppStartEndTime('343532');
            genAppo.createAppointmentRecord('343532','TELSTRA',sub.id,'343532','schedule');
            genAppo.loadRescheduleReasonList();
            Test.stopTest();
            
            System.assertNotEquals(site, NULL);
        }
        
        /*------------------------------------------------------------ 
    //EDGE-66449, 66475
    Method: rebookAppointment 
    Description: Rebook Appointment BOM
    <02-05-2019> <Jawahar> <Ila>
    ------------------------------------------------------------*/
        
        @istest
        public static void generateAppointmentTestRebook(){
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
            csord__Order__c testOrder2=ProductTestService.getNewOrderForAccount(acc);
            order.csord__Primary_Order__c= testOrder2.id;     
            update order;
            csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
            sub.Site__c =site.id;
            sub.Primary_Order__c = order.id;
            update sub;
            Contact cntct1 = new Contact();
            cntct1.LastName = 'Primary';
            cntct1.Phone = '111222';
            insert cntct1;
            Contact cntct2 = new Contact();
            cntct2.LastName = 'Secondary';
            cntct2.Phone = '22223333';
            insert cntct2;
            Contact cntct3 = new Contact();
            cntct3.LastName = 'Site';
            cntct3.Phone = '33334444';
            insert cntct3;
            
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csord__Subscription__c  = sub.id;
            serv.csord__Order__c = order.id;
            serv.csordtelcoa__Service_Number__c = '3';
            serv.Primary_Contact__c = cntct1.Id;
            serv.Technical_Contact__c = cntct1.Id;
            serv.Project_Contact__c = cntct1.Id;
            insert serv;
            
            Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
            
            fcRole1.Role__c = 'Primary Site Contact';
            fcRole2.Role__c = 'Technical Contact';
            fcRole3.Role__c = 'Project Contact';
            
            fcRole1.ContactID__c = cntct1.id;
            fcRole2.ContactID__c = cntct2.id;
            fcRole3.ContactID__c = cntct3.id;
            
            fcRole1.SiteID__c = site.id;
            fcRole2.SiteID__c = site.id;
            fcRole3.SiteID__c = site.id;
            insert fcRole1;
            insert fcRole2;
            insert fcRole3;
            
            
            
            Required_Appointment__c reqAppoint = new Required_Appointment__c();
            reqAppoint.name = 'RequireTestRecord';
            reqAppoint.Appointment_BOM_ID__c ='34532443';
            reqAppoint.Appointment_Category__c='TELSTRA';
            //reqAppoint.createdDate =system.today();
            reqAppoint.Appointment_Type__c='ORDER INSTALL';
            reqAppoint.Appointment_SubType__c='EXCHANGE';
            insert reqAppoint;
            reqAppoint.Generate_Appointment_Order__c=order.id;
            reqAppoint.Generate_Appointment_Subscription__c=sub.id;
            update reqAppoint;
            system.debug('Required Appointment --->>>>'+reqAppoint);
            Date fromDate=date.valueOf('2019-04-10T00:05:00');
            
            
            
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
            
             PageReference pageRef = new PageReference('apex/GenerateAppointmentPage?id=' + sub.id + '&ApptId=' + appt.SlotId__c + '&Category='+ reqAppoint.Appointment_Category__c + '&operation=FollowOn');
             Test.setCurrentPage(pageRef);
            GenerateAppointmentHandler genAppo=new GenerateAppointmentHandler();
            genAppo.appointmentOperation='FollowOn';
            genAppo.popupTitle='Booking Successful';
            
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
            BOMAppointmentService.searchRebookAppointment(apptDTO,appt.id);
            
            
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
            appointData.CauseEvent = cause;
            
            appointDTO.Data = appointData;
            
            
            Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
            
            Test.startTest();
            genAppo.searchAppointments();
            genAppo.populateSlotWrapper(appointDTO);
            genAppo.populateContactForReserveAppointmentAPV2(sub.id);
            genAppo.setSlotId();
            genAppo.switchOfTimerApex();
            genAppo.clearBottomSection();
            genAppo.setSlotId();
            //genAppo.updateAppointmentRecord();
            genAppo.getAppoinmentDetails(sub.id);
            
            genAppo.confirmAppointment();
            genAppo.reserveAppointment('343532',sub.id,'test');
            //  genAppo.getAppStartEndTime('343532');
            genAppo.createAppointmentRecord('343532','TELSTRA',sub.id,'343532','schedule');
            genAppo.updateParentApptStatus(appt);
            
            Test.stopTest();
            
            System.assertNotEquals(site, NULL);
            
        }
        //Reschedule 
        @istest
        public static void generateAppointmentTestReschedule(){
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
            csord__Order__c testOrder2=ProductTestService.getNewOrderForAccount(acc);
            order.csord__Primary_Order__c= testOrder2.id;     
            update order;
            csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
            sub.Site__c =site.id;
            sub.Primary_Order__c = order.id;
            update sub;
            Contact cntct1 = new Contact();
            cntct1.LastName = 'Primary';
            cntct1.Phone = '111222';
            insert cntct1;
            Contact cntct2 = new Contact();
            cntct2.LastName = 'Secondary';
            cntct2.Phone = '22223333';
            insert cntct2;
            Contact cntct3 = new Contact();
            cntct3.LastName = 'Site';
            cntct3.Phone = '33334444';
            insert cntct3;
            
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csord__Subscription__c  = sub.id;
            serv.csord__Order__c = order.id;
            serv.csordtelcoa__Service_Number__c = '3';
            serv.Primary_Contact__c = cntct1.Id;
            serv.Technical_Contact__c = cntct1.Id;
            serv.Project_Contact__c = cntct1.Id;
            insert serv;
            
            Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
            
            fcRole1.Role__c = 'Primary Site Contact';
            fcRole2.Role__c = 'Technical Contact';
            fcRole3.Role__c = 'Project Contact';
            
            fcRole1.ContactID__c = cntct1.id;
            fcRole2.ContactID__c = cntct2.id;
            fcRole3.ContactID__c = cntct3.id;
            
            fcRole1.SiteID__c = site.id;
            fcRole2.SiteID__c = site.id;
            fcRole3.SiteID__c = site.id;
            insert fcRole1;
            insert fcRole2;
            insert fcRole3;
            
            
            
            Required_Appointment__c reqAppoint = new Required_Appointment__c();
            reqAppoint.name = 'RequireTestRecord';
            reqAppoint.Appointment_BOM_ID__c ='34532443';
            reqAppoint.Appointment_Category__c='TELSTRA';
            //reqAppoint.createdDate =system.today();
            reqAppoint.Appointment_Type__c='ORDER INSTALL';
            reqAppoint.Appointment_SubType__c='EXCHANGE';
            insert reqAppoint;
            reqAppoint.Generate_Appointment_Order__c=order.id;
            reqAppoint.Generate_Appointment_Subscription__c=sub.id;
            update reqAppoint;
            system.debug('Required Appointment --->>>>'+reqAppoint);
            Date fromDate=date.valueOf('2019-04-10T00:05:00');
            
            
            
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
            
            PageReference pageRef = new PageReference('apex/GenerateAppointmentPage?id=' + sub.id + '&ApptId=' + appt.SlotId__c + '&Category=' +reqAppoint.Appointment_Category__c + '&operation=Reschedule');
            Test.setCurrentPage(pageRef);
            GenerateAppointmentHandler genAppo=new GenerateAppointmentHandler();
            genAppo.appointmentOperation='Reschedule';
            genAppo.popupTitle='Booking Successful';
            
            AppointmentSearchRequestDTO apptDTO = new AppointmentSearchRequestDTO();
            AppointmentSearchRequestDTO.data apptdata = new AppointmentSearchRequestDTO.data();
            AppointmentSearchRequestDTO.Reason reason  = new AppointmentSearchRequestDTO.Reason();
            AppointmentSearchRequestDTO.Appointment appointmentData = new AppointmentSearchRequestDTO.Appointment();
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
            BOMAppointmentService.searchReschedAppointment(apptDTO,appt.id);
            
            
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
            appointData.CauseEvent = cause;
            
            appointDTO.Data = appointData;
            
            
            Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
            
            Test.startTest();
            genAppo.searchAppointments();
            genAppo.populateSlotWrapper(appointDTO);
            genAppo.populateContactForReserveAppointmentAPV2(sub.id);
            genAppo.setSlotId();
            genAppo.switchOfTimerApex();
            genAppo.clearBottomSection();
            genAppo.setSlotId();
            //genAppo.updateAppointmentRecord();
            genAppo.getAppoinmentDetails(sub.id);
            
            genAppo.confirmAppointment();
            genAppo.reserveAppointment('343532',sub.id,'test');
            //  genAppo.getAppStartEndTime('343532');
            genAppo.createAppointmentRecord('343532','TELSTRA',sub.id,'343532','schedule');
            Test.stopTest();
            
            System.assertNotEquals(site, NULL);
            
        }
        @istest
        public static void generateNBNAppointmentTest(){
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
            
            
            //ServiceQualification
            Service_Qualification__c sq = new Service_Qualification__c();
            sq.name = 'Test';
            sq.Site__c =site.id;
            sq.Location_ID__c = 'LOC343242';
            insert sq;
            
            //order
            csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
            csord__Order__c testOrder2=ProductTestService.getNewOrderForAccount(acc);
            order.csord__Primary_Order__c= testOrder2.id;     
            update order;
            csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
            sub.Site__c =site.id;
            sub.Primary_Order__c = order.id;
            update sub;
            Contact cntct1 = new Contact();
            cntct1.LastName = 'Primary';
            cntct1.Phone = '111222';
            insert cntct1;
            Contact cntct2 = new Contact();
            cntct2.LastName = 'Secondary';
            cntct2.Phone = '22223333';
            insert cntct2;
            Contact cntct3 = new Contact();
            cntct3.LastName = 'Site';
            cntct3.Phone = '33334444';
            insert cntct3;
            
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csord__Subscription__c  = sub.id;
            serv.csord__Order__c = order.id;
            serv.csordtelcoa__Service_Number__c = '3';
            serv.Primary_Contact__c = cntct1.Id;
            serv.Technical_Contact__c = cntct1.Id;
            serv.Project_Contact__c = cntct1.Id;
            insert serv;
            
            Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
            
            fcRole1.Role__c = 'Primary Site Contact';
            fcRole2.Role__c = 'Technical Contact';
            fcRole3.Role__c = 'Project Contact';
            
            fcRole1.ContactID__c = cntct1.id;
            fcRole2.ContactID__c = cntct2.id;
            fcRole3.ContactID__c = cntct3.id;
            
            fcRole1.SiteID__c = site.id;
            fcRole2.SiteID__c = site.id;
            fcRole3.SiteID__c = site.id;
            insert fcRole1;
            insert fcRole2;
            insert fcRole3;
            
            
            
            Required_Appointment__c reqAppoint = new Required_Appointment__c();
            reqAppoint.name = 'RequireTestRecord';
            reqAppoint.Appointment_BOM_ID__c ='34532443';
            reqAppoint.Appointment_Category__c='NBN';
            //reqAppoint.createdDate =system.today();
            reqAppoint.Appointment_Type__c='ORDER INSTALL';
            reqAppoint.Appointment_SubType__c='EXCHANGE';
            insert reqAppoint;
            reqAppoint.Generate_Appointment_Order__c=order.id;
            reqAppoint.Generate_Appointment_Subscription__c=sub.id;
            update reqAppoint;
            system.debug('Required Appointment --->>>>'+reqAppoint);
            // String fromDate = '10-04-2019T00:05:00'; 
            Date fromDate=date.valueOf('2019-04-10T00:05:00');
            PageReference pageRef = new PageReference('apex/GenerateAppointmentPage?id=' + sub.id +'&operation=Generate+Appointment'+ '&fromDate=' + fromDate +'&Category=' +reqAppoint.Appointment_Category__c);
            Test.setCurrentPage(pageRef);
            GenerateAppointmentHandler genAppo=new GenerateAppointmentHandler();
            genAppo.appointmentOperation='Schedule';
            genAppo.popupTitle='Booking Successful';
            
            
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
            BOMAppointmentService.searchAppointment(apptDTO);
            
            
            
            
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
            
            
            
            Appointment__c appt = new Appointment__c();
            appt.name ='a7M2O0000003Cui';
            appt.SlotId__c ='343532';
            appt.Category__c ='Telstra Installation';
            appt.StartDate__c = Datetime.now();
            appt.EndDate__c = DateTime.now();
            appt.Subscription__c = sub.id;
            appt.Notes__c ='test';
            //appt.SlotId__c='TAP123';
            //appt.Status ='SCHEDULED';
            insert appt; 
            
            Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
            
            Test.startTest();
            genAppo.searchAppointments();
            genAppo.populateSlotWrapper(appointDTO);
            genAppo.populateContactForReserveAppointmentAPV2(sub.id);
            genAppo.setSlotId();
            genAppo.switchOfTimerApex();
            genAppo.clearBottomSection();
            genAppo.setSlotId();
            //genAppo.updateAppointmentRecord();
            genAppo.getAppoinmentDetails(sub.id);
            
            genAppo.confirmAppointment();
            genAppo.reserveAppointment('343532',sub.id,'test');
            //  genAppo.getAppStartEndTime('343532');
            genAppo.createAppointmentRecord('343532','TELSTRA',sub.id,'343532','schedule');
            Test.stopTest();
            
            System.assertNotEquals(site, NULL);
        }
        
        //EDGE-66238: Resserves the slot for appointment   
        @istest
        public static void reserveAppointmentTest(){
            Account acc = AccountTestFactory.buildAccount('TestAccount');
            insert acc;
            csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
            Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
            insert appt;
            
            csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
            csord__Order__c testOrder2=ProductTestService.getNewOrderForAccount(acc);
            order.csord__Primary_Order__c= testOrder2.id;     
            update order;
            
            Required_Appointment__c reqAppoint = new Required_Appointment__c();
            reqAppoint.name = 'RequireTestRecord';
            reqAppoint.Appointment_BOM_ID__c ='34532443';
            reqAppoint.Appointment_Category__c='NBN';
            //reqAppoint.createdDate =system.today();
            reqAppoint.Appointment_Type__c='ORDER INSTALL';
            reqAppoint.Appointment_SubType__c='EXCHANGE';
            insert reqAppoint;
            reqAppoint.Generate_Appointment_Order__c=order.id;
            reqAppoint.Generate_Appointment_Subscription__c=sub.id;
            update reqAppoint;
            Date fromDate=date.valueOf('2019-04-10T00:05:00');
            PageReference pageRef = new PageReference('apex/GenerateAppointmentPage?id='+sub.id+'&operation=Reschedule');
            Test.setCurrentPage(pageRef);
             PageReference pageRef1 = new PageReference('apex/GenerateAppointmentPage?id=' + sub.id +'&operation=Generate+Appointment'+ '&fromDate=' + fromDate +'&Category=' +reqAppoint.Appointment_Category__c);
             Test.setCurrentPage(pageRef1);
            GenerateAppointmentHandler appBpage = new GenerateAppointmentHandler();
            //appBpage.secondaryConstructor(String.valueOf(sub.id));
            appBpage.appointmentOperation='Schedule';
            appBpage.fromDate=System.today();
            appBpage.todate=System.today();
            //appBpage.selectedname=NULL;
            //appBpage.detailList=NUll;
            appBpage.notes='Test Notes';
            appBpage.causeEventReason=NULL;
            appBpage.isCauseEvent = false;
            appBpage.appDetails=NULL;
            appBpage.appointmentId='123456';
            appBpage.popupTitle='Title';
            //appBpage.getCategories();
            
            
            Attachment attach=new Attachment();      
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=sub.id;
            insert attach;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
            appBpage.switchOfTimerApex();
            appBpage.confirmAppointment();
            appBpage.createAppointmentRecord('343532','TELSTRA',sub.id,'343532','schedule');
            
            Test.stopTest();
            
            CPEDeliveryDateHelper.AddBusinessDays(Date.Today(), 5);
            System.assertEquals(true,pageRef!=NULL);
        }
        
        //EDGE - 75002, Test method for Creating tasks for the appointment that is generated.
        @istest
        public static void createTaskRecordsTest(){
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
            csord__Order__c order=ProductTestService.getNewOrderForAccount(acc); //secondary order
            csord__Order__c testOrder2=ProductTestService.getNewOrderForAccount(acc); 
            order.csord__Primary_Order__c= testOrder2.id;     
            update order;
            csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
            sub.Site__c =site.id;
            sub.csord__Order__c = order.id;
            update sub;
            Contact cntct1 = new Contact();
            cntct1.LastName = 'Primary';
            cntct1.Phone = '1112221';
            insert cntct1;
            Contact cntct2 = new Contact();
            cntct2.LastName = 'Secondary';
            cntct2.Phone = '222233331';
            insert cntct2;
            Contact cntct3 = new Contact();
            cntct3.LastName = 'Site';
            cntct3.Phone = '333344441';
            insert cntct3;
            
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csord__Subscription__c  = sub.id;
            serv.csord__Order__c = order.id;
            serv.csordtelcoa__Service_Number__c = '3';
            serv.Primary_Contact__c = cntct1.Id;
            serv.Technical_Contact__c = cntct1.Id;
            serv.Project_Contact__c = cntct1.Id;
            insert serv;
            
            Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
            
            fcRole1.Role__c = 'Primary Site Contact';
            fcRole2.Role__c = 'Technical Contact';
            fcRole3.Role__c = 'Project Contact';
            
            fcRole1.ContactID__c = cntct1.id;
            fcRole2.ContactID__c = cntct2.id;
            fcRole3.ContactID__c = cntct3.id;
            
            fcRole1.SiteID__c = site.id;
            fcRole2.SiteID__c = site.id;
            fcRole3.SiteID__c = site.id;
            insert fcRole1;
            insert fcRole2;
            insert fcRole3;
            
            Required_Appointment__c reqAppoint = new Required_Appointment__c();
            reqAppoint.name = 'RequireTestRecord';
            reqAppoint.Appointment_BOM_ID__c ='34532443';
            reqAppoint.Appointment_Category__c='TELSTRA';
            //reqAppoint.createdDate =system.today();
            reqAppoint.Appointment_Type__c='ORDER INSTALL';
            reqAppoint.Appointment_SubType__c='EXCHANGE';
            insert reqAppoint;
            reqAppoint.Generate_Appointment_Order__c=testOrder2.id;
            reqAppoint.Generate_Appointment_Subscription__c=sub.id;
            reqAppoint.baseRuleProducts__c = '[{"productInstanceID":"397949fd-test-f459-b34f-4bcdb7d5b5c1","productID":"DMCAT_ProductSpecification_000073"}]';
            update reqAppoint;
            system.debug('Required Appointment --->>>>'+reqAppoint);
            Date fromDate=date.valueOf('2019-04-10T00:05:00');
            Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
            insert appt;
            
             PageReference pageRef = new PageReference('apex/GenerateAppointmentPage?id=' + sub.id +'&operation=Generate+Appointment'+ '&fromDate=' + fromDate + '&Category=' +reqAppoint.Appointment_Category__c);
             Test.setCurrentPage(pageRef);
            GenerateAppointmentHandler handler = new GenerateAppointmentHandler();
            handler.createTaskRecords(appt.id);
                        System.assertNotEquals(site, NULL);

        }
        /*------------------------------------------------------------ 
    //EDGE -66470
    Method: rescheduleAppointment 
    Description: Initiate Appointment BOM API
    History 
    <26-04-2019> <Kalashree Borgaonkar>
    ------------------------------------------------------------*/
        @isTest
        public static void testRescheduleAppointment(){
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
            csord__Order__c order=ProductTestService.getNewOrderForAccount(acc); //secondary order
            csord__Order__c testOrder2=ProductTestService.getNewOrderForAccount(acc); 
            order.csord__Primary_Order__c= testOrder2.id;     
            update order;
            csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
            sub.Site__c =site.id;
            sub.csord__Order__c = order.id;
            update sub;
            Contact cntct1 = new Contact();
            cntct1.LastName = 'Primary';
            cntct1.Phone = '1112221';
            insert cntct1;
            Contact cntct2 = new Contact();
            cntct2.LastName = 'Secondary';
            cntct2.Phone = '222233331';
            insert cntct2;
            Contact cntct3 = new Contact();
            cntct3.LastName = 'Site';
            cntct3.Phone = '333344441';
            insert cntct3;
            
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csord__Subscription__c  = sub.id;
            serv.csord__Order__c = order.id;
            serv.csordtelcoa__Service_Number__c = '3';
            serv.Primary_Contact__c = cntct1.Id;
            serv.Technical_Contact__c = cntct1.Id;
            serv.Project_Contact__c = cntct1.Id;
            insert serv;
            
            Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
            Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
            
            fcRole1.Role__c = 'Primary Site Contact';
            fcRole2.Role__c = 'Technical Contact';
            fcRole3.Role__c = 'Project Contact';
            
            fcRole1.ContactID__c = cntct1.id;
            fcRole2.ContactID__c = cntct2.id;
            fcRole3.ContactID__c = cntct3.id;
            
            fcRole1.SiteID__c = site.id;
            fcRole2.SiteID__c = site.id;
            fcRole3.SiteID__c = site.id;
            insert fcRole1;
            insert fcRole2;
            insert fcRole3;
            
            Required_Appointment__c reqAppoint = new Required_Appointment__c();
            reqAppoint.name = 'RequireTestRecord';
            reqAppoint.Appointment_BOM_ID__c ='34532443';
            reqAppoint.Appointment_Category__c='TELSTRA';
            //reqAppoint.createdDate =system.today();
            reqAppoint.Appointment_Type__c='ORDER INSTALL';
            reqAppoint.Appointment_SubType__c='EXCHANGE';
            insert reqAppoint;
            reqAppoint.Generate_Appointment_Order__c=testOrder2.id;
            reqAppoint.Generate_Appointment_Subscription__c=sub.id;
            reqAppoint.baseRuleProducts__c = '[{"productInstanceID":"397949fd-test-f459-b34f-4bcdb7d5b5c1","productID":"DMCAT_ProductSpecification_000073"}]';
            update reqAppoint;
            system.debug('Required Appointment --->>>>'+reqAppoint);
            Date fromDate=date.valueOf('2019-04-10T00:05:00');
            Appointment__c appt= new Appointment__c(SlotId__c='12345',Category__c='Test',Subscription__c=sub.id,StartDate__c=System.today(),EndDate__c=System.today());
            insert appt;
            
            
            PageReference pageRef = new PageReference('apex/GenerateAppointmentPage?id=' + sub.id + '&ApptId=' + appt.SlotId__c + '&Category= Telstra Installation' + '&operation=Reschedule');
            Test.setCurrentPage(pageRef);
            GenerateAppointmentHandler genAppo=new GenerateAppointmentHandler();
            genAppo.appointmentOperation='Reschedule';
            genAppo.popupTitle='Booking Successful';
            AppointmentSearchRequestDTO apptDTO = new AppointmentSearchRequestDTO();
            AppointmentSearchRequestDTO.data apptdata = new AppointmentSearchRequestDTO.data();
            AppointmentSearchRequestDTO.Reason reason  = new AppointmentSearchRequestDTO.Reason();
            AppointmentSearchRequestDTO.Appointment appointmentData = new AppointmentSearchRequestDTO.Appointment();
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
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
            genAppo.switchOfTimerApex();
            genAppo.confirmAppointment();
            genAppo.detailsList=BOMAppointmentService.searchReschedAppointment(apptDTO,appt.id);
            
            genAppo.rescheduleAppointment('343532',sub.id,'test');
            genAppo.rebookAppointment('343532',sub.id,'test');
            Test.stopTest();
            System.assertNotEquals(site, NULL);

        }
    }