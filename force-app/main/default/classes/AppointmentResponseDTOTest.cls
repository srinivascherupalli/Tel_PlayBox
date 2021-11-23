@isTest
    public class AppointmentResponseDTOTest {
        
        @isTest
        public static void testparseSuccess(){
            String json = '{"status":200,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/appointment-bom","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","bomID":"BOM0000000009","numberOfAppointmentsRequired":2,"requiredAppointments":[{"arrayItemNumber":1,"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","suggestedStartDate":"2019-02-10T00:05:00","minimumStartDate":"2019-02-04T00:05:00","baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000073","productInstanceID":"397949fd-e6a7-f459-b34f-4bcdb7d5b5c1"}]},{"arrayItemNumber":2,"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"EXCHANGE","suggestedStartDate":"2019-02-07T00:05:00","minimumStartDate":"2019-02-04T00:05:00"}]}}'; 
            Test.startTest();
            AppointmentResponseDTO appRes= AppointmentResponseDTO.parse(json);
            Test.stopTest();
            
            System.assert(appRes.status ==200);
            System.assert(appRes.path =='/v1/appointments/appointment-bom'); 
            System.assert(appRes.correlationId =='e8314645-c0fe-42a7-beac-2e64f8b3ebcf');
            System.assert(appRes.method =='POST');
            System.assert(appRes.data.transactionReferenceID =='MyOrderNumber123');
            System.assert(appRes.data.callingSystemID =='b2b');
            System.assert(appRes.data.bomID =='BOM0000000009');
            System.assert(appRes.data.numberOfAppointmentsRequired ==2);
            System.assert(appRes.data.requiredAppointments[0].arrayItemNumber ==1);
            System.assert(appRes.data.requiredAppointments[0].appointmentCategory =='TELSTRA');
            System.assert(appRes.data.requiredAppointments[0].appointmentType =='ORDER INSTALL');
            System.assert(appRes.data.requiredAppointments[0].appointmentSubType =='CUST PREMISES');
            System.assert(appRes.data.requiredAppointments[0].suggestedStartDate =='2019-02-10T00:05:00');
            System.assert(appRes.data.requiredAppointments[0].minimumStartDate =='2019-02-04T00:05:00');
            System.assert(appRes.data.requiredAppointments[0].baseRuleProducts[0].productID =='DMCAT_ProductSpecification_000073');
            System.assert(appRes.data.requiredAppointments[0].baseRuleProducts[0].productInstanceID =='397949fd-e6a7-f459-b34f-4bcdb7d5b5c1');
           System.assert(appRes.data.requiredAppointments[1].arrayItemNumber ==2);
            System.assert(appRes.data.requiredAppointments[1].appointmentCategory =='TELSTRA');
            System.assert(appRes.data.requiredAppointments[1].appointmentType =='ORDER INSTALL');
            System.assert(appRes.data.requiredAppointments[1].appointmentSubType =='EXCHANGE');
            System.assert(appRes.data.requiredAppointments[1].suggestedStartDate =='2019-02-07T00:05:00');
            System.assert(appRes.data.requiredAppointments[1].minimumStartDate =='2019-02-04T00:05:00');
        }
    }