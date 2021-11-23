/*************************************************************************************************************************************************
 * Name         :  BasketOpportunityUpdateHelper
 * Description  :  To update Opportunity fields - StageName, Amount, Basket Redemption Amount, Last Basket Sync
 *                 This class is called from ProductBasketTriggerHandler, InflightProductUtilityForModular. 

    Sr.No.  Developer Name      Date            Story           Description
    1.      Pooja Bhat          23/09/2020      EDGE-178203     Technical Refactoring - Opportunity Sync - DML Operations
    2.      Pooja Bhat          15/10/2020      EDGE-181579     Technical Refactoring - Enable Number Reservation for 500 configurations for Adaptive Mobility
    3.      Payal Popat         02/12/2020      EDGE-192400     Added Product type check along with profile in the else if condition for fixing the issue
    4.      Pooja Bhat          22/12/2020      EDGE-195956     Fix to: Case Number 326053
    5.      Gokul/Pooja         01/02/2021      EDGE-192806     In-Flight: Basket to Opportunity line item sync framework enhancements
    6.      Pooja Bhat          17/02/2021      EDGE-204423     Inflight Amend : PD rule updates to support Inflight Amend
**************************************************************************************************************************************************/
public with sharing class BasketOpportunityUpdateHelper {

    /*  
    * Method Name   :   updateOpportunityDetails
    * Purpose       :   To update opportunity field value from the synced product basket
    * Params        :   map of ProductBasket, set of opportunity ids
    * Return Type   :   void
    * Called from   :   ProductBasketTriggerHandler - methods ______
    */
    public static void updateOpportunityDetails(Map<Id,cscfga__Product_Basket__c> mapSyncedBasket, Set<Id> setOpportunityIds) {
        //Modified as part of EDGE-195956 fix. User to List<User> 
        //To avoid 'List has no rows for assignment to SObject' when Automated User executes the sync process
        List<User> currUser        =   [SELECT Id,Name,Profile.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];  
        String currUserProfileName =   ((!currUser.isEmpty() && currUser.size() > 0) ?  currUser[0].Profile.Name : ''); 

        Map<String,Opportunity> mapOpportunity      =   new Map<String,Opportunity>();
        Map<String,Set<String>> mapOppIdOLIDomains  =   new Map<String,Set<String>>();
        Map<String,Double> mapOppyIdNewRedemptionAmt=   new Map<String,Double>();   
        Set<String> setOppIds = new Set<String>();
        for(Id oppId : setOpportunityIds) { setOppIds.add((String)oppId); }
        Set<String> setBskIds = new Set<String>();
        for(Id basId : mapSyncedBasket.keySet()) { setBskIds.add((String)basId); }
        mapOpportunity.putAll(getOpportunityDetails(setOppIds));
        mapOppIdOLIDomains.putAll(getOpportunityDomain(setOppIds));
        mapOppyIdNewRedemptionAmt.putAll(calculateBasketRedemptionAmount(setBskIds, setOppIds, false));

        for(cscfga__Product_Basket__c oPB : mapSyncedBasket.values()) {
            if(oPB.cscfga__Opportunity__c != null && mapOpportunity.containsKey(oPB.cscfga__Opportunity__c)) {
                Opportunity opp         =   new Opportunity();
                opp                     =   mapOpportunity.get(oPB.cscfga__Opportunity__c);
                String basketStage      =   '';

                if(oPB.csordtelcoa__Basket_Stage__c!='Enriched' && oPB.csordtelcoa__Basket_Stage__c!='Cancelled' && oPB.csordtelcoa__Basket_Stage__c!='Submitted' && oPB.csordtelcoa__Basket_Stage__c!='Draft') {
                    opp.Amount              =   oPB.cscfga__total_contract_value__c;
                    opp.Last_Basket_Sync__c =   System.now();
                }
                
                if(CustomConfigurationOptions__c.getValues('CommercialConfiguration')!=null && oPB.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c){
                    basketStage =   'CommercialConfiguration';
                } else if(CustomConfigurationOptions__c.getValues('Quote')!=null && oPB.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('Quote').Enrichment_Basket_Stage__c) {
                    basketStage =   'Quote';                
                } else if(CustomConfigurationOptions__c.getValues('ContractInitiate')!=null && oPB.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c) {
                    basketStage =   'ContractInitiate'; 
                } else if(CustomConfigurationOptions__c.getValues('ContractAccepted')!=null && oPB.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c) {
                    basketStage =   'ContractAccepted';
                }
                if(String.isNotBlank(basketStage) && String.isNotBlank(currUserProfileName)) {
                    if (opp.Product_Type__c == 'Non Modular' && oPB.Primary_Basket__c && opp.StageName != 'Closed Won' && !(currUserProfileName == 'Sales - Enterprise' || currUserProfileName == 'Sales Manager - Enterprise' || currUserProfileName == 'Sales-Enterprise-Unified')) {
                        opp.StageName = CustomConfigurationOptions__c.getValues(basketStage).Opportunity_Stage__c;
                    } else if (opp.Product_Type__c == 'Modular' && (currUserProfileName == 'Sales - Enterprise' || currUserProfileName == 'Sales Manager - Enterprise' || currUserProfileName == 'Sales-Enterprise-Unified') && opp.StageName == 'Define' && oPB.csordtelcoa__Basket_Stage__c == 'Commercial Configuration') {
                        opp.StageName = CustomConfigurationOptions__c.getValues(basketStage).Opportunity_Stage__c;
                    } else if (!(currUserProfileName == 'Sales - Enterprise' || currUserProfileName == 'Sales Manager - Enterprise' || (opp.Product_Type__c == 'Non Modular' && currUserProfileName == 'Sales-Enterprise-Unified'))) { // added check for Non-Modular product only, to resolve issue EDGE-192400
                        opp.StageName = CustomConfigurationOptions__c.getValues(basketStage).Opportunity_Stage__c;
                    }
                }
                if(opp.Product_Type__c == 'Modular') {
                    if(mapOppyIdNewRedemptionAmt.containsKey(opp.Id) && opp.Basket_Redemption_amount__c != mapOppyIdNewRedemptionAmt.get(opp.Id)) {
                        opp.Basket_Redemption_amount__c =  mapOppyIdNewRedemptionAmt.get(opp.Id);
                    } 
                    if(mapOppIdOLIDomains.containsKey(opp.Id)) { // START: EDGE-181579
                        opp.Domain__c   =   (mapOppIdOLIDomains.get(opp.Id).size() == 1 ? 'Single' : 'Multi');
                    } // END: EDGE-181579 
                }
                mapOpportunity.put(opp.Id,opp);            
            }
        }

        if(!mapOpportunity.isEmpty()) {
            update mapOpportunity.values();
        } 
    }   //End of updateOpportunityDetails()


    public static List<Opportunity> updateOppOnInflightSync(Map<String,cscfga__Product_Basket__c> mapSyncedBasket, Set<String> setOpportunityIds) {        
        List<Opportunity> lstOpportunities              =   new List<Opportunity>();
        Map<String,Set<String>> mapOppIdOLIDomains      =   new Map<String,Set<String>>();
        Map<String,Double> mapOppyIdNewRedemptionAmt    =   new Map<String,Double>();         
        mapOppIdOLIDomains.putAll(getOpportunityDomain(setOpportunityIds));
        mapOppyIdNewRedemptionAmt.putAll(calculateBasketRedemptionAmount(mapSyncedBasket.keyset(), setOpportunityIds, true));
        for(cscfga__Product_Basket__c oPB : mapSyncedBasket.values()) {
            if(oPB.cscfga__Opportunity__c != null) {
                Opportunity opp         =   new Opportunity();
                opp.Id                  =   oPB.cscfga__Opportunity__c;
                opp.Amount              =   oPB.cscfga__total_contract_value__c;
                opp.Last_Basket_Sync__c =   System.now();
                opp.StageName           =   Label.Opp_Stage_ClosedWon;

                if(mapOppyIdNewRedemptionAmt.containsKey(opp.Id) && opp.Basket_Redemption_amount__c != mapOppyIdNewRedemptionAmt.get(opp.Id)) {
                    opp.Basket_Redemption_amount__c =  mapOppyIdNewRedemptionAmt.get(opp.Id);
                } 
                
                if(mapOppIdOLIDomains.containsKey(opp.Id)) { // START: EDGE-181579
                    opp.Domain__c   =   (mapOppIdOLIDomains.get(opp.Id).size() == 1 ? 'Single' : 'Multi');
                } // END: EDGE-181579 
                lstOpportunities.add(opp);    
            }
        }
        return lstOpportunities;
    } //End: EDGE-192806

    public static Map<String,Opportunity> getOpportunityDetails(Set<String> setOpportunityIds) {
        Map<String,Opportunity> mapOpportunity  =   new Map<String,Opportunity>();
        List<Opportunity> opportunityList   =   [SELECT Id,StageName,Amount,Domain__c,Basket_Redemption_amount__c,
                                                Last_Basket_Sync__c,Product_Type__c 
                                                FROM Opportunity 
                                                WHERE Id IN: setOpportunityIds AND StageName != 'Closed Won'];
        for(Opportunity oOppy: opportunityList) {
            mapOpportunity.put(oOppy.Id,oOppy);
        }
        return mapOpportunity;
    }

    public static Map<String,Set<String>> getOpportunityDomain(Set<String> setOpportunityIds) {
        //Start: EDGE-181579 ==> High Volume Basket with 2000+ Subcription execution of Flow:Verify Opportunity Domains causing exception APEX CPU TIME LIMIT EXCEEDED. 
        //Modular Basket Flow:Verify Opportunity Domain logic is handled here.
        Map<String,Set<String>> mapOppIdOLIDomains  =   new Map<String,Set<String>>();
        List<AggregateResult> listOLIAggResult      =   [SELECT Domain__c,OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN:setOpportunityIds AND Product_Status__c = 'Won' GROUP BY Domain__c,OpportunityId];
        if(!listOLIAggResult.isEmpty()) {
            for(AggregateResult aggrResult : listOLIAggResult) {
                Id oppId        =   String.valueOf(aggrResult.get('OpportunityId'));
                String domain   =   String.valueOf(aggrResult.get('Domain__c'));
                if(mapOppIdOLIDomains.containsKey(oppId)) {
                    mapOppIdOLIDomains.get(oppId).add(domain);
                } else {
                    mapOppIdOLIDomains.put(oppId, new Set<String>{domain});
                }             
            }
        }   //END: EDGE-181579
        return mapOppIdOLIDomains;
    }
    

    public static Map<String,Double> calculateBasketRedemptionAmount(Set<String> setBasketIds, Set<String> setOppyIds, Boolean isInflight) {
        Map<String,Double> mapOppyIdRedemptionAmt   =   new Map<String,Double>();
        Set<String> setAllBasketIds                 =   new Set<String>();
        Set<String> setReplacedPCIdRF               =   new Set<String>();
        List<cscfga__Attribute__c> lstAttribute     =   new List<cscfga__Attribute__c>();
        if(isInflight) {
            List<cscfga__Product_Basket__c> basketLst   =   [SELECT Id,cscfga__Opportunity__c,csordtelcoa__Previous_Product_Basket__c 
            FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c IN:setOppyIds AND isCancelled__c=false];
        
            for(cscfga__Product_Basket__c oPB : basketLst) {                
                if(oPB.csordtelcoa__Previous_Product_Basket__c != null) {
                    setAllBasketIds.add(oPB.csordtelcoa__Previous_Product_Basket__c);
                    setAllBasketIds.add(oPB.Id);
                }            
            }
        } else {
            setAllBasketIds.addAll(setBasketIds);
        }
        attributeSelectorHelper attrObj =   new attributeSelectorHelper();
        attrObj.basketIdSet             =   setAllBasketIds;
        lstAttribute                    =   attrObj.attributeCondition('redeemFund');
        for(cscfga__Attribute__c oAttr : lstAttribute) {
            if(oAttr.cscfga__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c!=null) {
                setReplacedPCIdRF.add(oAttr.cscfga__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c);   
            }
        }

        for(cscfga__Attribute__c oAttr : lstAttribute) {
            String pcId         =   (oAttr.cscfga__Product_Configuration__c != null? oAttr.cscfga__Product_Configuration__c : '');
            String oppyId       =   (oAttr.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c!=null ? oAttr.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c : '');
            Decimal rfValue     =   Decimal.valueOf(oAttr.cscfga__Value__c != null ? oAttr.cscfga__Value__c : '0');
            if(!oAttr.cscfga__Product_Configuration__r.Type__c.containsIgnoreCase('Cancel') && !setReplacedPCIdRF.contains(pcId) && String.isNotBlank(oppyId)) {
                if(mapOppyIdRedemptionAmt.containsKey(oppyId) && mapOppyIdRedemptionAmt.get(oppyId)!=null) {
                    mapOppyIdRedemptionAmt.put(oppyId,(rfValue + mapOppyIdRedemptionAmt.get(oppyId)));
                } else {
                    mapOppyIdRedemptionAmt.put(oppyId,rfValue);
                }
            }
        }
        return mapOppyIdRedemptionAmt;
    } //End of calculateBasketRedemptionAmount

}   //End of BasketOpportunityUpdateHelper