/**
*	Purpose			:	This class is used to upsert data on the number and type of visitors from PreChat Form
*
*	Author			:	Padmesh Soni (Wipro)
*
*	Date			:	13/08/2020
*
*	Current Version	:	V_1.0
*
*	Revision Log	:	V_1.0 - DPA-204 - Created
**/
public without sharing class BCSLeadGenTranscript {

    @AuraEnabled
    public static TranscriptWrapper isOrphanTranscript(String recordId) {
        
        LiveChatTranscript chatTranscript = [SELECT Id, Contact.AccountId, Contact.Account.Name, Contact.FirstName, Contact.LastName, Contact.Seniority_Level__c, 
                                             ContactId, Contact.Email, Chat_Channel__c, LeadId, Chat_Start_URL__c FROM LiveChatTranscript WHERE Id =: recordId];
        
        TranscriptWrapper wrapper = new TranscriptWrapper();
        wrapper.chatTranscript = chatTranscript;
        wrapper.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId();
        
        if(chatTranscript != null && String.isNotBlank(chatTranscript.Chat_Start_URL__c)) {
            
            List<BCS_Lead_Domain__mdt> leadDomains = [SELECT Id, MasterLabel, Domain__c, Start_URL__c FROM BCS_Lead_Domain__mdt WHERE Start_URL__c =: chatTranscript.Chat_Start_URL__c];
            wrapper.domainName = leadDomains.size() > 0 ? (String.isNotBlank(leadDomains[0].Domain__c) ? leadDomains[0].Domain__c : leadDomains[0].MasterLabel) : null;
        }
        return wrapper;
    }
    
    @InvocableMethod
    public static void leadAssign(List<List<String>> LeadTranscriptIds)
    {	
        System.debug('LeadIds :::'+ LeadTranscriptIds);
        List<String> recordIds = LeadTranscriptIds[0];
        String LeadIds = recordIds[0];
        String transcriptId = recordIds[1];
        
        System.debug('LeadIds :::'+ LeadIds);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;          
        Lead leadRecord =[select id from lead where id = :LeadIds];
        leadRecord.setOptions(dmo);
        update leadRecord;
        
        if(String.isNotBlank(transcriptId)) {
            
            update new LiveChatTranscript(Id = transcriptId, LeadId = leadRecord.Id);
        }
   }
    
    public class TranscriptWrapper {
        
        @AuraEnabled
        public LiveChatTranscript chatTranscript {get; set;}
        
        @AuraEnabled
        public String domainName {get; set;}
        
        @AuraEnabled
        public String recordTypeId {get; set;}
    }
}