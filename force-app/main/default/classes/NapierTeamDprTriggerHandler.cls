/********************************************************
Class Name : NapierTeamDprTriggerHandler  
Test Class : DPRSyncwithOpportunityTriggerTest
===============================================================================================================================
Change.No.    Developer Name          Story Description
1.            Navneet Sanotra         EDGE: 122428    
2.            Vishal Arbune           EDGE-210318 : As a Sales User, I want Opportunity TCV to match the Active FA's TCV
**********************************************************
*/
public without sharing class NapierTeamDprTriggerHandler extends ATF_AbstractDomainHandler { 
    
    List<delegated_pricing_request__c> oldDPR=trigger.old;
    List<delegated_pricing_request__c> newDPR=trigger.new;
    set<string> setProductBasketId  = new set<string>();//added here by Rishabh
    //Map<ID, SObject> updatedRecordsMap=trigger.newMap;
    //Map<ID, delegated_pricing_request__c>updatedDPRMap=(Map<ID, delegated_pricing_request__c>)updatedRecordsMap;  
    
    public override void handleBeforeUpdate(Map<ID, SObject> oldRecords){
        No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
        
        if (notriggers == null || !notriggers.Flag__c)
        {
            list<delegated_pricing_request__c> dprUpdate = null;
            //set<string> setProductBasketId  = new set<string>();
            System.debug('newDPR.........'+newDPR);
            
            for(delegated_pricing_request__c dpr :newDPR){
                
                if(!dpr.Counter__c && (dpr.deal_status__c == 'Scored' || dpr.deal_status__c == 'Approved' || dpr.deal_status__c == 'Active') && !dpr.is_deal_escalated__c){
                    dpr.Synchronise_With_Opportunity__c = true;
                    dpr.isPrimary__c = true;
                    system.debug('****dpr.Synchronise_With_Opportunity__c=' +  dpr.Synchronise_With_Opportunity__c);
                    setProductBasketId.add(dpr.ID);
                }
                
                if (dpr.Counter__c) {
                    dpr.Counter__c = false;
                }
                
            }
            
            //DPRSyncOpptyProductUtility.CreateOLIs(setProductBasketId);
            DprTriggerhelper.beforeUpdateHandle(newDPR, oldDPR);
            
        }
        
    }
    
    
    public override void handleAfterUpdate(Map<ID, SObject> oldRecordsMap){
        
        if(!setProductBasketId.isEmpty()){
            DPRSyncOpptyProductUtility.CreateOLIs(setProductBasketId);//added here by Rishabh
        }
        
        DprTriggerhelper.afterUpdateHandle(newDPR, oldDPR);
        
    }
    
    
    
}