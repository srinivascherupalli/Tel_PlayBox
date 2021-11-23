/*********************************************************************************************************************************
Author  : Anuj Pathak
Class Name      :   LegacyTenancyHelper
Test Class : LegacyTenancyHelperTest
Description : class is to implement stamping of legacy tenancy id attribute of brodsoft tenancy product  using transitionnguc.json from business calling product.

*********************************************************************************************************************************************************************

**/
global with sharing class LegacyTenancyHelper implements cssmgnt.RemoteActionDataProvider{
    @RemoteAction
    global static Map<String, Object> getData(Map<String, Object> inputMap)
    {
        Map<String, Object> returnMap = new Map<String, Object>();
        try {
        Set<String> inputKey = inputMap.keySet();
        for (String key : inputKey)
        {
            if (key != null || key.length() > 0)
            {    
            if (key == 'populateLegacyTenancyID' )
            {
                String basketId = (String)inputMap.get('populateLegacyTenancyID');
                System.debug('populateLegacyTenancyID for BaseketId:  ' + basketId);
                String res = populateLegacyTenancyID(basketId);
                returnMap.put('TenancyID', res);
                
            }
        }    
        }
        System.debug('returnMap: ' + returnMap);
        return returnMap; 
    }
    catch (Exception e){
        System.debug('gettenancydata: ' + e.getMessage());
        return returnMap;
    }
    }
/**********************************************************************************************************************************
Author  : Anuj Pathak
Method Name      :   populateLegacyTenancyID
Description : class is to implement stamping of legacy tenancy id attribute of brodsoft tenancy product  using transitionnguc.json from business calling product.
Parameter : Active basket id
Output : Map contains legacytenancyid value
*********************************************************************************************************************************************************************

**/
    global static string populateLegacyTenancyID(string basketId)
    {
        try
        {
            if (basketId == null || basketId.length() == 0)
            {
                return '';
            }
            else {
            Attachment attachment =[select body from attachment 
                                                        where name =: Label.NgUcTransitionName  
                                                        and 
                                                        parentid in 
                                                                (select id   
                                                                        from cscfga__Product_Configuration__c  
                                                                        where cscfga__Product_Definition__r.product_Specification__c= :Label.business_calling_product_specification
                                                                        and cscfga__Product_Basket__r.id=:basketId) limit 1];
            
            TransitionDataDTO attachmentBody =TransitionDataDTO.parse(attachment.Body.toString());
            string result=attachmentBody.LegacyTenancyID;
            return result;
            
            }
        } 
        catch (Exception e)
        {
            System.debug('getPCattachment: ' + e.getMessage());
            return '';
        }
    }
}