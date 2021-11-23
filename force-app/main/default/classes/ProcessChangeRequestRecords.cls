/*
Created BY: Abinash Barik
Created Date: 04/24/2019
Description: EDGE-81696,EDGE-70343 - Sigma-CS interface code refactoring - 
			Modular class structure and generic json parsing logic,
			Sigma-CS interface code refactoring - Update logic for Price Item, 
			Attribute LoV and EDM mappings.
	This class is responsible for create all Attachment(Change Request) records once the SIGMA LAUNCH happen
Class Name: ProcessChangeRequestRecords
=========================================================================
ChagneSet No    Name            Date                    Description

*/
public class ProcessChangeRequestRecords {
    //========================= CREATE CHANGE REQUEST FOR FULFILMENT SPECIFICATIONS =================
    // Below method is return the map of attachment record, Key will be ChangeRequest
    // and value will list of Attachment for Fullfilment Specification
    public static Map<String, List<sobject>> createFullfilmentChangerequest(
                                        Map<String, List<sobject>> mapsObjectrec, 
                                        csedm__Specification__c Spec,
                                        List<SigmaJSONParseInterface.Attributes>  attList, 
                                        SigmaJSONParseInterface.Products product,
                                        List<SigmaJSONParseInterface.MappingRules> MappingRule,
                                        String ParentSpecId,String recordType,boolean isFulfillmentcreate){
        try{
            String autoAddTrueJSON = '';
            String autoAddfalseJSON = '';
            boolean checkSuccess = false;
            boolean checkfalse = false;
            Integer staticAttrCounter = 0;
            Integer commercialAttrCounter = 0;
            autoAddTrueJSON = '{ "code" : "'+ Spec.csedm__Code__c + '","externalId" : "'+ Spec.External_Id__c + '", "attributes" : [  ' ;
            autoAddfalseJSON= autoAddTrueJSON;
                    
            for(SigmaJSONParseInterface.Attributes att : attList){    
                if(isFulfillmentcreate){
                    if(att.default_x != null && att.default_x != ''){
                        
                        autoAddTrueJSON +=  '{"name" : "'+ att.interfaceName + '", "value" : "'+att.default_x+'" , "type" : "' + 'String' + '",  "description": "' + '"' + '},'; 
                        
                        checkSuccess = true;
                        staticAttrCounter++;
                        
                    }else {
                        if(checkfalse){
                            autoAddfalseJSON +=',';
                        }
                        String failJsonStr = '{"name" : "'+ att.interfaceName + '", "value" : "" , "type" : "' + 'String' + '",  "description": "' + '"' + '}';
                        autoAddfalseJSON += failJsonStr;                            
                        checkfalse = true; 
                        checkSuccess = true;
                        commercialAttrCounter++;                           
                    } 
                }
            }
            if(MappingRule != null){
                for(SigmaJSONParseInterface.MappingRules mrules: MappingRule){
                    if(product.specid == mrules.target.productId){
                        autoAddTrueJSON +=  '{"name" : "'+ mrules.source.characteristicId + '", "value" : "'+mrules.source.productId+'" , "type" : "' + 'String' + '",  "description": "' + '"' + '},';
                    }
                }
            }
            if(ParentSpecId != product.specId){
                for(SigmaJSONParseInterface.ProductStaticCharacteristics prodchar : product.productStaticCharacteristics)
                {
                    if(prodchar.name == 'TechPhases' && prodchar.value == 'true')
                    {
                        staticAttrCounter++;
                        ParentSpecId = '{"name" : "parentSpec" , "value" : "' + ParentSpecId.removeEnd(',')+'_Fulfilment';
                        ParentSpecId+= '","type": "string"}';
                    }
                }                                
            }
            if(parentSpecID == ''){
                autoAddTrueJSON = autoAddTrueJSON.removeEnd(',');
            }
            autoAddTrueJSON += parentSpecID;
            
            autoAddTrueJSON += '], "autoAdd": "true" }';
            autoAddfalseJSON += '], "autoAdd": "false" }';
            
            System.debug('autoAddTrueJSON ====>'+autoAddTrueJSON);
            System.debug('autoAddfalseJSON ====>'+autoAddfalseJSON);
            
            if(staticAttrCounter > 0){
                Attachment attachment1 = new Attachment();
                attachment1.Body = Blob.valueOf(autoAddTrueJSON);
                attachment1.Name = Spec.External_Id__c;//'Change Request '+ date.today().format()+'.json';
                mapsObjectrec = ProcessSpecificationRecords.addSpecificationToMap(mapsObjectrec,attachment1,recordType);
            }
            if(CommercialAttrCounter > 0){
                Attachment attachment2 = new Attachment();
                attachment2.Body = Blob.valueOf(autoAddfalseJSON);
                attachment2.Name = Spec.External_Id__c;//'Change Request '+ date.today().format()+'.json';
                mapsObjectrec = ProcessSpecificationRecords.addSpecificationToMap(mapsObjectrec,attachment2,recordType);
            } 
            
        }
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }                                    
        
        return mapsObjectrec;
    }
    
    //===================== CREATE CHANGE REQUEST FOR ASSURANCE SPECIFICATIONS ===================
    // Below method is return the map of attachment record, Key will be ChangeRequest
    // and value will list of Attachment for Assurance Specification
   
    public static Map<String, List<sobject>> createAssuranceAttributesChangerequest(
                                        Map<String, List<sobject>> mapsObjectrec, 
                                        List<SigmaJSONParseInterface.Attributes>  attList, 
                                        SigmaJSONParseInterface.Products product,
                                        List<SigmaJSONParseInterface.MappingRules> MappingRule,
                                        String ParentSpecId,String recordType,boolean isFulfillmentcreate){
        try{
            String autoAddTrueJSON = '';
            String autoAddfalseJSON = '';
            boolean checkSuccess = false;
            boolean checkfalse = false;
            Integer staticAttrCounter = 0;
            Integer commercialAttrCounter = 0;
            for(SigmaJSONParseInterface.Attributes att : attList){    
                if(isFulfillmentcreate){
                    if(att.default_x != null && att.default_x != ''){
                        
                        autoAddTrueJSON +=  '{ "externalId" : "'+ parentSpecId+product.specId + '","code" : "'+ product.specId+'_Assurance' + '", "attributes" : [  ' ;
                        autoAddfalseJSON= autoAddTrueJSON;
                        
                    }else {
                        if(checkfalse){
                            autoAddfalseJSON +=',';
                        }
                        String failJsonStr = '{"name" : "'+ att.interfaceName + '", "value" : "" , "type" : "' + 'String' + '",  "description": "' + '"' + '}';
                        autoAddfalseJSON += failJsonStr;                            
                        checkfalse = true; 
                        checkSuccess = true;
                        commercialAttrCounter++;                           
                    } 
                }
            }
            if(MappingRule != null){
                for(SigmaJSONParseInterface.MappingRules mrules: MappingRule){
                    if(product.specid == mrules.target.productId){
                        autoAddTrueJSON +=  '{"name" : "'+ mrules.source.characteristicId + '", "value" : "'+mrules.source.productId+'" , "type" : "' + 'String' + '",  "description": "' + '"' + '},';
                    }
                }
            }
            if(ParentSpecId != product.specId){
                for(SigmaJSONParseInterface.ProductStaticCharacteristics prodchar : product.productStaticCharacteristics)
                {
                    if(prodchar.name == 'AssurancePhase' && prodchar.value == 'true')
                    {
                        staticAttrCounter++;
                        ParentSpecId = '{"name" : "parentSpec" , "value" : "' + ParentSpecId.removeEnd(',')+'_Assurance';
                        ParentSpecId+= '","type": "string"}';
                    }
                }                                
            }
            if(parentSpecID == ''){
                autoAddTrueJSON = autoAddTrueJSON.removeEnd(',');
            }
            autoAddTrueJSON += parentSpecID;
            
            autoAddTrueJSON += '], "autoAdd": "true" }';
            autoAddfalseJSON += '], "autoAdd": "false" }';
            
            System.debug('autoAddTrueJSON ====>'+autoAddTrueJSON);
            System.debug('autoAddfalseJSON ====>'+autoAddfalseJSON);
            
            if(staticAttrCounter > 0){
                Attachment attachment1 = new Attachment();
                attachment1.Body = Blob.valueOf(autoAddTrueJSON);
                attachment1.Name = ParentSpecId+product.specId;//'Change Request '+ date.today().format()+'.json';
                // Below method will add record into final map and return the updated map
                mapsObjectrec = ProcessSpecificationRecords.addSpecificationToMap(mapsObjectrec,attachment1,recordType);
            }
            if(CommercialAttrCounter > 0){
                Attachment attachment2 = new Attachment();
                attachment2.Body = Blob.valueOf(autoAddfalseJSON);
                attachment2.Name = ParentSpecId+product.specId;//'Change Request '+ date.today().format()+'.json';
                mapsObjectrec = ProcessSpecificationRecords.addSpecificationToMap(mapsObjectrec,attachment2,recordType);
            } 
            
        }
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }                                    
        
        return mapsObjectrec;
    }
    
    //================= CREATE CHANGE REQUEST FOR BILLING ATTRIBUTES SPECIFICATIONS ===============
    // Below method is return the map of attachment record, Key will be ChangeRequest
    // and value will list of Attachment for Billing Specification
   
    public static Map<String, List<sobject>> createBillingChargeAttributesChangerequest(
                                        Map<String, List<sobject>> mapsObjectrec, 
                                        csedm__Specification__c Spec,
                                        SigmaJSONParseInterface.Charges  chrgs, 
                                        SigmaJSONParseInterface.Products product,
                                        String ParentSpecId,String recordType){
        try{
            String autoAddfalseBillingJSON = '';
            Integer staticAttrCounter = 0;
            Integer commercialAttrCounter = 0; 
            String EXTERNALID = 'EXTERNALID'; 
                autoAddfalseBillingJSON= '{ "code" : "'+ product.specId+'_Billing_'+chrgs.specId.replace('DMCAT_','') + '","externalId" : "'+ EXTERNALID + '", "attributes" : [  ' ;
                
                if(String.isNotBlank(chrgs.type_x)){                                
                    autoAddfalseBillingJSON += '{"name": "type", "value": "","type": "string"},';
                } 
                if(String.isNotBlank(chrgs.currency_x)){
                    autoAddfalseBillingJSON +='{"name": "currency", "value": "","type": "string"},';
                }
                if( String.isNotBlank(chrgs.frequency_x)){
                    autoAddfalseBillingJSON +='{"name": "frequency", "value": "","type": "string"},';
                }
                if( String.isNotBlank(chrgs.billingSpecId))
                {
                    autoAddfalseBillingJSON +='{"name": "billingSpecId", "value": "","type": "string"},';
                }
                if(String.isNotBlank(chrgs.billInAdvance) ){
                    autoAddfalseBillingJSON +='{"name": "billInAdvance", "value": "","type": "string"},';
                }
                if(String.isNotBlank(chrgs.prorate) ){
                    autoAddfalseBillingJSON +='{"name": "prorate", "value": "","type": "string"},';
                }
                if( String.isNotBlank(chrgs.billingSubtype))
                {
                    autoAddfalseBillingJSON +='{"name": "billingSubtype", "value": "","type": "string"},';
                }
                
                //autoAddfalseBillingJSON +='{"name": "description", "value": "","type": "string"},{"name": "units", "value": "","type": "string"},{"name": "unitPrice", "value": "","type": "string"}';
                commercialAttrCounter++;  
                
                //Changes Start for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                autoAddfalseBillingJSON +='{"name": "billDescription", "value": "","type": "string"},{"name": "rateExcludeGST", "value": "","type": "string"}';
                if(product.attributes != null)
                {
                    for(SigmaJSONParseInterface.Attributes att : product.attributes)
                    {
                        if(String.isNotBlank(att.interfaceName))
                        {        
                            autoAddFalseBillingJSON += ',{"name": "'+ att.interfaceName + '", "value": "","type": "string"}';
                        } 
                    }
                    System.debug('autoAddFalseBillingJSON with new attributes ====>'+autoAddFalseBillingJSON);
                }
                //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
            autoAddfalseBillingJSON += '], "autoAdd": "false" }';               

            System.debug('autoAddfalseBillingJSON ====>'+autoAddfalseBillingJSON);  
            if(CommercialAttrCounter > 0){
                Attachment attachment1 = new Attachment();
                attachment1.Body = Blob.valueOf(autoAddfalseBillingJSON);
                attachment1.Name = Spec.External_Id__c;//'Change Request '+ date.today().format()+'.json';
                mapsObjectrec = ProcessSpecificationRecords.addSpecificationToMap(mapsObjectrec,attachment1,recordType);
            }               
            
        }
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }                                    
        
        return mapsObjectrec;
    }
    
    
    public static String createBillingChargeAttributesChangerequest(){
        String autoAddfalseBillingJSON = '';
        try{
            
            String PRODUCTSPECID = 'PRODUCTSPECID';
            String CHARGSPECID = 'CHARGSPECID';
            String EXTERNALID = 'EXTERNALID';           
            
                autoAddfalseBillingJSON= '{ "externalId" : "'+ EXTERNALID + '","code" : "'+ PRODUCTSPECID +'_Billing_'+ CHARGSPECID + '", "attributes" : [  ' ;
                
                //if(String.isNotBlank(chrgs.type_x)){                                
                    autoAddfalseBillingJSON += '{"name": "type", "value": "","type": "string"},';
                //} 
                //if(String.isNotBlank(chrgs.currency_x)){
                    autoAddfalseBillingJSON +='{"name": "currency", "value": "","type": "string"},';
                //}
                //if( String.isNotBlank(chrgs.frequency_x)){
                    autoAddfalseBillingJSON +='{"name": "frequency", "value": "","type": "string"},';
                //}
                //if( String.isNotBlank(chrgs.billingSpecId))
                //{
                    autoAddfalseBillingJSON +='{"name": "billingSpecId", "value": "","type": "string"},';
                //}
                //if(String.isNotBlank(chrgs.billInAdvance) ){
                    autoAddfalseBillingJSON +='{"name": "billInAdvance", "value": "","type": "string"},';
                //}
                //if(String.isNotBlank(chrgs.prorate) ){
                    autoAddfalseBillingJSON +='{"name": "prorate", "value": "","type": "string"},';
                //}
                //if( String.isNotBlank(chrgs.billingSubtype))
                //{
                    autoAddfalseBillingJSON +='{"name": "billingSubtype", "value": "","type": "string"},';
                //}
                
                
                //Changes Start for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                autoAddfalseBillingJSON +='{"name": "billDescription", "value": "","type": "string"},{"name": "rateExcludeGST", "value": "","type": "string"}';
                //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
            autoAddfalseBillingJSON += '], "autoAdd": "false" }';               

            System.debug('autoAddfalseBillingJSON ====>'+autoAddfalseBillingJSON);  
        }
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }                                    
        
        return autoAddfalseBillingJSON;
    }
}