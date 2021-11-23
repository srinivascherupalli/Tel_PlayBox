/*************************************************************************************************************************************************************
@ Class             :            CS_TransientMetadataHelper
@ Author            :            Vanita Mude (vanita.mude@infosys.com)
@ Purpose           :            Helper class for GenerateTransientDataHandler  
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history    :            Vanita Mude / Created the class.
@ User Story        :            EDGE-71655
**************************************************************************************************************************************************************/


public with sharing class CS_TransientMetadataHelper {
    
    
    /*********************************************************************************************************************************
* Method Name      :   getOfferListForNonAssetableProducts
*Return            :   Returns Set<String>
**********************************************************************************************************************************/
    public Set<String> getOfferListForNonAssetableProducts(){
        Set<String> offerSpecSet  = new Set<String>();
        try{
            for(Product_Attribute_Metadata__c prodAttrMetadata : [select id, name,Offer_Id__c from Product_Attribute_Metadata__c where Metadata_Type__c = 'isAssetable' and Metadata_Value__c = 'False']){
                if(prodAttrMetadata != null  && prodAttrMetadata.Offer_Id__c != null)
                offerSpecSet.add(prodAttrMetadata.Offer_Id__c);
            }
            System.debug('offerSpecSet===>'+offerSpecSet);
            return offerSpecSet;
        }catch(Exception e){ return offerSpecSet;
            //Handle exception here
           
        }
    }
    
    //Enhance this method when same spec code will be present with different offer ID in the Product_Attribute_Metadata__c in future
    
    /*********************************************************************************************************************************
* Method Name      :   getSpecCodeListForNonAssetableProducts
*Return            :   Returns List<String>
**********************************************************************************************************************************/
    public List<String> getSpecCodeListForNonAssetableProducts(){
        List<String> specCodeList = new List<String>();
        try{
            Set<String> specCodeSet = new Set<String>();
            for(Product_Attribute_Metadata__c prodAttrMetadata : [select id, name,Product_ID__c from Product_Attribute_Metadata__c where Metadata_Type__c = 'isAssetable' and Metadata_Value__c = 'False']){
                specCodeSet.add(prodAttrMetadata.Product_ID__c+'_Fulfilment');
            }
            specCodeList.addAll(specCodeSet);
            
            System.debug('specCodeList===>'+specCodeList);
            return specCodeList;
        }catch(Exception e){return specCodeList;
            //handle exception here
            
        }
    }
    
    /*********************************************************************************************************************************
* Method Name      :   getAttributeReferenceForNonAssetableProducts
*Return            :   Returns List<Product_Attribute_Metadata__c>
**********************************************************************************************************************************/
    public List<Product_Attribute_Metadata__c> getAttributeReferenceForNonAssetableProducts(){
        List<Product_Attribute_Metadata__c> metadataList = new List<Product_Attribute_Metadata__c>();
        try{
            for(Product_Attribute_Metadata__c prodAttrMetadata : [select id, Attribute_Name__c,Offer_Id__c,Change_Type__c,IsReference__c,ReferenceField__c,Static_Value__c,Product_ID__c from Product_Attribute_Metadata__c where Metadata_Type__c = 'isAssetable' and Metadata_Value__c = 'False']){
                metadataList.add(prodAttrMetadata);
            }
            System.debug('attributeMetadataMap===>'+metadataList);
            return metadataList;
        }catch(Exception e){ return metadataList;
            //Handle exception here
           
        }
    }
    
    /*********************************************************************************************************************************
* Method Name      :   getSpecCodeChangeTypeForNonAssetableProducts
*Return            :   Returns Map<String,List<String>>
**********************************************************************************************************************************/
    public Map<String,List<String>> getSpecCodeChangeTypeForNonAssetableProducts(){
        Map<String,List<String>> specCodeChangeTypeMap = new Map<String,List<String>>();
        Set<String> specOfferSet = new Set<String>();
        try{
            List<Product_Attribute_Metadata__c> prodAttrMetadataList = [select id, Change_Type__c,Offer_Id__c,Change_SubType__c,Static_Value__c,Product_ID__c from Product_Attribute_Metadata__c where Metadata_Type__c = 'isAssetable' and Metadata_Value__c = 'False'];
            for(Product_Attribute_Metadata__c prodAttrMetadata : prodAttrMetadataList){
                specOfferSet.add(prodAttrMetadata.Offer_Id__c+'::'+prodAttrMetadata.Product_ID__c);
            }
            for(String key : specOfferSet){
                List<String> changeTypeList = new List<String>();
                for(Product_Attribute_Metadata__c prodAttrMetadata : prodAttrMetadataList){
                    if(prodAttrMetadata.Offer_Id__c == key.split('::')[0] && prodAttrMetadata.Product_ID__c == key.split('::')[1]){                     
                        if(prodAttrMetadata.Change_SubType__c!=null){
                            
                            changeTypeList.add(prodAttrMetadata.Change_SubType__c);    
                        }else{
                            changeTypeList.add(prodAttrMetadata.Change_Type__c);    
                        }
                    }
                    System.debug('changeTypeList==>'+changeTypeList);
                }
                if(changeTypeList.size()>0){
                    specCodeChangeTypeMap.put(key,changeTypeList);
                }
            }
            System.debug('specCodeChangeTypeMap===>'+specCodeChangeTypeMap);
            return specCodeChangeTypeMap;
        }catch(Exception e){ return specCodeChangeTypeMap;
            //Handle exception here
           
        }
    }
    
    /*********************************************************************************************************************************
* Method Name      :   fetchTransientDataFromService
*Return            :   Returns Map<Id,csord__Service__c>
**********************************************************************************************************************************/
    public Map<Id,csord__Service__c> fetchTransientDataFromService(Set<String> serviceIDSet, List<String> fieldAPINameList){
        Map<Id,csord__Service__c> serviceTransientDataMap = new Map<Id,csord__Service__c>();
        System.debug('fieldAPINameList===>'+fieldAPINameList);
        try{
            String fieldAPIStr = '';
            for(String field : fieldAPINameList){
                fieldAPIStr = fieldAPIStr + field + ','; 
            }
            System.debug('fieldAPIStr==>'+fieldAPIStr);
            if(fieldAPIStr!=null && fieldAPIStr.length()>0){
                String queryString = 'SELECT ';
                queryString += 'id, ';
                queryString += fieldAPIStr;

                //EDGE-119900 : query string modified
                queryString += 'csordtelcoa__Service_Number__c,Replaced_Device_Id__c,Scenario_Type__c FROM csord__Service__c WHERE ';
                queryString += 'id in :serviceIDSet';
                
                System.debug('queryString===>'+queryString);
                for(csord__Service__c serv : Database.query(queryString)){
                    serviceTransientDataMap.put(serv.id,serv);
                }
            }
            System.debug('serviceTransientDataMap===>'+serviceTransientDataMap);
            return serviceTransientDataMap;
        }catch(Exception e){ return serviceTransientDataMap;
            //Handle exception here
            
        }
    }
    
    
    /*********************************************************************************************************************************
* Method Name      :   getTransientReferenceAPINameList
*Return            :   Returns List<String> 
**********************************************************************************************************************************/
    public List<String> getTransientReferenceAPINameList(){
        try{
            Set<String> fieldAPINameSet = new Set<String>();
            for(Product_Attribute_Metadata__c prodMetadat : [select id, ReferenceField__c,IsReference__c from Product_Attribute_Metadata__c where Metadata_Type__c = 'isAssetable' and Metadata_Value__c = 'False' and IsReference__c = true]){
                fieldAPINameSet.add(prodMetadat.ReferenceField__c);
            }
            return new List<String>(fieldAPINameSet);
        }catch(Exception e){ return null;
            //handle exception here
           
        }
    }
}