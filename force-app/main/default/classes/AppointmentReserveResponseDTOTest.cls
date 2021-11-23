@isTest
private class AppointmentReserveResponseDTOTest {
	
	@isTest static void testDTOStructure() {

		/*List<AppointmentReserveResponseDTO.Characterstics> charsList = new List<AppointmentReserveResponseDTO.Characterstics>();
		AppointmentReserveResponseDTO.Characterstics chars = new AppointmentReserveResponseDTO.Characterstics();
		chars.name = 'ManagementServiceHours';
		chars.value = '24x7';
		chars.action ='Disconnect';
		charsList.add(chars);

		List<AppointmentReserveResponseDTO.ProductCharacteristics> prodChars = new List<AppointmentReserveResponseDTO.ProductCharacteristics>();
		AppointmentReserveResponseDTO.ProductCharacteristics prodchar = new AppointmentReserveResponseDTO.ProductCharacteristics();
		prodchar.lineItemNumber = '1';
		prodchar.serviceLevel = 'Standard';
		prodchar.serviceIdentifier = '0435435035';
		prodchar.productOfferName = 'PS_000077';
		prodchar.productOfferId = 'PS_000077';
		prodchar.characterstics = charsList;
		prodChars.add(prodchar);
		*/
		/*List<AppointmentReserveResponseDTO.JobItems> jobitems = new List<AppointmentReserveResponseDTO.JobItems>();
		AppointmentReserveResponseDTO.JobItems jobItem = new AppointmentReserveResponseDTO.JobItems();
		jobItem.id ='83FAA21B-464F-410a-A7B7-CB2CD33734CD';
		jobItem.description = 'this is not so long description, it could be a long description if it is made one but it isnt ';
		jobItem.notes = 'Project_Manager_emailId - test@test.com';
		jobItem.productCharacteristics = prodChars;
		jobitems.add(jobItem);

		List<AppointmentReserveResponseDTO.TaskItems> taskItems = new List<AppointmentReserveResponseDTO.TaskItems>();
		AppointmentReserveResponseDTO.TaskItems taskItem = new AppointmentReserveResponseDTO.TaskItems();
		taskItem.id ='f2387ac5-2d1b-2938-ea08-58b0fdf9747b';
		taskItem.notes ='this is notes';
		taskItem.productCharacteristics = prodChars;
		taskItem.jobItems = jobitems;
		taskItems.add(taskItem);*/
		
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
		System.assertNotEquals(json, '');
	}
	
	@isTest static void testparseMethod() {
		String json = '{"ticketDetails":{"serviceLevelAgreement":"Standard","serviceIdentifier":"SVC-000003216","obligatoryCompletionDate":"22-04-2018T11:00:15Z","notes":"this is a ticket note in a note",'+
			'"isSilentLine":false,"impact":"low","id":"TKT-0000123","faultdetails":{"type":"Report","codes":[{"value":"SRX320","name":"SUPPORT"}]},"customerRequiredDate":"22-04-2018T11:00:00Z"},"taskItems":'+
			'[{"productCharacteristics":[{"serviceLevel":"Standard","serviceIdentifier":"0435435035","productOfferName":"PS_000077","productOfferId":"PS_000077","lineItemNumber":"1","characterstics":[{"value":"24x7",'+
			'"name":"ManagementServiceHours","action":"Disconnect"}]}],"notes":"this is notes","jobItems":[{"productCharacteristics":[{"serviceLevel":"Standard","serviceIdentifier":"0435435035","productOfferName":"PS_000077",'+
			'"productOfferId":"PS_000077","lineItemNumber":"1","characterstics":[{"value":"24x7","name":"ManagementServiceHours","action":"Disconnect"}]}],"notes":"Project_Manager_emailId - test@test.com","id":"83FAA21B-464F-410a-A7B7-CB2CD33734CD",'+
			'"description":"this is not so long description, it could be a long description if it is made one but it isnt "}],"id":"f2387ac5-2d1b-2938-ea08-58b0fdf9747b"}],"orderDetails":{"type":"New","id":"ON00001979"},'+
			'"notes":"this is another note on a higher level - note on another level ;)","customer":{"name":"EDGE TEST CUSTOMER TEST","class":"Sole Trader"},"contacts":[{"role":"Primary","phoneNumber":"0435435035","name":"Gary Legend"}]}';

		AppointmentReserveResponseDTO.Data data = AppointmentReserveResponseDTO.parse(json);

		System.assertEquals(data.notes, 'this is another note on a higher level - note on another level ;)');
		System.assertEquals(data.transitReserveToBook, null);
		System.assertEquals(data.contacts[0].name, 'Gary Legend');
		System.assertEquals(data.customer.name, 'EDGE TEST CUSTOMER TEST');
		System.assertEquals(data.ticketDetails.serviceLevelAgreement, 'Standard');
		System.assertEquals(data.ticketDetails.id, 'TKT-0000123');
		System.assertEquals(data.orderDetails.id, 'ON00001979');


	}
	
}