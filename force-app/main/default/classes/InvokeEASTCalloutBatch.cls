/*------------------------------------------------------------ 
Company: Infosys 
Description: This batch class is intended to correct the incorrect address records in SFDC platform. 
It will to invoke the existing EAST API with configurable size for batch for the given list of adborIds.
The fetched addresses will be upserted into CS address object once all the addresses are fetched.
This class achieves reuse by invoking the existing Address SQ callout feature.
Test Class: InvokeEASTCalloutBatch_Test
History :
<23-05-2019> <Sasidhar Devarapalli> <EDGE-85839 <Address Fix> Data Cleansing for Address Records - replace invalid AdborID> 
<20-06-2019> <EDGE-85839 <Address Fix> Updated code review comments (Comments updated)
------------------------------------------------------------*/

global class InvokeEASTCalloutBatch implements Database.batchable<String>,Database.AllowsCallouts,Database.stateful{ 
    global List<String> adboridList = new List<String>();
    global List<cscrm__Address__c> finalUpdate = new List<cscrm__Address__c>();
    global set<String> failsAdborIds = new set<String>();
   
    global Iterable<String> start(Database.BatchableContext info){ 
    
    //Resetting the AddressCorrection__c field to be false for the existing records to send the correct data to TCM
    List<cscrm__Address__c> addressListUpdate = [select id,AddressCorrection__c from cscrm__Address__c where AddressCorrection__c=true];
        List<cscrm__Address__c> addressListResetList = new List<cscrm__Address__c>();
        for(cscrm__Address__c addrReset : addressListUpdate){
            addrReset.AddressCorrection__c=false;
            addressListResetList.add(addrReset);
        }
        if(!addressListResetList.isEmpty() && addressListResetList.size()>0){
            update addressListResetList;
        }
    
    //EDGE-85839: Reading from a CSV with AdborIDs in a single column.
        adboridList = readDataFromCSV.splitData('AdborIdCSVFile');
        System.debug('adboridList'+adboridList);
        return adboridList;
    }
   
/*------------------------------------------------------------ 
EDGE-85839
Method: execute
Description: Fetch address based on Adbor ID in a batch and persist the map of addresses in Address object.
Inputs: BatchContext, List of AdborIds
Returns:  none
History 
<23-05-2019> <Sasidhar Devarapalli>
------------------------------------------------------------*/ 
    global void execute(Database.BatchableContext info, List<String> scope){
        Map<String,cscrm__Address__c> finalUpdateMap = new Map<String,cscrm__Address__c>();
        System.debug('scope---------------------->'+scope);
        ApplicationLog__c failLog= new ApplicationLog__c();
        failLog.Error_Description__c= 'Class : InvokeEASTCalloutBatch';
        failLog.Request_Message__c = '';
        failLog.Message__c = '';
        Integer failuresCounter = 0,normalCounter = 1;
        List<ApplicationLog__c> appLogs = new List<ApplicationLog__c>();    
        ApplicationLog__c failureLog = null;
        String eastAPIDate = String.valueOf(System.now());
        for(String adborId : scope){
            if(failureLog == null){
                    failureLog = new ApplicationLog__c();
                    failureLog.Request_Message__c = '';
                 }
            try{
            /* EDGE-85839: Calling the overloaded method with an additional argument for enabling batch based rules 
             To avoid persisting per record for batch and to bypass application logs.*/
            
                List<cscrm__Address__c> addressList= SearchAddressController.saveAddressApexList(null,adborId,'adborid',true);
                System.debug('addressList-------->'+addressList.size()+'------'+addressList);
                if(!addressList.isEmpty() && addressList.size()>0){
                //EDGE-85839: Address details are collated so that it can be persisted in a single transaction.
                    for(cscrm__Address__c address: addressList){
                        address.AddressCorrection__c = true;
                        address.EastModified__c = eastAPIDate;
                        finalUpdateMap.put(address.address_id__c,address);
                    }
                }
            }
            catch(Exception e){
                System.debug('ERROR----------->'+e);
                //if(failureLog.Request_Message__c != null && !failureLog.Request_Message__c.contains(adborId))
                failureLog.Request_Message__c = failureLog.Request_Message__c + '{adborId:'+adborId+',error:'+e+'}';
                failuresCounter = failuresCounter + 1;
            //EDGE-85839: Collating the failed records to persist into the application log.
            }
            normalCounter = normalCounter + 1;
            System.debug('failuresCounter step-1-----------'+failuresCounter);
            if(failuresCounter == 9)
            {
                System.debug('failureLog step-1-----------'+failureLog);
                failureLog.Error_Description__c= 'Class : InvokeEASTCalloutBatch';
                appLogs.add(failureLog);
                failureLog = null;
                failuresCounter = 0;
            }
           else if(normalCounter == scope.size()) //Batch last entry checking.
            {
                if(failureLog != null){
                     System.debug('failureLog step-2-----------'+failureLog);
                     failureLog.Error_Description__c= 'Class : InvokeEASTCalloutBatch';
                     appLogs.add(failureLog);
                     // flagCheck = false;
                }
                
            }
                
        }
        System.debug(appLogs.size()+'step-3-------->'+appLogs);
        if(!appLogs.isEmpty() && appLogs.size()>0)
            Database.SaveResult[] srList = Database.insert(appLogs, false);

        System.debug('finalUpdateMap---------->'+finalUpdateMap.size()+'-------->'+finalUpdateMap);
        if(!finalUpdateMap.isEmpty() && finalUpdateMap.size()>0){
            Schema.SObjectField addresID = cscrm__Address__c.Fields.Address_ID__c;
            Database.UpsertResult[] results = Database.upsert(finalUpdateMap.values(), addresID, false);
            System.debug('final result'+results);
        }
    }
     /**------------------------------------------------------------ 
    EDGE-85839
    Method: finish
    Description: Send final results to User/Developer
    Inputs: BatchableContext, Batch job results.
    Returns:  none
    History 
    <23-05-2019> <Sasidhar Devarapalli>
    ------------------------------------------------------------**/ 
    global void finish(Database.BatchableContext info){ 
        AsyncApexJob asyncJob = [SELECT Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:info.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {asyncJob.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('InvokeEASTCalloutBatch : Update Contact data to TCM ' + asyncJob.Status);
        mail.setPlainTextBody('records processed ' + asyncJob.TotalJobItems +   ' with '+ asyncJob.NumberOfErrors + ' failures.');
       if(!Test.isRunningTest()){
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        
        SyncUpCustomerTCMBatch syncCusObj = new SyncUpCustomerTCMBatch();
        Id JobId = Database.executeBatch(syncCusObj,30);
    }
}