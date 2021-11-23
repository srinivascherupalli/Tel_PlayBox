public class GetSubscriptionsForAccountErrorCodes {
    private static GetSubscriptionsForAccountErrorCodes instance = null;
    private Map<String,String> errorCodes { get; set; }
    
    private GetSubscriptionsForAccountErrorCodes () {
        errorCodes = new Map<String,String>();
        loadErrorCodes();
    }
    
    public static String getErrorMessage(String code) {
        String msg = GetSubscriptionsForAccountErrorCodes.getInstance().errorCodes.get(code);
        return msg == null ? 'Unknown error code' : msg;
    }
    
    public static GetSubscriptionsForAccountErrorCodes getInstance() {
        if(instance == null) {
            return new GetSubscriptionsForAccountErrorCodes();
        }
        return instance;
    }
    
    private void loadErrorCodes() {
        errorCodes.put('AUTHERR_001','Request Header parameter emailId not present');
        errorCodes.put('AUTHERR_002','Request Header parameter CIDN not present');
        errorCodes.put('AUTHERR_003','No records found matching the given email and CIDN');
        errorCodes.put('AUTHERR_004','More than one contact found matching the given email');
        errorCodes.put('AUTHERR_005','No records found matching the given email and CIDN having required roles');
        errorCodes.put('AUTHERR_006','Too many records found matching the given email and CIDN');
        errorCodes.put('AUTHERR_007','Exception occurred');
        errorCodes.put('AUTHSUCCESS', 'Success');
    }
}