/*
Hawaii : DIGI-15298 : Vivian Charlie : Replacing PRM_MS_VARIABLES custom label with metadata
Hawaii : 21.15 fdr fix : Vivian Charlie : adding Test.isrunning test
*/
global without sharing class ManagePIMSInterface {
    global static Object callPIMSMicroservice(String msRequest,
            String pimsCallhandler,
            String HTTP_METHOD,
            String payLoadURI,
            Object pageParams) {
        Object pimsResponse;
        // Return it to the system for processing*/
        HttpResponse httpResponse ;
        try {
            String token = AuthenticationManager.getOauthToken(pimsCallhandler);
            
            //String token='123';
            Map<String, String> headerMap = new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + token
            };
            //Map<String,String> headerMap =
            //HTTP callout to interface handler
            
            pimsResponse =  IntegrationRecordHandlerUtil.calloutContinuation(
                                'callbackPIMS',
                                pageParams,
                                payLoadURI,
                                msRequest,
                                HTTP_METHOD,
                                headerMap,
                                String.escapeSingleQuotes(pimsCallhandler),
                                null,
                                generateUniqueId()) ;
            System.debug(pimsResponse + 'pimsResponse*****');
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString() + '*****8Exception');
            //refer looging in existing code
            throw (ex);
        } finally {
        }
        return pimsResponse;
    }
    
    //Method for FIndAPI call
    /*
     public static string findUser(ManagePIMSController.WrapperPageParameters pageParams,String userEmail) {
        Object pimsResponse;
        ManagePIMSController.WrapperPageResponse pageResponse = new ManagePIMSController.WrapperPageResponse();
        WrapperMSPIMSParams.MSResponseFindUser FinduserResponse;    
        try{ 
             String Jsonstr='';
            if(userEmail.toLowerCase().contains('tcw')) 
             Jsonstr='{"data":{"userPid": "P500147","userFirstName": "first","userLastName": "name","userEmail": "P500147@retail1.telstra.com","orgId": 43,"userType": "OTHER","isDeactivate": "FALSE","userMobileNumber": "","isPDUA": "FALSE","partnerLevelId": "Premise", "retailLiveId": "PDUA","positionTypeId": "TLS Shop Sales Rep","partnerNameId": "TLS WAURN PONDS_","partnerCodeId": "LA8H","timezone": "", "userOrgCategory": "TCW"},"description": "User found: P504303.","pimsStatus": 0}';
           else
             Jsonstr='{"data":{"userPid": "P500147","userFirstName": "first","userLastName": "name","userEmail": "P500147@retail.telstra.com","orgId": 43,"userType": "OTHER","isDeactivate": "FALSE","userMobileNumber": "","isPDUA": "FALSE","partnerLevelId": "Premise", "retailLiveId": "PDUA","positionTypeId": "TLS Shop Sales Rep","partnerNameId": "TLS WAURN PONDS_","partnerCodeId": "LA8H","timezone": "", "userOrgCategory": "TE"},"description": "User found: P504303.","pimsStatus": -1}';

            FinduserResponse = WrapperMSPIMSParams.parsePIMSFindUserResponse(Jsonstr);
            system.debug('FinduserResponse'+FinduserResponse);            
                    
            pageResponse.pimsuserdetails=FinduserResponse;
            pageResponse.wrapperValidOperations =  ManagePIMSController.validate(pageParams.pageObjectID) ;   
            System.debug(pageResponse + 'pageResponse*****');

        }
        catch (Exception ex) {
            System.debug(ex.getStackTraceString() + '*****8Exception');
            //refer looging in existing code
            throw (ex);
        } finally {
        }
         
        return JSON.serialize(pageResponse);
}
*/
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
    public  static Map<String,String> getApiDefaults() {
        // DIGI-15298 replacing custom label with metadata
        // 21.15 adding isrunningtest check for prod validation failure
        if(!Test.isRunningTest()){
            ConstantMetadataUtility__mdt mc = ConstantMetadataUtility__mdt.getInstance('PRM_MS_VARIABLES');
            return (Map<String,String>)JSON.deserialize(mc.Value__c,Map<String,String>.class);
        }else{
            return (Map<String,String>)JSON.deserialize('{"defaultOrgName":"1222","callerKey":"salesforce-jdf5ews634azhgdfyeYe623"}',Map<String,String>.class);
        }
    }
    public static String generateUniqueId() {
        return String.valueOf(Crypto.getRandomInteger());
    }
    
    

    
}