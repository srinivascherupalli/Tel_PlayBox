/*
Name        Date           Description
Divya       12/15/2020  Method to attach the order form file to PS
Shashank    03/09/2021  DIGI-17328-Convert Content Document to Attachment
Shashank    30/09/2021  DIGI-27894-Changed the attachmentContentType
*/
public with sharing class ContentDocumentLinkTriggerHelper {
    private Static String documentTitle = 'Order Form';
    private Static String recordTypeNamme = 'Schedule';
    private Static String attachmentContentType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';//DIGI-27894
         /*-------------------------------------------------------- 
EDGE-170431
Method: priceScheduleOFormFile
Description: Method to attach the order form file to PS
Author:Divya Chilakabathini
--------------------------------------------------------*/
    public static void attachOrderFormFilePS(list<ContentDocumentLink> newList) {
        system.debug('newList:'+newList);
        try
        {
            List<String> cntver = new List<String>();
            set<id> contractIdSet = new set<id>();
            set<id> accountIds = new set<id>();
            set<id> priceSchdIds = new set<id>();
            set<id> cntDocIdSet = new set<id>();
            List<Apttus__APTS_Agreement__c> agreementRecords = new List<Apttus__APTS_Agreement__c>();
            Set<String> statusCategory = new Set<String>{'Request','In Authoring','In Signatures','In Effect','Cancelled'};
            String sName = 'ContractJunction__c';
            List<contentversion> cvList = new List<contentversion>();
            List<ContractJunction__c> contractJun = new List<ContractJunction__c>();
            
            for(ContentDocumentLink cdRec : newList){
                cntDocIdSet.add(cdRec.ContentDocumentId);
            }
            system.debug('cntDocIdSet:'+cntDocIdSet);
            // querying on contentversion to check the title of the file whether it is order form or not
            if(!cntDocIdSet.isEmpty()){
                //DIGI-17328-Added VersionData,FileExtension in following query
                cvList = [select ContentDocumentId, Title, VersionData,FileExtension from contentversion Where ContentDocumentId IN: cntDocIdSet]; //newList[0].ContentDocumentId];
            }
            system.debug('cvList:'+cvList);
            //forming the list of titlte from content version
            if(!cvList.isEmpty()){
                for(contentversion cv : cvList){
                    cntver.add(cv.Title);
                }
            }
            // newList Contains contentdocumentLink records which are newly inserted. 
            // getting the linked entity id if the sobject id contractjunction__C
            for(ContentDocumentLink nt : newList){ 
                String sObjName = nt.linkedentityid.getSObjectType().getDescribe().getName();
                system.debug('sObjName:'+sObjName);
                if (sObjName == sName) {
                    if(!cntver.isEmpty()){
                        for(String cvTitle : cntver){
                            system.debug('cvTitle:'+cvTitle);
                            if(cvTitle.contains(documentTitle)){
                                contractIdSet.add(nt.linkedentityid);
                            }
                        }
                    }
                }             
            }
            system.debug('contractIdSet:'+contractIdSet);
            //quering the account id from the contract junction object
            if(!contractIdSet.isEmpty()){
                contractJun = [Select Id,Related_Opportunity__r.AccountId,isDSAGenerated__c,Related_Price_Schedule__c from ContractJunction__c where Id IN:contractIdSet];
            }
            system.debug('contractJun:'+contractJun);
            
            if(!contractJun.isEmpty()){
                for(ContractJunction__c cjId :  contractJun){
                    //checking if PS is not null in the contract junction record
                    if(cjId.Related_Price_Schedule__c != null){//cjId.isDSAGenerated__c
                        accountIds.add(cjId.Related_Opportunity__r.AccountId);
                    }
                }
            }
            //fetching the latest price schedule record of that particular account record.
            if(!accountIds.isEmpty()){
                agreementRecords = [Select Id,Apttus__Account__c from Apttus__APTS_Agreement__c Where APTPS_Record_Type_Name__c =:recordTypeNamme AND Apttus__Account__c IN: accountIds AND Apttus__Status_Category__c IN: statusCategory order by createddate desc limit 1];            
            }
            List<ContentDocumentLink> cd=new List<ContentDocumentLink>();
            //DIGI-17328-Start
            Attachment attachmentForSuccess;
            for(ContentDocumentLink nt : newList)
            {
                if(!agreementRecords.isEmpty()){
                    for(Apttus__APTS_Agreement__c ag : agreementRecords)
                    {
                        system.debug('ag:'+ag);
                        ContentDocumentLink cd1=new ContentDocumentLink();
                        cd1.ShareType='V';
                        cd1.Visibility='AllUsers';
                        cd1.linkedEntityId = ag.Id;
                        cd1.ContentDocumentId = nt.ContentDocumentId;
                        cd.add(cd1);
                        
                        for(contentversion cv2 : cvList){
                            if(cv2.ContentDocumentId == nt.ContentDocumentId && cv2.Title.contains(documentTitle)){
                                attachmentForSuccess = new Attachment();
                                attachmentForSuccess.Body = cv2.VersionData; 
                                attachmentForSuccess.ParentId = ag.Id;
                                attachmentForSuccess.Name = cv2.Title;
                                //attachmentForSuccess.Name = cv2.Title+'.'+cv2.FileExtension;
                                attachmentForSuccess.ContentType = attachmentContentType;
              }
                        }
                        
                    }
                }
            }
            // inserting the file for the price schedule record as a attachment
            /*
            if(!cd.isEmpty()){
                insert cd;
            }*/
            //Insert the Order Form attachment for the PS
            if(attachmentForSuccess != null){
                database.insert(attachmentForSuccess) ;
            }
            //DIGI-17328-End
            
        }catch(Exception ex){
            system.debug('Exception:::: ContentDocumentLinkTriggerHandler Class:::: priceScheduleOFormFile Method'+ Ex.getMessage());
        }
    }

}