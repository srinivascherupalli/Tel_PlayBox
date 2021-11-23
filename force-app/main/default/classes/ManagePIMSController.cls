/**
     Description :  Controller class for ManagePIMS Aura Component. This class holds the logic for onboarding of a partner-user to TPC-Community.
     Updates     :
     1. P2OB-6753 - Hawaii - 05/06/2020 - Commenting the License Limit validation - Business do not want it right now
     2. P2OB-7962 - Hawaii - 25/08/2020 - Updating Onboarding-Process by adding a provision to update partner-roles, access and permissions from Manage-User Component.
     3. P2OB-7962 - Hawaii - 15/09/2020 - Resolved ApexCSRF : Calling ManagePIMSControllerService's method to handle updates after PIMS-response. Removed the DMLs from constructor of ManagePIMSControllerService.
	 4. P2OB-9678 - Hawaii - 08/10/2020 - Commented method and call for 'checkUserDeactivated'	  
**/
 
global without sharing class ManagePIMSController {
    public static Object response;
    public static WrapperPageResponse wrapperPageResponse;
    public static string accountName;
    
    /*
     * P2OB-7962 : Method to query custom-metadata records for allowed partner-roles
    */
    @AuraEnabled 
    public static List<PRM_Manage_User_Onboarding__mdt> getPartnerRolesfromMDT(){
         String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('PRM_Manage_User_Onboarding__mdt')) + '\n ' +
                          ' FROM PRM_Manage_User_Onboarding__mdt \n order by Display_Sequence__c' ;
         List<PRM_Manage_User_Onboarding__mdt> mdList = Database.query(queryStr);
        system.debug('***Telstra:ManagePIMSController:getPartnerRoles:records found:'+mdList);
        return mdList;
    }
    
    /*
     * P2OB-7962 : Method to obtain picklist values for field Contact.Deactivate_Reason__c
    */
    @AuraEnabled
    public static List<String> getDeactivateReasonPicklist(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Deactivate_Reason__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    /*
     * P2OB-7962 - Updated method to remove dupilcate query on contact 
     */
    @AuraEnabled
    public static String validate(String pageObjectID) {
        String PRMCommunityUser = Label.PRM_Community_User;
        String IndirectChannelMangr = Label.PRM_Indirect_Channel_Mangr;
        String IndirectchannelmgrIntl = Label.PRM_Indirect_channel_mgrIntl;
        String PRMCommunityAdminUser = Label.PRM_CommunityAdmin_User;
        String BusinessAdminNewProfile = PRMConstants.PRM_BusinessAdminNewProfile;
         String ICMProfile = PRMConstants.PRM_Profile_IndirectChannelManager;
        WrapperValidPIMSOperations Wrappervalidops = new WrapperValidPIMSOperations();
        //TODO
        try {
            system.debug('pageObjectID' + pageObjectID);
            string ObjectType = sObjecthelper.getObjectNameFromId(pageObjectID);
            system.debug('ObjectId' + ObjectType);
            if (ObjectType == 'Account') {
                Wrappervalidops.isAccountType = true;
                Account acc = [SELECT Id, name, IsPartner, Account_Status__c FROM Account WHERE Id = :pageObjectID];
                //SonarCube Changes for Tech Debt EDGE-130098
                updateBasedonAccountStatusAndPartner(acc , Wrappervalidops);
            } else if (ObjectType == 'Contact') {
                Wrappervalidops.isContactType = true;
                Contact con = [SELECT Id, AccountId, Community_User_Type__c, PIMS_User_Status__c, Onboarding_Status__c,Partner_Role__c FROM Contact WHERE Id = :pageObjectID];
                String Accountid = con.AccountId;
                //SonarCubeChanges for Tech Debt EDGE-130098
                checkAccountStatus(Accountid, Wrappervalidops);
                if (con.Id != null) {
                    String loggedinUserId = UserInfo.getUserId();
                    String loggedinProfileId = UserInfo.getProfileId();
                    User logeduser = [SELECT Id, IsPortalEnabled, IsPrmSuperUser, ProfileId
                                      FROM User
                                      WHERE Id = :loggedinUserId];
                    Profile logeduserprofilr = [SELECT Id, Name FROM Profile where id = :loggedinProfileId];
                    //Wrappervalidops.isElevateToPDUAAllowed = logeduser.IsPortalEnabled?true:false;
                    //If user is PRM user, they should not accees for any field
                    //SonarCubeChanges for Tech Debt EDGE-130098
                    checkLogedInUserProfile(logeduserprofilr.Name, Wrappervalidops);
          /*
if (con.Onboarding_Status__c == 'Frozen') {
Wrappervalidops.isReinstateUserAllowed = true;
} 
else {
Wrappervalidops.isReinstateUserAllowed = false;
} */
                    List<User> cousr = [SELECT Id, isactive, IsPortalEnabled, IsPrmSuperUser, ProfileId
                                        FROM User
                                        WHERE ContactId = :pageObjectID];
                    //P2OB-7962 : Removing duplicate query on contact 
                    //contact cont = [SELECT Id, Community_User_Type__c, PIMS_User_Status__c, Onboarding_Status__c from contact where id = :pageObjectID];
                    profile p;
                    //Sonarcube Changes for Tech Debt EDGE-130098
                    Set<String> getPIMSUserStatusSet = new  Set<String>();
                    getPIMSUserStatusSet.add('User Created');
                    getPIMSUserStatusSet.add('Elevated to Admin');
                    getPIMSUserStatusSet.add('Removed Admin access');
                    //Sonarcube Changes for Tech Debt EDGE-130098


                    if (getPIMSUserStatusSet.contains(con.PIMS_User_Status__c) && logeduserprofilr.Name != PRMCommunityUser) {
                        if (!cousr.isempty())
                            p = [select id, Name from profile where id = :cousr[0].ProfileId];
                        Wrappervalidops.isUserDeactivationAllowed = true;
                        Wrappervalidops.isUserUpdateAllowed = true;
                        Wrappervalidops.isUserCreateAllowed = false;
                        //Wrappervalidops.isremovePDUA = true;
                       //Only ICM user and business admin new profile will be allowed in the below block
                        // if(logeduserprofilr.Name != PRMCommunityAdminUser && logeduserprofilr.Name != BusinessAdminNewProfile && con.Community_User_Type__c!='PRM Community Admin')
                         //Sonarcube Changes No statements
                        //if (logeduserprofilr.Name != PRMCommunityAdminUser && (logeduserprofilr.Name == BusinessAdminNewProfile || logeduserprofilr.Name == ICMProfile ) && (p.Name != '' && p.Name != PRMConstants.PRM_PROFILE_PRM_Admin_Australia))
                            //Wrappervalidops.isElevateToPDUAAllowed = true;
                            //system.debug('con.PIMS_User_Status__c_1'+cont.PIMS_User_Status__c);
                        //Sonar Cube Changes for Tech Debt EDGE-130098
                        statusUpdate(con.PIMS_User_Status__c, Wrappervalidops);
                        if (con.Onboarding_Status__c == 'Frozen') {
                            Wrappervalidops.isReinstateUserAllowed = true;
                        } 
                        else {
                            Wrappervalidops.isReinstateUserAllowed = false;
                        }
                    }
                    //SonarCube Changes for Tech Debt EDGE-130098
                    //P2OB-9678 : Remove 'deactivateUser' logic 
                    //checkUserDeactivated(con.PIMS_User_Status__c, Wrappervalidops);
                }
                system.debug('Wrappervalidops.isremovePDUA'+Wrappervalidops.isremovePDUA);
            }
            system.debug('ddd' + Wrappervalidops);
            //validate as per scenarios described in US
        } catch (Exception ex) {
            System.debug('Exception' + ex.getStackTraceString() + ex.getMessage());
            //refer logging in existing code
            response = getExceptionErrorResponse('Apex_Error_Exception', ex.getMessage() + '--' + ex.getStackTraceString());
        } finally {
        }
        return JSON.serialize(Wrappervalidops);
        // return JSON.serialize(new WrapperPageResponse());
    }
    // Called via JavaScript Remoting
    // //Girish P Changes
    @RemoteAction
    global static Object invoke(String pageInputParams, string Handlername) {
        system.debug('pageInputParams***' + pageInputParams);
        system.debug('Handlername***' + Handlername);
        
        string Handler = Handlername;
        
        Object response = null;
        //Added escapesinglequotes method to tackle security risk EDGE-145584 - team Amsterdam
       WrapperMSPIMSParams.WrapperPageParameters pageParams = parsePageParams(String.escapeSingleQuotes(pageInputParams));
        //WrapperMSPIMSParams.WrapperPageParameters pageParams = parsePageParams(pageInputParams);
        // WrapperPageParameters pageParams = pageInputParams;
        if (pageParams.pimsAPIType.equalsIgnoreCase('MANAGEORG')) {
            if (String.isEmpty(Handler)) {
                Handler = 'PimsMicroserviceManageOrg';
            }
            //Added escapesinglequotes method to tackle security risk EDGE-145583 - team Amsterdam
            response = manageOrg(pageParams, String.escapeSingleQuotes(Handler));
        }
        if (pageParams.pimsAPIType.equalsIgnoreCase('MANAGEUSER')) {
            if (String.isEmpty(Handler)) {
                Handler = 'PimsMicroserviceManageUser';
            }
            //Added escapesinglequotes method to tackle security risk EDGE-145583 - team Amsterdam
            response =  manageUser(pageParams,String.escapeSingleQuotes(Handler));
        }
        return response;
    }
    public static Object manageUser(WrapperMSPIMSParams.WrapperPageParameters pageParams,String Handler) {
        String orgId = '';
        String userPid = '';
        String profileName = '';
        WrapperPageResponse wrapperPageResponse = new WrapperPageResponse();
        WrapperMSPIMSParams.MSRequestUser msRequest = new WrapperMSPIMSParams.MSRequestUser();
        WrapperMSPIMSParams.WrapperPageResponse pageResponse = new WrapperMSPIMSParams.WrapperPageResponse();
        Logger2 logger = Logger2.getLogger('ManagePIMSController');
        //TODO based on the pimsCallType, create request Paraemeter for API call
        try {
            System.debug(msRequest + '***msRequest');
            System.debug(pageParams + '***pageParams');
            // Make an HTTPRequest as we normally would
            switch on pageParams.pimsCallType {
                // Commented for bypassing finduser call
                when  'finduser'{
                response= PIMSService.finduser(pageParams,Handler);
                }
                when  'updateTCW'{
                response= PIMSService.createUser(pageParams,Handler);
                }
               /* // added for bypassing finduser call
                when  'createUser'{ 
                    response= PIMSService.createUser(pageParams,Handler);
                }
                */
                //P2OB-9678 : Commented the logic for Button 'Deactivate User'
                /*when  'deactivateUser'{
                    response= PIMSService.deactivateUser(pageParams,Handler);
                    //SonarCube Changes for Tech Debt EDGE-127537
                    return getResponse(response, pageParams, '', false, true);
                }*/ when  'reinstateUser'{
                    response= manageContact(pageParams.pageObjectID, pageParams.Pimscalltype);
                    //response= PIMSService.reinstateUser(pageParams,Handler);
                    //SOnarCube Change as no statement in if loop for Tech Debt EDGE-127537
                    // if('TCW'==String.valueOf(response)){
                    //     //TODO: just update the user in Salesforce
                    // }
                } when  'elevateToPDUA'{ // if TEG user then callout to make elecateToPDUA,If TCW user then just updating the user to ADMIN
                    response= PIMSService.createAdminUser(pageParams,Handler);
                    system.debug('***Manage pims : elevateToPDUA:'+response);
                    //SonarCube Changes for Tech Debt EDGE-127537
                    return getResponse(response, pageParams, PRMConstants.PRM_PROFILE_PRM_Admin_Australia, true, true);
                }when  'removePDUA'{// if TEG user then callout to make removePDUA,If TCW user then just updating the user to Community user
                    response= PIMSService.removeAdminUser(pageParams,Handler);
                    //SonarCube Changes for Tech Debt EDGE-127537
                    return getResponse(response, pageParams, PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA, true, true);
                    //return getResponse(response, pageParams, null , true, true);
                } when  'updateUser'{
                    response= PIMSService.updateUser(pageParams,Handler);
                } //when  'freezeUser'{
                //     //PIMSService.updateUser(pageParams);
                // } when  'unFreezeUser'{
                //     //PIMSService.updateUser(pageParams);
                // }//SonarCubeChanges for Tech Debt EDGE-127537
            }
        } catch (Exception ex) {
            //refer looging in existing code
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            //Un-comment and re-use accordingly
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            response = getExceptionErrorResponse('Apex_Error_Exception', ex.getMessage() + '--' + ex.getStackTraceString());
        } finally {
            logger.exitLogger();
        }
        //parse response;
        return response;
    }
    public static Object manageOrg(WrapperMSPIMSParams.WrapperPageParameters pageParams, string Handlername) {
        String orgName = null;
        String orgId = null;
        WrapperPageResponse wrapperPageResponse = new WrapperPageResponse();
        WrapperMSPIMSParams.MSRequestOrg msRequest = new WrapperMSPIMSParams.MSRequestOrg();
        Logger2 logger = Logger2.getLogger('ManagePIMSController.ManageOrg');
        try {
            switch on pageParams.pimsCallType {
                when  'createOrg'{
                    response =PIMSService.createOrg( pageParams,  Handlername);
                }
                when  'deactivateOrg'{
                    response =PIMSService.deactivateOrg( pageParams,  Handlername);
                } when  'reactivateOrg'{
                    response =PIMSService.reactivateOrg( pageParams,  Handlername);
                } when  'freezeOrg'{
                    response =manageAccount(pageParams.pageObjectID, pageParams.Pimscalltype);
                } when  'unfreezeOrg'{
                    response =manageAccount(pageParams.pageObjectID, pageParams.Pimscalltype);
                } 
            }
        } catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            response = getExceptionErrorResponse('Apex_Error_Exception', ex.getMessage() + '--' + ex.getStackTraceString());
        } finally {
            //pageResponse.wrapperValidOperations =  ManagePIMSControllerG.validate(params.pageObjectID);
            logger.exitLogger();
        }
        return response;
    }
    //Manage Account, Freeze unfreeze account logic here EDGE-61863, Added by Ramya
    // we are passing the current accountid and PIMS call type which will be FREEZE_ORG or UNFREEZE_ORG. based on the calltype, we are
    //updting account and contact status to frozen(all accounts, related contacts and corresp. users) or active (all accounts, only PDUA contacts and corresp. users).
    public static Object manageAccount(Id accountid, String Pimscalltype) {
        ////account status=frozen, all Contact.Onboarding_Status__c=frozen
        ////if unfrezze all PDUA will be Contact.Onboarding_Status__c=active
        Account actstatus = [Select Id, Name, Account_Status__c from Account where Id = :accountid];
        List<Contact> conList = [Select id, Name, Onboarding_Status__c, Community_User_Type__c, account.Account_Status__c from Contact where accountId = :accountid];
        Map<Id, contact> conlistmap = new Map<Id, contact>([Select id, Name, Onboarding_Status__c, Community_User_Type__c, account.Account_Status__c from Contact where accountId = :accountid]);
        Map<Id, user> conusrmap = new Map<Id, user>();
        Map<Id, User> pduaUser = new Map<Id, User>([Select id, contactid, name, profile.name, profileid from User where contactid in :conlistmap.keySet()]);
        WrapperMSPIMSParams.WrapperPageResponse pageResponse = new WrapperMSPIMSParams.WrapperPageResponse();
        map<string, string> FieldMapnew = new map<string, string>();
        try{
            for (user u : pduaUser.values()) {
                conusrmap.put(u.contactid, u);
            } 
           // EDGE-127537 commented for Tech Debt remediation. added logic to method manageAccountExt
          /* if (Pimscalltype == PRMConstants.FREEZE_ORG) {
                actstatus.Account_Status__c = PRMConstants.STATUS_FROZEN;
                for (Contact con : conList) {
                    con.Onboarding_Status__c = PRMConstants.STATUS_FROZEN;
                }
            } else if (Pimscalltype == PRMConstants.UNFREEZE_ORG) {
                actstatus.Account_Status__c = PRMConstants.STATUS_ACTIVE;
                for (Contact con : conList) {
                    // Only PDUA users (Profile = PRM Admin) to be Unfrozen
                    if (actstatus.Account_Status__c != 'Frozen' && conusrmap.get(con.id) != null && conusrmap.get(con.id).profile.name == PRMConstants.PRM_PROFILE_PRM_Admin_Australia) {
                        con.Onboarding_Status__c = PRMConstants.STATUS_ACTIVE;
                    }
                }
            }
            update actstatus;
            update conList; */
            manageAccountExt(Pimscalltype,actstatus,conList,conusrmap); //EDGE-127537 Tech debt method
            pageResponse.description = 'Success';
            if(Pimscalltype == PRMConstants.FREEZE_ORG)
                FieldMapnew.put('DeveloperName', 'Freeze_success');
            if(Pimscalltype == PRMConstants.UNFREEZE_ORG)
                FieldMapnew.put('DeveloperName', 'Unfreeze_success');
            List<PIMS_Status_Message_Mapping__mdt> statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMapnew);
            pageResponse.message = statusMapping[0].End_User_Message__c;
            pageResponse.isSuccess = true;   
            pageResponse.status = statusMapping[0].STATUS_CODE__c;            
            return pageResponse;
        }
        catch(exception e)
        {
            pageResponse.description = 'Failure';
            if(Pimscalltype == PRMConstants.FREEZE_ORG)
                FieldMapnew.put('DeveloperName', 'Freeze_failure');
            if(Pimscalltype == PRMConstants.UNFREEZE_ORG)
                FieldMapnew.put('DeveloperName', 'Unfreeze_failure');
            List<PIMS_Status_Message_Mapping__mdt> statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMapnew);
            pageResponse.message = statusMapping[0].End_User_Message__c + '\n' + 'Error code: ' + statusMapping[0].User_Error_Code__c;
            pageResponse.isSuccess = false;   
            pageResponse.status = statusMapping[0].STATUS_CODE__c;            
            return pageResponse;
        }
    }
    //EDGE-127537 method for tech debt remediation for manageAccount
    private static void manageAccountExt(String Pimscalltype, Account actstatus, List<Contact> conList,Map<Id, user> conusrmap){
    if (Pimscalltype == PRMConstants.FREEZE_ORG) {
                actstatus.Account_Status__c = PRMConstants.STATUS_FROZEN;
                for (Contact con : conList) {
                    con.Onboarding_Status__c = PRMConstants.STATUS_FROZEN;
                }
            } else if (Pimscalltype == PRMConstants.UNFREEZE_ORG) {
                actstatus.Account_Status__c = PRMConstants.STATUS_ACTIVE;
                for (Contact con : conList) {
                    // Only PDUA users (Profile = PRM Admin) to be Unfrozen
                    if (actstatus.Account_Status__c != 'Frozen' && conusrmap.get(con.id) != null && conusrmap.get(con.id).profile.name == PRMConstants.PRM_PROFILE_PRM_Admin_Australia) {
                        con.Onboarding_Status__c = PRMConstants.STATUS_ACTIVE;
                    }
                }
            }
            update actstatus;
            update conList;
    }
    //Manage Contact, Based Contact.Onboarding_Status__c, corresponding Users Freeze/Unfreeze logic here EDGE-61863, Added by Ramya   
    public static Object manageContact(Id contactid, String Pimscalltype) {
        WrapperMSPIMSParams.WrapperPageResponse pageResponse = new WrapperMSPIMSParams.WrapperPageResponse();
        map<string, string> FieldMapnew = new map<string, string>();
        Contact contstatus = [Select Id, Name, Onboarding_Status__c from Contact where Id = :contactid];
        if (Pimscalltype == PRMConstants.REINSTATE_USER) {
            contstatus.Onboarding_Status__c = PRMConstants.STATUS_ACTIVE;
        }
        update contstatus;
        pageResponse.description = 'Success';
        if(Pimscalltype == PRMConstants.REINSTATE_USER)
            FieldMapnew.put('DeveloperName', 'Reinstate_success');
        List<PIMS_Status_Message_Mapping__mdt> statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMapnew);
        pageResponse.message = statusMapping[0].End_User_Message__c;
        pageResponse.isSuccess = true;   
        pageResponse.status = statusMapping[0].STATUS_CODE__c;            
        return pageResponse;
        //return null;
    }
    /*
parsePIMS reposnse
*/
    public static Object parsePIMSResponse(HttpResponse httpResponse,
                                           ContinuationController.WrapperState wrapperState) {
                ManagePIMSControllerService handler = new ManagePIMSControllerService();
                //P2OB-7962 : ApexCSRF : Calling method to handle response-parsing logic
                handler.handleResponse(httpResponse,wrapperState);                                        
                return handler.getPageResponse();
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
    public static String generateUniqueId() {
        return String.valueOf(Crypto.getRandomInteger());
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
       public static WrapperMSPIMSParams.WrapperPageResponse getPageResponse(boolean isError,WrapperMSPIMSParams.WrapperPageParameters pageParams) {                
                WrapperMSPIMSParams.WrapperPageResponse pageResponse = new WrapperMSPIMSParams.WrapperPageResponse();
                map<string, string> FieldMapnew = new map<string, string>();
                Contact Con= new contact();
                  string ObjectType = sObjecthelper.getObjectNameFromId(pageParams.pageObjectID);
                    if (ObjectType == 'Contact' && !String.isEmpty(pageParams.pageObjectID)  ) {
                        Con = [SELECT Id,P_Number__c FROM contact WHERE id = :pageParams.pageObjectID];
                    }
                FieldMapnew.put('Pims_Interface__c', pageParams.pimsCallType);              
                if(isError)
                    {
                            FieldMapnew.put('PIMS_Status_code__c', '-1');
                            FieldMapnew.put('STATUS_CODE__c', '400');       
                            pageResponse.isSuccess = false;                             
                    }
                    else
                    {
                           FieldMapnew.put('PIMS_Status_code__c', '0');
                           FieldMapnew.put('STATUS_CODE__c', '200'); 
                            pageResponse.isSuccess = true;                                                         
                    }
                List<PIMS_Status_Message_Mapping__mdt> statusMapping = (List<PIMS_Status_Message_Mapping__mdt>)PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt', FieldMapnew);
                pageResponse.message = statusMapping[0].End_User_Message__c;
                  if (!String.isEmpty(Con.P_Number__c) && statusMapping[0].End_User_Message__c.indexOf('<PID>') > -1) {
                        pageResponse.message = pageResponse.message.replaceAll('<PID>', Con.P_Number__c);
                    }
        return pageResponse;
    }
    @AuraEnabled
    public static String validateContactDetails(String pageObjectID, string callType) {
        WrapperMessage message = new WrapperMessage();
        try {
            Map<String, String> specAttributes = (Map<String, String>) JSON.deserialize(Label.PRM_PARTNER_LICENSE_VALIDATION_MESSAGE, Map<String, String>.class);
            system.debug('pageObjectID' + pageObjectID);
            string ObjectType = sObjecthelper.getObjectNameFromId(pageObjectID);
            if (ObjectType == 'Contact') {
                Contact con = [SELECT Id,Account.PartnerPrincipalContact__c,Account.PRM_Remaining_License__c, Account.Overall_Accreditation__c, AccountId, FirstName, LastName, email, Phone,OTP_Mobile_Phone_Number__c, Deactivate_Reason__c FROM Contact WHERE Id = :pageObjectID];
                switch on callType {
                    when  'updateUser'{
                    message.ShowMessage = (String.isBlank(con.FirstName) || String.isBlank(con.LastName) || String.isBlank(con.email) || String.isBlank(con.OTP_Mobile_Phone_Number__c));
                    message.ErrorMessage = System.Label.RequiredFields_Contact_Message;
                    return JSON.serialize(message);
                    }
                    when  'createUser','finduser'{
                    if (String.isBlank(con.OTP_Mobile_Phone_Number__c)) {
                        message.ShowMessage = (String.isBlank(con.OTP_Mobile_Phone_Number__c));
                        message.ErrorMessage = System.Label.RequiredFields_Contact_Message_createcall;
                        return JSON.serialize(message);
                    } /*  P2OB-6753 - Hawaii - 05/06/2020 - Commenting the License Limit validation 
                    else {
                                /*
                                //Commented these lines as part of code refactor as we can refer the details from the Contact query (03-01-2019)
                        String Accountid = con.AccountId;
                        if (Accountid != null) {
                            Account acc = [SELECT Id, PRM_Remaining_License__c, Overall_Accreditation__c  FROM Account WHERE Id = :Accountid];
                                */
                            //commented by Saran for EDGE-59393 and added new if block to check the remaining licenses
                                        /* 
                                        if (acc.PRM_Remaining_License__c <= 0 && acc.Overall_Accreditation__c == 'Platinum') {
message.ShowMessage = true;
message.ErrorMessage = specAttributes.get('platinumPDUA');
return JSON.serialize(message);
} else if (acc.PRM_Remaining_License__c <= 0 && acc.Overall_Accreditation__c != 'Platinum') {
message.ShowMessage = true;
message.ErrorMessage = specAttributes.get('nonPlatinumPDUA');
return JSON.serialize(message);
                                        }
                                        */
                                   /*  P2OB-6753 - Hawaii - 05/06/2020 - Commenting the License Limit validation  
                                   if(con.Account.PRM_Remaining_License__c<=0)
                                    {
                                        message.ShowMessage=true;
                                        message.ErrorMessage=specAttributes.get('PartnerLicenseExhausted');
                                        return JSON.serialize(message);
                                    }
                            }P2OB-6753 - Hawaii - comment end*/
                    }
                   /* when  'deactivateUser'{
                      //account acc = [select id, PartnerPrincipalContact__c from account where id = :con.Accountid]; //Commented these lines as part of code refactor as we can refer the details from the Contact query (03-01-2019)
                        //if (acc.PartnerPrincipalContact__c == pageObjectID) {
                        if (con.account.PartnerPrincipalContact__c == pageObjectID) {
                            message.ShowMessage = true;
                            message.ErrorMessage = specAttributes.get('deactivatePrincipalContact');
                            return JSON.serialize(message);
                        }
                        if (con.Deactivate_Reason__c == null) {
                            message.ShowMessage = true;
                            message.ErrorMessage = specAttributes.get('DeactivateReason_Required');
                            return JSON.serialize(message);
                        }
                    }*/
                }
               /* commented part of code refcator,cyclomaticcomplexity reduction                
                if (callType == 'updateUser') {
                    message.ShowMessage = (String.isBlank(con.FirstName) || String.isBlank(con.LastName) || String.isBlank(con.email) || String.isBlank(con.OTP_Mobile_Phone_Number__c));
                    message.ErrorMessage = System.Label.RequiredFields_Contact_Message;
                    return JSON.serialize(message);
                } else if (callType == 'createUser' || callType == 'finduser') {
                    if (String.isBlank(con.OTP_Mobile_Phone_Number__c)) {
                        message.ShowMessage = (String.isBlank(con.OTP_Mobile_Phone_Number__c));
                        message.ErrorMessage = System.Label.RequiredFields_Contact_Message_createcall;
                        return JSON.serialize(message);
                    } else {
                        String Accountid = con.AccountId;
                        if (Accountid != null) {
                            Account acc = [SELECT Id, PRM_Remaining_License__c, Overall_Accreditation__c  FROM Account WHERE Id = :Accountid];
                            //commented by Saran for EDGE-59393 and added new if block to check the remaining licenses
                                //if (acc.PRM_Remaining_License__c <= 0 && acc.Overall_Accreditation__c == 'Platinum') {
                                //message.ShowMessage = true;
                                //message.ErrorMessage = specAttributes.get('platinumPDUA');
                                //return JSON.serialize(message);
                                //} else if (acc.PRM_Remaining_License__c <= 0 && acc.Overall_Accreditation__c != 'Platinum') {
                                //message.ShowMessage = true;
                                //message.ErrorMessage = specAttributes.get('nonPlatinumPDUA');
                                //return JSON.serialize(message);
                                //}
                            if(acc.PRM_Remaining_License__c<=0)
                            {
                                message.ShowMessage=true;
                                message.ErrorMessage=specAttributes.get('PartnerLicenseExhausted');
                                return JSON.serialize(message);
                            }
                        }
                    }
                } else if (callType == 'deactivateUser') {
                    account acc = [select id, PartnerPrincipalContact__c from account where id = :con.Accountid];
                    if (acc.PartnerPrincipalContact__c == pageObjectID) {
                        message.ShowMessage = true;
                        message.ErrorMessage = specAttributes.get('deactivatePrincipalContact');
                        return JSON.serialize(message);
                    }
                    if (con.Deactivate_Reason__c == null) {
                        message.ShowMessage = true;
                        message.ErrorMessage = specAttributes.get('DeactivateReason_Required');
                        return JSON.serialize(message);
                    }
                }
                */
            }
        } catch (Exception ex) {
            System.debug('Exception' + ex.getStackTraceString() + ex.getMessage());
        }
        return JSON.serialize(message) ;
    }
    @AuraEnabled
    public static String IsPIMSAccessible(String pageObjectID) {
        WrapperMessage message = new WrapperMessage();
        try {
            //Boolean isPlatinumPDUA = false;
            string ObjectType = sObjecthelper.getObjectNameFromId(pageObjectID);
            Map<String, String> specAttributes = (Map<String, String>) JSON.deserialize(Label.PRM_PARTNER_LICENSE_VALIDATION_MESSAGE, Map<String, String>.class);
            Group  CATGroup = [Select Id, Type from Group where DeveloperName = :PRMConstants.PRM_PUBLICGROUP_CHANNEL_ACQUISITION_TEAM And type = 'Regular' limit 1];
            List<GroupMember> GMlist = [Select id, GroupId, UserOrGroupId from GroupMember where  GroupId = :CATGroup.id AND UserOrGroupId = :UserInfo.getUserId()];
            system.debug('GMlist' + GMlist);
            Profile p = [select id, name from profile where id = :userinfo.getProfileId()];
            //Only Platinum PDUA has access to manage Users
            //Commented:Apr 15-2019- Manage user operations Accessible without consideration of Accreditation status.
           /* if (p.name == PRMConstants.PRM_PROFILE_PRM_Admin_Australia) {
                User loggedInUser = [Select id, Contact.Account.Overall_Accreditation__c from User where Id = :UserInfo.getUserId()];
                isPlatinumPDUA = !String.isEmpty(loggedInUser.Contact.Account.Overall_Accreditation__c) && loggedInUser.Contact.Account.Overall_Accreditation__c == PRMConstants.PRM_PLATINUM_PDUA ? true : false;
            }*/
            if (GMlist.size() == 0) {
                if (ObjectType == 'Account' &&  p.name!='System Administrator') { //Manage Org
                    message.ShowMessage = true;
                    message.ErrorMessage = specAttributes.get('noAccess');
                    return JSON.serialize(message);
                } else if (ObjectType == 'Contact') { //Manage User
                    contact con = [select id, Account.Account_Status__c from contact where id = :pageObjectID];
                    //SonarCube Changes for Tech Debt EDGE-127537
                    Set<String> getProfileSet = new  Set<String>();
                    getProfileSet.add(PRMConstants.PRM_Profile_IndirectChannelManager);
                    getProfileSet.add(PRMConstants.PRM_BusinessAdminNewProfile);
                    getProfileSet.add('System Administrator');
                    getProfileSet.add(PRMConstants.PRM_PROFILE_PRM_Admin_Australia);
                    if (con.Account.Account_Status__c != 'Active' || !getProfileSet.contains(p.name))
                    { 
                        message.ShowMessage = true;
                        message.ErrorMessage = specAttributes.get('noAccess');
                        return JSON.serialize(message);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Exception' + ex.getStackTraceString() + ex.getMessage());
        } finally {
        }
        return JSON.serialize(message);
    }
    //SonatCube Methods
    public static void statusUpdate(String Status, WrapperValidPIMSOperations Wrappervalidops){
        if (Status == 'Elevated to Admin'){
            system.debug('cont.PIMS_User_Status__c'+Status);
            Wrappervalidops.isremovePDUA = true;
        }
        if (Status == 'Removed Admin access' || Status == 'User Created'){
            Wrappervalidops.isElevateToPDUAAllowed = true;                   
        } 
    }
    public static void checkLogedInUserProfile(String profileName, WrapperValidPIMSOperations Wrappervalidops){
        String PRMCommunityAdminUser = Label.PRM_CommunityAdmin_User;
        String PRMCommunityUser = Label.PRM_Community_User;
        if (profileName == PRMCommunityUser) {    
            Wrappervalidops.isUserCreateAllowed = false;
            Wrappervalidops.isElevateToPDUAAllowed = false;
            Wrappervalidops.isUserDeactivationAllowed = false;
            Wrappervalidops.isUserUpdateAllowed = false;
            Wrappervalidops.isremovePDUA = false;
            Wrappervalidops.isICMuser= true;  
        }
        if (profileName == PRMCommunityAdminUser) {
            Wrappervalidops.isICMuser= true;
        }
    }
    public static void updateBasedonAccountStatusAndPartner(Account acc, WrapperValidPIMSOperations Wrappervalidops){
        if (acc.Account_Status__c == 'New' && !acc.IsPartner) {
            Wrappervalidops.isActiveAccount = true;
            Wrappervalidops.isOrgCreateAllowed = true;
        } else if (acc.IsPartner && acc.Account_Status__c != 'Inactive') {
            Wrappervalidops.isOrgDeactivateAllowed = true;
            Wrappervalidops.isOrgCreateAllowed = false;
            if (acc.Account_Status__c == 'Active') {
                Wrappervalidops.isActiveAccount = true;
                Wrappervalidops.isOrgFreezeAllowed = true;
            }
            if (acc.Account_Status__c == 'Frozen') {
                Wrappervalidops.isActiveAccount = false;
                Wrappervalidops.isOrgUnFreezeAllowed = true;
            }
        }
    }
    public static WrapperMSPIMSParams.WrapperPageResponse getResponse(Object response, WrapperMSPIMSParams.WrapperPageParameters pageParams, String profileName, Boolean isActive, Boolean isProfileUpdatable){
        if('TCW'==String.valueOf(response)){
            map<Id, string> mapConIdUserId = new map<Id, string>();
            list<id>  lstContactIds= new list<id>();
            lstContactIds.add(pageParams.pageObjectID);
            PhoenixGlobalUtil.UpdateContactRecord(pageParams.pimsCallType,pageParams.pageObjectID);
            boolean isError = PhoenixGlobalUtil.upsertUserRecordBulk(lstContactIds,mapConIdUserId, profileName, isActive, isProfileUpdatable); 
            return getPageResponse(isError,pageParams);
        }
        return null;
    }
    //P2OB-9678 : Remove 'deactivateUser' logic 
    /*public static void checkUserDeactivated(String Status, WrapperValidPIMSOperations Wrappervalidops){
        if (Status == 'Deactivated') {
            Wrappervalidops.isUserDeactivationAllowed = false;
            Wrappervalidops.isUserUpdateAllowed = false;
            Wrappervalidops.isElevateToPDUAAllowed = false;
            Wrappervalidops.isUserCreateAllowed = false;
            Wrappervalidops.isremovePDUA = false;
        }
    }*/
    public static void checkAccountStatus(String Accountid, WrapperValidPIMSOperations Wrappervalidops){
        if (Accountid != null) {
            Account acc = [SELECT Id, Account_Status__c FROM Account WHERE Id = :Accountid];
            if (acc.Account_Status__c != 'New' && acc.Account_Status__c != 'Inactive') {
                Wrappervalidops.isActiveAccount = true;
                Wrappervalidops.isUserCreateAllowed = true;
                Wrappervalidops.isReinstateUserAllowed = false;
            }
        }
    }
    public class WrapperServiceResponse {
        public  WrapperMSPIMSParams.MSResponse MSResponse;
        public Id ContactId;
        public Id AccountId;
    }
    public class WrapperPageResponse {
        @AuraEnabled
        public String wrapperValidOperations;
        public sObject pageObjectRecord;
        public String description;
        public String status;
        public Boolean isSuccess;
        public String message;
        //public WrapperMSPIMSParams.MSResponseFindUserdetails pimsuserdetails;
    }
    public static WrapperMSPIMSParams.WrapperPageParameters parsePageParams(Object pageInputParams) {
        return (WrapperMSPIMSParams.WrapperPageParameters)JSON.deserialize((String)pageInputParams,
                                                                           WrapperMSPIMSParams.WrapperPageParameters.class);
    }
    public class WrapperPageParameters {
        public  String pageObjectID;
        public  String pimsAPIType;
        public  String pimsCallType;
    }
    public class WrapperMessage {
        public  boolean ShowMessage = false;
        public  String ErrorMessage = '';
    }
}