/*************************************************************************************************
Name : macDiscountHandler
===============================================================================================================================
Sr.No.    Developer Name      Date            Story Description
1.        Shubhi              21-09-2021      DIGI-16898  (new)
================================================================================================================================
***************************************************************************************************/
/*  
     * Method Name : getData this method is used for sending discount data from apex back to js using remoteAction 
     * Input Parameter 1 : Map<String, Object> inputMap from js 
     * Return Parameter : Map<String, Object>
     * Owner : shubhi V
     * Jira : DIGI-16898
    */
	global class macDiscountHandler implements cssmgnt.RemoteActionDataProvider{
    @RemoteAction
    global static Map<String, Object> getData(Map<String, Object> inputMap){
        Map<String, Object> returnMap=new Map<String, Object>();
        if(inputMap.containskey('getCarryForwardDiscounts') && inputMap.containskey('configList')){
            String configIdListStr = (String)inputMap.get('configList');
            List<String> configIdList = new List<String>(configIdListStr.split(','));
            for(Discount_Line_Item__c dli:[Select id,BusinessID__c,chargeInstance__r.serviceId__r.csordtelcoa__Product_Configuration__c 
                  from Discount_Line_Item__c  where chargeInstance__r.serviceId__r.csordtelcoa__Product_Configuration__c IN:configIdList AND(isUnlimited__c=true OR discountEndDate__c>=Today)]){
                      if(returnMap.containskey(dli.chargeInstance__r.serviceId__r.csordtelcoa__Product_Configuration__c )){
                          String value=returnMap.get(dli.chargeInstance__r.serviceId__r.csordtelcoa__Product_Configuration__c)+','+dli.BusinessID__c;
                          returnMap.put(dli.chargeInstance__r.serviceId__r.csordtelcoa__Product_Configuration__c,value);
                      }else{
                          returnMap.put(dli.chargeInstance__r.serviceId__r.csordtelcoa__Product_Configuration__c,dli.BusinessID__c);
                      }                             
             }
        }
        if(inputMap.containskey('checkFeatureEligibility')){
            for(FeatureToggle__mdt fmd: FeatureToggle__mdt.getAll().values()){
               returnMap.put(fmd.developerName,fmd); 
            }
        }
        system.debug('@@@@@@@'+returnMap);
        return returnMap;
    }
    
}