/*****************************************************************************
@Name: ContentDocumentLinkContract
@Author: Maqsood Alam.
@CreateDate: 30/07/2018.
@Description: This Class is Helper for ContentDocumentLinkTrigger Trigger for contract.

*******************************************************************************/
public without sharing class ContentDocumentLinkContract{

    public static void modifiedContractFlag(list<ContentDocumentLink> newList , string UpdOrDelOrIns) {
       
       list<id> contractId = new list<id>(); 
          for(ContentDocumentLink nt : newList){            
           // pId stores the object code related to contentdocumentLink
               String sObjName = nt.linkedentityid.getSObjectType().getDescribe().getName();
              system.debug('************>sObjName ='+sObjName);
           if(sObjName == 'ContractJunction__c'){ // checking whether the record is ContractJunction__c or not
               contractId.add(nt.linkedentityid);
           }            
       }
       if(UpdOrDelOrIns == 'fileGenerate')
       {
       List<ContractJunction__c> contractlist=new List<ContractJunction__c>();
       List<ContentDocumentLink> OrderformFile =new List<ContentDocumentLink>();
       if(!contractId.isEmpty()){                  
           //querying ContractJunction__c record 
           contractlist = [select id, isAgreementGenerated__c,isOrderFormGenerated__c from ContractJunction__c where Id IN: contractId];
           //EDGE-169277 start
           OrderformFile = [SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.Id, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId IN:contractId and ContentDocument.Title LIKE '%Order Form%'];
           //EDGE-169277 End
           if(!contractlist.isEmpty()){
             
               for(ContractJunction__c CJ : contractlist){    
                   
                   if(UpdOrDelOrIns == 'fileGenerate'){
                       
                   //Updating the field isAgreementGenerated__c  in ContractJunction__c
                   CJ.isAgreementGenerated__c= true;
                   //EDGE-169277start
                   if(OrderformFile.size()>0 && !OrderformFile.isEmpty())
                       CJ.isOrderFormGenerated__c= true; 
                   }
                    //EDGE-169277End
               }   
           } 
       }
       if(!contractlist.isEmpty()){
           update contractlist;
       }
      }
     //Added as part of US 37402 
     if(UpdOrDelOrIns == 'fileGenerate' || UpdOrDelOrIns =='fileDelete')
       {
           countFilesAttachedToContract(contractId);   
       }
        
   } 
  public static void countFilesAttachedToContract(List<ID> contractId) {
       
      
       if(!contractId.isEmpty())
       {                  
          //Querying ContentDocumentLink to get all attached file on contract        
          List<ContentDocumentLink> fileAttachedList = [SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.Id, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM ContractJunction__c) and LinkedEntity.Type='ContractJunction__c' and LinkedEntityId IN:contractId ];
          
          // This map contains key:contract Id and value : set of ContentDocument attached on that contract
          Map<id,Set<id>> contractAndAttachmentMap = new  Map<id,Set<id>>();
          list<opportunity> updateOppList = new list<opportunity>();
          List<ContractJunction__c> contractRecordList =new List<ContractJunction__c>();
          system.debug('fileAttachedList.isEmpty()->'+fileAttachedList.isEmpty());
          if(!fileAttachedList.isEmpty())
           {   
               for(ContentDocumentLink obj : fileAttachedList)
               {    
                   if((contractAndAttachmentMap.keySet()).contains(obj.LinkedEntityId))
                   {
                      
                       Set<id> contentDocumentAttached=new Set<id>();
                       contentDocumentAttached=contractAndAttachmentMap.get(obj.LinkedEntityId);
                       contentDocumentAttached.add(obj.ContentDocument.Id);
                       contractAndAttachmentMap.put(obj.LinkedEntityId,contentDocumentAttached);
                   }
                   else
                   { 
                       Set<id> contentDocumentAttached1=new Set<id>();
                       contentDocumentAttached1.add(obj.ContentDocument.Id);
                       contractAndAttachmentMap.put(obj.LinkedEntityId,contentDocumentAttached1);
                   }
               }
           
               //querying ContractJunction__c to get related Opportunity
               contractRecordList = [Select id,name,Related_Opportunity__r.id from ContractJunction__c where id IN : contractAndAttachmentMap.keySet()];
               
               for(ContractJunction__c c : contractRecordList)
               {
                   opportunity relatedOpp = new opportunity(); 
                   relatedOpp.Id = c.Related_Opportunity__r.id;
                   relatedOpp.Contract_Attachment_Count__c = (contractAndAttachmentMap.get(c.id)).size();
                   updateOppList.add(relatedOpp);
               }
           }
           else{
               contractRecordList = [Select id,name,Related_Opportunity__r.id from ContractJunction__c where id IN :contractId];   
               for(ContractJunction__c c : contractRecordList)
               {
                   opportunity relatedOpp = new opportunity(); 
                   relatedOpp.Id = c.Related_Opportunity__r.id;
                   relatedOpp.Contract_Attachment_Count__c = 0;
                   updateOppList.add(relatedOpp);
               }               
           }
              
               
               
               
               if(!updateOppList.isEmpty())
               {
                   System.debug('updateOppList-->'+updateOppList);
                   update updateOppList;
               }
               
               

       }
   }
   
   public static void modifyFileVisibility(list<ContentDocumentLink> newList , string UpdOrDelOrIns) {
       for(ContentDocumentLink nt : newList){            
           // pId stores the object code related to contentdocumentLink
           String sObjName = nt.linkedentityid.getSObjectType().getDescribe().getName();
           if(sObjName == 'ContractJunction__c' && UpdOrDelOrIns == 'ChangeVisibility'){ // checking whether the record is ContractJunction__c or not
               nt.Visibility = 'AllUsers';
           }            
       }
   }
   //EDGE-58811 Start    
   public static string getUserEmail(Id ownerId) {
       list<User> userDetails=new List<User>();
       userDetails = [SELECT ID, Email from USER WHERE ID = : ownerId];
       if(userDetails.size() > 0){
           return userDetails[0].Email;
       }
       return 'test@team.telstra.com';
   }
   //EDGE-58811 End

   public static boolean shareAgreementVariation(Id priceScheduleId) {
       Id currentUser = UserInfo.getUserId();
       list<Apttus__APTS_Agreement__Share> shareAgreementList = new list<Apttus__APTS_Agreement__Share>();
       list<Apttus__APTS_Agreement__Share> shareDetail = [SELECT Id, UserOrGroupId FROM Apttus__APTS_Agreement__Share WHERE UserOrGroupId =: currentUser  AND ParentId =: priceScheduleId];
           if(shareDetail.size() == 0){
               Apttus__APTS_Agreement__Share agmtShare = New Apttus__APTS_Agreement__Share();
               // Set the ID of record being shared.
               agmtShare.ParentId = priceScheduleId;
               // Set the ID of user or group being granted access.
               agmtShare.UserOrGroupId = currentUser;
               // Set the access level.
               agmtShare.AccessLevel = 'Edit';
               shareAgreementList.add(agmtShare);
           }
       
       if(shareAgreementList.size() > 0)
       INSERT shareAgreementList;
       return true;
   }
   // ----------- DIGI-687 : Retract agreement when contract is retracted ------------------
   // Maq | Eureka
   public static boolean updateAgreementOnRetract(Apttus__APTS_Agreement__c retractedAgreement) {
       list<Apttus__APTS_Agreement__c> updateAgreementList = new list<Apttus__APTS_Agreement__c>();
       Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
       String agmtStatus = 'Being Amended';
       If(retractedAgreement != NULL){
       list<Apttus__APTS_Related_Agreement__c> activateAgreementPrevious = [SELECT name, Id, Apttus__APTS_Contract_From__r.Id, Apttus__APTS_Contract_From__r.name, Apttus__APTS_Contract_To__r.Apttus__Status__c,Apttus__APTS_Contract_From__r.Apttus__Status__c, Apttus__APTS_Contract_From__r.Apttus__Version_Number__c, Apttus__APTS_Contract_To__r.name, Apttus__APTS_Contract_To__c, Apttus__Relationship_To_Type__c FROM Apttus__APTS_Related_Agreement__c WHERE Apttus__APTS_Contract_From__r.Apttus__Status__c =: agmtStatus AND Apttus__APTS_Contract_To__r.Apttus__Status__c !=: agmtStatus AND Apttus__APTS_Contract_To__c =: retractedAgreement.Id limit 1];
           if(activateAgreementPrevious.size() > 0){
               Apttus__APTS_Agreement__c agmtCancelled = New Apttus__APTS_Agreement__c();
               agmtCancelled.Id = retractedAgreement.Id;
               agmtCancelled.Apttus__Status_Category__c = 'Cancelled';
               agmtCancelled.Apttus__Status__c = 'Cancelled Request';
               updateAgreementList.add(agmtCancelled);

               Apttus__APTS_Agreement__c agmtActivate = New Apttus__APTS_Agreement__c();
               agmtActivate.Id = activateAgreementPrevious[0].Apttus__APTS_Contract_From__r.Id;
               agmtActivate.Apttus__Status_Category__c = '  In Effect';
               agmtActivate.Apttus__Status__c = 'Activated';
               updateAgreementList.add(agmtActivate);
           }
           else {
               if(retractedAgreement.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID){
                   Apttus__APTS_Agreement__c agmtPSCancelled = New Apttus__APTS_Agreement__c();
                   agmtPSCancelled.Id = retractedAgreement.Id;
                   agmtPSCancelled.Apttus__Status_Category__c = 'Cancelled';
                   agmtPSCancelled.Apttus__Status__c = 'Cancelled Request';
                   updateAgreementList.add(agmtPSCancelled);
   
                   Apttus__APTS_Agreement__c agmtSACancelled = New Apttus__APTS_Agreement__c();
                   agmtSACancelled.Id = retractedAgreement.Apttus__Parent_Agreement__c;
                   agmtSACancelled.Apttus__Status_Category__c = 'Cancelled';
                   agmtSACancelled.Apttus__Status__c = 'Cancelled Request';
                   updateAgreementList.add(agmtSACancelled);
               }
           }
       
       if(updateAgreementList.size() > 0)
       UPDATE updateAgreementList;
       return true;
       }
       return false;
   }
   //DIGI-19515 Start
    public static list<Apttus__APTS_Agreement__c> shareAgreements(Id accountId) {
        List<Apttus__APTS_Agreement__c> agreementsInAcc = [SELECT Id,Apttus__Source__c,RecordTypeId,Apttus__Account__c,Apttus__Parent_Agreement__c,Apttus__Status_Category__c,Name,Related_Basket__r.Name,Related_Basket__r.csbb__Account__c,Related_Contract__r.Account__r.APTPS_Contract_Manager__c, (SELECT Name, Product__c,Apttus__ProductId__r.Telstra_Marketable_Product_Family__c FROM Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c where Apttus__Account__c =:accountId AND Apttus__Status_Category__c=:APTPS_Constants.apttusStatusCategory AND Apttus__Status__c != 'Cancelled Request'];
        system.debug('agreementsInAcc@@'+agreementsInAcc);
        List<Id> agmstIdList = new List<Id>();
        List<Id> shareAgList = new List<Id>();
        for(Apttus__APTS_Agreement__c ag:agreementsInAcc){
            agmstIdList.add(ag.id);
        }
        Id currentUser = UserInfo.getUserId();
        list<Apttus__APTS_Agreement__Share> shareAgreementList = new list<Apttus__APTS_Agreement__Share>();
        list<Apttus__APTS_Agreement__Share> shareDetail = [SELECT Id, UserOrGroupId,ParentId FROM Apttus__APTS_Agreement__Share WHERE UserOrGroupId =: currentUser  AND ParentId in :agmstIdList];
        for(Apttus__APTS_Agreement__Share agShare:shareDetail){
           shareAgList.add(agShare.ParentId);
        } 
        system.debug('shareDetail@@'+shareDetail);
        for(Apttus__APTS_Agreement__c agmst:agreementsInAcc){
            if(!shareAgList.contains(agmst.id)){
                system.debug('agmst::'+agmst);
               Apttus__APTS_Agreement__Share agmtShare = New Apttus__APTS_Agreement__Share(); 
                // Set the ID of record being shared.
                agmtShare.ParentId = agmst.Id;
                // Set the ID of user or group being granted access.
                agmtShare.UserOrGroupId = currentUser;
                // Set the access level.
                agmtShare.AccessLevel = 'Edit';
                shareAgreementList.add(agmtShare);
            }
        }
        system.debug('shareAgreementList::'+shareAgreementList);
        if(shareAgreementList.size() > 0)
        INSERT shareAgreementList;
        return agreementsInAcc;
        
    }
    //DIGI-19515 End
   public static list<Apttus__APTS_Agreement__c> shareAgreementsBulk(Set<String> accountId) {
        List<Apttus__APTS_Agreement__c> agreementsInAcc = [SELECT Id,Apttus__Source__c,RecordTypeId,Apttus__Account__c,Apttus__Parent_Agreement__c,Apttus__Status_Category__c,Name,Related_Basket__r.Name,Related_Basket__r.csbb__Account__c,Related_Contract__r.Account__r.APTPS_Contract_Manager__c, (SELECT Name, Product__c,Apttus__ProductId__r.Telstra_Marketable_Product_Family__c FROM Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c where Apttus__Account__c IN:accountId AND Apttus__Status_Category__c=:APTPS_Constants.apttusStatusCategory AND Apttus__Status__c != 'Cancelled Request'];
        system.debug('agreementsInAcc@@'+agreementsInAcc);
        List<Id> agmstIdList = new List<Id>();
        List<Id> shareAgList = new List<Id>();
        for(Apttus__APTS_Agreement__c ag:agreementsInAcc){
            agmstIdList.add(ag.id);
        }
        Id currentUser = UserInfo.getUserId();
        list<Apttus__APTS_Agreement__Share> shareAgreementList = new list<Apttus__APTS_Agreement__Share>();
        list<Apttus__APTS_Agreement__Share> shareDetail = [SELECT Id, UserOrGroupId,ParentId FROM Apttus__APTS_Agreement__Share WHERE UserOrGroupId =: currentUser  AND ParentId in :agmstIdList];
        for(Apttus__APTS_Agreement__Share agShare:shareDetail){
           shareAgList.add(agShare.ParentId);
        } 
        system.debug('shareDetail@@'+shareDetail);
        for(Apttus__APTS_Agreement__c agmst:agreementsInAcc){
            if(!shareAgList.contains(agmst.id)){
                system.debug('agmst::'+agmst);
               Apttus__APTS_Agreement__Share agmtShare = New Apttus__APTS_Agreement__Share(); 
                // Set the ID of record being shared.
                agmtShare.ParentId = agmst.Id;
                // Set the ID of user or group being granted access.
                agmtShare.UserOrGroupId = currentUser;
                // Set the access level.
                agmtShare.AccessLevel = 'Edit';
                shareAgreementList.add(agmtShare);
            }
        }
        system.debug('shareAgreementList::'+shareAgreementList);
        if(shareAgreementList.size() > 0)
        INSERT shareAgreementList;
        return agreementsInAcc;
      }

}