/*
*@Created Date : 8-3-2021
*@Created By : Kamlesh Kumar
*@Breif : Utility class, contains logic which can be used in different classes
*/
/*************************************************************************************************************************************************
* Name         :   GenericUtilityClass  
* Description  :   Utility class, contains logic which can be used in different classes                   
* Test Class   :   GenericUtilityClassTest,ShowSubscriptionsOnMACButtonControllTest

Sr.No.      Developer Name      Date            Story           Description
1.          Gokul               29/04/2021      EDGE-210200     Added generic method to check for any parallel MACD subscriptions are there 

2.          Pooja               14/04/2021      EDGE-209488      To filter Subscription record related to COBA request

**************************************************************************************************************************************************/

public with sharing class GenericUtilityClass {
    private static final String USER_KEY        =   'User_Match_Found';
    private static final String PROFILE_KEY     =   'Profile_Match_Found';
    private static final String ORG_KEY         =   'Org_Match_Found';
    private static String correlationId         =   GuidUtil.NewGuid();

    /*
    *@Created By : Kamlesh Kumar
    *@Created Date : 17/3/2021
    *@Breif : EDGE : 200438 Fetches the group details
    */
    public static List<Group> fetchGroupTypeDetails(String name, String groupType) {
       List<Group> groupList = new List<Group>();
       groupList = [select Id from Group where Type =: +groupType AND DeveloperNAME =: +name];
       return groupList;
    }
    
    /*
    *@Created By : Kamlesh Kumar
    *@Created Date : 8-3-2021
    *@Breif : EDGE-205509, Return apex job details using the the apex job id.
    */
    public static Map <String,AsyncApexJob> ayncJobDetails(List<String>jobId) {
        Map <String,AsyncApexJob> asyncApexJobMap = new Map <String,AsyncApexJob>();
        Set<String> jobSet = new Set<String>();
        jobSet.addAll(jobId);
        for(AsyncApexJob asyncjob: [SELECT id, Status, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :jobId AND JobType = 'BatchApex' ORDER BY CreatedDate DESC]) {
            asyncApexJobMap.put(asyncjob.id, asyncjob);
        }
        return asyncApexJobMap;
    }
   
    /*
    *@Created By : Kamlesh Kumar
    *@Created Date : 17-3-2021
    *@Breif : EDGE-205509, Update AsyncJobIdWrapper and create a new sync job id string.Return sync job string.
    */
    public static String createSyncJobMessage(String jobMessage,String jobName,Boolean isCompleted, Boolean isError) {
        String jsonMessage;
        if(String.isNotBlank(jobMessage) && jobMessage.contains(jobName)) {
            CheckAsyncJobDetails.AsyncJobIdWrapper asyncwrap = new CheckAsyncJobDetails.AsyncJobIdWrapper();
            List<CheckAsyncJobDetails.AsyncJobIdWrapper> obj = asyncwrap.parse(jobMessage);
            List<CheckAsyncJobDetails.AsyncJobIdWrapper> updatedWrapper = new List<CheckAsyncJobDetails.AsyncJobIdWrapper>();
            for(CheckAsyncJobDetails.AsyncJobIdWrapper wp : obj ) {
                if(wp.name == jobName) {
                    wp.isCompleted = isCompleted;
                    wp.error = isError;
                }
                updatedWrapper.add(wp);
            }
            jsonMessage = JSON.serialize(updatedWrapper);
        }
        return jsonMessage;
    }

    /*
    *@Created By : Pooja Bhat
    *@Created Date : 14-04-2021
    *@Description : EDGE-209488, To retrieve SObject records using dynamic query construct
                    1. Parameter inputMap accept map of <fieldName, operator fieldValue>,
                    2. Parameter fieldsList accept the list of fields to be retreived 
                    3. Parameter objectAPIName, accept the object name to query the record
    */
    public static List<SObject> getfilteredQueryResult(Map<String, Object> inputMap, List<String> fieldsList, String objectAPIName) {
        List<SObject> queryResult   =   new List<SObject>();
        if(fieldsList != null && !fieldsList.isEmpty() && String.isNotBlank(objectAPIName)) {
            String query =  'SELECT ';
            for(String fields : fieldsList) {
                query += fields + ', ';
            }
            query =  query.removeEnd(', ');
            query += ' FROM ' + objectAPIName; 
            if(inputMap != null && inputMap.size() > 0) {
                query += ' WHERE ';
                for(String filterFields : inputMap.keySet()) {


                    String fieldName    =   filterFields;
                    String fieldValue   =   (String)inputMap.get(filterFields);
                    query               +=  fieldName + fieldValue + ' AND ';
                }
            }   
            query   =   (query.endsWith('AND ') ? query.removeEnd('AND ') : (query.endsWith('WHERE ') ? query.removeEnd('WHERE ') : ''));

            queryResult =   Database.query(query);

        }
        return queryResult;
    }   //End of getFilteredSubscriptionsData()
    
    /*
    *@Created By : Pooja Bhat
    *@Created Date : 14-04-2021
    *@Description : EDGE-209488, To get the Status value allowed for COBA Request
    */
    public static List<String> getSubscriptionStatusAllowingCoBA() {
        List<String> statusList             =  new List<String>();
        Utility_Settings__c utilitySettings =  Utility_Settings__c.getInstance();
        if(String.isNotBlank(utilitySettings.Subscription_Statuses_Allowing_CoBA__c)) {
            for(String status : utilitySettings.Subscription_Statuses_Allowing_CoBA__c.split(',')) {
                statusList.add('\''+status+'\'');
            }
        }
        return statusList;
    }   //End of getSubscriptionStatusAllowingCoBA()
   
    /*
    *@Created By : GOkul
    *@Created Date : 15-04-2021
    *@Description : This method is a generic method to log the exceptions
    */
    public static void logException(string CONST_INTERFACENAME,String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription, C2O_ExceptionHandler.Capability codeCapability){
      Map<String, Object> eLogMap = new Map<String, Object>();
      eLogMap.put('interfaceName', CONST_INTERFACENAME);
      eLogMap.put('elementName', methodName);
      eLogMap.put('referenceNumber', referenceNumber);
      eLogMap.put('correlationId', correlationId);
      eLogMap.put('errorDescription', errorMessage);
      eLogMap.put('businessDescription', businessDescription);
      eLogMap.put('capability', codeCapability);
      C2O_Utilities.logException(eLogMap, false);
    }

    /*
    *@Created By : Pooja Bhat
    *@Created Date : 19-04-2021
    *@Description : EDGE-210731, To retrieve the MACD Order Action Types List from the metadata MACD_Order_Options__mdt. 
        This will return personalised Action Type list based on User/Profile/Org setting saved in MACD Order Options metadata
    */
    public static MACD_Order_Options__mdt retrieveEligibleActionTypes(String userId, String profileId, List<String> fieldList) {
        String currentUserId                                =   userId;
        String currentProfileId                             =   profileId;
        String currentOrgId                                 =   '';
        Map<String, Object> inputMap                        =   new Map<String, Object>();
        Map<String,MACD_Order_Options__mdt> macdOrderMap    =   new  Map<String,MACD_Order_Options__mdt>();
        List<MACD_Order_Options__mdt> lstMACDOrderTypeMtd   =   new List<MACD_Order_Options__mdt>();
        inputMap.put('Profile_User__r.Salesforce_Id__c',' IN (\''+  String.escapeSingleQuotes(currentUserId) + '\',\'' + String.escapeSingleQuotes(currentProfileId) + '\',\'' + currentOrgId + '\')');
        lstMACDOrderTypeMtd   =   GenericUtilityClass.getfilteredQueryResult(inputMap,fieldList,'MACD_Order_Options__mdt');
        for(MACD_Order_Options__mdt macdOrdOpt : lstMACDOrderTypeMtd) {
            if(macdOrdOpt.Profile_User__r.Salesforce_Id__c == currentUserId) {
                macdOrderMap.put(USER_KEY,macdOrdOpt);
            } else if(macdOrdOpt.Profile_User__r.Salesforce_Id__c == currentProfileId) {
                macdOrderMap.put(PROFILE_KEY,macdOrdOpt);
            } else if(macdOrdOpt.Profile_User__r.DeveloperName == 'Telstra_Corporation_Limited') {
                macdOrderMap.put(ORG_KEY,macdOrdOpt);
            }
        }
        if(macdOrderMap.containsKey(USER_KEY) && macdOrderMap.get(USER_KEY)!=null) {
            return macdOrderMap.get(USER_KEY);
        }         
        if(macdOrderMap.containsKey(PROFILE_KEY) && macdOrderMap.get(PROFILE_KEY)!=null) {
            return macdOrderMap.get(PROFILE_KEY);
        } 
        return macdOrderMap.get(ORG_KEY);         
    } //End of retrieveEligibleActionTypes()

     /*
    *@Created By : GOkul
    *@Created Date : 20-04-2021
    *@Description : 210200- This method is a generic method to check for any parallel MACD subscriptions are there
    */
    public static parallelChangeValidationResponse parallelChangeValidationForNonCommMACD(List<String> subscriptionIdList){

        boolean hasReplacedSub = false;
        parallelChangeValidationResponse pcv = new parallelChangeValidationResponse();
        try{
            Utility_Settings__c cobaUtilSettings =   Utility_Settings__c.getInstance();
            string feedMessage = (String.isNotBlank(cobaUtilSettings.CoBA_Parallel_MACD_Error__c) ? cobaUtilSettings.CoBA_Parallel_MACD_Error__c : '');
            string ownerName;
            string ownerEmail;
            for(cscfga__product_configuration__c pc : Model_ProductConfiguration.getConfigWithReplacedSubs(subscriptionIdList)){
                list<string> params = new list<string>();
                ownerName = pc.cscfga__product_basket__r.Owner.Name;
                ownerEmail = pc.cscfga__product_basket__r.Owner.Email;
                params.add(ownerName);
                params.add(ownerEmail);                             
                hasReplacedSub = true;                                        
                pcv.BasketName = pc.cscfga__product_basket__r.Name;
                pcv.BasketOwnerName = pc.cscfga__product_basket__r.Owner.Name;
                pcv.BasketOwnerEmailId = pc.cscfga__product_basket__r.Owner.Email;
                pcv.ChangeAllowed = false;
                pcv.ErrorMessage = String.format(feedMessage, params);

                }
                if(!hasReplacedSub){
                    pcv.ChangeAllowed = true;
                }
                return pcv;
        }
        catch(Exception e) {
            logException('GenericUtilityClass','parallelChangeValidationResponse','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured while submitting CoBA request',C2O_ExceptionHandler.Capability.ORD);
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage() );
        }
        
    }


     /*
     *@Created By : Pooja Bhat
     *@Created Date : 14-04-2021
     *@Description : EDGE-209488, To filter Subscription record related to COBA request
    */
    public static List<csord__Subscription__c> filterSubcriptionCoBARequest(List<csord__Subscription__c> subsList) {
        List<csord__Subscription__c> subscriptionsLst   =  new List<csord__Subscription__c>();
        if(subsList != null && !subsList.isEmpty()) {
            Map<Id,csord__Subscription__c> mapSubscriptions  =  new Map<Id,csord__Subscription__c>();
            Set<String> setHardwareSubsIds          =  new Set<String>();
            for(csord__Subscription__c subs : subsList) {
                Boolean isHWRefundElgbl =   subs.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Eligible_For_Hardware_Refund__c;
                Boolean isHardware      =   subs.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c;
                String refundDuration   =   subs.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Refund_Duration__c;
                if(isHWRefundElgbl && String.isNotBlank(refundDuration) && subs.Initial_Activation_DateTime__c!=null && ((Date.valueOf(subs.Initial_Activation_DateTime__c)).daysBetween(System.Today())) <  Integer.valueOf(refundDuration) ) {
                    continue;
                } else {
                    mapSubscriptions.put(subs.Id,subs);
                } 
                if(isHardware) {
                    setHardwareSubsIds.add(subs.Id);
                }               
            }
            if(!setHardwareSubsIds.isEmpty()) {
                List<csord__Service__c> serviceList = [SELECT Id,Name,Payment_Type__c,csord__Subscription__c 
                    FROM csord__Service__c 
                    WHERE csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c = true AND csord__Subscription__c IN:setHardwareSubsIds];
                for(csord__Service__c oServ : serviceList) {
                    if(oServ.Payment_Type__c != 'Hardware Repayment' && !mapSubscriptions.isEmpty() && mapSubscriptions.containsKey(oServ.csord__Subscription__c)) {
                        mapSubscriptions.remove(oServ.csord__Subscription__c);
                    }
                }
            }
            subscriptionsLst.addAll(mapSubscriptions.values());
        }
        return subscriptionsLst;
    }  //End of filterSubcriptionCoBARequest()

}