/*******************************************************************************************************
Name          : ChargeZoneController
Created By    : Aman Soni
Created Date  : Nov 27 2019
Description   : This class is the controller for Zone Update invoked on Access Technology attribute update
Test class    : ChargeZoneControllerTest
-------
History
-------
VERSION     AUTHOR          DATE            DETAIL     
-------     ------          -----           ---------
1.1         Aman Soni       27-11-2019      Class created as part of EDGE-98299
1.2 		Laxmi Rahate    20-12-2019      EDGE-98299 Change made in URL for Microservice as MS URL is changed and added one condition
1.3 		Laxmi Rahate    20-12-2019      EDGE-137160 Change made in URL for Microservice 
1.4         Ajith Kumar     08/Oct/2021     DIGI-15723 : Updated logic product charge zone api
1.5         Ajith Kumar     28/Oct/2021     DIGI-33904 : Created a New method for Updating the Rental Values from MS API.

*******************************************************************************************************/
global with sharing class ChargeZoneController implements cssmgnt.RemoteActionDataProvider {

    //DIGI-33904 Created final variables for static values
    public final static string CHARGE_ZONE_PRODUCT_GROUP_A='A';
    public final static string CHARGE_ZONE_PRODUCT_GROUP_B='B';
    public final static string CHARGE_ZONE_PRODUCT_GROUP_C='C';
    public final static string CHARGE_ZONE_PRODUCT_GROUP_D='D';
    
/****************************************************************************************************
* Method Name : getData
* Description : Default method to be overwritten from the Interface to perform Remote Actions
* Parameters  : Map<String, Object>     -   inputMap passed from the JavaScript Plugin
* Return      : Map<String, Object>     -   ReturnMap with the details required for JavaScript Plugin
****************************************************************************************************/
global Map<String,Object> getData(Map<String,Object> inputMap){
    try{
        Map<String, Object> returnMap = new Map<String, Object>(); 
            
        //Call service method to get response      
        HttpResponse response = new HttpResponse();
        String es = String.valueOf(inputMap.get('esaCode'));
        String czp = String.valueOf(inputMap.get('czpId'));
        String csd = String.valueOf(inputMap.get('contractStartDate'));
        
        if(!String.isBlank(es) && !String.isBlank(csd) && !String.isBlank(czp)){
            GetChargeZoneAPIDTO resDTO = new GetChargeZoneAPIDTO();
            resDTO = ChargeProductZoneHandler.callChargeProductZoneService(es,csd,czp);          
            //Put the required response to return map and send it to Js
            Object responseToReturn;
            if(resDTO != null && resDTO.zone!=null && resDTO.zone.rental != null && resDTO.zone.sla != null){
                responseToReturn = resDTO.zone.rental;
                returnMap.put('Zone Rental',responseToReturn);
                responseToReturn = resDTO.zone.sla;
                returnMap.put('Zone SLA',responseToReturn);
            }
            else{ //  EDGE-98299 Added Below condition to be handled in js in case response in Null from MS
                responseToReturn = '';
                returnMap.put('Zone Rental',responseToReturn);
            }
            if(Test.isRunningTest() && es.equals('TestException')){
                CalloutException e = new CalloutException();
                e.setMessage('Testing exceptionblock from test class');
                throw e;
            }
            return returnMap;           
        }
    }catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception while checking for Charge Zone Service : ' + e.getMessage()));
            logger.exitLogger();
    }
    return null;    
}

/*
Story Number: DIGI-33904
Created By: Ajith Kumar
Description:  Method to update the Rental values provided by chargezone MS API and sigma 
@Param: siteId,isImmediate,ProductType
*/
public static GetChargeZoneAPIDTO chargeZoneProductMapping(Id siteId,Boolean isImmediate,String productType){
    
    List<ZoneProductList__mdt> zoneProductList=[Select Product_Type__c,Group_Name__c,Default_Value__c from ZoneProductList__mdt where Product_Type__c=:productType LIMIT 1];
    GetChargeZoneAPIDTO getchargeZoneReponse=ChargeProductZoneHandler.fetchProductChargeZoneInfo(siteId,isImmediate,true);
    if(zoneProductList!=null && !zoneProductList.isEmpty() && zoneProductList[0].Product_Type__c!=null ){
        if(zoneProductList[0].Group_Name__c.equalsIgnoreCase(CHARGE_ZONE_PRODUCT_GROUP_A)){
            return getchargeZoneReponse;
        }
        else if(zoneProductList[0].Group_Name__c.equalsIgnoreCase(CHARGE_ZONE_PRODUCT_GROUP_B)){
            getchargeZoneReponse.zone.rental=zoneProductList[0].Default_Value__c;
        }
        else if(zoneProductList[0].Group_Name__c.equalsIgnoreCase(CHARGE_ZONE_PRODUCT_GROUP_C) && getchargeZoneReponse!=null && getchargeZoneReponse.zone!=null && getchargeZoneReponse.zone.products!=null && !getchargeZoneReponse.zone.products.isEmpty()){
            getchargeZoneReponse=chargeProductZoneHandler.mappingGroupCProducts(getchargeZoneReponse,zoneProductList);
        }
        else if(zoneProductList[0].Group_Name__c.equalsIgnoreCase(CHARGE_ZONE_PRODUCT_GROUP_D)){
            getchargeZoneReponse.zone.rental=getchargeZoneReponse.zone.sla;
        }
        else{
            getchargeZoneReponse.zone.rental=null;
        }      
    }
    return getchargeZoneReponse;
}
}