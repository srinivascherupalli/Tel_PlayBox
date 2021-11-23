/*------------------------------------------------------------ 
Company: Telstra 
Description: Controller for the Address search 
Test Class: AddressSearchTest 
History :
<18-04-2019> <Kalashree Borgaonakar> <EDGE-76217 Updated the class for mapping> 
------------------------------------------------------------*/
public with sharing class AddressSearch
{    
    
    
    /*------------------------------------------------------------ 
EDGE-76217
Method: saveAddressApex 
Description: Creates the Address record using response received from AddressSq
Inputs: AddressRequest , Handler name, adborid 
Returns: List of address to display on UI 
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    public static List<AddressSummary> searchUnStructuredAddress(AddressRequest addressDTO,String handler,String adborid){
        
        AddressResponseDTO adResponse ;
        String reqTest = '';
        reqTest = 'test';
        String test;
        List<AddressSummary> addressList = new List<AddressSummary>();
        if(handler.equalsIgnoreCase('AdborIdAddressHandler')){
            adResponse = searchAdborIdAddress(adborid,handler); 
            system.debug('searchadResponse++**' +adResponse);
            addressList = returnNBNAddresses(adResponse,true,handler);
            return addressList;
        }else{
            adResponse= searchAddress(addressDTO,handler);//change this
            addressList = returnNBNAddresses(adResponse,false,handler);
            return addressList;
        }
        //return addressList;
    }
    
    public static cscrm__Address__c searchAutoAdd(AddressRequest addressDTO,String handler){
        AddressResponseDTO adResponse ;
        adResponse= searchAddress(addressDTO,handler);
        system.debug('adResponse Auto' +adResponse);
        cscrm__Address__c addr = new cscrm__Address__c();
        addr = AddressAndSiteObjectUtility.upsertnbnStructured_Auto(adResponse);
        return addr;
    }
    
    
    public static List<String> searchAutocomplete(String handler,String searchUnstructured){
        AddressResponseDTO adResponse ;
        String reqTest = '';
        reqTest = 'test';
        List<String> addressAutoList= new List<String>() ;
        if(handler.equalsIgnoreCase('UnStructuredAutocompleteHandler')){
            adResponse = searchUnstructredAdd(searchUnstructured,handler); 
            system.debug('searchadResponse++**' +adResponse);
            if(adResponse==null){
                return null;
            }else{
                addressAutoList = returnAddressName(adResponse,handler);
                
            }
        }
        if(addressAutoList==null){
            return null;
        }else{
            system.debug('addressAutoList++' +addressAutoList);
            return addressAutoList;
        }
    }
    
    public static List<AddressSummary> returnNBNAddresses(AddressResponseDTO adResponse ,Boolean isAdborSearch,String handler){
        System.debug('returnAddresses::' + adResponse + ',' + handler);
        List<AddressSummary> addressList = new List<AddressSummary>();
        if(isAdborSearch == true && adResponse != NULL){ 
            AddressResponseDTO.UnstructuredAUPost unstruct ;
            if(adResponse.Data ==NULL || (adResponse.Data !=NULL && adResponse.Data.matchingresultscount != NULL && adResponse.Data.matchingresultscount==0)){
                AddressSummary addSum = new AddressSummary();
                addSum.responseStatus = adResponse.status;
                system.debug('addSum.responseStatus'+ addSum.responseStatus);
                addSum.addNotFound = Label.SQ_address_unavailable;
                addressList.add(addSum);
                system.debug('addressListError'+addressList);
                return addressList;
            }
            else if(adResponse.Data.unstructuredAUPost!=null && adResponse.Data.UnstructuredAUPost.addresses!=null){
                unstruct = adResponse.Data.unstructuredAUPost;
                AddressSummary addSum = new AddressSummary(unstruct);
                addSum.responseStatus = adResponse.status;
                addressList.add(addSum);
            }
            return addressList;
        }else if(adResponse!=null && adResponse.DataZ !=NULL){
            if(adResponse.DataZ.resultCount != NULL && adResponse.DataZ.resultCount==0 ) {
                AddressSummary addSum = new AddressSummary();
                addSum.responseStatus = adResponse.status;
                addSum.addNotFound = Label.SQ_address_unavailable;
                addressList.add(addSum);
                return addressList;
            }
            else if(!adResponse.DataZ.UnstructuredAUPost.isEmpty()){
                for(AddressResponseDTO.UnstructuredAUPost unstruct: adResponse.DataZ.UnstructuredAUPost){
                    AddressSummary addSum = new AddressSummary(unstruct);
                    addSum.responseStatus = adResponse.status;
                    addressList.add(addSum);
                }
                List<AddressSummary> addList = getAddressSummaryList(adResponse.DataZ.Structured);
                addressList.addAll(addList);
                return addressList;
            }
        }  
        return null;
    }
    
    
    
    public static List<String> returnAddressName(AddressResponseDTO adResponse ,String handler){
        List<String> addressRetList = new List<String>();
        if(adResponse==null){
            return null;
        }else{
            
            for(AddressResponseDTO.results addrname:adResponse.results){
                String adname=addrname.name;
                
                //AddressSummary addSum = new AddressSummary(addrname);
                //addSum.addname.add(addrname);
                addressRetList.add(adname);
            }
            
        }
        
        if(addressRetList==null){
            return null;
        }else{
            system.debug('addressRetList++' +addressRetList);
            return addressRetList;
        }
        
    }
    
    
    public static AddressResponseDTO searchUnstructredAdd(String searchUnstructured, String handler){
        String handlerName = handler;
        system.debug('handlerName++' +handlerName);
        String reqTest =handler;
        reqTest = handler;
        Logger2 logger = Logger2.getLogger(handlerName);
        AddressResponseDTO res = new AddressResponseDTO();
        HttpResponse response;
        try{
            String urlAutoComplete = getEncodedURLUnstruct(searchUnstructured);
            System.debug('urlAutoComplete++' +urlAutoComplete);
            if(urlAutoComplete == null){
                return null;
            }else{ 
                
                String token= AuthenticationManager.getOauthToken(handlerName);
                //String token= '8dieVAcAq9obj4sbwqmm';
                
                Map<String,String> headerMap = new Map<String, String>{'Authorization'=> 'Bearer ' + token};
                    
                    response = calloutAdborUnstruct(urlAutoComplete,IntegrationRecordHandlerUtil.HTTP_METHOD_GET,headerMap,handlerName,null,null);
                String responseCode = String.valueOf(response.getStatusCode());
                System.debug('addressResCode: '+response);   
                if (responseCode.startsWith('2')) {
                    res=AddressResponseDTO.parse_unstruct(response.getBody());
                    System.debug('addressRes: '+res);
                    logger.logMessages(urlAutoComplete, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
                }
                else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                    res=AddressResponseDTO.parse_unstruct(response.getBody());
                    system.debug('Sattuscode404' +res);
                    logger.logMessages(urlAutoComplete, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
                }
                logger.exitLogger();
            }
            
            
        }catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        system.debug('finalsearchreturn' +res);
        return res;
        
        
    }   
    
    
    /*------------------------------------------------------------ 
EDGE-76217
Method: searchAdborIdAddress 
Description: Callout to Address SQ interface, changed return type to AddressResponseDTO
Inputs: adborId , Handler name
Returns: 
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    public static AddressResponseDTO searchAdborIdAddress(String adborId,String handler){
        String correlationid = EDISSingleManager.getUID();
        String handlerName = handler;
        String reqTest =handler;
        reqTest = handler;
        Logger2 logger = Logger2.getLogger(handlerName);
        AddressResponseDTO res = new AddressResponseDTO();
        HttpResponse response;
        try{
            String urlAdbor = getEncodedURLParam(adborId);
            System.debug('urlAdbor++' +urlAdbor);
            if(urlAdbor == null){
                return null;
            }else{ 
                
                String token= AuthenticationManager.getOauthToken(handlerName);
                
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','accept'=>'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
                    //response = IntegrationRecordHandlerUtil.calloutAdbor(urlAdbor,IntegrationRecordHandlerUtil.HTTP_METHOD_GET,headerMap,'AdborIdAddressHandler',null,null);
                    response = calloutAdborUnstruct(urlAdbor,IntegrationRecordHandlerUtil.HTTP_METHOD_GET,headerMap,handlerName,null,null);
                String responseCode = String.valueOf(response.getStatusCode());
                System.debug('addressRes: '+response);   
                if (responseCode.startsWith('2')) {
                    res=AddressResponseDTO.parse(response.getBody());
                    System.debug('addressRes: '+res);
                    logger.logMessages(urlAdbor, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
                    
                }
                else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                    res=AddressResponseDTO.parse(response.getBody());
                    logger.logMessages(urlAdbor, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
                }
                logger.exitLogger();
                return res;
            }            
        }catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return res;        
    }   
    
    public static AddressResponseDTO searchAddress(AddressRequest addressDTO, String handler){
        String correlationid = EDISSingleManager.getUID();
        String handlerName = handler;
        String reqTest =handler;
        reqTest = handler;
        String reqBody = JSON.serialize(addressDTO,true);
        System.debug('AddressRequest::' + reqBody);
        Logger2 logger = Logger2.getLogger(handlerName);
        AddressResponseDTO addressRes = new AddressResponseDTO() ;
        HttpResponse adResponse;
        try {
            
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
                adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            system.debug('adResponse::' + adResponse.getBody());
            String responseCode = String.valueOf(adResponse.getStatusCode());
            if (responseCode.startsWith('2')) {
                addressRes = AddressResponseDTO.parseStructure(adResponse.getBody());
                System.debug('addressRes: '+addressRes);
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
            }
            else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                addressRes = AddressResponseDTO.parseStructure(adResponse.getBody());
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return addressRes;
    }
    
    
    public static String getEncodedURLParam(String adborId){
        System.debug('adborId++' +adborId);
        String adborEndpoint = [Select End_Point__c from Integration_Handler__mdt where Label='AdborIdAddressHandler'].End_Point__c;
        String enddURL = '';
        enddURL = '>>';
        String encodedUrl = '';
        if(adborId == '' || adborId == null)
            return null;
        else
            encodedUrl = adborEndpoint+adborId+'?reqaddformatout=unstructuredAUPost,structured';
        System.debug('encodedUrl++' +encodedUrl);
        return encodedUrl;   
    }
    
    public static String getEncodedURLUnstruct(String searchUnstructured){
        String UnstructEP = [Select End_Point__c from Integration_Handler__mdt where Label='UnStructuredAutocompleteHandler'].End_Point__c;
        String encodedUrl = '';
        if(searchUnstructured=='' || searchUnstructured == null){
            return null;
        }else{
            encodedUrl = UnstructEP+searchUnstructured;
            System.debug('encodedUrl++' +encodedUrl);
            return encodedUrl; 
        }
    }
    
    
    public static HTTPResponse calloutAdborUnstruct(String EndpointAdbor, String method, Map<String,String> headerMap, String handlerName, List<String> params, String correlationId){
        String errorMessage = null;
        String endPoint=null;
        system.debug('EndpointAdbor++' +EndpointAdbor);
        Logger log = String.isBlank(correlationId) ? Logger.getLogger(handlerName) : Logger.getLogger(handlerName + ':' + correlationId);
        HTTPResponse res; 
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        
        Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        if(String.isBlank(EndpointAdbor)) {
            System.debug('Cannot make a callout without an Endpoint');
            return null;
        }
        HttpRequest req = new HttpRequest();
        if(method =='GET'){         
            req.setEndpoint(EndpointAdbor);
            system.debug('req++' +req.getEndpoint());
        }
        if(handleSettingRecord.Enable_MASSL__c) {
            System.debug('MASSL is enabled for interface');
            String certificateName = null;
            certificateName = EnvironmentVariable.get('massl_certificate_name');
            System.debug('Setting ' + certificateName + ' certificate for http call');
            if(certificateName!=null){
                req.setClientCertificateName(certificateName);
            }
        }
        req.setMethod(method);
        req.setTimeout(timeout);
        if(headerMap != null) {
            for(String hdName : headerMap.keySet()) {
                req.setHeader(hdName, headerMap.get(hdName));   
            }
        }
        try {
            Http http = new Http();
            res = http.send(req);
            System.debug('Response: ' + res.getBody());
            if(!handleSettingRecord.Is_Sync_Call__c){
                if(res.getStatusCode() != 200 && res.getStatusCode() != 202) { 
                    errorMessage = 'A HTTP error occurred' +  '\n' + 'Status Code: ' + res.getStatusCode() + '\n' + 'Status Message: ' + res.getStatus();   
                    IntegrationQueuableUtils.retry(handlerName, params, errorMessage); //retry                
                    System.debug('For handler: ' + handlerName + ' Error Response: '+ errorMessage);
                } else {
                    System.debug('For handler: ' + handlerName + ' got success Response');
                    IntegrationQueuableUtils.updateOnSucess(handlerName, params);
                }
                
            }
            
        } catch(System.Exception e) {
            System.debug(e);
            if(!handleSettingRecord.Is_Sync_Call__c){
                IntegrationQueuableUtils.retry(handlerName, params, (e.getMessage() + '\n\n' + e.getStackTraceString())); //retry     
            }       
        }
        finally {
            if(handleSettingRecord.Is_Sync_Call__c) {
                Logger.exitLogger();    
            }
        }
        System.debug('RecordIntegraionres' +res);
        return res;
        
    }
    
    /*------------------------------------------------------------ 
Story: EDGE-122625
Author: Kalashree Borgaonkar
Method: getAddressSummaryList 
Description: Display subaddresses
Inputs: adborId , Handler name
Returns: 
------------------------------------------------------------*/
    public static List<AddressSummary> getAddressSummaryList(List<AddressResponseDTO.Structured> addrStructList ) {
        
        list<AddressResponseDTO.level1> level1List=new list<AddressResponseDTO.level1>();
        list<AddressResponseDTO.level2> level2List=new list<AddressResponseDTO.level2>();
        list<AddressResponseDTO.level3> level3List=new list<AddressResponseDTO.level3>();
        map<String,String> level1ToPrimary = new map<String,String>();
        map<String,String> level2ToLevel1= new map<String,String>();
        map<String,String> level3ToLevel2 = new map<String,String>();
        map<String,String> mapPrimaryL1 = new map<String,String>();
        map<String,String> mapL1L2= new map<String,String>();
        map<String,String> mapL2L3 = new map<String,String>();				
        String postcode;
        String state;
        String locality;
        String aLineLevel1;
        String aLineLevel2;
        String aLine;
		String subadd;
        List<AddressSummary> addressSumList = new List<AddressSummary> ();
        for(AddressResponseDTO.Structured addStruct:addrStructList){
            String propFrom = String.valueof(addStruct.propertyNumberFrom);   
            if(propFrom !=null && addStruct.propertyNumberTo==''){
                aLine = propFrom;
            }
			subadd=AddressTriggerHandler.getAddressType(addStruct.streetType);
			subadd = (subadd=='LE'?'L':subadd);
			
            aLine = (aLine!=null?aLine:'') +' '+(addStruct.propertyNumberTo!=null?addStruct.propertyNumberTo : '') +' '+ (addStruct.streetName!=null?addStruct.streetName:'')  +' '+ (addStruct.streetType!=null?subadd:'');
            level1ToPrimary.put(addStruct.addressid,aLine);
            aLine='';
            postcode = addStruct.postcode;
            state=addStruct.state;
            locality=addStruct.localityName;
            System.debug('addStruct.subaddresses: '+addStruct.subaddresses);
            if(addStruct.subaddresses!=null && addStruct.subaddresses.level1!=null){
                for(AddressResponseDTO.Level1 level1:addStruct.subaddresses.level1){
                    mapPrimaryL1.put(String.valueof(level1.id),String.ValueOf(level1.parentid));				
                    String subAddL1 = AddressTriggerHandler.getAddressType(level1.SubAddressType);
					subAddL1 = subAddL1=='LE'?'L':subAddL1;
                    aLineLevel1= (subAddL1!=null?subAddL1:'') +' '+ (level1.levelFrom!=null?level1.levelFrom:'');
                    level2ToLevel1.put(String.valueOf(level1.id),aLineLevel1);	
                    if(level1.level2!=null){
                        level2List.addAll(level1.level2);
                    }
                    else{
                        AddressSummary addSum = new AddressSummary();
                        addSum.addressLine = (subAddL1!=null?subAddL1:'')+ ' '+ (level1.BUname!=null?level1.BUname:'') + ' ' +(level1.levelFrom!=null?level1.levelFrom:'') + ' '+level1ToPrimary.get(String.valueOf(level1.parentid));						
                        addSum.addressId = String.valueOf(level1.id);
                        addSum.status = level1.confirmed?'CONFIRMED':'UNCONFIRMED';  
                        addSum.state = state;
                        addSum.postcode = postcode;
                        addSum.locality = locality;
                        addressSumList.add(addSum);
                    }
                }
                for(AddressResponseDTO.Level2 level2 : level2List){
                    String subAddL2 = AddressTriggerHandler.getAddressType(level2.SubAddressType);
					subAddL2=(subAddL2=='LE'?'L':subAddL2);
                    aLineLevel2= (subAddL2!=null?subAddL2:'') +' '+ (level2.levelFrom!=null?level2.levelFrom:'');
                    level3ToLevel2.put(String.valueof(level2.id),aLineLevel2);
                    
                    mapL1L2.put(String.valueof(level2.id),String.valueof(level2.parentid));
                    if(level2.level3!=null){
                        level3List.addAll(level2.level3);
                    }
                    else{
                        AddressSummary addSum = new AddressSummary();
                        addSum.addressLine = (subAddL2!=null?subAddL2:'')+ ' '+ (level2.levelFrom!=null?level2.levelFrom:'') + ' ' + level2ToLevel1.get(String.valueOf(level2.parentid))+' '+ level1ToPrimary.get(mapPrimaryL1.get(String.valueof(level2.parentid)));
                        addSum.addressId = String.valueOf(level2.id);
                        addSum.status = level2.confirmed?'CONFIRMED':'UNCONFIRMED';  
                        addSum.state = state;
                        addSum.postcode = postcode;
                        addSum.locality = locality;
                        addressSumList.add(addSum);
                    }
                }
                for(AddressResponseDTO.Level3 level3 : level3List){
                    AddressSummary addSum = new AddressSummary();
					subadd= AddressTriggerHandler.getAddressType(level3.SubAddressType);
					subadd = subadd=='LE'?'L':subadd;
                    addSum.addressLine = subadd+ ' '+ (level3.levelFrom!=null?level3.levelFrom:'') + ' ' + level3ToLevel2.get(String.valueOf(level3.parentid))+' '+level2ToLevel1.get(mapL1L2.get(String.valueOf(level3.parentid)))+' '+ level1ToPrimary.get(mapPrimaryL1.get(mapL1L2.get(String.valueOf(level3.parentid))));
                    addSum.addressId = String.valueOf(level3.id);
                    addSum.status = level3.confirmed?'CONFIRMED':'UNCONFIRMED';  
                    addSum.state = state;
                    addSum.postcode = postcode;
                    addSum.locality = locality;
                    addressSumList.add(addSum);
                }   
            }
        }
        return addressSumList;    
    }
}