/**
* 
* @author       : Gautam Kumar
* @version      : 1.0
* @createdDate  : 14/09/2021 
* @Type         : Apex Class
* @Test Class   : APTPS_EchoSignRecipentTriggerHandlerTest
* @Description  : echosign_dev1__SIGN_Recipients__c object's trigger handler based on SYS_TriggerHandler
*
**/
public with sharing class APTPS_EchoSignRecipientTriggerHandler extends SYS_TriggerHandler{
    
    //constructor
    public APTPS_EchoSignRecipientTriggerHandler(Schema.SObjectType sobjectType) {
        super(String.valueOf(sObjectType));
        this.setHandlerName('APTPS_EchoSignRecipientTriggerHandler');
        
    }
    
    //after update event handler
    public override void afterUpdate(){
        List<String> fieldChangesToMonitor = new List<String>{'echosign_dev1__Status__c'};
        Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap, Trigger.newMap, fieldChangesToMonitor);
        Set<String> echoSignAgreementIdSet = new Set<String>();
        Set<String> recipientIdSet = new Set<String>();
        for(echosign_dev1__SIGN_Recipients__c recipient : (List<echosign_dev1__SIGN_Recipients__c>)Trigger.new){
            
            if(recordsWithChanges.get(recipient.Id).contains('echosign_dev1__Status__c')){ 
                if((recipient.echosign_dev1__Status__c == 'Signed' || recipient.echosign_dev1__Status__c == 'Accepted'
                || recipient.echosign_dev1__Status__c == 'Approved')
                && (recipient.echosign_dev1__Order_Number__c == 2 || recipient.echosign_dev1__Order_Number__c == 3
                || recipient.echosign_dev1__Order_Number__c == 4 ) && String.isNotBlank(recipient.echosign_dev1__Agreement__c)){
                    echoSignAgreementIdSet.add(recipient.echosign_dev1__Agreement__c);
                    recipientIdSet.add(recipient.Id);
                }
            }
        }
        
        Set<String> attpsAgreementIdSet = new Set<String>();
        Map<echosign_dev1__SIGN_Recipients__c, String> echoSignRecipientMap = new Map<echosign_dev1__SIGN_Recipients__c, String>();
        Map<String, String> echoSignParentIdMap = new Map<String, String>();
        
        if(!echoSignAgreementIdSet.isEmpty() && !recipientIdSet.isEmpty()){
            //get the relevant echosign recipient map
            echoSignRecipientMap = getEchoSignRecipientMap(recipientIdSet);
            
            //get the map of echosignagreement and apttus agreement
            for(echosign_dev1__SIGN_Agreement__c  echoSignAgreement: [select Id, Apttus_Echosign__Apttus_Agreement__c
                                                                      from echosign_dev1__SIGN_Agreement__c 
                                                                      where Id In: echoSignAgreementIdSet
                                                                      limit 50000]){
                                                                          attpsAgreementIdSet.add(echoSignAgreement.Apttus_Echosign__Apttus_Agreement__c);
                                                                          echoSignParentIdMap.put(echoSignAgreement.Id, 
                                                                                                  echoSignAgreement.Apttus_Echosign__Apttus_Agreement__c);
                                                                      }
        }
        
        //get the apptus agreement map 
        Map<String, Apttus__APTS_Agreement__c> apttusAgreementMap = getApttusAgreementMap(attpsAgreementIdSet);
        Map<String, Apttus__APTS_Agreement__c> toUpdateApttusAgreementMap = new Map<String, Apttus__APTS_Agreement__c>();
        Set<String> parentAgreementWithStartDate = new Set<String>();
                
        for(echosign_dev1__SIGN_Recipients__c recipient: echoSignRecipientMap.keySet()){
            
            String echoSignAgreementId = echoSignRecipientMap.get(recipient);
            
            if(String.isNotBlank(echoSignAgreementId) && echoSignParentIdMap.containsKey(echoSignAgreementId)
            && echoSignParentIdMap.get(echoSignAgreementId) != null){
                String apttusAgreementId = echoSignParentIdMap.get(echoSignAgreementId);
                Apttus__APTS_Agreement__c apttusAgreement = apttusAgreementMap.get(apttusAgreementId);
                
                String recipientName = '';
                if(recipient.echosign_dev1__Recipient_Type__c == 'Contact') recipientName = recipient.echosign_dev1__Contact__r.Name;
                else if (recipient.echosign_dev1__Recipient_Type__c == 'User') recipientName = recipient.echosign_dev1__User__r.Name;
                else if (recipient.echosign_dev1__Recipient_Type__c == 'Lead') recipientName = recipient.echosign_dev1__Lead__r.Name;
                
                if(apttusAgreement.RecordType.Name == 'NDA' && apttusAgreement.Apttus__Agreement_Category__c == 'Multi-Party'){
                    if(recipient.echosign_dev1__Order_Number__c == 3){
                        apttusAgreement.Apttus__Other_Party_Signed_Date__c = System.today();
                        apttusAgreement.APTPS_Other_Party_Signed_By__c = recipientName;
                    }
                    if(recipient.echosign_dev1__Order_Number__c == 4){
                        apttusAgreement.Apttus__Company_Signed_Date__c = System.today();
                        apttusAgreement.APTPS_Company_Signed_By__c = recipientName;
                    }
                }
                else{
                    if(recipient.echosign_dev1__Order_Number__c == 2){
                        apttusAgreement.Apttus__Other_Party_Signed_Date__c = System.today();
                        apttusAgreement.APTPS_Other_Party_Signed_By__c = recipientName;
                    }
                    if(recipient.echosign_dev1__Order_Number__c == 3){
                        apttusAgreement.Apttus__Company_Signed_Date__c = System.today();
                        apttusAgreement.APTPS_Company_Signed_By__c = recipientName;
                    }
                }
                //if the recipient order is 3 and the status is signed then capture this parent agreement and populate the child agreement
                //agreeement start date with today
                if(recipient.echosign_dev1__Order_Number__c == 3 && recipient.echosign_dev1__Status__c == 'Signed'){
                    parentAgreementWithStartDate.add(apttusAgreement.Id);
                }
                
                apttusAgreement.APTPS_Is_Custom_Update__c = true;
                if(!toUpdateApttusAgreementMap.containsKey(apttusAgreement.Id)){
                    toUpdateApttusAgreementMap.put(apttusAgreement.Id, apttusAgreement);
                } 
            }
        }
        
        
        //get and populate child agreements from parent agreement records
        if(!toUpdateApttusAgreementMap.isEmpty() && !toUpdateApttusAgreementMap.keySet().isEmpty()){
            for(Apttus__APTS_Agreement__c apttusAgreement: [select Id,RecordType.Name, Apttus__Agreement_Category__c,
                                                            Apttus__Company_Signed_Date__c, APTPS_Other_Party_Signed_By__c, 
                                                            APTPS_Company_Signed_By__c, Apttus__Other_Party_Signed_Date__c,
                                                            Apttus__Parent_Agreement__c 
                                                            from Apttus__APTS_Agreement__c
                                                            where Apttus__Parent_Agreement__c In: toUpdateApttusAgreementMap.keySet()
                                                            And Apttus__Status_Category__c = 'In Signatures'
                                                            And Apttus__Status__c = 'Other Party Signatures'
                                                            limit 50000]){
                                                                if(toUpdateApttusAgreementMap.containsKey(apttusAgreement.Apttus__Parent_Agreement__c)){
                                                                    Boolean hasUpdate = false;
                                                                    if(String.isBlank(apttusAgreement.APTPS_Other_Party_Signed_By__c)){
                                                                        apttusAgreement.APTPS_Other_Party_Signed_By__c = toUpdateApttusAgreementMap.get(apttusAgreement.Apttus__Parent_Agreement__c).APTPS_Other_Party_Signed_By__c;
                                                                        apttusAgreement.Apttus__Other_Party_Signed_Date__c = System.today();
                                                                        apttusAgreement.APTPS_Is_Custom_Update__c = true;
                                                                        hasUpdate = true;
                                                                    }
                                                                    if(String.isBlank(apttusAgreement.APTPS_Company_Signed_By__c)){
                                                                        apttusAgreement.APTPS_Company_Signed_By__c = toUpdateApttusAgreementMap.get(apttusAgreement.Apttus__Parent_Agreement__c).APTPS_Company_Signed_By__c;
                                                                        apttusAgreement.Apttus__Company_Signed_Date__c = System.today();
                                                                        apttusAgreement.APTPS_Is_Custom_Update__c = true;
                                                                        hasUpdate = true;
                                                                    }
                                                                    
                                                                    if(parentAgreementWithStartDate.contains(apttusAgreement.Apttus__Parent_Agreement__c)){
                                                                        apttusAgreement.Apttus__Contract_Start_Date__c = System.today();
                                                                        apttusAgreement.APTPS_Is_Custom_Update__c = true;
                                                                        hasUpdate = true;
                                                                    }
                                                                    
                                                                    if(hasUpdate && !toUpdateApttusAgreementMap.containsKey(apttusAgreement.Id)){
                                                                        toUpdateApttusAgreementMap.put(apttusAgreement.Id, apttusAgreement);
                                                                    }
                                                                }
                                                            }
        }
        
        
        List<Apttus__APTS_Agreement__c> uncheckCustomUpdateFlagList = new List<Apttus__APTS_Agreement__c>();
        system.debug('G*G toUpdateApttusAgreementMap.values() size '+ toUpdateApttusAgreementMap.values().size());
        
        try{
            if(!toUpdateApttusAgreementMap.isEmpty() && !toUpdateApttusAgreementMap.keySet().isEmpty()){
                update toUpdateApttusAgreementMap.values();
                for(Apttus__APTS_Agreement__c apttusAgreement : toUpdateApttusAgreementMap.values()){
                    apttusAgreement.APTPS_Is_Custom_Update__c = false;
                    uncheckCustomUpdateFlagList.add(apttusAgreement);
                }
                update uncheckCustomUpdateFlagList;
            } 
        }
        catch (Exception ex){
            Logger.getLogger(APTPS_EchoSignRecipientTriggerHandler.class).debug(ex);
            Logger.exitLogger();
        }
        
    }
    
    /**
    * 
    * @author       : Gautam Kumar
    * @param        : echosign_dev1__SIGN_Recipients__c records id set
    * @return       : Map with echosign_dev1__SIGN_Recipients__c record as key and the  echosign_dev1__Agreement__c Id as value
    * @Description  : function to get the echoSignRecipientMap
    *
    **/
    private Map<echosign_dev1__SIGN_Recipients__c, String> getEchoSignRecipientMap(Set<String> recipientIdSet){
        Map<echosign_dev1__SIGN_Recipients__c, String> echoSignRecipientMap = new Map<echosign_dev1__SIGN_Recipients__c, String>();
        
        if(!recipientIdSet.isEmpty()){
            for(echosign_dev1__SIGN_Recipients__c recipient : [select Id, echosign_dev1__Contact__r.Name, echosign_dev1__User__r.Name, 
                                                               echosign_dev1__Lead__r.Name, echosign_dev1__Agreement__c, 
                                                               echosign_dev1__Recipient_Type__c, echosign_dev1__Order_Number__c,
                                                               echosign_dev1__Status__c 
                                                               from echosign_dev1__SIGN_Recipients__c 
                                                               where Id In: recipientIdSet 
                                                               limit 50000]){
                                                                   echoSignRecipientMap.put(recipient, recipient.echosign_dev1__Agreement__c);
                                                               }
        }
        return echoSignRecipientMap;
    }
    
    /**
    * 
    * @author       : Gautam Kumar
    * @param        : Apttus__APTS_Agreement__c records id set
    * @return       : Map with Apttus__APTS_Agreement__c record id as key and the Apttus__APTS_Agreement__c record as value
    * @Description  : function to get the apttusAgreementMap
    *
    **/
    private Map<String, Apttus__APTS_Agreement__c> getApttusAgreementMap(Set<String> attpsAgreementIdSet){
        Map<String, Apttus__APTS_Agreement__c> apttusAgreementMap = new Map<String, Apttus__APTS_Agreement__c>();
        
        if(!attpsAgreementIdSet.isEmpty()){
            for(Apttus__APTS_Agreement__c apttusAgreement : [select Id,RecordType.Name, Apttus__Agreement_Category__c,
                                                             Apttus__Company_Signed_Date__c, APTPS_Other_Party_Signed_By__c, 
                                                             APTPS_Company_Signed_By__c, Apttus__Other_Party_Signed_Date__c
                                                             from Apttus__APTS_Agreement__c
                                                             where Id In: attpsAgreementIdSet
                                                             limit 50000]){
                                                                 apttusAgreementMap.put(apttusAgreement.Id, apttusAgreement);
                                                             }
        }
        return apttusAgreementMap;
    }
    
    
}