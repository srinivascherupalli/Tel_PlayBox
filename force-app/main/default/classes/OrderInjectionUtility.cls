public class OrderInjectionUtility {
    class ResultData{
        public String status;
        public String code;
        public String message;
        public String description;
        public String errors;
        public string orderNumber;
        public string correlationId;
        public string solutionid;//DIGI-16926
        public string basketid;//DIGI-16926
        public string configGUID;//DIGI-9360
        public string solutions; 
        public ResultData(String code, String status,string solutionid,string basketid, string correlationId, String Description, string orderNumber,String message,  String errors, String configGUID, String solutions){
            this.status = status;
            this.code = code;
            this.message = message;
            this.description = description;
            this.errors = errors;
            this.orderNumber = orderNumber;
            this.correlationId = correlationId;
            this.solutionid = solutionid;
            this.basketid = basketid;
            this.configGUID = configGUID;
            this.solutions = solutions;

        }
    }
    public static RestResponse generateResponse(RestResponse response, Map<String,String> responseMap, Map<String,String> responseHeaders) {
        ResultData rsData = new ResultData(responseMap.get('code'),
                                           responseMap.get('status'),
                                           responseMap.get('solutionid'),
                                           responseMap.get('basketid'),
                                           responseMap.get('correlationId')                                           ,
                                           responseMap.get('description'),
                                           responseMap.get('orderNumber'),
                                           responseMap.get('message'),
                                           responseMap.get('errors'),
                                           responseMap.get('configGUID'),
                                           responseMap.get('solutions'));
        String jsonResponse = JSON.serialize(rsData,true);
        jsonResponse = jsonResponse.replace('correlationId','CorrelationId__c');
        jsonResponse = jsonResponse.replace('orderNumber','Order_Number__c');
        jsonResponse = jsonResponse.replace('solutionid','Solution_Id__c');
        jsonResponse = jsonResponse.replace('basketid','Basket_Id__c');
        jsonResponse = jsonResponse.replace('configGUID','configGUID');
        jsonResponse = jsonResponse.replace('\"[','[');
        jsonResponse = jsonResponse.replace(']\"',']');
        jsonResponse = jsonResponse.replace('\\"','\"');
        response.responseBody = Blob.valueOf(jsonResponse);
        response.statusCode = Integer.valueOf(rsData.code); 
        
        if(responseHeaders != null){
            for (String key : responseHeaders.keySet()){
                response.addHeader(key,responseHeaders.get(key));
            }
        }
        else 
            response.addHeader('Content-Type','application/json');

        return response;
    }
}