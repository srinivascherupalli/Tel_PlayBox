/*********************************
 * @Author: Sarvanan, Sathyanarayanan, Vasu
 * @Date : Sep 19, 2021
 * @Description : orderEnrichmentUtill
 * Last modified Date: 13/10/2021
 *********************************/

public class orderEnrichmentUtill{
    private static final Integer LOOKUP_DELIVERY_SELECT_LIMIT = 25; 
    private static final Integer LOOKUP_CONTACT_SELECT_LIMIT = 99; 
    @AuraEnabled(cacheable=true)
    Public static string getSolutionsDetail(String solutionId){  
        Set<String> prodDefinitionId = New Set<String> ();
        Map<String,string> prodSpecMap = New Map<String,String> ();
        Map<String,string> prodSpecMapSolName = New Map<String,string> ();
        Map<String,string> prodSpecMapSolId = New Map<String,string> ();
        Map<String,String>  defId_solDefName = New Map<String,String>  ();
        Map<String,list<Order_Enrichment_Schema__mdt>> SchemaMeatdataMap = New Map<String,list<Order_Enrichment_Schema__mdt>> ();
        Map<String,list<OrderEnrichmentValidation__c>> validationMap = New Map<String,list<OrderEnrichmentValidation__c>> ();
        Map<String,solutionWrapper> solutionMap = New Map<String,solutionWrapper> ();
        Map<String,list<cscfga__Product_Configuration__c>> prodMap = New Map<String,list<cscfga__Product_Configuration__c>> ();
        list<string>attributeList=Label.orderEnrichmentAttribtes.split(',');
        list<cscfga__Product_Configuration__c>prodConfigList=[SELECT id, Name,(select id,Name,cscfga__Value__c,cscfga__Display_Value__c from cscfga__Attributes__r where Name IN :attributeList),(select id,Product_Definition_Name__c,Attribute1__c,Attribute2__c,Attribute3__c,Attribute4__c,Attribute5__c,Attribute6__c,Attribute7__c,Attribute8__c,Attribute9__c,Attribute10__c,Attribute11__c,Attribute12__c,Attribute13__c,Attribute14__c,Attribute15__c,Attribute16__c,Attribute17__c,Product_Basket__c from Order_Enrichments__r),csordtelcoa__Hierarchy_Level__c,cscfga__Index__c,cscfga__Product_Definition__c,cscfga__Product_Definition__r.Name, cscfga__Product_Definition__r.product_Specification__c,cssdm__solution_association__r.Name FROM cscfga__Product_Configuration__c  where cssdm__solution_association__r.id =: solutionId ORDER BY cscfga__Product_Definition__r.product_Specification__c ASC];
         for (cscfga__Product_Configuration__c prod :prodConfigList){
            if(prodMap.containsKey(prod.cscfga__Product_Definition__r.product_Specification__c)){
                prodMap.get(prod.cscfga__Product_Definition__r.product_Specification__c).add(prod);
            }else{
                List<cscfga__Product_Configuration__c>prodList=new List<cscfga__Product_Configuration__c>();
                prodList.add(prod);
                prodMap.put(prod.cscfga__Product_Definition__r.product_Specification__c,prodList);
            }
            prodSpecMap.put(prod.cscfga__Product_Definition__r.product_Specification__c,prod.cssdm__solution_association__r.Name+'-'+prod.cssdm__solution_association__r.id);
            prodSpecMapSolName.put(prod.cscfga__Product_Definition__r.product_Specification__c,prod.cssdm__solution_association__r.Name);
            prodSpecMapSolId.put(prod.cscfga__Product_Definition__r.product_Specification__c,prod.cssdm__solution_association__r.id);

          } 
            //system.debug('prodSpecId::'+prodSpecId); 
        for(Order_Enrichment_Schema__mdt lstSchemaMeatdata : [select id, Attribute_Json__c, Offer_Name__c,Product_Definition_Name__c,Product_Specification__c, Tab_Name__c, Tab_Order__c from Order_Enrichment_Schema__mdt where Product_Specification__c IN : prodSpecMap.keySet() ORDER BY Tab_Order__c ASC]){
            if(SchemaMeatdataMap.containsKey(lstSchemaMeatdata.Product_Specification__c)){
                SchemaMeatdataMap.get(lstSchemaMeatdata.Product_Specification__c).add(lstSchemaMeatdata);
            }else{
                List<Order_Enrichment_Schema__mdt>schemaList=new List<Order_Enrichment_Schema__mdt>();
                schemaList.add(lstSchemaMeatdata);
                SchemaMeatdataMap.put(lstSchemaMeatdata.Product_Specification__c,schemaList);
            }
        }
        for(OrderEnrichmentValidation__c lstValidation : [select id, Is_Active__c,Action__c,Condition__c,Target__c,Logic__c,Product_Specification_Id__c,Offer_Name__c from OrderEnrichmentValidation__c where Product_Specification_Id__c IN : prodSpecMap.keySet()]){
            if(validationMap.containsKey(lstValidation.Product_Specification_Id__c)){
                validationMap.get(lstValidation.Product_Specification_Id__c).add(lstValidation);
            }else{
                List<OrderEnrichmentValidation__c>schemaList=new List<OrderEnrichmentValidation__c>();
                schemaList.add(lstValidation);
                validationMap.put(lstValidation.Product_Specification_Id__c,schemaList);
            }
        }
        system.debug('validationMap:::::'+validationMap);
         list<OrderEnrichmentValidation__c>validatinNewList=new list<OrderEnrichmentValidation__c>();
        for (string schemaKey :SchemaMeatdataMap.keySet()){
           if(SchemaMeatdataMap.containsKey(schemaKey)){
                 if(validationMap.containsKey(schemaKey)){
                     validatinNewList.addAll(validationMap.get(schemaKey));
                 }
                if(solutionMap.containskey(prodSpecMap.get(schemaKey))){
                    solutionMap.get(prodSpecMap.get(schemaKey)).componentList.add(new ProductConfigurationWrapper(prodMap.get(schemaKey),SchemaMeatdataMap.get(schemaKey)));
                }else{
                    list<ProductConfigurationWrapper>ProdConfigSchemaList=new list<ProductConfigurationWrapper>();
                    ProdConfigSchemaList.add(new ProductConfigurationWrapper(prodMap.get(schemaKey),SchemaMeatdataMap.get(schemaKey)));
                    list<string>solList=(prodSpecMap.get(schemaKey)).split('-');                    
                    solutionMap.put(prodSpecMap.get(schemaKey),new solutionWrapper(prodSpecMapSolName.get(schemaKey),prodSpecMapSolId.get(schemaKey),ProdConfigSchemaList,new list<OrderEnrichmentValidation__c>()));                }
            }
        }
         list<solutionWrapper> solWrapList=solutionMap.values();
         solWrapList[0].validationlist=validatinNewList;
        
        system.debug('solutionMap'+solutionMap);
        return  JSON.serialize(solutionMap);

    }       
    public class solutionWrapper{
        @AuraEnabled
        public string solution{get; set;}
        @AuraEnabled
        public string solutionId{get; set;}
        @AuraEnabled
        public list<OrderEnrichmentValidation__c> validationlist{get; set;}
        @AuraEnabled
        public list<ProductConfigurationWrapper>componentList{get; set;}
        
        public solutionWrapper(string solutionName,string solutionId,list<ProductConfigurationWrapper> pcList,list<OrderEnrichmentValidation__c>validationlist){
            this.solution = solutionName;   
            this.solutionId=solutionId;
            this.componentList=pcList;
            this.validationlist=validationlist;
        }
    }

    public class ProductConfigurationWrapper{
        @AuraEnabled
        public list<cscfga__Product_Configuration__c> productConfigurationList{get; set;}
        @AuraEnabled
        public list<Order_Enrichment_Schema__mdt> SchemaWrapper{get; set;}
        public  ProductConfigurationWrapper(list<cscfga__Product_Configuration__c> prodConfigList,list<Order_Enrichment_Schema__mdt> SchemaWrapper){
            this.productConfigurationList=prodConfigList;
            this.SchemaWrapper=SchemaWrapper;
        }
    }
/***********************************************************************************************************
 * @Description : Method to return Delivery Address details 
 * @Parameters  : basketId , searchValue, CommercialPDName
 ************************************************************************************************************/

    @AuraEnabled
    public static List<Contact> doLookupContactDetails(String basketId, String searchValue, String CommercialPDName){
        Map<String,String> searchFields = new Map<String,String>();
        try {
            if(basketId != null && basketId != ''){
                searchFields.put('basketId',basketId);
                searchFields.put('searchValue',searchValue);
                searchFields.put('CommercialPDName',CommercialPDName);
                List<Contact> conLst = (List<Contact>)OrderEnrichmentLookUpHandler.doLookupContactFromAcctBasket(searchFields,LOOKUP_CONTACT_SELECT_LIMIT);
                return conLst;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception at OrderEnrichmentLookUp.doLookupContactDetails '+e.getMessage());
            return null;
        }
    }
/***********************************************************************************************************
 * @Description : Method to return Delivery Address details 
 * @Parameters  : basketId , searchValue
 ************************************************************************************************************/
    @AuraEnabled
    public static List<cscrm__Address__c> doLookupDeliveryAddress(String basketId, String searchValue){
        Map<String,String> searchFields = new Map<String,String>();
        try {
            searchFields.put('basketId',basketId);
            searchFields.put('searchValue',searchValue);
            List<cscrm__Address__c> deliveryAddress = (List<cscrm__Address__c>)OrderEnrichmentLookUpHandler.doLookupConfirmedAddress(searchFields,LOOKUP_DELIVERY_SELECT_LIMIT);
            return deliveryAddress;
        } catch (Exception e) {
            System.debug('Exception at OrderEnrichmentLookUp.doLookupContactDetails '+ e.getMessage());
            return null;
        }
    }


 @AuraEnabled
    public static String doInsertOE(List<Order_Enrichment__c> oeList,list<attributeWrapper>attributeList){
      
        set<string>pcSet=new set<string>();
        
        try {
            for(Order_Enrichment__c oeRecord :oeList){
                pcSet.add(oeRecord.Product_Configuration__c);
            }
            Map<string,list<cscfga__Attribute__c>>attrMap =new Map<string,list<cscfga__Attribute__c>>();
            list<cscfga__Attribute__c>attList=[select id,Name,cscfga__Value__c,cscfga__Product_Configuration__c from cscfga__Attribute__c where cscfga__Product_Configuration__c IN :pcSet];
            for(cscfga__Attribute__c att:attList){
                if(attrMap.containsKey(att.cscfga__Product_Configuration__c)){
                    attrMap.get(att.cscfga__Product_Configuration__c).add(att);
                }else{
                    list<cscfga__Attribute__c>alist=new list<cscfga__Attribute__c>();
                    alist.add(att);
                    attrMap.put(att.cscfga__Product_Configuration__c,alist);
                }
            }
            List<Order_Enrichment__c>ordList=[select id from Order_Enrichment__c where Product_Configuration__c IN:pcSet];
            if(!ordList.isEmpty()){
                delete ordList;
            }
            system.debug('attributeList::'+attributeList);
            if(!oeList.isEmpty()){
            
                insert oeList;
            }
            list<cscfga__Attribute__c>attrUpdate=new list<cscfga__Attribute__c>();
            Map<id,list<cscfga__Attribute__c> >relatedProductAttributeMap=new Map<id,list<cscfga__Attribute__c> >(); 
            for(attributeWrapper attrList: attributeList){
                if(attrMap.containsKey(attrList.pcID)){
                    for(cscfga__Attribute__c attrbute: attrList.attributeList){
                        for(cscfga__Attribute__c attrbuteUpdate:attrMap.get(attrList.pcID)){
                            if(attrbute.Name==attrbuteUpdate.Name){
                                cscfga__Attribute__c attr=new cscfga__Attribute__c(id=attrbuteUpdate.id,Name=attrbute.Name,cscfga__Value__c=attrbute.cscfga__Value__c,cscfga__Display_Value__c=attrbute.cscfga__Value__c);    
                                attrUpdate.add(attr); 
                            }else{
                                if(relatedProductAttributeMap.containsKey(attrList.pcID)){
                                    relatedProductAttributeMap.get(attrList.pcID).add(attrbute);
                                }else{
                                     list<cscfga__Attribute__c>attrListnew=new list<cscfga__Attribute__c>();
                                     attrListnew.add(attrbute);
                                     relatedProductAttributeMap.put(attrList.pcID,attrListnew);
                                }    
                            }
                        }                      
                    }
                }
            }
            if(relatedProductAttributeMap !=null){
                list<cscfga__Attribute__c>RelatedattList=[select id,Name,cscfga__Value__c,cscfga__Product_Configuration__c from cscfga__Attribute__c where cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c IN : relatedProductAttributeMap.keySet()];
                for(cscfga__Attribute__c attr: RelatedattList){
                 if(relatedProductAttributeMap.containsKey(attr.cscfga__Product_Configuration__c)){
                    for(cscfga__Attribute__c attrRel: relatedProductAttributeMap.get(attr.cscfga__Product_Configuration__c)){
                        if(attr.Name==attrRel.Name){
                            cscfga__Attribute__c Relatedattr=new cscfga__Attribute__c(id=attr.id,Name=attr.Name,cscfga__Value__c=attrRel.cscfga__Value__c,cscfga__Display_Value__c=attrRel.cscfga__Value__c);
                            attrUpdate.add(Relatedattr); 
                        }   
                    }
                    }
                       
                }
                
            }
            system.debug('attrUpdate:::'+attrUpdate);
             if(!attrUpdate.isEmpty())
                    update attrUpdate;
            
            return 'Success';
        } catch (Exception e) {
            System.debug('Exception at OrderEnrichmentLookUp.doInsertOE '+ e.getMessage());
            return 'failure';
        }
       // return '';
    }
    public class attributeWrapper{
        @AuraEnabled
        public id pcID{get; set;}
        @AuraEnabled
        public list<cscfga__Attribute__c>attributeList{get; set;}
        
        public attributeWrapper(Id pcID,list<cscfga__Attribute__c>attrList){
            this.pcID=pcID;
            this.attributeList=attrList;
        }
        public attributeWrapper(){}
    
    }
    public static set<id> getErrorDetails(string solId){
        list<string>attributeList=Label.orderEnrichmentAttribtes.split(',');
        set<id>pcListupdate =new set<id>();
         set<id>pcListupdateNew =new set<id>();
        list<cscfga__Product_Configuration__c>prodConfigList=[SELECT id, Name,(select id,Name,cscfga__Value__c,cscfga__Display_Value__c from cscfga__Attributes__r where Name IN :attributeList),csordtelcoa__Hierarchy_Level__c,cscfga__Index__c,cscfga__Product_Definition__c,cscfga__Product_Definition__r.Name, cscfga__Product_Definition__r.product_Specification__c,cssdm__solution_association__r.Name FROM cscfga__Product_Configuration__c  where cssdm__solution_association__c = :solId  ORDER BY cscfga__Product_Definition__r.product_Specification__c ASC];
         for (cscfga__Product_Configuration__c prod :prodConfigList){
             for(cscfga__Attribute__c attr :prod.cscfga__Attributes__r){
                 if(attr.cscfga__Value__c !=null && attr.cscfga__Value__c !=''){
                     pcListupdateNew.add(prod.id);
                 }else{
                     pcListupdate.add(prod.id);
                 }
             }
         
         }
        return pcListupdate;
    }
     public static string cloneOrderEnrichmentRecords(Map<string,string>pcMap){
      Map <string,string>returnMap=new Map<string,string>();
      string response='';
      try{
       
        list<Order_Enrichment__c>OrderListupdate =new list<Order_Enrichment__c>();
        list<Order_Enrichment__c>orderEnrichmentList=[select id,Product_Definition_Name__c,Product_Configuration__c,Attribute1__c,Attribute2__c,Attribute3__c,Attribute4__c,Attribute5__c,Attribute6__c,Attribute7__c,Attribute8__c,Attribute9__c,Attribute10__c,Attribute11__c,Attribute12__c,Attribute13__c,Attribute14__c,Attribute15__c,Attribute16__c,Attribute17__c,Product_Basket__c from Order_Enrichment__c where Product_Configuration__c IN :pcMap.keySet()];
         for (Order_Enrichment__c orderEnrich :orderEnrichmentList){
             Order_Enrichment__c ord=new Order_Enrichment__c();
             ord=orderEnrich.clone(false,false,false,false);
             system.debug(pcMap.get(orderEnrich.Product_Configuration__c));
             ord.Product_Configuration__c=pcMap.get((String.valueof(orderEnrich.Product_Configuration__c)).substring(0,15));
             OrderListupdate.add(ord);
         }
         if(!OrderListupdate.isEmpty()){
             insert OrderListupdate;
             response= 'Sucesss';
         }
      }catch(exception Ex){
        response= Ex.getmessage();
      }
        return response;
    }

}