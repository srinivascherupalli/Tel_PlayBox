public class WrapperMSPIMSParams {
 public MSRequestUser msRequestUser = new MSRequestUser();
    public class MSRequestUser {
        public String callerKey = ManagePIMSInterface.getApiDefaults().get('callerKey');
        // public String userPid; //Commented as per new request stretcure
        public String userLastName;
        public String userFirstName;
        public String userEmail;
        //public String orgName; //Commented as per new request stretcure
        //this for account request
        public String mobileNumber;
        public String userType;
        public String userPid;
        //dont send this in update call
        public Boolean isPDUA;
        //this is for deactivate call
        public Boolean isDeactivate;
    }

    public class MSRequestOrg {
        public String callerKey = ManagePIMSInterface.getApiDefaults().get('callerKey');
        public String orgName;
        //this for account request
        //public String immediateParentOrg=ManagePIMSInterface.getApiDefaults().get('defaultOrgName');
        public String immediateParentOrgId = ManagePIMSInterface.getApiDefaults().get('defaultOrgName');
        //this is for deactivate call
        public Boolean isDeactivate;

    }
    
      public class MSRequesFindUser {
        public String callerKey = ManagePIMSInterface.getApiDefaults().get('callerKey');
        public String userEmail;
        public String userPid;
    }
    
    public class MSResponse {
        public Integer status;
        public String title;
        public String description;
        //public String userIdCreated;
        public Integer pimsStatus;
        public String orgId;
        public String userPid;
        public MSResponseFindUserdetails data;
       
    }

    public class MSResponseFindUser {
        public MSResponseFindUserdetails data;
        public String description;
        public integer pimsStatus;
    }

    public class MSResponseFindUserdetails {
        public String userPid;
        public String userFirstName;
        public String userLastName;
        public String userEmail;
        public Integer orgId;
        public String userType;
        public String isDeactivate;
        public String userMobileNumber;
        public String isPDUA;
        public String partnerLevelId;
        public String retailLiveId;
        public String positionTypeId;
        public String partnerNameId;
        public String partnerCodeId;
        public String timezone;
        public String userOrgCategory;
    }


    public static MSResponse parsePIMSresponse(String pimsJSONResponse) {
        return (MSResponse)JSON.deserialize(pimsJSONResponse, MSResponse.class);
    }

    public static MSResponseFindUserdetails parsePIMSFindUserResponsedetails(String pimsJSONResponse) {
        return (MSResponseFindUserdetails)JSON.deserialize(pimsJSONResponse, MSResponseFindUserdetails.class);
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
    public static WrapperPageParameters parsePageParams(Object pageInputParams) {
        return (WrapperPageParameters)JSON.deserialize((String)pageInputParams, WrapperPageParameters.class);
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