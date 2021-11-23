/*Author: Kalashree Borgaonkar
Company: Tesltra 
User Story :EDGE-118383
Description: Lightning UI controllerController to initiate callout from PB.
*/
global class AddressEastCallout {
    static final String  HANDLER_NAME = 'AdborIdAddressHandler';
    /*-------------------------------------------------------- 
EDGE-118383
Method: makeCallout
Description: Initiates EAST callout
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    @InvocableMethod
    global  static void makeCallout(List<String> addressid){
        if(!addressid.isEmpty()){
            AddressResponseDTO addressDTO =AddressSearch.searchAdborIdAddress(addressid[0],HANDLER_NAME);
            if(addressDTO!=null){
                AddressAndSiteObjectUtility.upsertNBNEastAddress(addressDTO);
            }  
        } 
    }

}