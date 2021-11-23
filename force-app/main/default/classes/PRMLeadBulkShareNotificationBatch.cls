/*
Version     Author                         Last Modified Date      Description
v1.0        Vivian Charlie (Team Hawaii)     15 Jan 2021           Initial Draft
*/
public without sharing class PRMLeadBulkShareNotificationBatch implements Database.Batchable<sObject>, Database.Stateful{
    map<Id,Id> mapPartnerPPC;
    map<Id,list<Id>> mapPartnerSalesManagers;
    list<Lead> lstLeadsToUpdate;
    set<Id> setPartnerPPC;
    
    public List<Id> leadIds = new List<Id>();
    
    public PRMLeadBulkShareNotificationBatch(List<Id> objectList2){
        leadIds = objectList2;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        mapPartnerPPC = new map<Id,Id>();
        mapPartnerSalesManagers = new map<Id,list<Id>>();
        lstLeadsToUpdate = new list<Lead>();
        setPartnerPPC = new set<Id>();
        // fetch all leads created via bulk import and pending notification processing
        return database.getQueryLocator([Select Id
                                              , isBulkSharedLead__c
                                              , PartnerAccountId
                                              , PartnerAccount.PartnerPrincipalContact__c
                                              , Partner_Principal_Contact__c
                                              , Trigger_Share_with_Partner__c
                                        From Lead WHERE Id IN : leadIds]);
    }

    public void execute(Database.BatchableContext BC, List<Lead> scope){
        for(Lead objL : scope){
            setPartnerPPC.add(objL.PartnerAccountId);
            // assign the lead as processed and update in finish method
            objL.isBulkSharedLead__c = true;
            lstLeadsToUpdate.add(objL);
        }
        
        if(!setPartnerPPC.isEmpty()){
            // fetch the Sales Managers for all Partner Account
            for(Account objA : [Select Id
                                     , PartnerPrincipalContact__c
                                     , Name
                                     , (Select Id
                                             , Name
                                             , Email
                                             , Partner_Role__c
                                             , AccountId
                                        From Contacts
                                        Where Partner_Role__c INCLUDES ('Partner Sales Manager')
                                        and Onboarding_Status__c =: PRMConstants.PRM_Account_Status_Active)
                                From Account
                                Where Id IN : setPartnerPPC]){
                list<Id> lstSalesManagerIds = new list<Id>();
                mapPartnerPPC.put(objA.Id, objA.PartnerPrincipalContact__c);
                for(Contact objC : objA.Contacts){
                    lstSalesManagerIds.add(objC.Id);
                }
                if(!lstSalesManagerIds.isEmpty()){
                    // map PartnerAccount with all its Sales Managers
                    mapPartnerSalesManagers.put(objA.Id, lstSalesManagerIds);
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        list<EmailTemplate> template = [Select Id
                                             , DeveloperName 
                                        From EmailTemplate 
                                        Where DeveloperName = 'PPC_and_SM_Notification'
                                        limit 1];
        if(!template.isEmpty()){
            list<Messaging.SingleEmailMessage> lstEmail = new list<Messaging.SingleEmailMessage>();
            for(Id partnerAccountId : mapPartnerPPC.keySet()){
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                semail.setTargetObjectId(mapPartnerPPC.get(partnerAccountId));
                semail.setWhatId(partnerAccountId);
                semail.setTemplateId(template[0].Id);
                semail.setToAddresses(mapPartnerSalesManagers.get(partnerAccountId));
                lstEmail.add(semail);
            }
            list<Messaging.SendEmailResult> lstEmailResult = Messaging.sendEmail(lstEmail, false);
            for(Messaging.SendEmailResult emailResult : lstEmailResult){
                system.debug('emailResult.isSuccess()**********'+emailResult.isSuccess());
                system.debug('emailResult.getErrors()**********'+emailResult.getErrors());
            }
            if(!lstLeadsToUpdate.isEmpty()){
                update lstLeadsToUpdate;
            }
        }
    }
}