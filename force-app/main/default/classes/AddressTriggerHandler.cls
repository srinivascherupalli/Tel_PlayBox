public class AddressTriggerHandler {
    
    public  static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }
        else {
            return run;
        }
    }
    public void onAfterUpdate(List<cscrm__Address__c> newList){
        if(AddressTriggerHandler.runOnce()){
            publishCreateBillingEvents(newList,EventConstants.UPDATE_OPERATION); 
        }
    }    
    /*------------------------------------------------------------ 
Story: EDGE-122626
Author: Kalashree Borgaonkar
Method: onBeforeInsertUpdate 
Description: Update address status
Inputs: List of cscrm__Address__c
------------------------------------------------------------*/
    public void onBeforeInsertUpdate(List<cscrm__Address__c> newList){
        if(!newList.isEmpty()){
            for(cscrm__Address__c address: newList){
                if('CO'.equalsIgnoreCase(address.Address_Status__c) ){
                    address.Address_Status__c = 'CONFIRMED';
                }
                if('UN'.equalsIgnoreCase(address.Address_Status__c)){
                    address.Address_Status__c = 'UNCONFIRMED';
                }
            }
        }
    }
    
    public void publishCreateBillingEvents(List<cscrm__Address__c> newList,String event){
        
        BillingPublishEvents publishIntface=BillingPublishEventsImpl.getInstance();
        publishIntface.addressEventObject(newList,EventConstants.ADDRESS,event);
        publishIntface.createBillingEvent(); 
    } 
    
    /*------------------------------------------------------------ 
EDGE - 39902,
Method: getAddressType 
Description: This method returns addressType value for TCM manage call
Inputs: addressType
Returns: addressType for payload
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    public static String getAddressTypeForTCMManage(String parentId,String numSubaddresses,String subaddressType){
        String addrType = '';
        if(parentId==null && numSubaddresses==null){
            addrType= '';
        }
        else if(parentId!=null && numSubaddresses!=null && Integer.valueOf(numSubaddresses)==0){
            //query TCM EAST AddressType
            addrType = getAddressType(subaddressType);
        }
        else if(parentId==null && numSubaddresses!=null && Integer.valueOf(numSubaddresses)>=1){
            addrType= '';
        }
        else if(parentId!=null && numSubaddresses!=null && Integer.valueOf(numSubaddresses)>=1){
            //query TCM EAST AddressType
            addrType = getAddressType(subaddressType);
        }
        return addrType;
    }
        /*------------------------------------------------------------ 
EDGE - 39902,
Method: getAddressType 
Description: This method returns addressType from TCM_EAST_AddressType__c custom setting
Inputs: addressType
Returns: addressType for payload
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
   
   public static String getAddressType(String addressType){
        String addrType = '';
        TCM_EAST_AddressType__c eastAddress = null;
        if(addressType!=null){
                eastAddress = TCM_EAST_AddressType__c.getInstance(addressType.toUpperCase('en_AU'));
                if(eastAddress!=null)
                {
                    System.debug(eastAddress.addressType__c);
                    addrType =  eastAddress.addressType__c;
                }
            }
        return addrType;
   }
           /*------------------------------------------------------------ 
EDGE - 39902,
Method: getStreetTypeForTCMManage 
Description: This method returns streetType from TCM_EAST_Street_Type__c custom setting
Inputs: streetType
Returns: streetType for payload
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
 
    public static String getStreetTypeForTCMManage(String streetType){
        String street_Type = '';
        TCM_EAST_Street_Type__c eastStreet = null;
        if(streetType!=null){
                eastStreet = TCM_EAST_Street_Type__c.getInstance(streetType.toUpperCase('en_AU'));
                if(eastStreet!=null)
                {
                    System.debug(eastStreet.streetTypeCode__c);
                    street_Type =  eastStreet.streetTypeCode__c;
                }
            }
        return street_Type;
    }
}