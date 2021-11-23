/* Description: Test class Request DTO for Appointment BOM Slot Query EDGE-66237
       Author: Jawahar
     */

    @IsTest
    public class AppointmentSearchRequestDTO_Test {
        
          static testMethod void testParse() {
                String json='{"correlationId": "e8314645-c0fe-42a7-beac-2e64f8b3ebcf","data":{"transactionReferenceID":"MyOrder123","bomID":"BOM1555050043VMQT","appointment":{"place":{"id":"161152457","type":"ADBOR_ID"},"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","priority":"STANDARD","searchStartDate":"2019-05-06T00:00:00","searchEndDate":"2019-05-20T10:00:00"}}}';
                AppointmentSearchRequestDTO appReq = AppointmentSearchRequestDTO.parse(json);  
                System.assert(appReq.correlationId =='e8314645-c0fe-42a7-beac-2e64f8b3ebcf');
                System.assert(appReq.data.bomID =='BOM1555050043VMQT');
                System.assert(appReq.data.transactionReferenceID =='MyOrder123');
                System.assert(appReq.data.Appointment.appointmentCategory  =='TELSTRA');
                System.assert(appReq.data.Appointment.appointmentType  =='ORDER INSTALL');
                System.assert(appReq.data.Appointment.appointmentSubType  =='CUST PREMISES');
                System.assert(appReq.data.Appointment.priority  =='STANDARD');
                System.assert(appReq.data.Appointment.searchStartDate =='2019-05-06T00:00:00');
                System.assert(appReq.data.Appointment.searchEndDate =='2019-05-20T10:00:00');
                System.assert(appReq.data.Appointment.Place.id =='161152457');
                System.assert(appReq.data.Appointment.Place.type  =='ADBOR_ID');
            
                }
    }