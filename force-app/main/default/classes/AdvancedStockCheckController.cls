/*************************************************************************************************
EDGE : EDGE-143860
Name:AdvancedStockCheckController 
Description: Controller for AdvacedStockCheck 
Author:Pradeep Bhumi
Modified: Shresth Dixit(DPG-3510)
***************************************************************************************************/


public with sharing  class AdvancedStockCheckController {
    
    
    /**********************************
EDGE-143860
Description: Method to retrive search results of Lookup Field for AdvacedStockCheck Lightning component
Author: Pradeep
Modified: Shresth Dixit(DPG-3510 : Added parameter filter to the method, Implemented condition to enforce filter on SOQL query)
***********************************/
    @AuraEnabled
    public static List <sObject> fetchLookUpStockCheck(String searchKeyWord, String ObjectName,String identifier,Map<String,Object> resultSearchMap,String filter) 
    {
        
        List<String> productName=new List<String>();
        String searchKey = searchKeyWord + '%';      
        List <sObject> returnList = new List < sObject > ();
        String[] fieldNameList     = identifier.split('\\.');
        String fieldName          =    fieldNameList[1];
        List<StockProductSpecID__mdt> prodSpec=[SELECT MasterLabel from StockProductSpecID__mdt];
        String resultType=String.valueOf(resultSearchMap.get('Type__c'));
        String resultManufacturer=String.valueOf(resultSearchMap.get('Manufacturer__c'));
        String resultModel=String.valueOf(resultSearchMap.get('Model__c'));
        
        for(StockProductSpecID__mdt stMdt:prodSpec){
            productName.add(stMdt.MasterLabel);
        }
        
        //Added  ProdSpecId__c to get the Product specs and pass pass the value to getMetaProdVal for  
        String sQuery = 'SELECT '+fieldName+ ' FROM ' +ObjectName + ' WHERE ProdSpecId__c IN  : productName AND Check_todays_date__c = true';
        String sQueryGroup =   ' AND '+fieldName+' LIKE: searchKey GROUP BY '+fieldName ;
        system.debug('sQuery'+sQuery);
        system.debug('sQueryGroup'+sQueryGroup);
		//DPG-3510 Start
        if(String.isNotBlank(filter)){
            sQuery +=  ' '+filter;
        }
        //DPG-3510 End
        if (identifier == 'cspmb__Price_Item__c.Type__c'){
            sQuery +=  sQueryGroup;        }
        
        else if (identifier == 'cspmb__Price_Item__c.Manufacturer__c'){
            sQuery +=  ' AND Type__c=: resultType'; 
            sQuery +=  sQueryGroup;        }
        
        else if (identifier == 'cspmb__Price_Item__c.Model__c'){
            if (String.IsNotBlank(resultManufacturer)){
                sQuery +=  ' AND Type__c=: resultType AND Manufacturer__c =: resultManufacturer '; 
            }
            else{
                sQuery +=  ' AND Type__c=: resultType ';
            }
            sQuery +=  sQueryGroup;         }
        
        else if (identifier == 'cspmb__Price_Item__c.Colour__c'){
            if (String.IsNotBlank(resultManufacturer)){
                sQuery +=  ' AND Type__c=: resultType AND Manufacturer__c =: resultManufacturer AND Model__c =: resultModel'; 
            }
            else{
                sQuery +=  ' AND Type__c=: resultType AND Model__c =: resultModel'; 
                
            }
            sQuery +=  sQueryGroup;         }
        
        returnList = Database.query(sQuery) ;
        system.debug('returnList'+returnList);
        return  returnList;
        
    }  

    /**********************************
EDGE-155450
Description: Stock Check_Greying Out Manufacture and Colour fields for accessories 
This metchod fetched Color ,Model,Type and Manufacture from Custom metadata
Author: Zeeshan
Modified: Manjunath EDIGA - EDGE-174905
***********************************/
    @AuraEnabled
    public static List <StockProductSpecID__mdt> getMetaProdVal( String deviceType) 
    {   //Start of EDGE-174905 - Changes made to address Duplicate values for Device Type,Manufacturer
        List<StockProductSpecID__mdt> prodSpecFromMetadata = new List<StockProductSpecID__mdt>();
        //Map of ProductSpec from Metadata
        Map<String, StockProductSpecID__mdt> prodSpecMap = new Map<String, StockProductSpecID__mdt>();
        for(StockProductSpecID__mdt prodSpec :[SELECT MasterLabel,Colour__c,Manufacturer__c,Model__c,Type__c from StockProductSpecID__mdt] ){
            prodSpecMap.put(prodSpec.MasterLabel,prodSpec);
        }system.debug('prodSpecMap'+prodSpecMap);
        //Retrive ProductSpec from cspmb__Price_Item__c using DeviceType selected and productSpecs configured in MetaData 
        List<cspmb__Price_Item__c> DeviceTypeprodSpec= [SELECT ProdSpecId__c,Type__c FROM cspmb__Price_Item__c WHERE Type__c=: deviceType AND ProdSpecId__c IN : prodSpecMap.keyset() AND Check_todays_date__c = true];
        system.debug('DeviceTypeprodSpec'+DeviceTypeprodSpec);
        StockProductSpecID__mdt prodSpecFromDeviceType = prodSpecMap.get(DeviceTypeprodSpec[0].ProdSpecId__c);
        system.debug('prodSpecFromDeviceType'+prodSpecFromDeviceType);
      prodSpecFromMetadata.add(prodSpecFromDeviceType);
        //End of EDGE-174905 
    return prodSpecFromMetadata;
    }    
    /**********************************
EDGE-143860
Description: Method to  get stock details for selected devices
Author: Pradeep
***********************************/
    
    @AuraEnabled
    public static List<stockCheckController.DeviceModelWrapper> setProductDetails(Map<String,Object> resultLookUpMap)
    {         
        List<stockCheckController.DeviceModelWrapper> wrapperList = new List<stockCheckController.DeviceModelWrapper>();
        List<stockCheckController.DeviceModelWrapper> wrapperResult = new List<stockCheckController.DeviceModelWrapper>();
        stockCheckController.DeviceModelWrapper wrapper=null;
        Map<String,stockCheckController.DeviceModelWrapper> mapResult=new  Map<String,stockCheckController.DeviceModelWrapper>();  
        List<String> skuList=new List<String> ();
        List<cspmb__Price_Item__c> modelset = new List<cspmb__Price_Item__c>();
        String resultType=String.valueOf(resultLookUpMap.get('Type__c'));
        String resultManufacturer=String.valueOf(resultLookUpMap.get('Manufacturer__c'));
        String resultModel=String.valueOf(resultLookUpMap.get('Model__c'));
        String resultColour=String.valueOf(resultLookUpMap.get('Colour__c'));
        
        String sQuery= 'SELECT Name,Type__c,Model__c,Manufacturer__c,Colour__c ,SKU__c from cspmb__Price_Item__c WHERE Type__c=:resultType AND Check_todays_date__c = true';
        
        if(resultManufacturer !=null)               {
            sQuery += ' AND Manufacturer__c=:resultManufacturer';
        }
        if (resultModel !=null)      {
            sQuery += ' AND Model__c=:resultModel';  
        }
        if (resultColour !=null)        {
            sQuery += ' AND Colour__c=:resultColour';
        }
        //sQuery += ' LIMIT 10';
        modelset = Database.query(sQuery) ;
        
        for(cspmb__Price_Item__c detail: modelset){
            wrapper=new stockCheckController.DeviceModelWrapper();
            wrapper.deviceType = detail.Type__c !=null ? detail.Type__c : null;
            wrapper.model = detail.Model__c !=null ? detail.Model__c : null;
            wrapper.manufacturer = detail.Manufacturer__c !=null ? detail.Manufacturer__c : null;
            wrapper.colour = detail.Colour__c !=null ? detail.Colour__c : null;
            wrapper.skuId = detail.SKU__c;
            mapResult.put(detail.SKU__c,wrapper); 
             }
           
        for (String result:mapResult.keySet())
           {
           wrapperList.add(mapResult.get(result));
           }
           system.debug('wrapperList in method'+wrapperList);
       return wrapperList;
    }
   /**********************************
EDGE-143860
Description: Method to invoke API call and get stock details for selected devices for each page
Author: Pradeep
***********************************/
     @AuraEnabled
    public static List<stockCheckController.DeviceModelWrapper> checkAdvStockQuantity(List<String> skuidList,List<stockCheckController.DeviceModelWrapper> displayWrapper)
    { 
   Set<String> myset = new Set<String>();
   List<String> resultList = new List<String>();
   myset.addAll(skuidList);

   for(String stock : myset){
   if(stock!=null) {
   resultList.add(stock);
}
   }
  
  List<stockCheckController.DeviceModelWrapper> results= stockCheckController.checkStockQuantity(resultList,displayWrapper);
  return results;
}

   /**********************************
EDGE-148587
Description: Method to get logged in User's profile
Author: Manjunath Ediga
***********************************/

    @AuraEnabled
    public static Boolean getUserInfo(){
      try{
            Boolean isPartner = false;
            List<Profile_Setting__mdt> partnerProfiles = [SELECT MasterLabel,Category__c FROM Profile_Setting__mdt WHERE Category__c = 'Partners'];
            string profileId = UserInfo.getProfileId();
            profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
            if(partnerProfiles != null){
                for(Profile_Setting__mdt partnerName : partnerProfiles){
                   if(partnerName.MasterLabel.equals(profile.Name)){
                       isPartner = true;
                   }
                }
            }
            return isPartner;
      }catch(Exception e){
         throw new AuraHandledException(e.getMessage()); 
      }
    }
}