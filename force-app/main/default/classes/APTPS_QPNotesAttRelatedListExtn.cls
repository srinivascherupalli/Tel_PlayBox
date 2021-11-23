/*************************************************************
@Name: APTS_QPNotesAttRelatedListExtn
@Author: Akanksha Trivedi
@CreateDate: 2nd Feb 2017.
@Description: This class acts as extension for page APTS_QPNotesAttachmentRelatedList
@UsedBy: APTPS_QPNotesAttachmentRelatedList
******************************************************************
@ModifiedBy: Author who modified this process.
@ModifiedDate: Date the process was modified.
@ChangeDescription: A brief description of what was modified. */

public with sharing class APTPS_QPNotesAttRelatedListExtn{
    
    /* Variables */
    private Apttus__APTS_Agreement__c           agreement;
    public  String                              agreementId                            {get; set;} //Holds the parent agreement ID
    public  String                              agreementName                          {get; set;} //Holds the name agreement name
    public  List<APTS_NotesAttachmentWrapper>   listNotesAttachmentWrapper                 {get; set;} //Holds the wrapper records to be displayed on page
    public String                               strdltAttachment                           { get; set; }
  
   
    /* Constructor */
    public APTPS_QPNotesAttRelatedListExtn(ApexPages.StandardController sc){
       
        strdltAttachment = null;
        //adding name fields to standard controller and initializing variables from standard controllers
        if(!test.isRunningTest()){
        sc.addFields(new List<String> {'Name'});
        }    
        this.agreement  = (Apttus__APTS_Agreement__c)sc.getRecord();
        agreementId     = sc.getId();                          //Using 15 digit id to avoid redirect error
        agreementName   = agreement.Name;
        //Collections/Variable Initializations
        listNotesAttachmentWrapper = new List<APTS_NotesAttachmentWrapper>();
        
        getNotesAttacmentRecords();        
    }
     /* Method to populate wrapper objects list with records */
    public void getNotesAttacmentRecords(){
        //clear list and populate records
        listNotesAttachmentWrapper.clear();
		
        //added by lokesh to remove soql cVersion from for loop
		Set<Id> cdIdSet = new Set<Id>();
		Map<String,String> cdIdWithCVIdMap = new Map<String,String>();
		for (ContentDocumentLink cDoc: getDocument(agreementId)){
			cdIdSet.add(cDoc.ContentDocumentId);
		}
        if (cdIdSet != null){
		List<ContentVersion>  cVersionList = [SELECT Id,ContentDocumentID FROM ContentVersion WHERE ContentDocumentID IN : cdIdSet];
            for (ContentVersion cv : cVersionList){
		cdIdWithCVIdMap.put(cv.ContentDocumentID,cv.Id);
		}
        } 	
       
        for(Attachment atth:getAttachments(agreementId)){
            listNotesAttachmentWrapper.add(new APTS_NotesAttachmentWrapper(false, true,false,null, atth,null,null));
        }
        for (Note note : getNotes(agreementId)) {
            listNotesAttachmentWrapper.add(new APTS_NotesAttachmentWrapper(true, false,false, note, null,null,null));
        }
        for (ContentDocumentLink cDoc: getDocument(agreementId)) {
            //ContentVersion  cVersion=[SELECT Id FROM   ContentVersion  WHERE //ContentDocumentID=:cDoc.ContentDocumentId limit 1];
            listNotesAttachmentWrapper.add(new APTS_NotesAttachmentWrapper(false, false,true, null, null,cDoc,cdIdWithCVIdMap.get(cDoc.ContentDocumentId)));
        }
        
      //sort based on last modified date
        listNotesAttachmentWrapper.sort();
    }
    
    /*Method to get contract's notes*/
    public  List<Note> getNotes(Id parentId) {
            List<Note> listNotes = new List<Note>();
            if (parentId != null) {
                listNotes = [SELECT Id, Title, CreatedById ,CreatedDate, CreatedBy.Name, LastModifiedDate,LastModifiedBy.Name,LastModifiedBy.Id, ParentId 
                             FROM Note
                             WHERE Parentid = : parentId];
            }
            return listNotes;
    }
    
    /*Method to get contract's Document*/
    public  List<ContentDocumentLink> getDocument(Id parentId) {
            List<ContentDocumentLink> listDoc = new List<ContentDocumentLink>();
            if (parentId != null) {
                 listDoc  = [SELECT Id, ContentDocument.title,ContentDocument.CreatedDate,ContentDocument.CreatedBy.Name,ContentDocument.CreatedById, ContentDocument.LastModifiedDate,ContentDocumentId,LinkedEntityId   FROM ContentDocumentLink WHERE LinkedEntityId = : parentId];
                 
            }
            return listDoc;
    }
    /*Method to get contract's Attachment*/
    //Query updated for Description Column - EDGE-40663
    public  List<Attachment> getAttachments(Id parentId) {
            List<Attachment> listAttch = new List<Attachment>();
            if (parentId != null) {
                listAttch = [SELECT Id, name, Description, CreatedById ,CreatedDate, CreatedBy.Name, LastModifiedDate,LastModifiedBy.Name,LastModifiedBy.Id, ParentId 
                             FROM Attachment
                             WHERE Parentid = : parentId];
            }
            return listAttch;
    }
    
     /*Method to get attachments by record ID*/
        public Attachment getAttachmentsByID(Id recId) {
            Attachment att = null;//EDGE-69042 Sonar fix
            if (recId != null) {
                List<Attachment> listAttachments = [SELECT Id, Name FROM Attachment
                                                    WHERE Id = : recId];
                if(listAttachments != null && !listAttachments.isEmpty()){
                    att = listAttachments[0];
                }                                    
            }
            return att;
        }
        
       
        /*Method to get Note by record ID*/
        public Note getNoteByID(Id recId) {
            Note noteRec = null;//EDGE-69042 Sonar fix
            if (recId != null) {
                List<Note> listNotes = [SELECT Id, Title, Body, CreatedById , CreatedBy.Name, LastModifiedDate,LastModifiedBy.Name, ParentId 
                                        FROM Note
                                        WHERE id= : recId];
                if(listNotes != null && !listNotes.isEmpty()){
                    noteRec = listNotes[0];
                }                                    
            }
            return noteRec;
        }
         /*Method to get Doc by record ID*/
        public ContentDocument getDocByID(Id recId) {
            ContentDocument docRec = null;//EDGE-69042 Sonar fix
            if (recId != null) {
                List<ContentDocument> listDocs = [SELECT Id, Title
                                        FROM ContentDocument
                                        WHERE id= : recId];
                if(listDocs != null && !listDocs.isEmpty()){
                    docRec= listDocs[0];
                }                                    
            }
            return docRec;
        }
    /* Method to delete attachment */
    public void deleteAttachment(){
        if(String.isNotBlank(strdltAttachment)){
            Attachment delAtt = getAttachmentsByID(strdltAttachment);
            if(delAtt != null){
                try{
                    delete delAtt;
                    //Remove from wrapper list
                    List<APTS_NotesAttachmentWrapper> tempList = new List<APTS_NotesAttachmentWrapper> ();
                    for(APTS_NotesAttachmentWrapper wrapperObj : listNotesAttachmentWrapper){
                        if(!(wrapperObj.attachment != null && wrapperObj.attachment.Id == strdltAttachment)){
                            tempList.add(wrapperObj);
                        }
                    }
                    listNotesAttachmentWrapper.clear();
                    System.debug('## inside del before listNotesAttachmentWrapper: '+listNotesAttachmentWrapper);
                    listNotesAttachmentWrapper.clear();
                    System.debug('## inside del tempList: '+tempList);
                    listNotesAttachmentWrapper = tempList;
                    System.debug('## inside del listNotesAttachmentWrapper: '+listNotesAttachmentWrapper);
                }catch(Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
                }
            }
        }
    }
 
    
     /* Method to delete Notes */
    public void deleteNote(){
        //String itemId=Apexpages.currentPage().getParameters().get('delItemId');
       
        if(String.isNotBlank(strdltAttachment)){
            Note delNote = getNoteByID(strdltAttachment);
           
            if(delNote != null){
                try{
                   
                    delete delNote;
                    //Remove from wrapper list
                    List<APTS_NotesAttachmentWrapper> tempList = new List<APTS_NotesAttachmentWrapper> ();
                    for(APTS_NotesAttachmentWrapper wrapperObj : listNotesAttachmentWrapper){
                        if(!(wrapperObj.note != null && wrapperObj.note.Id == strdltAttachment)){
                            tempList.add(wrapperObj);
                        }
                    }
                    System.debug('## inside del before listNotesAttachmentWrapper: '+listNotesAttachmentWrapper);
                    listNotesAttachmentWrapper.clear();
                    System.debug('## inside del tempList: '+tempList);
                    listNotesAttachmentWrapper = tempList;
                    System.debug('## inside del listNotesAttachmentWrapper: '+listNotesAttachmentWrapper);
                    
                }catch(Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
                }
            }
        }
    }
    
     /* Method to delete Doc*/
    public void deleteDoc(){
        //String itemId=Apexpages.currentPage().getParameters().get('delItemId');
       
        if(String.isNotBlank(strdltAttachment)){
            ContentDocument delDoc = getDocByID(strdltAttachment);
           
            if(delDoc != null){
                try{
                   
                    delete delDoc ;
                    //Remove from wrapper list
                    List<APTS_NotesAttachmentWrapper> tempList = new List<APTS_NotesAttachmentWrapper> ();
                    for(APTS_NotesAttachmentWrapper wrapperObj : listNotesAttachmentWrapper){
                        if(!(wrapperObj.document!= null && wrapperObj.document.ContentDocumentId== strdltAttachment)){
                            tempList.add(wrapperObj);
                        }
                    }
                    System.debug('## inside del before listNotesAttachmentWrapper: '+listNotesAttachmentWrapper);
                    listNotesAttachmentWrapper.clear();
                    System.debug('## inside del tempList: '+tempList);
                    listNotesAttachmentWrapper = tempList;
                    System.debug('## inside del listNotesAttachmentWrapper: '+listNotesAttachmentWrapper);
                    
                }catch(Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
                }
            }
        }
    }
    // wrapper class
    public class APTS_NotesAttachmentWrapper implements Comparable{
    
        public Boolean      isAttachment        {get; set;}
        public Boolean      isNotes             {get; set;}
        public Boolean      isDocument             {get; set;}
        public Note         note                {get; set;}
        public Attachment attachment          {get; set;}
        public ContentDocumentLink document{get; set;}
        public DateTime     lastModifiedDateTime  {get; set;} 
        public String     createdBy {get; set;}
        public String     createdById{get; set;}
        public String     type   {get; set;}
        public DateTime   createdDateTime {get; set;}
        public String     title {get;set;}
        public String     cVersionId {get;set;}
     
        
        /*Constructor*/
        public APTS_NotesAttachmentWrapper(Boolean isNote, Boolean isAttach,Boolean isDoc, Note noteObj, Attachment attachmentObj,ContentDocumentLink doc,String versionId) {
            isAttachment=   isAttach;
            isNotes     =   isNote;
            isDocument  =   isDoc;
            note        =   noteObj;
            attachment  =   attachmentObj;
            document= doc;
            if (attachmentObj != null) {
                lastModifiedDateTime  = attachmentObj.LastModifiedDate;
                title = attachmentObj.name;
                createdBy = attachmentObj.CreatedBy.Name;
                type= 'Attachment';
                createdById = attachmentObj.CreatedById;
                createdDateTime = attachmentObj.CreatedDate;
                
            } else if (noteObj != null) {
                lastModifiedDateTime  = noteObj.LastModifiedDate;
                type= 'Note';
                createdById = noteObj.CreatedById;
                createdBy = noteObj.CreatedBy.Name;
                createdDateTime = noteObj.CreatedDate;
            }
            else if (doc!= null) {
                lastModifiedDateTime  = doc.ContentDocument.LastModifiedDate;
                type= 'File';
                createdById = doc.ContentDocument.CreatedById;
                createdBy = doc.ContentDocument.CreatedBy.Name;
                title= doc.ContentDocument.title;
                createdDateTime = doc.ContentDocument.CreatedDate;
                cVersionId =versionId;

            }
        }
       /*Comparator*/
      public Integer compareTo(Object compareTo) {
        APTS_NotesAttachmentWrapper naWrapper = (APTS_NotesAttachmentWrapper) compareTo;
        if (createdDateTime == naWrapper.createdDateTime ) return 0;
           if (createdDateTime < naWrapper.createdDateTime ) return 1;
        return -1;
      } 
    }
       
    
    }