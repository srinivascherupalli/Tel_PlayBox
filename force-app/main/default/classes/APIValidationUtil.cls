public with sharing class APIValidationUtil {

    public static AuthorizeContactRequestParams validateHeaders(RestRequest req) {
        AuthorizeContactRequestParams retval;

        final String emailId = req.headers.get(system.label.RequestHeaderEmailId);
        final String CIDN    = req.headers.get(system.label.RequestHeaderCIDN);

        if(null == emailId || '' == emailId) {
            throw new ValidationException('AUTHERR_001');
        } else if(null == CIDN || '' == CIDN) {
            throw new ValidationException('AUTHERR_002');
        } else {
            retval = new AuthorizeContactRequestParams(emailId, CIDN);
        }

        return retval;
    }

}