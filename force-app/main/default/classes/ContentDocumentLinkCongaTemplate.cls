public with sharing class ContentDocumentLinkCongaTemplate {

    @InvocableMethod(label='Update File' description='file update in conga template')
    public static void updateFile(List<Id> myList){
        
          List<Conga_Template_Version__c> congaTemplateVersions = [Select id, Active__c, Conga_Template__c,Version__c from Conga_Template_Version__c where id in :myList];
    	//Manoj : EDGE-127536
        Set<String> versionIdSet = new Set<String>(); 
        Set<String> congaTemplateIdSet = new Set<String>();
        Set<String> versionSet = new Set<String>(); 
        List<ContentDocumentLink> toUpdateList = new List<ContentDocumentLink>();
        List <APXTConga4__Conga_Template__c> congaTemplate_List = new List <APXTConga4__Conga_Template__c> ();
        Map<String,ContentDocumentLink> oldLinkMap = new Map<String,ContentDocumentLink>();
        Map<String,APXTConga4__Conga_Template__c> congaTemplateMap = new Map<String,APXTConga4__Conga_Template__c>();
        List<ContentDocumentLink> toDeleteContLink = new List<ContentDocumentLink>();
            //iterating congaTemplateVersions List : Manoj : EDGE-127536
        for(Conga_Template_Version__c version:congaTemplateVersions){
            versionIdSet.add(version.Id);
            congaTemplateIdSet.add(version.Conga_Template__c);
        }
        if(!versionIdSet.IsEmpty()){
            toUpdateList = [SELECT id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :versionIdSet AND LinkedEntity.Type='Conga_Template_Version__c' ORDER BY SystemModstamp DESC]; 
            for(ContentDocumentLink cd : toUpdateList){
                oldLinkMap.put(cd.LinkedEntityId, cd);
            }
        }
        
        if(!congaTemplateIdSet.IsEmpty()){
            congaTemplate_List = [select id,Active_Template_Version__c from APXTConga4__Conga_Template__c where id in :congaTemplateIdSet]; 
            for(APXTConga4__Conga_Template__c temp : congaTemplate_List){
                congaTemplateMap.put(temp.id, temp);
            }
        } 
       //Manoj  
         List<ContentDocumentLink> contentDocumentsForCongaTemplate = New list<ContentDocumentLink>(); 
         List <APXTConga4__Conga_Template__c> congaTemplateList = new List <APXTConga4__Conga_Template__c> ();
        Set<Id> contDocLinkSet = new Set<Id>();
        for(Conga_Template_Version__c version:congaTemplateVersions){
              
            List<ContentDocumentLink> oldcontentDocuments = new list<ContentDocumentLink>(); 
           // List<ContentDocumentLink> toUpdate = [SELECT id,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:version.Id and LinkedEntity.Type='Conga_Template_Version__c' ORDER BY SystemModstamp DESC limit 1]; 
             System.debug('oldLinkMap '+oldLinkMap);
            
              if(version.Active__c && oldLinkMap.size()>0){
               // oldcontentDocuments.addAll([SELECT id,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:version.Conga_Template__c and LinkedEntity.Type='APXTConga4__Conga_Template__c']);
               // System.debug('deleted docs'+oldcontentDocuments);
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = oldLinkMap.get(version.Id).ContentDocumentId;
                cdl.LinkedEntityId = version.Conga_Template__c;
           		cdl.ShareType = 'V';
                System.debug('cdl '+cdl);
                contentDocumentsForCongaTemplate.add(cdl);
				//delete oldcontentDocuments;

                /*List <APXTConga4__Conga_Template__c> congaTemplate = [select id,Active_Template_Version__c from APXTConga4__Conga_Template__c where id=:version.Conga_Template__c];
            	congaTemplate[0].Active_Template_Version__c = version.Id;
                upsert congaTemplate; */
                APXTConga4__Conga_Template__c congaTemplate = congaTemplateMap.get(version.Conga_Template__c);
                congaTemplate.Active_Template_Version__c = version.Id;
                congaTemplateList.add(congaTemplate);
                System.debug('congaTemplate '+congaTemplate);
                //Adding value in set for deletion
                contDocLinkSet.add(oldLinkMap.get(version.Id).Id);
            }
             // insert contentDocumentsForCongaTemplate;
        }
        if(!contDocLinkSet.IsEmpty()){
            toDeleteContLink = [SELECT Id FROM ContentDocumentLink WHERE Id in :contDocLinkSet];
            Delete toDeleteContLink;
        }
         if(!congaTemplateList.IsEmpty()){
            upsert congaTemplateList;
        }
         if(!contentDocumentsForCongaTemplate.IsEmpty()){
            insert contentDocumentsForCongaTemplate;
        }
     

        
    }
    
    
    public static boolean activateVersion(list<ContentDocumentLink> newList){
        System.debug('New Content Document Link');
        Set<String> versionSet = new Set<String>();
        Map<id,ContentDocumentLink> congaTemplateVersion = new Map<id,ContentDocumentLink>(); 
        try{
              for(ContentDocumentLink nt : newList){            
            // pId stores the object code related to contentdocumentLink
            System.debug('link'+nt);
               String sObjName = nt.linkedentityid.getSObjectType().getDescribe().getName();
               system.debug('************>sObjName ='+ sObjName);
            if(sObjName == 'Conga_Template_Version__c'){ // checking whether the record is Conga_Template_Version__c or not
                congaTemplateVersion.put(nt.linkedentityid,nt);
                versionSet.add(nt.linkedentityid);
            }            
        }
        System.debug('List:'+congaTemplateVersion);
        List<Conga_Template_Version__c> congaTemplateVersions = [Select id, Active__c, Conga_Template__c,Version__c from Conga_Template_Version__c where id in :congaTemplateVersion.keySet()];
        List<ContentDocumentLink> contentDocumentsForCongaTemplate = New list<ContentDocumentLink>();  
        List<ContentDocumentLink> oldcontentDocuments = new list<ContentDocumentLink>(); 
        List<ContentDocumentLink> toUpdateList = new List<ContentDocumentLink>();
         Map<String,APXTConga4__Conga_Template__c> congaTemplateMap = new Map<String,APXTConga4__Conga_Template__c>();
       
        Map<String,ContentDocumentLink> oldLinkMap = new Map<String,ContentDocumentLink>();
         List <APXTConga4__Conga_Template__c> congaTemplateList = new List <APXTConga4__Conga_Template__c> ();
         List <APXTConga4__Conga_Template__c> congaTemplate_List = new List <APXTConga4__Conga_Template__c> ();
         Set<Id> contDocLinkSet = new Set<Id>();
        //Manoj
        Set<String> versionIdSet = new Set<String>(); 
        Set<String> congaTemplateIdSet = new Set<String>();
        //iterating congaTemplateVersions List : Manoj
       
        for(Conga_Template_Version__c version:congaTemplateVersions){
            versionIdSet.add(version.Id);
            congaTemplateIdSet.add(version.Conga_Template__c);
        }
         
        if(!versionIdSet.IsEmpty()){
            toUpdateList = [SELECT id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :versionIdSet AND LinkedEntity.Type='Conga_Template_Version__c' ORDER BY SystemModstamp DESC]; 
            for(ContentDocumentLink cd : toUpdateList){
                oldLinkMap.put(cd.LinkedEntityId, cd);
            }
        }
         if(!congaTemplateIdSet.IsEmpty()){
            congaTemplate_List = [select id,Active_Template_Version__c from APXTConga4__Conga_Template__c where id in :congaTemplateIdSet]; 
            for(APXTConga4__Conga_Template__c temp : congaTemplate_List){
                congaTemplateMap.put(temp.id, temp);
            }
        } 
        //Manoj
        for(Conga_Template_Version__c version:congaTemplateVersions){
          
            if(version.Active__c){
               // oldcontentDocuments.addAll([SELECT id,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:version.Conga_Template__c and LinkedEntity.Type='APXTConga4__Conga_Template__c']);
              
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = congaTemplateVersion.get(version.id).ContentDocumentId;
                cdl.LinkedEntityId = version.Conga_Template__c;
           		cdl.ShareType = 'V';
                contentDocumentsForCongaTemplate.add(cdl);
				//delete oldcontentDocuments;

            /*    List <APXTConga4__Conga_Template__c> congaTemplate = [select id,Active_Template_Version__c from APXTConga4__Conga_Template__c where id=:version.Conga_Template__c];
            	congaTemplate[0].Active_Template_Version__c = version.Id;
                upsert congaTemplate; */
                
                APXTConga4__Conga_Template__c congaTemplate = congaTemplateMap.get(version.Conga_Template__c);
                congaTemplate.Active_Template_Version__c = version.Id;
                congaTemplateList.add(congaTemplate);
                System.debug('congaTemplate '+congaTemplate);
                contDocLinkSet.add(oldLinkMap.get(version.Id).Id);
            }
        }
         if(!contDocLinkSet.IsEmpty()){
            List<ContentDocumentLink> toDeleteContLink = [SELECT Id FROM ContentDocumentLink WHERE Id in :contDocLinkSet];
            Delete toDeleteContLink;
        }
        if(!congaTemplateList.IsEmpty()){
            upsert congaTemplateList;
        }
        insert contentDocumentsForCongaTemplate;
        System.debug('DML:'+contentDocumentsForCongaTemplate);
        return true;
        }
         Catch(Exception ex){
            System.debug('Error caught : '+ex.getMessage());
            System.debug('Error caught : '+ex.getLineNumber());
        }
      return null;
    }
}