/*----------------------------------------------------------------------
EDGE        -150172
Class       -searchDeviceController
Description -Enable search functionality to search original device id using replaced device id
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/
public with sharing class searchDeviceController {
public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');   
/*----------------------------------------------------------------------
EDGE        -150172
Method      -getSearchedDevice
Description -search Orginal and replacement device by deviceId
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/    
    @AuraEnabled public static List<assetWrapper> getSearchedDevice(String deviceId) {
        List<asset> asset=new List<asset>();
        List<assetWrapper> assetWrapperList=new List<assetWrapper>();
        if(String.isNotBlank(deviceId)){
            asset=[SELECT Id,account.name,accountId,ParentId,csordtelcoa__Replaced_Asset__c,AssetID__c FROM Asset 
                   WHERE AssetID__c =:deviceId LIMIT 1];
            if(!asset.IsEmpty()){
                for(Asset asst:[SELECT id,status,account.name,accountId,ParentId,csordtelcoa__Replaced_Asset__c,
                                AssetID__c,createdDate FROM Asset WHERE ( ParentId != null AND ParentId =:asset[0].ParentId)
                                OR Id=: asset[0].ParentId OR Id=:asset[0].Id OR ParentId =:asset[0].Id ORDER By createdDate Asc]){
                                  assetWrapper wrapper=new assetWrapper();
                                    wrapper.deviceId=asst.AssetID__c;
                                    wrapper.createdDate= asst.createdDate.date().format();
                                    wrapper.accountName=asst.account.name;
                                    wrapper.accountId=asst.accountId;
                                    wrapper.assetId=asst.Id;
                                    if(asst.ParentId==null && asst.csordtelcoa__Replaced_Asset__c==null){
                                        wrapper.type=customMetadataNameValueMap.containsKey('Original')? String.valueOf(customMetadataNameValueMap.get('Original').get('Value__c')):'';
                                        wrapper.isOriginal=true;
                                    }
                                    else {
                                        wrapper.type=customMetadataNameValueMap.containsKey('Replacement')? String.valueOf(customMetadataNameValueMap.get('Replacement').get('Value__c')):'';  
                                    }
                                    assetWrapperList.add(wrapper);
                                    
                                }
            }
        }
        return assetWrapperList; 
    }
/******************************************************************
EDGE        -150172
Method      -checkForPartnerUser 
Description -Check logged in user in partner user or CRM user
Author      -Dheeraj Bhatt
******************************************************************/ 
    @AuraEnabled public static Boolean checkForPartnerUser(){
      return ConstantMetadataUtility.checkForPartnerUser();
        
    }
/*----------------------------------------------------------------------
EDGE        -150172
Class       -assetWrapper
Description -Wrapper Class to store the device Information
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/
    public class assetWrapper{
        @AuraEnabled public String  deviceId;
        @AuraEnabled public String  type;
        @AuraEnabled public String  replacedOn;
        @AuraEnabled public String  createdDate;
        @AuraEnabled public String  accountName;
        @AuraEnabled public String  accountId;
        @AuraEnabled public Boolean isOriginal;
        @AuraEnabled public String  assetId;
        @AuraEnabled public Boolean isReplacementInProgress;
    }
}