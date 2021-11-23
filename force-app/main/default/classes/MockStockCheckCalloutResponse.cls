/*******************************************************************************************************************
Name : MockStockCheckCalloutResponse
EDGE-> 80857
Description : Mock test class for callout to the Stock Check API to get the stock availability details of the selected product
====================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Ravi Shankar     12/06/2019   As a salesforce user, I want to Perform Stock Check for the selected device
                                        so that I can present the information to customer : Stock Enquiry API Consumption
2.         Martand Atrey   3/2/2021     added different response according to EDGE-199064
====================================================================================================================
********************************************************************************************************************/
global class MockStockCheckCalloutResponse implements HttpCalloutMock{
    protected String resType;
    private String orderNumber;
    private List<String> serviceNumbers;
    
    global MockStockCheckCalloutResponse(String resType){
        this.resType = resType;
    }
    global MockStockCheckCalloutResponse(String resType, String orderNumber, List<String> serviceNumbers){
        this.resType = resType;
        this.orderNumber = orderNumber;
        this.serviceNumbers = serviceNumbers;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Search ='{"status":200, "productId": "100119246","isServiceable": true,"inventory": [{"availableQuantity": 0,"description": "SIM CARD 128K TRIO LANES (R) EMERGENCY 054","nextReplenishmentDate": "2019-06-11"}]}';
        String success_Error = '{"status":422}';
        String oneService = '';
        String allservices = '{ "externalOrderId": "'+orderNumber+'", "sourceSystem": "Cloudsense", "action": "CREATE", "customerId": "2019092687845848800", "OrderItemsinPONR": [ ';
        //String allservices = '{ "externalOrderId": "'+orderNumber+'", "sourceSystem": "Cloudsense", "action": "CREATE", "customerId": "2019092687845848800", "OrderItemsinPONR": [ "'+orderNumber+'|SVC-000107096|9b1406b6-706f-a676-0904-8f501cb42396", "'+orderNumber+'|SVC-000107097|9b1406b6-706f-a676-0904-8f501cb42396", "'+orderNumber+'|SVC-000107098|9b1406b6-706f-a676-0904-8f501cb42396", "'+orderNumber+'|SVC-000107099|9b1406b6-706f-a676-0904-8f501cb42396", "'+orderNumber+'|SVC-000107100|9b1406b6-706f-a676-0904-8f501cb42396" ] }';
        if(serviceNumbers != null)
        {
            for(String servNum : serviceNumbers){
                allservices += '"' + orderNumber + '|' + servNum + '|9b1406b6-706f-a676-0904-8f501cb42396",';
            }

            oneService = '{ "externalOrderId": "'+orderNumber+'", "sourceSystem": "Cloudsense", "action": "CREATE", "customerId": "2019092687845848800", "OrderItemsinPONR": [ "'+orderNumber+'|'+ serviceNumbers[0]+'|9b1406b6-706f-a676-0904-8f501cb42396" ] }';
        }
        allservices = allservices.removeEnd(',');
        allservices += '] }';
        String noService = '{ "externalOrderId": "'+orderNumber+'", "sourceSystem": "Cloudsense", "action": "CREATE", "customerId": "2019092687845848800", "OrderItemsinPONR": [ ] }';
        String null_Response=Null;
        String success_multiple = '{"idSource":"string","products":[{"id":"100158856","isServiceable":true,"availableQuantity":10,"description":"string","nextReplenishmentDate":"2019-10-14"},{"id":"100157169","isServiceable":true,"availableQuantity":0,"description":"string","nextReplenishmentDate":"2019-10-14"},{"id":"100115460","isServiceable":true,"availableQuantity":0,"description":"string","nextReplenishmentDate":""},{"id":"100159379","isServiceable":true,"availableQuantity":30,"description":"string","nextReplenishmentDate":"2019-10-14"}],"lineOfBusinessCode":"string"}';
        if(resType.contains('success_Search')){
            res.setBody(success_Search);
            res.setStatusCode(200);
        }
        else if(resType.contains('success_Error')){
            res.setBody(success_Error);
            res.setStatusCode(422);
        }
        else if(resType.equalsIgnoreCase('success_multiple')){
            res.setBody(success_multiple);
            res.setStatusCode(200);
        }
        else if(resType.equalsIgnoreCase('allservices')){
            res.setBody(allservices);
            res.setStatusCode(200);
        }
        else if(resType.equalsIgnoreCase('oneService')){
            res.setBody(oneService);
            res.setStatusCode(200);
        }
        else if(resType.equalsIgnoreCase('noService')){
            res.setBody(noService);
            res.setStatusCode(200);
        }
        else if(resType.contains('null_Response')){
            res=Null;
            //res.setStatusCode(422);
        }
        return res;
    }
}