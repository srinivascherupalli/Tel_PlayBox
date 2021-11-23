/* 
 * AttachmentTrigger helper class 
 * Help AttachmentTrigger to create and delete PDFs
 * 
 * @story : EDGE-9883
 * @author : Om Deshmukh
 */
public with sharing class AttachmentTriggerHelper {
    public static Set<String> prefixIds = new Set<String>();
      public Static Set<String> lstObjNames = new Set<String>();
      /**
      * This method generate QuotePDFs using exsting pdf (By default conga create quote pdf in notes & attachment related list) 
      * After successful creation of quote, delete all pdf available in notes and attachment section (to avaoid duplication of pdf)
      * 
      * @param : Map<Id, Attachment> : attachmentMap
      * @return : void 
      */
      public void performQuoteCreationAndAttachmentDeletion(Map<Id, Attachment> attachmentMap){
          try{
              system.debug('attachmentMap>>' + attachmentMap);
              Set<Id> parentIdSet = new Set<Id>();
              Map<Id, Attachment> attachmentMapWithPIds = new Map<Id, Attachment>();
              for(Attachment attachment : attachmentMap.values()){
                  parentIdSet.add(attachment.ParentId);
                  attachmentMapWithPIds.put(attachment.ParentId, attachment);
              }
              Map<id,cscfga__Product_Basket__c> mapProductBasketTobeUpdated = new Map<id,cscfga__Product_Basket__c>();
              List<Quote> quoteList = [SELECT Id,Conga_Status__c,Product_Basket__c,isAttachmentAvailable__c FROM quote 
                                      WHERE Id IN :parentIdSet AND (Product_Basket__c != NULL OR Frame_Agreement__c!=null)];// Added Frame Agreement condition EDGE-176683
              Set<Id> quoteIdSet = new Set<Id>();
              if(!quoteList.isEmpty()){
                  for(Quote q : quoteList){
                      quoteIdSet.add(q.Id);
                      q.Conga_Status__c = 'Success'; 
                      q.isAttachmentAvailable__c = true;
                      if(q.Product_Basket__c!=null){// Added condition EDGE-176683
                      mapProductBasketTobeUpdated.put(q.Product_Basket__c, 
                            new cscfga__Product_Basket__c(id=q.Product_Basket__c, QuoteGenerated__c = true)); 
                      }                         
                  }
              }
              
              
            if(!mapProductBasketTobeUpdated.isEmpty()){
              update mapProductBasketTobeUpdated.values();
            }  
            if(!quoteList.isEmpty()){
              update quoteList;
            } 
              for(Id parentId : parentIdSet){
                  if(!quoteIdSet.contains(parentId)){
                      attachmentMapWithPIds.remove(parentId);
                  }
              }
              CreateQuotePDFDeleteAttachment(attachmentMapWithPIds);
          }catch(Exception e){
              System.debug(e.getMessage());
          }
      }
  
      /**
       * This method create Quote PDF and delete attachments
       *
       * @param : Map<Id, Attachment> : attachmentMapWithPIds
       * @return : void
       */
      public void CreateQuotePDFDeleteAttachment(Map<Id, Attachment> attachmentMapWithPIds){
          try{
              Set<Id> quoteIds = attachmentMapWithPIds.keySet();
              List<QuoteDocument> quoteDocs = new List<QuoteDocument>();
              for(Id quoteId : quoteIds){
                  QuoteDocument quoteDoc = new QuoteDocument();
                  quoteDoc.QuoteId = quoteId;
                  quoteDoc.Document = attachmentMapWithPIds.get(quoteId).body;
                  quoteDocs.add(quoteDoc);
              }
  
              if(!quoteDocs.isEmpty()){
                  insert quoteDocs;
                  
                  List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE parentId IN : quoteIds];
                  if (!attachmentList.isEmpty()) {
                      system.debug('deletion started');
                      AttachmentService.deleteAttachment(attachmentList);
                  }
                  System.debug('QuotePDF has been generated successfully!!!');
              }          
            
          }catch(Exception e){
              system.debug('Exception occurred during insertion and deletion of attachment for quote : '+ e.getMessage() +' : '+e.getLineNumber());
          }
      }
      
      Public Static void cleanUpAttachments(List<Attachment> lstattachment){
          system.debug('G*G cleanUpAttachments called');
          Map<Id, Attachment> attachmentMap = new Map<Id, Attachment>();
          /*
          * * Below code is executed when the Attachment is created only for Quote Object
          */
          Set<String> setprefixIds = new Set<String>();
          Set<String> lstObjNames = AttachmentService.getallObjectName();
          Set<String> apttusAgreementIdSet = new Set<String>(); // Added as part of DIGI-33094 by Gautam Kumar
          system.debug('lstObjNames>>>' + lstObjNames);
          if(!lstObjNames.isEmpty())
              setprefixIds = AttachmentService.getKeyPrefix(lstObjNames);
          
          system.debug('setprefixIds>>' + setprefixIds);
          for(Attachment att : lstattachment){
              if(setprefixIds.contains(String.valueOf(att.parentId).substring(0, 3))){ // it will check the if Attachment Parent id start with Quote Object
                  attachmentMap.put(att.id,att);
              }
              // Added as part of DIGI-33094 by Gautam Kumar
              if(att.parentId != null && String.ValueOf(att.parentId.getSobjectType()) == 'Apttus__APTS_Agreement__c'){
                  apttusAgreementIdSet.add(att.parentId);
              }
          }
          if(!attachmentMap.isEmpty()){
              AttachmentTriggerHelper helper = new AttachmentTriggerHelper();
              helper.performQuoteCreationAndAttachmentDeletion(attachmentMap);
          }
  
          // Added as part of DIGI-33094 by Gautam Kumar
          if(!apttusAgreementIdSet.isEmpty() && FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion')
          && FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')) insertTransactionLogs(apttusAgreementIdSet);
  
      }
     // Public Static void attachmentUpdateHandler(map<id,SObject> newattmap,map<id,SObject>oldattmap){
      Public Static void onTRAMASAttachmentsUpdate(map<id,SObject> newattmap,map<id,SObject>oldattmap){
      //system.debug('in AttachmentTriggerHelper'+attachmentlist);
     Map<id,Sobject> newSobjectMap= new Map<id,Sobject>();
     
          for(sobject a:newattmap.values()){
              if(String.valueOf((((Attachment)newattmap.get(a.id)).ParentId).getSObjectType())=='TramasElgibilityCallbackResponse__c'){
                 newSobjectMap.put(a.id,a);
              }
          }
          /*if(newSobjectMap.size()>0)
          TramasEligiblityUpdate.tamasAttachmentsUpdate( newattmap,oldattmap);*/ 
      }
      //Start EDGE - 94797
      Public Static void onCallbackTRAMASAttachmentsUpdate(map<id,SObject> newAttMap,map<id,SObject>oldAttMap){
      system.debug('in AttachmentTriggerHelper');
    String parentObj = 'MobileTramasElgibility__c';
    String parentObject='TramasElgibilityCallbackResponse__c';
     Map<id,Sobject> newSobjectMap= new Map<id,Sobject>();
     Map<id,Sobject> tramasElgSobjectMap= new Map<id,Sobject>();
     
          for(sobject attachRec:newAttMap.values()){
              system.debug('OBJECTName'+String.valueOf((((Attachment)newAttMap.get(attachRec.id)).ParentId).getSObjectType()));
              if(String.valueOf((((Attachment)newAttMap.get(attachRec.id)).ParentId).getSObjectType())==parentObj){
                 newSobjectMap.put(attachRec.id,attachRec);
                 system.debug('INSIDEMobileobject');
              }
              if(String.valueOf((((Attachment)newAttMap.get(attachRec.id)).ParentId).getSObjectType())==parentObject){
                  tramasElgSobjectMap.put(attachRec.id,attachRec);
                  system.debug('INSIDETRAMASobject');
              }
          }
         // system.debug('INSIDETRAMASobject'+tramasElgSobjectMap);
          /*Map<id,Sobject> newSobjectMapTemp= new Map<id,Sobject>();
          for(sobject attachRec1:newAttMap.keySet()){
              newSobjectMapTemp.put(attachRec1.id, newAttMap.get(attachRec1.id))
              //if(attachRec1.id == 'Body'){
                //  newSobjectMapTemp.put(attachRec1.id,newAttMap.get(attachRec1.id).toString());
              //}
              }
          system.debug('@@@@New New Map' + newSobjectMapTemp);*/
          /*for(Id AttachRec1:newAttMap.keySet()){
              system.debug('Id : ' + AttachRec1);
              system.debug('Value : ' + newAttMap.get(AttachRec1));
          }*/
         // System.debug('@@@@@newMap-------->'+newAttMap);
          List<Id> recordId = new List<Id>();
          List<Id> parentId = new List<Id>();
          List<String> attachBody = new List<String>();
          if(newSobjectMap.size()>0 || tramasElgSobjectMap.size()>0){
          for(sobject attachRec:newAttMap.values()){
              system.debug('MyValue@@@' + (((Attachment)newAttMap.get(attachRec.id)).ParentId));
              recordId.add((((Attachment)newAttMap.get(attachRec.id)).Id));
              parentId.add((((Attachment)newAttMap.get(attachRec.id)).ParentId));
              attachBody.add((((Attachment)newAttMap.get(attachRec.id)).Body).toString());
          }
          }
          
          //system.debug('RecordIdList@@@' + recordId);
          //system.debug('ParentIdList@@@' + parentId);
          //system.debug('AttachBody@@@' + attachBody);
         // if(newSobjectMap.size()>0)
          
            //  TramasCallbackResponseUpdate.tamasAttachmentsUpdate( newattmap,oldattmap);
              
              if(!Test.isRunningTest()){
             // System.debug('@@@@@newMap-------->'+newAttMap);
             // System.debug('@@@@@OldMap-------->'+oldAttMap);
             // System.debug('@@@@@Trigger.newMap-------->'+JSON.serialize(newAttMap));
             // System.debug('@@@@@Trigger.OldMap-------->'+JSON.serialize(oldAttMap));
              //newAttMap = newAttMap[0].Body.toString()    
                  
        //In below statement map is being converted to string as the arguments are being passed to a future method and future callout only supports primitve datatypes.
              //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(JSON.serialize(newAttMap),JSON.serialize(oldAttMap));
              if(newSobjectMap.size()>0){
                  system.debug('MObileTramasObjectblock');
              TramasCallbackResponseUpdate.tamasAttachmentsUpdate(recordId,parentId,attachBody);
              }
              
              if(tramasElgSobjectMap.size()>0){
                  system.debug('TramasEligibilityObjectblock');
                  TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,attachBody);
              }
  }
      }
      //End EDGE - 94797
      
      public static void setStatusToSuccessAndPublishEvent(List<Attachment> listOfAttachment) {
          Map<Id, Attachment> mapOfOpportunityIdToAttachment = new Map<Id, Attachment>();
          Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
          Schema.SObjectType sobjType = gd.get('Opportunity');
          Schema.DescribeSObjectResult r = sobjType.getDescribe();
          String OpptyPrefix = r.getKeyPrefix();
          List<Attachment> listOfProposalAttachment = new List<Attachment>();
          for(Attachment att : listOfAttachment){
              if(String.valueOf(att.parentId).substring(0, 3) == OpptyPrefix) {
                  mapOfOpportunityIdToAttachment.put(att.ParentId, att);
              }
          }
          List<Opportunity> listOfOpportunity = new List<Opportunity>();
          if(!mapOfOpportunityIdToAttachment.isEmpty()) {
              listOfOpportunity = [SELECT Id,Conga_Status__c, Product_Type__c 
                                          FROM Opportunity 
                                          WHERE Id IN: mapOfOpportunityIdToAttachment.keySet()];
          }
          List<DocumentGenerationNotification__e> listOfPlatformEvent = 
              new List<DocumentGenerationNotification__e>(); 
          List<Opportunity> listOfOpportunityToUpdate = new List<Opportunity>();
          for(Opportunity opp : listOfOpportunity) {
              if(opp.Product_Type__c == 'Non Modular' && 
                  opp.Conga_Status__c == 'InProgress'){
                  opp.Conga_Status__c = 'Success';
                  listOfOpportunityToUpdate.add(opp);
                  if(mapOfOpportunityIdToAttachment != null 
                      && mapOfOpportunityIdToAttachment.containsKey(opp.Id)) {
                      DocumentGenerationNotification__e docGeneratingNotification = 
                      platformEventPublisher.createProposalPlatformEvent(opp, mapOfOpportunityIdToAttachment.get(opp.Id));
                      if(docGeneratingNotification != null) {
                          listOfPlatformEvent.add(docGeneratingNotification);
                      }
                  }
              }
          }
          if(!listOfOpportunityToUpdate.isEmpty()){
              update listOfOpportunityToUpdate;
          }
          List<Database.SaveResult> results = new List<Database.SaveResult>();
          if(!listOfPlatformEvent.isEmpty()) {
              results = EventBus.publish(listOfPlatformEvent);  
          }
          
          for (Database.SaveResult sr : results) {
              if (sr.isSuccess()) {
                  System.debug('Successfully published event.');
              } else {
                  for(Database.Error err : sr.getErrors()) {
                      System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                  }
              }
          }
      }
  
        /**
        * @description 
        * @author Rohit Pal | 08-23-2021 
        **/
        public static void createSubscriptionPlatformEvent( Map<Id, Attachment> newAttachmentsMap){
            List<Technical_Object_Creation_Event__e> eventTechnicalObjectCreationList = new List<Technical_Object_Creation_Event__e>();
            List<Database.SaveResult> dataSaveResultList = new List<Database.SaveResult>();
            for (Attachment iterator : newAttachmentsMap.values()) {
                eventTechnicalObjectCreationList.add(PublishInventoryEvents.publishTechnicalObjectCreationEvent(iterator.id , iterator.ParentId));
                system.debug('createSubscriptionPlatformEvent :: found eventTechnicalObjectCreationList ---> '+ eventTechnicalObjectCreationList);
            }
            if (!eventTechnicalObjectCreationList.isEmpty()) {
                dataSaveResultList = EventBus.publish(eventTechnicalObjectCreationList);
                system.debug('createSubscriptionPlatformEvent :: found dataSaveResultList ---> '+ dataSaveResultList);
                //logApplicationLog(null,ServiceSpecEventList,saveRes);
            }
        }
    
      /*  
      * Method Name : insertTransactionLogs
      * Author : Gautam Kumar
      * Jira : DIGI-33094 & DIGI-11211
     */
      
      public static void insertTransactionLogs(Set<String> apttusAgreementIdSet){
          
          system.debug('G*G insertTransactionLogs AttachmentTriggerHelper outer called '+ apttusAgreementIdSet);
          
          for(Apttus__APTS_Agreement__c apttusAgreement : [select Id, Apttus__Account__c, Apttus__Source__c, Apttus__Status__c, Apttus__Parent_Agreement__c,
                                                          Apttus__Related_Opportunity__c, Apttus__Related_Opportunity__r.Type, Related_Basket__c, 
                                                          Related_Basket__r.Name, Related_Contract__c, Delegated_Pricing_Request__c
                                                           from Apttus__APTS_Agreement__c
                                                           where Id In: apttusAgreementIdSet
                                                           And Apttus__Parent_Agreement__c = null
                                                           LIMIT 50000]){
                                                               system.debug('G*G outer if ');
                                                               if(apttusAgreement.Apttus__Account__c != null && apttusAgreement.Apttus__Source__c != 'Internal Digital'){
                                                                   system.debug('G*G inner if ');
                                                                   string corId = apttusAgreement.Apttus__Account__c + '-' + apttusAgreement.Id;
                                                                   Map<String,Object> loggerdetailsMap=new Map<String,Object>();
                                                                   loggerdetailsMap.put('event','Legacy Contract generation completed');
                                                                   loggerdetailsMap.put('AgreementType','Legacy');
                                                                   loggerdetailsMap.put('AgreementStatus',apttusAgreement.Apttus__Status__c);
                                                                   TransactionLogger.insertTransactionLogs(corId,loggerdetailsMap,'AttachmentTriggerHelper');
                                                               }
                                                               else{
                                                                      if(apttusAgreement.Delegated_Pricing_Request__c != null && apttusAgreement.Apttus__Account__c != null
                                                                      && apttusAgreement.Apttus__Related_Opportunity__c != null){
                                                                          string corId = apttusAgreement.Apttus__Related_Opportunity__c + '-' + apttusAgreement.Apttus__Account__c;
                                                                          Map<String,Object> loggerdetailsMap=new Map<String,Object>();
                                                                          loggerdetailsMap.put('event','FAM Contract generation completed');
                                                                          loggerdetailsMap.put('OrderType', apttusAgreement.Apttus__Related_Opportunity__r.Type);
                                                                          TransactionLogger.insertTransactionLogs(corId,loggerdetailsMap,'AttachmentTriggerHelper');
                                                                      }
                                                                      else if(apttusAgreement.Related_Basket__c != null && apttusAgreement.Related_Contract__c != null
                                                                      && apttusAgreement.Apttus__Related_Opportunity__c != null){
                                                                          string corId = apttusAgreement.Apttus__Related_Opportunity__c + '-' + apttusAgreement.Related_Basket__c;
                                                                          Map<String,Object> loggerdetailsMap=new Map<String,Object>();
                                                                          loggerdetailsMap.put('event','Contract generation completed');
                                                                          loggerdetailsMap.put('OrderType', apttusAgreement.Apttus__Related_Opportunity__r.Type);
                                                                          loggerdetailsMap.put('basketName', apttusAgreement.Related_Basket__r.Name);
                                                                          TransactionLogger.insertTransactionLogs(corId,loggerdetailsMap,'AttachmentTriggerHelper');
                                                                      }
                                                               }
                                                           }
          
      }
  }