public class FNNAvailabilityController {
    public static List<String> fnnList = new List<String>();
    public static Boolean isFNNValid=True;
    static final String CHECKFNN ='(^(0)[23478][0-9]{8})|(^1800[0-9]{6})|(^1300[0-9]{6})|(^1[32][0-9]{4})';
    public static Map<String, FNNManager> fnnMap = new Map<String, FNNManager>();
    
    private FNNAvailabilityController(){
    	
    }
    //Add fnn
    @AuraEnabled
    public static List<String> initalizeInput(){
        fnnList.add('');
        return fnnList;
    }
    
    //Check is FNN input are valid, if yes then check if they are portable and populate result.  
    @AuraEnabled
    public static Map<String, FNNManager> checkFNN(String fnnString){
        try{
            fnnMap=validateFNNList(fnnString);
			if(isFNNValid){
             checkPortability(fnnString);
            }   
            return fnnMap;
        }
        catch(Exception e){
            Logger.getLogger(FNNAvailabilityController.class).debug(e);
            Logger.exitLogger();
        }
        return null;
    }
    
    //Check if the FNN are portable
	public static  Map<String, FNNManager> checkPortability(String fnnString){
     try{
         fnnList=deserializeFNNList(fnnString);
         //Populate requestDTO with list of FNNs
         
            PortInSQRequestDTO sqReqDTO = new PortInSQRequestDTO();
            PortInSQRequestDTO.Data sqData = new PortInSQRequestDTO.Data();
         	
            sqData.fnns = fnnList;
            sqReqDTO.Data = sqData;
			
            //Request Call 
            PortInSQResponseDTO sqResDTO = SQManager.checkSQForPortability(sqReqDTO);
         	//PortInSQResponseDTO sqResDTO;
                        
            system.debug('req DTO' + sqResDTO);
            
            //Traversing and Iterating Response DTO 
         	if(sqResDTO.status!=200){
             	fnnMap=null;
         	}
         getResult(sqResDTO);
         system.debug('fnnMap' + fnnMap);
         return fnnMap;
     }
      catch(Exception e){
			Logger.getLogger(FNNAvailabilityController.class).debug(e);
            Logger.exitLogger();
          	throw(e);
      }
	}
    
    
    //Validate FNN Number
    public static boolean validateFnnNumber(String fnnNumber){
        try{
            if(Pattern.matches(CHECKFNN,fnnNumber)){
                return true;
            }
            return false;
        }
        catch(Exception e){
			Logger.getLogger(FNNAvailabilityController.class).debug(e);
            Logger.exitLogger();
            throw(e);
        }
    }
           
    //Validate FNN
    private static Map<String, FNNManager> validateFNNList(String fnnString){
        try{
            fnnList=deserializeFNNList(fnnString);
			for(Integer i=0;i<fnnList.size();i++)
			{
                FNNManager fnnObject=new FNNManager();
                if(validateFnnNumber(fnnList[i])){
                    fnnObject.reason='';
            		fnnObject.result='';
                    fnnMap.put(fnnList[i],fnnObject);
                }
                else{
                    fnnObject.reason=System.Label.ERROR_INVALID_FNN;
            		fnnObject.result='Not Valid';
                    fnnMap.put(fnnList[i],fnnObject);
                    isFNNValid=False;
                }
			}
            return fnnMap;
       	 }
        catch(Exception e){
           Logger.getLogger(FNNAvailabilityController.class).debug(e);
           Logger.exitLogger();
           throw(e);
        }
    }
    
    //Deserialize FNNList
    private static List<String> deserializeFNNList(String fnnString){
        try{
        	fnnList = (List<String>)JSON.deserialize(fnnString, List<String>.class);
            return fnnList;
        }
        catch(Exception e){
        	Logger.getLogger(FNNAvailabilityController.class).debug(e);
            Logger.exitLogger();
            throw(e);
        }
    }
    
    //Call Interface
    public static  Map<String, FNNManager> getResult(PortInSQResponseDTO sqResDTO){
        List<PortInSQResponseDTO.NumberDetails> sqNumberList;
        List<PortInSQResponseDTO.ErrorDetails> sqErrorList;
        try{
        	PortInSQResponseDTO.Data sqNumberDetails = sqResDTO.Data;
            PortInSQResponseDTO.Errors sqErrorDetails = sqResDTO.Errors;
            if(sqNumberDetails!=null){
                sqNumberList=sqNumberDetails.numberDetails;
                for(Integer i=0;i<sqNumberList.size();i++){
                	FNNManager fnnObject=new FNNManager();
                	if(fnnMap.containsKey(sqNumberList[i].fullNationalNumber)){
                    	fnnObject.reason=sqNumberList[i].reason;
	                    fnnObject.code=sqNumberList[i].code;
            			fnnObject.fnnPortabilityIndicator=sqNumberList[i].fnnPortabilityIndicator;
                    	fnnMap.put(sqNumberList[i].fullNationalNumber,fnnObject);
                	}
         		}
            }
            if(sqErrorDetails!=null){
                sqErrorList=sqErrorDetails.errorDetails;
                for(Integer i=0;i<sqErrorList.size();i++){
                	FNNManager fnnObject=new FNNManager();
                	if(fnnMap.containsKey(sqErrorList[i].fullNationalNumber)){
                    	fnnObject.reason=sqErrorList[i].message;
                    	fnnObject.code=sqNumberList[i].code;
                    	fnnMap.put(sqErrorList[i].fullNationalNumber,fnnObject);
                	}
         		}
            }
            return fnnMap;
    }
        catch(Exception e){
        	Logger.getLogger(FNNAvailabilityController.class).debug(e);
            Logger.exitLogger();
          	throw(e);
        }
    }
}