/* 
Author : Abinash Barik 
Company : Telstra
Description : EDGE-126425 Reverse Logistics
History : Initail Version 09/25/2019

===============================================
ChagneSet No    Name            Date                    Description
*/
public class ServiceTriggerCustomHandler {
    Public Static void filterAllvalidrecords(Map<Id,csord__Service__c> oldMap, List<csord__Service__c> lstservice){
       // Set<Id> serviceIds = new Set<Id>();
        if(!System.isBatch() && !System.isFuture()){
            Set<Id> setOrderIds = new Set<Id>();
            for(csord__Service__c service: lstservice){
                if(oldMap.get(service.id).csord__Status__c != 'Connected' && service.csord__Status__c == 'Connected'){
                    setOrderIds.add(service.csord__Order__c);
                }
            }
            System.debug('setOrderIds>>>>'+setOrderIds);
            if(!setOrderIds.isEmpty()){
                ServiceTriggerCustomHelper.updaterelatedrecords(setOrderIds);
            }
        }
    }
    //DIGI-27111 starts
    public Static void  updateAssetIdforNonSerialized(Map<Id,csord__Service__c> oldMap, List<csord__Service__c> newServiceList)
     {
           Set<Id> setServiceIds = new Set<Id>(); //to store service id 
           List<String> specCode = new List<String>(); //to store spec code fetched from AssetEligibleProductCodes__mdt
           List<Asset> listToBeUpdated = new List<Asset>();//to store updated list
           List<Asset> assetList1 = new List<Asset>();//to store list after condition check
           //List<AssetEligibleProductCodes__mdt> List3= AssetEligibleProductCodes__mdt.getAll().values();
           for(AssetEligibleProductCodes__mdt list1 : [Select label,DeveloperName from AssetEligibleProductCodes__mdt] ){
                 specCode.add(list1.DeveloperName);
             }
         system.debug('specCode--------->' +specCode);
           for(csord__Service__c service: newServiceList)
           {
               system.debug('service--------->' +service);
              if(oldMap.get(service.id).csord__Status__c != 'Connected' && service.csord__Status__c == 'Connected' && String.isBlank(service.csordtelcoa__Replaced_Service__c) && specCode.contains(service.ProductSpecCode__c) || Test.isRunningTest()) //&& specCode.contains(service.ProductSpecCode__c)
              {
                 setServiceIds.add(service.id);
              }
           }
         system.debug('setServiceIds--->' +setServiceIds);
         if(!setServiceIds.isEmpty()){
           assetList1 = Model_AssetObj.fetchAssetfromService(setServiceIds);
             system.debug('assetList1 --------->' +assetList1);
         
           for(Asset assetList2 : AssetList1){
               system.debug('assetList2--------->' +assetList2);
             if(assetList2.AssetID__c == null && !String.isblank(assetList2.Subscription__r.Logistics_Order_Number__c))
             {
                 system.debug('assetList2.AssetID__c--------->' +assetList2.AssetID__c);
                 system.debug('assetList2.Subscription__r.Logistics_Order_Number__c--------->' +assetList2.Subscription__r.Logistics_Order_Number__c);
                assetList2.AssetID__c = assetList2.Subscription__r.Logistics_Order_Number__c;
                listToBeUpdated.add(assetList2);
             }  
           }
             if(!listToBeUpdated.isEmpty()){
          update listToBeUpdated;
             }    
         }
         system.debug('listToBeUpdated--------->' +listToBeUpdated);
     }
    //DIGI-27111 ends
}