/**================================================================
 * Appirio, Inc
 * Name: Orchestration_AbstractStepHandler
 * Description: This class implements the CSPOFA.ExecutionHandler,CSPOFA.Calloutable to provide abstract/virtual methods for the interface methods
 *               and so that the orchestration step handlers need to implement only the methods they have to.
 * Created Date: June 11, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/

 public with sharing abstract class Orchestration_AbstractStepHandler implements CSPOFA.ExecutionHandler, CSPOFA.Calloutable {
    //Collections to store the DML data
    protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
    protected List<SObject> sObjectsToInsert = new List<SObject>();
    protected Map<Id, SObject> sObjectsToDelete = new Map<Id, SObject>();
    protected List<SObject> sObjectsToUndelete = new List<SObject>();
    protected List<SObject> eventsToPublish = new List<SObject>();
    //Collection to Store the Step Result
    protected Map<Id, stepResult> stepResults = new Map<Id, stepResult>();
    //Collection to Store the recordIds related to the step directly
    protected Set<Id> accountIds = new Set<Id>();
    protected Set<Id> orderIds = new Set<Id>();
    protected Set<Id> subscriptionIds = new Set<Id>();
    protected Set<Id> serviceIds = new Set<Id>();
    //Step --> Processed Ids Attachment
    protected Map<Id, Attachment> stepProcessedAttachData = new Map<Id, Attachment>();
    //Log --> Callout Attachment
    protected Map<Id, Attachment> stepCalloutAttachData = new Map<Id, Attachment>();
    //Step --> (Related Record --> Application Logs)
    protected Map<Id, Map<Id, ApplicationLog__c>> mapStepIdToRecordApplicationLog = new Map<Id, Map<Id, ApplicationLog__c>>();
    protected Map<Id, Map<String, ApplicationLog__c>> mapStepIdToUniqueIdApplicationLog = new Map<Id, Map<String, ApplicationLog__c>>();

    /**
     * @author Ashish Agarwal
     * @date 30/12/2019
     * @description called to perform SOQL to fetch step data for the data in context for the running batch transaction
     * @param List<sObject> a list of steps being passed in to the process method during batch execution
     */
    public virtual List<sObject> getStepList(List<sObject> steps) {
        List<sObject> stepList = [
            SELECT
                ID,
                Name,
                CSPOFA__Orchestration_Process__c,
                CSPOFA__Status__c,
                CSPOFA__Completed_Date__c,
                JSON__c,
                CSPOFA__Message__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,
                CSPOFA__Orchestration_Process__r.cspofa__account__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                CSPOFA__Orchestration_Process__r.Order__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];

        return stepList;
    }

    /**
     * @author Gaurang Maheshwari
     * @date 30/12/2019
     * @description fetch the processedIds attachment if step is partial or error
     */
    public virtual void getAttachmentList(Set<String> stepIds) {
        for (Attachment attch : [SELECT Id, Name, parentId, body FROM Attachment WHERE parentId IN :stepIds AND Name = :OrchestratorConstants.DataOrchestrationNames.processedIds]) {
            stepProcessedAttachData.put(attch.parentId, attch);
        }
    }

    public virtual void getAttachmentList(Set<String> stepIds, Set<String> appLogIds) {
        for (Attachment attch : [SELECT Id, Name, parentId, body FROM Attachment WHERE (parentId IN :stepIds AND Name = :OrchestratorConstants.DataOrchestrationNames.processedIds) OR (parentId IN :appLogIds AND Name = :OrchestratorConstants.DataOrchestrationNames.callOutResponse)]) {
            if (attch.Name == OrchestratorConstants.DataOrchestrationNames.processedIds) {
                stepProcessedAttachData.put(attch.parentId, attch);
            } else {
                stepCalloutAttachData.put(attch.parentId, attch);
            }
        }
    }

    public virtual void getResponseAndProcessIdAttachments(Set<String> stepIds, String handlerName) {
        Set<String> appResponseinAttachments = new Set<String>();
        for (ApplicationLog__c app : [SELECT Id, Reference_Info__c, Debug_Level__c, Related_Record_Id__c, Step__c, Status_Code__c, Message__c FROM ApplicationLog__c WHERE Step__c IN :stepIds AND Reference_Info__c = :handlerName ORDER BY createdDate DESC]) {
            if (!mapStepIdToRecordApplicationLog.containsKey(app.Step__c)) {
                Map<Id, ApplicationLog__c> tempMap = new Map<Id, ApplicationLog__c>();
                tempMap.put(app.Related_Record_Id__c, app);
                mapStepIdToRecordApplicationLog.put(app.Step__c, tempMap);
            } else {
                Map<Id, ApplicationLog__c> tempMap = mapStepIdToRecordApplicationLog.get(app.Step__c);
                if (!tempMap.containsKey(app.Related_Record_Id__c)) {
                    tempMap.put(app.Related_Record_Id__c, app);
                }
                mapStepIdToRecordApplicationLog.put(app.Step__c, tempMap);
            }
            if (app.Message__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                appResponseinAttachments.add(app.Id);
            }
        }

        if (appResponseinAttachments != null) {
            getAttachmentList(stepIds, appResponseinAttachments);
        } else {
            getAttachmentList(stepIds);
        }
    }

    public virtual void getUniqueResponseAndProcessIdAttachments(Set<String> stepIds, String handlerName) {

        Set<String> appResponseinAttachments = new Set<String>();
        for (ApplicationLog__c app : [SELECT Id, Reference_Info__c, Debug_Level__c, Related_Record_Id__c, Step__c, Status_Code__c, Message__c FROM ApplicationLog__c WHERE Step__c IN :stepIds AND Reference_Info__c = :handlerName ORDER BY createdDate DESC]) {
            if (!mapStepIdToUniqueIdApplicationLog.containsKey(app.Step__c)) {
                Map<String, ApplicationLog__c> tempMap = new Map<String, ApplicationLog__c>();
                tempMap.put(app.Related_Record_Id__c, app);
                mapStepIdToUniqueIdApplicationLog.put(app.Step__c, tempMap);
            } else {
                Map<String, ApplicationLog__c> tempMap = mapStepIdToUniqueIdApplicationLog.get(app.Step__c);
                if (!tempMap.containsKey(app.Related_Record_Id__c)) {
                    tempMap.put(app.Related_Record_Id__c, app);
                }
                mapStepIdToUniqueIdApplicationLog.put(app.Step__c, tempMap);
            }
            if (app.Message__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                appResponseinAttachments.add(app.Id);
            }
        }

        if (appResponseinAttachments != null) {
            getAttachmentList(stepIds, appResponseinAttachments);
        } else {
            getAttachmentList(stepIds);
        }
    }


    /**
     * @author Ashish Agarwal
     * @date 30/12/2019
     * @description called to perform callouts from the step handlers. The step handlers can chose to ignore this if they dont
     *             need any callouts to be performed.
     * @param List<sObject> a list of steps being passed in to the process method during batch execution
     */
    public virtual Boolean performCallouts(List<SObject> data) {
        return true;
    }

    /**
     * @author Ashish Agarwal
     * @date 30/12/2019
     * @description runs the logic during the batch execution context. The step handlers need to implement
     *              this method.
     * @param List<sObject> a list of steps being passed in to the process method during batch execution
     */
    public abstract List<SObject> process(List<sObject> steps);

    /**
     * @author Ashish Agarwal
     * @date 30/12/2019
     * @description Updates the objects, if any.
     */
    public virtual void insertObjects() {
        if (sObjectsToInsert.size() > 0)
            insert sObjectsToInsert;
    }

    /**
     * @author Ashish Agarwal
     * @date 30/12/2019
     * @description Updates the objects, if any.
     */
    public virtual void updateObjects() {
        if (sObjectsToUpdate.size() > 0)
            update sObjectsToUpdate.values();
    }

    /**
     * @author Gaurang Maheshwari
     * @date 19/05/2020
     * @description publishing the high volume events
     */
    public virtual void publishObject(List<Orchestration_CallOutResponse> respList) {
        Boolean allSuccess = true;
        
        if (eventsToPublish.size() > 0) {
            //High value events are queued therefore async
            List<Database.SaveResult> result = EventBus.publish(eventsToPublish);
            for (Database.SaveResult res : result) {
                if (!res.isSuccess()) {
                    allSuccess = false;
                }
            }

            if (allSuccess) {
                for (Orchestration_CallOutResponse resp : respList) {
                    ApplicationLog__c lg = new ApplicationLog__c();
                    lg.Reference_Info__c = resp.loggerName;
                    lg.Debug_Level__c = resp.debugLevel;
                    lg.Request_Message__c = resp.reqBody;
                    lg.Timer__c = resp.currentStamp;
                    lg.Status_Code__c = resp.statusCode;
                    lg.Http_Code__c = resp.httpCode;
                    sObjectsToInsert.add(lg);
                }
                //Added by Gautam Kumar as part of DIGI-11210
                if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs_OrderSubmit','orderSubmitHV') && !eventsToPublish.isEmpty())
                insertHVOrderLogs(eventsToPublish.get(0),'SUCCESS');
            }
            //Added by Gautam kumar as part of DIGI-11210
            else{
                if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs_OrderSubmit','orderSubmitHV') && !eventsToPublish.isEmpty())
                insertHVOrderLogs(eventsToPublish.get(0),'FAIL');
            }
        }

        if (sObjectsToInsert.size() > 0) {
            insertObjects();
        }
    }

    /**
     * @author Gaurang Maheshwari
     * @date 08/06/2020
     * @description populate result with custom message
     */
    public virtual List<CSPOFA__Orchestration_Step__c> populateStepResults(String msg, String status, List<CSPOFA__Orchestration_Step__c> stepList) {
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            stepResults.put(step.Id, new stepResult(msg, status));
        }
        return processStepResults(stepList, stepResults);
    }

    /**
     * @author Gaurang Maheshwari/Martand Atrey
     * @date 10/06/2020
     * @description populate result
     */
    public List<CSPOFA__Orchestration_Step__c> processStepResults(List<CSPOFA__Orchestration_Step__c> stepList, Map<Id, stepResult> stepResults) {
        //Store attachment for insertion
        List<Attachment> attchList = new List<Attachment>();
        //Store attachment for updation
        List<Attachment> updateAttchList = new List<Attachment>();
        //List of application logs
        List<ApplicationLog__c> logList = new List<ApplicationLog__c>();
        //This will store Logs for insertion
        List<ApplicationLog__c> logResponseList = new List<ApplicationLog__c>();
        //correlation Id --> Response Body
        Map<String, String> logResponse = new Map<String, String>();

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            stepResult sr = stepResults.get(step.Id);
            if (sr != null) {
                step.cspofa__completed_date__c = Date.today();
                //Null check for status
                if (sr.status != null) {
                    step.cspofa__status__c = sr.status;
                }
                step.cspofa__message__c = sr.message;
                if (sr.stackTrace != null) {
                    step.StackTrace__c = sr.stackTrace;
                }

                //Created new field for storing the processed data
                if (sr.processedRecords != null) {
                    //Check if attachment is Required
                    String serializedIds = JSON.serialize(sr.processedRecords, true);
                    //Added for test class to avoid Apex heap size
                    Integer textFieldLimit = System.Test.isRunningtest() ? 50 : OrchestratorConstants.SystemConstant.TextAreaSize;
                    if (serializedIds.length() > textFieldLimit) {
                        Attachment att = new Attachment();
                        att.Body = Blob.valueOf(serializedIds);
                        att.Name = OrchestratorConstants.DataOrchestrationNames.processedIds;
                        att.parentId = step.Id;
                        if (stepProcessedAttachData.containsKey(step.Id)) {
                            att.Id = stepProcessedAttachData.get(step.Id).Id;
                            updateAttchList.add(att);
                        } else {
                            attchList.add(att);
                        }
                        //Updating the message to look for attachment
                        serializedIds = OrchestratorConstants.SystemConstant.AttachmentMsg;
                    }

                    step.JSON__c = serializedIds;
                }

                //Check for callout wrapper
                if (sr.callOutResponse != null) {
                    for (Orchestration_CallOutResponse resp : sr.callOutResponse) {
                        ApplicationLog__c lg = new ApplicationLog__c();
                        lg.Reference_Info__c = resp.loggerName;
                        lg.Debug_Level__c = resp.debugLevel;
                        lg.Request_Message__c = resp.reqBody;
                        //Added for test class to avoid Apex heap size
                        Integer textFieldLimit = System.Test.isRunningtest() ? 10 : OrchestratorConstants.SystemConstant.TextAreaSize;
                        if (String.isNotBlank(resp.responseBody) && resp.responseBody.length() > textFieldLimit) {
                            lg.Message__c = OrchestratorConstants.SystemConstant.AttachmentMsg;
                            //Will be used for attachment insertion
                            logResponseList.add(lg);
                            logResponse.put(resp.correlationId, resp.responseBody);
                        } else {
                            lg.Message__c = resp.responseBody;
                        }
                        lg.Error_Category__c = resp.errorCategory;
                        lg.correlationId__c = resp.correlationId;
                        lg.Error_Code__c = resp.errorCode;
                        lg.Timer__c = resp.currentStamp;
                        lg.User__c = resp.usrId;
                        lg.Status_Code__c = resp.statusCode;
                        lg.Http_Code__c = resp.httpCode;
                        lg.API_Request_Time__c = resp.requestTime;
                        lg.Request_Method__c = resp.requestMethod;
                        lg.Step__c = step.Id;
                        lg.Related_Record_Id__c = resp.recordId;
                        lg.Error_Type__c = resp.errorType;
                        logList.add(lg);
                    }
                }
            }
        }

        if (logList.size() > 0) {
            Database.insert(logList, false);

            //Inserting the attachment after log insertion
            for (ApplicationLog__c lg : logResponseList) {
                //Negative case check, log insertion failed
                if (lg.Id != null) {
                    Attachment att = new Attachment();
                    att.Body = Blob.valueOf(logResponse.get(lg.correlationId__c));
                    att.Name = OrchestratorConstants.DataOrchestrationNames.callOutResponse;
                    att.parentId = lg.Id;
                    attchList.add(att);
                }
            }
        }

        //Insert the attchment
        if (attchList.size() > 0) {
            //If insertion fails, the reporting of processed Ids fails
            Database.insert(attchList, false);
        }

        //Update the attchment if exist
        if (updateAttchList.size() > 0) {
            //If insertion fails, the reporting of processed Ids fails
            Database.update(updateAttchList, false);
        }
        return stepList;
    }

    /**
     * @author Gaurang Maheshwari/Martand Atrey
     * @date 10/06/2020
     * @description return the wrapper of processed Ids
     * @NOTE: IF this method is used then make sure to populate the Attachment maps by calling the getAttachmentList method.
     */
    public Orchestration_ProcessedRecords getProcessedRecords(CSPOFA__Orchestration_Step__c step) {
        //Store deserialized Json
        Orchestration_ProcessedRecords processedRecords;

        //Getting the processed id
        String jsonData;
        if (!stepProcessedAttachData.isEmpty() && stepProcessedAttachData.containsKey(step.Id)) {
            jsonData = stepProcessedAttachData.get(step.Id).body.toString();
        } else if (step.JSON__c != null) {
            jsonData = step.JSON__c;
        }
 
        if (jsonData != null) {
            //Store deserialized Json
            processedRecords = (Orchestration_ProcessedRecords) JSON.deserialize(jsonData, Orchestration_ProcessedRecords.class);
        }

        return processedRecords;
    }

    public String getcalloutResponse(ApplicationLog__c appLog) {
        //Store serialized Json
        String callouResponseBody;
        if (!stepCalloutAttachData.isEmpty() && stepCalloutAttachData.containsKey(appLog.Id)) {
            callouResponseBody = stepCalloutAttachData.get(appLog.Id).body.toString();
        } else if (appLog.message__c != null) {
            callouResponseBody = appLog.message__c;
        }
        return callouResponseBody;
    }

    /**
     * @author Ashish Agarwal
     * @date 30/12/2019
     * @description wrapper object to store step status
     */
    public class stepResult {
        public String message; 
        public String status;
        //Added new id to store processed record id
        public Orchestration_ProcessedRecords processedRecords;
        //Callout Response
        public List<Orchestration_CallOutResponse> callOutResponse;
        //Catch Stack Trace in case of exception
        public String stackTrace;

        public stepResult(String msg, String sts) {
            if (msg.length() > 255) {
                msg = msg.substring(0, 254);
            }
            this.message = msg;

            if (sts != null) {
                this.status = sts;
            }
        }

        public stepResult(String msg, String sts, Orchestration_ProcessedRecords processedRecords) {
            if (msg.length() > 255) {
                msg = msg.substring(0, 254);
            }
            this.message = msg;

            if (sts != null) {
                this.status = sts;
            }

            //Store all the processed Ids
            if (processedRecords != null) {
                this.processedRecords = processedRecords;
            }
        }

        public stepResult(String msg, String sts, List<Orchestration_CallOutResponse> callOutResponse) {
            if (msg.length() > 255) {
                msg = msg.substring(0, 254);
            }
            this.message = msg;

            if (sts != null) {
                this.status = sts;
            }

            //Store all callout response
            if (!callOutResponse.isEmpty()) {
                this.callOutResponse = callOutResponse;
            }
        }

        public stepResult(String msg, String sts, String stackTrace) {
            if (msg.length() > 255) {
                msg = msg.substring(0, 254);
            }
            this.message = msg;

            if (sts != null) {
                this.status = sts;
            }

            if (stackTrace.length() > 32768) {
                stackTrace = stackTrace.substring(0, 32768 - 1);
            }
            this.stackTrace = stackTrace;
        }
    }

    /**
     * @author Gaurang Maheshwari
     * @date 19/05/2020
     * @description fetch account Ids related to the steps
     */
    public virtual void getRelatedAccountIds(List<CSPOFA__Orchestration_Step__c> stepList) {
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.cspofa__account__c != null) {
                accountIds.add(step.CSPOFA__Orchestration_Process__r.cspofa__account__c);
            }
        }
    }

    /**
     * @author Gaurang Maheshwari
     * @date 19/05/2020
     * @description fetch order Ids related to the steps
     */
    public virtual void getRelatedOrderIds(List<CSPOFA__Orchestration_Step__c> stepList) {
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                OrderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
            }
        }
    }

    /**
     * @author Gaurang Maheshwari
     * @date 19/05/2020
     * @description fetch subscription Ids related to the steps
     */
    public virtual void getRelatedSubscriptionIds(List<CSPOFA__Orchestration_Step__c> stepList) {
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            }
        }
    }

    /**
     * @author Gaurang Maheshwari
     * @date 19/05/2020
     * @description fetch service Ids related to the steps
     */
    public virtual void getRelatedServiceIds(List<CSPOFA__Orchestration_Step__c> stepList) {
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c != null) {
                serviceIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c);
            }
        }
    }

    public virtual boolean hasDMLRowsLimitExceeded() {
        boolean dmlRowsExceeded = true;
        if ((eventsToPublish.size() + sObjectsToInsert.size() + sObjectsToUpdate.size() + sObjectsToDelete.size() + sObjectsToUndelete.size()) <= (Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c) - Limits.getDMLRows() - 1)) {
            return false;
        }
        return dmlRowsExceeded;
    }

    public virtual Integration_Handler__mdt getIntegrationHandlerSettings(String hName) {
        Integration_Handler__mdt handleSettingRecord = null;
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Integration_Handler__mdt')) + '\n ' + ' FROM Integration_Handler__mdt \n ' + ' WHERE DeveloperName = \'' + String.escapeSingleQuotes(hName) + '\' LIMIT 1 ';

        List<Integration_Handler__mdt> handleSettingRecordList = Database.query(queryStr);

        if (handleSettingRecordList != null && !handleSettingRecordList.isEmpty() && handleSettingRecordList.get(0) != null) {
            handleSettingRecord = handleSettingRecordList.get(0);
        }
        return handleSettingRecord;
    }
    
    /*  
    * Method Name : insertHVOrderLogs
    * Author : Gautam Kumar
    * Jira : DIGI-11210
   */
    
    private static void insertHVOrderLogs(sObject higVolOrderEvent, String status){
        system.debug('G*G insertHVOrderLogs outer called');
        if(higVolOrderEvent != null && status != null && String.ValueOf(higVolOrderEvent.getSobjectType()) == 'HighVolumeReadyToSubmitOrder__e'){
            
            system.debug('G*G has highVolOrderEvent');
            HighVolumeReadyToSubmitOrder__e highVolOrderObj = (HighVolumeReadyToSubmitOrder__e)higVolOrderEvent;
            
            if(highVolOrderObj.OrderID__c != null ){
                
                system.debug('G*G has order Id '+ highVolOrderObj.OrderID__c);
                Set<String> orderIdSet = new Set<String>();
                orderIdSet.add(highVolOrderObj.OrderID__c);
                List<csord__Order__c> orderList = Model_Order.getOrdersList(orderIdSet);
                
                if(!orderList.isEmpty()){
                    system.debug('G*G insertHVOrderLogs called');
                    for(csord__Order__c order : orderList){
                        if(order.csordtelcoa__Opportunity__c != null && order.Product_Basket__c != null){
                            
                            system.debug('G*G has correaltion Id ');
                            Map<String,Object> loggerdetailsMap=new Map<String,Object>();
                           //Trim Product Basket from 18 digit to 15 digit
                            String ProductBasketId = order.Product_Basket__c!= null && String.ValueOf(order.Product_Basket__c).length()>= 15?
                            String.ValueOf(order.Product_Basket__c).subString(0,15) : '';
                            string correlationId = order.csordtelcoa__Opportunity__c+'-'+ProductBasketId;
                            
                     //     string correlationId = order.csordtelcoa__Opportunity__c+'-'+order.Product_Basket__c;
                    
                            String eventType = status == 'SUCCESS' ? 'Order submitted to high volume ms' : 'Order rejected to high volume ms';
                            String orderStatusType = status == 'SUCCESS' ? 'In Progress' : 'In Error';
                            
                            loggerdetailsMap.put('event', eventType);
                            loggerdetailsMap.put('OrderType', order.csordtelcoa__Opportunity__r.Type);
                            loggerdetailsMap.put('OrderStatus', orderStatusType);
                            loggerdetailsMap.put('OrderId', order.Id);
                            TransactionLogger.insertTransactionLogs(correlationId, loggerdetailsMap, 'Orchestration_AbstractStepHandler');
                        }
                    }
                }
            }
        }
    
    }
}