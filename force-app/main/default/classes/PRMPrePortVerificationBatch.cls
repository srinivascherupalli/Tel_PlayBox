/**
* Description : Batch class to process stamping of secondary numbers                   
* Jira        : P2OB - 11651
* Author      : Team Hawaii : Vivian Charlie , Ritika Jaiswal
* Date        : 25-Jan-2021 
* Modifications : 
1. 03-03-2021 : Ritika Jaiswal : P2OB-12674 - Update status and log response for non-json response from PPV-API 
2. 05-10-2021 : Irfan Inamdar : DIGI-779,14124 : added ownerIds for Chatter notifications
**/
global without sharing class PRMPrePortVerificationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public string token;
    public string opptyID;
    public string basketID;
    public string cafID;
    public String event = 'PPVCreateVerificationRequest';
    
    /**    
* Description : Parameterized contructor 
* Jira : P2OB - 11651
*/
    global PRMPrePortVerificationBatch(String reference_recordID){
        opptyID = reference_recordID;
    }

    global PRMPrePortVerificationBatch(String reference_recordID, String reference_basketid, String reference_cafid){
        opptyID = reference_recordID;
        basketID = reference_basketid;
        cafID = reference_cafid;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //P2OB-11651 : Obtain authentication token 
        invokeLoginService();
        //P2OB-11651 : Return list of staging-records which created for opportunity and are unprocessed  
        return Database.getQueryLocator([Select Id
                                         , Is_Processed_in_CSV__c
                                         , Opportunity_Id__c
                                         , Parent_Number__c
                                         , Response_Details__c
                                         , Requested_by__c
                                         , Secondary_number_PPV_Status__c
                                         , Secondary_numbers__c
                                         From PRM_PPVCheck_Staging__c
                                         Where Secondary_numbers__c != null and Secondary_number_PPV_Status__c = null and Is_Processed_in_CSV__c = false and Opportunity_Id__c =:opptyID ] );
        
    }
    
    global void execute(Database.BatchableContext BC, List<PRM_PPVCheck_Staging__c> scope){
        //P2OB-11651 : for every staging-record callout to PPV-API for stamping secondary number with primary number
        for(PRM_PPVCheck_Staging__c objStage : scope){
            //P2OB-11651 : Return list of staging-records updated with response of stamping-request
            objStage = invokeSecondaryNumberStamping(objStage);
        }
        //P2OB-11651 : Upsert staging-record
        upsert scope;
    }
    
    global void finish(Database.BatchableContext BC){
        //P2OB-11651 : Output the staging records onto a CSV file
        generateCSV();      
    }
    
    /**    
* Description : Method to obtain authentication token 
* Jira : P2OB - 11651
*/
    public void invokeLoginService(){
        token = AuthenticationManager.getOauthToken(event);
        System.debug('***Telstra:PRMPrePortVerificationBatch:invokeLoginService:'+token);
    }
    
    /**    
* Description : Method to obtain callout PPV-API for stamping secondary number and process result 
* Jira : P2OB - 11651
*/
    public PRM_PPVCheck_Staging__c invokeSecondaryNumberStamping(PRM_PPVCheck_Staging__c objStage){
        String httpMethodType = 'POST';
        HttpResponse res = new HttpResponse();
        try{
            String urlParams = '{"data": {"mobileNumber":"'+objStage.Secondary_numbers__c+'", "parentNumber": "'+objStage.Parent_Number__c+'"}}';        
            Map<String,String> headerMap = PRM_PPV_CreateVerificationRequest.create_PPV_request_Header(token);
            if(!Test.isRunningTest())
                res = IntegrationRecordHandlerUtil.calloutSync(urlParams, httpMethodType, headerMap, event);
            else{
                res.setBody('{"status": 200,"responseCode": "PPV-SUCCESS","time": "2018-11-12T12:33:49.404Z","correlationId": "f1bc3577-8889-48b5-9197-d17a182","data": {"mobileNumber": "0456876999"}}');
                res.setStatusCode(200);
            }
            System.debug('***Telstra:PRMPrePortVerificationBatch:invokeSecondaryNumberStamping:Response:'+res);
            
            ////P2OB-11651 : Parse the response 
            Map<String,Object> resp = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            if (res.getStatusCode() == 200){
                objStage.Secondary_number_PPV_Status__c = 'Success';            
            }else if(res.getStatusCode() == 401 && res.getStatus() == 'Unauthorized'){
                //P2OB-11651 : Regain the authentication token if it expires
                map<String,Object> p = (map<String,Object>) resp.get('fault');
                if(p.get('faultstring') == 'Access Token expired'){
                    invokeLoginService();
                    invokeSecondaryNumberStamping(objStage);
                }
            }else{
                //P2OB-11651 : Record the failure of secondary number stamping on staging-record 
                objStage.Secondary_number_PPV_Status__c = 'Fail';
                objStage.Response_Details__c = res.getBody();
                
            }
        }
        catch(Exception e){
            //P2OB-12674 : Update staging record 
            objStage.Secondary_number_PPV_Status__c = 'Fail';
            if(res != null )
            	objStage.Response_Details__c = '{"StatusCode":"'+res.getStatusCode()+'"}';
            System.debug('***Telstra:PRMPrePortVerificationBatch:invokeSecondaryNumberStamping:exception:'+e.getMessage());
        }
        
        return objStage;
    }
    
    /**    
* Description : Method to output unprocessed staging-records onto CSV 
* Jira : P2OB - 11651
*/
    private void generateCSV(){
        Set<String> requesters = new Set<String>();
        try{
            //P2OB-11651 : Obtain network-id for prm-community
            String prm_community_name = System.Label.PRM_Partner_Community_Name;
            Network prm_network = [Select id from network where name=:prm_community_name ];
            System.debug('***Loggedinuser'+UserInfo.getUserId());
            String CurrentUsID = UserInfo.getUserId();
            User usr = [Select Id, IsPortalEnabled from User where Id=:CurrentUsID];
            System.debug('***usr***'+usr);
            //P2OB-11651 : Obtain staging records which will be output on CSV file
            String csvStr='Parent Number,Secondary Number,Secondary Number PPV_Status,PPV Check Start Time,Requested by,Method of verification,Errors';
            List<PRM_PPVCheck_Staging__c> listToUpdate = [Select Id
                                                          , Is_Processed_in_CSV__c
                                                          , Opportunity_Id__c
                                                          , Parent_Number__c
                                                          , Response_Details__c
                                                          , Requested_by__c
                                                          , Secondary_number_PPV_Status__c
                                                          , Secondary_numbers__c
                                                          , Method_of_Verification__c
                                                          , createddate,CreatedById
                                                          , Opportunity_Id__r.Account.OwnerId
                                                          , Opportunity_Id__r.OwnerId
                                                          From PRM_PPVCheck_Staging__c
                                                          Where Secondary_numbers__c != null and Secondary_number_PPV_Status__c != null and Is_Processed_in_CSV__c = false and Opportunity_Id__c =:opptyID];//DIGI-779,14124
            
            //P2OB-11651 : Concatenate Staging-record fields
            for(PRM_PPVCheck_Staging__c staging:listToUpdate){
                csvStr += '\n' + staging.Parent_Number__c + ',' + staging.Secondary_numbers__c + ',' + staging.Secondary_number_PPV_Status__c + ',' + staging.createddate.format('MM/dd/yyyy HH:mm:ss', 'Australia/Sydney') + ',' + staging.Requested_by__c + ','+ staging.Method_of_Verification__c ;
                if(!String.isBlank(staging.Response_Details__c)){
                    //csvStr += ',' + staging.Response_Details__c;
                    Map<String,Object> resp = (Map<String,Object>) JSON.deserializeUntyped(staging.Response_Details__c);
                    String responseCode = String.valueOf(resp.get('responseCode'));
                    csvStr += ',' + responseCode ;  
                    if(resp.get('errors') != null){   
                        List<Object> errorDetails = (List<Object>) resp.get('errors');
                        Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(errorDetails[0]));
                        String msg = String.valueOf(errormap.get('message'));
                        csvStr += '-' +msg.replaceAll(',', '-');

                    }
                }
                else
                    csvStr += + ',' + '';
                //P2OB-11651 : Update staging record as marked
                staging.Is_Processed_in_CSV__c = true;
                System.debug('--'+csvStr);
                requesters.add(staging.CreatedById);
                //DIGI-779,14124
                if(basketID != Null && cafID != null){
                    requesters.add(staging.Opportunity_Id__r.Account.OwnerId);
                    requesters.add(staging.Opportunity_Id__r.OwnerId);
            }
                System.debug('requesters****'+requesters);
            }
            
            String timeStamp = DateTime.now().format('dd-MM-yyyy_HH-mm', 'Australia/Sydney');
            
            //P2OB-11651 : Create SalesForceFile to be uploaded into community on the opportunity-record 
            ContentVersion cv = new ContentVersion();
            cv.Title = timeStamp+'_'+'PPV_check.csv';
            cv.PathOnClient = timeStamp+'_'+'PPV_check.csv';
            cv.VersionData = Blob.valueOf(csvStr);
            cv.IsMajorVersion = true;
            cv.FirstPublishLocationId =  opptyID;
            //DIGI-779,14124
            if(usr.IsPortalEnabled){
                cv.NetworkId = prm_network.id;
            }
            
            Insert cv;
            
            //P2OB-11651 : Upsert the staging record as processed 
            upsert listToUpdate;

            
            
            //DIGI-14124
            //Calling MobilePortinController.processPPVData() to process PPVStaging records after batch class run
            if(basketID != Null && cafID != null){

                List<PRM_PPVCheck_Staging__c> stagingRecList = [Select Id, Is_Processed_in_CSV__c, Opportunity_Id__c, Parent_Number__c, 
                                                        Response_Details__c, Requested_by__c, Secondary_number_PPV_Status__c, 
                                                        Secondary_numbers__c From PRM_PPVCheck_Staging__c where Secondary_number_PPV_Status__c != null
                                                        AND Is_Processed_in_CSV__c = true AND  Opportunity_Id__c =:opptyID];

                                                        System.debug('***stagingRecListBatch***'+stagingRecList);

            List<Service_Qualification__c> sqList = [SELECT id,Service_number__c,Added_to_CA_form__c,PPV_status__c
            FROM Service_Qualification__c Where Portability_Status__c='Y' AND basket_id__c=:basketID];

            System.debug('***sqList***'+sqList);


                MobilePortinController.processPPVData(opptyID,basketID,cafID,stagingRecList,sqList);
            }

            //P2OB-11651 :Call flow to post chatter
            postChattertorequester(requesters);
        }
        catch(Exception e){
            System.debug('***Telstra:PRMPrePortVerificationBatch:generateCSV:exception:'+e.getMessage());
        }
    }
    @testVisible
    private void postChattertorequester(Set<String> requesters){
        //P2OB-11651 : Read custom-label
        Map<String,Object> msg_settings = (Map<String,Object>) JSON.deserializeUntyped(System.Label.PRM_PPV_chatter_message);
        String notificationName = string.valueOf(msg_settings.get('CustomNotification'));
        CustomNotificationType customNotification = [SELECT Id, CustomNotifTypeName, DeveloperName from CustomNotificationType WHERE DeveloperName =:notificationName];
        String postmessage = string.valueOf(msg_settings.get('PPV_Chatter_Msg'));     
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        //P2OB-11651 : Custom notification type Id
        obj.setNotificationTypeId(customNotification.id);
        //P2OB-11651 : when we click on the notification it will redirect to the specified targetId
        obj.setTargetId(opptyID);
        //P2OB-11651 : Notification Title
        obj.setTitle('PPV Check Completed');
        //P2OB-11651 : Notification Body
        obj.setBody(postmessage);
        //P2OB-11651 : send used to send the notification, pass the set of user ids , Group or Queue member
        obj.send(requesters);
        for(String req : requesters){ 
            //P2OB-11651 : Call flow 'Chatter Post to Record Feed' 
            Map<String, Object> params = new Map<String, Object>();
            params.put('userId', req);
            params.put('targetSobjectId', opptyID);
            params.put('chatter_message',postmessage);
            Flow.Interview.Chatter_Post_to_Record_Feed chatterFlow = new Flow.Interview.Chatter_Post_to_Record_Feed(params);
            if(!Test.isRunningTest()){
                chatterFlow.start();
            }
            
        }
        
    }
    
}