/*************************************************************************************************
EDGE -93081
Name: NumberReservationBaseComp
Description: Handler for LRM Number reservation on New Tab
Author:Ila/Mahima 
***************************************************************************************************/

public with sharing class NumberReservationNewCompHandler {
    
    //Declare constants    
    public static String REGULAR =  'Regular';
    public static String CONTINUOUS =  'CONTINUOUS';
    public static String PATTERN =  '614';
    public static String POSTPAID =  'Postpaid';
    public static String SEARCH =  'SEARCH';
    public static String AVAILABLE =  'AVAILABLE';
    public static String TELSTRA_NUM =  'Telstra Numbers';
    public static String DIRECT_HOLD =  'DIRECT HOLD';
    
    
    //Wrapper to pass UI input values
    public class SearchMSISDNWrapper {
        @AuraEnabled
        public Integer reqQuantity {get;set;}  
        @AuraEnabled
        public String reqSearch{get;set;}  
        @AuraEnabled
        public String reqPattern{get;set;}
        @AuraEnabled
        public String areaCode{get;set;}
        @AuraEnabled
        public String patternType{get;set;}
        @AuraEnabled
        public Integer pattern{get;set;}
        @AuraEnabled
        public String addressId{get;set;}
        @AuraEnabled
        public String esaValue{get;set;}
    }
    
    //Wrapper to display LRM success response
    public class LRMWrapper{
        @AuraEnabled
        public String numberList{get;set;}
        @AuraEnabled
        public Boolean isSelectedNew{get;set;}
        @AuraEnabled
        public String message{get;set;}
        
    }
    
    /**********************************
EDGE-93081 
Description: LRM Search for MSISDN Numbers
Author: Ila
************************************
    @AuraEnabled
    public static List<LRMWrapper> searchMSISDN(SearchMSISDNWrapper searchObj){
        //Searches the MSISDN numbers for Mobility
        List<LRMWrapper> msisdnList = new List<LRMWrapper>();
        FNNDTO fnnDto = new FNNDTO();
        FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
        FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
        List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
        cto.value = REGULAR;
        ctoList.add(cto);
        fdo.quantity = searchObj.reqQuantity;
        
        fdo.searchType = searchObj.reqSearch;
        if( fdo.searchType == CONTINUOUS)
        {
            fdo.pattern = PATTERN + searchObj.reqPattern;
        }
        
        fdo.poolName = POSTPAID;
        fdo.activityName = SEARCH;
        fdo.categoryType = ctoList;
        fdo.searchStatus = AVAILABLE;
        fnnDto.data = fdo;
        FNNResponseDTO fnnResponse = MSISDNService.searchMSISDN(fnnDto);
        
        if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
            for(FNNResponseDTO.ResourcesDataObject res : fnnResponse.data.resources){
                LRMWrapper wrap = new LRMWrapper();
                wrap.numberList= res.resourceId;
                wrap.isSelectedNew= false;
                msisdnList.add(wrap);
            }
        }
        System.debug('msisdnList::' + msisdnList);
        return msisdnList;
    }*/
 /**********************************
EDGE-92020
Description: Search mobile numbers/MSISDN in Bulk
Author: Aishwarya
************************************/
    @AuraEnabled
    public static List<LRMWrapper> searchMSISDN(SearchMSISDNWrapper searchObj){
        system.debug('searchObj' +searchObj);
        //Searches the MSISDN numbers for Mobility
        List<LRMWrapper> msisdnList = new List<LRMWrapper>();
        
         FNNSearchRequestDTO fnnDto = new FNNSearchRequestDTO();
        FNNSearchRequestDTO.data fdo=new FNNSearchRequestDTO.data();
        
        fdo.quantity = searchObj.reqQuantity;
        

        if(searchObj.reqPattern!=null  && searchObj.patternType.equalsIgnoreCase('Starts With')){
           
                fdo.pattern = string.valueOf(searchObj.reqPattern)+'*';
            
        }  
        else if(searchObj.reqPattern!=null  && searchObj.patternType.equalsIgnoreCase('Ends With')){
                fdo.pattern = '*'+string.valueOf(searchObj.reqPattern);
        }    
        else if(searchObj.reqPattern!=null  && searchObj.patternType.equalsIgnoreCase('Contains')){
            
                 fdo.pattern = '*'+string.valueOf(searchObj.reqPattern)+'*';
               
        }

        fdo.resourceType = 'Mobile';
        fdo.activityName = SEARCH;
        
        fdo.searchType = searchObj.reqSearch;
        fdo.premiumType = 'Regular'; // EDGE-138110 
        fnnDto.data = fdo;
        FNNSearchResponseDTO fnnResponse = NumberReservationFixedHandler.searchFNN(fnnDto);
        
        if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
            for(FNNSearchResponseDTO.Resources res : fnnResponse.data.resources){
                LRMWrapper wrap = new LRMWrapper();
                wrap.numberList= res.resourceId;
                wrap.isSelectedNew= false;
                msisdnList.add(wrap);
            }
        }
        System.debug('msisdnList::' + msisdnList);
        return msisdnList;
    }
    
    /*****************************************************************
EDGE-93081 
Description: LRM Reserve and AutoReserve for MSISDN Numbers
Author: Ila
******************************************************************/
    public static String searchReserveMSISDN(String fnnListToReserve, String basketId,Integer searchQuan,String selectedTab){
        String jobId1;
        system.debug('fnnListToReserve' +fnnListToReserve);
        system.debug('basketId' +fnnListToReserve);
        List<String> lstfinaltoReserve = new List<String>(); //Abinash
        List<LRMWrapper> msisdnList = new List<LRMWrapper>();
		String Status = '';
            
        if ((searchQuan != NULL && searchQuan > 0) && fnnListToReserve==NULL)
        {
            //EDGE-92021 Start
            FNNSearchRequestDTO fnnDto = new FNNSearchRequestDTO();
            FNNSearchRequestDTO.data fdo=new FNNSearchRequestDTO.data();
            fdo.quantity = searchQuan;
            fdo.resourceType = 'Mobile';
            fdo.activityName = 'Reserve Next Available';
            
            fnnDto.data = fdo;
            FNNSearchResponseDTO fnnResponse = NumberReservationFixedHandler.searchFNN(fnnDto);
            if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
                for(FNNSearchResponseDTO.Resources res : fnnResponse.data.resources){
                    //Added by aishwarya
                    lstfinaltoReserve.add(res.resourceId);
                    LRMWrapper wrap = new LRMWrapper();
                    wrap.numberList= res.resourceId;
                    wrap.isSelectedNew= false;
                    msisdnList.add(wrap);

                }
            }
             //Added by Aishwarya
            if(!lstfinaltoReserve.isEmpty()){
				MSISDNService.saveReserveMSISDN(lstfinaltoReserve,basketId);
				Status = 'Success';            
            }else{
				Status = 'No Number found.'; 
			}
            //EDGE-92021 End
            /*system.debug('in Auto');
            Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
            FNNDTO dto = new FNNDTO();
            FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
            FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
            List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
            cto.value = REGULAR;
            cto.value = TELSTRA_NUM;
            ctoList.add(cto);
            fdo.poolName = POSTPAID;
            fdo.activityName = DIRECT_HOLD;
            fdo.categoryType = ctoList;
            fdo.searchStatus = AVAILABLE;
            dto.data = fdo;
            system.debug('searchQuan++' +searchQuan);
            for(integer i = 0; i< searchQuan ; i++){
                fnnMap.put(String.valueOf(i),dto);
            }
            
            system.debug('fnnmapauto'+fnnMap);
            jobId1 = System.enqueueJob(new MSISDNService(fnnMap,'SearchReserveMSISDNHandler',basketId,true));
            System.debug('AutoreserveJobId::' + jobId1);*/
        }else
        {
            //EDGE-92021 Start
            List<LRMWrapper> msisdnDetailsList = (List<LRMWrapper>)System.JSON.deserialize(fnnListToReserve, List<LRMWrapper>.Class);
            for(LRMWrapper fnn : msisdnDetailsList){
                lstfinaltoReserve.add(fnn.numberList);
                
                //if(fnn.isSelectedNew==true){
               /* Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
                FNNDTO dto = new FNNDTO();
                FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
                FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
                List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
                cto.value = REGULAR;
                cto.value = TELSTRA_NUM;
                ctoList.add(cto);
                fdo.poolName = POSTPAID;
                fdo.activityName = DIRECT_HOLD;
                fdo.categoryType = ctoList;
                fdo.searchStatus = AVAILABLE;
                // EDGE-131248-Dheeraj Bhatt-Use Age Out Parameter in MSISDN Reservation Call to HOLD number till certain period.
				fdo.ageOut=Label.MSISDN_Reservation_AgeOut;
                dto.data = fdo;
                fnnMap.put(fnn.numberList,dto);
                system.debug('fnnmap'+fnnMap);
                
                
                jobId1 = System.enqueueJob(new MSISDNService(fnnMap,'ReserveMSISDNHandler',basketId,true));
                System.debug('ReservereserveJobId::' + jobId1);*/
                //}
            }
			NumberReservationFixedHandler.ResponseWrapper responseWrapperList = new NumberReservationFixedHandler.ResponseWrapper();
            responseWrapperList = NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(lstfinaltoReserve,basketId,'Held Order',selectedTab);
			system.debug('responseWrapperList>>>>>'+ responseWrapperList);
            if((responseWrapperList.resIds != null && responseWrapperList.resIds.size() > 0) 
				|| responseWrapperList.successMsg != null){
				Status = 'Success';
			}else if(responseWrapperList.errList != null){
				for(NumberReservationFixedHandler.ErrorList error: responseWrapperList.errList){
					Status = Status + '\n'+ error.resourceId + '-'+ error.message;
				}
			}
            // EDGE-92021 End
        }	
        system.debug('Status>>>>>'+ Status);
        system.debug('lstfinaltoReserve>>>>>'+ lstfinaltoReserve);
        return Status;
    }
    
    /*****************************************************************
EDGE-93081 
Description: LRM AutoReserve MSISDN Numbers called from component
Author: Ila
******************************************************************/
    @AuraEnabled
    public static String autoReserveMSISDN(Integer searchQuan,String basketId, String selectedTab)
    {   
        String response =searchReserveMSISDN(null,basketId,searchQuan,selectedTab);
        return response;
        
    }
    
    /*****************************************************************
EDGE-93081 
Description: LRM Reserve MSISDN Numbers called from component
Author: Ila
******************************************************************/
    @AuraEnabled
    public static String reserveMSISDN(String fnnListToReserve,String basketId,String selectedTab)
    {
        String response= searchReserveMSISDN(fnnListToReserve,basketId,null,selectedTab);
        return response;
        
    }
    
    /******************************************************************
EDGE -89257 , AC6
Method: getJobStatus
Description: get status of Queueable job
Author:Kalashree
******************************************************************/
    /*@AuraEnabled
    public static Boolean getJobStatus(string jobId){  
        System.Debug('jobId: '+jobId);
        Boolean isJobCompleted = false;
        List<AsyncApexJob> lstjobstatus = [SELECT Id,Status FROM AsyncApexJob where id =:jobId];
        if(lstjobstatus!=null && lstjobstatus.size()>0)
        {
            AsyncApexJob jobstatus=lstjobstatus[0];
            if('Completed'.equalsIgnoreCase(jobstatus.Status) ){
                system.debug('Job completed');
                isJobCompleted = true;  
            }
        }
        return isJobCompleted;
    } */
    
    /******************************************************************
EDGE :59982
Method:SearchFNN 
Description: SearchFNN 
Author:Aishwarya
*****************************************************************

@AuraEnabled
public static List<LRMWrapper> searchFNNNew(SearchMSISDNWrapper searchObj){
List<LRMWrapper> msisdnList = new List<LRMWrapper>();
FNNDTO fnnDto = new FNNDTO();
FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
FNNDTO.CategoryTypeDataObject cto = new FNNDTO.CategoryTypeDataObject();
List<FNNDTO.CategoryTypeDataObject> ctoList = new List<FNNDTO.CategoryTypeDataObject>();
cto.value = REGULAR;
ctoList.add(cto);
fdo.quantity = searchObj.reqQuantity;

//fdo.pattern = searchObj.reqSearch;

if(searchObj.reqPattern!=null && searchObj.reqPattern.length()>0 && searchObj.reqSearch.equalsIgnoreCase('Equals'))
fdo.pattern = searchObj.reqPattern;
else if(searchObj.reqPattern!=null && searchObj.reqPattern.length()>0 && searchObj.reqSearch.equalsIgnoreCase('Begins With'))
fdo.pattern = '*'+searchObj.reqPattern;
else if(searchObj.reqPattern!=null && searchObj.reqPattern.length()>0 && searchObj.reqSearch.equalsIgnoreCase('Ends With'))
fdo.pattern = searchObj.reqPattern+'*';
else if(searchObj.reqPattern!=null && searchObj.reqPattern.length()>0 && searchObj.reqSearch.equalsIgnoreCase('Contains'))
fdo.pattern = '*'+searchObj.reqPattern+'*';

fdo.poolName = POSTPAID;
fdo.activityName = SEARCH;
fdo.categoryType = ctoList;
fdo.searchStatus = AVAILABLE;
fdo.searchType = 'RANDOM';
fdo.systemId = 'SFDC';
fnnDto.data = fdo;
FNNService fnnSer = new FNNService();
FNNResponseDTO fnnResponse = fnnSer.searchFNN(fnnDto);
//fnnList = fnnRes.data.fnns;

if(fnnResponse != NULL && fnnResponse.data != NULL){
List<String> fnnList = fnnResponse.data.fnns;
for(String fnn : fnnList){
LRMWrapper wrap = new LRMWrapper();
wrap.numberList= fnn;
wrap.isSelectedNew= false;
msisdnList.add(wrap);
}
}

System.debug('msisdnList::' + msisdnList);
return msisdnList;
}*/
    /******************************************************************
EDGE :59982
Method:SearchFNN 
Description: SearchFNN 
Author:Aishwarya
******************************************************************/
    
    @AuraEnabled
    public static List<LRMWrapper> searchFNN(SearchMSISDNWrapper searchObj){
        System.debug('searchObj::' + searchObj);
        List<LRMWrapper> msisdnList = new List<LRMWrapper>();
        Integer resSize=0;
        
        FNNSearchRequestDTO fnnDto = new FNNSearchRequestDTO();
        FNNSearchRequestDTO.data fdo=new FNNSearchRequestDTO.data();
        
        fdo.quantity = searchObj.reqQuantity;
        
        //fdo.pattern = searchObj.reqSearch;
          
        //EDGE-126317. Kalashree Borgaonkar. Changes for Contiguous pattern. Start
        if(searchObj.reqSearch.equalsIgnoreCase('Contiguous') && searchObj.patternType.equalsIgnoreCase('None')){
            fdo.pattern = '*00';
        }
        if(searchObj.pattern!=null  && searchObj.patternType.equalsIgnoreCase('Starts With')){
            if(searchObj.reqSearch.equalsIgnoreCase('Contiguous')){
            	fdo.pattern = string.valueOf(searchObj.pattern)+'*00';
        	}
            else{
                fdo.pattern = string.valueOf(searchObj.pattern)+'*';
            }
        }  
        else if(searchObj.pattern!=null  && searchObj.patternType.equalsIgnoreCase('Ends With')){
                fdo.pattern = '*'+string.valueOf(searchObj.pattern);
        }    
        else if(searchObj.pattern!=null  && searchObj.patternType.equalsIgnoreCase('Contains')){
            if(searchObj.reqSearch.equalsIgnoreCase('Contiguous')){
             	fdo.pattern = '*'+string.valueOf(searchObj.pattern)+'*00';
            }
             else{
                 fdo.pattern = '*'+string.valueOf(searchObj.pattern)+'*';
             }    
        }
        //EDGE-126317. Kalashree Borgaonkar. Changes for Contiguous pattern. End

        fdo.resourceType = 'Fixed';
        fdo.activityName = SEARCH;
        //EDGE-100661 starts
        fdo.searchType = searchObj.reqSearch;
        if(searchObj.areaCode != ''){
            fdo.nationalDestinationCode = searchObj.areaCode;
        }
        if(searchObj.addressId != ''){
            fdo.addressId = searchObj.addressId;
        }
        if(searchObj.esaValue != ''){
            fdo.geoParam = 'ESA';
            fdo.geoParamValue = searchObj.esaValue;
        }
        //EDGE-100661 ends
        System.debug('fdo'+fdo);
        fnnDto.data = fdo;
        
        FNNSearchResponseDTO fnnResponse = NumberReservationFixedHandler.searchFNN(fnnDto);
        //NResponseDTO.Resources resList = new FNNResponseDTO.Resources();
        List<FNNSearchResponseDTO.Resources> fnnResource=new List<FNNSearchResponseDTO.Resources>();
        Integer requestedQuantity=0;
        Integer returnedQuantity=0;
        
        if(fnnResponse != NULL && fnnResponse.data != NULL){
            
            fnnResource= fnnResponse.data.resources;
            if(fnnResponse.data.requestedQuantity !=NULL && fnnResponse.data.returnedQuantity !=NULL){
            requestedQuantity=Integer.valueOf(fnnResponse.data.requestedQuantity);
            returnedQuantity=Integer.valueOf(fnnResponse.data.returnedQuantity);
                System.debug('requestedQuantity::' + requestedQuantity);
            }
            
            if(searchObj.reqSearch=='Non-Contiguous'){
               
                for(FNNSearchResponseDTO.Resources resource: fnnResource){
                     LRMWrapper wrap = new LRMWrapper();
                    wrap.numberList=resource.resourceId;
                    wrap.isSelectedNew= false;
                   
               	 if(returnedQuantity < requestedQuantity){
                    wrap.message=returnedQuantity  + ' of' + requestedQuantity + ' numbers available using this Search pattern. You can reserve these numbers or search again changing the Pattern';
                }
                else{
                    wrap.message='';
                }
                    //wrap.message='';
                    msisdnList.add(wrap);
                }
                 
            }
            else{
                resSize = fnnResponse.data.resources.size();
                LRMWrapper wrap = new LRMWrapper();
                
                String startNumber=fnnResource[0].resourceId;
                
                String endNumber=fnnResource[resSize-1].resourceId;
                
              
                
                wrap.numberList=startNumber+' - '+endNumber;
                wrap.isSelectedNew= false;
                
                if(returnedQuantity < requestedQuantity){
                    wrap.message=returnedQuantity  + ' of' + requestedQuantity + ' numbers available using this Search pattern. You can reserve these numbers or search again changing the Pattern';
                }
                else{
                    wrap.message='';
                }
                
                msisdnList.add(wrap);
                
            }
        }
        
        System.debug('msisdnList::' + msisdnList);
        return msisdnList;
    }
    
    /******************************************************************
Story: EDGE-59987
Method:reserveFNN  
Author:Ila
*******************************************************
***********/
    @AuraEnabled
    public static NumberReservationFixedHandler.ResponseWrapper reserveFNN(String fnnListToReserve,String basketId, String resourceState,String selectedTab){
        system.debug('fnnListToReserve++' +fnnListToReserve +basketId +resourceState);
        NumberReservationFixedHandler.ResponseWrapper wrap=new NumberReservationFixedHandler.ResponseWrapper();
        
        List<String> listToReserve = new List<String>();
        if(fnnListToReserve!=null){
            List<LRMWrapper> msisdnDetailsList = (List<LRMWrapper>)System.JSON.deserialize(fnnListToReserve, List<LRMWrapper>.Class);
            
            system.debug('msisdnDetailsList+++' +msisdnDetailsList);
            for(LRMWrapper fnn : msisdnDetailsList){
                listToReserve.add(fnn.numberList);
            }
        }
        system.debug('listToReserve+++' +listToReserve);
        wrap=NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(listToReserve,basketId,resourceState, selectedTab);
        system.debug('wrap++++)' +wrap);
        return wrap;  
    }
      /******************************************************************
EDGE-126317
Method:getPatternType 
Description: get Pattern type based on serach type 
Author:Kalashree Borgaonkar
******************************************************************/  
 @AuraEnabled
    public static List<SelectOptionz> getPatternType(String searchType) {
        List<SelectOptionz> patternTypeList = new List<SelectOptionz>();
		patternTypeList.add(new SelectOptionz('None','None'));
        List<Fixed_Number_Search_types__mdt> patternList=[SELECT Is_Include_in_Picklist__c,Pattern_type__c FROM Fixed_Number_Search_types__mdt WHERE Search_type__c=:searchType AND Is_Include_in_Picklist__c=TRUE];
        for(Fixed_Number_Search_types__mdt pattern:patternList){
            patternTypeList.add(new SelectOptionz(pattern.Pattern_type__c,pattern.Pattern_type__c));
        }
        system.debug('uploading patternTypeList ' + patternTypeList);
        return patternTypeList;
    }
 /******************************************************************
EDGE        -100661
Method      -checkForPartnerUser 
Description -Check logged in user in partner user or CRM user
Author      -Dheeraj Bhatt
******************************************************************/ 
    @AuraEnabled public static Boolean checkForPartnerUser(){
        return [SELECT Id,IsPortalEnabled FROM User WHERE id =:UserInfo.getUserId()].IsPortalEnabled;
        
    }
}