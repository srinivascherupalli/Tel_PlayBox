/**

 *  Description: Service class for ManagePIMSController Parseresponse Logic
 *  Author:RaviTeja
 *  Date:1-1-2020  
 *  Updates : 
 * 1. 07-09-2020 : Team Hawaii : P2OB-7962 : Populating partner_role on contact, along with onboarding_status(existing) while onboarding a user
 * 2. 15-09-2020 : Team Hawaii : P2OB-7962 : SCA P1: Resolved ApexCSRF : Calling ManagePIMSControllerService's method to handle updates after PIMS-response. Removed the DMLs from constructor of ManagePIMSControllerService.
 * 3. 21-09-2020 : Team Hawaii : P2OB-7962 : Removing profile-assignment as it will be handled by Flow 'PRM_Manage_User_Onboarding'
 * 4. 08-10-2020 : Team Hawaii : P2OB-9678 : Commented logic for button 'deactivate User'
***/


public without sharing class ManagePIMSControllerService {
    
    public static Object response;     
    public static WrapperMSPIMSParams.WrapperPageResponse pageResponse = new WrapperMSPIMSParams.WrapperPageResponse();
    private static List<PIMS_Status_Message_Mapping__mdt> statusMapping= new List<PIMS_Status_Message_Mapping__mdt>();
    private static WrapperMSPIMSParams.MSResponse msResponse;
    private static WrapperMSPIMSParams.WrapperPageParameters params = new WrapperMSPIMSParams.WrapperPageParameters(); 
    private static List<sObject> listSobjectUpdate = new list<sObject>();
    private static map<string, string> FieldMap = new map<string, string>();
    private static ContinuationController.WrapperState wrapperStatenew= new ContinuationController.WrapperState();
    private static Logger2 logger;
    private static HttpResponse httpRes;
    private static Boolean updateUser;
    private static Long requestTime; //EDGE-127154 - CLF Changes

    public Object getPageResponse(){
        return pageResponse;
    }
    //P2OB-7962 : ApexCSRF : Moving the logic from constructor to method
    public void handleResponse(HttpResponse httpResponse,
                                           ContinuationController.WrapperState wrapperState){
                                  params = (WrapperMSPIMSParams.WrapperPageParameters) wrapperState.pageParams;
                                               wrapperStatenew=wrapperState;
                                               system.debug('httpReparsePIMSResponsesponse****' + httpResponse);
                                               logger = Logger2.getLogger('parsePIMSResponse');
                                               system.debug('httpReparsePIMSResponsesponse****' + httpResponse);
                                                //EDGE-127154 - CLF Changes : Start 
                                                   DateTime startTime=wrapperState.requestTime;
                                                   DateTime endTime=DateTime.now();
                                                   requestTime = logger.getRequestTimeDifference(startTime, endTime);
                                                 //EDGE-127154 - CLF Changes : End
                                               WrapperMSPIMSParams.MSResponseFindUserdetails msfinduserResponse;
                                               //httpResponse=httpResponse;
                                               httpRes=httpResponse;
                                               system.debug('httpRes'+httpRes);
                                               String mappingClause;                                              
                                               try {
                                                   if (null == httpResponse.getBody() || '' == httpResponse.getBody()) {
                                                       response = getExceptionErrorResponse('Apex_Error_Exception_PIMS', '');
                                                    }
                                                   system.debug('params.pimsCallType'+params.pimsCallType);
                                                   system.debug('httpResponse.getBody()****' + httpResponse.getBody());
                                                   
                                                   //String Jsonstr = '{\n' +' "title" :"Success",\n' +' "status" : "200",\n' +' "pimsStatus" : "0",\n' +' "description" : "Success",\n' +' "userPid" : "P504342"\n' +'}';
                                                   //String Jsonstr='{"data":{"userPid": "P500147","userFirstName": "first","userLastName": "name","userEmail": "P500147@retail1.telstra.com","orgId": 43,"userType": "OTHER","isDeactivate": "FALSE","userMobileNumber": "","isPDUA": "FALSE","partnerLevelId": "Premise", "retailLiveId": "PDUA","positionTypeId": "TLS Shop Sales Rep","partnerNameId": "TLS WAURN PONDS_","partnerCodeId": "LA8H","timezone": "", "userOrgCategory": "TCW"},"description": "User found: P504303.","pimsStatus": 1}';
                                                   //msResponse = WrapperMSPIMSParams.parsePIMSresponse(Jsonstr);
                                                   
                                                   msResponse = WrapperMSPIMSParams.parsePIMSresponse(httpResponse.getBody());
                                               
                                                   if(!params.pimsCallType.equalsIgnoreCase('finduser') ){
                                                        manageOperations();  
                                                    }
                                                   else if( params.pimsCallType.equalsIgnoreCase('finduser')){
                                                        managefinduserOperation(); 
                                                    }            
                                                   
                                                  // if (listSobjectUpdate.size() > 0)
                                                       update listSobjectUpdate;       
                                                   
                                                   
                                                   //pageResponse.wrapperValidOperations =  ManagePIMSControllerG.validate(params.pageObjectID);
                                                   if (statusMapping.size() > 0) {
                                                        managePageResponse();
                                                   }
                                               } catch (Exception e) {
                                                   logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                                                   pageResponse =  getExceptionErrorResponse('Apex_Error_Exception', e.getStackTraceString() + '----' + e.getMessage());
                                               } finally {
                                                   logger.exitLogger();
                                                   pageResponse.wrapperValidOperations =  ManagePIMSController.validate(params.pageObjectID);
                                               }
                                               
                                               System.debug('pageResponse************' + pageResponse);                                
        
        
    }
    
        @future
    public static void inactivateUsers(Set<String> setContactId) {
        //Inactivate user record
        List<User> userRecords = new list<user>();
        for (user eachUser : [SELECT id, name , IsPortalEnabled
                              FROM User
                              where isportalenabled = true
                              and contactId in :setContactId]) {
                                  eachUser.isactive = false;
                                  userRecords.add(eachUser);
                              }
        update userRecords;
    }
    /* 
    Description:Utility method for Manage User Opertaions
    */
    private static void manageUserOperations()
         {  
                String profileName = '';
                Boolean isActive = true;                
                Contact contact = [SELECT id, Account.Account_Status__c,Account.PartnerPrincipalContact__c from contact where id = :params.pageObjectID];
                
                switch on params.pimsCallType.toLowercase() {
                        when 'createuser','updatetcw' {     // when block 1
                                profileName = PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA;
                                 List<user> u = [select id
                                                 from User
                                                 where FederationIdentifier = :msResponse.userPid and FederationIdentifier != null ]; //userIdcreated updated with userPid
                                if (u.size() > 0) {
                                     system.debug('User already exists');
                                     updateUser = false;
                                     pageResponse.isSuccess = false;
                                     pageResponse.message = Label.PRM_UserExists_Message;
                                 } 
                                 else {
                                     contact.Onboarding_Status__c = contact.Account.Account_Status__c == PRMConstants.PRM_Account_Status_Active ? PRMConstants.PRM_Account_Status_Active : PRMConstants.PRM_Account_Status_InActive;
                                     contact.PIMS_User_Status__c = 'User Created';
                                     //P2OB-7962 : Adding partner_role at the time of onboarding
                                     if(contact.account.PartnerPrincipalContact__c!= null && contact.account.PartnerPrincipalContact__c == contact.id)
                                         contact.Partner_Role__c = 'Partner Sales User;Principal Partner Contact';
                                     else
                                         contact.Partner_Role__c = 'Partner Sales User';
                                     //P2OB-7962 : Role assignment end 
                                     if (msResponse.userPid != '')
                                         contact.P_Number__c = msResponse.userPid;
                                     
                                       if(params.pimsCallType.equalsIgnoreCase('createUser'))
                                               contact.PIMS_User_Type__c=PRMConstants.PRM_USER_TYPE_TEG;
                                }
                        }   
                        when 'elevatetopdua' {      
                            //profileName = PRMConstants.PRM_PROFILE_PRM_Admin_Australia; //P2OB-7962 : Removing profile-assignment as it will be handled by Flow 'PRM_Manage_User_Onboarding'
                            contact.Community_User_Type__c = 'PRM Community Admin'; //EDGE-18967
                            contact.PIMS_User_Status__c = 'Elevated to Admin';
                        }
                        when 'removepdua' {
                            //profileName = PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA; //P2OB-7962 : Removing profile-assignment as it will be handled by Flow 'PRM_Manage_User_Onboarding'
                            contact.Community_User_Type__c = 'PRM Community User'; //EDGE-53188 added by saran
                            contact.PIMS_User_Status__c = 'Removed Admin access';
                        }
                        //P2OB-9678 - Removing logic for 'Deactivate User'
                        /*when 'deactivateuser' {       
                             isActive = false;
                            contact.Onboarding_Status__c = 'Inactive';
                            contact.PIMS_User_Status__c = 'Deactivated';
                        }*/
                        
                    }
              
                     listSobjectUpdate.add(contact); //EDGE-18967
                     System.debug('***manageUserOperations:profileName'+profileName);
                     if (updateUser) {
                         PhoenixGlobalUtil.upsertUserRecord(params.pageObjectID,
                                                            msResponse.userPid, //userIdcreated replaced with userPid
                                                            profileName,
                                                                                          isActive);
                                                               }
        }

     /*
     Description: Utility method for Fineuser  Opertaion
      */
    private static void managefinduserOperation() 
    {
                                                                        
                                                                        
                                if( msResponse.pimsStatus==0)  //TCW
                                                       {                    
                                                       
                                                           if (params.pimsAPIType.equalsIgnoreCase('MANAGEUSER')) {
                                                               Contact contact = [SELECT id, Account.Account_Status__c from contact where id = :params.pageObjectID];
                                                               contact.PIMS_User_Type__c=PRMConstants.PRM_USER_TYPE_TCW;
                                                               contact.P_Number__c=msResponse.data.userPid;
                                                               contact.TCW_OrgId__c=String.valueOf(msResponse.data.orgId);
                                                               listSobjectUpdate.add(contact);
                                                           }
                                                           
                                                           pageResponse.pimsuserdetails=msResponse.data;
                                                            
                                                       }
                                                       else if (msResponse.pimsStatus==-1) //TEG
                                                       {
                                                          //EDGE-70130 Bhargava 03/27 As part of this User Story Creating user's will be disabled from Salesforce
                                                          
                                                           pageResponse.isSuccess = false;
                                                           pageResponse.message = Label.PRM_PIMSUserCreation_Message;
                                                           
                                                          //Code commeneted for PIMS call out                                                           
                                                          //system.debug('params.pimsCallType'+params.pimsCallType);
                                                          //system.debug('msResponse.pimsStatus'+msResponse.pimsStatus);
                                                          //WrapperMSPIMSParams.MSRequestUser msRequest = (WrapperMSPIMSParams.MSRequestUser) //PIMSService.getPIMSUserRequestAttributes(params.pageObjectID);
                                                          // Contact contact = [SELECT id, Account.Account_Status__c from contact where id = :params.pageObjectID];
                                                          //contact.PIMS_User_Type__c=PRMConstants.PRM_USER_TYPE_TEG;
                                                          // listSobjectUpdate.add(contact);
                                                          //params.pimsCallType = 'createUser';                                                           
                                                          // return PIMSService.postUser(msRequest, params,'PimsMicroserviceManageUser');

                                                       }
                                                       else if( msResponse.pimsStatus<= -2 &&  msResponse.pimsStatus>= -5 )
                                                       {
                                                       
                                                           FieldMap.put('PIMS_Status_code__c', String.valueOf(msResponse.pimsStatus));
                                                           FieldMap.put('Pims_Interface__c', params.pimsCallType);
                                                           statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMap);
                                                           pageResponse.isSuccess = false;
                                                           //logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(), '', '', '', '', false, false, httpRes.getStatusCode(), '', '', ''); //CLF Changes
                                                           logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(),'', '', '', '',String.valueOf(httpRes.getStatusCode()),wrapperStatenew.requestCid,'', '','','Update',requestTime,'POST',false, false);//CLF Changes
                                                           //logger.exitLogger();
                                                       }
                                                        else
                                                       {
                                                           FieldMap.put('DeveloperName', 'Apex_Error_Exception_PIMS');
                                                           statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMap);
                                                           pageResponse.isSuccess = false;
                                                           //logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(), '', '', '', '', false, false, httpRes.getStatusCode(), '', '', '');//CLF Changes
                                                           logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(),'', '', '', '',String.valueOf(httpRes.getStatusCode()),wrapperStatenew.requestCid,'', '','','Update',requestTime,'POST',false, false);//CLF Changes
                                                           //logger.exitLogger();
                                                       }
                                                     
                }

private static void  UpdatePimsStatus(){
                   Account acc;
                           if (params.pimsAPIType.equalsIgnoreCase('MANAGEORG')) {
                               acc = new Account(
                                   Id = params.pageObjectID,
                                   PIMS_Sync_Status__c = 'Error'
                               );
                               listSobjectUpdate.add(acc);
                           }
                   }

private static void  manageOperations(){
    
                updateUser = true;
                switch on msResponse.status {
                   when 200 {
                            String profileName = '';
                            Boolean isActive = true;
          
                       if (params.pimsAPIType.equalsIgnoreCase('MANAGEUSER')) {
                            manageUserOperations();                                                           
                       } else if (params.pimsAPIType.equalsIgnoreCase('MANAGEORG')) {
                            manageOrgOperations();                                                               
                       }
                       
                       if(updateUser)
                       {
                           FieldMap.put('PIMS_Status_code__c', String.valueOf(msResponse.pimsStatus));
                           FieldMap.put('STATUS_CODE__c', String.valueOf(msResponse.status));
                           FieldMap.put('Pims_Interface__c', params.pimsCallType);
                           statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMap);
                           pageResponse.isSuccess = false;
                       }
                       system.debug('@@@@'+httpRes);                  
                       //logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(), '', '', '', '', false, false, httpRes.getStatusCode(), '', '', '');  																//CLF Changes
                       logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(),'', '', '', '',String.valueOf(httpRes.getStatusCode()),wrapperStatenew.requestCid,'', '','','Update',requestTime,'POST',false, false);//CLF Changes
                   }
                   when 400 {
                       UpdatePimsStatus();
                       
                           /*Account acc;
                           if (params.pimsAPIType.equalsIgnoreCase('MANAGEORG')) {
                               acc = new Account(
                                   Id = params.pageObjectID,
                                   PIMS_Sync_Status__c = 'Error'
                               );
                               listSobjectUpdate.add(acc);
                           }*/
                           
                           FieldMap.put('PIMS_Status_code__c', String.valueOf(msResponse.pimsStatus));
                           FieldMap.put('STATUS_CODE__c', String.valueOf(msResponse.status));
                           FieldMap.put('Pims_Interface__c', params.pimsCallType);
                           statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMap);
                           pageResponse.isSuccess = false;
                                             
                        
                           //logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(), '', '', '', '', false, false, httpRes.getStatusCode(), '', '', '');																//CLF Changes
                       	   logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(),'', '', '', '',String.valueOf(httpRes.getStatusCode()),wrapperStatenew.requestCid,'', '','','Update',requestTime,'POST',false, false);//CLF Changes
                           //logger.exitLogger();
                   }
                   when 500 {
                       UpdatePimsStatus();
                       /*Account acc;
                           if (params.pimsAPIType.equalsIgnoreCase('MANAGEORG')) {
                               acc = new Account(
                                   Id = params.pageObjectID,
                                   PIMS_Sync_Status__c = 'Error'
                               );
                               listSobjectUpdate.add(acc);
                           }
                           */
                           
                           // FieldMap.put('DeveloperName','Apex_Error_Exception_PIMS');
                           FieldMap.put('STATUS_CODE__c', String.valueOf(msResponse.status));
                           FieldMap.put('Pims_Interface__c', params.pimsCallType);
                           statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMap);
                           pageResponse.isSuccess = false;
                           //logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(), '', '', '', '', false, false, httpRes.getStatusCode(), '', '', '');                                                                //CLF Changes
                           logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(),'', '', '', '',String.valueOf(httpRes.getStatusCode()),wrapperStatenew.requestCid,'', '','','Update',requestTime,'POST',false, false);//CLF Changes
                           //logger.exitLogger();
                   }
                   when else {                                                                     
                         UpdatePimsStatus();
                       /*Account acc;
                       if (params.pimsAPIType.equalsIgnoreCase('MANAGEORG')) {
                           acc = new Account(
                               Id = params.pageObjectID,
                               PIMS_Sync_Status__c = 'Error'
                           );
                           listSobjectUpdate.add(acc);
                       }*/
                       
                     if (updateUser){
                           FieldMap.put('DeveloperName', 'Apex_Error_Exception_PIMS');
                           statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMap);
                           pageResponse.isSuccess = false;
                       }
                       
                      
                       //logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(), '', '', '', '', false, false, httpRes.getStatusCode(), '', '', '');                                                                //CLF Changes
                       logger.logMessages('Correlationid:' + wrapperStatenew.requestCid + ' Request body' + wrapperStatenew.requestBody, 'Correlationid:' + httpRes.getHeader('Correlationid') + ' Response body' + httpRes.getBody(),'', '', '', '',String.valueOf(httpRes.getStatusCode()),wrapperStatenew.requestCid,'', '','','Update',requestTime,'POST',false, false);//CLF Changes
                       //logger.exitLogger();
                   }
                }
            }
     
     
     /*
     Descripttion: Utility method for appending error message based on pims response and status Mappings
     */
     private static void managePageResponse() {                                          
        
        if (statusMapping.size() > 1 && !String.isEmpty(msResponse.description)) {
                   for (PIMS_Status_Message_Mapping__mdt status : statusMapping) {
                       if (!String.isEmpty(status.PIMS_ERROR__c) && String.valueOf(msResponse.description).containsIgnoreCase(String.valueOf(status.PIMS_ERROR__c))) {
                           pageResponse.status = status.STATUS_CODE__c;
                           pageResponse.message = status.End_User_Message__c;
                           system.debug('@@@msResponse.description' + status);
                       }
                   }
            } else  {
                   pageResponse.status = statusMapping[0].STATUS_CODE__c;
                   pageResponse.message = statusMapping[0].End_User_Message__c;
               }
               
            pageResponse.message=getPageResponseMessage();  
                                        
            if (statusMapping[0].STATUS_CODE__c == '200') {
                 pageResponse.isSuccess = true;                                                                                                            
                               } 
            else {
                                                                                             
                 pageResponse.isSuccess = false;
                  pageResponse.message += '\n' + 'Error code: ' + statusMapping[0].User_Error_Code__c;
            }
         system.debug('pageResponse.message'+pageResponse.message);
        }
        
         
        private static string getPageResponseMessage() { 

             map<string,string> mappings= new Map<string,string>();
            mappings.put('<PID>',msResponse.userPid);
            mappings.put('<ORGID>',msResponse.orgId);
            mappings.put('<DESCRIPTION>',msResponse.description);

            for(string str:mappings.keyset()){
                    if (!String.isEmpty(mappings.get(str)) && statusMapping[0].End_User_Message__c.indexOf(str) > -1) {
                        pageResponse.message = pageResponse.message.replaceAll(str,mappings.get(str));
                    }
            }
        /*
                    if (!String.isEmpty(msResponse.userPid) && statusMapping[0].End_User_Message__c.indexOf('<PID>') > -1) {
                        pageResponse.message = pageResponse.message.replaceAll('<PID>', msResponse.userPid);
                    }
                    if (!String.isEmpty(msResponse.orgId) && statusMapping[0].End_User_Message__c.indexOf('<ORGID>') > -1) {
                        pageResponse.message = pageResponse.message.replaceAll('<ORGID>', msResponse.orgId);
                    }
                    if (!String.isEmpty(msResponse.description) && statusMapping[0].End_User_Message__c.indexOf('<DESCRIPTION>') > -1) {
                        pageResponse.message = pageResponse.message.replaceAll('<DESCRIPTION>', msResponse.description);
                    }
        */  
                    return pageResponse.message;
                    
            }
                
   /*
   Description: Utility method for Manage Org operations
   */
    private static void manageOrgOperations() { 
                Account acc;
                if (params.pimsCallType.equalsIgnoreCase('createOrg')) {
                                                                   acc = new Account(
                                                                       Id = params.pageObjectID,
                                                                       IsPartner = true,
                                                                       Account_Status__c = 'Pending activation',
                                                                       Partner_External_Id__c = msResponse.orgId,
                                                                       PIMS_Sync_Status__c = 'Success'
                                                                   );
                                                                   listSobjectUpdate.add(acc);
                                                               } else if (params.pimsCallType.equalsIgnoreCase('deactivateOrg')) {
                                                                   acc = new Account(
                                                                       Id = params.pageObjectID,
                                                                       IsPartner = false,
                                                                       Account_Status__c = 'Inactive',
                                                                       Approve_Decline_Reason__c = 'Inactived from PIMS',
                                                                       PIMS_Sync_Status__c = 'Success'
                                                                   );
                                                                   
                                                                   listSobjectUpdate.add(acc);
                                                                   set<String> setContactId = new set<String>();
                                                                   List<Contact> AccConSts = [SELECT Id, OwnerId
                                                                                              FROM contact
                                                                                              WHERE AccountId = :params.pageObjectID];
                                                                   for (Contact ConStat : AccConSts) {
                                                                       ConStat.Onboarding_Status__c  = 'Inactive';
                                                                       setContactId.add(conStat.Id);
                                                                   }
                                                                   if (!setContactId.isEmpty()) {
                                                                       //disable all portal users
                                                                       inactivateUsers(setContactId);
                                                                   }
                                                                   listSobjectUpdate.addAll(AccConSts);
                                                                   
                                                               }
            }
    
    public static WrapperMSPIMSParams.WrapperPageResponse getExceptionErrorResponse(String errorRecord, String errorMessage) {
        WrapperMSPIMSParams.WrapperPageResponse pageResponse = new WrapperMSPIMSParams.WrapperPageResponse();
        pageResponse.description = errorMessage;
        // String mappingClause = ' where DeveloperName=\'' + errorRecord + '\'';
        map<string, string> FieldMapnew = new map<string, string>();
        FieldMapnew.put('DeveloperName', 'Apex_Error_Exception_PIMS');
        List<PIMS_Status_Message_Mapping__mdt> statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMapnew);
        pageResponse.message = statusMapping[0].End_User_Message__c + '\n' + 'Error code: ' + statusMapping[0].User_Error_Code__c;
        pageResponse.isSuccess = false;
        pageResponse.status = statusMapping[0].STATUS_CODE__c;
        return pageResponse;
    }
}