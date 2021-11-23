/*
* @Author : Robin Chawla
* @Date : 10 May 2019
* @Desc : Get Address data from East using adbor id and Upsert it in salesforce 
* @Jira : EDGE-72118  Validate ADBOR id provided by Replicator with EASTsystem prior 
*         to using that site information in CPQ journey.
*@TestClass: NBNEastCalloutTest @methods:eastCalloutAndUpsertAddressAndSiteSuccessTest(),eastCalloutAndUpsertAddressAndSiteFailureTest
*/
public class NBNEastCallout implements Queueable , Database.AllowsCallouts{
    public static final String NBN_EAST = 'AddressValidateServiceByAdborId';

    Private AddressRequestDTO addressRequestDTOObj=null; 
    Private String adborID=null;
    Private ReplicatorGetSiteDataObject replicatorAddress=null; 
   
    Public NBNEastCallout(AddressRequestDTO addressRequestDTOObj,String adborID,ReplicatorGetSiteDataObject replicatorAddress){
        
        this.addressRequestDTOObj=addressRequestDTOObj;
        this.adborID=adborID;
        this.replicatorAddress=replicatorAddress;
    } 
    
    //EDGE-72118 This method is executed when System.enqueue method is called from AddressAndSiteObjectUtility class
    Public void execute(QueueableContext context){
        String urlParam = addressRequestDTOObj.getEncodedURLParam();
        getAndUpsertAddressByAdborId(urlParam,NBN_EAST);
        AddressAndSiteObjectUtility.upsertReplicatorAddressAndSite(adborID,replicatorAddress);
    }
    
  
   // EDGE-72118 get Address from East and upsert it in salesforce
    public static void getAndUpsertAddressByAdborId(String urlParam, String handlerName){
        AddressResponseDTO addressResponseDTOObj;
        HTTPResponse adResponse = new HTTPResponse();
        Long requestTime= null;  
        Logger2 logger2 = Logger2.getLogger(NBNEastCallout.class);
        
        try{
            String token = AuthenticationManager.getOauthToken(NBN_EAST);
            
            Map<String,String> headerMap = new Map<String, String>{'Accept' => 'application/json','Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            DateTime startTime = DateTime.now();
            adResponse = IntegrationRecordHandlerUtil.callout(urlParam, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName,null, null);
            DateTime endTime = DateTime.now();
		    requestTime = logger2.getRequestTimeDifference(startTime, endTime);
            addressResponseDTOObj = AddressResponseDTO.parse(adResponse.getBody());           
            if(addressResponseDTOObj!=null && addressResponseDTOObj.code==200 && addressResponseDTOObj.ErrorCode==null){
                
                AddressAndSiteObjectUtility.upsertNBNEastAddress(addressResponseDTOObj);
                logger2.logMessages(urlParam,adResponse.getBody(),'','','','',String.ValueOf(adResponse.getStatusCode()),'','','','','',requestTime,'',false,false);
            	logger2.exitLogger();
            }
            else{
                logger2.logMessages(urlParam,adResponse.getBody(),'','','','',String.ValueOf(adResponse.getStatusCode()),'','','','','',requestTime,'',false,false);
           		logger2.exitLogger();
            }
        }catch(Exception e){
             logger2.logMessages('NBNEastCallout:getAndUpsertAddressByAdborId',e.getMessage() , '', '', '', '', false, false, null , null, null, null); 
            logger2.exitLogger();
            
        }
    }
}