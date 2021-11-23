/********************************************************
Class Name :  DprTriggerhelper
Test Class : DPRSyncwithOpportunityTriggerTest
===============================================================================================================================
Change.No.    Developer Name         Story Description
1.            Navneet Sanotra        EDGE: 122428   
2.            Madhu Gaurav           EDGE: 204335 
3.            Manuga Kale            DIGI-719 commented the technical logic to set setApprovedOpportunityId set.
**********************************************************
*/

public with sharing class DprTriggerhelper {
    
    public static boolean BlockDprTrigger = false;     // Added as part of EDGE :204335
    public static void beforeUpdateHandle(List<delegated_pricing_request__c> newDPRList, List<delegated_pricing_request__c> oldDPRList) {
        System.debug(LoggingLevel.INFO, 'DPStatusChangeTriggerHandler.beforeUpdateHandle.lstOldPB = ' + oldDPRList);
        System.debug(LoggingLevel.INFO, 'DPStatusChangeTriggerHandler.beforeUpdateHandle.lstNewPB = ' + newDPRList);
        
        UnSyncDPRBeforeUpdate(newDPRList, oldDPRList);
        
    }
    
    public static void AfterUpdateHandle(List<delegated_pricing_request__c> newDPRList, List<delegated_pricing_request__c> oldDPRList) {
        System.debug(LoggingLevel.INFO, 'DPStatusChangeTriggerHandler.AfterUpdateHandle.lstOldPB = ' + oldDPRList);
        System.debug(LoggingLevel.INFO, 'DPStatusChangeTriggerHandler.AfterUpdateHandle.lstNewPB = ' + newDPRList);
        
        updateOpportunityStage(newDPRList, oldDPRList);
        
    }
    
    private static void UnSyncDPRBeforeUpdate(List<delegated_pricing_request__c> newDPRList, List<delegated_pricing_request__c> oldDPRList) {
        //to be called after insert or after update,
        //if newly updated DPRs were synced then un-sync all others which have same Opportunity
        //if newly inserted DPRs are synced then un-sync all others which have same Opportunity
        set<string> setOpportunityId = new set<string>();
        set<string> setActiveDPROppId = new set<string>();
        set<string> setSyncedDPRId = new set<string>();
        set<string> setActiveDPRId = new set<string>();
        List<Delegated_Pricing_Request__c> updateCancelledDPRList = new List<Delegated_Pricing_Request__c>();
        Boolean Pass;
        
        
        for (integer i = 0; i < newDPRList.size(); ++i) {
            Pass = false;
            
            if (oldDPRList != null) {
                if  (newDPRList[i].Synchronise_With_Opportunity__c && newDPRList[i].isPrimary__c){
                    Pass = true;
                }
                
                if ((newDPRList[i].Synchronise_With_Opportunity__c) && (!oldDPRList[i].Synchronise_With_Opportunity__c)
                    && (newDPRList[i].isPrimary__c) && (!oldDPRList[i].isPrimary__c)) {
                        Pass = true;
                    }
                
                System.debug('oldDPRList[i].deal_status__c '+oldDPRList[i].deal_status__c);
                System.debug('newDPRList[i].deal_status__c '+newDPRList[i].deal_status__c);
                //Added by Rishabh
                if  (oldDPRList[i].deal_status__c == 'Sent for Approval' && (newDPRList[i].deal_status__c != 'Approved' || newDPRList[i].deal_status__c != 'Rejected')){
                    
                    //Added by Navneet
                    if  (oldDPRList[i].deal_status__c == 'Sent for Approval' && newDPRList[i].deal_status__c == 'Draft'){
                        newDPRList[i].deal_status__c = 'Draft';
                    }else if(newDPRList[i].deal_status__c == 'Rejected') {
                        newDPRList[i].deal_status__c = 'Rejected';
                    } else {                    
                    newDPRList[i].deal_status__c = 'Sent for Approval';
                    }
                }
                
            } 
            if ((Pass) && (newDPRList[i].Opportunity__c != null)) {
                setOpportunityId.add(newDPRList[i].Opportunity__c);
                setSyncedDPRId.add(newDPRList[i].Id);
            }
            
        }
        
        if (setOpportunityId.size() > 0) {
            list<delegated_pricing_request__c> allDPRList = [select Id, Synchronise_With_Opportunity__c, isPrimary__c, Opportunity__c
                                                             from delegated_pricing_request__c where Opportunity__c in : setOpportunityId];
            
            list<delegated_pricing_request__c> allDPRListUpdate = new list<delegated_pricing_request__c>();
            for (delegated_pricing_request__c tmpDPR : allDPRList) {
                if (!setSyncedDPRId.contains(tmpDPR.Id)) {
                    if (tmpDPR.Synchronise_With_Opportunity__c
                        || tmpDPR.isPrimary__c) {
                            tmpDPR.Synchronise_With_Opportunity__c = false;
                            tmpDPR.isPrimary__c = false;
                            tmpDPR.Counter__c = true;
                            allDPRListUpdate.add(tmpDPR);
                            System.debug(LoggingLevel.INFO, 'Info 4 inside sync false = ' + allDPRListUpdate);
                        }
                }
            }
            
            if (allDPRListUpdate.size() > 0)
                update allDPRListUpdate;
        }
        
    }
    
    
    private static void updateOpportunityStage(List<delegated_pricing_request__c> newDPRList, List<delegated_pricing_request__c> oldDPRList) {
        
        set<string> setOpportunityId = new set<string>();
        set<string> setApprovedOpportunityId = new set<string>();
        set<string> setdraftOpportunityId = new set<string>();//added by rishabh
        set<string> setRejectedOpportunityId = new set<string>();//added by rishabh
        set<string> setProductBasketId  = new set<string>();//added by rishabh
        set<string> setProposeOpportunityId  = new set<string>();//added by rishabh
        
        for (integer i = 0; i < newDPRList.size(); ++i) {
            if (oldDPRList[i].deal_Status__c != newDPRList[i].deal_Status__c && newDPRList[i].deal_Status__c == 'Scored' && newDPRList[i].isPrimary__c && newDPRList[i].Opportunity__c != null) {
                setOpportunityId.add(newDPRList[i].Opportunity__c);
            }
            
          /*  if (oldDPRList[i].deal_Status__c != newDPRList[i].deal_Status__c && newDPRList[i].deal_Status__c == 'Approved' && newDPRList[i].isPrimary__c && newDPRList[i].Opportunity__c != null) {
                setApprovedOpportunityId.add(newDPRList[i].Opportunity__c);
            }  */
            //added by rishabh
            if (oldDPRList[i].deal_Status__c != newDPRList[i].deal_Status__c && newDPRList[i].deal_Status__c == 'Draft' && newDPRList[i].Opportunity__c != null){
                setdraftOpportunityId.add(newDPRList[i].Opportunity__c);
                setProductBasketId.add(newDPRList[i].Id);
            }
            
            //EDGE:123727 - Accept Contract, added by rishabh
            if (oldDPRList[i].deal_Status__c != newDPRList[i].deal_Status__c && newDPRList[i].deal_Status__c == 'Contract Generated' && newDPRList[i].Opportunity__c != null){
                setProposeOpportunityId.add(newDPRList[i].Opportunity__c);
            }
            
            //added by navneet
            if (oldDPRList[i].deal_Status__c != newDPRList[i].deal_Status__c && newDPRList[i].deal_Status__c == 'Rejected' && newDPRList[i].isPrimary__c && newDPRList[i].Opportunity__c != null){
                setRejectedOpportunityId.add(newDPRList[i].Opportunity__c);
             }
            
        }
        
        if (setOpportunityId.size() > 0) {
            list<Opportunity> OpptyList = [select Id,Stagename
                                           from opportunity WHERE ID in : setOpportunityId];
            
            list<Opportunity> opptyListUpdate = null;
            for (Opportunity tmpOppty : OpptyList) {
                opptyListUpdate = new list<Opportunity>();
                tmpOppty.Stagename = 'Develop';
                opptyListUpdate.add(tmpOppty);
            }
            
            if (opptyListUpdate.size() > 0)
                update opptyListUpdate;
        }
        
        
      /*  if (setApprovedOpportunityId.size() > 0) {
            list<Opportunity> OpptyList = [select Id,Stagename
                                           from opportunity WHERE ID in : setApprovedOpportunityId];
            
            list<Opportunity> opptyListUpdate = null;
            for (Opportunity tmpOppty : OpptyList) {
                opptyListUpdate = new list<Opportunity>();
                tmpOppty.Stagename = 'Price';
                opptyListUpdate.add(tmpOppty);
            }
            
            if (opptyListUpdate.size() > 0)
                update opptyListUpdate;
        } */ 
        //added by Navneet
        if (setRejectedOpportunityId.size() > 0) {
            list<Opportunity> OpptyList = [select Id,Stagename
                                           from opportunity WHERE ID in : setRejectedOpportunityId];
            
            list<Opportunity> opptyListUpdate = null;
            for (Opportunity tmpOppty : OpptyList) {
                opptyListUpdate = new list<Opportunity>();
                tmpOppty.Stagename = 'Define';
                opptyListUpdate.add(tmpOppty);
            }
            
            if (opptyListUpdate.size() > 0)
                update opptyListUpdate;
        }
        //added by rishabh
        if (setdraftOpportunityId.size() > 0){
            Boolean isDefine = true;
            List<Delegated_Pricing_Request__c> dprList = [Select Id,
                                                          Name, Deal_Status__c,
                                                          isPrimary__c,
                                                          Synchronise_With_Opportunity__c
                                                          from Delegated_Pricing_Request__c
                                                          where Opportunity__c IN: setdraftOpportunityId];
            System.debug('dprList.... '+dprList);
            
            for(Delegated_Pricing_Request__c dpr: dprList){
                if(dpr.Deal_Status__c == 'Scored'||
                   dpr.Deal_Status__c == 'Approved'||
                   dpr.Deal_Status__c == 'Sent for Approval'||
                   dpr.isPrimary__c == true||
                   dpr.Synchronise_With_Opportunity__c == true){
                    isDefine = false;
                    break;   
                }
            }
            System.debug('isDefine...... '+isDefine);
            
            if(isDefine){
                list<Opportunity> OpptyList = [select Id,Stagename
                                               from opportunity WHERE ID in : setdraftOpportunityId];
                
                list<Opportunity> opptyListUpdate = new list<Opportunity>();
                
                
                for (Opportunity tmpOppty : OpptyList) { 
                    tmpOppty.Stagename = 'Define';
                    opptyListUpdate.add(tmpOppty);
                }
                
                if (opptyListUpdate.size() > 0){
                    update opptyListUpdate;
                }
                
                if(setProductBasketId.size() > 0){
                    DPRSyncOpptyProductUtility.deleteHardOLIs(setProductBasketId);
                }
                
            }
            
             
        } 
        
        //EDGE:123727 - Accept Contract, Added by Rishabh
        if(setProposeOpportunityId.size()>0){
            list<Opportunity> OpptyList = [select Id,Stagename
                                               from opportunity WHERE ID in : setProposeOpportunityId];
                
                list<Opportunity> opptyListUpdate = new list<Opportunity>();
                
                
                for (Opportunity tmpOppty : OpptyList) { 
                    tmpOppty.Stagename = 'Propose';
                    opptyListUpdate.add(tmpOppty);
                }
                
                if (opptyListUpdate.size() > 0){
                    update opptyListUpdate;
                }
        }
    }
}