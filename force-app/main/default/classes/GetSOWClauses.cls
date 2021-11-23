/**************************************************************************************************************
Name          : GetSOWClauses
Created By    : Purushottam Sahu
Created Date  : Sep 23 2019
Description   : EDGE-108286 - Create SOW ,SOW Items
-------
History                                                            
-------                                                            
VERSION     AUTHOR             DATE            DETAIL                   
-------     ------             -----           ---------                 
1.1         Purushottam        23-09-2019      EDGE-108286: Created
**************************************************************************************************************/
public with sharing class GetSOWClauses {
	@TestVisible
    private class Relationship {
        private SObject Record;
        private Schema.sObjectField RelatedToField;
        private SObject RelatedTo;
        public Relationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo) {
            this.Record = record;
            this.RelatedToField = relatedToField;
            this.RelatedTo = relatedTo;
        }
        public void resolve(){
            this.Record.put( this.RelatedToField, this.RelatedTo.Id);
        }
    }

    public List<SOW__c> loadSOWClauses(Map<String,List<Clauses__c>> offerClauseMapping,Map<String,cscfga__Product_Configuration__c> productConfigurationDetails){
        List<SOW__c> sowList = new List<SOW__c>();
        List<SOW_Items__c> sowItemList = new List<SOW_Items__c>();
        List<GetSOWClauses.Relationship> relationShip = new List<GetSOWClauses.Relationship>();
        List<Schema.FieldSetMember> obligationFields = SObjectType.Clauses__c.fieldSets.SOW_Clause.getFields();
        Set<String> offerIdset=offerClauseMapping.keySet();
		Map<String,string> offerReviewerMap= new Map<String,string>();
        for (Master_Clauses__c masterclause:[select Offer_Id__c,Reviewer__c from Master_Clauses__c where Offer_Id__c in :offerIdset]){
            offerReviewerMap.put(masterclause.Offer_Id__c,masterclause.Reviewer__c);
        }
        Savepoint sp = Database.setSavepoint();
        for(String offerId : productConfigurationDetails.keySet()){
            if(offerClauseMapping.containsKey(offerId)){
                cscfga__Product_Configuration__c productConfiguration = productConfigurationDetails.get(offerId);
                SOW__c sow = new SOW__c();
                sow.name = productConfiguration.Marketable_Offer__r.Name;
                sow.Offer_Id__c = productConfiguration.Marketable_Offer__r.Offer_ID__c;
                sow.Reviewer__c = offerReviewerMap.get(offerId);
                sow.Account__c=productConfiguration.cscfga__Product_Basket__r.cscfga__Opportunity__r.AccountId;
                sow.Opportunity__c = productConfiguration.cscfga__Product_Basket__r.cscfga__Opportunity__c;
                sow.Basket__c = productConfiguration.cscfga__Product_Basket__c;
                for(Clauses__c sowClause : offerClauseMapping.get(offerId)){
                    SOW_Items__c sowItem = new SOW_Items__c();
                    relationShip.add(new Relationship(sowItem,SOW_Items__c.sow__c,sow));
                    sowItem.name=sowClause.name;
                    for(Schema.FieldSetMember fieldAPI :  obligationFields) {
                        sowItem.put(fieldAPI.getFieldPath(),sowClause.get(fieldAPI.getFieldPath()));
                    }
                    sowItemList.add(sowItem);
                }
                sowList.add(sow);
            }
        }
        try{
            if(!sowList.isEmpty()){
                insert sowList;
            }
            resolveRelationShip(relationShip);
            if(!sowItemList.isEmpty()){
                insert sowItemList;
            }
        } catch(DmlException dmlException){
            Database.rollback(sp);
            return null;
        }
        return sowList;
    }

    private void resolveRelationShip(List<Relationship> realtionRelationships){
        for(Relationship relationship : realtionRelationships){
            relationship.resolve();
        }
    }

    public Map<String,List<Clauses__c>> loadMarketableOfferClause(Set<String> offerIds){
        Map<String,List<Clauses__c>> offerSOWClauseMapping = new Map<String,List<Clauses__c>>();
        String sowClausesFields = 'SELECT ' +SObjectHelper.getFieldListForSOQL('Clauses__c') + ', (SELECT Active__c,Id,MasterItems__r.Offer_Id__c FROM Clauses_Junction__r WHERE Active__c=true and MasterItems__r.Offer_Id__c IN :offerIds) FROM Clauses__c WHERE ParentId__c = null';
        List<Clauses__c> sowClauses = (List<Clauses__c>) Database.query(sowClausesFields);
        for(Clauses__c sowClause : sowClauses){
            for(Clauses_Junction__c junction : sowClause.Clauses_Junction__r){
                if(offerSOWClauseMapping.get(junction.MasterItems__r.Offer_Id__c) == null){
                    offerSOWClauseMapping.put(junction.MasterItems__r.Offer_Id__c, new List<Clauses__c>{sowClause});
                } else {
                    offerSOWClauseMapping.get(junction.MasterItems__r.Offer_Id__c).add(sowClause);
                }
            }
        }
        return offerSOWClauseMapping;
    }

    public Map<String,cscfga__Product_Configuration__c> getProfessionalServiceConfiguration(String basketId){
        Map<String,cscfga__Product_Configuration__c> productConfigurationDetails = new Map<String,cscfga__Product_Configuration__c>();
        List<cscfga__Product_Configuration__c> productConfigurationsList = new List<cscfga__Product_Configuration__c>();
        for(cscfga__Product_Configuration__c productConfiguration : [SELECT Id,cscfga__Product_Basket__r.cscfga__Opportunity__c,cscfga__Product_Basket__r.cscfga__Opportunity__r.AccountId,cscfga__Product_Basket__c,Marketable_Offer__r.Offer_ID__c,Marketable_Offer__r.Name
                    FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId and Marketable_Offer__r.type__c = 'Professional Service']){
            productConfigurationDetails.put(productConfiguration.Marketable_Offer__r.Offer_ID__c,productConfiguration);
        }
        return productConfigurationDetails;
    }

}