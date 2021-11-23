/**
* 
* @author       : Gautam Kumar
* @version      : 1.0
* @createdDate  : 07/10/2021 
* @Type         : Apex Class
* @Test Class   : APTPS_EchoSignAgreementEventTrgTest
* @Description  : echosign_dev1__SIGN_AgreementEvent__c object's trigger handler based on SYS_TriggerHandler
*
**/
public with sharing class APTPS_EchoSignAgreementEventTrgHandler extends SYS_TriggerHandler{ 

    //constructor
    public APTPS_EchoSignAgreementEventTrgHandler(Schema.SObjectType sobjectType) {
        super(String.valueOf(sObjectType));
        this.setHandlerName('APTPS_EchoSignAgreementEventTrgHandler');
        
    }
    
    //after update event handler
    public override void afterInsert(){
        Set<String> echoSignAgreementIdSet = new Set<String>();
        Map<String, String> eventCommentMap = new Map<String, String>();
        Set<String> rejectedIdSet = new Set<String>();
        Set<String> recalledIdSet = new Set<String>();
        Set<String> createdIdSet = new Set<String>();
        for(echosign_dev1__SIGN_AgreementEvent__c agreementEvent : (List<echosign_dev1__SIGN_AgreementEvent__c>)Trigger.new){
            
            if(agreementEvent.echosign_dev1__Event_Type__c == 'RECALLED' || agreementEvent.echosign_dev1__Event_Type__c == 'REJECTED'
              || agreementEvent.echosign_dev1__Event_Type__c == 'CREATED'){
                eventCommentMap.put(agreementEvent.echosign_dev1__SIGN_Agreement__c, agreementEvent.echosign_dev1__Comment2__c);
                echoSignAgreementIdSet.add(agreementEvent.echosign_dev1__SIGN_Agreement__c);
                
                if(agreementEvent.echosign_dev1__Event_Type__c == 'RECALLED') recalledIdSet.add(agreementEvent.echosign_dev1__SIGN_Agreement__c);
                else if(agreementEvent.echosign_dev1__Event_Type__c == 'REJECTED') rejectedIdSet.add(agreementEvent.echosign_dev1__SIGN_Agreement__c);
                else if(agreementEvent.echosign_dev1__Event_Type__c == 'CREATED') createdIdSet.add(agreementEvent.echosign_dev1__SIGN_Agreement__c);
                
            }
            
        }
        system.debug('G*G echoSignAgreementIdSet '+ echoSignAgreementIdSet);
        
        Set<String> relevantApttusAgreementIdSet = new Set<String>();
        Map<String, String> apttusAgreementReasonMap = new Map<String, String>();
        Set<String> rejectedApttusAgreementIdSet = new Set<String>();
        Set<String> recalledApttusAgreementIdSet = new Set<String>();
        Set<String> createdApttusAgreementIdSet = new Set<String>();
        if(!echoSignAgreementIdSet.isEmpty()){
            for(echosign_dev1__SIGN_Agreement__c  echoSignAgreement: [select Id, Apttus_Echosign__Apttus_Agreement__c, Apttus_Echosign__Apttus_RSPCAttachments__c,
                                                                      Apttus_Echosign__Apttus_Agreement__r.Apttus__Status__c
                                                                      from echosign_dev1__SIGN_Agreement__c 
                                                                      where Id In: echoSignAgreementIdSet
                                                                      and Apttus_Echosign__Apttus_Agreement__r.Apttus__Status__c != 'Fully Signed'
                                                                      and Apttus_Echosign__Apttus_Agreement__r.Apttus__Status__c != 'Activated'
                                                                      limit 50000]){
                                                                          if(echoSignAgreement.Apttus_Echosign__Apttus_RSPCAttachments__c != null){
                                                                              Map<String, String> attachmentIdMap = new Map<String, String>();
                                                                              attachmentIdMap = (Map<String, String>) JSON.deserialize(echoSignAgreement.Apttus_EchoSign__Apttus_RSPCAttachments__c,
                                                                                                                                       Map<String, String>.class);
                                                                              if(!attachmentIdMap.isEmpty() && !attachmentIdMap.keySet().isEmpty())
                                                                              relevantApttusAgreementIdSet.addAll(attachmentIdMap.values());
                                                                              
                                                                              if(eventCommentMap.containsKey(echoSignAgreement.Id))
                                                                                  apttusAgreementReasonMap.put(echoSignAgreement.Apttus_Echosign__Apttus_Agreement__c,
                                                                                                              eventCommentMap.get(echoSignAgreement.Id));
                                                                              
                                                                              if(recalledIdSet.contains(echoSignAgreement.Id)) 
                                                                                  recalledApttusAgreementIdSet.add(echoSignAgreement.Apttus_Echosign__Apttus_Agreement__c);
                                                                              
                                                                              else if(rejectedIdSet.contains(echoSignAgreement.Id))
                                                                                  rejectedApttusAgreementIdSet.add(echoSignAgreement.Apttus_Echosign__Apttus_Agreement__c);
                                                                              
                                                                              else if(createdIdSet.contains(echoSignAgreement.Id))
                                                                                  createdApttusAgreementIdSet.add(echoSignAgreement.Apttus_Echosign__Apttus_Agreement__c);
                                                                          }
                                                                      }
        }
        
        system.debug('G*G relevantApttusAgreementIdSet size'+ relevantApttusAgreementIdSet.size());
        List<Apttus__APTS_Agreement__c> toUpdateApttusAgreementList = new List<Apttus__APTS_Agreement__c>();
        
        if(!relevantApttusAgreementIdSet.isEmpty()){
            for(Apttus__APTS_Agreement__c apttusAgreement: [select Id,Apttus__Parent_Agreement__c, Apttus__Source__c, Apttus__Status_Category__c  
                                                            from Apttus__APTS_Agreement__c
                                                            where Id In: relevantApttusAgreementIdSet
                                                            limit 50000]){
                                                                
                                                                Boolean isCreatedStatus = false;
                                                                String comparisonId = apttusAgreement.Apttus__Parent_Agreement__c != null ? 
                                                                                      apttusAgreement.Apttus__Parent_Agreement__c : apttusAgreement.Id;
                                                                
                                                                if(recalledApttusAgreementIdSet.contains(comparisonId)){
                                                                    
                                                                    if(apttusAgreement.Apttus__Source__c != 'Internal Digital'){
                                                                        apttusAgreement.Apttus__Status_Category__c = 'In Authoring';
                                                                        apttusAgreement.Apttus__Status__c = 'Author Contract';
                                                                    }
                                                                    else{
                                                                        if(apttusAgreement.Apttus__Status_Category__c != 'In Effect'
                                                                           && apttusAgreement.Apttus__Status_Category__c != 'Expired'
                                                                           && apttusAgreement.Apttus__Status_Category__c != 'Terminated'
                                                                           && apttusAgreement.Apttus__Status_Category__c != 'Cancelled'
                                                                           && apttusAgreement.Apttus__Status_Category__c != 'Request'
                                                                           && apttusAgreement.Apttus__Status_Category__c != 'Amended'
                                                                           && apttusAgreement.Apttus__Status_Category__c != 'In Approvals'){
                                                                               
                                                                               apttusAgreement.Apttus__Status_Category__c = 'Cancelled';
                                                                               apttusAgreement.Apttus__Status__c = 'Cancelled Request';
                                                                           }
                                                                    }
                                                                }
                                                                
                                                                else if(rejectedApttusAgreementIdSet.contains(comparisonId)){
                                                                    apttusAgreement.Apttus__Status_Category__c = 'In Signatures';
                                                                    apttusAgreement.Apttus__Status__c = 'Signature Declined';
                                                                }
                                                                
                                                                else if(createdApttusAgreementIdSet.contains(comparisonId)){
                                                                    apttusAgreement.Apttus__Status_Category__c = 'In Signatures';
                                                                    apttusAgreement.Apttus__Status__c = 'Other Party Signatures';
                                                                    isCreatedStatus = true;
                                                                }
                                                                
                                                                if(apttusAgreementReasonMap.containsKey(apttusAgreement.Id)
                                                                  && !isCreatedStatus){
                                                                    String reason = apttusAgreementReasonMap.get(apttusAgreement.Id);
                                                                    if(reason != null && reason.length() > 255) reason = reason.subString(0,255);
                                                                    apttusAgreement.APTPS_Reason__c = reason;
                                                                    
                                                                }
                                                                
                                                                if(!toUpdateApttusAgreementList.contains(apttusAgreement)) 
                                                                    toUpdateApttusAgreementList.add(apttusAgreement);
                                                                
                                                            }
        }
        
        system.debug('G*G toUpdateApttusAgreementList size '+ toUpdateApttusAgreementList.size());
        try{
            if(!toUpdateApttusAgreementList.isEmpty()) update toUpdateApttusAgreementList;
        }
        catch (Exception ex){
            Logger.getLogger(APTPS_EchoSignAgreementEventTrgHandler.class).debug(ex);
            Logger.exitLogger();
        }
        
    }
  
}