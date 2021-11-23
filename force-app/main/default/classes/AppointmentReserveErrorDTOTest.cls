@isTest
private class AppointmentReserveErrorDTOTest {
	
	@isTest static void testDTOStructure() {
		List<AppointmentReserveErrorDTO.ErrorCodes> errCodes = new List<AppointmentReserveErrorDTO.ErrorCodes>();
		AppointmentReserveErrorDTO.ErrorCodes errCode = new AppointmentReserveErrorDTO.ErrorCodes();
		errCode.code = 'WOM-APP-0017';
		errCode.message = 'WOM: The manadatory tag was missed';
        errCodes.add(errCode);

		AppointmentReserveErrorDTO.Error err = new AppointmentReserveErrorDTO.Error();
		err.status = 400;
		err.code = 1003;
		err.message = 'BAD REQUEST';
		err.dtime = '2018-10-20T15:29:05+11:00'; //time is reserved keyword
		err.correlationId = '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e';
		err.errors = errCodes;
		
		String json = JSON.serialize(err);
		System.debug(json);
		System.assertNotEquals(json, '');
	}
	
	@isTest static void testParseMethod() {
		String json = '{"status":400,"message":"BAD REQUEST","errors":[{"message":"WOM: The manadatory tag was missed","code":"WOM-APP-0017"}],"time":"2018-10-20T15:29:05+11:00","correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","code":1003}';
		AppointmentReserveErrorDTO.Error err = AppointmentReserveErrorDTO.parse(json);

		System.assertEquals(err.status, 400);
		System.assertEquals(err.code, 1003);
		System.assertEquals(err.message, 'BAD REQUEST');
		System.assertEquals(err.dtime, '2018-10-20T15:29:05+11:00');
		System.assertEquals(err.correlationId, '58fb5c78-77ed-4f58-97e3-6e0ae3ce498e');
		System.assertEquals(err.errors[0].code, 'WOM-APP-0017');
	}
	
}