global with sharing class GetOrderSpecAPIResponse {
    public cls_response response;
    public class cls_response{
        public Integer code;
        public Integer status;
        public string message;
        public Errors errors; 
    }
    public class Errors {
        public Integer code;
        public String field;
        public String message;
        
    } 
    
    public GetOrderSpecAPIResponse(){
        
    }
    
    public static GetOrderSpecAPIResponse generateResponse(Integer code, Integer status, string message,Integer errCode,string field,string errMessage){
        GetOrderSpecAPIResponse resobj =  new GetOrderSpecAPIResponse();
        GetOrderSpecAPIResponse.cls_response clsResObj = new GetOrderSpecAPIResponse.cls_response();
        GetOrderSpecAPIResponse.Errors errObj = new  GetOrderSpecAPIResponse.Errors();
        errObj.code = errCode;
        errObj.field = field;
        errObj.message = errMessage;
        // resobj.errors = errObj;
        clsResObj.code = code;
        clsResObj.status = status;
        clsResObj.message = message;
        clsResObj.errors =errObj;
        resobj.response=clsResObj;
        return resobj;
    }
}