global with sharing class ReactivateMSISDNService implements Queueable, Database.AllowsCallouts{
    
    public List<String> mobileNumberList;
    public Integer calloutCounter;
    public Logger2 logger;
    public String handlerName;
    
  
    public ReactivateMSISDNService(List<String> ListOfNumbers){
        this.mobileNumberList=ListOfNumbers;
        this.calloutCounter = 0;
        this.handlerName = 'HeldToReserveMSISDNHandler';
        this.logger = Logger2.getLogger(handlerName);
    }
    
    public void execute(QueueableContext context) {
        //String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        String token = AuthenticationManager.getOauthToken(handlerName);
        calltoMSISDN(token);        
    }
    
      public void calltoMSISDN(String token){
        String reqBody;
        List<HttpResponse> HttpResponseList = new List<HttpResponse>();
        HttpResponse adResponse;
       
        try {
            for(String mobileNumber :mobileNumberList){
                Map<String,String> headerMap = new Map<String, String>();
                headerMap.put('Accept','application/json'); 
                headerMap.put('Content-type','application/json');
                headerMap.put('Authorization','Bearer '+token);
                headerMap.put('X-HTTP-Method-Override','PATCH');
                //String reqBody = JSON.serialize(fnnDTOList,true);
                reqBody = '{"data":{"activityName":"RESERVE"}}';
                Map<String, String> pathMap = new Map<String, String>{'msisdn' => mobileNumber};
                    
                 adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST,headerMap,handlerName, pathMap);
                calloutCounter++;
                HttpResponseList.add(adResponse);
            }
            if(calloutCounter == mobileNumberList.size()){
                for(HttpResponse res : HttpResponseList){
                   
                    //if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {
                    if(res!= null)
                    logger.logMessages(reqBody, res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) , null, null, null);
                    logger.exitLogger();  
                    // }
                    }
                    
            }
        }
        catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
        }
        }

}