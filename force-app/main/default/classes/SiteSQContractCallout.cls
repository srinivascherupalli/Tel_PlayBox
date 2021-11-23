/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 18 March 2019
 * Description : Class to initiate web callout to SQ Site services
 * Revision :
 * 
 * *****************************************************************************/
public without sharing class SiteSQContractCallout implements Database.AllowsCallouts{
    public Integer configurablePeriod;
    SiteSQContractCalloutHandler sqHandler = new  SiteSQContractCalloutHandler();
    public static final String handler =  'SiteSQAddressHandler';
    public Integer SQQualifiedCounter =0;
    public SiteSQContractCallout(){
       this.configurablePeriod = Integer.valueOf(Label.SQSiteConfigDays);
    }

/***********************************************************************
  * Name: siteSQContractCallout
  * Author : Mohammed Zeeshan : EDGE-79405
  * Date : 18 March 2019
  * Description:Parameterized Constructor 
*******************************************************************/    
    public siteSQContractCallout(String triggerringEvent){
        if(triggerringEvent == 'BasketClone'){
            this.configurablePeriod = Integer.valueOf(Label.RetriggerSQSiteonBasketClone);
        }else if(triggerringEvent == 'Contract'){
            this.configurablePeriod = Integer.valueOf(Label.SQSiteConfigDays);
        }
    }
    
   
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 18 March 2019
 * Description : Initiate Callout and token authorisation
 * Parameters : List of String,Account Id
 * Return type : Map of Http response
 * *****************************************************************************/
    
    public Map<String,HttpResponse>  initiateSQService(List<String> addressidList, String AccountId){
           Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        if(!addressidList.isEmpty()){
             List<String>    addressidListForSQ = addressidList;
            System.debug('addressidListForSQ '+addressidListForSQ);
            if(!addressidListForSQ.isEmpty()){
                
                String token = AuthenticationManager.getOauthToken(handler);
                System.debug('Debug List## '+addressidListForSQ);
                addressToResponseMap = callSQService(token,addressidListForSQ,AccountId);
                 System.debug('addressToResponseMap res## '+addressToResponseMap);
                return addressToResponseMap;
            }
            
        }
         return addressToResponseMap;
    } 
    
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 18 March 2019
 * Description : Actual callout method : invoking class: IntegrationRecordHandlerUtil
 * Parameters : String, List of String, Account ID
 * Return type : Map of Http response
 * *****************************************************************************/
    public  Map<String,HttpResponse> callSQService(String token, List<String> addressidList,String AccountId){
        
       
        SqResponseDTO responseDTO =null;
        List<Service_Qualification__c> serviceQList =new List<Service_Qualification__c>();
        Logger2 logger = Logger2.getLogger(handler);
        HttpResponse response;
        String payload = '';
        String serviceFilter='Internet';
        Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        System.debug('addressidList **'+addressidList);
        System.debug('addressidListSize **'+addressidList.Size());
        try{    
            for(String addressId:addressidList){
                 payload = 'addressId='+addressid+'&serviceFilter='+serviceFilter;
               
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                response = IntegrationRecordHandlerUtil.callout(payload,'GET',headerMap,handler,null, null);
                String responseCode = String.valueOf(response.getStatusCode());
                System.debug('addressRes: '+response);  
                addressToResponseMap.put(addressid,response);
            }
          
                for(String addId: addressToResponseMap.keyset()){
                    
                    HttpResponse res = addressToResponseMap.get(addId);
                    System.debug('res.getStatusCode## ' +res.getStatusCode() +'& res.getBody():' + res.getBody());
                    if (res.getStatusCode() == 200) {
                        Service_Qualification__c sqRec = new Service_Qualification__c();
                        responseDTO = SqResponseDTO.parse(res.getBody());
                        System.debug('responseDTO: '+responseDTO);
                        logger.logMessages(addId, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , null, null, null);
                        System.debug('MapOfResp '+addressToResponseMap);
                        //sqHandler.saveSQResponse(addId,responseDTO);
                        sqRec = sqHandler.saveSQResponse(addId,responseDTO,AccountId);
                        serviceQList.add(sqRec);
                      
                    }  
                    System.debug('serviceQList ** '+serviceQList);
                   logger.exitLogger();
                }
            if(!serviceQList.IsEmpty()){
                insert serviceQList;
                System.debug('serviceQList** '+serviceQList);
                // Save partial response : ProviderResources
                sqHandler.saveProviderResources(serviceQList,addressToResponseMap);
               
                //iterating response map to save ResourceDetail 
                
                for(String addId: addressToResponseMap.keyset()){
                    
                    HttpResponse res = addressToResponseMap.get(addId);
                    System.debug('res.getStatusCode## ' +res.getStatusCode() +'& res.getBody():' + res.getBody());
                    if (res.getStatusCode() == 200) {
                        Service_Qualification__c sqRec = new Service_Qualification__c();
                        responseDTO = SqResponseDTO.parse(res.getBody());
                        List<SqResponseDTO.ServiceTypeQualifications> srvQualificationList = responseDTO.data.serviceTypeQualifications;
                        if(!srvQualificationList.isEmpty()){
                            for(SqResponseDTO.ServiceTypeQualifications sq: srvQualificationList){
                                if(sq.technologyType.equalsIgnoreCase('Fibre')){
                                    sqHandler.saveResourceDetail(serviceQList,responseDTO);
                                }
                            }
                        }
                        
                    }
                }
               
            }
                 System.debug('addressToResponseMap Size'+addressToResponseMap.Size());
                 return addressToResponseMap;
             
        }catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }       
      
        return null ;
    }   
      
        
    /* ****************************************************************************
 * Author : Manoj Kumar 
 * Date : 18 March 2019
 * Description : Get list of addressids for which call is not made within configurable time period. 
 * Parameters : List of String
 * Return type : List of String
 * *****************************************************************************/
    
    
    public List<String> getConfigurableAddressIdList(List<String> addressidList,String AccountId){
       System.debug('AccountId** '+AccountId);
        List<cscrm__Site__c> siteList = [SELECT id,AdborID__c,(SELECT CreatedDate,Copper_Pair_Indicator__c,Status__c from Service_qualifications__r ORDER BY CreatedDate LIMIT 1) FROM 
                                         cscrm__Site__c WHERE AdborID__c IN  :addressidList AND cscrm__Account__c =:AccountId];
        System.debug('List_siteList'+siteList);
        System.debug('List_siteListSize '+siteList.Size());
        List<Service_Qualification__c> sqList = null;
        List<String> adboridList = new List<String>();
        for(cscrm__Site__c site : siteList){
            sqList = site.Service_qualifications__r;
            if(sqList.isEmpty()){
                adboridList.add(site.AdborID__c);
            }
            else{
                if(shouldInitiateSQ(Date.valueOf(sqList[0].CreatedDate))){
                    adboridList.add(site.AdborID__c);
                }
            }
        }
        System.debug('adboridList '+adboridList);
        return adboridList;
     
    }
    
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 18 March 2019
 * Description : Check if  call was made within configurable time period.
 * Parameters : Date
 * Return type : Boolean
 * *****************************************************************************/
    public Boolean shouldInitiateSQ(Date createDate){
        Date todayDate = Date.today();
        if(todayDate.daysBetween(createDate)>configurablePeriod){
            return true;
        }
        else{
            return false;
        }
    }    
}