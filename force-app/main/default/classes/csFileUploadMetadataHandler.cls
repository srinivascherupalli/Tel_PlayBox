/*****************************************************************************
@Name : csFileUploadMetadataHandler
@Description : This class is helper class for CaseAttachment LWC component. 
@Created by : Chandrakant Wani as part of P2OB-10677.

@Description : Logic to delete unattached file by user and update ss_Case_Search__c user record.

*******************************************************************************/

public without sharing class csFileUploadMetadataHandler {

    /*
    Method Name:         UpdateMetadata
    Input Parameter:     Id[] fileIdList: This list will have list of uploaded document Id's                       
    Output Parameter:    Nothing(Void)

    Description:         This method will update ss_Case_Search__c user record with Attachemnet id's
    Reference:           JIRA Story: P2OB-10677,P2OB-14078

    */
    @AuraEnabled
    public static void UpdateMetadata(Id[] fileIdList){


        ss_Case_Search__c[] searchRecord = [Select id,User__c, Attachments__c from ss_Case_Search__c where User__c =: userinfo.getuserId()] ;    
        if(searchRecord.size() > 0){
            searchRecord[0].Attachments__c = fileIdList.toString();
            update searchRecord[0];

        }
    }

    /*
    Method Name:         doMetadataEmpty
    Input Parameter:     Nothing                       
    Output Parameter:    Nothing(Void)

    Description:         This method will update ss_Case_Search__c user record to make Attachemnet id empty

    Reference:           JIRA Story: P2OB-10677
    */
    @AuraEnabled
    public static void doMetadataEmpty(){


        ss_Case_Search__c[] searchRecord = [Select id,User__c, Attachments__c from ss_Case_Search__c where User__c =: userinfo.getuserId()] ;
        if(searchRecord.size() > 0){
            String attachmentIds = searchRecord[0].Attachments__c;                       
            if(attachmentIds !='' && attachmentIds !=null){
                searchRecord[0].Attachments__c = '';
                update searchRecord[0];

            }
        }
    }

    /*
    Method Name:         deleteUnattachedFiles
    Input Parameter:     String attachmentIds: document id to delete from database //format : '0695P000000NJB4QAO'                 
    Output Parameter:    Nothing(Void)
    Description:         This method will delete Contentdocuments from database based on Id mentiod in input parameter
    Reference:           JIRA Story: P2OB-10677
    */
    @future
    public static void deleteUnattachedFiles(String attachmentIds) {
        if(attachmentIds !='' && attachmentIds !=null){
            
            attachmentIds = attachmentIds.substring(1, attachmentIds.length() - 1);
            List<String> metaIds = attachmentIds.split(', ');
            List<Id> idList=  new List<Id>();

            for(String mId : metaIds){
                idList.add(Id.valueOf(mId));
            }

            if(idList.size() > 0){
                List<ContentDocumentLink> clList = [SELECT  ContentDocument.Id, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.FileType,LinkedEntityId
                                                FROM ContentDocumentLink where ContentDocumentId IN: idList];
             
                Set<String> setToReturn = new Set<String>();
                Set<String> setToDelete = new Set<String>();

                for(ContentDocumentLink cl : clList ){
                    if(!setToDelete.add(cl.ContentDocumentId)){
                        setToReturn.add(cl.ContentDocumentId);
                    }  
                }

                for(String sId: setToReturn){
                    if(setToDelete.contains(sId)){                    
                        setToDelete.remove(sId);
                    }
                }
                List<String> idListToDelete = new List<String>(setToDelete);             
                database.delete(idListToDelete,false);
            }
        }
    }
}