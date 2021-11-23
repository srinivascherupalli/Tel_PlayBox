/**------------------------------------------------------------ 
Company: Infosys 
Description: Batch class to send the updated contact information to TCM
Test Class: SyncUpContactTCM_Test
History :
<30-05-2019> <Sasidhar Devarapalli> <EDGE-85839 <Address Fix> Data Cleansing for Address Records - replace invalid Adbor ID> 
------------------------------------------------------------**/

global class SyncUpContactTCMBatch implements Database.batchable<sObject>,Database.AllowsCallouts,Database.Stateful{ 
    public static final String PRIMARY_ADDRESS = 'Primary Address';
    public Set<Id> setConIds = new Set<Id>();
    global map<Id,cscrm__Contact_Address_Relationship__c> conAddresMap = new map<Id,cscrm__Contact_Address_Relationship__c>();
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        List<cscrm__Contact_Address_Relationship__c> conRel = [SELECT id, cscrm__End_Date__c,cscrm__Contact__c FROM cscrm__Contact_Address_Relationship__c WHERE cscrm__Active__c = true AND cscrm__Address_Type__c IN ('Home Address', 'Office Address') AND Primary__c = true AND cscrm__Address__r.AddressCorrection__c = true];
         //EDGE-85839: Get the contact ids from the cscrm__Contact_Address_Relationship__c junction Object
        for(cscrm__Contact_Address_Relationship__c conRelation : conRel){
            setConIds.add(conRelation.cscrm__Contact__c);
            conAddresMap.put(conRelation.cscrm__Contact__c,conRelation);
        }
        String query = 'SELECT id,Home_Email__c,Driver_Licence_State__c,Driver_License_Id__c,AccountId,Home_Fax__c,TCM_Last_Updated_Datetime__c,Language_Preference__c,Has_Reviewed__c,jobTitle__c,Job_Description__c,timeZone__c,Occupation__c,numberInHousehold__c,Notes__c,lastVerifiedDate__c,Pref_Comm_Method__c,Online_Flag__c,Email,Contact_Status__c,Phone,MobilePhone,Fax,HomePhone,HomePhone__c,Birthdate,LastName,Source_System__c,UUID__c,Salutation,FirstName,MiddleName FROM Contact WHERE id IN :setConIds AND AccountId <> null AND UUID__c <> null ';
        System.debug('query----->'+query);
        return Database.getQueryLocator(query);
    }
    /**------------------------------------------------------------ 
    EDGE-85839
    Method: execute
    Description: Send the contact record to external TCM system.
    Inputs: BatchContext, List of Contact records
    Returns:  none
    History 
    <30-05-2019> <Sasidhar Devarapalli>
    ------------------------------------------------------------**/ 
    global void execute(Database.BatchableContext info, List<Contact> scope){
        System.debug('********execute method testing**********');
        String event = ManageContactHandler.EVENT_ACTION_UPDATE;
        Boolean isEndDated = false;
        Logger2 loggerArg = Logger2.getLogger('SyncUpContactTCM');
        ApplicationLog__c failLog = new ApplicationLog__c();
        failLog.Error_Description__c= 'Class : SyncUpContactTCM';
        failLog.Request_Message__c = '';
        failLog.Message__c = '';
        List<ApplicationLog__c> appLogs = new List<ApplicationLog__c>();    
        ApplicationLog__c successLog = null;
        ApplicationLog__c failureLog = null;
        
        Integer successCounter = 0,failuresCounter = 0,normalCounter = 1;
        System.debug('------scope------'+scope);
        for(Contact con : scope){ 
            if(conAddresMap.containsKey(con.id)){
                cscrm__Contact_Address_Relationship__c addDate = conAddresMap.get(con.id);
                if(addDate.cscrm__End_Date__c!=null && addDate.cscrm__End_Date__c==Date.today()){
                    isEndDated = true;
                }else{isEndDated = false;}
            }
            //EDGE-85839: Generats the TCM contact request as String
            String mcReq = ManageContactHandler.generateManageContactRequest(con,event,null,isEndDated,con.AccountId);
            System.debug('mcReq :: ---------->'+ mcReq);
            //EDGE-85839: Send the request to TCM
            HttpResponse resp = new HttpResponse();
            if(!Test.isRunningTest()){
            resp = ManageContactHandler.sendManageContact(mcReq,event,con.UUID__c,loggerArg,true);
            }else{
                System.debug('Null');
            }
            System.debug('resp :: ---------->'+resp);
            if(resp != null)
            {
                if(resp.getStatusCode() == 202){
                    if(successLog == null)
                        successLog = new ApplicationLog__c();
                    successLog.Request_Message__c = successLog.Request_Message__c+'{conid:'+con.id+',code:'+resp.getStatusCode()+',body:'+resp.getBody()+'}';
                    successCounter = successCounter + 1;
                }
                else{
                    if(failureLog == null)
                        failureLog = new ApplicationLog__c();
                    failureLog.Request_Message__c = failureLog.Request_Message__c+'{conid:'+con.id+',code:'+resp.getStatusCode()+',body:'+resp.getBody()+'}';
                    failuresCounter = failuresCounter + 1;
                }
            }
            
            if(failuresCounter == 9)
            {
                failureLog.Error_Description__c= 'Class : SyncUpContactTCM';
                appLogs.add(failureLog);
                failureLog = null;
                failuresCounter = 0;
            }
            if(successCounter == 9)
            {
                successLog.Error_Description__c= 'Class : SyncUpContactTCM';
                appLogs.add(successLog);
                successLog = null;
                successCounter = 0;
            }
            normalCounter = normalCounter + 1;
            if(normalCounter == scope.size()) //Batch last entry checking.
            {
                if(successLog != null){
                    successLog.Error_Description__c= 'Class : SyncUpContactTCM';
                    appLogs.add(successLog);
                }
                
                if(failureLog != null){
                    failureLog.Error_Description__c= 'Class : SyncUpContactTCM';
                    appLogs.add(failureLog);
                }
                
            }
        }
        System.debug('appLogs :: ----------->'+appLogs.size()+'----'+appLogs);
        if(!appLogs.isEmpty() && appLogs.size()>0){
            insert appLogs;
            System.debug('appLogs :: step1----------->'+appLogs.size()+'----'+appLogs);
        }
    }     
     /**------------------------------------------------------------ 
    EDGE-85839
    Method: finish
    Description: Send final results to User/Developer
    Inputs: BatchableContext, Batch job results.
    Returns:  none
    History 
    <30-05-2019> <Sasidhar Devarapalli>
    ------------------------------------------------------------**/ 
    global void finish(Database.BatchableContext info){  
        AsyncApexJob asyncJob  = [SELECT Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    FROM AsyncApexJob WHERE Id =:info.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {asyncJob.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('SyncUpContactTCM : Update Contact data to TCM ' + asyncJob.Status);
        mail.setPlainTextBody('records processed ' + asyncJob.TotalJobItems +   ' with '+ asyncJob.NumberOfErrors + ' failures.');
       if(!Test.isRunningTest()){
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
       }
    } 
}