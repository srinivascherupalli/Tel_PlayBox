/*
Created BY: Abinash Barik
Created Date: 04/24/2019
Description: EDGE-81696,EDGE-70343 - Sigma-CS interface code refactoring - 
            Modular class structure and generic json parsing logic,
            Sigma-CS interface code refactoring - Update logic for Price Item, 
            Attribute LoV and EDM mappings.
            This class is responsible for prepare data and return as string or object
Class Name: ProcessSpecificationRecords
=========================================================================
ChangeSet   No    Name            Date                    Description
EDGE-82599  1     Vijayalakshmi  30-May-2019            Changes  to populate Product Attribute Metadata 
                                                        when TechPhases is True and IsAssetable is True.
*/
public class ProcessSpecificationRecords {
    // This method is responsible for adding all records with map, return the map
    public static Map<String, List<sobject>> addSpecificationToMap(Map<String, List<sobject>> mapsObjectrec, 
                                                                sobject prodSpec, String recordType){
        if(mapsObjectrec.containsKey(recordType)){
            mapsObjectrec.get(recordType).add(prodSpec);
        }else{
            mapsObjectrec.put(recordType, new List<sobject>{prodSpec});
        }       
        return mapsObjectrec;
    }
    // This method is responsible for prepare the data for Specification record and return as object
    public static csedm__Specification__c createSpecification(SigmaJSONParseInterface.Products product, 
                                                                csedm__Specification__c prodSpec){
        prodSpec.csedm__Active__c = true;
        prodSpec.csedm__Start_Date__c = Date.valueOf(product.associationStartDate);
        prodSpec.csedm__End_Date__c = Date.valueOf(product.associationEndDate);
        prodSpec.csedm__Version__c = product.version;
        return prodSpec;
    }
   // This method is responsible for prepare the json data and return the same
    public static String generatechargeJSON(){
        String ValueJson = '';
        String CODE = 'CODE';
        String SPECNAME = 'SPECNAME';
                            
        String Json1 = '{ "code": "' + CODE + '", "name": "' + SPECNAME + '", "description": "",  "cpqAttributes": {}, "attributes": {   ';
        String json2 = '';
        json2+='"__targetSystem": {"value": "'+Label.targetSystem+'","type": "string"}';
        
        string json3 = '}, "nonCommercialAttributes": []}';
        
        ValueJson = Json1 + json2 + json3;
        
        if(ValueJson!=''){
            ValueJson = ValueJson;
        }else{
            ValueJson = '{}';
        }                                                            
        return ValueJson;
    }
    // This method is responsible for prepare the json data and return the same
    public static String generateFulfilmentJSON(csedm__Specification__c prodSpec, List< SigmaJSONParseInterface.Attributes> attList, SigmaJSONParseInterface.Products product, 
    String offername, String offerspecId, List<Product_Attribute_Metadata__c> PrdtAttrMetadatalst){
        String ValueJson = '';
        String CODE = 'CODE';
        String NAME = 'NAME';
        String EXTERNALID = 'EXTERNALID';
                            
        String Json1 = '{ "code": "' + CODE + '", "name": "' + NAME+ '", "description": "",  "cpqAttributes": {}, "attributes": {   ';
        String json2 = '';
        if (attList!=null && attList.size() == 1) {
            for (SigmaJSONParseInterface.Attributes att: attList) 
            {
                if(att.default_x!='' && att.default_x!=null)
                {
                    json2 += '"' + att.interfaceName + '": {     "value": "' + att.default_x + '",     "type": "' + att.type_x + '"   }';
                }
            }
        } else if (attList!=null && attList.size() > 1) {
            for (integer i = 0; i < attList.size() - 1; i++) {
                if(attList[i].default_x!='' && attList[i].default_x!=null){
                    json2 += '"' + attList[i].interfaceName + '": {     "value": "' + attList[i].default_x + '",     "type": "' + attList[i].type_x + '"   },';
                }
            }
            if(attList[attList.size() - 1].default_x!='' && attList[attList.size() - 1].default_x!=null){
                json2 += '"' + attList[attList.size() - 1].interfaceName + '": {     "value": "' + attList[attList.size() - 1].default_x + '",     "type": "' + attList[attList.size() - 1].type_x + '"   },';
                
            }
        }
        json2+='"__targetSystem": {"value": "FULFILMENT","type": "string"}';
        string json3 = '}, "nonCommercialAttributes": []}';
        
        ValueJson = Json1 + json2 + json3;
        
        if(ValueJson!=''){
            ValueJson = ValueJson;
        }else{
            ValueJson = '{}';
        }
        //changes start for 82599 to populate Product Attribute Metadata when 
        //TechPhases is True and IsAssetable is True.
        if (attList!=null && attList.size() >= 1)
        {
            for (SigmaJSONParseInterface.Attributes attr: attList) 
            {
                boolean TechPhasesFlg = false;
                boolean prdtAttrMetadataFlg = false;
                Product_Attribute_Metadata__c locPrdtAttrMetadata = new Product_Attribute_Metadata__c();
                String interfaceName = '';
                for (SigmaJSONParseInterface.ProductStaticCharacteristics attrStaticChars : attr.staticCharacteristics)
                {
                    if(attrStaticChars.name == 'TechPhases' && attrStaticChars.value == 'true' && TechPhasesFlg != true)
                    {
                        TechPhasesFlg = true;
                        //break;
                    }
                    
                    if(attrStaticChars.name == 'IsAssetable' && attrStaticChars.value == 'false')
                        {
                            //add attribute to Product Attribute Metadata
                            prdtAttrMetadataFlg = true;
                            locPrdtAttrMetadata.Offer_Name__c = offername;
                            locPrdtAttrMetadata.Offer_Id__c = offerspecId;
                            locPrdtAttrMetadata.Product_Name__c = product.name; 
                            locPrdtAttrMetadata.Product_ID__c = product.specId;
                            locPrdtAttrMetadata.Identifier__c = product.specId + '_' + attr.interfaceName;
                            locPrdtAttrMetadata.Attribute_Name__c = attr.interfaceName;
                            locPrdtAttrMetadata.Name = attr.interfaceName;
                            interfaceName = attr.interfaceName;
                            locPrdtAttrMetadata.Metadata_Type__c = 'isAssetable';
                            locPrdtAttrMetadata.Metadata_Value__c = 'False';
                            //PrdtAttrMetadatalst.add(locPrdtAttrMetadata);
                            //break;
                        }
                }
                if(TechPhasesFlg && prdtAttrMetadataFlg){
                    PrdtAttrMetadatalst.add(locPrdtAttrMetadata);
                }
            }
        }
        //changes end for 82599
        return ValueJson;
    }
    // This method is responsible for prepare the json data and return the same
    public static String generateAllowanceJSON(){
        String ValueJson = '';
        
        String CODE = 'CODE';
        String SPECNAME = 'SPECNAME';
        String BILLINGSPECID = 'BILLINGSPECID';
        String OCRPRODID = 'OCRPRODID';
        String TYPEX = 'TYPEX';
        String UNITOFMEASURE = 'UNITOFMEASURE';
        String VALUE = 'VALUE';
        String EXTERNALID = 'EXTERNALID';
                                    
        String Json1 = '{ "code": "' + CODE + '", "name": "' + SPECNAME + '", "description": "",  "cpqAttributes": {}, "attributes": {   ';
        String json2 = '';
        json2+='"__targetSystem": {"value": "'+Label.targetSystem+'","type": "string"},';
        json2+='"billingSpecId": {"value": "'+BILLINGSPECID+'","type": "string"},';
        json2+='"ocsProdID": {"value": "'+OCRPRODID+'","type": "string"},';
        json2+='"type": {"value": "'+TYPEX+'","type": "string"},';
        json2+='"unitofMeasure": {"value": "'+UNITOFMEASURE+'","type": "string"},';
        json2+='"value": {"value": "'+VALUE+'","type": "string"}';
        
        string json3 = '}, "nonCommercialAttributes": []}';
        
        ValueJson = Json1 + json2 + json3;
        
        if(ValueJson!=''){
            ValueJson = ValueJson;
        }else{
            ValueJson = '{}';
        }                                                        
        return ValueJson;
    }
    
    
}