@isTest
global class MockSlotReserveResponseGenerator implements HttpCalloutMock{
	
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockSlotReserveResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        String endPoint = req.getEndpoint();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        System.debug('endPoint:::'+req.getEndpoint());
        if(endPoint.contains('/S-200/reservations')) {
            String js = reserveSuccessResponse();
            res.setBody(js);
        } else if (endPoint.contains('/S-400/reservations')) {
            String jse1 = reserveErrorResponse(400, 1000, 'BAD REQUEST');
            res.setBody(jse1);
        } else if (endPoint.contains('/S-422/reservations')) {
            String jse2 = reserveErrorResponse(422, 1010, 'UNPROCESSABLE ENTITY');
            res.setBody(jse2);
        } else if (endPoint.contains('token')) {
            res.setBody('{ "access_token": "tElsAddR32156teSt","expires_in": "2000"}');
        } 
        res.setStatusCode(this.code);
        //res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

    public static String reserveSuccessResponse() {

		List<AppointmentReserveResponseDTO.Codes> codeList = new List<AppointmentReserveResponseDTO.Codes>();
		AppointmentReserveResponseDTO.Codes codeDtl = new AppointmentReserveResponseDTO.Codes();
		codeDtl.name ='SUPPORT';
		codeDtl.value = 'SRX320';
		codeList.add(codeDtl);
		

		AppointmentReserveResponseDTO.OrderDetails ordDetails = new AppointmentReserveResponseDTO.OrderDetails();
		ordDetails.id ='ON00001979';
		ordDetails.type ='New';
		
		AppointmentReserveResponseDTO.Faultdetails fault = new AppointmentReserveResponseDTO.Faultdetails();
		fault.type = 'Report';
		fault.codes = codeList;
		
		AppointmentReserveResponseDTO.TicketDetails ticketdtl = new AppointmentReserveResponseDTO.TicketDetails();
		ticketdtl.id ='TKT-0000123';
		ticketdtl.serviceLevelAgreement ='Standard';
		ticketdtl.impact = 'low';
		ticketdtl.serviceId ='SVC-000003216';
		ticketdtl.isSilentLine = false;
		ticketdtl.customerRequiredDate ='22-04-2018T11:00:00Z';
		ticketdtl.obligatoryCompletionDate ='22-04-2018T11:00:15Z';
		ticketdtl.notes ='this is a ticket note in a note';
		ticketdtl.faultdetails = fault;

		AppointmentReserveResponseDTO.Customer acc = new AppointmentReserveResponseDTO.Customer();
		acc.name ='EDGE TEST CUSTOMER TEST';
		acc.customerclass ='Sole Trader';

		List<AppointmentReserveResponseDTO.Contacts> contcts = new List<AppointmentReserveResponseDTO.Contacts>();
		AppointmentReserveResponseDTO.Contacts contct = new AppointmentReserveResponseDTO.Contacts();
		contct.name = 'Gary Legend';
		contct.phoneNumber ='0435435035';
		contct.role = 'Primary';
		contcts.add(contct);
	
		AppointmentReserveResponseDTO.Data data = new AppointmentReserveResponseDTO.Data();
		data.contacts = contcts;
		data.customer = acc;
		data.ticketDetails = ticketdtl;
		data.orderDetails = ordDetails;
		data.notes = 'this is another note on a higher level - note on another level ;)';
		//data.taskItems = taskItems;

		String json = JSON.serialize(data);
		System.debug(json);
		
		return json;
	}


	public static String reserveErrorResponse(Integer status, Integer code, String message) {

		List<AppointmentReserveErrorDTO.ErrorCodes> errCodes = new List<AppointmentReserveErrorDTO.ErrorCodes>();
		AppointmentReserveErrorDTO.ErrorCodes errCode = new AppointmentReserveErrorDTO.ErrorCodes();
		errCode.code = 'WOM-APP-0017';
		errCode.message = 'WOM: The manadatory tag was missed';
        errCodes.add(errCode);

		AppointmentReserveErrorDTO.Error err = new AppointmentReserveErrorDTO.Error();
		err.status = status;
		err.code = code;
		err.message = message;
		err.dtime = '2018-10-20T15:29:05+11:00'; //time is reserved keyword
		err.correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
		err.errors = errCodes;
		
		String json = JSON.serialize(err).replace('dtime', 'time');
		System.debug(json);
		
		return json;
	}
    
	@istest static void testAppointReserveSuccessResponse(){
	   AppointmentReserveRequestDTO reserveDTO = new AppointmentReserveRequestDTO();
       AppointmentReserveRequestDTO.Data data = EWOMAppointmentServiceTest.getReserveRequestDTO();
       String slotId = 'S-200';
	   reserveDTO.data = data;
       Test.setMock(HttpCalloutMock.class, new MockSlotReserveResponseGenerator(200, 'OK', null, new Map<String, String>()));
       Test.startTest();
       HttpResponse result = EWOMAppointmentService.reserveAppointment(reserveDTO, slotId);
       system.debug('result=='+result.getBody());
       Test.stopTest();
       System.assertNotEquals(null,result.getBody());
   }

}