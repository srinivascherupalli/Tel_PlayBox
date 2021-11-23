/*************************************************************************************************
Name : NumberReservationController
Description :Controller class for Modified Number Reservation 
Author: Abinash Barik,Kalashree Borgaonkar 
Story: EDGE-140792,EDGE-138086
modification: 
1.DIGI-3161 added by shubhi 
***************************************************************************************************/
public with sharing class NumberReservationController { 
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');   
    public Static map<string,id> subscriptionNumberIdMap=new map<string,id>();
    //EDGE-203930
    @AuraEnabled
    public static String getProfileInfo(){  
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()];
        return profile.Name;
    }
    // wrapper or Inner class with @AuraEnabled {get;set;} properties*    
    public class NumberReserve{
        @AuraEnabled public Integer quantity;
        @AuraEnabled public Integer reqPattern;
        @AuraEnabled public String selectedSearchType;
        @AuraEnabled public String selectedPatternType ;
        @AuraEnabled public String selectedAreaCode ;
        @AuraEnabled public boolean sameExchange ;
        @AuraEnabled public cscrm__Address__c deliveryAddress ;//EDGE-148657
        @AuraEnabled public List<SelectOptionz> searchTypeList ;
        @AuraEnabled public List<SelectOptionz> patternList ;
        @AuraEnabled public List<SelectOptionz> areaCodeList;
        public NumberReserve(){
            this.searchTypeList = new List<SelectOptionz>();
            this.patternList = new List<SelectOptionz>();
            this.areaCodeList = new List<SelectOptionz>();
            this.selectedSearchType = 'Non-Contiguous'; // EDGE-145555
            this.selectedPatternType = '';
            this.selectedAreaCode = '';           
            this.deliveryAddress= null;
            this.reqPattern = reqPattern;
        }
    }
    //165572 UI Story for new ngEM orders to capture SIM Type(Physical SIM/e-SIM) in Number Management
    public class simDetails{
        @AuraEnabled public List<ConstantMetadataUtility.picklistWrapper> selectSimType;
        @AuraEnabled public String selectedSimType;
        @AuraEnabled public String selectedSimTypeValue;
        public simDetails(){
            this.selectSimType = new List<ConstantMetadataUtility.picklistWrapper>();
            this.selectedSimType = 'SIM Card';
            this.selectedSimTypeValue = 'SIM Card';
        }        
    }
    @AuraEnabled 
    public static simDetails getsimDetails(){
        simDetails objdetails = new simDetails();
        objdetails.selectSimType = ConstantMetadataUtility.findPicklistOptions('Number__c','SIM_Type__c');
        return objdetails;
    }
    //165572
    
    //EDGE-140792,EDGE-138086 
    @AuraEnabled 
    public static NumberReserve SearchInitialdata(String tabType){
        // create a wrapper class object and set the wrapper class @AuraEnabled properties and return it to the lightning component.
        NumberReserve returnwrapperClass = new  numberReserve();     
        returnwrapperClass.searchTypeList.add(new SelectOptionz('Non-Contiguous','Non-Contiguous'));
        returnwrapperClass.patternList=getPatternType('Non-Contiguous');
        returnwrapperClass.areaCodeList.addAll(returnAreaCode());
        return returnwrapperClass;    
    }
    //EDGE-140792,EDGE-138086
    public static List<SelectOptionz> returnAreaCode() {
        List<SelectOptionz> areaCode= new List<SelectOptionz>();
        areaCode.add(new SelectOptionz('','None')); // INC000097816856 Fix
        areaCode.add(new SelectOptionz('02','02'));
        areaCode.add(new SelectOptionz('03','03'));
        areaCode.add(new SelectOptionz('07','07'));
        areaCode.add(new SelectOptionz('08','08')); 
        
        return areaCode;
    }
    
    /******************************************************************
EDGE        -100661
Method      -checkForPartnerUser 
Description -Check logged in user in partner user or CRM user
Author      -Dheeraj Bhatt
******************************************************************/ 
    //EDGE-140792,EDGE-138086
    @AuraEnabled public static Boolean checkForPartnerUser(){
        return [SELECT Id,IsPortalEnabled FROM User WHERE id =:UserInfo.getUserId()].IsPortalEnabled;
        
    }
    /******************************************************************
EDGE        -126317
Method      -getPatternType 
Description -get Pattern type based on serach type 
Author      -Kalashree
******************************************************************/ 
    @AuraEnabled public static List<SelectOptionz> getPatternType(String searchType){
        return NumberReservationHelper.getPatternType(searchType);    
    } 
    /******************************************************************
EDGE        -140792
Method      -searchNumbers 
Description -API callout for mobile and fixed number search
Author      -Kalashree
******************************************************************/  
    //EDGE-140792,EDGE-138086
    @AuraEnabled(cacheable=true)
    public static searchResult searchNumbers(String searchString,String tabType){
        system.debug('searchString>>>'+searchString);
        searchResult result = new searchResult();
        try{
            Integer resSize=0;
            NumberReserve searchObj = (NumberReserve) JSON.deserialize(searchString, NumberReserve.class);
            FNNSearchRequestDTO searchDto= NumberReservationHelper.createSearchPayload(searchObj,tabType);
            List<LRMWrapper> msisdnList = new List<LRMWrapper>();
            FNNSearchResponseDTO fnnResponse = NumberReservationFixedHandler.searchFNN(searchDto);
            system.debug('fnnResponse>>>>'+fnnResponse);
            Set<String> setresourceIds = new Set<String>();
            if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
                if(searchObj.selectedSearchType=='Contiguous'){
                    List<FNNSearchResponseDTO.Resources> fnnResource = fnnResponse.data.resources;  
                    resSize = fnnResponse.data.resources.size();
                    LRMWrapper wrap = new LRMWrapper();
                    String startNumber=fnnResource[0].resourceId;               
                    String endNumber=fnnResource[resSize-1].resourceId;
                    wrap.numberList=startNumber+' - '+endNumber;
                    msisdnList.add(wrap);
                    result.responsemessage = resSize+ ' numbers of record found.';
                }
                else{
                    for(FNNSearchResponseDTO.Resources res : fnnResponse.data.resources){
                        if(!setresourceIds.contains(res.resourceId)){
                            LRMWrapper wrap = new LRMWrapper();
                            wrap.numberList= res.resourceId;
                            wrap.isSelectedNew= false;                   
                            msisdnList.add(wrap);
                            setresourceIds.add(res.resourceId);
                            result.responsemessage = setresourceIds.size()+ ' numbers of record found.';
                        }
                    }
                }
                
                result.lstsearchresult.addAll(msisdnList);
                
                result.isError = false;
            }else{
                system.debug('Inside Else');
                result.isError = true;
                result.responsemessage = Label.Reserve_numbers_not_found;
            }
        }catch (Exception e) {
            System.debug('Inside Catch>>>>>'+e.getMessage());
            result.isError = true;
            result.responsemessage = e.getMessage();
        }
        System.debug('msisdnList>>>>>'+result);
        return result;  
    } 
    /******************************************************************
EDGE        -140792
Method      -autoReserveMSISDN 
Description -API callout for autoreserving MSISDN
Author      -Kalashree
******************************************************************/     
    @AuraEnabled public static String autoReserveMSISDN(String basketId,Integer searchQuan){
        return NumberReservationHelper.autoReserveMSISDN(basketId,searchQuan);
    }  
    /******************************************************************
EDGE        -140792
Method      -reserveNumbers 
Description -API callout for mobile and fixed number reservation
Author      -Kalashree
******************************************************************/     
    @AuraEnabled public static String reserveNumbers(String fnnListToReserve,String selectedTab,String basketId){
        return NumberReservationHelper.reserveNumbers(fnnListToReserve,selectedTab,basketId);
    }
    
    
    @AuraEnabled public static List<NumberReservationHelper.EachRecord> getreserveNumbers(String basketId,String numberType){
        return NumberReservationHelper.getAllreserveNumbers(basketId, numberType);
    }
    /******************************************************************
EDGE        -140792
Method      -assignNumbers 
Description -Assign numbers to PCs
Author      -Kalashree Borgoankar
******************************************************************/ 
    //EDGE-140792,EDGE-138086,EDGE-165572
    @AuraEnabled
    public static Object assignNumbers(List<string> selectedPcWrapper, List<string> selectedNumbers,
                                       String selectedTab,String basketid,String selectedSimTypeValue,
                                       String newWxistingSIM,String selectedOption,string transitionWrapper){
                                           Object result='Error';
                                           //EDGE-203932-Dheeraj Bhatt-create Number Records Before Assigning it to PC for transition/Migration scenerio.
                                           if(selectedOption=='Transition'){
                                              selectedNumbers= TransitionController.createTransitionNumberRecord(transitionWrapper,basketid,selectedPcWrapper); 
                                           } 
                                           
                                           if('Mobile'.equalsIgnoreCase(selectedTab)){
                                               result = NumberReservationHelper.assignMSISDNNumbers(selectedPcWrapper,selectedNumbers,basketid,selectedSimTypeValue,newWxistingSIM,selectedOption);
                                           }
                                           else { 
                                               result = NumberReservationHelper.assignFixedNumbers(selectedPcWrapper,selectedNumbers,basketid,selectedSimTypeValue,newWxistingSIM,selectedTab,selectedOption);
                                           }
                                           return result;
                                       }
    /******************************************************************
EDGE        -140792
Method      -removeNumbersFromPool 
Description -unreserve 
Author      -Kalashree Borgaonkar
******************************************************************/ 
    //EDGE-140792,EDGE-138086
    @AuraEnabled
    public static NumberReservationFixedHandler.ResponseWrapper removeNumbersFromPool(List<string> numberList,  String basketId, String selectedTab){
        NumberReservationFixedHandler.ResponseWrapper wrapper = new NumberReservationFixedHandler.ResponseWrapper(); 
        if('Mobile'.equalsIgnoreCase(selectedTab)){
            wrapper = NumberReservationHelper.unreserveMobileNumbers(numberList,basketid); 
        }
        else{
            wrapper = NumberReservationHelper.unreserveFixedNumbers(numberList,basketid);            
        } 
        return wrapper;
    }
    //EDGE-140792,EDGE-138086
    @AuraEnabled
    public static List<NumberReservationHelper.ProdConfigWrapper> getAllProductConfig( String basketId, String selectedTab,String selectedRadioOption){
        List<NumberReservationHelper.ProdConfigWrapper> pcWrapList = new List<NumberReservationHelper.ProdConfigWrapper>();
        
        if(selectedTab == 'Mobile'){
            pcWrapList = NumberReservationHelper.getProdConfig(basketid,selectedRadioOption); 
        }else{
            pcWrapList = NumberReservationHelper.getNGUCProdConfig(basketid,selectedTab); 
        }
        system.debug('wrapper>>>>'+pcWrapList);
        return pcWrapList;
    }
    /******************************************************************
EDGE        -140792,96503
Method      -removeNumbersFromPool 
Description -unreserve 
Author      -Kalashree Borgaonkar,Mahima
******************************************************************/ 
    @AuraEnabled
    public static String removeAssignedNumbers(List<String> selectedPCList, string basketID, String selectedTab){   
        return  NumberReservationHelper.removeAssignedNumbers(selectedPCList,basketid,selectedTab); 
    }
    /******************************************************************
Name : validatSimSerialCallout
Description : Method for making callout to ValidateSIM interface
Author: Kalashree Borgaonkar
Story: EDGE-170884
******************************************************************/ 
    @AuraEnabled
    public static List<NumberReservationHelper.prodConfigWrapper> validatSimSerialCallout(String validSimList,String prodConfigList,String basketid){  
        return  NumberReservationHelper.validatSimCallout(validSimList,prodConfigList,basketid);   
    }
    
    /*************************************************************************************************
Name : finishReservation
Description : Method for validating Numbers reserved in NgUC
Author: Kalashree Borgaonkar
Story: EDGE-128633
***************************************************************************************************/
    @AuraEnabled
    public Static NumberReservationHelper.ValidationWrapper finishReservationbtn(String basketId,String selectedTab){
        if(selectedTab=='Mobile'){
            return NumberReservationHelper.finishReservationMobile(basketId);
        }
        else{
            return NumberReservationHelper.finishReservationFixed(basketId);
        }   
    }
    /*************************************************************************************************
Name : OKunReserveFNN
Description: Check Unassigned numbers on click of OK 
Author: Jannath
Story: EDGE-100662
***************************************************************************************************/    
    
    @AuraEnabled
    public static NumberReservationFixedHandler.ResponseWrapper OKunReserveFNN(string basketId){
        boolean Status;
        String Url=URL.getCurrentRequestUrl().toExternalForm();
        List<string> numlist= new List<string>();
        for(Number__c num : [select Id, Type__c,Status__c, Mobile__c,Service_Number__c,
                             Product_Configuration__c, Product_Configuration__r.Name,Basket__c 
                             from Number__C where Basket__c=: basketID and Type__c ='FNN' and 
                             Status__c ='RESERVED' and Product_Configuration__c = NULL]){
                                 numlist.add(num.Service_Number__c);   
                             }
        
        NumberReservationFixedHandler.ResponseWrapper wrap =NumberReservationHelper.unReserveFNN(numlist,basketId,'Rollback');
        system.debug('');
        return wrap; 
    }
    
    
    //EDGE-173151 This method is used to get the user input and update on respective Number record
    @AuraEnabled
    public static String updateNumberRecs(string basketId, String data,String numberType, boolean basketType,String radioOption){
        system.debug('data>>>>>'+data);
        List<pcrecords> configrec  = new List<pcrecords>();
        configrec = (List<pcrecords>) System.JSON.deserialize(data, List<pcrecords>.class);
        system.debug('configrec>>>>>'+configrec + '===========basketId======'+basketId);
        String message='Success';
        Map<String, pcrecords> setServiceNumber = new Map<String, pcrecords>();
        Map<String, String> cfsToPcMap= new Map<String,String>();
        List<String> customerFacingIdList =new  List<String>();
        try{
            if(!configrec.isEmpty()){
                for(pcrecords config : configrec){
                    setServiceNumber.put(config.assignedNumber, config);  
                    cfsToPcMap.put(config.assignedNumber,config.id);
                    customerFacingIdList.add(config.assignedNumber);
                }
                List<Number__c> lstNumberrectobeUpdated = [SELECT Id,SIM_Type__c,SimAvailabilityType__c,Service_Number__c,Sim_Serial_Number__c,Product_Configuration__c
                                                           FROM Number__c WHERE Service_Number__c IN:setServiceNumber.keyset() AND
                                                           Basket__c=: basketID];
                system.debug('lstNumberrectobeUpdated>>>>>'+lstNumberrectobeUpdated);
                Map<String, Number__c> pcToCfsIdMap= NumberReservationHelper.getSIMSerialDetails(  cfsToPcMap, customerFacingIdList );
                if(!lstNumberrectobeUpdated.isEmpty()){
                    for(Number__c objnumber : lstNumberrectobeUpdated){
                        //EDGE-172362. Kalashree Borgaonkar. Set value of SIM serial number
                        if( setServiceNumber.get(objnumber.Service_Number__c).newExistingSim == 'New SIM' ){
                            objnumber.Sim_Serial_Number__c =null ;
                        }
                        //EDGE-224706
                        if(radioOption=='reactiveServices'){  
                            if((setServiceNumber.get(objnumber.Service_Number__c).newExistingSim == 'Existing Blank SIM' || setServiceNumber.get(objnumber.Service_Number__c).newExistingSim == 'Blank SIM')   && objnumber.Sim_Serial_Number__c!=null){
                                String simnumber = (pcToCfsIdMap.get(objnumber.Product_Configuration__c)!=null)?pcToCfsIdMap.get(objnumber.Product_Configuration__c).Sim_Serial_Number__c:null;
                                if(setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber==simnumber){
                                    objnumber.Sim_Serial_Number__c =null;
                                    objnumber.imsi__c = null;
                                } 
                                else{
                                    objnumber.Sim_Serial_Number__c = setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber != null 
                                        ? setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber :objnumber.Sim_Serial_Number__c;
                                }
                            }
                            else{
                                objnumber.Sim_Serial_Number__c = setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber != null 
                                    ? setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber :objnumber.Sim_Serial_Number__c;
                            }
                            //EDGE-214802: Existing Deactivated SIM
                            //EDGE-224706
                            if(setServiceNumber.get(objnumber.Service_Number__c).newExistingSim == 'Existing Active SIM' || setServiceNumber.get(objnumber.Service_Number__c).newExistingSim == 'Existing SIM' ){
                                
                                String simnumber = (pcToCfsIdMap.get(objnumber.Product_Configuration__c)!=null)?pcToCfsIdMap.get(objnumber.Product_Configuration__c).Sim_Serial_Number__c:null;
                                if((setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber!='' && setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber!=simnumber && (objnumber.SimAvailabilityType__c =='New' || objnumber.SimAvailabilityType__c =='Existing Blank SIM' || objnumber.SimAvailabilityType__c =='Blank SIM')) 
                                   || (( setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber!=simnumber && (objnumber.SimAvailabilityType__c=='Existing Active SIM' || objnumber.SimAvailabilityType__c=='Existing SIM')))){
                                       message = 'SIM serial number cannot be changed for existing active SIM.';
                                   }  
                                else{
                                    objnumber.Sim_Serial_Number__c = (pcToCfsIdMap.get(objnumber.Product_Configuration__c)!=null)?pcToCfsIdMap.get(objnumber.Product_Configuration__c).Sim_Serial_Number__c:null;
                                    objnumber.imsi__c = (pcToCfsIdMap.get(objnumber.Product_Configuration__c)!=null)?pcToCfsIdMap.get(objnumber.Product_Configuration__c).imsi__c:null;
                                    
                                }
                            } 
                        }
                        else{
                            objnumber.Sim_Serial_Number__c = setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber != null 
                                ? setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber :objnumber.Sim_Serial_Number__c;
                        }
                        system.debug('objnumber.Sim_Serial_Number__c'+objnumber.Sim_Serial_Number__c);
                        system.debug('setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber'+setServiceNumber.get(objnumber.Service_Number__c).simSerialNumber);
                        objnumber.SIM_Type__c = setServiceNumber.get(objnumber.Service_Number__c).simType != null 
                            ? setServiceNumber.get(objnumber.Service_Number__c).simType :objnumber.SIM_Type__c;
                        objnumber.SimAvailabilityType__c = setServiceNumber.get(objnumber.Service_Number__c).newExistingSim != null 
                            ? setServiceNumber.get(objnumber.Service_Number__c).newExistingSim :objnumber.SimAvailabilityType__c;
                    }
                    system.debug('lstNumberrectobeUpdated>>>>>'+lstNumberrectobeUpdated);
                    if(message=='Success'){
                        update lstNumberrectobeUpdated;
                    }
                    
                } 
            } 
        }
        catch(Exception e){
            System.debug('Exception in updateNumberRecs: '+e.getStackTraceString()); 
            message=e.getMessage();
        } 
        return message;
    }
    //EDGE-173151 This wrapper class is used to parse the user input data
    public class pcrecords{
        @AuraEnabled public String assignedNumber;
        @AuraEnabled public String id;
        @AuraEnabled public String planName;
        @AuraEnabled public String simType;
        @AuraEnabled public String newExistingSim;
        @AuraEnabled public String simSerialNumber;
        public pcrecords(){
            this.assignedNumber = assignedNumber;
            this.id = id;
            this.planName = planName;
            this.simType = simType;
            this.newExistingSim = newExistingSim;
            this.simSerialNumber = simSerialNumber;
        }
    }       
    /*************************************************************************************************
EDGE        -EDGE-165481,171843
Method      -getPortOutReversalRadio 
Description -Check whether to show Port out reversal or not. 
Author      -Kalashree Borgaonkar
***************************************************************************************************
    @AuraEnabled 
    public static Boolean getPortOutReversalRadio(String basketID){
        return NumberReservationHelper.getPortOutReversalRadio(basketID);
    }
    /*************************************************************************************************
EDGE        -EDGE-185029
Method      -getRadioOptions 
Description -check for displaying radio buttons 
Author      -Kalashree Borgaonkar
***************************************************************************************************/
    @AuraEnabled 
    public static NumberReservationHelper.RadioOptionsWrapper getRadioOptions(String basketID){
        return NumberReservationHelper.getRadioOptions(basketID);
    }
    
    //EDGE-168641 : get SIM Configurration data from custom meta data
    @AuraEnabled 
    public static List<Object> getSIMConfiguration(){
        List<Mobile_Number_SIM_Config__mdt> ObjResult= [Select Selected_Tab__c,SIM_Mode__c,SIM_Options__c,Type__c,Order__c 
                                                        from Mobile_Number_SIM_Config__mdt ORDER BY Order__c]; //EDGE-170885 Adding order by for sorting
        return ObjResult;
    }
    
    public class searchResult{
        @AuraEnabled public List<LRMWrapper> lstsearchresult;
        @AuraEnabled public String responsemessage;
        @AuraEnabled public boolean isError;
        public searchResult(){
            this.lstsearchresult = new List<LRMWrapper>();
            this.responsemessage = '';
            this.isError = false;
        }
    }
    //Wrapper to display LRM success response
    public class LRMWrapper{
        @AuraEnabled
        public String numberList;
        @AuraEnabled
        public Boolean isSelectedNew;
        @AuraEnabled
        public String message;
        
    }
    @AuraEnabled
    public static string assignSIM(String selectedPcWrapper,String basketId, String selectedSimTypeValue,String newWxistingSIM){
        return NumberReservationHelper.assignSIM(selectedPcWrapper,basketId,selectedSimTypeValue,newWxistingSIM);
        
    }
     //EDGE-185029 Kalashree check for Reactivate service.
    @AuraEnabled
    public static Boolean checkReactivateServices(String basketId){
        return NumberReservationHelper.checkReactivateServices(basketId);
        
    }
    //DIGI-3161 added by shubhi 
    @AuraEnabled
    public static void logTransaction(String searchType,String basketId, String quantity,String event){
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')){
        if(String.isNotBlank(basketId)){
            cscfga__Product_Basket__c pb=Model_ProductBasket.getProductBasketonLoadSolution(basketId);
            if(pb!=null){
                Map<String,Object> loggerdetailsMap=new Map<String,Object>();
                string correlationId=pb.cscfga__Opportunity__c+'-'+basketId;
                loggerdetailsMap.put('event',event);
                loggerdetailsMap.put('searchType',searchType);
                loggerdetailsMap.put('basketName',pb.name);
                loggerdetailsMap.put('Quantity',quantity);
                TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'NumberReservationController');
            }
        }
    }
}

/*************************************************************************************************
Name : validateSimSerNumberCtrl
Description : Enhance SIM validation to include Active/Previously used check
Author: Irfan Inamdar
Story: DIGI-21833
***************************************************************************************************/
@AuraEnabled
public Static List<String> validateSimSerNumberCtrl(List<String> simSerNumberList){

    return NumberReservationHelper.validateSimSerNumber(simSerNumberList);

    }
}