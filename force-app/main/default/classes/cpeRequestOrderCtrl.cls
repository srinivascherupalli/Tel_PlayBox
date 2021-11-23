/**
  * Author: Nilima Borse
  * Team: Jaipur
  * Sprint: 20.10
  * Date: 16/07/2020
  * Description: Controller class for cpeGetQuoteDetails lightning component - P2OB-7498
  **/

public without sharing class cpeRequestOrderCtrl {
    public static Map<Id, soc_Case_Line_Item__c> existingCLI = new Map<Id,soc_Case_Line_Item__c>();
    
    /*
    Sprint : 20.10 & P2OB-6821
    Description:    Returns all the case line item of selected case Id.
     */
    @AuraEnabled
    public static CaseLineItemWrapper fetchQuoteDetails(String caseId){
        map<Id,soc_Case_Line_Item__c> caseLineItems = new Map<Id,soc_Case_Line_Item__c>(
            													[SELECT cpe_External_System_Quote_Number__c, Id, cpe_Requote_Details__c, 
                                                                 cpe_Accept_Quote__c FROM soc_Case_Line_Item__c 
                                                                 where soc_CaseId__c =: caseId order by CreatedDate asc] );
        
        Group cpeQuoteQueue = [Select Id, DeveloperNAME From Group where Type = 'Queue' AND DeveloperNAME =: 'cpe_Ordering_Hardware' Limit 1];
        List<ContentDocumentLink> caseAttachmentRecList=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:caseId];  	
        //CaseLineItemWrapper returnwrapperClass = new  CaseLineItemWrapper(cpeQuoteQueue.Id, caseLineItems.values());
        CaseLineItemWrapper returnwrapperClass = new  CaseLineItemWrapper();
        returnwrapperClass.quoteQueueId = cpeQuoteQueue.Id;
        returnwrapperClass.quoteDeatils = caseLineItems.values();
        if(caseAttachmentRecList == null || caseAttachmentRecList.isEmpty() || caseAttachmentRecList.size()==0){
            returnwrapperClass.noOfCaseDocuments = 0;
        }else{
        	returnwrapperClass.noOfCaseDocuments = caseAttachmentRecList.size();          
		}
        existingCLI = caseLineItems;
        return returnwrapperClass;
    }
    /*
    Sprint : 20.10 & P2OB-6821
    Description:    Accept all selected case line items which are selected.
     */
    @AuraEnabled
    public static List<soc_Case_Line_Item__c> acceptQuotes(List<soc_Case_Line_Item__c> quoteList, String caseId){
        map<Id,soc_Case_Line_Item__c> existingCaseLineItems = new Map<Id,soc_Case_Line_Item__c>(
            													[SELECT cpe_External_System_Quote_Number__c, Id, cpe_Requote_Details__c, 
                                                                 cpe_Accept_Quote__c FROM soc_Case_Line_Item__c 
                                                                 where soc_CaseId__c =: caseId order by CreatedDate asc] );
        List<soc_Case_Line_Item__c> quoteListToUpdate = new List<soc_Case_Line_Item__c>();
        Set<Id> selectedQuote = new Set<Id>();
        system.debug('test'+quoteList);
        for(soc_Case_Line_Item__c quote : quoteList){
           selectedQuote.add(quote.Id);
        }
        system.debug('selectedQuote'+selectedQuote);
        for(soc_Case_Line_Item__c existingQuote : existingCaseLineItems.values()){
            soc_Case_Line_Item__c quoteToUpdate = new soc_Case_Line_Item__c();
            quoteToUpdate.Id = existingQuote.Id;
            if(selectedQuote.contains(existingQuote.Id)){
            	quoteToUpdate.cpe_Accept_Quote__c = true;
            }    
            else{
                quoteToUpdate.cpe_Accept_Quote__c = false;
            }
            quoteListToUpdate.add(quoteToUpdate);
        }
        
        update quoteListToUpdate;
        system.debug(quoteListToUpdate);
        map<Id,soc_Case_Line_Item__c> caseLineItems = new Map<Id,soc_Case_Line_Item__c>(
            													[SELECT cpe_External_System_Quote_Number__c, Id, cpe_Requote_Details__c, 
                                                                 cpe_Accept_Quote__c FROM soc_Case_Line_Item__c 
                                                                 where soc_CaseId__c =: caseId order by CreatedDate asc]);
        return caseLineItems.values();
    }
    
    /*
    Sprint : 20.10 & P2OB-6821
    Description:    Link content link doucment of case line item to opportunity.
     */
     @AuraEnabled
    public static void attachDocumentToOpportunity(List<soc_Case_Line_Item__c> quoteList, String caseId){
    	Set<Id> acceptedQuoteId = new Set<Id>();
        for(soc_Case_Line_Item__c quote : quoteList){
            if(quote.cpe_Accept_Quote__c)
                acceptedQuoteId.add(quote.Id);
        }
        Case caseRecord = [Select Id, OpportunityId__c FROM Case Where Id = :caseId];
            
        if(caseRecord.OpportunityId__c != null){
            List<ContentDocumentLink> lstContDocLink = new List<ContentDocumentLink>([ SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink 
                                                         Where LinkedEntityId IN :acceptedQuoteId  ]) ;
            
            List<ContentDocumentLink> lstNewContDocLink = new List<ContentDocumentLink>();
            for(ContentDocumentLink contlink : lstContDocLink) 
            { 
                  ContentDocumentLink cdlink = new ContentDocumentLink(); 
                  cdlink.ContentDocumentId = contlink.ContentDocumentId; 
                  cdlink.LinkedEntityId = caseRecord.OpportunityId__c;
                  lstNewContDocLink.add(cdlink); 
            }
            insert lstNewContDocLink;
        }
    }
    
    public class CaseLineItemWrapper{
        @AuraEnabled public String quoteQueueId {get;set;}
        @AuraEnabled public Integer noOfCaseDocuments {get;set;}
        @AuraEnabled public List<soc_Case_Line_Item__c> quoteDeatils {get;set;}
    }
}