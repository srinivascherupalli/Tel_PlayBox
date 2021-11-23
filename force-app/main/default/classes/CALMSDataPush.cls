public with sharing class CALMSDataPush {
    
    
    public void pushData(String BasketId){
        try{
            //get basket information
            cscfga__Product_Basket__c basket = [select Id, cscfga__Opportunity__c, Used_Snapshot_Objects__c from cscfga__Product_Basket__c Where Id = :BasketId limit 1];
            
            
            //get Opportunity information
            Opportunity opp = [select Id, Name, Account.Id,Total_Contract_Value_Calc__c, Account.OwnerId from Opportunity where Id = :basket.cscfga__Opportunity__c limit 1];
            //String oppId = opp.Id;
            
            //get primary contact
            List<OpportunityContactRole> contact = [SELECT Id,ContactId FROM OpportunityContactRole WHERE OpportunityId =: opp.Id AND IsPrimary = true];
            
            String primaryContactId = contact[0].ContactId;
            
            List<sObject> lstSnapshotData = [select Id,OfferName__c ,Quantity, PricebookEntry.Product2.Name, Product_Name__c, cscfga__Attribute__c, cscfga__Attribute__r.cscfga__Product_Configuration__r.Id,cscfga__Attribute__r.OneOffCharge__c,Product2Id,cscfga__Attribute__r.RecurringCharge__c,TotalPrice, cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c from OpportunityLineItem where cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__c =:basketId ];
            system.debug('snapshot data :'+lstSnapshotData +' '+basketId);
            List<Schema.SObjectType> sObjectTypeList = new Schema.SObjectType[] { 
                Apttus__APTS_Agreement__c.SObjectType,
                    Apttus__AgreementLineItem__c.SObjectType,
                    APTPS_Component__c.SObjectType};      
                        
                        CALMSAgreementHeadTerms headterm =  new  CALMSAgreementHeadTerms(opp, lstSnapshotData);
            //CALMSAgreementSchedule schedule = new CALMSAgreementSchedule(opp, lstSnapshotData);
            CALMSAgreementOrderForm orderForm = new CALMSAgreementOrderForm(opp, lstSnapshotData);
            CALMSAgreementKeyFacts keyFacts = new CALMSAgreementKeyFacts(opp, lstSnapshotData);
            CALMSAgreementGeneralTerms generalTerms = new CALMSAgreementGeneralTerms(opp, lstSnapshotData);
            CALMSAgreementLineItem lineitem = new CALMSAgreementLineItem(opp, lstSnapshotData);
            CALMSAgreementLineItemAttribute lineitemattribute = new CALMSAgreementLineItemAttribute(opp, lstSnapshotData);              
            
            
            SObjectUnitOfWork UoW = new SObjectUnitOfWork(sObjectTypeList);
            
            //create a head term record
            system.debug('----- Create head term record -----');
            Apttus__APTS_Agreement__c headtermRecord = headterm.createHeadTermsRecord(BasketId, primaryContactId);
            UoW.registerNew(headtermRecord);
            system.debug('----- head term record registered-----');
            
            //create order form records
            system.debug('----- Create order form record -----'+headtermRecord.Id);
            Apttus__APTS_Agreement__c orderFormRecord = orderForm.createOrderFormRecord(headtermRecord , BasketId, primaryContactId);
            UoW.registerNew(orderFormRecord);
            system.debug('----- order form record registered-----');
            
            UoW.registerRelationship(orderFormRecord, Apttus__APTS_Agreement__c.Apttus__Parent_Agreement__c, headtermRecord);
            
            //create key fcats record
            system.debug('----- Create key facts record -----');
            Apttus__APTS_Agreement__c keyFactsRecord = keyFacts.createKeyFactsRecord(headtermRecord, BasketId, primaryContactId );
            UoW.registerNew(keyFactsRecord);
            system.debug('----- key facts record registered-----');
            
            UoW.registerRelationship(keyFactsRecord, Apttus__APTS_Agreement__c.Apttus__Parent_Agreement__c, headtermRecord);
            
            //create general terms record
            system.debug('----- Create general term record -----');
            Apttus__APTS_Agreement__c generalTermsRecord = generalTerms.createGeneralTermsRecord(headtermRecord, BasketId, primaryContactId );
            UoW.registerNew(generalTermsRecord);
            system.debug('----- general term record registered -----');
            
            //set the relationship for each of child agreement 
            system.debug('----- Create agreement records relationships -----');             
            
            UoW.registerRelationship(generalTermsRecord, Apttus__APTS_Agreement__c.Apttus__Parent_Agreement__c, headtermRecord);
            system.debug('----- relationships for agreement record registered -----');
            
            Map<String, List<sObject>> agreementLineItemsMap = new Map<String, List<sObject>>();
            Map<String, Product2> product2Map = new Map<String, Product2>();
            
            
            system.debug('Opportunity Line Item Data -----> '+lstSnapshotData);
			String offerName;
			List<Product2> product2List = new List<Product2>();
			for(sObject productval : lstSnapshotData){
			offerName = String.valueOf(productval.get('OfferName__c'));
				
			}
			if(offerName != null){
			   product2List = [SELECT Id, Name FROM Product2 WHERE Name =: offerName];
			}
			
            for(sObject product : lstSnapshotData){
                String mapKey = '';            
                String siteAddress = getSiteAddress(String.valueOf(product.getSObject('cscfga__Attribute__r').getSObject('cscfga__Product_Configuration__r').get('cscfga__Parent_Configuration__c')));
                System.debug('ProductOffer:'+product);
               // String offerName = String.valueOf(product.get('OfferName__c'));
                
                system.debug('Offer name :'+offerName);
               // List<Product2> product2List = [SELECT Id, Name FROM Product2 WHERE Name =: offerName];
                System.debug('ProductList:'+product2List);
                
                if(!product2List.isEmpty()){
                    mapKey = product2List[0].Name + ' $ ' +siteAddress;
                    System.debug('Mapkey:'+mapKey);
                }
                
                if(agreementLineItemsMap.containsKey(mapKey)){
                    List<sObject> agreementLineItemAttributes = agreementLineItemsMap.get(mapKey);
                    agreementLineItemAttributes.add(product);
                    agreementLineItemsMap.put(mapKey, agreementLineItemAttributes);
                }else{
                    List<sObject> agreementLineItemAttributes = new List<sObject>();
                    agreementLineItemAttributes.add(product);   
                    agreementLineItemsMap.put(mapKey, agreementLineItemAttributes);
                }
                
                if(!product2List.isEmpty() && !product2Map.containsKey(mapKey)){
                    product2Map.put(mapKey, product2List[0]);
                }
            }
            
            for(String key : agreementLineItemsMap.keySet()){
                Decimal totalOneOff = 0.0;
                Decimal totalRecurring = 0.0;
                
                for(sObject attribute : agreementLineItemsMap.get(key)){
                    totalRecurring = totalRecurring + Decimal.valueOf(String.valueOf(attribute.getSObject('cscfga__Attribute__r').get('RecurringCharge__c')));
                    totalOneOff = totalOneOff + Decimal.valueOf(String.valueOf(attribute.getSObject('cscfga__Attribute__r').get('OneOffCharge__c')));
                }
                
                system.debug('Site :'+key);
                system.debug('Site Address:' + key.substringAfter(' $ '));
                
                System.debug('Product in calmsdatapush:'+product2Map.get(key));
                Apttus__AgreementLineItem__c aliRecord = lineitem.createAgreementLineItemRecord(orderFormRecord, product2Map.get(key), totalRecurring, totalOneOff, key.substringAfter(' $ '));
                UoW.registerNew(aliRecord);
                UoW.registerRelationship(aliRecord, Apttus__AgreementLineItem__c.Apttus__AgreementId__c, orderFormRecord); 
                
                for(sObject attribute : agreementLineItemsMap.get(key)){
                    APTPS_Component__c aliAttrRecord = lineitemattribute.createAgreementLineItemRecord(aliRecord, attribute);
                    UoW.registerNew(aliAttrRecord);  
                    UoW.registerRelationship(aliAttrRecord, APTPS_Component__c.Agreement_Line_Item__c, aliRecord);
                }
            }
            
            UoW.commitWork();
        }catch(Exception e){
            system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
        }
    }
    
    public String getSiteAddress(String productConfigId){
        String siteAddress = '';
        List<csbb__Product_Configuration_Request__c> pcr = [SELECT csbb__Optionals__c FROM csbb__Product_Configuration_Request__c WHERE csbb__Product_Configuration__c =: productConfigId];
        if(!pcr.isEmpty()){
            String json = pcr[0].csbb__Optionals__c;
            
            SiteAddress siteAddressObj = new SiteAddress();
            SiteAddress sites = siteAddressObj.parse(json);
            siteAddress = sites.selectedAddressDisplay;
        }
        return siteAddress;
    }
    
    public class SiteAddress{
        public String selectedAddressDisplay;
        public String hiddenParam1;
        
        public SiteAddress parse(String json) {
            return (SiteAddress) System.JSON.deserialize(json, SiteAddress.class);
        }
    }
}