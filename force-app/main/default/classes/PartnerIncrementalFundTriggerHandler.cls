/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   01/06/2020
Jira                :   P2OB-6797
Desc                :   This class is called from PartnerIncrementalFundTrigger to upsert budget allocation records
***********************************************************************/
public without sharing class PartnerIncrementalFundTriggerHandler{
    private static final String REQUEST_STATUS_APPROVED = 'Approved';
    private static final String REQUEST_TITLE = ' Request';
    private static Map<String, PartnerMarketingBudget> budgetMap;
    private static Map<String, PartnerFundAllocation> partnerFundAllocationMap;
    private static Map<String, PartnerFundRequest> partnerFundRequestMap;
    private static final String ALLOCATION_EXTERNAL_ID_FIELD = 'Allocation_External_Id__c';
    private static final String ALLOCATION_REQUEST_EXTERNAL_ID_FIELD = 'Allocation_Request_External_Id__c';
    private static String requestActivityType; 
    static{
        PRM_Funds_Management__c prmSetting = PRM_Funds_Management__c.getInstance();
        requestActivityType =  prmSetting != null && !String.isEmpty(prmSetting.Fund_Request_Activity_Type__c) ? prmSetting.Fund_Request_Activity_Type__c : 'Partners'; // if setting does not contain any value then setting default
    }
    /* Before Insert*/
    public static void beforeInsert(List<Partner_Incremental_Fund_Allocation__c> partnerIncFundAllocations){
        upsertAllocationRecords(partnerIncFundAllocations);
    }
    /* create or update Fund Allocation Record */
    private static void upsertAllocationRecords(List<Partner_Incremental_Fund_Allocation__c> partnerIncFundAllocations){
        Set<String> dealerCodes = new Set<String>(); 
        Set<String> fySet = new Set<String>();
        Map<String,Partner_Incremental_Fund_Allocation__c> partnerIncrementalFundMap = new  Map<String,Partner_Incremental_Fund_Allocation__c>();
        budgetMap = new Map<String, PartnerMarketingBudget>();
        partnerFundAllocationMap = new Map<String, PartnerFundAllocation>();
        partnerFundRequestMap = new Map<String, PartnerFundRequest>();
        // loop over Incremental Fund and prepare Dealer code , FY set 
        for(Partner_Incremental_Fund_Allocation__c pif : partnerIncFundAllocations){
           if(pif.Dealer_Code__c != null && pif.Financial_Year__c != null && pif.Amount__c != null){
                pif.Dealer_Code__c =  pif.Dealer_Code__c.toUpperCase();
                pif.Financial_Year__c = pif.Financial_Year__c.toUpperCase();
                dealerCodes.add(pif.Dealer_Code__c);
                fySet.add(pif.Financial_Year__c);
                partnerIncrementalFundMap.put(pif.Dealer_Code__c + pif.Financial_Year__c,pif);
            }
        }
        if(!dealerCodes.isEmpty() && !fySet.isEmpty()){
            // get existing Fund Allocation and budget records 
            getExistingBudgetAndFundAllocation(dealerCodes,fySet,partnerIncrementalFundMap);
            mapIncremaentalFundWithAllocation(partnerIncFundAllocations);
            // update Budget and Fund Allocation Record
            if(!budgetMap.isEmpty()){
                Database.SaveResult[] fundBudgetResult = Database.update(budgetMap.values(), false);
                Database.UpsertResult[] fundAllocationUpsertList = Database.upsert(partnerFundAllocationMap.values(), false);
                System.debug('::fundAllocationUpsertList'+fundAllocationUpsertList);
                addErrorAndPopulateIncrementalRecord(partnerFundAllocationMap, fundAllocationUpsertList,partnerIncrementalFundMap, ALLOCATION_EXTERNAL_ID_FIELD, true);
            }
            // update Budget and Fund Reqeust Record
            if(!partnerFundRequestMap.isEmpty()){
                Schema.SObjectField extId = PartnerFundRequest.Fields.Allocation_Request_External_Id__c;
                Database.UpsertResult[] fundAllocationRequestUpsertList = Database.upsert(partnerFundRequestMap.values(), extId , false);
                System.debug('::fundAllocationRequestUpsertList'+fundAllocationRequestUpsertList);
                addErrorAndPopulateIncrementalRecord(partnerFundRequestMap, fundAllocationRequestUpsertList,partnerIncrementalFundMap, ALLOCATION_REQUEST_EXTERNAL_ID_FIELD, false);
           }
        }
    }
    /* get Existing Budget and Fund Allocation */
    private static void getExistingBudgetAndFundAllocation(Set<String> dealerCodes, Set<String> fySet, Map<String,Partner_Incremental_Fund_Allocation__c> partnerIncrementalFundMap){
        for(PartnerMarketingBudget pmb : [select id , Title ,Amount, Financial_Year__c,(Select id, Amount, ChannelPartnerId, ChannelPartner.Partner_Code__c,BudgetId,Allocation_External_Id__c,Financial_Year__c from PartnerFundAllocations where ChannelPartner.Partner_Code__c in : dealerCodes AND Financial_Year__c in :fySet AND Allocation_External_Id__c != null) from PartnerMarketingBudget where Financial_Year__c != null AND Financial_Year__c in : fySet]){
                budgetMap.put(pmb.Financial_Year__c, pmb);
                for(PartnerFundAllocation pfa : pmb.PartnerFundAllocations){
                    if(partnerIncrementalFundMap.containsKey(pfa.Allocation_External_Id__c)){
                        pfa.Amount += partnerIncrementalFundMap.get(pfa.Allocation_External_Id__c).Amount__c;
                        budgetMap.get(pfa.Financial_Year__c).Amount += partnerIncrementalFundMap.get(pfa.Allocation_External_Id__c).Amount__c;
                        if(partnerIncrementalFundMap.get(pfa.Allocation_External_Id__c).Channel_Partner__c  == null){
                            partnerIncrementalFundMap.get(pfa.Allocation_External_Id__c).Channel_Partner__c = pfa.ChannelPartnerId;
                        }
                        partnerFundAllocationMap.put(pfa.Allocation_External_Id__c,pfa);
                        partnerFundRequestMap.put(pfa.Allocation_External_Id__c, createPartnerFundRequest(partnerIncrementalFundMap.get(pfa.Allocation_External_Id__c), budgetMap.get(pfa.Financial_Year__c).Id, pfa.Id, pfa.ChannelPartnerId, pfa.Amount));
                    }
                }
            }
    }
   /* map Incremental fund with Partner Fund Allocation */ 
    private static void mapIncremaentalFundWithAllocation(List<Partner_Incremental_Fund_Allocation__c> partnerIncFundAllocations){
            for(Partner_Incremental_Fund_Allocation__c pif : partnerIncFundAllocations){
                // check Fund Allocation found or not 
                if(pif.Dealer_Code__c != null && pif.Financial_Year__c != null && pif.Amount__c != null && !partnerFundAllocationMap.containsKey(pif.Dealer_Code__c + pif.Financial_Year__c)){
                    if(budgetMap.containsKey(pif.Financial_Year__c)){
                       budgetMap.get(pif.Financial_Year__c).Amount += pif.Amount__c;
                       // create new fund allocation 
                       partnerFundAllocationMap.put(pif.Dealer_Code__c + pif.Financial_Year__c, createPartnerFundAllocation(pif,budgetMap.get(pif.Financial_Year__c).Id));
                       // create Fund Request
                       partnerFundRequestMap.put(pif.Dealer_Code__c + pif.Financial_Year__c, createPartnerFundRequest(pif, budgetMap.get(pif.Financial_Year__c).Id, pif.Partner_Fund_Allocation__c, pif.Channel_Partner__c, pif.amount__c));
                    }else{
                        pif.addError(Label.PRM_Budget_Not_Found.replace('{0}', pif.Financial_Year__c));
                    }
                }
            } // end Trigger.new
     }
    /* create Partner Fund Allocation */
    private static PartnerFundAllocation createPartnerFundAllocation(Partner_Incremental_Fund_Allocation__c pif, String budgetId){
        return new PartnerFundAllocation(title =  pif.Dealer_Code__c + ' ' + pif.Financial_Year__c , Financial_Year__c = pif.Financial_Year__c,Amount = pif.Amount__c,  
                                         Allocation_External_Id__c= pif.Dealer_Code__c + pif.Financial_Year__c, ChannelPartnerId = pif.Channel_Partner__c, BudgetId = budgetId);
     }
     /* create Partner Fund Request */
     private static PartnerFundRequest createPartnerFundRequest(Partner_Incremental_Fund_Allocation__c pif,String budgetId, String allocationId, String channelPartnerId, Decimal amount){
        return new PartnerFundRequest(title =  pif.Dealer_Code__c + ' ' + pif.Financial_Year__c + REQUEST_TITLE , budgetId = budgetMap.get(pif.Financial_Year__c).Id,ChannelPartnerId = channelPartnerId, 
                                      AllocationId = allocationId, Allocation_Request_External_Id__c = pif.Dealer_Code__c + pif.Financial_Year__c,
                                      Financial_Year__c = pif.Financial_Year__c,
                                      RequestedAmount =  amount, Amount = amount, Status = REQUEST_STATUS_APPROVED, Activity = requestActivityType);
    }
    /* add error if Fund Allocation failed and populate new fund on Partner Incremental Fund Allocation */
    private static void addErrorAndPopulateIncrementalRecord(Map<String, Sobject> sobjectMap, Database.UpsertResult[] upsertResults, Map<String,Partner_Incremental_Fund_Allocation__c> partnerIncrementalFundMap, String fieldName, Boolean isFundAllocation){
        List<Sobject> sobjectList = sobjectMap.values();
        for(Integer i = 0; i < upsertResults.size(); i++){
            Database.UpsertResult result =  upsertResults[i];
            if(!result.isSuccess()){
                Database.Error[] errors = result.getErrors();
                if(sobjectList[i].get(fieldName) != null && partnerIncrementalFundMap.containsKey((String)sobjectList[i].get(fieldName))){
                    partnerIncrementalFundMap.get((String)sobjectList[i].get(fieldName)).addError(result.getErrors()[0].getMessage());
                }
                if(isFundAllocation && partnerFundRequestMap.containsKey((String)sobjectList[i].get(fieldName))){
                    partnerFundRequestMap.remove((String)sobjectList[i].get(fieldName)); 
                }
            }else if(isFundAllocation && sobjectList[i].get(fieldName) != null){
                // populate Partner Fund Allocation on Incremental record 
                if(partnerIncrementalFundMap.containsKey((String)sobjectList[i].get(fieldName))){
                    partnerIncrementalFundMap.get((String)sobjectList[i].get(fieldName)).Partner_Fund_Allocation__c = result.getId();
                }
                // populate Partner Fund Allocation on Request record 
                if(partnerFundRequestMap.containsKey((String)sobjectList[i].get(fieldName))){
                    partnerFundRequestMap.get((String)sobjectList[i].get(fieldName)).AllocationId = result.getId(); 
                }
            }
        }
    }
}