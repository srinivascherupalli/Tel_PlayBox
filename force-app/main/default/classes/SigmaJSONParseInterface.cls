/*
Created BY: Abinash Barik
Created Date: prodspectoId

Description: EDGE-81696,EDGE-70343 - Sigma-CS interface code refactoring - 
            Modular class structure and generic json parsing logic,
            Sigma-CS interface code refactoring - Update logic for Price Item, 
            Attribute LoV and EDM mappings.
            Sigma to CS Adaptor Class and process the JSON

Class Name: SigmaJSONParseInterface
============================================================================
ChagneSet   No    Name            Date                    Description
EDGE-81060  1     Laxmi Rahate  30-May-2019               The changes done in this story are related to Parsing. Chaning the way Specs 
                                                          are created for Alowance. And Changing the External ID in case of Incident management
                                                          Custom MetaData is created to hold such IDs where Grand Parent ID needs to be merged
EDGE-82599  2     Vijayalakshmi 30-May-2019               Change in the naming pattern of allowance specification
EDGE-89988  3     Vijayalakshmi 17-Jun-2019               Enhancement to Allowance Data Modeling - Sigma Adaptor 
                                                          Changes
Spring 20       Sandeep Y       18/08/2020              SM Spirng package upgrade csedm__Product_Definition__c is deprecated use new field csedm__Source__c    
============================================================================
*/ 
public class SigmaJSONParseInterface { 
    Private Static Boolean isPriceOnlyCreate = SigmaDataInterfaceUtility.isPriceChangeOnly();
    public Static Map< String,Id> prodspectoId = SigmaUtility.prodDefWithIds();
    public Static Map< String,String> prodsmapSpecdetails = SpecificationAttributesSave.getSpecificationAttributes();
    public Static Map<String,cscfga__Product_Definition__c> mapProductDef = SigmaUtility.getAllProductDefination();
    public Static Map<String,String> mapChildParentComb = new Map <String,String> ();
    public Static Map<String,List <Attributes>> fulfilmentMap = new Map <String,List <Attributes>> ();
    public Static List<csedm__Specification__c> lstSpecificationToInsert = new List<csedm__Specification__c>();
    public Static List<Product_Attribute_Metadata__c> PrdtAttrMetadataLst = new List<Product_Attribute_Metadata__c>();
    public Static List<cspmb__Price_Item__c> lstPriceItemToInsert = new List<cspmb__Price_Item__c>();
    public Static List<cspmb__Add_On_Price_Item__c> lstAddonToInsert = new List<cspmb__Add_On_Price_Item__c>();
    //Changes start for EDGE-89988 -- list to insert records into Allowance object
    public Static List<Allowance__c> allowanceListToInsert = new List<Allowance__c>();
    //Changes end for EDGE-89988
    public Static map <String, cscfga__Product_Definition__c> MapUpdateDefinationwithVersion = new map <String,cscfga__Product_Definition__c> ();            
    public Static List<Attachment> lstAddAttachment = new List<Attachment>();
    public Static Set<String> setSpecExternalIds = new Set<String>();
    public Static Set<String> setPriceItemExternalIds = new Set<String>();
    public Static Set<String> setAddonExternalIds = new Set<String>();
    public Static String offername; 
    public Static String offerspecId;
    public Static List<BusinessID_Specification__mdt>  listBusinessSpecIDs;
    public Static Map<String, String> specGrandSpecID = new Map<String, String>();

    public class ProductStaticCharacteristics {
        public String name {get;set;} 
        public String value {get;set;} 
    }
    SigmaDataInterfacev2 v2 = new SigmaDataInterfacev2();
    public class Products {
        public String name {get;set;} 
        public String type_x {get;set;} // in json: type
        public String action {get;set;} 
        public String specId {get;set;} 
        public String startDate {get;set;} 
        public String endDate {get;set;} 
        public String associationStartDate {get;set;} 
        public String associationEndDate {get;set;} 
        public String version {get;set;} 
        public List<ProductStaticCharacteristics> productStaticCharacteristics {get;set;} 
        public List<Attributes> attributes {get;set;} 
        public List<Charges> charges {get;set;} 
        public List<MappingRules> mappingRules {get;set;} 
        public List<Products> products {get;set;} 
        public List<Allowances> allowances {get;set;}
        public map<String, List<sObject>> maprecdetails;
        
        
        
        public void AssignObjectValues(Map<String, List<sobject>> mapOfObjects, Products  prod, String parentSpecId){
            System.debug (' -----------AssignObjectValues------------ Getting called for parent ID --- '+parentSpecId + ' Product ID ' +prod.specId  );
           //EDGE-70345
            String externalCharacteristic;
            csedm__Specification__c prodSpec= new csedm__Specification__c();
            //Map<string,List<SigmaJSONParseInterface.Attributes>> mapOfInterfaceNames = new map<string,List<SigmaJSONParseInterface.Attributes>>();
            prodSpec = ProcessSpecificationRecords.createSpecification(prod,prodSpec);     
              
            if(productStaticCharacteristics != null && action != 'none' && !isPriceOnlyCreate){
                mapChildParentComb.put(specId,parentSpecId);
                String ProductDefId = SigmaUtility.getProductDefination(specId, mapChildParentComb,prodspectoId);
                boolean isFulfillmentcreate=false;
                //changes start for 82599 
                String SpecValue = ProcessSpecificationRecords.generateFulfilmentJSON(prodSpec,attributes, prod,offername,offerspecId, PrdtAttrMetadataLst);
                //changes end for 82599
                for(SigmaJSONParseInterface.ProductStaticCharacteristics prodStcChar : productStaticCharacteristics)
                {
                    if(prodStcChar.name == 'TechPhases' && prodStcChar.value == 'true') {
                        if(parentSpecId != specId){
                            prodSpec.csedm__identifier__c =parentSpecId+ specId;
                            prodSpec.External_Id__c =parentSpecId+ specId;
                        }else{
                            prodSpec.External_Id__c =specId;
                            prodSpec.csedm__identifier__c =specId;
                        }
                        prodSpec.Name = name+'_Fulfilment';
                        prodSpec.csedm__Code__c = specId+'_Fulfilment';
                        externalCharacteristic = prodSpec.External_Id__c+'_Fulfilment';
                        String FinalValue = SpecValue;
                        FinalValue = FinalValue.replace('CODE',prodSpec.csedm__Code__c);
                        //FinalValue = FinalValue.replace('EXTERNALID',prodSpec.External_Id__c);                        
                        FinalValue = FinalValue.replace('NAME',prodSpec.Name);
                        prodSpec.csedm__Value__c = FinalValue;
                        if(prodsmapSpecdetails.containsKey(prodSpec.External_Id__c))
                            prodSpec.csedm__Value__c = prodsmapSpecdetails.get(prodSpec.External_Id__c);
                        /*
                        ** Populate Product Defination
                        */
                        
                        //system.debug('---------- 70345 ------ProductDefId>'+ProductDefId);
                        if(ProductDefId != null && ProductDefId !='' && ProductDefId != 'Not Found'){
                           // prodSpec.csedm__Product_Definition__c = ProductDefId;  // Spring 20 Commented
                            prodSpec.csedm__Source__c = ProductDefId; // Spring 20 
                            //externalCharacteristic += '_PRODDEF'+ProductDefId;
                            //system.debug('------>externalCharacteristic<----'+externalCharacteristic);
                           // MapUpdateDefinationwithVersion.put(prodSpec.csedm__Product_Definition__c, new cscfga__Product_Definition__c(Id=prodSpec.csedm__Product_Definition__c, // Spring 20 Commented
                            MapUpdateDefinationwithVersion.put(prodSpec.csedm__Source__c, new cscfga__Product_Definition__c(Id=prodSpec.csedm__Source__c,  // Spring 20
                                    Product_Model_Version__c=prod.version));
                        }
                        
                   
                        if(!setSpecExternalIds.contains(prodSpec.External_Id__c)){
                            lstSpecificationToInsert.add(prodSpec);
                            setSpecExternalIds.add(prodSpec.External_Id__c);
                        }
                        isFulfillmentcreate = true;
                        if(attributes != null){
                            //System.debug ('****************EDGE-70345 Values*********************'+prodSpec.csedm__Code__c);
                            //System.debug ('****************EDGE-70345 Values*********************'+ATTRIBUTES);
                            //SigmaDataInterfacev2.mapOfInterfaceNames.put(externalCharacteristic, ATTRIBUTES);
                            
                            //System.debug (' ****************EDGE-70345 Values*********************'+SigmaDataInterfacev2.mapOfInterfaceNames);
                            mapOfObjects = ProcessChangeRequestRecords.createFullfilmentChangerequest(mapOfObjects,
                                prodSpec,attributes,prod,mappingRules,parentSpecId,'ChangeRequest',isFulfillmentcreate);
                        }
                    }
                    
                    
                    if(prodStcChar.name == 'AssurancePhase' && prodStcChar.value == 'true') {
                        if(parentSpecId != specId){
                            prodSpec.External_Id__c =parentSpecId+ specId;
                            prodSpec.csedm__identifier__c =parentSpecId+ specId;
                        }else{
                            prodSpec.External_Id__c =specId;
                            prodSpec.csedm__identifier__c =specId;
                        }
                        prodSpec.Name = name+'_Assurance';
                        prodSpec.csedm__Code__c = specId+'_Assurance';
                        //EDGE-70345: Ramya G
                        externalCharacteristic = prodSpec.External_Id__c+'_Assurance';
                        String FinalValue = SpecValue;
                        FinalValue = FinalValue.replace('_Fulfilment','_Assurance');
                        FinalValue = FinalValue.replace('FULFILMENT','ASSURANCE');
                        //FinalValue = FinalValue.replace('EXTERNALID',prodSpec.External_Id__c);
                        FinalValue = FinalValue.replace('CODE',prodSpec.csedm__Code__c);
                        FinalValue = FinalValue.replace('NAME',prodSpec.Name);
                        
                        prodSpec.csedm__Value__c = FinalValue;
                        if(prodsmapSpecdetails.containsKey(prodSpec.External_Id__c))
                            prodSpec.csedm__Value__c = prodsmapSpecdetails.get(prodSpec.External_Id__c);
                            
                        /*
                        ** Populate Product Defination
                        */
                        
                        if(ProductDefId != null && ProductDefId !='' && ProductDefId != 'Not Found'){
                           // prodSpec.csedm__Product_Definition__c = ProductDefId;  // Spring 20 Commented
                            prodSpec.csedm__Source__c = ProductDefId;  // Spring 20
                            
                            //MapUpdateDefinationwithVersion.put(prodSpec.csedm__Product_Definition__c, new cscfga__Product_Definition__c(Id=prodSpec.csedm__Product_Definition__c, // Spring 20
                            MapUpdateDefinationwithVersion.put(prodSpec.csedm__Source__c, new cscfga__Product_Definition__c(Id=prodSpec.csedm__Source__c, // Spring 20
                                    Product_Model_Version__c=prod.version));
                        }
                        
                        
                        /*Below method will generate populate the field values into current spec and retun
                        * updated SpecialMapping
                        */
                        prodSpec = ProcessSpecificationRecords.createSpecification(prod,prodSpec);
                        
                        /*Below method will generate the json file and add into current spec and retun
                        * updated SpecialMapping
                        */
                        if(!setSpecExternalIds.contains(prodSpec.External_Id__c)){
                            lstSpecificationToInsert.add(prodSpec);
                            setSpecExternalIds.add(prodSpec.External_Id__c);
                        }
                        if(attributes != null){
                        //
                        //EDGE-70345: Ramya G
                            //SigmaDataInterfacev2.mapOfInterfaceNames.put(externalCharacteristic, ATTRIBUTES);
                            mapOfObjects = ProcessChangeRequestRecords.createAssuranceAttributesChangerequest(
                                mapOfObjects,attributes,prod,mappingRules,parentSpecId,'ChangeRequest',isFulfillmentcreate);
                        }
                        
                    }
                } 
                
            }
            
            
            
            if(charges != null && action != 'none'){
                String SpecValue = ProcessSpecificationRecords.generatechargeJSON();
                String autoAddFalseBillingJSON = ProcessChangeRequestRecords.createBillingChargeAttributesChangerequest();
                if(prod.attributes != null)
                {
                    for(SigmaJSONParseInterface.Attributes att : prod.attributes)
                    {
                        if(String.isNotBlank(att.interfaceName))
                        {        
                            autoAddFalseBillingJSON += ',{"name": "'+ att.interfaceName + '", "value": "","type": "string"}';
                        } 
                    }
                }
                
                for(SigmaJSONParseInterface.Charges charge : Charges)
                {
                    if(!isPriceOnlyCreate){
                        String FinalValue = SpecValue;
                        mapChildParentComb.put(charge.specId,specid);
                        prodSpec = new csedm__Specification__c(); // 
                        prodSpec.csedm__Value__c = '';
                        
                        prodSpec.Name = name+'_Billing_'+charge.specId.replace('DMCAT_','');
                        prodSpec.csedm__Code__c = parentSpecId+'_Billing_'+charge.specId.replace('DMCAT_','');
                        prodSpec.BDSEDM__c = true;
                        prodSpec.Type__c = charge.type_x;
                        prodSpec.External_Id__c = parentSpecId+SpecId+'_Billing_'+charge.specId.replace('DMCAT_','');
                       
                        /*
                        ** Populate Product Defination
                        */
                        String ProductDefId = SigmaUtility.getProductDefination(charge.specId, mapChildParentComb,prodspectoId);
                        if(ProductDefId != null && ProductDefId !='' && ProductDefId != 'Not Found'){
                           // prodSpec.csedm__Product_Definition__c = ProductDefId;
                            prodSpec.csedm__Source__c = ProductDefId;
                            
                           // MapUpdateDefinationwithVersion.put(prodSpec.csedm__Product_Definition__c, new cscfga__Product_Definition__c(Id=prodSpec.csedm__Product_Definition__c, // Spring 20 Commented
                            MapUpdateDefinationwithVersion.put(prodSpec.csedm__Source__c, new cscfga__Product_Definition__c(Id=prodSpec.csedm__Source__c,  // Spring 20 
                                        Product_Model_Version__c=prod.version));
                        }
                        
                        prodSpec.csedm__identifier__c = prodSpec.External_Id__c;
                        FinalValue = FinalValue.replace('CODE',prodSpec.csedm__Code__c);
                        FinalValue = FinalValue.replace('SPECNAME',prodSpec.Name);
                        //FinalValue = FinalValue.replace('EXTERNALID',prodSpec.External_Id__c);
                        //system.debug('After FinalValue>>>>>' + FinalValue);
                        prodSpec.csedm__Value__c = FinalValue;
                        if(prodsmapSpecdetails.containsKey(prodSpec.External_Id__c))
                            prodSpec.csedm__Value__c = prodsmapSpecdetails.get(prodSpec.External_Id__c);
                                            
                        /*Below method will generate populate the field values into current spec and retun
                        * updated SpecialMapping
                        */
                        prodSpec = ProcessSpecificationRecords.createSpecification(prod,prodSpec);

                        //lstSpecificationToInsert.add(prodSpec);
                        if(!setSpecExternalIds.contains(prodSpec.External_Id__c)){
                            lstSpecificationToInsert.add(prodSpec);
                            setSpecExternalIds.add(prodSpec.External_Id__c);
                        }
                        
                        autoAddFalseBillingJSON = autoAddFalseBillingJSON.replace('PRODUCTSPECID',prod.SpecId);
                        String chargeSpecId = charge.specId.replace('DMCAT_','');
                        autoAddFalseBillingJSON = autoAddFalseBillingJSON.replace('CHARGSPECID',chargeSpecId);
                        autoAddFalseBillingJSON = autoAddFalseBillingJSON.replace('EXTERNALID',prodSpec.External_Id__c);
                        system.debug(Logginglevel.ERROR ,'autoAddFalseBillingJSON>>>>'+autoAddFalseBillingJSON);
                        Attachment attachment1 = new Attachment();
                        attachment1.Body = Blob.valueOf(autoAddfalseBillingJSON);
                        attachment1.Name = prodSpec.External_Id__c;//'Change Request '+ date.today().format()+'.json';
                        //system.debug(Logginglevel.ERROR ,'attachment1>>>>'+attachment1);
                        lstAddAttachment.add(attachment1);
                    }
                    /*
                    ** Process Charge for creating the Price Item
                    */
                    mapOfObjects = ProcessPriceItemRecords.createPriceItem(mapOfObjects,charge, prod);
                    
                }
            }

            // Sr 1 - EDGE-81060 - Code to check if the spec ID if in the custom meta data if it exists then change the external id to
            //grandParentID+ParentID+SPecID
            System.debug ('specId-------------------------------------------'+ specId +'size  '+specGrandSpecID.size() );
            if (specGrandSpecID.containsKey(specId))
            {
                //System.debug ('Changing the External ID for Incident Management - ');
                prodSpec.External_Id__c = specGrandSpecID.get (specId)+ parentSpecId+ specId;
            }
            String specNumber;
            String strtargetEntity = '';
            if(allowances != null && action != 'none' && !isPriceOnlyCreate){
                specNumber = '';
                String autoAddfalseBillingJSON = '';
                String code;
                //changes start for 82599 to store the AllowanceVal in another variable before 
                //it gets overwritten in the for loop
                String AllowanceValOrig = ProcessSpecificationRecords.generateAllowanceJSON();
                //changes end for 82599
                //Added by LG
                integer icountAllowanceDetails =0;
                for(SigmaJSONParseInterface.allowances allowance : allowances)
                {
                   //changes start for 82599 to store the AllowanceVal in another variable before 
                   //it gets overwritten in the for loop
                   String AllowanceVal = AllowanceValOrig;
                   //changes end for 82599
                   strtargetEntity = allowance.targetEntity;
                   if(allowance.allowanceDetails != null)
                   {
                        //changes start for EDGE-89988 -- check the size of allowance details
                        icountAllowanceDetails = allowance.allowanceDetails.size();
                        boolean alwnceSpecCreated = false;
                        //changes end for EDGE-89988
                        for(SigmaJSONParseInterface.AllowanceDetails allowancedetail : allowance.allowanceDetails)
                        {
                            //changes start for EDGE-89988. -- create allowance spec only once even for multiple records under allowance details.
                            Allowance__c alwnceSpec= new Allowance__c();
                            if(alwnceSpecCreated == false)
                            {
                            //changes end for EDGE-89988
                                prodSpec = new csedm__Specification__c();
                                mapChildParentComb.put(allowance.specId,specId);
                                String[] arrName; 
                                if(allowancedetail.externalId != null){
                                    arrName= allowancedetail.externalId.split('Allowance');
                                }
                              //changes start for 82599 to incorporate naming pattern changes for allowances.
                              prodSpec.Name = name+'_Billing_'+allowance.specId;
                              specNumber = allowance.specId.replace('DMCAT_Allowance','');
                              //changes end for 82599
                                //Added for EDGE-81060
                              if (strtargetEntity==null || strtargetEntity =='' ||strtargetEntity== specId){
                                    prodSpec.csedm__Code__c = specId+'_Billing_Allowance'+specNumber;
                              }else 
                               if (strtargetEntity != specId){
                                    prodSpec.csedm__Code__c = strtargetEntity+'_Billing_Allowance'+specNumber;
                                }
                               // prodSpec.csedm__Code__c = specId+'_Billing_Allowance'+arrName[1];
                                prodSpec.BDSEDM__c = true;
                                prodSpec.Type__c = allowancedetail.type_x;
                                /*
                                ** Populate Product Defination
                                */
                                String ProductDefId = SigmaUtility.getProductDefination(allowance.specId, mapChildParentComb,prodspectoId);
                                if(ProductDefId != null && ProductDefId !='' && ProductDefId != 'Not Found'){
                                 //   prodSpec.csedm__Product_Definition__c = ProductDefId;
                                    prodSpec.csedm__Source__c = ProductDefId;
                                    
                                  //  MapUpdateDefinationwithVersion.put(prodSpec.csedm__Product_Definition__c, new cscfga__Product_Definition__c(Id=prodSpec.csedm__Product_Definition__c, // Spring 20 Commented
                                    MapUpdateDefinationwithVersion.put(prodSpec.csedm__Source__c, new cscfga__Product_Definition__c(Id=prodSpec.csedm__Source__c,  // Spring 20 
                                        Product_Model_Version__c=prod.version));
                                }
                                
                                prodSpec.External_Id__c =parentSpecId+ specId+'_Billing_Allowance'+arrName[1];
                                // EDGE-81060The above stmt had issues and it was copying the external id instead now copying the specID
                                
                               // prodSpec.External_Id__c =parentSpecId+ specId+'_Billing_Allowance'+allowance.specId;
                                
                                prodSpec.csedm__identifier__c = prodSpec.External_Id__c;
                                
                                /*Below method will generate populate the field values into current spec and retun
                                * updated SpecialMapping
                                */
                                prodSpec = ProcessSpecificationRecords.createSpecification(prod,prodSpec);
                                /*Below method will generate the json file and add into current spec and retun
                                * updated SpecialMapping
                                */
                                
                                //changes start for EDGE-89988. Add ocsProdId only when there is one record in AllowanceDetails.
                                if(icountAllowanceDetails == 1)
                                {
                                    AllowanceVal = AllowanceVal.replace('OCRPRODID', allowance.ocsProdID);
                                }
                                //changes end for EDGE-89988
                                AllowanceVal = AllowanceVal.replace('CODE', prodSpec.csedm__Code__c);
                                AllowanceVal = AllowanceVal.replace('SPECNAME', prodSpec.name);
                                AllowanceVal = AllowanceVal.replace('BILLINGSPECID', allowance.billingSpecId);
                                AllowanceVal = AllowanceVal.replace('TYPEX', allowancedetail.type_x);
                                AllowanceVal = AllowanceVal.replace('UNITOFMEASURE', allowancedetail.unitofMeasure);
                                AllowanceVal = AllowanceVal.replace('VALUE', allowancedetail.value);
                                
                                //System.debug ('AllowanceVal ------' + allowancedetail.value);
                                //AllowanceVal = AllowanceVal.replace('EXTERNALID', prodSpec.External_Id__c);
                                prodSpec.csedm__Value__c = AllowanceVal;
                                if(prodsmapSpecdetails.containsKey(prodSpec.External_Id__c))
                                    prodSpec.csedm__Value__c = prodsmapSpecdetails.get(prodSpec.External_Id__c);
                            
                                if(!setSpecExternalIds.contains(prodSpec.External_Id__c)){
                                    //changes start for EDGE-89988 -- set alwnceSpecCreated to true when one record is inserted into specification list.
                                    alwnceSpecCreated = true;
                                    //changes start for EDGE-89988
                                    lstSpecificationToInsert.add(prodSpec);
                                    setSpecExternalIds.add(prodSpec.External_Id__c);
                                }
                                /*
                                ** Create Attachment for Specification
                                */
                                arrName = new List<String>(); 
                                if(allowancedetail.externalId != null){
                                    arrName= allowancedetail.externalId.split('Allowance');
                                }
                                //code = parentSpecId+ specId+'_Billing_Allowance'+arrName[1];
                                code = prodSpec.csedm__Code__c;
                                autoAddfalseBillingJSON= '{ "code" : "'+ code + '","externalId": "' + prodSpec.External_Id__c + '", "attributes" : [  ' ;
                                
                                if(String.isNotBlank(allowancedetail.type_x)){                                
                                    autoAddfalseBillingJSON += '{"name": "type", "value": "","type": "string"},';
                                } 
                                if( String.isNotBlank(allowance.ocsProdID)){
                                    autoAddfalseBillingJSON +='{"name": "ocsProdID", "value": "","type": "string"},';
                                }
                                if( String.isNotBlank(allowance.billingSpecId))
                                {
                                    autoAddfalseBillingJSON +='{"name": "billingSpecId", "value": "","type": "string"},';
                                }
                                if(String.isNotBlank(allowancedetail.unitofMeasure) ){
                                    autoAddfalseBillingJSON +='{"name": "unitofMeasure", "value": "","type": "string"},';
                                }
                                if(String.isNotBlank(allowancedetail.value) ){
                                    autoAddfalseBillingJSON +='{"name": "value", "value": "","type": "string"},';
                                }
                                
                                //Changes Start for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                                autoAddfalseBillingJSON +='{"name": "billDescription", "value": "","type": "string"},{"name": "rateExcludeGST", "value": "","type": "string"}';
                                if(attributes.size() > 0)
                                {
                                    for(SigmaJSONParseInterface.Attributes att : attributes)
                                    {
                                        if(String.isNotBlank(att.interfaceName))
                                        {        
                                            autoAddFalseBillingJSON += ',{"name": "'+ att.interfaceName + '", "value": "","type": "string"}';
                                        } 
                                    }
                                }
                            }
                            //changes start for EDGE-89988 -- add records into allowance list that will be added into the custom Allowance object
                            if(icountAllowanceDetails > 1)
                            {
                                alwnceSpec.External_Id__c = allowancedetail.externalId;
                                alwnceSpec.offer__c = allowancedetail.offer;
                                alwnceSpec.plan__c = allowancedetail.plan;
                                alwnceSpec.Name = allowance.name ;
                                alwnceSpec.billingSpecId__c = allowance.billingSpecId;
                                alwnceSpec.ocsProdID__c = allowance.ocsProdID; 
                                alwnceSpec.type__c = allowancedetail.type_x;
                                alwnceSpec.value__c = allowancedetail.value;
                                alwnceSpec.Unit_Of_Measure__c = allowancedetail.unitofMeasure;
                                alwnceSpec.subtype__c = allowancedetail.subtype;
                                alwnceSpec.specId__c = allowance.specId;
                                alwnceSpec.startDate__c = Date.valueOf(allowancedetail.startDate);
                                alwnceSpec.endDate__c = Date.valueOf(allowancedetail.endDate);
                                alwnceSpec.offerId__c = offername;
                                allowanceListToInsert.add(alwnceSpec);
                            }
                            //changes end for EDGE-89988
                    
                        }
                    }
                }
                autoAddfalseBillingJSON += '], "autoAdd": "false" }';               
                //system.debug(Logginglevel.ERROR ,'autoAddFalseBillingJSON>>>>'+autoAddFalseBillingJSON);
                    
                Attachment attachment1 = new Attachment();
                attachment1.Body = Blob.valueOf(autoAddfalseBillingJSON);
                attachment1.Name = prodSpec.External_Id__c;//'Change Request '+ date.today().format()+'.json';
                //system.debug(Logginglevel.ERROR ,'attachment1>>>>'+attachment1);
                // Below method will add record into final map and return the updated map
                lstAddAttachment.add(attachment1);
            }
            
            if(products != null){
                for (Products childprod: products){
                    childprod.AssignObjectValues(mapOfObjects,childprod, prod.specId);
                }
            }
            //Add all record to MAP
            mapOfObjects.put('Specification',lstSpecificationToInsert);
            mapOfObjects.put('AddonPriceItem',lstAddonToInsert);
            mapOfObjects.put('PriceItem',lstPriceItemToInsert);
            mapOfObjects.put('ChangeRequest',lstAddAttachment);
            mapOfObjects.put('ProductDefination',MapUpdateDefinationwithVersion.values());
            //changes start for 82599 to add PrdtAttrMetadata into the map
            mapOfObjects.put('PrdtAttrMetadata',PrdtAttrMetadataLst);
            //changes end for 82599 
            //changes start for EDGE-89988 -- Insert the allowanceListToInsert into the map.
            mapOfObjects.put('Allowance',allowanceListToInsert);
            //changes end for EDGE-89988
            //setSpecExternalIds = new Set<String>();
            //return mapOfInterfaceNames;
        }
    }
    
    public class MappingRules {
        public String type_x {get;set;} // in json: type
        public String dependencyRule {get;set;} 
        public String name {get;set;} 
        public Source source {get;set;} 
        public Source target {get;set;} 
    }
    
    public class Attributes {
        public String name {get;set;} 
        public String interfaceName {get;set;} 
        public String cpqDisplayName {get;set;} 
        public String type_x {get;set;} // in json: type
        public List<String> values {get;set;} 
        public String default_x {get;set;} // in json: default
        public List<ProductStaticCharacteristics> staticCharacteristics {get;set;} 
    }
    
    public class Allowances {
        public String name {get;set;} 
        public String specId {get;set;} 
        public String startDate {get;set;} 
        public String endDate {get;set;} 
        public String associationStartDate {get;set;} 
        public String associationEndDate {get;set;} 
        public String billingSpecId {get;set;} 
        public String ocsProdID {get;set;} 
        public List<AllowanceDetails> allowanceDetails {get;set;} 
        //Added for EDGE-81060
        public String targetEntity {get;set;}
    }
    
    public class Source {
        public String productId {get;set;} 
        public String characteristicId {get;set;} 
    }
    
    public class AllowanceDetails {
        public String externalId {get;set;} 
        public String startDate {get;set;} 
        public String endDate {get;set;} 
        public String type_x {get;set;} // in json: type
        public String unitofMeasure {get;set;} 
        public String value {get;set;} 
        //Changes start for EDGE-89988 -- Declare new variables coming as part of the json.
        public String plan {get;set;} 
        public String offer {get;set;} 
        public String subtype {get;set;} 
        //Changes end for EDGE-89988 
    }
    public class Prices {
        public String startdate {get;set;} 
        public String enddate {get;set;} 
        public String term; //ui
        public String externalId {get;set;} 
        public String billingId; //Customer Facing Service Id
        public String rateExcludeGST {get;set;} 
        public String billDescription {get;set;} 
        public List<ProductStaticCharacteristics> attributes {get;set;} 
    }
    
    public ProductOffering productOffering {get;set;} 
    public class ProductOffering {
        public String name {get;set;} 
        public String specId {get;set;} 
        public String invoiceDefinition {get;set;} 
        public String version {get;set;} 
        public List<Products> products {get;set;} 
        
        public void AssignObjectValues(Map<String, List<sobject>> mapOfObjects){
            offername = name;
            offerspecId = specId;

            //Sr 1 - This list stores the SPec ID where External ID format needs to be changed
            listBusinessSpecIDs = [select label, GrandParentID__c from BusinessID_Specification__mdt];
            for (BusinessID_Specification__mdt listSpecsGrandSpec : listBusinessSpecIDs)
            {
               specGrandSpecID.put (listSpecsGrandSpec.label,listSpecsGrandSpec.GrandParentID__c); 
               //System.debug ('listSpecsGrandSpec.label'+ listSpecsGrandSpec.label);
               //System.debug ('listSpecsGrandSpec.GrandParentID__c'+ listSpecsGrandSpec.GrandParentID__c);
            }
            
            for (Products prod : products){
                prod.AssignObjectValues(mapOfObjects, prod, prod.specId);
              
            }
        }
    }
    
    
    public class Charges {
        public String specId {get;set;} 
        public String type_x {get;set;} // in json: type
        public String currency_x {get;set;} 
        public String frequency_x {get;set;} 
        public String billingSpecId {get;set;} 
        public String billInAdvance {get;set;} 
        public String prorate {get;set;} 
        public String taxTreatment {get;set;} 
        public String unitofMeasure {get;set;} 
        public String billingSubtype {get;set;} 
        public String ocsProdID {get;set;} 
        public List<Prices> prices {get;set;} 
    }
}