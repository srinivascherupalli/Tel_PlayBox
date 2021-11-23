/*********************************************************************************************************************************
 *Class Name      :   CoBAProcessHelper
Test Class : CoBAProcessHelperTest
Ch.No.  Developer Name      Date            Story Description
1.      Gokul               21/04/2021      EDGE-210200 - Created a new method to validate parallel change before submit in CoBA process 
2.      Kamlesh             21/04/2021      EDGE-210193 - Created a method to execute batch class and in case of exception send chatter notification to user      
3.      Pooja Bhat          22/04/2021      EDGE-212439 - As a User, I should receive Chatter Notification if CoBA request fails/Errors
4.      Kamlesh Kumar       4/5/2021        EDGE-212440 - As a User on click of submit button on case UI. I shall resubmit the case if any error occurs
*********************************************************************************************************************************
*/
public with sharing class CoBAProcessHelper {
    
    //EDGE-210193:Added for exception handling
    private static String correlationId =   GuidUtil.NewGuid();
    private static String className     =   'CoBAProcessHelper';

    //   EDGE-210200 - This method to validate parallel change before submit in CoBA process 
    public static String validationBeforeCoBASubmission(list<string> subids){
        string response;
        try{
            parallelChangeValidationResponse pcv = GenericUtilityClass.parallelChangeValidationForNonCommMACD(subids);
            if(pcv.ChangeAllowed){
                response ='success';
            }else{
                response = pcv.ErrorMessage;    
            }
            return response;
        }catch(Exception e) {
            GenericUtilityClass.logException(className,'validationBeforeCoBASubmission','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured while submitting CoBA request',C2O_ExceptionHandler.Capability.ORD);
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage() );
        }
        
        
    }
    
    /********************************************************************************************************************************************
    * Method Name:  billingAPICalloutsForCoBA
    * Created Date : 21-4-2021
    * Created By : Kamlesh Kumar
    * Edge :210193
    * Description:  The method will be invoke from CoBASubscriptionsUpdateBatch,CoBASubscriptionsUpdateUtility and this method will execute the batch class : CoBABatchHanlder 
    ********************************************************************************************************************************************/    
    public static void billingAPICalloutsForCoBA(List<String> caseId) {
        Set<String> caseIdList = new Set<String>(caseId);
        caseIdList.addAll(caseId);
        try {
            if(String.isNotBlank(BDS_API_Settings__c.getValues('SubscriptionAPI Limit').Value__c)) {
                Id jobId = Database.executeBatch(new CoBABatchHandler(Id.valueOf(caseId[0])),Integer.valueOf(BDS_API_Settings__c.getValues('SubscriptionAPI Limit').Value__c));
            }    
        }catch(Exception e) {
            cobaSubmissionFailureChatterPost(caseIdList);
            GenericUtilityClass.logException(className,'billingAPICalloutsForCoBA','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during billing api callout',C2O_ExceptionHandler.Capability.ORD);
            
        }
        
    }
    
    /********************************************************************************************************************************************
    * Method Name:  billingAPICalloutsForCoBA
    * Created Date : 21-4-2021
    * Created By : Kamlesh Kumar
    * Edge :212440
    * Description: The method will also be used to fetch validations value and display on case UI(Record type :  Change of billing account)
    ********************************************************************************************************************************************/    
    @AuraEnabled
    public static Map<String,String> coBACaseResubmitMethod(List<String> caseId) {
        Utility_Settings__c utilSettings = Utility_Settings__c.getInstance();
        String CoBASubmitNotAllowedMessage = utilSettings.CoBA_submit_not_allowed_message__c;
        String CoBAAssociationStatuseAllowingSubmit  = utilSettings.CoBA_association_statuse_allowing_submit__c;  
        Map<String,String> validationMessageMap = new Map<String,String>();
        set<String> successCaseId = new set<String>();
        set<String> failureCaseId = new set<String>();
        successCaseId.addAll(new Set<String>(caseId));
        List<String> subscriptionStatusList = CoBAAssociationStatuseAllowingSubmit.split(',');
        try  {
            List<Case> caseList = [SELECT Id,Status,(SELECT id,Status__c from Subscriptions_to_Case_Associations__r WHERE Status__c IN:subscriptionStatusList) FROM Case WHERE Id IN:successCaseId];
            
            for(Case cc:caseList) {
                if(cc.Status!='In Error' && !validationMessageMap.containsKey(cc.Id)) {
                    String messgae = CoBASubmitNotAllowedMessage;
                    messgae = messgae.replace('<status>',cc.Status);
                    validationMessageMap.put(cc.Id,messgae);
                }
                else if(cc.Subscriptions_to_Case_Associations__r.size()== 0 && !validationMessageMap.containsKey(cc.Id)) {
                    validationMessageMap.put(cc.Id,'There are no subscriptions ready to be submitted.');
                }
            }
            if(String.isNotBlank(BDS_API_Settings__c.getValues('SubscriptionAPI Limit').Value__c) && !validationMessageMap.containsKey(caseId[0])) {
                Case caseRecord = new Case(Id=caseId[0],Status='In Progress');
                update caseRecord;
                Id jobId = Database.executeBatch(new CoBABatchHandler(caseRecord.Id),Integer.valueOf(BDS_API_Settings__c.getValues('SubscriptionAPI Limit').Value__c));
                validationMessageMap.put(caseRecord.Id,utilSettings.CoBA_submission_success_message__c);
            }    
            validationMessageMap.put('showToastMessage',String.valueof(utilSettings.ShowCoBAToastMessage__c));
        }catch(Exception e) {
            Case caseRecord = new Case(Id=caseId[0],Status='In Error');
            update caseRecord;
            failureCaseId.add(caseRecord.Id);
            cobaSubmissionFailureChatterPost(failureCaseId);
            GenericUtilityClass.logException(className,'billingAPICalloutsForCoBA','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during billing api callout',C2O_ExceptionHandler.Capability.ORD);
            validationMessageMap.put(caseRecord.Id,utilSettings.CoBA_submission_error_message__c);
            validationMessageMap.put('showToastMessage',String.valueof(utilSettings.ShowCoBAToastMessage__c));
            return validationMessageMap;
            
        }
          
       return validationMessageMap;
       
    }
    
    
    /********************************************************************************************************************************************
    * Method Name:  cobaSubmissionFailureChatterPost
    * Description:  To post chatter feed on CoBA Request Submission Failure.
    ********************************************************************************************************************************************/    
    public static void cobaSubmissionFailureChatterPost(Set<String> setCaseIds) {
        List<ChatterUtilityClass.ChatterFeedWrapper> feedsLst   =   new List<ChatterUtilityClass.ChatterFeedWrapper>();
        List<String> params                                     =   new List<String>();
        Utility_Settings__c cobaUtilSettings                    =   Utility_Settings__c.getInstance();
        String feedMessage                                      =   (String.isNotBlank(cobaUtilSettings.Chatter_notification_for_CoBA_failure__c) ? cobaUtilSettings.Chatter_notification_for_CoBA_failure__c : '');
        String telstraITLink                                    =   (String.isNotBlank(cobaUtilSettings.Telstra_MyIT__c) ? cobaUtilSettings.Telstra_MyIT__c : '');
        String currentUserId                                    =   UserInfo.getUserId();
        String caseIds                                          =   '';
        for(String caseId : setCaseIds) {
            caseIds += ' {record:' + caseId + '},';            
        }
        caseIds = caseIds.removeEnd(',');
        params.add('{'+currentUserId+'}');
        params.add(caseIds);
        params.add(telstraITLink);
        feedsLst.add(new ChatterUtilityClass.ChatterFeedWrapper(null,currentUserId,String.format(feedMessage, params)));
        if(feedsLst!=null && feedsLst.size() > 0) {
            ChatterUtilityClass.chatterNotificationHelper(feedsLst);
        }
    }   //End of cobaSubmissionFailureChatterPost()
}