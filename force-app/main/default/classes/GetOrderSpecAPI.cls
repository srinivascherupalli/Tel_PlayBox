/**
* This class is to handle the POST API request for Custom wrapper API to support high volume orders.
* Developer: Vanita Mude
* Date: 10 June 2019
* Description: EDGE-86669 expose OrderSpecs via Custom wrapper API to support high volume orders
* Modified :Manjunath Ediga Added OrderNum__c as a part of EDGE: 105942 for getting Order specification details with Order Number as input
*/
public class GetOrderSpecAPI extends ffrest_ICustomRESTAPI {
    public final static Integer ERR_422 = 422;
    public final static Integer ERR_404 = 404;
    public final static Integer ERR_500 = ffrest_ICustomRESTAPI.ERR_500;
    
    public final static Integer CODE_1000 = 1000;
    public final static Integer CODE_1001 = 1001;
    public final static string ERR_MSG_VALIDATIONFAILED = 'Validation failed'; 
    public final static string ERR_MSG_CORIDNOTPRESENT = 'CorrelationId__c does not exist in CS';
    //Start of EDGE: 105942: appended OrderNum__c Number to display error message when OrderID or Order Number is null
    //Changed OrderNum__c  to Order_Number__c which is failing at MS
    public final static string ERR_MSG_ORDERIDNOTPRESENT = 'OrderID__c/Order_Number__c does not exist in CS';
    public final static string CORID = 'CorrelationId__c';
    public final static string ORDID = 'OrderID__c/Order_Number__c';
    //End of EDGE: 105942
    
    RestRequest request=RestContext.request;
    public String reqBody=request.requestBody.toString();
    
    //overriding method of ffrest_ICustomRESTAPI
    public virtual void handleRequest(){
        
        try{
            switch on request.httpMethod{
                when 'POST'{
                    handlePost();
                }
                when else{
                    handleOtherRequests();
                }
            }
        }
        catch(Exception e){
            RestResponse response=RestContext.response;
            response.statusCode=ERR_500;
            GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_500,ERR_500,ffrest_ICustomRESTAPI.ERR_MSG_500,ERR_500,ORDID,ffrest_ICustomRESTAPI.ERR_MSG_500);
            response.responseBody=Blob.valueOf(JSON.serialize(respBody));
            response.addHeader('Content-Type', 'application/json;charset=UTF-8');
            response.addHeader('Transfer-Encoding', 'chunked');
            Logger2 logger=Logger2.getLogger(GetOrderSpecAPI.class);
            logger.logMessages(reqBody,(RestContext.response.responseBody).toString(),e.getStackTraceString(),'Technical','Exception',e.getMessage(), false, false);
            logger.exitLogger();
            throw e;
        }
    }
    //method to handle all other requests.
    public virtual void handleOtherRequests(){
        //for Requests except 'POST'
        throw new GetOrderSpecAPIException('Exception in GetOrderSpecAPI class');
    }
    
    
    //method to handle POST request
    public virtual void handlePost(){
        GetOrderSpecAPIRequestDTO reqDTO = GetOrderSpecAPIRequestDTO.parse(reqBody);
        GetOrderSpecAPIPostHandler handler;
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> finalServiceSpecification = new Map<String,List<CS_SpecificationDTO.ServiceSpecification>>();
        String str;
        System.debug('reqDTO==>'+reqDTO);
        RestResponse response=RestContext.response;
        //GetOrderSpecAPIPostHandler handler = new GetOrderSpecAPIPostHandler(reqBody);
        //System.debug('reqBody===>'+reqBody);
        
        String orderId = reqDTO.OrderID;
        //System.debug('orderId==>'+orderId);
        String targetSystem = reqDTO.targetSystem;
        String Order_Number = reqDTO.Order_Number;
        Set<id> setServiceIds = new Set<id>();
        if(reqDTO.serviceId != null){
            for(GetOrderSpecAPIRequestDTO.serviceId i : reqDTO.serviceId){
                setServiceIds.add(i.Id);
            }
        }
        if(setServiceIds != null && !setServiceIds.isEmpty()){
            finalServiceSpecification = HVMS_GetOrderSpecsAPIHandler.getAllServSpecsFromService(setServiceIds, targetSystem, orderId);
            System.debug('finalServiceSpecification==>'+finalServiceSpecification);    
        }else{
            handler = new GetOrderSpecAPIPostHandler(reqBody);
        }
        //Added OrderNum__c as a part of EDGE: 105942
        try{
            if(finalServiceSpecification != null && !finalServiceSpecification.isEmpty()){
                str = HVMS_GetOrderSpecsAPIHandler.getOrderSpecs(orderId,targetSystem,Order_Number , finalServiceSpecification);//EDGE: 105942 - Added orderNum
                System.debug('str==>'+str);
            }else{
                str = handler.getOrderSpecs(orderId,targetSystem,Order_Number);
                System.debug('str==>'+str);
            }
            if(reqDTO.CorrelationId == null || reqDTO.CorrelationId == ''){
                response.statusCode=ERR_422;
                GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_422,ERR_422,ERR_MSG_VALIDATIONFAILED,CODE_1000,CORID,ERR_MSG_CORIDNOTPRESENT);
                response.responseBody=Blob.valueOf(JSON.serialize(respBody));
                response.addHeader('Content-Type', 'application/json;charset=UTF-8');
                response.addHeader('Transfer-Encoding', 'chunked');
            }//Start of EDGE: 105942 : Added orderNum check in below condition ensuring both orderNum and OrderID are not empty in the REST Request
            else if((reqDTO.OrderID == null || reqDTO.OrderID == '') && (reqDTO.Order_Number == null ||reqDTO.Order_Number == '') ){
                //System.debug('reqDTO.OrderID==>'+reqDTO.OrderID);
                response.statusCode=ERR_422;
                GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_422,ERR_422,ERR_MSG_VALIDATIONFAILED,CODE_1001,ORDID,ERR_MSG_ORDERIDNOTPRESENT);
                response.responseBody=Blob.valueOf(JSON.serialize(respBody));
                response.addHeader('Content-Type', 'application/json;charset=UTF-8');
                response.addHeader('Transfer-Encoding', 'chunked');
             //EDGE-217119 Added by Nikhil part of B2B 1260 Fixes
            }else if(str ==  'Manage Fixed Numbers'){   
                response.responseBody=Blob.valueOf('{"data":[]}');
                response.addHeader('Content-Type', 'application/json;charset=UTF-8');
                response.addHeader('Transfer-Encoding', 'chunked');
            //EDGE-217119 END
            }else if(str == ''){                
                response.statusCode=ERR_422;
                GetOrderSpecAPIResponse respBody=GetOrderSpecAPIResponse.generateResponse(ERR_422,ERR_422,ERR_MSG_VALIDATIONFAILED,CODE_1001,ORDID,ERR_MSG_ORDERIDNOTPRESENT);
                response.responseBody=Blob.valueOf(JSON.serialize(respBody));
                response.addHeader('Content-Type', 'application/json;charset=UTF-8');
                response.addHeader('Transfer-Encoding', 'chunked');
            }
            else{               
                response.responseBody=Blob.valueOf(str/*handler.getOrderSpecs(orderId,targetSystem,Order_Number)*/);   //EDGE: 105942 - Added orderNum            
                response.addHeader('Content-Type', 'application/json;charset=UTF-8');
                response.addHeader('Transfer-Encoding', 'chunked');
                
            }
        }catch(Exception e){
            throw e;
        }
    }
    
    
    //custom Exception
    public class GetOrderSpecAPIException extends Exception{}
    
}