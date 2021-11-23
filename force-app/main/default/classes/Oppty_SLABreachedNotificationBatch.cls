public class Oppty_SLABreachedNotificationBatch implements Database.Batchable<sObject>, schedulable, Database.Stateful {
    
    
/********************************************************************************************************
* Author - Sudheendra
* Batch Class Name - Oppty_SLABreachedNotificationBatch
* Description - This Batch class is used to post chatter feed messages that breaches the Oppty SLA time.
*******************************************************************************************************/
    Public List<C2O_OpportunityTriggerHelper.ChatterFeedInfo> listOfchatterFeeds = new List<C2O_OpportunityTriggerHelper.ChatterFeedInfo>();
    C2O_OpportunityTriggerHelper.ChatterFeedInfo slaBreachNotif;
    C2O_OpportunityTriggerHelper.ChatterFeedInfo pendingApprovalNotif;
    public Database.QueryLocator start(Database.BatchableContext BC){
        Datetime todaysDate = (DateTime)Date.today();
        Datetime tomorrowsdate = (DateTime)Date.today().addDays(1);
        
        
        String opptySLABreachQuery = 'Select Id, createdbyId,createdby.Contact.Account.OwnerId, OwnerId, Account.OwnerId,Partner_Opportunity_Verification__c, Opportunity_Source__c, SLA_date__c FROM Opportunity ' + 
            ' WHERE IsClosed =false AND Partner_Opportunity_Verification__c = \'Verification Required\' AND Opportunity_Source__c = \'Partner\' ' +
            ' AND SLA_date__c >=:todaysDate AND SLA_date__c <: tomorrowsdate'; 
        
        
        return Database.getQueryLocator(opptySLABreachQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('@@scope:'+scope);
        for(Opportunity s : scope){
            slaBreachNotif = null;
            pendingApprovalNotif = null;
            slaBreachNotif = new C2O_OpportunityTriggerHelper.ChatterFeedInfo(s.Id ,new set<Id>{s.createdby?.Contact?.Account?.OwnerId},OpptyConstants.PRM_Chatter_SLA_breached_Notification);
            pendingApprovalNotif = new C2O_OpportunityTriggerHelper.ChatterFeedInfo(s.Id ,new set<Id>{s.Account.OwnerId},OpptyConstants.PRM_Chatter_Pending_Opportunity_Approval);
            // Create chatter feed instances for the scope of opportunities and add them to the class list chatterfeed object
            if(slaBreachNotif != null){
                listOfchatterFeeds.add(slaBreachNotif);
            }
            if(pendingApprovalNotif != null){
                listOfchatterFeeds.add(pendingApprovalNotif);
            }
        }
        if(!this.listOfchatterFeeds.isEmpty()){
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for(C2O_OpportunityTriggerHelper.ChatterFeedInfo feed: listOfchatterFeeds){
                
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(C2O_OpportunityTriggerHelper.createChatterPost(feed.parentRecId, feed.mentionIds,  feed.chatterFeedText));
                
                if(batchInputs.size() < 500){ // Add chatter feeds till batch size reaches 500 
                    batchInputs.add(batchInput);
                }   
                else{
                    try{
                        ConnectApi.ChatterFeeds.postFeedElementBatch(opptyConstants.EDGE_PARTNERS_NETWORK_ID, batchInputs);  
                        // Post chatter feeds till 500
                    }
                    catch(Exception ex){
                        PRMUtilityClass.createException(ex);
                    }
                    batchInputs = new List<ConnectApi.BatchInput>();
                }
            }
            if(!batchInputs.isEmpty()){
                try{
                    // Handle the final set of Feed elements
                    ConnectApi.ChatterFeeds.postFeedElementBatch(opptyConstants.EDGE_PARTNERS_NETWORK_ID, batchInputs);     
                }
                catch(Exception ex){
                    PRMUtilityClass.createException(ex);
                }
            }
            
        }
    }
    
    public void finish(Database.BatchableContext BC){        
        
    } 
    
    // SCHEDULER 
    
    public Oppty_SLABreachedNotificationBatch() {
        
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new Oppty_SLABreachedNotificationBatch());
    }
}