/* ****************************************************************************
Class Name      : SolutionHelperESACode
* Author        : Laxmi Rahate : EDGE-98299
* Date          : 25 Nov 2019
* Description   : Class for fetching the ESA Code
* *****************************************************************************/
global with sharing class SolutionHelperESACode implements cssmgnt.RemoteActionDataProvider {

/****************************************************************************************************
* Method Name : getData
* Description : Default method to be overwritten from the Interface to perform Remote Actions
* Parameters  : Map<String, Object>     -   inputMap passed from the JavaScript Plugin
* Return      : Map<String, Object>     -   ReturnMap with the details required for JavaScript Plugin
****************************************************************************************************/
    global Map<String,Object> getData(Map<String,Object> inputMap){
        Map<String, Object> returnMap = new Map<String, Object>();      
        System.debug('inputMap'+inputMap);
        
        String adborID = (inputMap.containsKey('adborID') && inputMap.get('adborID') != '')? (String)inputMap.get('adborID'):'';
        String cidn = (inputMap.containsKey('cidn') && inputMap.get('cidn') != '')? (String)inputMap.get('cidn'):'';
      
        
        cscrm__Site__c site = getESACode(adborID,cidn);        
        returnMap.put('ESACode', site);
       
       return returnMap;
    }
    
/******************************************************************************************************
* Method Name : getZonePattern
* Description : Used to fetch ZonePattern from  ChargeZone Object
* Parameters  : NA
* Return      : NA                      
******************************************************************************************************/
    public static cscrm__Site__c getESACode(String adborID, String cidn){
       // System.debug ( 'adborID' + adborID + ' cidn ' + cidn);
        cscrm__Site__c site =  new cscrm__Site__c ();
        if(String.isNotBlank(adborID ) && String.isNotBlank(cidn  )){
            site = [select id,cscrm__Account__c, cscrm__Account__r.CIDN__c,AdborID__c, cscrm__Installation_Address__r.ESA_Code__c from cscrm__Site__c where  cscrm__Account__r.CIDN__c = :cidn and AdborID__c = :adborID limit 1 ];
        }
        if (site.cscrm__Installation_Address__r.ESA_Code__c == null)
        {
            site.cscrm__Installation_Address__r.ESA_Code__c = '';
        }
        return site;
     }
      
}