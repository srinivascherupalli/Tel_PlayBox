@isTest
public class EWOMAppointmentManagerTest {          
   @testsetup
   public static void dataSetup(){
       Environment_Configurations__c ec = new Environment_Configurations__c(Custom_Logging__c = true);
       insert ec;
       EnvironmentVariable.put('access_token', '1234');
       EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6/avaliable-slots');
       EnvironmentVariable.put('okapi_east_url', '/?');
       EnvironmentVariable.put('okapi_client_id', '1234');
       EnvironmentVariable.put('okapi_client_secret', '1234');
       EnvironmentVariable.put('okapi_token_url', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
    }
   
   @isTest static void testGetInstance()
   {
       EWOMAppointmentManager.getInstance();
       system.assertNotEquals(null,EWOMAppointmentManager.getInstance());
   }
 
   @istest static void testAppointQuerySuccessResponse(){
       AppointmentSlotRequestDTO apptDTO = new AppointmentSlotRequestDTO();
       AppointmentSlotRequestDTO.data apptdata = new AppointmentSlotRequestDTO.data();
           apptdata.startDate = '2018-09-10T08:00:00.0Z';
            apptdata.endDate = '2018-12-10T08:00:00.0Z';
       AppointmentSlotRequestDTO.SlotSiteAddress siteAddr = new AppointmentSlotRequestDTO.SlotSiteAddress();
           siteAddr.id = '12345'; 
            //siteAddr.type= AppointmentSlotRequestDTO.Types.Preferred;
       List<AppointmentSlotRequestDTO.SlotTask> taskList = new List<AppointmentSlotRequestDTO.SlotTask>();
       AppointmentSlotRequestDTO.SlotTask task = new AppointmentSlotRequestDTO.SlotTask();
           task.extTaskReferenceId = '1234567';
           //task.visitType = AppointmentSlotRequestDTO.VisitTypes.CP;
            //task.serviceType = 'Blogg';
            //task.purpose = 'Company';
       AppointmentSlotRequestDTO.JobItem jobitems = new AppointmentSlotRequestDTO.JobItem();
            //jobitems.extJobReferenceId = '1234567';
            jobitems.technology = 'Joe';
            jobitems.resourceType = 'Blogg';
            jobitems.action = 'Company';
            jobitems.description = 'testing';
            //jobitems.visitType=AppointmentSlotRequestDTO.VisitTypes.CP;
            //jobitems.serviceType= 'yes';
      list< AppointmentSlotRequestDTO.JobItem> item =   new list< AppointmentSlotRequestDTO.JobItem>();
            item.add(jobitems);
            task.jobItems = item;
       //AppointmentSlotRequestDTO.Technician tech = new AppointmentSlotRequestDTO.Technician();
           //tech.type= 'Joe';
           //tech.id = 'Blogg';
        apptdata.address =siteAddr;
       taskList.add(task);
        apptdata.taskItems=taskList;
        //apptdata.technician =tech;
        apptDTO.data = apptdata;
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
       AppointmentSlotResponseDTO result = EWOMAppointmentManager.searchAppointment(apptDTO);
       system.debug('result=='+result);
       Test.stopTest();
       System.assertNotEquals(null,result.data.availableSlots);
   }
    
    @istest static void testAppointQuerySuccessErrorResponse(){
       AppointmentSlotRequestDTO apptDTO = new AppointmentSlotRequestDTO();
       AppointmentSlotRequestDTO.data apptdata = new AppointmentSlotRequestDTO.data();
           apptdata.startDate = '2018-09-10T08:00:00.0Z';
            apptdata.endDate = '2018-12-10T08:00:00.0Z';
       AppointmentSlotRequestDTO.SlotSiteAddress siteAddr = new AppointmentSlotRequestDTO.SlotSiteAddress();
           siteAddr.id = '12345'; 
            //siteAddr.type= AppointmentSlotRequestDTO.Types.Preferred;
        List<AppointmentSlotRequestDTO.SlotTask> taskList = new List<AppointmentSlotRequestDTO.SlotTask>();
       AppointmentSlotRequestDTO.SlotTask task = new AppointmentSlotRequestDTO.SlotTask();
           task.extTaskReferenceId = '1234567';
           //task.visitType =AppointmentSlotRequestDTO.VisitTypes.CP;
            //task.serviceType = 'Blogg';
           // task.purpose = 'Company';
       AppointmentSlotRequestDTO.JobItem jobitems = new AppointmentSlotRequestDTO.JobItem();
            //jobitems.extJobReferenceId = '1234567';
            jobitems.technology = 'Joe';
            jobitems.resourceType = 'Blogg';
            jobitems.action = 'Company';
            jobitems.description = 'testing';
           // jobitems.visitType= AppointmentSlotRequestDTO.VisitTypes.CP;
            //jobitems.serviceType= 'yes';
      list< AppointmentSlotRequestDTO.JobItem> item =   new list< AppointmentSlotRequestDTO.JobItem>();
            item.add(jobitems);
            task.jobItems = item;
     // AppointmentSlotRequestDTO.Technician tech = new AppointmentSlotRequestDTO.Technician();
           //tech.type= 'Joe';
           //tech.id = 'Blogg';
        apptdata.address =siteAddr; 
        taskList.add(task);
        apptdata.taskItems=taskList;
        //apptdata.technician =tech;
        apptDTO.data = apptdata;
       Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(400, 'OK', null, new Map<String, String>()));
       Test.startTest();
       AppointmentSlotResponseDTO result = EWOMAppointmentManager.searchAppointment(apptDTO);
       Test.stopTest();
       System.assertEquals(null,result.data);
   }

   public static AppointmentReserveRequestDTO.Data getReserveRequestDTO(){

    /*List<AppointmentReserveRequestDTO.Characterstics> charsList = new List<AppointmentReserveRequestDTO.Characterstics>();
    AppointmentReserveRequestDTO.Characterstics chars = new AppointmentReserveRequestDTO.Characterstics();
    chars.name = 'ManagementServiceHours';
    chars.value = '24x7';
    chars.action ='Disconnect';
    charsList.add(chars);

    List<AppointmentReserveRequestDTO.ProductCharacteristics> prodChars = new List<AppointmentReserveRequestDTO.ProductCharacteristics>();
    AppointmentReserveRequestDTO.ProductCharacteristics prodchar = new AppointmentReserveRequestDTO.ProductCharacteristics();
    prodchar.lineItemNumber = '1';
    prodchar.serviceLevel = 'Standard';
    prodchar.serviceIdentifier = '0435435035';
    prodchar.productOfferName = 'PS_000077';
    prodchar.productOfferId = 'PS_000077';
    prodchar.characterstics = charsList;
    prodChars.add(prodchar);
    
    List<AppointmentReserveRequestDTO.JobItems> jobitems = new List<AppointmentReserveRequestDTO.JobItems>();
    AppointmentReserveRequestDTO.JobItems jobItem = new AppointmentReserveRequestDTO.JobItems();
    jobItem.id ='83FAA21B-464F-410a-A7B7-CB2CD33734CD';
    jobItem.description = 'this is not so long description, it could be a long description if it is made one but it isnt ';
    jobItem.notes = 'Project_Manager_emailId - test@test.com';
    jobItem.productCharacteristics = prodChars;
    jobitems.add(jobItem);

    List<AppointmentReserveRequestDTO.TaskItems> taskItems = new List<AppointmentReserveRequestDTO.TaskItems>();
    AppointmentReserveRequestDTO.TaskItems taskItem = new AppointmentReserveRequestDTO.TaskItems();
    taskItem.id ='f2387ac5-2d1b-2938-ea08-58b0fdf9747b';
    taskItem.notes ='this is notes';
    taskItem.productCharacteristics = prodChars;
    taskItem.jobItems = jobitems;
    taskItems.add(taskItem);
    
    List<AppointmentReserveRequestDTO.Codes> codeList = new List<AppointmentReserveRequestDTO.Codes>();
    AppointmentReserveRequestDTO.Codes codeDtl = new AppointmentReserveRequestDTO.Codes();
    codeDtl.name ='SUPPORT';
    codeDtl.value = 'SRX320';
    codeList.add(codeDtl);
    

    AppointmentReserveRequestDTO.OrderDetails ordDetails = new AppointmentReserveRequestDTO.OrderDetails();
    ordDetails.id ='ON00001979';
    ordDetails.type ='New';
    
    AppointmentReserveRequestDTO.Faultdetails fault = new AppointmentReserveRequestDTO.Faultdetails();
    fault.type = 'Report';
    fault.codes = codeList;
    
    AppointmentReserveRequestDTO.TicketDetails ticketdtl = new AppointmentReserveRequestDTO.TicketDetails();
    ticketdtl.id ='TKT-0000123';
    ticketdtl.serviceLevelAgreement ='Standard';
    ticketdtl.impact = 'low';
    ticketdtl.serviceIdentifier ='SVC-000003216';
    ticketdtl.isSilentLine = false;
    ticketdtl.customerRequiredDate ='22-04-2018T11:00:00Z';
    ticketdtl.obligatoryCompletionDate ='22-04-2018T11:00:15Z';
    ticketdtl.notes ='this is a ticket note in a note';
    ticketdtl.faultdetails = fault;*/

    AppointmentReserveRequestDTO.Customer acc = new AppointmentReserveRequestDTO.Customer();
    acc.name ='EDGE TEST CUSTOMER TEST';
    acc.customerclass ='Sole Trader';

    List<AppointmentReserveRequestDTO.Contacts> contcts = new List<AppointmentReserveRequestDTO.Contacts>();
    AppointmentReserveRequestDTO.Contacts contct = new AppointmentReserveRequestDTO.Contacts();
    contct.name = 'Gary Legend';
    contct.phoneNumber ='0435435035';
    contct.role = 'Primary';
    contcts.add(contct);
  
    AppointmentReserveRequestDTO.Data data = new AppointmentReserveRequestDTO.Data();
    data.contacts = contcts;
    data.customer = acc;
    //data.ticketDetails = ticketdtl;
    //data.orderDetails = ordDetails;
    data.notes = 'this is another note on a higher level - note on another level ;)';
    //data.taskItems = taskItems;

    return data;
   }

   @istest static void testAppointReserveSuccessResponse(){
       AppointmentReserveRequestDTO reserveDTO = new AppointmentReserveRequestDTO();
       AppointmentReserveRequestDTO.Data data = getReserveRequestDTO();
       String slotId = 'S-200';
       reserveDTO.data = data;
       Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
       HttpResponse result = EWOMAppointmentManager.reserveAppointment(reserveDTO, slotId);
       system.debug('result=='+result.getBody());
       Test.stopTest();
       System.assertNotEquals(null,result.getBody());
       String json = result.getBody();
       AppointmentReserveResponseDTO.Data responsedata = AppointmentReserveResponseDTO.parse(json);

       System.assertEquals(responsedata.notes, 'this is another note on a higher level - note on another level ;)');
        System.assertEquals(responsedata.transitReserveToBook, null);
        System.assertEquals(responsedata.contacts[0].name, 'Gary Legend');
        System.assertEquals(responsedata.customer.name, 'EDGE TEST CUSTOMER TEST');
        System.assertEquals(responsedata.ticketDetails.serviceLevelAgreement, 'Standard');
        System.assertEquals(responsedata.ticketDetails.id, 'TKT-0000123');
        System.assertEquals(responsedata.orderDetails.id, 'ON00001979');
   }

   @istest static void testAppointReserveError400Response(){
       AppointmentReserveRequestDTO.Data data = getReserveRequestDTO();
       AppointmentReserveRequestDTO reserveDTO = new AppointmentReserveRequestDTO();
       String slotId = 'S-400';
       reserveDTO.data = data;
       Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(400, 'ERROR', null, new Map<String, String>()));
       Test.startTest();
       HttpResponse result = EWOMAppointmentManager.reserveAppointment(reserveDTO, slotId);
       system.debug('result=='+result.getBody());
       Test.stopTest();
       System.assertNotEquals(null,result.getBody());
       AppointmentReserveErrorDTO.Error err = AppointmentReserveErrorDTO.parse(result.getBody());

        System.assertEquals(err.status, 400);
        System.assertEquals(err.message, 'BAD REQUEST');
        System.assertEquals(err.dtime, '2018-10-20T15:29:05+11:00');
        System.assertEquals(err.errors[0].code, 'WOM-APP-0017');
   }

   @istest static void testAppointReserveError422Response(){
       AppointmentReserveRequestDTO reserveDTO = new AppointmentReserveRequestDTO();
       AppointmentReserveRequestDTO.Data data = getReserveRequestDTO();
       String slotId = 'S-422';
       reserveDTO.data = data;
       Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(422, 'ERROR', null, new Map<String, String>()));
       Test.startTest();
       HttpResponse result = EWOMAppointmentManager.reserveAppointment(reserveDTO, slotId);
       system.debug('result=='+result.getBody());
       Test.stopTest();
       System.assertNotEquals(null,result.getBody());
       
       AppointmentReserveErrorDTO.Error err = AppointmentReserveErrorDTO.parse(result.getBody());

        System.assertEquals(err.status, 422);
        System.assertEquals(err.message, 'UNPROCESSABLE ENTITY');
        System.assertEquals(err.dtime, '2018-10-20T15:29:05+11:00');
        System.assertEquals(err.errors[0].code, 'WOM-APP-0017');
}
    @istest static void testAppointmentRebookQuerySuccessResponse(){
        AppointmentRescheduleRequestDTO.Data appData= new AppointmentRescheduleRequestDTO.Data();
        appData.startDate = '2018-09-10T08:00:00.0Z';
        appData.endDate = '2018-12-10T08:00:00.0Z';
        appData.searchType= 'PARTIAL_COMPLETE';
        AppointmentRescheduleRequestDTO app = new AppointmentRescheduleRequestDTO();
        app.data = appData;
        Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(200, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentSlotResponseDTO appres = EWOMAppointmentManager.searchRebookAppointment(app,'TAPT031531229299WQM2');
        Test.stopTest();
        system.assertNotEquals(null, appres.data.availableSlots);
    }
    
        @istest static void testAppointmentRebookQueryErrorResponse(){
        AppointmentRescheduleRequestDTO.Data appData= new AppointmentRescheduleRequestDTO.Data();
        appData.startDate = '2018-09-10T08:00:00.0Z';
        appData.endDate = '2018-12-10T08:00:00.0Z';
        appData.searchType= 'PARTIAL_COMPLETE';
        AppointmentRescheduleRequestDTO app = new AppointmentRescheduleRequestDTO();
        app.data = appData;
        Test.setMock(HttpCalloutMock.class, new MockAppointmentResponseGenerator(400, 'OK', null, new Map<String, String>()));
        Test.startTest();
        AppointmentSlotResponseDTO appres = EWOMAppointmentManager.searchRebookAppointment(app,'TAPT031531229299WQM2');
        Test.stopTest();
        system.debug('*********Error'+appres);
        system.assertEquals(null, appres.data);
    }
    
    @istest static void testAppointmentRebookReserveSuccessResponse(){
        AppointmentReserveRequestDTO reserveDTO = new AppointmentReserveRequestDTO();
        AppointmentReserveRequestDTO.Data data = getReserveRequestDTO();
        String slotId = 'S-200';
        String appId = '12345';
        reserveDTO.data = data;
        Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(200, 'OK', null, new Map<String, String>()));
        Test.startTest();
        HttpResponse result = EWOMAppointmentManager.reserveRebookAppointment(reserveDTO, slotId,appId);
        system.debug('result=='+result.getBody());
        Test.stopTest();
        System.assertNotEquals(null,result.getBody());
    }
    @istest static void testAppointmentRebookReserveErrorResponse(){
        AppointmentReserveRequestDTO reserveDTO = new AppointmentReserveRequestDTO();
        AppointmentReserveRequestDTO.Data data = getReserveRequestDTO();
        String slotId = 'S-200';
        String appId = '12345';
        reserveDTO.data = data;
        Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(400, 'OK', null, new Map<String, String>()));
        Test.startTest();
        HttpResponse result = EWOMAppointmentManager.reserveRebookAppointment(reserveDTO, slotId,appId);
        system.debug('result=='+result.getBody());
        Test.stopTest();
        System.assertNotEquals(null,result.getBody());
    }
    
    
    
 }