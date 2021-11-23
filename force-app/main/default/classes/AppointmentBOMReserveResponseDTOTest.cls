/* Description: Test classto parse Response DTO for Appointment BOM Reserve EDGE-66238
    Author: Aishwarya Yeware
    */

    @isTest
    public class AppointmentBOMReserveResponseDTOTest {
        
    /*------------------------------------------------------------ 
    Author: Aishwarya
    US: EDGE-66238  
    Description: parse json response for Schedule Success
    ------------------------------------------------------------*/
        @isTest
        public static void testParseSuccess(){
            //String json='{"status":200,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/appointment-bom","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","bomID":"BOM0000000009","numberOfAppointmentsRequired":2,"requiredAppointments":[{"arrayItemNumber":1,"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","suggestedStartDate":"2019-02-10T00:05:00","minimumStartDate":"2019-02-04T00:05:00","dependencies":{"dependentArraryItemNumber":2,"leadTimeDaysApplied":3}},{"arrayItemNumber":2,"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"EXCHANGE","suggestedStartDate":"2019-02-07T00:05:00","minimumStartDate":"2019-02-04T00:05:00"}]}}';
            String json='{"status":200,"time":"2019-02-12T09:57:46.028Z","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/confirmation/TAPT001529399876SVEU","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","appointmentCategory":"TELSTRA","appointmentID":"TAPT001529399876SVEU","dependencies":[{"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","suggestedStartDate":"2019-02-10T00:05:00","minimumStartDate":"2019-02-04T00:05:00"}]}}';
            Test.startTest();
            AppointmentBOMReserveResponseDTO appRes= AppointmentBOMReserveResponseDTO.parse(json);
            Test.stopTest();
            System.assert(appRes.status ==200);
            System.assert(appRes.correlationId =='e8314645-c0fe-42a7-beac-2e64f8b3ebcf');
            System.assert(appRes.path =='/v1/appointments/confirmation/TAPT001529399876SVEU'); 
            System.assert(appRes.method =='POST');
            System.assert(appRes.data.transactionReferenceID =='MyOrderNumber123');
            System.assert(appRes.data.callingSystemID =='b2b');
            System.assert(appRes.data.appointmentCategory =='TELSTRA');
            System.assert(appRes.data.appointmentID =='TAPT001529399876SVEU');
            System.assert(appRes.data.dependencies[0].appointmentCategory =='TELSTRA');
            System.assert(appRes.data.dependencies[0].appointmentType =='ORDER INSTALL');
            System.assert(appRes.data.dependencies[0].appointmentSubType =='CUST PREMISES');
            System.assert(appRes.data.dependencies[0].suggestedStartDate =='2019-02-10T00:05:00');
            System.assert(appRes.data.dependencies[0].minimumStartDate =='2019-02-04T00:05:00');   
        }
        
    /*------------------------------------------------------------ 
    Author: Kalashree 
    US: EDGE - 66470,70304  
    Description: parse json response for Reschedule success
    ------------------------------------------------------------*/
        
        @isTest
        public static void testParseRescheduleSuccess(){
            String json='{"status":200,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/existing-appointments/APT2352213142342/slots/1111-2222-3333-4444/reschedule","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","appointmentCategory":"NBN","appointmentID":"APT001529399876SVEU","oldAppointmentID":"APT001529343576SVEU","reservationReference":"MyOrderNumber123: RESERVED","reservationConditions":"Reduced working hours during weekend periods July 2019","dependencies":[{"appointmentID":"TAPT001529343576SVEU","appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","currentSlotStartDate":"2019-02-25T12:45:00","currentSlotEndDate":"2019-02-28T12:45:00","rescheduleRequired":"Y","leadTimeDaysApplied":4,"minimumStartDate":"2019-02-22T12:45:00","suggestedStartDate":"2019-02-23T12:45:00"}]}}';
            Test.startTest();
            AppointmentBOMReserveResponseDTO appRes= AppointmentBOMReserveResponseDTO.parse(json);
            Test.stopTest();
            System.assert(appRes.status ==200);
        }
        
        /*------------------------------------------------------------ 
    Author: Kalashree 
    US: EDGE - 66470,70304  
    Description: parse json response for Reschedule error
    ------------------------------------------------------------*/
        
        @isTest
        public static void testParseRescheduleError(){
            String json='{"status":422,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/existing-appointments/APT2352213142342/slots/1111-2222-3333-4444/reschedule","method":"POST","code":"1000","message":"Missing mandatory field value","request":{"correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","data":{"transactionReferenceID":"MyOrderNumber123","appointment":{"appointmentCategory":"NBN"}}},"errors":[{"message":"Mandatory inputs on field missing","code":"1000"}]}';
            Test.startTest();
            AppointmentBOMReserveResponseDTO appRes= AppointmentBOMReserveResponseDTO.parse(json);
            Test.stopTest();
            System.assert(appRes.status ==422);
        }
    }