public class AuthorizeContactForAccountHandler implements APIHandler {

    private AuthorizeContactForAccountHandler() {
        // do nothing
    }

    private static AuthorizeContactForAccountHandler instance = null;

    public static AuthorizeContactForAccountHandler getInstance() {
        if(instance == null) {
            instance = new AuthorizeContactForAccountHandler();
        }

        return instance;
    }

    public static AuthorizeContactResponse handle(RestRequest req, RestResponse res) {
        AuthorizeContactResponse retval;
        res.addHeader('Content-Type', 'application/json');

        try {

            final AuthorizeContactRequestParams validationResult = APIValidationUtil.validateHeaders(req);

            retval = AuthorizeContactForAccountUtil.validate(validationResult.emailId, validationResult.CIDN);

        } catch(ValidationException vex) {
            retval = AuthorizeContactForAccountUtil.genErrorResponse(vex.getMessage());
            // return http 200 status even in case of validation failures
            res.statusCode = 200;
        } catch(AuthorizationException vex) {
            retval = AuthorizeContactForAccountUtil.genErrorResponse(vex.getMessage());
            // return http 200 status even in case of authorization failures
            res.statusCode = 200;
        } catch(Exception ex) {
            retval = AuthorizeContactForAccountUtil.genErrorResponse(ex.getMessage());
            // return http 500 status in case of any other exception
            // this should never happen
            res.statusCode = 500;
        }
        
        return retval;
    }

}