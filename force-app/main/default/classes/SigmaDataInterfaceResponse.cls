global with sharing class SigmaDataInterfaceResponse {
   
    public cls_status status;
    
    public class cls_status{ 
        public string code;
   		public string message;
    	public string timestamp;
		public cls_status(String code, String message, String timestamp){
			this.code=code;
			this.message=message;
			this.timestamp=timestamp;		
		}
		
    }
    
    public SigmaDataInterfaceResponse(){
        
    }
    
    public static SigmaDataInterfaceResponse genresponse(String code, string message, string timestamp){
        SigmaDataInterfaceResponse resobj =  new SigmaDataInterfaceResponse();
        resobj.status=new SigmaDataInterfaceResponse.cls_status(code, message, timestamp);
        return resobj;
    }
    

}