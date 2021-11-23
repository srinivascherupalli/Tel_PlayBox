/*
* @Author   :   Manish Berad
* @Date     :   23 june 2020
* @Desc     :   EDGE-153347  Lightning components handler to save pre-authorisation, file upload & captur comments.
*               EDGE-165471 removed file deletion code to support multiple file upload
* */
public with sharing class ContractAuthorisationFileUploadHandler {
     public static final String PRE_AUTH_TITLE ='Pre-authorisation comment';
     public static final String PRE_AUTH_DESCRIPTION ='Contract Authorisation Docs';
    
        /**
    * This method delete existing file & Notes retaled to Opportunity to 
    * @param contentDocumentId   
    * @return void
    */
    @AuraEnabled  
    public static void deleteContentDocument(String contentDocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id=:contentDocumentId];       
    }  

        /**
    * This method used to check Pre_Authorised__c, uploded docs & note while loading the components
    * @param bskId   
    *  @param OppId   
    * @return ContractAuthorisationFileUploadHandler.ContractAuthorisationWrapper, return wrapper to set value on UI
    */
    @AuraEnabled  
    public static ContractAuthorisationFileUploadHandler.ContractAuthorisationWrapper onLoadCmp(String bskId,String OppId){
        Set<String> ContentDocumentIds=new  Set<String>();
        ContractAuthorisationFileUploadHandler.ContractAuthorisationWrapper wrapp=new ContractAuthorisationFileUploadHandler.ContractAuthorisationWrapper();
        String OpprtID=String.escapeSingleQuotes(OppId);
        //check login users Profile Name
        //EDGE-164560
        wrapp.profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
          
        cscfga__Product_Basket__c prodBasket=[Select Id,Pre_Authorised__c 
                                              From cscfga__Product_Basket__c 
                                              Where Id=:String.escapeSingleQuotes(bskId)];
        wrapp.isPreAuth=prodBasket.Pre_Authorised__c;
        
        List<ContentDocumentLink> cdlList=[SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.Title,ContentDocument.description 
                                           FROM ContentDocumentLink 
                                           where LinkedEntityId=:String.escapeSingleQuotes(OppId)
                                           AND ContentDocument.Title=:ContractAuthorisationFileUploadHandler.PRE_AUTH_TITLE];
        if(!cdlList.isEmpty()){
            for(ContentDocumentLink cl:cdlList){
                if(cl.ContentDocumentId!=null){
                    ContentDocumentIds.add(cl.ContentDocumentId);
                }
            }
        }
        List<ContentNote> lstContentNote=[SELECT Id, Title,TextPreview 
                                          FROM ContentNote 
                                          Where Id IN:ContentDocumentIds];
        List<ContentDocument>  cdlist=[SELECT Id, Title,description, FileType FROM ContentDocument WHERE Id IN :ContentDocumentIds];
        if(!lstContentNote.isEmpty() && !cdlist.isEmpty()){
            for(ContentDocument cd:cdlist){
                if(cd.Title==ContractAuthorisationFileUploadHandler.PRE_AUTH_TITLE){
                    wrapp.contentDocId=lstContentNote[0].Id;
                    wrapp.preAuthComments=lstContentNote[0].TextPreview;
                }
            }
        }
        return wrapp;
    }
    
    public class ContractAuthorisationWrapper{
        @AuraEnabled  public string profileName;
        @AuraEnabled public boolean isPreAuth;
        @AuraEnabled  public string preAuthComments;
        @AuraEnabled  public string contentDocId;
        ContractAuthorisationWrapper(){
            profileName='';
            isPreAuth=false;
            preAuthComments='';
            contentDocId='';
        }
    }
    
        /**
    * this method is used to update basket Pre_Authorised__c & Insert & update Notes related to Opportunity
    * @param isPreAuth, checkbox value 
    * @param NotesValue, Pre-authorisation comments
    * @param bskId , Product Basket Id to Update Pre_Authorised__c field
    * @param OppId , Opportunity Id to Insert & update the notes & files 
    * @param contentDocId , to delete priviously uploaded Notes
    * @param uploadedContentDocsId, to delete priviously uploaded files
    * @return void
    */
    @AuraEnabled  
    public static void submitPreAuthAndNotes(boolean isPreAuth,String NotesValue,String bskId,String OppId, String contentDocId){
        String basketID=String.escapeSingleQuotes(bskId);
        String OpprtID=String.escapeSingleQuotes(OppId);
        String notes=String.escapeSingleQuotes(NotesValue);
        if(contentDocId!=null){
            deleteContentDocument(contentDocId);    
        }
        if(isPreAuth && basketID!=null){
            cscfga__Product_Basket__c ProdBasket=[Select Id,Pre_Authorised__c From cscfga__Product_Basket__c Where Id=:basketID];
            ProdBasket.Pre_Authorised__c=isPreAuth;
            update ProdBasket;
        }
        if(OpprtID!=null && String.IsNotEmpty(notes)){
            ContentNote cn = new ContentNote(Title =ContractAuthorisationFileUploadHandler.PRE_AUTH_TITLE,Content = Blob.valueOf(notes));
            insert cn ;   
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId =OpprtID; // update opportunity id here
            cdl.ContentDocumentId = cn.Id;
            cdl.shareType = 'V';
            insert cdl;
        }
    }
        /**
    * This method insert uploded document in the file section related to opportunity
    * @param parentId   Opportunity Id
    * @param fileName   name of uploaded file
    * @param base64Data   uploaded file data
    * @param contentType   type of the file
    * @param fileId  ContentDocument Id for update
    * @return Id, Id of ContentDocument 
    */
     @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } 
        return Id.valueOf(fileId);
    }
        /**
    * This method insert uploded document in the file section related to opportunity
    * @param parentId   Opportunity Id
    * @param fileName   name of uploaded file
    * @param base64Data   uploaded file data
    * @param contentType   type of the file
    * @return Id, Id of ContentDocument 
    */
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        String title=fileName;
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; 
        conVer.PathOnClient =title;
        conVer.Title =fileName;
        conVer.Description =ContractAuthorisationFileUploadHandler.PRE_AUTH_DESCRIPTION;
        conVer.VersionData = EncodingUtil.base64Decode(base64Data);
        insert conVer; 
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId =parentId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;
        return conDocLink.Id;
    }
}