/**

* Class Name : ValidateSIMInterface
============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta        2/12/2020              EDGE-192401

****************************************************************************************************************************
*/
public class ValidateSIMInterface {
     private static final String LRM_Success = 'LRM Success';
     private static final String LRM_Failure = 'LRM Failure';
    /* This 
    
    */
    @AuraEnabled
    public static Map<String,Map<String,String>> ValidateSimSerial(Map<String,String> simSerialSImtypeMap,Boolean imsiRequired,Boolean allRequired,List<String> names){
        Boolean imsiRequd = false;
        Boolean allReqd = false;
        Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        if(simSerialSImtypeMap.isEmpty()){
            Map<String,String> responseMap = new Map<String,String>();
            responseMap.put('422',getErrorMsg(422));
            resMap.put(LRM_Failure,responseMap);
        }else{
            List<String> simSerialNums = new List<String>();
            simSerialNums.addAll(simSerialSImtypeMap.keySet());
            SimRequestDTO reqDTO = new SimRequestDTO();
            reqDTO.simSerialNumbers = simSerialNums;
            if(imsiRequired!=null){
                reqDTO.imsiRequired = imsiRequired;
            }else{
                reqDTO.imsiRequired = imsiRequd;
            }
            SimRequestDTO.Attributes reqAttr=new SimRequestDTO.Attributes();
            if(allRequired!=null){
                reqAttr.allRequired = allRequired;
            }else{
                reqAttr.allRequired = allReqd;
            }
            
            reqAttr.names = names;
            reqDTO.attributes = reqAttr;
            String body = Json.serialize(reqDTO, true);
            
            resMap = processLRMSIMaSCallout(body,simSerialSImtypeMap);
            system.debug('body'+body);
        }
        
        return resMap;
    }
    
    public static Map<String,Map<String,String>> processLRMSIMaSCallout(String body ,Map<String,String> simSerialSImtypeMap){
        Map<String,Map<String,String>> respMap = new Map<String,Map<String,String>>();
        Map<String,String> responseMap = new Map<String,String>();
        String handlerName = 'LRMSIMaSHandler';
        Logger2 logger = Logger2.getLogger(handlerName);
        HttpResponse adResponse;
        String token = '';
        
        Integration_Handler__mdt handlerMetaData = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        if(!Test.isRunningTest()){
            token = Orchestration_CalloutUtility.getOauthToken(handlerMetaData);
        }
        system.debug('token27'+token);
        if (String.isBlank(token)) {
            system.Debug('blank token');
        }
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + token, 'Source-System' => 'SFDC' ,'Accept' => 'application/json'};
            DateTime startTime = DateTime.now();
            system.debug('Body'+body);
            system.debug('headerMap'+headerMap);
            system.debug('handlerMetaData'+handlerMetaData);
        adResponse = Orchestration_CalloutUtility.sendRequestGeneric(body, Orchestration_CalloutUtility.HTTP_METHOD_POST, headerMap, handlerMetaData, null);
        //calling mock
        //adResponse = getMockRes();
        DateTime endTime = DateTime.now();
        Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
        logger.logMessages(body, adResponse.getBody(), '', '', '', '', String.valueOf(adResponse.getStatusCode()), '', '','','Read','',requestTime ,Orchestration_CalloutUtility.HTTP_METHOD_POST,true, false);
        system.debug('adResponse67'+adResponse);
        system.debug('adResponse68'+adResponse.getStatusCode());
        if(adResponse.getStatusCode() == 200){
            system.debug('Inside if');
            SimResponseDTO responseDTO = SimResponseDTO.parse(adResponse.getBody());
            system.debug('responseDTO:'+responseDTO);
            system.debug('simSerialSImtypeMap:'+simSerialSImtypeMap);
            respMap = handlingOfResponse(responseDTO,simSerialSImtypeMap);
    //  INC000097267068 Fix - added another if condition for status 404 
        }else if(adResponse.getStatusCode() == 404){
            system.debug('Inside if');
            SimResponseDTO responseDTO = SimResponseDTO.parse(adResponse.getBody());
            system.debug('responseDTO:'+responseDTO);
            system.debug('simSerialSImtypeMap:'+simSerialSImtypeMap);
            respMap = handlingOfResponse(responseDTO,simSerialSImtypeMap);
        }else{
            system.debug('Inside else' + adResponse.getStatusCode());
            responseMap.put(String.ValueOf(adResponse.getStatusCode()),getErrorMsg(adResponse.getStatusCode()));
            respMap.put(LRM_Failure,responseMap);
            
        }
        
        return respMap;
        
    }
    
     public static HttpResponse getMockRes(){
    HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":200,"code":200,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-PARTIAL-SUCCESS","message":"Requested SIM[s] details partially found. Please refer to errors for further assistance","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","errors":[{"simNumber":"8200050137412","message":"SIM details not found","code":"LRM-RESOURCE_NOT_FOUND"},{"simNumber":"82000501374422","message":"Invalid SIM number","code":"LRM-LRM-INVALID_DATA"},{"simNumber":"82000501374433","message":"LRM ERROR","code":"LRM-ERROR"}],"data":{"resources":[{"resourceId":"8200050137442","resourceType":"ICCID","resourceState":"AVAILABLE","characteristics":[{"name":"SIM Type","value":"3GUniversal"},{"name":"SIM Category","value":"3G Standard SIM"},{"name":"Order ID","value":"0300898383"}]},{"resourceId":"82000501374452","resourceType":"ICCID","resourceState":"Active","characteristics":[{"name":"SIM Type","value":"3GUniversal"},{"name":"SIM Category","value":"3G Standard SIM"},{"name":"Order ID","value":"0300898383"}]}]}}');


        res.setStatusCode(200);
        return res;
  }
    
    public static String getErrorMsg(Integer code){
        String ErrorMsg = '';
        if(code == 401){
            ErrorMsg = 'Invalid or no credentials passed in the request';
        }else if(code == 502){
            ErrorMsg = 'Error while processing information';
        }else if(code == 500 || code == 503){
            ErrorMsg = 'LRM General Error';
        }else if(code == 400){
            ErrorMsg = 'Requested SIM[s] details not found from LRM';
        }else if(code == 422){
            ErrorMsg = 'Invalid request. simSerialNumbers cannot be null/empty';
        }else{
            ErrorMsg = 'Error while processing information';
        }
        return ErrorMsg;
    }
  
    public static Map< String,Map<String,String>> handlingOfResponse(SimResponseDTO res,Map<String,String> simnumSimTypeMap ){
        Map<String,Map<String,String>> responseMap = new Map<String,Map<String,String>> ();
        Map<String,String> finalResponseMap = new Map<String,String>(); 
        Map<String,String> resIdSimCatMap = new Map<String,String> ();
        Map<String,String>simCatsimTypemap = new Map<String,String>();
        
        List<SIM_Category__mdt> simCatList = [select SIM_Category__c,SIM_Type__c from SIM_Category__mdt];
        for (SIM_Category__mdt meta :simCatList){
            simCatsimTypemap.put(meta.SIM_Category__c,meta.SIM_Type__c);
        }
        
        system.debug('simCatList:'+simCatList);
        system.debug('simCatsimTypemap:'+simCatsimTypemap);
        if(res!= null && simnumSimTypeMap!= null) {
        if(res.errors!= null){
            List<SimResponseDTO.errors> errList = res.errors;
            if(!errList.isEmpty()){
                for(SimResponseDTO.Errors err :errList){
                    if(err.code.equalsIgnoreCase('LRM-RESOURCE_NOT_FOUND')){
                        finalResponseMap.put(err.simNumber,Label.SIM_Invalid);//'SIM Serial you entered is not valid'
                    }
                    else if(err.code.equalsIgnoreCase('LRM-LRM-INVALID_DATA')){
                        finalResponseMap.put(err.simNumber,err.message);
                    }
                    else{
                        finalResponseMap.put(err.simNumber,err.message);
                    }
                }
                responseMap.put(LRM_Failure,finalResponseMap); // INC000097267068 Fix
            }
        }
        
        if(res.data!= null && res.data.resources!= null){
         List<SimResponseDTO.Resources> resources = res.data.resources;
        for(SimResponseDTO.Resources rec :resources){  
            
            for(SimResponseDTO.Characteristics rec1 :rec.characteristics){
                if(rec1.name.equalsIgnoreCase('SIM Category')){
                    resIdSimCatMap.put(rec.resourceId ,rec1.value);
                }
            }
         
            System.debug('rec.resourceId: '+rec.resourceId);
             System.debug('resIdSimCatMap: '+resIdSimCatMap);
            
            if(rec.resourceState.equalsIgnoreCase('AVAILABLE') && simnumSimTypeMap.get(rec.resourceId)==simCatsimTypemap.get(resIdSimCatMap.get(rec.resourceId)))//EDGE-192401
            {
                finalResponseMap.put(rec.resourceId,rec.resourceState);
            }
            else if(!rec.resourceState.equalsIgnoreCase('AVAILABLE'))//EDGE-192401
            {
                finalResponseMap.put(rec.resourceId,Label.SIM_Available);//'SIM Serial you entered is not in available state'
              
            }
            else if(simnumSimTypeMap.get(rec.resourceId)!=simCatsimTypemap.get(resIdSimCatMap.get(rec.resourceId)))
            {
                
                finalResponseMap.put(rec.resourceId,Label.SIM_type_Invalid);//'SIM type you entered is not valid'
            }
            System.debug('finalResponseMap: '+finalResponseMap);
            
        }
            
        responseMap.put(LRM_Success,finalResponseMap);
        
        }
        }
        return responseMap;
    } 
    

}