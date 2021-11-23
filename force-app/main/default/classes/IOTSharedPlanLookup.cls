/**================================================================
 * Name: IOTSharedPlanLookup
 * Test Class:IOTSharedPlanLookupTest
 * DIGI-5706
 * Description: Class implemented for custom lookup config in IOT plans to show shared plans in ascending order
 * Created By: Pawan Singh
 ==================================================================*/


global with sharing class IOTSharedPlanLookup extends cscfga.ALookupSearch {
    public class planCompare implements Comparable {
    
        private  Map<String, Integer> ordering = new Map<String, Integer>{
            'KB' => 1,
            'MB' => 2,
            'GB' => 3,
            'TB' => 4
            };
    
            public String planString {get;  set;}
            public List<String> splitPlanList;  
           
    
            public planCompare(String plan) {
                this.planString = plan;
                this.splitPlanList =  plan.trim().split(' '); 
            }
            
            public Integer compareTo(Object objToCompare) {
                planCompare otherPlan = (planCompare) objToCompare;
    
                if (this.ordering.get(this.splitPlanList[1]) == this.ordering.get(otherPlan.splitPlanList[1]))
                    return Integer.valueof(this.splitPlanList[0]) - Integer.valueof(otherPlan.splitPlanList[0]);
                else
                    return this.ordering.get(this.splitPlanList[1]) - this.ordering.get(otherPlan.splitPlanList[1]);
            }
    }

   
    public override String getRequiredAttributes(){ 
        return '["OfferId","SelectPlanName","OfferTypeString"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit){
      
        String searchQuery;
        String offerId='';
        String selectPlanName='';
        String offerTypeString='';

        if(searchFields !=null){
            offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
            selectPlanName = searchFields.get('SelectPlanName') != null ? searchFields.get('SelectPlanName') : '';
            offerTypeString= searchFields.get('OfferTypeString') != null ? searchFields.get('OfferTypeString') : ''; 
        }

        Model_PriceItem mdPI = new Model_PriceItem();
        searchQuery = mdPI.getPlanType(offerId, offerTypeString);
        searchQuery=searchQuery +' AND Plan_Type__c =:selectPlanName';

        List<cspmb__Price_Item__c> lstplans = new List<cspmb__Price_Item__c>();
        if(String.isNotBlank(searchQuery)){
            lstplans = Database.query(searchQuery);
        }

        System.debug(lstplans);

        List<cspmb__Price_Item__c> distinctPlansList = new List<cspmb__Price_Item__c>();
        if(lstplans.size()>0){
            distinctPlansList = getSortedListByField(lstplans, 'Plan__c');
        }        
        return distinctPlansList;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getSortedListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        List<planCompare> wrapperClassCompare = new List<planCompare>();
        List<cspmb__Price_Item__c> sortedPlanList = new List<cspmb__Price_Item__c>();

        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Plan__c' && !itemMap.containsKey(item.Plan__c)) {
                itemMap.put(item.Plan__c, item);
                planCompare planInstances = new PlanCompare(item.Plan__c);
                wrapperClassCompare.add(planInstances);
            }
        }
        wrapperClassCompare.sort();

        for(planCompare plan: wrapperClassCompare){
            sortedPlanList.add(itemMap.get(plan.planString));
        }
        
        return sortedPlanList;
    }
       
    
}