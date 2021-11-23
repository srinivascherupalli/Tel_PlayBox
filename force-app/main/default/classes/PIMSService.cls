/*
 * Modifications : 
 * 1. P2OB-9678 - Hawaii - 8/10/2020 - Commented the method 'deactivateUser' for Button 'Deactivate User' 
 * */
public without sharing class PIMSService {
    public static Object msRequestOBJ;
    public static Object response;
    public static Boolean isTCWUser;
    public static Contact varContact;
    public static String userPid;
    public static String orgId;
    public static List < user > listUser;
    public static Account account;
    public static Boolean isTEGUser;
  
        public static Object createOrg(WrapperMSPIMSParams.WrapperPageParameters pageParams,String handlername) {
        WrapperMSPIMSParams.MSRequestOrg msRequest  = (WrapperMSPIMSParams.MSRequestOrg) getPIMSOrgRequestAttributes(pageParams.pageObjectID);
        system.debug(JSON.serialize(msRequest, true) + '***msRequest');
        return postOrg(msRequest, pageParams,handlername);
        }
    public static Object deactivateOrg(WrapperMSPIMSParams.WrapperPageParameters pageParams,String handlername) {
        WrapperMSPIMSParams.MSRequestOrg msRequest = (WrapperMSPIMSParams.MSRequestOrg) getPIMSOrgRequestAttributes(pageParams.pageObjectID);
        msRequest.isDeactivate = true;
        return postOrg(msRequest, pageParams,handlername);
    }
    public static Object reactivateOrg(WrapperMSPIMSParams.WrapperPageParameters pageParams,String handlername) {
        WrapperMSPIMSParams.MSRequestOrg msRequest = (WrapperMSPIMSParams.MSRequestOrg) getPIMSOrgRequestAttributes(pageParams.pageObjectID);
        msRequest.isDeactivate = false;
        return postOrg(msRequest, pageParams,handlername);
    }
    public void findOrg() {}
    /**
     * { function_description }
     *
     * @param      pageParams  The page parameters
     *
     * @return     { description_of_the_return_value }
     */
    public static Object createUser(WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        
       /* WrapperMSPIMSParams.MSRequestUser msRequest = (WrapperMSPIMSParams.MSRequestUser) getPIMSUserRequestAttributes(pageParams.pageObjectID);
             return postUser(msRequest, pageParams,handlername); 
           */  
    
        
        if(pageParams.pimsCallType.equalsIgnoreCase('updateTCW')){        
                WrapperMSPIMSParams.MSRequestUser msRequest = (WrapperMSPIMSParams.MSRequestUser) getPIMSUserRequestAttributes(pageParams.pageObjectID);
             return postUser(msRequest, pageParams,handlername); 
        }
        else{
            return findUser(pageParams,handlername); 
        } 
          
    }
    
      
    /**
     * { function_description }
     *
     * @param      pageParams  The page parameters
     *
     * @return     { description_of_the_return_value }
     */
    public static Object updateUser(WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        
        
        WrapperMSPIMSParams.MSRequestUser msRequest = (WrapperMSPIMSParams.MSRequestUser) getPIMSUserRequestAttributes(pageParams.pageObjectID);
        system.debug(msRequest + '***msRequest');
        return postUser(msRequest, pageParams,handlername);
    }

    /**
     * { function_description }
     *
     * @param      pageParams  The page parameters
     *
     * @return     { description_of_the_return_value }
     */
    //P2OB-9678 : Commented the logic for Button 'Deactivate User' 
    /*public static Object deactivateUser(WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        WrapperMSPIMSParams.MSRequestUser msRequest = (WrapperMSPIMSParams.MSRequestUser) getPIMSUserRequestAttributes(pageParams.pageObjectID);
        if (!isTCWUser) {
            msRequest.isDeactivate = true;
        } else {
            return 'TCW';
        }
        return postUser(msRequest, pageParams,handlername);
    }*/
    /**
     * { function_description }
     *
     * @param      pageParams  The page parameters
     *
     * @return     { description_of_the_return_value }
     */
    public static Object reinstateUser(WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        WrapperMSPIMSParams.MSRequestUser msRequest = (WrapperMSPIMSParams.MSRequestUser) getPIMSUserRequestAttributes(pageParams.pageObjectID);
        if (!isTCWUser) {
            msRequest.isDeactivate = false;
        } else {
            return 'TCW';
        }
        return postUser(msRequest, pageParams,handlername);
    }
    /**
     * { createAdminUser : Call type "elevateToPDUA" ,creats a PRM admin user }
     *
     * @param      pageParams  The page parameters
     *
     * @return     { description_of_the_return_value }
     */
    public static Object createAdminUser(WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        WrapperMSPIMSParams.MSRequestUser msRequest = (WrapperMSPIMSParams.MSRequestUser) getPIMSUserRequestAttributes(pageParams.pageObjectID);
        if (isTEGUser) {
        //if (true) {
            msRequest.isPDUA = true;
            userPid = listUser[0].FederationIdentifier != null ? listUser[0].FederationIdentifier : '';
            msRequest.isPDUA = true;
            //msrequest.userType = 'PDUA';          
            if ('Partner - International' == listUser[0].contact.account.RecordType.Name) {
            msrequest.userType = 'International';
            } 
            else if ('Partner' == listUser[0].contact.account.RecordType.Name) {
            msrequest.userType = 'Domestic';
            }
            
        } else {
            return 'TCW';
        }
        system.debug(msRequest + '***msRequest');
        return postUser(msRequest, pageParams,handlername);
    }
    /**
     * { removeAdminUser : Call type "removePDUA" ,removes PRM admin risghts and converts to PRM community user  }
     *
     * @param      pageParams  The page parameters
     *
     * @return     { description_of_the_return_value }
     * Comments : EDGE-53188
     */
    public static Object removeAdminUser(WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        WrapperMSPIMSParams.MSRequestUser msRequest = (WrapperMSPIMSParams.MSRequestUser) getPIMSUserRequestAttributes(pageParams.pageObjectID);
        if (isTEGUser) {
       // if (true) {
            //msRequest.isPDUA = true;
            userPid = listUser[0].FederationIdentifier != null ? listUser[0].FederationIdentifier : '';
            msRequest.isPDUA = false;
            if ('Partner - International' == listUser[0].contact.account.RecordType.Name) {
            msrequest.userType = 'International';
            } 
            else if ('Partner' == listUser[0].contact.account.RecordType.Name) {
            msrequest.userType = 'Domestic';
            }
        }
            else {
            return 'TCW';
        }
         
        system.debug(msRequest + '***msRequest');
        return postUser(msRequest, pageParams,handlername);
    }
    
    public static Object findUser(WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
     
        WrapperMSPIMSParams.MSRequesFindUser msRequest = (WrapperMSPIMSParams.MSRequesFindUser) getPIMSfindUserRequestAttributes(pageParams.pageObjectID);
        return posttofindUser(msRequest, pageParams,'PimsMicroserviceFindUser');
    }
    
    public static Object getUser(WrapperMSPIMSParams.MSRequestUser msRequest,
        WrapperMSPIMSParams.WrapperPageParameters pageParams,String handlername) {
        Object response = ManagePIMSInterface.callPIMSMicroservice(JSON.serialize(msRequest, true),
           handlername,
            'POST',
            '/users/',
            pageParams);
        return response;
    }
    /**
     * { function_description }
     *
     * @param      msRequest   The milliseconds request
     * @param      pageParams  The page parameters
     *
     * @return     { description_of_the_return_value }
     */
    public static Object postUser(WrapperMSPIMSParams.MSRequestUser msRequest,
        WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        system.debug(JSON.serialize(msRequest, true) + '***JSON USER msRequest');
        response = ManagePIMSInterface.callPIMSMicroservice(JSON.serialize(msRequest, true),
             handlername,
            'POST',
            orgId + '/users/' + userPid,
            pageParams);
        return response;
    }
    
     /**
     * { function_description }
     */
    public static Object postOrg(WrapperMSPIMSParams.MSRequestOrg msRequest,
        WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        response = ManagePIMSInterface.callPIMSMicroservice(
            JSON.serialize(msRequest, true),
            handlername,
            'POST',
            orgId,
            pageParams);

        return response;
    }
    
     /**
     * { function_description }
     */
    public static Object posttofindUser(WrapperMSPIMSParams.MSRequesFindUser msRequest,
        WrapperMSPIMSParams.WrapperPageParameters pageParams, String handlername) {
        system.debug(JSON.serialize(msRequest, true) + '***JSON USER msRequest');
        response = ManagePIMSInterface.callPIMSMicroservice(JSON.serialize(msRequest, true),
             handlername,
            'POST',
            '',
            pageParams);
            system.debug('response value is '+response);
        return response;
    }
    
    private static Object getPIMSOrgRequestAttributes(String accountId) {
        WrapperMSPIMSParams.MSRequestOrg msRequest = new WrapperMSPIMSParams.MSRequestOrg();
        account = [Select id, Name, Partner_External_Id__c, Primary_distributor__c, Primary_distributor__r.Partner_External_Id__c, Parent.Internal_CAC__c, Internal_CAC__c, ParentId, Parent.Name
            from Account
            where id =: accountId
        ];
         orgId = account.Partner_External_Id__c != null ? account.Partner_External_Id__c : '';
        // orgName = account.Name + '_' + account.Partner_External_Id__c;
        msRequest.orgName = account.Name;
        msRequest.immediateParentOrgId = account.Primary_distributor__c != null ?
            account.Primary_distributor__r.Partner_External_Id__c :
            msRequest.immediateParentOrgId;
        return msRequest;

    }
    /**
     * Gets the pims request attributes.
     *
     * @param      contactId  The contact identifier
     *
     * @return     The pims request attributes.
     */
    public static Object getPIMSUserRequestAttributes(String contactId) {
        varContact = [Select id, Name, PIMS_User_Type__c,P_Number__c,TCW_OrgId__c, account.IsPartner, account.RecordType.Name, account.Partner_External_Id__c, FirstName, LastName, Email, Phone,Work_Phone_Number__c,OTP_Mobile_Phone_Number__c, Account.Name
            from Contact
            where Id =: contactId
        ];
        listUser = [select id, FederationIdentifier,contact.account.RecordType.Name
            from user
            where contactid =: contactId
        ];
              
        if(varContact.PIMS_User_Type__c==PRMConstants.PRM_USER_TYPE_TCW){ 
            userPid=varContact.P_Number__c != null ?varContact.P_Number__c:'';
            orgId=varContact.TCW_OrgId__c != null ?varContact.TCW_OrgId__c:'';
        }
        else
        {
         userPid = listUser.size()>0 && listUser[0].FederationIdentifier != null ? listUser[0].FederationIdentifier : '';
         orgId = varContact.account.Partner_External_Id__c != null ?
            varContact.account.Partner_External_Id__c :
            '';  
        }

        
        WrapperMSPIMSParams.MSRequestUser msRequest = new WrapperMSPIMSParams.MSRequestUser();
        String userType = null;
        if ('Partner - International' == varContact.account.RecordType.Name) {
            userType = 'International';
        } else if ('Partner' == varContact.account.RecordType.Name) {
            userType = 'Domestic';
        }
        msRequest.userType = userType;
        msRequest.mobileNumber = varContact.OTP_Mobile_Phone_Number__c;
        switch on varContact.PIMS_User_Type__c {
            when 'TEG' {
                System.debug('TEG User*****');
                msrequest.userType = userType;
                msRequest.mobileNumber = varContact.OTP_Mobile_Phone_Number__c;
                msRequest.userFirstName = varContact.FirstName;
                msRequest.userLastName = varContact.LastName;
                msRequest.userEmail = varContact.email;
                msRequest.userPid = userPid;
                isTCWUser = false;
                isTEGUser=true;
            }
            when 'TCW' {
                isTCWUser = true;
                isTEGUser=false;
            }
            when else {
                msrequest.userType = userType;
                msRequest.mobileNumber = varContact.OTP_Mobile_Phone_Number__c;
                msRequest.userFirstName = varContact.FirstName;
                msRequest.userLastName = varContact.LastName;
                msRequest.userEmail = varContact.email;
                msRequest.userPid = userPid;
                isTCWUser = false;
                
            }
        }
        return msRequest;
    }
    
    /**
     * Gets the pims request attributes.
     *
     * @param      contactId  The contact identifier
     *
     * @return     The pims request attributes.
     */
    public static Object getPIMSfindUserRequestAttributes(String contactId) {
        varContact = [Select id, Name, TCW_OrgId__c,P_Number__c,PIMS_User_Type__c, account.IsPartner, account.RecordType.Name, account.Partner_External_Id__c, FirstName, LastName, Email, Phone,OTP_Mobile_Phone_Number__c,Work_Phone_Number__c, Account.Name
            from Contact
            where Id =: contactId
        ];
        listUser = [select id, FederationIdentifier,contact.account.RecordType.Name
            from user
            where contactid =: contactId
        ];  
        
        WrapperMSPIMSParams.MSRequesFindUser msRequest = new WrapperMSPIMSParams.MSRequesFindUser();
        
        msRequest.userEmail = varContact.Email;
        msRequest.userPid = userPid;        
        return msRequest;
    }


    public class PIMSServiceException extends Exception {

    }

    public class WrapperPageResponse {
        @AuraEnabled
        public String wrapperValidOperations;
        public sObject pageObjectRecord;
        public String description;
        public String status;
        public Boolean isSuccess;
        public String message;
        public WrapperMSPIMSParams.MSResponseFindUserdetails pimsuserdetails;

    }
}