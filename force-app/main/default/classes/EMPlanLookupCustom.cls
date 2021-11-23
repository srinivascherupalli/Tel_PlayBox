/*********************************************************************************************************************************
Class Name :  EMPlanLookupCustom
Test Class : EMPlanLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.           Mahima Gandhe          5/08/2021       Created with entry plan logic, DIGI-3249
2.           Mahima Gandhe          23/08/2021      fixed mapping of OfferTypeString and bsk_FA_id
**********************************************************************************************************************************/

global with sharing class EMPlanLookupCustom extends cscfga.ALookupSearch {
    public override String getRequiredAttributes()
    { 
        return '["OfferId,OfferTypeString,PlanTypeString,basketId"]';  //PlanTypeString, OfferId, basketId
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        String searchQuery;
        String offerId='';
        String basketId='';
        String planTypeString='';
        String offerTypeString='';
        //Added null check searchFields !=null by Aman Soni as a part of EDGE-154026
        system.debug('searchFields==>'+searchFields);
        if(searchFields !=null){
         offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
         basketId = searchFields.get('basketId') != null ? searchFields.get('basketId') : '';
         planTypeString = searchFields.get('PlanTypeString') != null ? searchFields.get('PlanTypeString') : ''; 
         offerTypeString= searchFields.get('OfferTypeString') != null ? searchFields.get('OfferTypeString') : ''; 
         system.debug('offerId==>'+offerId);
         system.debug('basketId==>'+basketId);
         system.debug('planTypeString==>'+planTypeString);
         system.debug('offerTypeString==>'+offerTypeString);
        }
         string bsk_FA_id='';
         List<cspmb__Price_Item__c> CommercialProductsList = new List<cspmb__Price_Item__c>();
        List<cscfga__Product_Basket__c> lstbskid=[select csconta__Frame_Agreement__c from cscfga__Product_Basket__c where id=:basketId LIMIT 1];
       if(lstbskid!= null && lstbskid.size()>0)
       {bsk_FA_id=lstbskid[0].csconta__Frame_Agreement__c;}
       system.debug('bsk_FA_id==>'+bsk_FA_id);
       if(bsk_FA_id!= null){
            List<cspmb__Pricing_Rule_Group_Rule_Association__c> PRAList=[select id,cspmb__pricing_rule__c from cspmb__Pricing_Rule_Group_Rule_Association__c where cspmb__pricing_rule_group__r.csconta__Frame_Agreement__c=:bsk_FA_id];   
            List<string> PRAIDs= new List<string>();
            for(cspmb__Pricing_Rule_Group_Rule_Association__c PRA:PRAList){PRAIDs.add(PRA.cspmb__pricing_rule__c); }     
           List<cspmb__Price_Item_Pricing_Rule_Association__c> lstCPPRA= new List<cspmb__Price_Item_Pricing_Rule_Association__c>();
           if (String.isNotBlank(offerId)) {
            if (String.isNotBlank(planTypeString))  
            {
            lstCPPRA=[select Name, cspmb__price_item__r.id, cspmb__price_item__r.Offer_Type__c,cspmb__price_item__r.Plan__c,cspmb__price_item__r.cspmb__Is_Active__c,cspmb__price_item__r.Check_todays_date__c,cspmb__price_item__r.type__c,cspmb__price_item__r.cspmb__Price_Item_Code__c, cspmb__price_item__r.Commercial_Product_Code__c, cspmb__price_item__r.Offer_Id__c,cspmb__price_item__r.ProdSpecId__c,cspmb__price_item__r.Offer__c,cspmb__price_item__r.BYO__c, cspmb__price_item__r.Frequency__c,
            cspmb__price_item__r.taxTreatment__c,cspmb__price_item__r.Unit_Of_Measure__c,cspmb__price_item__r.Billing_Description__c,cspmb__price_item__r.Plan_Type__c, cspmb__price_item__r.name,cspmb__price_item__r.cspmb__recurring_charge__c,cspmb__price_item__r.cspmb__one_off_charge__c,cspmb__price_item__r.specId__c,cspmb__price_item__r.Charge_Id__c,cspmb__price_item__r.External_Id__c,cspmb__price_item__r.Sale_Eligibility__c from cspmb__Price_Item_Pricing_Rule_Association__c where cspmb__pricing_rule__c in: PRAIDs and cspmb__price_item__r.Sale_Eligibility__c='Invite Only' and cspmb__price_item__r.Check_todays_date__c = true 
            and cspmb__price_item__r.Plan__c  != null and cspmb__price_item__r.Offer_Id__c = :offerId and cspmb__price_item__r.Type__c = :planTypeString];           
            system.debug('lstCPPRA1==>'+lstCPPRA);
            }
            else 
            {
             lstCPPRA=[select Name, cspmb__price_item__r.id, cspmb__price_item__r.Offer_Type__c,cspmb__price_item__r.Plan__c,cspmb__price_item__r.cspmb__Is_Active__c,cspmb__price_item__r.Check_todays_date__c,cspmb__price_item__r.type__c,cspmb__price_item__r.cspmb__Price_Item_Code__c, cspmb__price_item__r.Commercial_Product_Code__c, cspmb__price_item__r.Offer_Id__c,cspmb__price_item__r.ProdSpecId__c,cspmb__price_item__r.Offer__c,cspmb__price_item__r.BYO__c, cspmb__price_item__r.Frequency__c,cspmb__price_item__r.taxTreatment__c,cspmb__price_item__r.Unit_Of_Measure__c,cspmb__price_item__r.Billing_Description__c,cspmb__price_item__r.Plan_Type__c,cspmb__price_item__r.name,cspmb__price_item__r.cspmb__recurring_charge__c,cspmb__price_item__r.cspmb__one_off_charge__c,cspmb__price_item__r.specId__c,cspmb__price_item__r.Charge_Id__c,cspmb__price_item__r.External_Id__c,cspmb__price_item__r.Sale_Eligibility__c from cspmb__Price_Item_Pricing_Rule_Association__c where cspmb__pricing_rule__c in: PRAIDs and cspmb__price_item__r.Sale_Eligibility__c='Invite Only' and cspmb__price_item__r.Check_todays_date__c = true 
             and cspmb__price_item__r.Plan__c  != null and cspmb__price_item__r.Offer_Id__c = :offerId];
             system.debug('lstCPPRA2==>'+lstCPPRA);
            }
            for (cspmb__Price_Item_Pricing_Rule_Association__c cppra : lstCPPRA)
            {
                CommercialProductsList.add(cppra.cspmb__Price_Item__r);             
            }            
          }
        }
        system.debug('CommercialProductsList==>'+CommercialProductsList);
        Model_PriceItem mdPI = new Model_PriceItem();
        system.debug('planTypeString==>'+planTypeString);
        searchQuery = mdPI.getPlanString(offerId, planTypeString);
        searchQuery=searchQuery +' AND Sale_Eligibility__c =\'Standard\'';
        system.debug('searchQuery==>'+searchQuery);
        List<cspmb__Price_Item__c> lstplans = new List<cspmb__Price_Item__c>();
        if(String.isNotBlank(searchQuery)){
            lstplans = Database.query(searchQuery);
        }
        CommercialProductsList.addAll(lstplans);
        system.debug('CommercialProductsList2==>'+CommercialProductsList);
        //Added by Aman Soni as a part of EDGE-154026 || End
        List<cspmb__Price_Item__c> distinctManufacturerList = new List<cspmb__Price_Item__c>();
        if(CommercialProductsList.size()>0){
          distinctManufacturerList = getUniqueListByField(CommercialProductsList, 'Plan__c');
        }       
        system.debug('distinctManufacturerList==>'+distinctManufacturerList);
        
        return distinctManufacturerList;

    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Plan__c' && !itemMap.containsKey(item.Plan__c)) {
                itemMap.put(item.Plan__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }

}