public class AuthorizeContactForAccountErrorCodes {
    private static AuthorizeContactForAccountErrorCodes instance = null;
    private final Map<String,String> errorCodes { get; set; }
    
    private AuthorizeContactForAccountErrorCodes() {
        errorCodes = new Map<String,String>();
        loadErrorCodes();
    }
    
    public static String getErrorMessage(String code) {
        final String msg = AuthorizeContactForAccountErrorCodes.getInstance().errorCodes.get(code);
        return msg == null ? 'Unknown error code' : msg;
    }
    
    public static AuthorizeContactForAccountErrorCodes getInstance() {
        if(instance == null) {
            instance = new AuthorizeContactForAccountErrorCodes();
        }

        return instance;
    }
    
    private void loadErrorCodes() {
        errorCodes.put('AUTHERR_001', system.label.EmailId_Not_Present);
        errorCodes.put('AUTHERR_002', system.label.CIDN_Not_Present);
        errorCodes.put('AUTHERR_003', system.label.No_Contacts_Found_Matching_Email);
        errorCodes.put('AUTHERR_004', system.label.Multiple_Contacts_Matching_Email);
        errorCodes.put('AUTHERR_005', system.label.No_Authorized_Contacts);
        errorCodes.put('AUTHERR_006', system.label.Too_Many_Records_Found_Expected_One);
        errorCodes.put('AUTHERR_007', system.label.Unexpected_Exception);
        errorCodes.put('AUTHSUCCESS', system.label.Authorization_Success);
    }
}