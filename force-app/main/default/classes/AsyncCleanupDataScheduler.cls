/*
Created BY: Abinash Barik
Created Date: 
Description: EDGE-87804 Schedule clean up job in Colombo CI org
Class Name: AsyncCleanupDataScheduler
============================================================================
ChangeSet   No    Name            Date                    Description
*/ 
global class AsyncCleanupDataScheduler implements Database.batchable<Sobject>,Schedulable {
    // Below variable stores the total number of records to be deleted
    public Integer totalAccessDateDelete = 0;
    public Integer totalorchProcessDelete = 0;
    public Integer totalorchStepsDelete = 0;
    public Integer totalcalloutResulDelete = 0;
    public Integer totalerrorLogDelete = 0;
    public Integer totalpclistDelete = 0;
    public Integer totalappLogDelete = 0;
    public Integer totalbasketListDelete = 0;
    public Integer totalOppLineItemDelete = 0;
    Public Integer RETAINDATA_DURATION = Integer.valueOf(System.Label.Clean_Up_Days);
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id FROM Account limit 1'; // No more use this Query
        return Database.getQueryLocator(query);
    }
 	global void execute(SchedulableContext sc) {
         AsyncCleanupDataScheduler b = new AsyncCleanupDataScheduler ();
         database.executebatch(b);
     }
    global void execute(Database.BatchableContext BC, List<Sobject> scope)
    {
        String QueryAccess = 'SELECT Id FROM cscfga__User_Session__c WHERE CreatedDate < LAST_N_DAYS:' + RETAINDATA_DURATION;
        List<cscfga__User_Session__c> lstAccessDate = Database.query(QueryAccess);
        
        String QueryOrchProcess = 'select Id, Name from CSPOFA__Orchestration_Process__c WHERE (Order__c = null AND '
            					+'csordtelcoa__Service__c = null  AND csordtelcoa__Subscription__c = null) '
            					+'AND CreatedDate < LAST_N_DAYS:' + RETAINDATA_DURATION; 
        
        List<CSPOFA__Orchestration_Process__c> orchProcess =Database.query(QueryOrchProcess);
        
        List<Id> procIds = new List<Id>();
        for(CSPOFA__Orchestration_Process__c proc: orchProcess){
            procIds.add(proc.Id);
        }
        
        String QueryOrchStep = 'select Id, Name FROM CSPOFA__Orchestration_Step__c WHERE '
            				+'(CSPOFA__Orchestration_Process__c ' + ' IN:procIds OR '
            				+'CSPOFA__Orchestration_Process__c = null) AND CREATEDDATE < LAST_N_DAYS:' + Label.Clean_Up_Days;
        system.debug('QueryOrchStep>>>' +QueryOrchStep);
        List<CSPOFA__Orchestration_Step__c> orchSteps =Database.query(QueryOrchStep);
        
        List<csbb__Callout_Result__c>  calloutResultList= Database.query('SELECT id,name FROM csbb__Callout_Result__c '
														+' WHERE CREATEDDATE < LAST_N_DAYS :'+RETAINDATA_DURATION);
        
        List<Error_Log__c> errorLogList = Database.query('SELECT id,Application_Id__c FROM '
                                                         +'Error_Log__c WHERE CREATEDDATE < LAST_N_DAYS :'+ RETAINDATA_DURATION);       
        
        List<ApplicationLog__c> appLogList = Database.query('SELECT id FROM ApplicationLog__c WHERE '
                                                            +'CREATEDDATE < LAST_N_DAYS :' + RETAINDATA_DURATION);    
        
        List<cscfga__Product_Configuration__c> pclist = Database.query('SELECT Id, '
									+'cscfga__Product_Configuration__c.cscfga__Product_Basket__c From '
									+'cscfga__Product_Configuration__c where cscfga__Configuration_Offer__c=null '
									+'and CREATEDDATE < LAST_N_DAYS :' + RETAINDATA_DURATION);
        
        Set<Id> basketIds = new Set<Id>();
        for(cscfga__Product_Configuration__c pc: pclist){
            if(pc.cscfga__Product_Basket__c !=null){                
                basketIds.add(pc.cscfga__Product_Basket__c); 
            }
        }
        List<cscfga__Product_Basket__c> basketList = Database.query('SELECT Id, Name from cscfga__Product_Basket__c where '
										+' Id IN: basketIds AND CREATEDDATE < LAST_N_DAYS :'+RETAINDATA_DURATION);   
        
        List<OpportunityLineItem> OppLineItem = Database.query('Select id From OpportunityLineItem where '
												+'cscfga__Attribute__r.cscfga__Product_Configuration__c '
												+' in : pclist AND CREATEDDATE < LAST_N_DAYS :'+RETAINDATA_DURATION);
        
        
        system.debug('lstAccessDate>>>' +lstAccessDate.size());
        system.debug('orchProcess>>>' +orchProcess.size());
        system.debug('orchSteps>>>' +orchSteps.size());
        system.debug('calloutResultList>>>' +calloutResultList.size());
        system.debug('errorLogList>>>' +errorLogList.size());
        system.debug('pclist>>>' +pclist.size());
        system.debug('appLogList>>>' +appLogList.size());
        system.debug('basketList>>>' +basketList.size());
        system.debug('OppLineItem>>>' +OppLineItem.size());
		// Store all the record counts
        totalAccessDateDelete = lstAccessDate.size();
        totalorchProcessDelete = orchProcess.size();
        totalorchStepsDelete = orchSteps.size();
        totalcalloutResulDelete = calloutResultList.size();
        totalerrorLogDelete = errorLogList.size();
        totalpclistDelete = pclist.size();
        totalappLogDelete = appLogList.size();
        totalbasketListDelete = basketList.size();
        totalOppLineItemDelete = OppLineItem.size();
        
        // Delete all satisfied records
        Database.delete(lstAccessDate, false);
        Database.delete(orchProcess, false);
        Database.delete(orchSteps, false);
        Database.delete(calloutResultList, false);
        Database.delete(errorLogList, false);
        Database.delete(pclist, false);
        Database.delete(appLogList, false);
        Database.delete(basketList, false);
        Database.delete(OppLineItem, false);
        
        
    }  
    global void finish(Database.BatchableContext BC)
    {
    /*
     * * Once batch is executed below code will send an email to Executed User
     * */
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:BC.getJobId()];
        String[] toAddresses = new String[] {a.CreatedBy.Email};

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       mail.setToAddresses(toAddresses);
       //mail.setTargetObjectId(u.Id);
       mail.setSubject('Data Clean up job for Last '+ RETAINDATA_DURATION +' Days - ' + a.Status);
       mail.setSaveAsActivity(false);
       mail.setPlainTextBody
       ('The Data Clean up job completed on  \n' 
        +' User_Session: '+ totalAccessDateDelete + ',\n' 
        +' Orch Process: '+ totalorchProcessDelete + ',\n' 
        +' Orch Steps: '+ totalorchStepsDelete + ',\n' 
        +' Call out Resul: '+ totalcalloutResulDelete + ',\n' 
        +' Error Log: '+ totalerrorLogDelete + ',\n' 
        +' Product Config:  '+ totalpclistDelete + ',\n' 
        +' Application Log: '+ totalappLogDelete + ',\n' 
        +' Basket : '+ totalbasketListDelete + ',\n'
        +' Opportunity Line Item : '+ totalOppLineItemDelete + ',\n\n'     
       
        +'Total Record Deleted : ' + (totalAccessDateDelete+totalorchProcessDelete+
                                    totalorchStepsDelete+ totalcalloutResulDelete+
                                    totalerrorLogDelete+totalpclistDelete+totalappLogDelete
                                    +totalOppLineItemDelete) );
       if(!Test.isRunningTest()){
	   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	   }
    }
}