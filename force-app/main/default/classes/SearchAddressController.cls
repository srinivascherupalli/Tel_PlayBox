/*------------------------------------------------------------ 
Company: Telstra 
Description: Controller for the Address search lightning components
Test Class: SearchAddressControllerTest 
History :
<18-04-2019> <Kalashree Borgaonakar> <EDGE-76217 Updated the class for mapping> 
------------------------------------------------------------*/
public with sharing class SearchAddressController {
    
    private static string failureMsg = 'Fail';
    
    @AuraEnabled
    public static List<AddressSummary> searchAddress(String addressText) {
        System.debug('In manager class');
        List<AddressSummary> addSum;
        if(addressText == null){
            return null; 
        }
        else{
            addSum = AddressValidateManager.searchAddress(addressText);
            system.debug('uploading addresssummary ' + addSum);
            return addSum;
        }
        
    }
    
    //For Autocomplete Multiformat
    @AuraEnabled
    public static String getAutoCompAddress(String name) {
        //creating dto from adborid
        AddressRequest addressRequestObj = new AddressRequest();
        addressRequestObj.searchData = new AddressRequest.SearchData();
        addressRequestObj.searchData.addressLine1 = name;
        cscrm__Address__c addr = new cscrm__Address__c();
        if(addressRequestObj != null){
          
          addr =   AddressSearch.searchAutoAdd(addressRequestObj,'UnStructuredAutocompleteResponseHandler'); 
        }
        
        if(addr == null){
                system.debug('EAST address is null');
                return 'Fail';
            }
            else{
                List<cscrm__Address__c> addressList = [select id,Address_ID__c from cscrm__Address__c where Address_ID__c =: addr.Address_ID__c];
                if(addressList==null || addressList.isEmpty()){
                    system.debug('EAST address not created');
                    return 'Fail';   
                }
                else{
                    system.debug('created address id ' + addressList[0].id);
                    return addressList[0].id+''; 
                }
            }
            
        return 'fff';
    } 
    /**************** Start of Edge 85839 *****************/
    /**
     * 
     * @name saveAddressApexList
     * @description             :The method will execute from the "InvokeEASTCalloutBatch" class and It will help send the ADBORID to EAST System.
                                 Added one boolean argument to the existing method "saveAddressApex".
     * @param addList           : null 
     * @param selectedAddressId : ADBORID
     * @param searchType        : adborid
     * @param isBatch           : true
     * @return List<cscrm__Address__c> : List of Addresses
     * @jiraStoryRef            : EDGE-85839
     * @createdBy               : Sasidhar Devarapalli,OSAKA
     * 
     **/
    @AuraEnabled
    public static List<cscrm__Address__c> saveAddressApexList(String addList, String selectedAddressId,string searchType, Boolean isBatch){
    //String isBatch = 'Yes';
        AddressResponseDTO nbnAddressDTO = null;
        List<cscrm__Address__c> addressToUpdate = new List<cscrm__Address__c>();
            //nbnAddressDTO = searchAddressByAdborid(selectedAddressId);
            System.debug('selectedAddressIdKala: '+selectedAddressId);
            nbnAddressDTO = AddressSearch.searchAdborIdAddress(selectedAddressId,'AdborIdAddressHandler'); 
            System.debug('nbnAddressDTOKala: '+nbnAddressDTO);
            List<AddressSummary> addsList ;
            if(addList!=null){
                addsList = (List<AddressSummary>)JSON.deserialize(addList, List<AddressSummary>.class);
            }
            // upert using new east nbn interface
            system.debug('addsList-step-1------>'+addsList);
            cscrm__Address__c addr = new cscrm__Address__c();
            if(nbnAddressDTO != null && nbnAddressDTO.code == 200 && nbnAddressDTO.ErrorCode==null && nbnAddressDTO.ErrorDescription==null){
                system.debug('****upserting using new nbn east method');
                addr = AddressAndSiteObjectUtility.upsertNBNEastAddress(nbnAddressDTO, isBatch);
                system.debug('addr-step-1------>'+addr);
                if(addr!=null) {
                    addressToUpdate.add(addr);
                }
                //return addressToUpdate;
            }
            else{
                if(searchType == 'adborid'){
                    String errMsg = 'EAST address not created';
                    system.debug(errMsg);
                    throw new AddressException (errMsg);   
                }
                else{
                    for(AddressSummary ads: addsList){
                        if(ads.addressId == selectedAddressId){
                            addr = AddressAndSiteObjectUtility.UpsertEastAddress(ads);
                               system.debug('addr-step-2------>'+addr);
                            if(addr!=null) {
                                addressToUpdate.add(addr);
                            }
                            system.debug('result from upsert ' + addr);
                            break;
                        }
                     }              
                 }
            }
            
           
            //for returning the address to create site page
            if(addr == null){
                String errMsg = 'EAST address is null';
                system.debug(errMsg);
                throw new AddressException ( errMsg);   
                
            }
            else{
                if(isBatch)
                {
                     System.debug('addressToUpdate ====>step-2--------->'+addressToUpdate.size()+'---------->'+addressToUpdate);
                     return addressToUpdate;
                }
                else{
                    List<cscrm__Address__c> addressList = [select id,Address_ID__c from cscrm__Address__c where Address_ID__c =: addr.Address_ID__c LIMIT 1];
                  system.debug('addr-step-3------>'+addressList);
                
                if(!addressList.isEmpty() && addressList.size()>0){
                    addressToUpdate.addAll(addressList);
                    //return addressList;
                }else
                {
                    String errMsg = 'EAST address not created';
                    system.debug(errMsg);
                    throw new AddressException ( errMsg); 
                } 
                }
            }
            return addressToUpdate;
            /**************** End of Edge 85839 *****************/
        
    }
    /**************** End of Edge 85839 *****************/
    
     /*------------------------------------------------------------ 
    EDGE - 76217
    Method: saveAddressApex 
    Description: Creates the Address record using response received from AddressSq
    Inputs: addresslist , adborid, searchType 
    Returns: List of address to display on UI 
    History 
    <18-04-2019> <Kalashree Borgaonkar>
    ------------------------------------------------------------*/
    //Overridden the method with one extra boolean argument to extend the existing functionality to use in InvokeEastCalloutBatch Batch class.
    @AuraEnabled
    public static String saveAddressApex(String addList, String selectedAddressId,string searchType){
        /**************** Start of Edge 85839 *****************/
         try{
          List<cscrm__Address__c> updateAddressList=saveAddressApexList(addList, selectedAddressId,searchType, false);
          
          return updateAddressList.get(0).id;
          }catch(Exception e){
            system.debug('East save address exception'+e.getStackTraceString());
            return failureMsg;
        }
        /**************** End of Edge 85839 *****************/
          
    }
 
    @AuraEnabled
    public static String getId(String adborid){
       List<cscrm__Address__c> addressList;
       String addList;
       try{
        addressList = [select id,Address_ID__c from cscrm__Address__c where Address_ID__c =: adborid];
        addList = addressList[0].id;        
       }Catch(Exception e){
           system.debug('*****in catch');
            return null;
        }
       return addList;
    }
    
   
    
    @AuraEnabled
    public static List <String> fetchAdd(String searchedText) {
      System.debug('-----' + searchedText);
      //add 1st callout
      List <String> returnList = AddressSearch.searchAutocomplete('UnStructuredAutocompleteHandler',searchedText);
      if(returnList==null){
          return null;
      }else{
      
       system.debug('returnList' + returnList);

      return returnList;
    }
    }

    @AuraEnabled
    public static sObject getErrorMsg(String errorStatus){
        System.debug('errorStatus++' +errorStatus);
        sObject BusinessDescription;
        try{
         BusinessDescription = Database.query('SELECT BusinessDescription__c FROM ErrorMappingSQ__mdt WHERE ErrorCode__c =: errorStatus');  
        //BusinessDescription = Database.query('SELECT BusinessDescription__c FROM Error_Mapping__mdt WHERE (ErrorCode__c =: errorStatus and Interface__c =: interfaceName)'); 
        }Catch(Exception e){
            return null;
        }
        return BusinessDescription;
    }
       @AuraEnabled
    public static sObject getErrorMsgInterface(String errorStatus,String interfaceName){
        sObject BusinessDescription;
        try{
         //BusinessDescription = Database.query('SELECT BusinessDescription__c FROM ErrorMappingSQ__mdt WHERE ErrorCode__c =: errorStatus');  
        BusinessDescription = Database.query('SELECT BusinessDescription__c FROM Error_Mapping__mdt WHERE (ErrorCode__c =: errorStatus and Interface__c =: interfaceName)'); 
        }Catch(Exception e){
            return null;
        }
        return BusinessDescription;
    }
    
    /* US41754 */
     
  
     /**
     * EDGE - 57162
     * Unstructured Search AddressSQ
     */
     @AuraEnabled
    public static List<AddressSummary> searchAddressSQ(Map<String, Object> params,String handler,String adborid) {
        System.debug('In manager class');
        System.debug('params++' +params +'handler++' +handler +'adborid++' +adborid);
        List<AddressSummary> addSum;
        if(params != null && params.size()>0 && handler!= 'AdborIdAddressHandler' && handler!='UnStructuredAutocompleteHandler'){
            addSum = AddressValidateManager.searchAddressSQ(params,handler,adborid);
            system.debug('uploading addresssummary ' + addSum);
            system.debug('handler ' + handler);
            return addSum;
         }else if(adborid!=null && handler== 'AdborIdAddressHandler' ){
             addSum = AddressValidateManager.searchAddressSQ(params,handler,adborid);
             return addSum;
         }
        return null; 
    }
    
    /*US41754  */
    @AuraEnabled
    public static List<SelectOptionz> getPostCodeByState(String stateCode) {
        System.debug('In manager class' +stateCode);
        List<SelectOptionz> postCodeList = new List<SelectOptionz>();
        if(String.isNotBlank(stateCode)){
            postCodeList = AddressValidateManager.getPostCodeByState(stateCode);
            system.debug('uploading addresssummary ' + postCodeList);
            return postCodeList;
         }
        system.debug('uploading addresssummary ' + postCodeList);
        return postCodeList;
    } 
    
    /* US41754  */
     @AuraEnabled
    public static List<SelectOptionz> getLocalityByPostCode(String postCode) {
        System.debug('In manager class' +postCode);
        List<SelectOptionz> localityList = new List<SelectOptionz>();
        if(String.isNotBlank(postCode)){
            localityList = AddressValidateManager.getLocalityByPostCode(postCode);
            system.debug('uploading addresssummary ' + localityList);
            return localityList;
         }
        system.debug('uploading addresssummary ' + localityList);
        return localityList;
    }
    public class AddressException extends Exception {
        
    }
  /*-------------------------------------------------------- 
EDGE-122625
Method: getStreettype
Description: get list of street type
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
     @AuraEnabled
    public static List<SelectOptionz> getStreettype() {
        List<SelectOptionz> StreetTypeList = new List<SelectOptionz>();
        List<TCM_EAST_Street_Type__c> streetList=[SELECT StreetType__c FROM TCM_EAST_Street_Type__c ORDER BY StreetType__c];
        for(TCM_EAST_Street_Type__c street:streetList){
            StreetTypeList.add(new SelectOptionz(street.StreetType__c,street.StreetType__c));
        }
        system.debug('uploading StreetTypeList ' + StreetTypeList);
        return StreetTypeList;
    }
}