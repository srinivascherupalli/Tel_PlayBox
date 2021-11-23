/**
 * Class for address check service.
 */
public with sharing class AddressValidateService {
     public static final String NBN_EAST = 'AddressValidateServiceByAdborId';
     
    /* private AddressValidateService(){
        
    }*/
    /*US41754 */
    /*public static List<AddressSummary>   searchUnstructuredAddress(Map<String, Object> params, String systemName) {
        try{
            return runUnstructuredSearch(params, systemName);
        }catch(Exception e){
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
        }
        return null;
    }*/
    
    /**
     * EDGE - 57162
     * Unstructured Search AddressSQ
     */
    public static List<AddressSummary>   searchAddressSQ(Map<String, Object> params, String handler,String adborid) {
        try{
            return runSearchSQ(params,handler,adborid);
        }catch(Exception e){
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
            System.debug('Exception::' + e.getLineNumber() + e.getMessage() + e.getStackTraceString() + e.getCause());
        }
        return null;
    }
    
    /**
     * Search Addresses
     *
     * @param      addressText  The address text
     * @param      systemName  The System Name
     *
     * @return     AddressSummary List
     */
    public static List<AddressSummary>   searchAddress(String addressText, String systemName) {
        try{
            return runSearch(addressText, systemName);
        }catch(Exception e){
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
        }
        return null;
    }


    public static void searchAddressByAdborIdAsync(AddressRequestDTO addressRequestDTOObj) {
        try{
            String urlParam = addressRequestDTOObj.getEncodedURLParam();
            System.debug('urlParam'+urlParam+'handlerName'+NBN_EAST);
            runSearchByAdborIdAsync(urlParam,NBN_EAST);            
        }
        catch(Exception e){
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
            throw(e);
        }
    }
    
    @future(callout=true)
    public static void runSearchByAdborIdAsync(String urlParam, String handlerName){
        AddressResponseDTO addressResponseDTOObj;
        HTTPResponse adResponse = new HTTPResponse();
        try{
            String token = AuthenticationManager.getOauthToken(NBN_EAST);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.callout(urlParam, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, handlerName,null, null);
            addressResponseDTOObj = AddressResponseDTO.parse(adResponse.getBody());
            System.debug('addressResponseDTOObj:'+addressResponseDTOObj);            
            if(addressResponseDTOObj!=null && addressResponseDTOObj.code==200 && addressResponseDTOObj.ErrorCode==null){
                AddressAndSiteObjectUtility.upsertNBNEastAddress(addressResponseDTOObj);
            }
        }catch(Exception e){
            System.debug('Exception in runSearchByAdborIdAsync'+e);                     
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
        }
    }
    
    /* US41754 */
    /*public static List<AddressSummary>  runUnstructuredSearch(Map<String, Object> params, String systemName) {
        try{
            String paramString ='';
            for(String paramKey : params.keySet()){
                if(params.get(paramKey)!=null && params.get(paramKey)!=''){
                    if(String.isBlank(paramString)){
                        if(paramKey == 'addressType' && params.get(paramKey) == 'Property Parcel')
                            paramString += paramKey+'=Property & Parcel';                            
                        else
                            paramString += paramKey+'='+params.get(paramKey);
                    }else{
                        if(paramKey == 'addressType' && params.get(paramKey) == 'Property Parcel')
                            paramString += '&'+paramKey+'=Property & Parcel';
                        else
                            paramString += '&'+paramKey+'='+params.get(paramKey);
                    }
                }
            }
            system.debug('>>>>>>>> paramString :'+paramString);
            String urlSearchString = EncodingUtil.URLEncode(paramString, 'UTF-8');
            
            System.debug('urlSearchString is '+urlSearchString);
            return fetchResults(urlSearchString, systemName);
            
        }catch(Exception e){
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
            
        }
        return null;
    }*/
    
    /**
     * EDGE - 57162
     * Unstructured Search AddressSQ
     */
    public static List<AddressSummary>  runSearchSQ(Map<String, Object> params,String handler,String adborid) {
        System.debug('params'+params+'hanlder: '+handler);
         List<AddressSummary> response;
        if(handler.equalsIgnoreCase('AdborIdAddressHandler')){
            response = AddressSearch.searchUnStructuredAddress(null,handler,adborid);
        }
        else{
            AddressRequest requestBody = new AddressRequest();
        AddressRequest.SearchOptions  searchAddOptions = new AddressRequest.SearchOptions();
        AddressRequest.Data addData = new  AddressRequest.Data();
        AddressRequest.SearchData  searchAddData = new AddressRequest.SearchData();
        AddressRequest.FuzzyOptions fuzzy = new AddressRequest.FuzzyOptions();
        AddressSQRequestSpecs__c  addReq = AddressSQRequestSpecs__c.getValues(handler);
        List<String> responseFormats = new List<String> {'unstructuredAUPost','structured'};
        if(addReq!=null){
            fuzzy.enabled = addReq.enabled__c;
            searchAddOptions.addressesToSkip = (Integer) addReq.addressesToSkip__c;
            searchAddOptions.addressesToReturn = (Integer) addReq.addressesToReturn__c;
            //searchAddOptions.sortType = addReq.sortType__c;
        }
        
        searchAddOptions.addressType = (String) params.get('addressType');  
        searchAddOptions.responseFormats = responseFormats;
        searchAddOptions.fuzzyOptions = fuzzy;
        searchAddData.suburb = (String) params.get('locality'); 
        searchAddData.state = (String) params.get('state'); 
        searchAddData.postcode = (String) params.get('postcode');
        if(handler.equalsIgnoreCase('UnStructuredAddressHandler')){
           searchAddData.addressLine1 = (String) params.get('searchLine1');
        }
         if(handler.equalsIgnoreCase('StructuredAddressHandler')){
            searchAddData.streetNumber = (String) params.get('streetnumber');
          searchAddData.streetName = (String) params.get('streetname');
          searchAddData.streetType = (String) params.get('streetType');
        }
        addData.searchOptions = searchAddOptions;
        addData.searchData = searchAddData;
        requestBody.data = addData;
        response = AddressSearch.searchUnStructuredAddress(requestBody,handler,null);
        System.debug('response::' + response ); 
        System.debug('requestBody::' + requestBody + ',Request::' + JSON.serialize(requestBody,true));   
        }
             
        
        return response;
    }
    
    /**
     * Runs Search
     *
     * @param      address      The address
     * @param      systemName  The System Name
     *
     * @return     AddressSummary List
     */
    public static List<AddressSummary>  runSearch(String address, String systemName) {
        try{
        String searchLine1 = '';
        String searchLine2 = '';
        String searchLine3 = '';
        Integer addressSize = 0;
        String tempVarForAddress = '';
        
        if (address != null && address != 'null') {
            addressSize = address.length();
            tempVarForAddress=address;
        } else {
            //address = '';
            addressSize = 0;
        }
        //searchLine1 = address;

        if (addressSize <= 40) {
            searchLine1 = tempVarForAddress;
        } else if (addressSize <= 80) {
            searchLine1 = tempVarForAddress.substring(0, 40);
            searchLine2 = tempVarForAddress.substring(40, addressSize);
        } else if (addressSize > 80) {
            searchLine1 = tempVarForAddress.substring(0, 40);
            searchLine2 = tempVarForAddress.substring(40, 80);
            searchLine3 = tempVarForAddress.substring(80, addressSize);
        }


        System.debug('searchLine1 ' + searchLine1);
        System.debug('searchLine2 ' + searchLine2);
        System.debug('searchLine3 ' + searchLine3);

        String optionalParam = (searchLine2 != '' && searchLine2 != null) ? ('&searchLine2=' + searchLine2) : '';
        optionalParam += (searchLine3 != '' && searchLine3 != null) ? ('&searchLine3=' + searchLine3) : '';


        String urlSearchString = EncodingUtil.URLEncode('searchLine1=' + searchLine1 + optionalParam + '&numberOfAddressesToReturn=' + EnvironmentVariable.get('okapi_east_address_limit'), 'UTF-8');
        
       
        System.debug('urlSearchString is '+urlSearchString);
        return fetchResults(urlSearchString, systemName);
        }catch(Exception e){
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
        }
        return null;
    }

     public static List<AddressSummary> fetchResults(String urlSearchString, String systemName) {

        List<AddressSummary> addressList = new List<AddressSummary>();
    Logger2 logger = Logger2.getLogger('AddressValidationService');
        HttpResponse adResponse = new HttpResponse();
        try {

            String envResultListWarningLimit = EnvironmentVariable.get('okapi_east_result_list_warning_limit');
            Integer  adddressListLimit = (envResultListWarningLimit != null && envResultListWarningLimit != '') ? integer.valueof(envResultListWarningLimit) : 1000;


            String token = AuthenticationManager.getOauthToken(systemName);

            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.callout(urlSearchString, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, AddressValidateService.class.getName(),null, null);
            
            
            if (adResponse.getStatusCode() == 200) {
                System.debug('json Response Test ' + adResponse.getBody());
                EASTAddressDataObject edo = EASTAddressDataObject.parse(adResponse.getBody());                
                System.debug('Response data size is ' + edo.data.size());
                AddressSummary addSum = new AddressSummary();
                addSum.responseStatus = adResponse.getStatusCode();
                addressList.add(addSum);
                if (edo != null) {

                    for (EASTAddressDataObject.EASTAddress e : edo.data) {

                        if (e.numberOfSubAddresses == null || e.numberOfSubAddresses == '' || Integer.valueOf(e.numberOfSubAddresses) == 0 ) {
                            if (addressList.size() < adddressListLimit) {
                                addressList.add(addressSummarize(e));
                            }
                        } else {
                            List<AddressSummary> subAddList = subAddressSummarize(e);
                            if ((addressList.size() + subAddList.size() <= adddressListLimit) || (addressList.size() < adddressListLimit)) {
                                addressList.addAll(subAddList);
                            }
                        }
                    }
                }
                logger.logMessages(urlSearchString, adResponse.getBody(), '', '', '', '', false, false);  

            } else {
                System.debug('json Response Test ' + adResponse.getStatusCode());
                AddressSummary addSum = new AddressSummary();
                addSum.responseStatus = adResponse.getStatusCode();
                system.debug('addSum.responseStatus'+addSum.responseStatus);
                addressList.add(addSum);
                system.debug('addressList'+addressList);
                String msg = adResponse.getStatusCode() == 404? 'Page Not found': '';
                logger.logMessages(urlSearchString, adResponse.getBody(), '', '', adResponse.getStatus()+': '+adResponse.getStatusCode(), msg, false, false);  
            }
        } catch (Exception e) {

            System.debug(e);
        }
        logger.exitLogger();
        return addressList;
    }


    /**
     * Create AddressSummary obj from EASTAddress
     *
     * @param      e   EASTAddress
     *
     * @return     AddressSummary
     */
    public static AddressSummary addressSummarize(EASTAddressDataObject.EASTAddress e) {

        String stNumber = '';
        String adLine = '';
        try{
        if (e.numberZ != null) {
            stNumber = e.numberZ;
            if (e.numberPrefix != null) {stNumber = e.numberPrefix + stNumber; }
            if (e.numberSuffix != null) {stNumber = stNumber + e.numberSuffix; }
        }
        if (e.numberTo != null && e.numberTo != '0' && e.numberTo != '') {
            String numTo = e.numberTo;
            if (e.numberToPrefix != null) {numTo = e.numberToPrefix + numTo; }
            if (e.numberToSuffix != null) {numTo = numTo + e.numberToSuffix; }
            stNumber += '-' + numTo;
        }
        //  address line 1 = name + numberPrefix + numberZ + numberSuffix + numberToPrefix + numberTo + numberToSuffix;
        if(e.name != null){adline = e.name + ' ' +adline;}
        adLine = adline + ' ' +stNumber + ' ' + e.streetName + ' '
                 + e.streetType;
        adLine.replace('null', ' ');
        return new AddressSummary(e.id, adLine, e);
        }catch(Exception excep){
            Logger.getLogger(AddressValidateService.class).debug(excep);
            Logger.exitLogger();
            System.debug(excep);
        }
        return null;
    }

    /**
     * Create SubAddress Summary obj from EASTAddress
     *
     * @param      e   EASTAddress
     *
     * @return     List of AddressSummary
     */
    public static List<AddressSummary> subAddressSummarize(EASTAddressDataObject.EASTAddress e) {

        List<AddressSummary> addressSummary = new List<AddressSummary>();

        String stNumber = '';
        String adLine = '';
        try{
        if (e.numberZ != null) {
            stNumber = e.numberZ;
            if (e.numberPrefix != null) {stNumber = e.numberPrefix + stNumber; }
            if (e.numberSuffix != null) {stNumber = stNumber + e.numberSuffix; }
        }
        if (e.numberTo != null && e.numberTo != '0' && e.numberTo != '') {
            String numTo = e.numberTo;
            if (e.numberToPrefix != null) {numTo = e.numberToPrefix + numTo; }
            if (e.numberToSuffix != null) {numTo = numTo + e.numberToSuffix; }
            stNumber += '-' + numTo;
        }
            
        if(e.name != null){adline = e.name + ' ' +adline;}
        adLine = adline + ' ' + stNumber + ' ' + e.streetName + ' '
                 + e.streetType;
        adLine.replace('null', ' ');
        addressSummary.add(new AddressSummary(e.id, adLine, e));

        List<EASTAddressDataObject.SubAddressComponents> subAddressComponentsl1 = e.SubAddress.subAddressComponents;

        if (subAddressComponentsl1 != null && subAddressComponentsl1.size() > 0) {
            for (EASTAddressDataObject.SubAddressComponents subAddress : subAddressComponentsl1) {
                addressSummary.add(new AddressSummary(e.id, adLine, e, subAddress));

                List<EASTAddressDataObject.SubAddressComponents> subAddressComponentsl2 = subAddress.subAddressComponents;
                if (subAddressComponentsl2 != null && subAddressComponentsl2.size() > 0) {
                    for (EASTAddressDataObject.SubAddressComponents subAddressl2 : subAddressComponentsl2) {
                        addressSummary.add(new AddressSummary(e.id, adLine, e, subAddress, subAddressl2));


                        List<EASTAddressDataObject.SubAddressComponents> subAddressComponentsl3 = subAddressl2.subAddressComponents;
                        if (subAddressComponentsl3 != null && subAddressComponentsl3.size() > 0) {
                            for (EASTAddressDataObject.SubAddressComponents subAddressl3 : subAddressComponentsl3) {
                                addressSummary.add(new AddressSummary(e.id, adLine, e,subAddress,subAddressl2,subAddressl3));
                    
                    List<EASTAddressDataObject.SubAddressComponents> subAddressComponentsl4 = subAddressl3.subAddressComponents;
                                if (subAddressComponentsl4 != null && subAddressComponentsl4.size() > 0) {
                                    for (EASTAddressDataObject.SubAddressComponents subAddressl4 : subAddressComponentsl4) {
                                        addressSummary.add(new AddressSummary(e.id, adLine, e,subAddress,subAddressl2,subAddressl3,subAddressl4));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        }
        catch(Exception excep){
            Logger.getLogger(AddressValidateService.class).debug(excep);
            Logger.exitLogger();
            System.debug(excep);
        }
        return addressSummary;
    }
     public static AddressResponseDTO searchAddressByAdborId(AddressRequestDTO AddressRequestDTOObj) {
        AddressResponseDTO responseDTO;
        try{
            String urlParam = AddressRequestDTOObj.getEncodedURLParam();    
            if(urlParam == null){
                return null;
            }else{
                responseDTO = runSearchByAdborId(urlParam);
            }
        }catch(Exception e){
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
        }
        return responseDTO;
    }
    public static AddressResponseDTO runSearchByAdborId(String urlParam){
        AddressResponseDTO addressResponseDTOObj;
        HTTPResponse adResponse = new HTTPResponse();
        try{
            String token = AuthenticationManager.getOauthToken(NBN_EAST);
            Map<String,String> headerMap = new Map<String, String>{'Accept' => 'application/json','Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.callout(urlParam, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, NBN_EAST,null, null);
            addressResponseDTOObj = AddressResponseDTO.parse(adResponse.getBody());
            
            if (adResponse.getStatusCode() != 200) {
                Logger.getLogger(SQService.class).debug('Callout not success ' + adResponse.getStatusCode());
                Logger.exitLogger();
            }
        }catch(Exception e){
            Logger.getLogger(AddressValidateService.class).debug(e);
            Logger.exitLogger();
        }
        return addressResponseDTOObj;
    }
    
    /* US41754 */
    public static List<SelectOptionz> getPostCodeByState(String stateCode) {
        
        List<AggregateResult> lst = [select Zip_Code__c from Post_Code__c where state__C = :stateCode GROUP BY Zip_Code__c ];
        List<SelectOptionz> postCodeList = new List<SelectOptionz>();
        for(AggregateResult aResult : lst){
            postCodeList.add(new SelectOptionz(String.ValueOf(aResult.get('Zip_Code__c')), String.ValueOf(aResult.get('Zip_Code__c'))));
        }
        system.debug('>>>>>>>lst '+postCodeList);
        return postCodeList;
    }
    
    /*US41754 */
    public static List<SelectOptionz> getLocalityByPostCode(String postCode) {
        
        List<AggregateResult> lst = [select name from Post_Code__c where Zip_Code__c = :postCode GROUP BY name ];
        List<SelectOptionz> loalityList = new List<SelectOptionz>();
        for(AggregateResult aResult : lst){
            loalityList.add(new SelectOptionz(String.ValueOf(aResult.get('name')), String.ValueOf(aResult.get('name'))));
        }
        system.debug('>>>>>>>lst '+loalityList);
        return loalityList;
    }
}