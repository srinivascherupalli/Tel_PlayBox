public class GetSubscriptionsForAccountHandler implements APIHandler {
	
	private GetSubscriptionsForAccountHandler() {
		// do nothing
	}

	private static GetSubscriptionsForAccountHandler instance = null;
	
	public static GetSubscriptionsForAccountHandler getInstance() {
		if(instance == null) {
			return new GetSubscriptionsForAccountHandler();
		}
		
		return instance;
	}

	public static OnlineOrderingResponse handle(RestRequest req, RestResponse res) {
		OnlineOrderingResponse retval;
		res.addHeader('Content-Type', 'application/json');

		try {
			AuthorizeContactRequestParams validationResult = APIValidationUtil.validateHeaders(req);
			AccountContactRelation acr = AuthorizeContactForAccountUtil.getACR(validationResult.emailId, validationResult.CIDN);
			retval = GetSubscriptionsForAccountUtil.getSubscriptions(acr.accountId);
		} catch (ValidationException vex) {
			retval = AuthorizeContactForAccountUtil.genErrorResponse(vex.getMessage());
			res.statusCode = 200;
		} catch (AuthorizationException aex) {
			retval = AuthorizeContactForAccountUtil.genErrorResponse(aex.getMessage());
			res.statusCode = 200;
		} catch (GetSubscriptionsForAccountException gex) {
			retval = GetSubscriptionsForAccountUtil.genErrorResponse(system.label.Unexpected_Exception, gex.getMessage());
			res.statusCode = 200;
		} catch(Exception ex) {
			retval = GetSubscriptionsForAccountUtil.genErrorResponse(system.label.Unexpected_Exception, ex.getMessage());
			res.statusCode = 500;
		}

        return retval;
	}
	
}