/**
    Apttus Adobe eSign Service Integration for Comply

    Adobe ESignService Signed Agreement Insert Trigger Helper
    
    @2016 Apttus Inc. All rights reserved.
Testclass:ApttusAdobeESignAttachmentTriggerTest
 */



public class ApttusAdobeESignAttachmentTriggerHelper {
    
    public static String ES_SIGN_AGMT_OBJECT_NAME = 'echosign_dev1__SIGN_Agreement__c';
    
    public static void updateAttachmentList(List<Attachment> signedAttachments) {
            
        String ES_SIGNED_ATTACHMENT_SUFFIX = 'signed.pdf';
        String ES_AUDIT_DOCUMENT_SUFFIX = 'audit.pdf';
        
        
        List<Attachment> attachmentList = new List<Attachment>();
            
        Set<Id> parentIdSet= new Set<Id>();
        
        //Check if attachment parent is echosign_dev1__SIGN_Agreement__c, and if yes,store it in a set
        for (Attachment attach : signedAttachments) {
            Id parentId = attach.parentId;
            String parentType = ''+parentId.getSObjectType();
            
            if(parentType.equalsIgnoreCase(ES_SIGN_AGMT_OBJECT_NAME)) {
                parentIdSet.add(parentId);
            }
            
        }
        
        //Get a map of only the Apttus related echosign_dev1__SIGN_Agreement__c for the given set of parent ids 
        Map<Id, echosign_dev1__SIGN_Agreement__c> eSAgmtMap = new Map<Id, echosign_dev1__SIGN_Agreement__c>([SELECT Id, Name
                , Apttus_EchoSign__Apttus_Agreement__c
                , Apttus_EchoSign__Apttus_RSPCAttachments__c
                , echosign_dev1__Status__c
            FROM echosign_dev1__SIGN_Agreement__c
            WHERE Id IN :parentIdSet AND (Apttus_EchoSign__Apttus_Agreement__c != null) LIMIT 1000]);
        
        for (Attachment signedAttachment : signedAttachments) {
            echosign_dev1__SIGN_Agreement__c esAgmt = null;
            //process only if the parent type is echosign_dev1__SIGN_Agreement__c
            if(eSAgmtMap.containsKey(signedAttachment.parentId)) {
                Attachment aptsAttachment = null;
                Map<String, Id> attachmentNameAndIdMap = new Map<String, Id>();
                esAgmt = eSAgmtMap.get(signedAttachment.parentId);
                
                if (null != esAgmt && (signedAttachment.Name.containsIgnoreCase(ES_SIGNED_ATTACHMENT_SUFFIX) ||
                    signedAttachment.Name.containsIgnoreCase(ES_AUDIT_DOCUMENT_SUFFIX))) {
                        String attName = '';
                    if(null != esAgmt.Apttus_EchoSign__Apttus_RSPCAttachments__c) {  
                        attachmentNameAndIdMap = (Map<String, Id>) JSON.deserialize(esAgmt.Apttus_EchoSign__Apttus_RSPCAttachments__c, Map<String, Id>.class);
                    }  
                        //added by Vamsi for TED-383 on 29SEP2021 starts
                        Map<String, Id> newattachMap = new Map<String, Id>();    
                        for(String obj:attachmentNameAndIdMap.keySet())
                            {
                            String s1 = obj;
                            s1 = s1.substring(0,s1.length()-15);
                            newattachMap.put(s1, attachmentNameAndIdMap.get(obj));
                                system.debug('newattachMap '+newattachMap);
                            }
                        if(signedAttachment.Name.containsIgnoreCase(ES_SIGNED_ATTACHMENT_SUFFIX))
                        {
                        attName = signedAttachment.Name;
                        attName = attName.substring(0,attName.length()-18);
                        system.debug('attName '+attName);
                        } //added by Vamsi for TED-383 on 29SEP2021 ends

                    aptsAttachment = new Attachment(
                        ParentId = newattachMap.containsKey(attName)?
                            newattachMap.get(attName):esAgmt.Apttus_EchoSign__Apttus_Agreement__c
                        , Name = signedAttachment.Name
                        , Body = signedAttachment.Body
                        , OwnerId = signedAttachment.OwnerId
                        , ContentType = signedAttachment.ContentType);
                            
                    attachmentList.add(aptsAttachment);
                    
                }
            }
            
        }
        
        if(attachmentList.size() > 0) {
            insert attachmentList;      
        
        }
        
    }
}