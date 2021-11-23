/*
* AUTHOR : Prashant
* TEAM: Napier
* DESCRIPTION : Class that contains logic for putting validation on New OneFund record creation as per EDGE-124394
*/



public with sharing class ValidationForCIDNAndBillingAccount {
    public static id committedRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
    public static id flexibleRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
    
    public static void validateCIDN(List<OneFund__c> newOneFunds){
        
        set<ID> flexiAccountIds = new set<ID>();
        set<ID> billingAccountIdSet = new set<ID>();
        set<ID> committedScenarioAccountSet = new set<ID>();
        set<ID> committedAccountHybridIds = new set<ID>();
        set<ID> committedBillingAccountIds = new set<ID>();
        list<oneFund__c> FlexCIDNList = new list<oneFund__c>();    
        list<oneFund__c> HybridCIDNList = new list<oneFund__c>();
        list<oneFund__c> CommittedCIDNList = new list<oneFund__c>();
        list<oneFund__c> CommittedBAList = new list<oneFund__c>();
        list<Billing_Account__c> billingAccountList = new list<Billing_Account__c>();
        list<Billing_Account__c> CIDNFromBillingAccount = new list<Billing_Account__c>();
        
        for(OneFund__c newOneFund: newOneFunds){ 
            //Flexible Record Type 
            if(newOneFund.RecordTypeId == flexibleRecId ){
                flexiAccountIds.add(newOneFund.CIDN__c);
            }
            else if(newOneFund.RecordTypeId ==committedRecId ){
                //Committed Record Type- Hybrid Scenario
                 if (newOneFund.Committed_OneFund_tied_to__c == 'CIDN'){
                    committedAccountHybridIds.add(newOneFund.CIDN__c);
                }
                //Committed Record Type- Committed Scenario
                else if(newOneFund.Committed_OneFund_tied_to__c == 'Billing Account'){
                    committedScenarioAccountSet.add(newOneFund.CIDN__c);
                    committedBillingAccountIds.add(newOneFund.Billing_Account__c);
                }
            }
        }
        if(committedScenarioAccountSet != null && !committedScenarioAccountSet.isEmpty()){
            
            //billingAccountList = [select id from Billing_Account__c where Account__c IN : committedAccountHybridIds]; 
            CommittedCIDNList = [select ID ,CIDN__c 
                              from OneFund__c 
                              where OneFund_Status__c= 'Active'
                              And recordtypeid = :committedRecId	
                              AND Committed_OneFund_tied_to__c = 'CIDN'
                              AND CIDN__c IN : committedScenarioAccountSet
                                  ];
        }
        if(CommittedCIDNList != null && CommittedCIDNList.size()>0){
            for(OneFund__c newOneFund: newOneFunds){
                for (OneFund__c cidnList: CommittedCIDNList)
                {
                    if(cidnList.CIDN__c == newOneFund.CIDN__c) {
                        newOneFund.addError(System.Label.Committed_Error);
                    }     
                }
            }
        }
        else {
            // Validation Logic For Committed Record Type- Committed Scenario
            if(committedBillingAccountIds != null && !committedBillingAccountIds.isEmpty()){
                CIDNFromBillingAccount = [select Account__c from Billing_Account__c where ID IN : committedBillingAccountIds];
                for(Billing_Account__c billingAccount: CIDNFromBillingAccount){
                    billingAccountIdSet.add(billingAccount.Account__c);
                }
                
                CommittedBAList = [select ID ,CIDN__c, Billing_Account__c 
                                   from OneFund__c 
                                   where OneFund_Status__c= 'Active'
                                   And recordtypeid = :committedRecId	
                                   AND (Billing_Account__c IN : committedBillingAccountIds
                                        OR CIDN__C IN :billingAccountIdSet)];
            }
            if(CommittedBAList != null && CommittedBAList.size()>0){
                for(OneFund__c newOneFund: newOneFunds){
                    for (OneFund__c cbList: CommittedBAList)
                    {
                        if(cbList.Billing_Account__c == newOneFund.Billing_Account__c) {
                            newOneFund.addError(System.Label.Committed_Error);
                        }     
                    }
                }
            }
        }
        
        
        
       
        // Validation Logic For Committed Record Type- Hybrid Scenario
        if(committedAccountHybridIds != null && !committedAccountHybridIds.isEmpty()){
            
            billingAccountList = [select id from Billing_Account__c where Account__c IN : committedAccountHybridIds]; 
            HybridCIDNList = [select ID ,CIDN__c 
                              from OneFund__c 
                              where OneFund_Status__c= 'Active'
                              And recordtypeid = :committedRecId	
                              AND(CIDN__c IN : committedAccountHybridIds
                                  OR Billing_Account__c IN: billingAccountList)];
        }
        if(HybridCIDNList != null && HybridCIDNList.size()>0){
            for(OneFund__c newOneFund: newOneFunds){
                for (OneFund__c hybridCIDN: HybridCIDNList)
                {
                    if(hybridCIDN.CIDN__c == newOneFund.CIDN__C) {
                        newOneFund.addError(System.Label.Committed_Error);
                    }      
                }
            }
        }
        // Validation Logic For Flexible Record Type
        if(flexiAccountIds != null && !flexiAccountIds.isEmpty()){
            FlexCIDNList = [select ID ,CIDN__c 
                            from OneFund__c 
                            where OneFund_Status__c= 'Active'
                            And recordtypeid = :flexibleRecId	
                            AND CIDN__c IN : flexiAccountIds];
        }
        if(FlexCIDNList != null && FlexCIDNList.size()>0){
            for(OneFund__c newOneFund: newOneFunds){
                for (OneFund__c flexiCIDN: FlexCIDNList)
                {
                    if(flexiCIDN.CIDN__c == newOneFund.CIDN__C) {
                        newOneFund.addError(System.Label.Flexi_Error);
                    } 
                }
            }
        }     
    }
}