/*
Created BY: Abinash Barik
Created Date: 04/24/2019
Description: EDGE-81696,EDGE-70343 - Sigma-CS interface code refactoring - 
            Modular class structure and generic json parsing logic,
            Sigma-CS interface code refactoring - Update logic for Price Item, 
            Attribute LoV and EDM mappings.
            This class is responsible for create all Attachment(Change Request) records once the SIGMA LAUNCH happen
Class Name: AsyncCreateAttachment
=========================================================================
ChagneSet No    Name            Date                    Description

*/
public class AsyncCreateAttachment implements Queueable{
    public  List<Attachment> lstAttachment;
    public map<String,csedm__Specification__c> mapSpecification = new map<String,csedm__Specification__c>();
    public List<csedm__Specification__c> specUpdateList;
    public List<cspmb__Add_On_Price_Item__c> lstAddonPriceItem;
    public List<cspmb__Price_Item__c> lstPriceItem = new List<cspmb__Price_Item__c>();
    public Map<String,String> mapChildParentComb;
	public Set<String> setOfRecId = new Set<String>();
    
    public AsyncCreateAttachment(List<Attachment> lstAttachment,List<cspmb__Add_On_Price_Item__c> lstAddonPriceItem,
                                List<cspmb__Price_Item__c> lstPriceItem,Map<String,String> mapChildParentComb) {
        this.lstAttachment = lstAttachment;
        this.lstAddonPriceItem = lstAddonPriceItem;
        this.lstPriceItem = lstPriceItem;
        this.mapChildParentComb = mapChildParentComb;
        specUpdateList = new List<csedm__Specification__c> ();
        // Fetch all the Specification and store the same in map
        for(csedm__Specification__c spec: [Select id, csedm__Code__c,csedm__Value__c,External_Id__c 
                                           FROM csedm__Specification__c]){
                                               mapSpecification.put(spec.External_Id__c, spec);
                                           }
    }
    public void execute(QueueableContext context) {
        //try{
            if(!lstAttachment.isEmpty()){
                // Itterate over over all Attachment those are going to be created
                for(Attachment attach: lstAttachment){
                    String strbody = attach.body.tostring();
                    system.debug('>>>>>strbody' + strbody);
                    Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(strbody);
                    String autoAdd = (String) request.get('autoAdd');
                    String cfsCode = (string) request.get('externalId');
                    system.debug('>>>>>cfsCode' + cfsCode);
                    // get Spec record to be related to Attachment 
                    csedm__Specification__c spec = mapSpecification.get(cfsCode);
                    
                    if (autoAdd != null && autoAdd.equalsIgnoreCase('true')) {
                        List<Object> reqAttrList = (List<Object>) request.get('attributes');
                        request.put('status', 'Complete');
                        if(cfsCode != null && mapSpecification.containsKey(cfsCode)){
                            Map<String, Object> specObj = new Map<String, Object>();
                            if(spec.csedm__Value__c != null)
                                specObj = (Map<String, Object>) JSON.deserializeUntyped(spec.csedm__Value__c);
                            Map<String, Object> attrMap = (Map<String, Object>) specObj.get('attributes');
                            for (Object simpleAttr : reqAttrList) {
                                Map<String, Object> smpObj = (Map<String, Object>) simpleAttr;
                                //attrMap.put((string) smpObj.get('name'), new SimpleAttributeWrapper((string) smpObj.get('value'), (string) smpObj.get('type')));
                            }
                            if(spec !=null){
                                spec.csedm__Value__c = JSON.serialize(specObj);
								if(!setOfRecId.contains(spec.id)){
									specUpdateList.add(spec);
									setOfRecId.add(spec.id);
								}
                                
                            }
                            
                            attach.body=Blob.valueOf(JSON.serialize(request));
                            //attList.add(new Attachment(Name = 'Change Request ' + Date.today().format() + '.json', parentId = spec.Id, Body = Blob.valueOf(JSON.serialize(request))));
                        }
                    }else{
                        request.put('status', 'Pending');
                        attach.body=Blob.valueOf(JSON.serialize(request));
                        if(spec !=null){
                            spec.csedm__Change_Request_Pending__c = true;
                            if(!setOfRecId.contains(spec.id)){
								specUpdateList.add(spec);
								setOfRecId.add(spec.id);
							}
                         }                  
                    }
                }
                system.debug('lstAttachment to insert>>>' + lstAttachment);
                system.debug('lstAttachment to insert>>>' + lstAttachment.size());
                // Insert all Attachment
                if (!lstAttachment.isEmpty()) {
                    Database.insert(lstAttachment,false);
                }
                // Update all Specification
                if (!specUpdateList.isEmpty()) {
                    Database.update(specUpdateList,false);
                }
            }
          System.debug('lstAddonPriceItem>>>' + lstAddonPriceItem);  
            System.debug('lstPriceItem>>>' + lstPriceItem); 
            System.debug('mapChildParentComb>>>>>' + mapChildParentComb); 
            getPriceItemAddonPriceItemAssociation(lstAddonPriceItem,lstPriceItem,mapChildParentComb);
        /*}
        catch(Exception ex) {
            System.debug('Error:' + ex);  
        }*/
    }
    
    public Static void getPriceItemAddonPriceItemAssociation(List<cspmb__Add_On_Price_Item__c> lstAddonPriceItem,
                                List<cspmb__Price_Item__c> lstPriceItem,Map<String,String> mapChildParentComb){
                                    
         map<String,List<cspmb__Price_Item__c>> mapPriceItem = new map<String,List<cspmb__Price_Item__c>>();
    
        for(cspmb__Price_Item__c priceitem : lstPriceItem){
            if(mapPriceItem.containskey(priceitem.ProdSpecId__c))
                mapPriceItem.get(priceitem.ProdSpecId__c).add(priceitem);
            else
                mapPriceItem.put(priceitem.ProdSpecId__c, new List<cspmb__Price_Item__c>{priceitem});               
        }
        map <String,cspmb__Price_Item_Add_On_Price_Item_Association__c> insertAssociationItem = new map <String,cspmb__Price_Item_Add_On_Price_Item_Association__c> ();
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
        }
        
    }
    
    
    Public static List<cspmb__Price_Item__c> getPriceItemId(String currentSpecId,map<String,String> childSpecToParentProdSpecMap, map<String,List<cspmb__Price_Item__c>> mapPriceItem){
        List<cspmb__Price_Item__c> lstMatchedPriceItem = new List<cspmb__Price_Item__c>();
        //system.debug('Outside Loop' + currentSpecId);
        String SpecId = currentSpecId;
        for(Integer i =0; i<4 ; i++){
            system.debug('Inside Loop' + SpecId);
            if(mapPriceItem.containsKey(SpecId)){
                lstMatchedPriceItem = mapPriceItem.get(SpecId);
                return lstMatchedPriceItem;
            }else{
                SpecId = childSpecToParentProdSpecMap.get(SpecId);
            }
        }
        
        return lstMatchedPriceItem;
    }
}