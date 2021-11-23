/*
Version     Author                         Last Modified Date      Description
v1.0        Vivian Charlie (Team Hawaii)     15 Jan 2021           Initial Draft
*/
public without sharing class PRMLeadTableGeneratorController{
    public Id partnerId {get;set;}
    
    public List<Lead> getlstLeads(){
        list<Lead> lstLeads;
        system.debug(partnerId+'*****getlstLeads called***');
        lstLeads= [Select Id
                               , PartnerAccountId
                               , Customer_Name__r.Name
                               , Contact_Name__r.Name
                               , Shared_By__c
                               , Shared_By__r.Name
                               , isBulkSharedLead__c
                               , Trigger_Share_with_Partner__c
                          From Lead
                          Where PartnerAccountId =: partnerId
                          and PartnerAccountId != null
                          and isBulkSharedLead__c = false
                          and Trigger_Share_with_Partner__c = true];
                          
            
        return lstLeads;
    }
}