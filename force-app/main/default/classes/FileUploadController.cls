/*****************************************************************************
@Name : FileUploadController
@Description : This class is helper class for CaseAttachment LWC component. 
@Created by : Chandrakant Wani as part of P2OB-10677.
@Description : Logic to get files from user record metadata.
*******************************************************************************/

public without sharing class FileUploadController {
    
    /*
    Method Name:         getFilesFromMetadata
    Input Parameter:     Nothing
    Output Parameter:    List<file>
    Description:         This method will called from LWC component 'CaseAttachments' and 

                        return list of files related with user record from 'Case Search' component
    Reference:           JIRA Story: P2OB-10677, P2OB-14078

    */
    @AuraEnabled
    public static List<file> getFilesFromMetadata(){


       ss_Case_Search__c[] searchRecord = [Select id,User__c, Attachments__c from ss_Case_Search__c where User__c =: userinfo.getuserId()] ;
        
        List<File> files = new List<File>();
        if(searchRecord.size() > 0){
            String attachmentIds = searchRecord[0].Attachments__c;
            // persist user uploaded id in attachmentIds received from user record

            if(attachmentIds !='' && attachmentIds !=null){
                attachmentIds = attachmentIds.substring(1, attachmentIds.length() - 1);
                List<String> metaIds = attachmentIds.split(', ');            
                List<Id> idList=  new List<Id>();
    
                for(String mId : metaIds){
                    idList.add(Id.valueOf(mId));
                }    
                
                if(idList.size() > 0){                

                    files = getRelatedFiles(idList);

                    return files;    
                }
            }
        }
        return files;
    }

    /*
    Method Name:         getRelatedFiles
    Input Parameter:     Id[] fileIdList
    Output Parameter:    List<file>
    Description:         This method will called from LWC component 'CaseAttachments' and 
                        return list of files related with input Id's
    Reference:           JIRA Story: P2OB-10677
    */
    @AuraEnabled
    public static List<file> getRelatedFiles(Id[] fileIdList){
        List<File> files = new List<File>();

        for(ContentVersion conVersion : [SELECT Id, Title, FileExtension, ContentDocumentId From ContentVersion Where ContentDocumentId IN: fileIdList]){   
            File file = new File();
            file.Title = conVersion.Title;
            file.Id = conVersion.ContentDocumentId;
            file.Type = conVersion.FileExtension.toUpperCase();
            files.add(file);
        }
        return files;
    }

    public class File{
        @AuraEnabled public String Title;
        @AuraEnabled public String Type;
        @AuraEnabled public Id Id;
    }
}