/*
Created BY: Abinash Barik
Created Date: 
Description: EDGE-81696,EDGE-70343 - Sigma-CS interface code refactoring - 
            Modular class structure and generic json parsing logic,
            Sigma-CS interface code refactoring - Update logic for Price Item, 
            Attribute LoV and EDM mappings.
        This class is responsible for create all PDM records once the SIGMA LAUNCH happen
Class Name: SigmaUtility
============================================================================
ChangeSet   No    Name            Date                    Description
EDGE-82599  1     Vijayalakshmi 31-May-2019               Changes related to Product attribute metadata upsert.
Spring 20       Sandeep Y       18/08/2020              SM Spirng package upgrade csedm__Product_Definition__c is deprecated use new field csedm__Source__c 
*/ 

public class SigmaUtility {
    public Static Map< String,Id> prodspectoId = new Map <String,Id>();
    
    public Static Map<String,csedm__Specification__c > mapSpecification= new Map < String,csedm__Specification__c> ();
    public static Map<String,csedm__Specification__c > getAllActiveSpecification(){
        if(mapSpecification.isEmpty()){
           // for(csedm__Specification__c spec: [SELECT id,Name,csedm__Code__c,csedm__identifier__c,External_Id__c,csedm__Product_Definition__c,  // Spring 20 COmmented
            for(csedm__Specification__c spec: [SELECT id,Name,csedm__Code__c,csedm__identifier__c,External_Id__c,csedm__Source__c,  // Spring 20 
                                               csedm__Active__c FROM csedm__Specification__c WHERE csedm__Active__c = true]){
                                                   mapSpecification.put(spec.External_Id__c, spec);
                                               }
        }
        return mapSpecification;
    }
    
    Public static map<String,cscfga__Product_Definition__c> getAllProductDefination(){
        Map<String,cscfga__Product_Definition__c> mapProductDef = new Map<String,cscfga__Product_Definition__c>();
        for(cscfga__Product_Definition__c def: [SELECT id,product_Specification__c FROM cscfga__Product_Definition__c
                                                WHERE product_Specification__c!= '' 
                                                AND cscfga__IsArchived__c=FALSE]){
                  system.debug('Def Spec ID>>>>' + def.product_Specification__c);
                                                    mapProductDef.put(def.product_Specification__c,def);                                  
        }
        return mapProductDef;
    }
    
    public static String peformInsertOperation(List<Sobject> lstrecords, Boolean createLog){
        // DML statement
        Database.SaveResult[] srList = Database.insert(lstrecords, false);
        /*if(createLog){            
            createLog(srList);
        }*/
        
        return '';
    }
    /*public static void createLog(Database.SaveResult[] srList){
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        } 
    }*/
    
    //When the JSON parsing is completed then below method will executed and 
    //create all respective recors (Specification, Price Item, Addon Price Item,
    // Add on Price Item Association and Attachments)
    
    public static void commitAllrecords(Map<String, List<sobject>> mapallrecords){
        Boolean isPriceOnlyCreate = SigmaDataInterfaceUtility.isPriceChangeOnly();
        system.debug('isPriceOnlyCreate>>>>>' + isPriceOnlyCreate);
        List<csedm__Specification__c> specificatioToInsert = new List<csedm__Specification__c>();
        List<Product_Attribute_Metadata__c> PrdtAttrMetadatalst = new List<Product_Attribute_Metadata__c>();
        //Above list stores All Specification records to be upserted
        List<cspmb__Price_Item__c> lstPriceItem = new List<cspmb__Price_Item__c>();
        //Above list stores All Price Item records to be upserted
        List<cspmb__Add_On_Price_Item__c> lstaddonPriceItem = new List<cspmb__Add_On_Price_Item__c>();
        //Above list stores All AddonPrice Item records to be upserted
        List<Attachment> lstAttachmentToInsert = new List<Attachment>();
        //Above list stores All Attachment to be inserted        
        Map<String, csedm__Specification__c> mapSpecification = new Map<String, csedm__Specification__c>(); 
        //Above map stores Specification records against External Ids
        
        // =============== UPSERT ALL SPECIFICATION RECORDS ====================//
        // Here we get all the Specification List and upsert the records against external Id
        if(mapallrecords.containsKey('Specification') && !isPriceOnlyCreate){
            Set<String> setSpecItem = new Set<String>();
            specificatioToInsert.addall((List<csedm__Specification__c>) mapallrecords.get('Specification'));
            
            upsert specificatioToInsert External_Id__c;
        }
        
        // =============== UPSERT ALL Product Attribute Metadata RECORDS ====================//
        // Here we get all the Product Attribute Metadata List and upsert the records against Name
        if(mapallrecords.containsKey('PrdtAttrMetadata')){
            PrdtAttrMetadatalst.addall((List<Product_Attribute_Metadata__c>) mapallrecords.get('PrdtAttrMetadata'));
            Set<Product_Attribute_Metadata__c> PrdtAttrMetadataSet = new Set<Product_Attribute_Metadata__c>(PrdtAttrMetadatalst);
            List<Product_Attribute_Metadata__c> PrdtAttrMetadataUniquelst = new List<Product_Attribute_Metadata__c>(PrdtAttrMetadataSet);
            upsert PrdtAttrMetadataUniquelst Identifier__c;
        }
        
        // =============== UPSERT Addon PRICE ITEM ====================//
        // Here we get all the Add on Price Item List and upsert the records against external Id
        if(mapallrecords.containsKey('AddonPriceItem')){
            Set<String> setAddonPriceItem = new Set<String>();
            lstaddonPriceItem.addall((List<cspmb__Add_On_Price_Item__c>) mapallrecords.get('AddonPriceItem'));
            upsert lstaddonPriceItem External_Id__c;
        }
        //============================UPDATE PRODUCT DEFINATION ==============
        if(mapallrecords.containsKey('ProductDefination') && !isPriceOnlyCreate){
            update mapallrecords.get('ProductDefination');
        }
        
        // =============== UPSERT PRICE ITEM ====================//
        // Here we get all the Commercial Product List and upsert the records against external Id
        map<String,List<cspmb__Price_Item__c>> mapPriceItem = new map<String,List<cspmb__Price_Item__c>>();
        if(mapallrecords.containsKey('PriceItem')){
            Set<String> setPriceItem = new Set<String>();
            /*for(cspmb__Price_Item__c priceitem : (List<cspmb__Price_Item__c>) mapallrecords.get('PriceItem')){
                if(mapPriceItem.containskey(priceitem.ProdSpecId__c))
                    mapPriceItem.get(priceitem.ProdSpecId__c).add(priceitem);
                else
                    mapPriceItem.put(priceitem.ProdSpecId__c, new List<cspmb__Price_Item__c>{priceitem});               
                }*/
            lstPriceItem.addall((List<cspmb__Price_Item__c>) mapallrecords.get('PriceItem'));
            upsert lstPriceItem External_Id__c;
        }
        
       /*for(cspmb__Price_Item__c priceitem : lstPriceItem){
            if(mapPriceItem.containskey(priceitem.ProdSpecId__c))
                mapPriceItem.get(priceitem.ProdSpecId__c).add(priceitem);
            else
                mapPriceItem.put(priceitem.ProdSpecId__c, new List<cspmb__Price_Item__c>{priceitem});               
        }*/
        
        // =============== INSERT ALL PRICE ITEM ADD ON PRICE ITEM ASSOCIATION ====================//
        /*map <String,cspmb__Price_Item_Add_On_Price_Item_Association__c> insertAssociationItem = new map <String,cspmb__Price_Item_Add_On_Price_Item_Association__c> ();
        Set<String> setExternalIds = new Set<String>();
        for(cspmb__Add_On_Price_Item__c addonPI: lstaddonPriceItem){
            List<cspmb__Price_Item__c> lstMatchedPriceItem = new List<cspmb__Price_Item__c>();
            lstMatchedPriceItem = getPriceItemId(addonPI.ProdSpecId__c,SigmaJSONParseInterface.mapChildParentComb,mapPriceItem);
            if(!lstMatchedPriceItem.isEmpty()){
                for(cspmb__Price_Item__c item: lstMatchedPriceItem){
                    cspmb__Price_Item_Add_On_Price_Item_Association__c objassociation = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
                    objassociation.cspmb__Add_On_Price_Item__c = addonPI.id;
                    objassociation.cspmb__Price_Item__c = item.id;
                    objassociation.External_Id__c = item.External_Id__c + addonPI.External_Id__c;
                    if(!setExternalIds.contains(objassociation.External_Id__c)){
                        insertAssociationItem.put(objassociation.External_Id__c,objassociation);
                        setExternalIds.add(objassociation.External_Id__c);
                    }
                    
                }
            }          
        }
        system.debug('>>>>>insertAssociationItem' + insertAssociationItem);
        if (!insertAssociationItem.isEmpty()) {
            Database.upsert (insertAssociationItem.values(),false);
        }*/
        
        // =============== INSERT ALL ATTACHMENT(Change Request) ====================//
        // Here we get all the attachment and mapped to its parent records,
        // then insert
        
        if(mapallrecords.containsKey('ChangeRequest') && !SigmaDataInterfaceUtility.isPriceChangeOnly()){
            mapSpecification = getAllActiveSpecification();
            Set<String> setSpecItem = new Set<String>();
            for(Attachment attch: (List<Attachment>) mapallrecords.get('ChangeRequest')){
                if(mapSpecification.containsKey(attch.name)){
                    String strbody = attch.body.tostring();
                    //system.debug('>>>>>strbody' + strbody);
                    attch.ParentId= mapSpecification.get(attch.name).id;
                    attch.name= 'Change Request '+ date.today().format()+'.json';
                    lstAttachmentToInsert.add(attch);
                }
            }
            //  Moving the code to Asynchronous mode to create Change Request against the Specification 
            //we were getting Apex CPU time limit, Attachment object have trigger so it was executed uncessary 
            // for each and every transaction
            if(!lstAttachmentToInsert.isEmpty()){
                AsyncCreateAttachment updateJob = new AsyncCreateAttachment(lstAttachmentToInsert,lstAddonPriceItem,
                        lstPriceItem,SigmaJSONParseInterface.mapChildParentComb);
                // enqueue the job for processing
                ID jobID = System.enqueueJob(updateJob);
            }            
        } 
        //================== INSERT END ===============================
    }
    
    
        
        
    
    // Below method is returns map with all active Product Defination, Key will be Spec ID and value equals to id
    Public Static Map<String,Id> prodDefWithIds(){
        if(prodspectoId.isEmpty()){
            for (cscfga__Product_Definition__c pd: [SELECT id, product_Specification__c 
                                                    FROM cscfga__Product_Definition__c where product_Specification__c != '' 
                                                    AND cscfga__Active__c = true AND RecordType.Name='Product Definition']) { 
                                                        for(String Spec: pd.product_Specification__c.split(',')){
                                                            prodspectoId.put(Spec, pd.id);
                                                        }       
                                                    }
        }
        
        return prodspectoId;
    }
    // Below method is returns Parent Product defination id for a child Specification
    Public Static String getProductDefination(String currentSpecId, Map <String,String> mapParChildSpec,Map <String,Id> prodspectoId){
        String SpecId = currentSpecId;
        String msg ='';
        for(Integer i =0; i<4 ; i++){
            system.debug('Inside Loop' + SpecId);
            
            if(prodspectoId.containsKey(SpecId)){
                return prodspectoId.get(SpecId);
            }else{
                SpecId = mapParChildSpec.get(SpecId);
                msg = 'Not Found';
            }
        }
        return msg;
    } 
    
}