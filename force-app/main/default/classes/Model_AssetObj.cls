/****************************************************************************************************************************************************
Main Class : Model_AssetObj
Test Class : Model_AssetObjTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story          Sprint               Description
1.        Ankit Goswami      03/07/2020      EDGE-148733    20.09(New Class)     To collate all the queries related to Asset Object
=====================================================================================================================================================
******************************************************************************************************************************************************/
public with sharing class Model_AssetObj{
    
    public static list<Asset>getAssetId(Set<String> configIds){
        list<Asset>AssetList=new list<Asset>();
         if (configIds != null && configIds.size()>0 ) {
            AssetList= [select id,AssetID__c,csord__Service__r.csordtelcoa__Product_Configuration__c from Asset where csord__Service__r.csordtelcoa__Product_Configuration__c In : configIds];
        }       
        return AssetList;
    }
    //DIGI-27111 starts
    public static list<Asset>fetchAssetfromService(Set<Id> serviceIds)
    {
        list<Asset> AssetList1 = new list<Asset>();
        if (serviceIds != null && serviceIds.size()>0 ) {
               AssetList1= [Select id,AssetID__c,csord__Service__c,Subscription__c,Subscription__r.Logistics_Order_Number__c from Asset where csord__Service__r.id In : serviceIds and AssetID__c=null];
        }
        system.debug('AssetList1--->' +AssetList1);
        return AssetList1;
   }   //DIGI-27111 ends
}