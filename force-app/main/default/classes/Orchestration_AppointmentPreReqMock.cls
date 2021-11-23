/**================================================================
 * Appirio, Inc
 * Name: Orchestration_AppointmentPreReqMock
 * Created Date: July 09, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/
@isTest
global class Orchestration_AppointmentPreReqMock implements HttpCalloutMock {
    protected String resType;
    global Orchestration_AppointmentPreReqMock(String resType) {
        this.resType = resType;
    }

    global HTTPResponse respond(HTTPRequest req) {
        //numberOfAppointmentsRequired = 0
        String success_GenerateAppReq0 = '{"status":200,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/appointment-bom","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","bomID":"BOM0000000009","numberOfAppointmentsRequired":0}}';

        HTTPResponse resp = new HTTPResponse();

        if (resType.contains('success_GenerateAppReq0')) {
            resp.setBody(success_GenerateAppReq0);
            resp.setStatusCode(200);
        }

        return resp;
    }
}