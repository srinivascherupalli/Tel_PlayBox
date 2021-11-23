/*------------------------------------------------------------ 
Company: Infosys 
Description: Batch class to send the updated customer info to TCM
Test Class: SyncUpCustomerTCM_Test
History :
<30-05-2019> <Sasidhar Devarapalli> <EDGE-85839 <Address Fix> Data Cleansing for Address Records - replace invalid Adbor ID> 
------------------------------------------------------------*/

global class SyncUpCustomerTCMBatch implements Database.batchable<sObject>,Database.AllowsCallouts{ 
    public static final String PRIMARY_ADDRESS = 'Primary Address';
    public Set<Id> setAccIds = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        List<cscrm__Account_Address_Relationship__c> addList = [SELECT id, cscrm__Account__c FROM cscrm__Account_Address_Relationship__c WHERE cscrm__Active__c = true  AND cscrm__Address_Type__c='Primary Address' AND cscrm__Address__r.AddressCorrection__c=true];
        System.debug('----addList------->'+addList);
        for(cscrm__Account_Address_Relationship__c accIds : addList){
            setAccIds.add(accIds.cscrm__Account__c);
        }
        System.debug('---------setAccIds------>'+setAccIds);
        String query = 'SELECT id,Customer_Trading_Name__c,Data_Sovereign_Status__c,Pref_Comm_Method__c,Account_UUID__c,VIP_Customer__c,FraudFlag__c,Website,ACN__c,Fax,ABN__c,Email__c,Phone,Name,Validation_Result_Override__c,Bypass_Concession_Validation__c,Last_Validated_Date__c,Valid_Concession_Flag__c,Concession_Type__c,Concession_Number__c,Concession_Authority__c,Credit_Rating__c,Credit_Management_Status__c,Credit_Limit__c,OLB_Online_Bill_Registered__c,TCM_Last_Updated__c,TCM_MasterID__c,Geographical_LocationCode__c,Sic,Date_of_Application__c,Customer_Effective_EndDate__c,Reporting_Point_Indicator__c,Relationship_Type__c,Customer_Effective_Start_Date__c,Validation_Consent_Request_Date__c,Validation_Customer_Consent__c,Recommended_Billing_Frequency__c,Recommended_Payment_Method__c,Approve_Decline_Reason__c,Partners__c,Customer_Current_Revenue__c,Customer_Potential_Revenue__c,Legacy_ROU__c,Legacy_Created_date__c,Customer_Last_Verified_Date__c,Effective_Retired_Date__c,Wriiten_Auth_Required__c,Time_Zone__c,Retirement_Reason__c,Retired_UserID__c,Franchisee_Arrange__c,Acount_Description__c,Date_Started_Trading_with_Telstra__c,Churn_Propensity__c,Loc__c,Actual_Retired_Date__c,Legacy_Ownership_Code__c,CIDN__c,Legacy_SOU__c,Customer_Status__c,Market_Segment__c,Language_Preference__c,Type,Source_System__c,Customer_ID__c,Business_Unit__c,Managed__c FROM Account WHERE id=:setAccIds';
        System.debug(query);
        return Database.getQueryLocator(query);
    }     
    /**------------------------------------------------------------ 
    EDGE-85839
    Method: execute
    Description: Send the customer data to TCM to sync up with the system.
    Inputs: BatchContext, List of Accounts
    Returns:  none
    History 
    <23-05-2019> <Sasidhar Devarapalli>
    ------------------------------------------------------------**/ 
    global void execute(Database.BatchableContext info, List<Account> scope){
        System.debug('********execute method testing**********');
        String eventType = 'EVENT_ACTION_UPDATE';
        ApplicationLog__c failLog= new ApplicationLog__c();
        failLog.Error_Description__c= 'Class : SyncUpCustomerTCMBatch';
        failLog.Request_Message__c = '';
        failLog.Message__c = '';
        List<ApplicationLog__c> appLogs = new List<ApplicationLog__c>();    
        ApplicationLog__c successLog = null;
        ApplicationLog__c failureLog = null;
        Integer successCounter = 0,failuresCounter = 0,normalCounter = 0;
        for(Account acc : scope){ 
            System.debug('------scope------'+scope);
            System.debug('******Inside for loop on execute*********');
            String mcReq = '';
            mcReq = ManageCustomerHandler.generateManageCustomerRequest(acc,eventType); 
            System.debug('GeneratedCustomerRequest'+mcReq);
            HttpResponse resp  = ManageCustomerHandler.sendManageCustomer(mcReq, eventType, acc.Customer_ID__c,true);
            System.debug('ResponseBackFromTCM'+resp); 
            if(successLog == null)
                successLog = new ApplicationLog__c();
            if(failureLog == null)
                failureLog = new ApplicationLog__c();
            if(resp != null){
                if(resp.getStatusCode() == 202){
                successLog.Request_Message__c = successLog.Request_Message__c+'{accid:'+acc.id+',code:'+resp.getStatusCode()+',body:'+resp.getBody()+'}';
                successCounter = successCounter + 1;
            }
            else{
                    failureLog.Request_Message__c = failureLog.Request_Message__c+'{accid:'+acc.id+',code:'+resp.getStatusCode()+',body:'+resp.getBody()+'}';
                    failuresCounter = failuresCounter + 1;
                }
            }
            if(failuresCounter == 9)
            {
                failureLog.Error_Description__c= 'Class : SyncUpCustomerTCMBatch';
                if(failureLog.Request_Message__c!=null && failureLog.Request_Message__c.length()>0)
                appLogs.add(failureLog);
                failureLog = null;
                failuresCounter = 0;
            }
            if(successCounter == 9)
            {
                successLog.Error_Description__c= 'Class : SyncUpCustomerTCMBatch';
                if(successLog.Request_Message__c!=null && successLog.Request_Message__c.length()>0)
                appLogs.add(successLog);
                successLog = null;
                successCounter = 0;
            }
            normalCounter = normalCounter + 1;
            if(normalCounter == scope.size()) //Batch last entry checking.
            {
                if(successLog != null){
                    successLog.Error_Description__c= 'Class : SyncUpCustomerTCMBatch';
                    if(successLog.Request_Message__c!=null && successLog.Request_Message__c.length()>0)
                    appLogs.add(successLog);
                }
                
                if(failureLog != null){
                    failureLog.Error_Description__c= 'Class : SyncUpCustomerTCMBatch';
                    if(failureLog.Request_Message__c!=null && failureLog.Request_Message__c.length()>0)
                    appLogs.add(failureLog);
                }
            }
            
        } 
        System.debug('--------->'+appLogs);
        if(!appLogs.isEmpty() && appLogs.size()>0)
            insert appLogs;
        //insert failLog;
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
        AsyncApexJob asyncJob = [SELECT Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:info.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {asyncJob.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('SyncUpCustomerTCM ' + asyncJob.Status);
        mail.setPlainTextBody('records processed ' + asyncJob.TotalJobItems +   ' with '+ asyncJob.NumberOfErrors + ' failures.');
        if(!Test.isRunningTest()){
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        SyncUpContactTCMBatch syncConObj = new SyncUpContactTCMBatch();
        Id JobId = Database.executeBatch(syncConObj,30);
    } 
}