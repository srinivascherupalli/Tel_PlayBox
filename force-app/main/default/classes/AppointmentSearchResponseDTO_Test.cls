@IsTest
    public class AppointmentSearchResponseDTO_Test {
        
        static testMethod void testParse() {
            String json = '{'+
            '  \"status\": 200,'+
            '  \"time\": \"2019-02-12T03:04:55.728Z\",'+
            '  \"correlationId\": \"e8314645-c0fe-42a7-beac-2e64f8b3ebcf\",'+
            '  \"path\": \"/v1/appointments/slot-enquiry\",'+
            '  \"method\": \"POST\",'+
            '  \"data\": {'+
            '    \"transactionReferenceID\": \"MyOrderNumber123\",'+
            '    \"callingSystemID\": \"b2b\",'+
            '    \"availableSlots\": [{'+
            '      \"slotID\": \"1111-2222-3333-4444\",'+
            '      \"slotType\": \"Standard\",'+
            '      \"startDate\": \"2019-02-08T08:00:00\",'+
            '      \"endDate\": \"2019-02-08T12:00:00\"'+
            '    }],'+
            '    \"causeEvent\": {'+
            '      \"eventReason\": \"MSD\",'+
            '      \"eventStartDate\": \"2019-02-01T08:00:00\"'+
            '    },'+
            '    \"estimatedDuration\": 60'+
            '  }'+
            '}';
            
            Test.startTest();
            String JSON_Response = '{ "status": 200, "time": "2019-02-12T03:04:55.728Z", "correlationId": "e8314645-c0fe-42a7-beac-2e64f8b3ebcf", "path": "/v1/appointments/slot-enquiry", "method": "POST", "data": { "transactionReferenceID": "MyOrderNumber123", "callingSystemID": "b2b", "availableSlots": [{ "slotID": "1111-2222-3333-4444", "slotType": "Standard", "startDate": "2019-02-08T08:00:00", "endDate": "2019-02-08T12:00:00" }], "causeEvent": { "eventReason": "MSD", "eventStartDate": "2019-02-01T08:00:00" }, "estimatedDuration": 60 } }';
            Test.stopTest();
             
            AppointmentSearchResponseDTO appRes = AppointmentSearchResponseDTO.parse(JSON_Response);
            //System.assert(obj != null);
             System.assert(appRes.status ==200);
            System.assert(appRes.path =='/v1/appointments/slot-enquiry'); 
            System.assert(appRes.correlationId =='e8314645-c0fe-42a7-beac-2e64f8b3ebcf');
            System.assert(appRes.method =='POST');
            System.assert(appRes.data.transactionReferenceID =='MyOrderNumber123');
            System.assert(appRes.data.callingSystemID =='b2b');
           
        }
    }