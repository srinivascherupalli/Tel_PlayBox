/**@Date : 2 AUG 2021
 * @description       : Charge Product Zone Handler class having all related methods
 * @author            : Ajith Kumar
 * @Jira : DIGI-15723
 * @test class : ChargeZoneControllerTest
 ******************************************************** CHANGE LOG ********************************************************
 * SL.No    Developer Name      Date            Description
 * 1.       Ajith Kumar      12/Oct/2021        DIGI-15723 : Updated logic product charge zone api
 * 2.       Ajith Kumar      20/Oct/2021        DIGI-15723 : Added request in logs
 * 3.       Ajith Kumar      02/Nov/2021        DIGI-33904 : created new method to assign rental values for Group C Product Types
 * 4.       Ajith Kumar      15/Nov/2021        DIGI-15723 : Removed null assignments and stored the response statusCode 
**/
public with sharing class ChargeProductZoneHandler {
    public static List<ApplicationLog__c> logList=new List<ApplicationLog__c>();
    public static List<cscrm__Site__c> siteObjectList=new List<cscrm__Site__c>();
    public final static string RENTAL_NATIONAL='National';
    public final static string RENTAL_DC_RATE_CARD='DC Rate Card';
    public final static string PRODUCT_AVAILABLE='Available';
    public final static string PRODUCT_NOT_AVAILABLE='Not Available';
    public final static string RENTAL_ZONE='zone';
    // Makes API call to Microservices to get charge Zone API response
    public static GetChargeZoneAPIDTO callChargeProductZoneService(String esaId, String contractStartDate, String czpId){
        GetChargeZoneAPIDTO responseDTO = null;
		responseDTO = makeChargeProductZoneCallout(esaId,contractStartDate,czpId,true);
        return responseDTO;
    }

/*
Story Number: DIGI-15723
Created By: Ajith Kumar
Description:  Method to call the API to get charge zone response and log based on the Boolean check Parameter value
@Param: esaId,contractStartDate,czpId,insertLog
*/
    public static GetChargeZoneAPIDTO makeChargeProductZoneCallout(String esaId, String contractStartDate, String czpId,Boolean insertLog){
        String correlationid = EDISSingleManager.getUID();
        String zoneHandler ='ChargeZoneServiceHandler';
        Logger2 logger = Logger2.getLogger(zoneHandler);
        HttpResponse response = new HttpResponse();
        ApplicationLog__c logresponse=new ApplicationLog__c(); 
        //DIGI-15723 Removed null assignment
        GetChargeZoneAPIDTO responseDTO = new GetChargeZoneAPIDTO();
        String payload = '';
    
        String token = AuthenticationManager.getOauthToken(zoneHandler);
        payload = 'esaCode='+esaId+'&czpId='+czpId+'&contractStartDate='+contractStartDate;
        Map<String,String> headerMap = new Map<String, String>{'Accept' => 'application/json',
                                                                'Content-Type' => 'application/json',
                                                                'Authorization'=> 'Bearer '+ token,
                                                                'correlationId'=> correlationid};
        
        response = IntegrationRecordHandlerUtil.callout(payload, 'GET', headerMap, zoneHandler, null, null);
        //DIGI-15723 Added status Code in the response returned
        if(response != null && response.getBody()!= null && response.getStatusCode()!=null){                       
            String resbody = response.getBody();
            if(response.getStatusCode() == 201 || response.getStatusCode() == 200){
                responseDTO = GetChargeZoneAPIDTO.parse(resbody);
                
            }
            if(insertLog){
            logger.logMessages(payload, resbody, '', '', '', '', true, false,Integer.valueof(response.getStatusCode()) , null, null, null);
            logger.exitLogger();
            }
            else{
                logresponse = logger.logMessage(payload,resbody,false,String.valueOf(response.getStatusCode()),correlationId,zoneHandler);
                if(logresponse!=null){
                    logList.add(logresponse);
                }                
            }
            //DIGI-41781 Storing the statuscode to responseDTO 
            responseDTO.statusCode=response.getStatusCode();
        }
        return responseDTO;
    }

/*
Story Number: DIGI-15723
Created By: Ajith Kumar
Description:  Method to return the wrapper response to LWC component to display the product Zone information
@Param: selectedSiteid,isImmediate
*/
/*
Story Number: DIGI-33904
Modified By: Ajith Kumar
Description: Added extra parameter to this method to log response for zoneRental Mapping
@Param: selectedSiteid,isImmediate,zoneMapping
*/
    public static GetChargeZoneAPIDTO fetchProductChargeZoneInfo(Id selectedSiteId, Boolean isImmediate,Boolean zoneMapping){
        //DIGI-15723 Removed null assignment
        GetChargeZoneAPIDTO chargeZoneInfo = new GetChargeZoneAPIDTO();              
            if (String.isNotBlank(selectedSiteId)) {
                cscrm__Site__c objSite = [SELECT Id, ProductZoneAPIResponse__c, LastVerificationDate__c, cscrm__Installation_Address__r.ESA_Code__c 
                                            FROM cscrm__Site__c 
                                            WHERE Id =: selectedSiteId 
                                            LIMIT 1];
                if (objSite != null) {
                    String esaCode = objSite.cscrm__Installation_Address__r.ESA_Code__c;
                    String contractDate = DateTime.now().format('yyyy-MM-dd');
                    String czpId = '1';

                    if (isImmediate || String.isBlank(objSite.ProductZoneAPIResponse__c)) {
                        chargeZoneInfo = makeChargeProductZoneCallout(esaCode, contractDate, czpId,false);
                        objSite.LastVerificationDate__c = Datetime.now();
                        chargeZoneInfo.lastVerificationDate= objSite.LastVerificationDate__c;
                        objSite.ProductZoneAPIResponse__c = JSON.serialize(chargeZoneInfo);
                        
                        // Store the respone back to Site Object
                        siteObjectList.add(objSite);

                    }else {
                        chargeZoneInfo = GetChargeZoneAPIDTO.parse(objSite.ProductZoneAPIResponse__c);
                    }
                }
                if(zoneMapping==true){
                    updateSiteRecords(null,logList);
                }
            }
        return chargeZoneInfo;
    }

/*
Story Number: DIGI-15723
Created By: Ajith Kumar
Description:  Method to store product Zone from siteTriggerHelper
@Param: siteRecordIds
*/ 
    @future(callout = true)
    public static void storeProductChargeZoneInfo(set<Id> siteRecordIds){
        try{
            if(siteRecordIds!=null && !siteRecordIds.isEmpty()){
                for(Id siteRecord : siteRecordIds){
                    fetchProductChargeZoneInfo(siteRecord, true,false);//DIGI-33904 Added extra boolean Parameter check for logging zone rental Mapping API response
                }
                updateSiteRecords(siteObjectList,logList);        
            }
        }
        catch(Exception ex){
            GenericUtilityClass.logException('ChargeProductZoneHandler','storeProductChargeZoneInfo','','',ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString(),'Exception occured during future callout',C2O_ExceptionHandler.Capability.ORD);
        }
    }
/*
Story Number: DIGI-15723
Created By: Ajith Kumar
Description:  Method to return results on refresh from Product Zone tab
@Param: siteRecordId
*/
    @AuraEnabled
    public static GetChargeZoneAPIDTO refreshProductChargeZoneInfo(Id siteRecordId,Boolean isImmediate){
        //DIGI-15723 Removed null assignment
        GetChargeZoneAPIDTO chargeZoneInfo = new GetChargeZoneAPIDTO();
        try{
            if(siteRecordId!=null){
                chargeZoneInfo=fetchProductChargeZoneInfo(siteRecordId, isImmediate,false);//DIGI-33904 Added extra boolean Parameter check for logging zone rental Mapping API response
            }
            updateSiteRecords(siteObjectList,logList); 
        }
        catch(Exception ex){
            GenericUtilityClass.logException('ChargeProductZoneHandler','refreshProductChargeZoneInfo','','',ex.getMessage() + ' - ' + ex.getLineNumber() + ' - ' +ex.getStackTraceString(),'Exception occured during refreshing the product zone tab',C2O_ExceptionHandler.Capability.ORD);

        }       
        return chargeZoneInfo; 
    }
/*
Story Number: DIGI-15723
Created By: Ajith Kumar
Description:  Method to update the site and log list
@Param: logList
*/
    public static void updateSiteRecords(List<cscrm__Site__c> siteObjectList,List<ApplicationLog__c> logList){
        //33904 Added Null check for siteObjectList and logList
        if(siteObjectList!=null && !siteObjectList.isEmpty() && siteObjectList.size()>0){
            update siteObjectList;
        }
        if(logList!=null && !logList.isEmpty() && logList.size()>0){
            insert logList;
        }        
    }

/*
Story Number: DIGI-33904
Created By: Ajith Kumar
Description:  Method to update the Rental values provided by chargezone for Group C Product Type
@Param: getchargeZoneReponse,zoneProductList
*/
public static GetChargeZoneAPIDTO mappingGroupCProducts(GetChargeZoneAPIDTO getchargeZoneReponse,List<ZoneProductList__mdt> zoneProductList){
    List<GetChargeZoneAPIDTO.Products> productList=new List<GetChargeZoneAPIDTO.Products>();
    productList=getchargeZoneReponse.zone.products;               
    for(GetChargeZoneAPIDTO.Products products:productList){
        if(products.name.equalsIgnoreCase(zoneProductList[0].Product_Type__c) && products.availability.equalsIgnoreCase(PRODUCT_AVAILABLE)){
            //DIGI-33904 change to containsIgnoreCase 
            if(getchargeZoneReponse.zone.rental.containsIgnoreCase(RENTAL_ZONE)){
                getchargeZoneReponse.zone.rental=RENTAL_NATIONAL;
            }
            else if(getchargeZoneReponse.zone.rental.containsIgnoreCase(RENTAL_DC_RATE_CARD)){
                getchargeZoneReponse.zone.rental=RENTAL_DC_RATE_CARD;
            }
            else{
                getchargeZoneReponse.zone.rental=null;                
            }
        }
        else if(products.name.equalsIgnoreCase(zoneProductList[0].Product_Type__c) && products.availability.equalsIgnoreCase(PRODUCT_NOT_AVAILABLE)){
            getchargeZoneReponse.zone.rental=null;
        }     
    }
    return getchargeZoneReponse;
} 
}