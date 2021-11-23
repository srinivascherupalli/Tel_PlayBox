/*****************************************************************************
@Author: Shamikh Hassan
@CreateDate: 06/09/2018
@Description: Improve the Case creation process experience, P2OB-9558 : Remove the CPE Request Option from the Partner Community
@ModifiedByandDate: Preeti Malik on 08/Sep/2020
@ModifiedByandDate: Preeti Malik on 22/Sep/2020 : P2OB-9108 : Validation before CBS Case creation.
*******************************************************************************/
/*
Code cleanup as a Part of P2OB-11460
-Removed Debug logs
*/

public with sharing class soc_CreateSOCRequestController {
    
    //P2OB-9558 Preeti Malik
    @AuraEnabled
    public static Map<String,Object> checkOpportunityClosedWonForPartners(String oppId){
        Opportunity opp;
        Map<String,Object> results=new Map<String,Object>();
        results.put('status','fail');
        results.put('isOppClosedWonForPartners','false');
        results.put('hasOppLineItemsNotPresent','false');
        try{                
            opp = fetchOpportunity(oppId);
            results.put('oppDetails', opp);
            if(Network.getNetworkId() != null && System.Label.SOC_Edge_Partners_Community_Id.contains(Network.getNetworkId()) && !Test.isRunningTest()){
                // Start : To make CPE Request Disabled for Community Users
                results.put('isCommunityDisabled','false');
                //End
                if(opp != null && opp.StageName != System.Label.SOC_Opportunity_Stage_Closed_Won){
                    results.put('status','pass');
                    results.put('isOppClosedWonForPartners','true');
                }
                //return results;
            }
            else{
                // Start : To make CPE Request Enabled for other than Community Users
                if(Network.getNetworkId() == null){
                    results.put('isCommunityDisabled','true');
                }
                //End
                if(opp.OpportunityLineItems.size() == 0){
                    results.put('status','pass');
                    results.put('hasOppLineItemsNotPresent','true');
                }
                //return results;   
            }
        }
        catch(Exception ex){
            results.put('status','fail');
            results.put('response',ex.getMessage());    
        }
        
        return results;
    }
    
    @AuraEnabled
    public static Map<String,Object> createSOCRequest(String oppId){
        
        String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        String recId_SupportRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request').getRecordTypeId();
        String recId_SupportRequestWO=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
        Opportunity opp;
        Map<String,Object> results=new Map<String,Object>();          
        results.put('status','fail');  
        
        try{
            List<Account> currentPartnerAccount = null;
            
            if(Network.getNetworkId() != null && System.Label.SOC_Edge_Partners_Community_Id.contains(Network.getNetworkId()) 
               && !Test.isRunningTest()){
                   List<User> currentPartnerUser = [Select Id,ContactId From User Where Id = :UserInfo.getUserId()];
                   
                   List<Contact> currentPartnerContact = null;
                   
                   if(currentPartnerUser.size() > 0)
                       currentPartnerContact = [Select Id,AccountId From Contact Where Id = :currentPartnerUser[0].ContactId];
                   
                   if(currentPartnerContact.size() > 0)
                       currentPartnerAccount = [Select Id,Partner_Code__c From Account Where Id = :currentPartnerContact[0].AccountId];
                   
               }
            opp=fetchOpportunity(oppId);
            case c = new case();
            c.Subject = soc_CaseTriggerHandler.soc_STR_SUBJECT+opp.Name;                
            c.Status = soc_CaseTriggerHandler.soc_STR_STATUS_NEW;
            c.RecordTypeId = recId_OrderRequest;
            c.Stage__c = soc_CaseTriggerHandler.soc_STAGE_NEW;                
            c.Primary_Domain__c = opp.Product_Domain__c;
            c.OwnerId = opp.OwnerId;
            c.Requestor__c = opp.OwnerId;
            c.AccountId = opp.AccountId;
            c.OpportunityId__c = opp.id;
            // EDGE-68030 - Pravin
            c.Partner_Code__c = (currentPartnerAccount != null && currentPartnerAccount.size() > 0) ? currentPartnerAccount[0].Partner_Code__c : '';
            insert c;
            results.put('status','pass');
            results.put('response',c);
            
            
        }
        catch(Exception e){
            results.put('status','fail');
            results.put('response',e.getMessage());            
        }   
        return results; 
        
    }    
    @AuraEnabled
    public static Map<String,Object> createSOCSupportRequest(String oppId,String category,String description){         
        String recId_SupportRequestWO=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
        Opportunity opp;
        Map<String,Object> results=new Map<String,Object>();          
        results.put('status','fail');          
        try{
            opp=fetchOpportunity(oppId);              
            case c = new case();
            c.Subject = 'SFD Order Support without SFD Request';                
            c.Status = soc_CaseTriggerHandler.soc_STR_STATUS_NEW;
            c.RecordTypeId = recId_SupportRequestWO;
            c.soc_Support_Category_WO__c=category;
            c.Description=description;
            c.AccountId = opp.AccountId;
            c.OpportunityId__c = opp.id;               
            insert c;
            results.put('status','pass');
            results.put('response',c);
        }
        catch(Exception e){
            results.put('status','fail');
            results.put('response',e.getMessage());            
        }    
        return results; 
        
    }
 
    @AuraEnabled
    public static String[] picklist_values(String object_name, String field_name) {
        String[] values = new String[]{};
            String[] types = new String[]{object_name};
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getValue());}
            }
        }
        return values;
    }
    
    //Karan : P2OB:9669 : Check for existing CBS Cases on opportunity
    @AuraEnabled
    public static Map<String,Object> existingCBSCaseValidation(String oppId){
        //String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
        Opportunity opp;
        Map<String,Object> results=new Map<String,Object>();          
        results.put('status','NoCaseExist');  
        opp=fetchOpportunity(oppId);
        List<case> caseLst = 	[Select Id, CaseNumber from Case where recordtype.name='CBS' AND srvsup_Categories__c = 'Billing Solution Design' AND OpportunityId__c =: oppID Limit 1];
        If(caseLst.size() > 0){
            results.put('CaseAlreadyExist','yes');
            results.put('caseRec',caseLst.get(0));
        }
        Else{
            results.put('CaseAlreadyExist','no');
        }
        
        return results; 
        
    }
    //Smriti : P2OB:11749 : Check for existing CBS Contract Cases on opportunity
     @AuraEnabled
    public static Map<String,Object> existingCBSCaseContractValidation(String oppId){
        
        //String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
        Opportunity opp;
        Map<String,Object> results=new Map<String,Object>();          
        results.put('status','NoCaseExist');  
        
        opp=fetchOpportunity(oppId);
        system.debug(opp);
        List<case> caseLst = 	[Select Id, CaseNumber from Case where recordtype.name='CBS' AND srvsup_Categories__c = 'Billing Solution Contract Implementation' And Status IN ('New','In Progress','On Hold') AND OpportunityId__c =: oppID Limit 1];
        If(caseLst.size() > 0){
            results.put('CaseAlreadyExist','yes');
            results.put('caseRec',caseLst.get(0));
        }
        Else{
            results.put('CaseAlreadyExist','no');
        }
        return results; 
    }
    
    public static Opportunity  fetchOpportunity(String oppId) {        
        //Opportunity o=new Opportunity();
        List<Opportunity> opplist=[select id,Name,Product_Domain__c ,CIDN__c,Owner.Name,
                                   Customer_Accepted__c, //Account.Offshore_Data_Hosting_Restricted__c, //Dependency with EDGE-47352
                                   Account.id,Account.Name,Account.CIDN__c,Account.Parent_CIDN__c,
                                   AccountId, OwnerId, Account.Ultimate_Parent_CIDN__c,StageName,
                                   Product_Type__c,Product_Count_Status_Won__c,Probability,  // Karan P2OB:9108 : Check Description for more info 
                                   (SELECT Id, Domain__c FROM OpportunityLineItems)
                                   from Opportunity where id=:oppId LIMIT 1];
        if(opplist.size()==1){
            return opplist[0];
        }else{
            return null;
        }
    }
}