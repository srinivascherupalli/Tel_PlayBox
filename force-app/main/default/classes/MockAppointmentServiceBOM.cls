global class MockAppointmentServiceBOM implements HttpCalloutMock
    {
        protected String resType;
        
        global MockAppointmentServiceBOM(String resType){
            this.resType = resType;
        }
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            //EDGE - 75002, AC1 -  data with baseRuleProduct array
          String success_GenerateAppo='{"status":200,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/appointment-bom","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","bomID":"BOM0000000009","numberOfAppointmentsRequired":2,"requiredAppointments":[{"arrayItemNumber":1,"appointmentCategory":"NBN","appointmentType":"STANDARD INSTALL","appointmentSubType":"STANDARD","suggestedStartDate":"2019-06-03T00:05:00","minimumStartDate":"2019-02-04T00:05:00","baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000027","productInstanceID":"463949fd-e9b7-f459-b34f-4bcdb7d5b8d2"}]},{"arrayItemNumber":2,"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","suggestedStartDate":"2019-06-14T00:05:00","minimumStartDate":"2019-02-04T00:05:00","dependencies":[{"dependentArrayItemNumber":1,"leadTimeDaysApplied":3}],"baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000073","productInstanceID":"397949fd-e6a7-f459-b34f-4bcdb7d5b5c1"}]}]}}';
            String errorResponse='{"status":422,"code":1000,"message":"Missing ruleSetId field value","time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/appointment-bom","method":"POST","request":{"notEarlierThanDate":"2019-02-01T00:00:00","transactionType":"Connect","transactionSubType":"Normal","state":"NSW","locationType":"METRO","complexityBand":"STD","transactionReferenceID":"MyOrderNumber123","transactionProducts":[{"productAction":"ADD","productID":"DMCAT_Offer_000303","productInstanceID":"877ca8f5-2487-752c-ad43-5b6dba91fe82"},{"productAction":"ADD","productID":"DMCAT_ProductSpecification_000027","productInstanceID":"9c7ab03e-8de7-b7fa-c48d-72e2b48d01fb","parentProductInstanceID":"877ca8f5-2487-752c-ad43-5b6dba91fe82","productParameters":[{"parameterName":"Access Technology","parameterValue":"Telstra Fibre Access"},{"parameterName":"Access Technology","parameterValue":"Telstra Fibre Access"}]}]},"errors":[{"message":"Missing ruleSetId field value","code":1000},{"message":"An unclassified error occurred","code":2001}]}';
            string reserve_Success='{"status":200,"time":"2019-02-12T09:57:46.028Z","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/confirmation/TAPT001529399876SVEU","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","appointmentCategory":"TELSTRA","appointmentID":"TAPT001529399876SVEU"}}';
            String rebook_reserve='{"data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","appointmentCategory":"NBN","appointmentID":"APT111529399876SVEM","oldAppointmentID":"APT001529343576SVEU","reservationReference":"MyOrderNumber123: RESERVED","reservationConditions":"Reduced working hours during weekend periods July 2019","dependencies":[{"appointmentID":"TAPT2352213142342","appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","currentSlotStartDate":"2019-02-25T12:45:00","currentSlotEndDate":"2019-02-28T12:45:00","rescheduleRequired":"Y","leadTimeDaysApplied":4,"minimumStartDate":"2019-02-22T12:45:00","suggestedStartDate":"2019-02-23T12:45:00"}]},"correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","status":200,"time":"2019-02-01T12:45:10","path":"/v1/appointments/existing-appointments/APT2352213142342/slots/1111-2222-3333-4444/rebook","method":"POST"}';
            if(resType.contains('success_GenerateAppo')){
                res.setBody(success_GenerateAppo);
                res.setStatusCode(200);
            }
        
            else if(resType.contains('Error')){
                res.setBody(errorResponse);
                res.setStatusCode(422);
            }
            else if(resType.contains('reserve')){
                res.setBody(reserve_Success);
                res.setStatusCode(200);
            }
            else if(resType.equals('rebook')){
                res.setBody(rebook_reserve);
                res.setStatusCode(200);
            }
            return res;
        }
    }