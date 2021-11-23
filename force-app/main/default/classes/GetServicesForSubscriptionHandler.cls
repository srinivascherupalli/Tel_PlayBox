public class GetServicesForSubscriptionHandler implements APIHandler {
	
	private GetServicesForSubscriptionHandler() {
		// do nothing
	}

	private static GetServicesForSubscriptionHandler instance = null;
	
	public static GetServicesForSubscriptionHandler getInstance() {
		if(instance == null) {
			return new GetServicesForSubscriptionHandler();
		}
		
		return instance;
	}

	public static OnlineOrderingResponse handle(RestRequest req, RestResponse res) {
		OnlineOrderingResponse retval;
		res.addHeader('Content-Type', 'application/json');

		try {
			AuthorizeContactRequestParams validationResult = APIValidationUtil.validateHeaders(req);
			String cidn = validationResult.CIDN;
			AccountContactRelation acr = AuthorizeContactForAccountUtil.getACR(validationResult.emailId, validationResult.CIDN);
			GetServicesRequestParams reqParams = getRequestParams(req);
			retval = GetServicesForSubscriptionUtil.getServicesForSubscription(reqParams.subscriptionId, cidn);
		} catch (ValidationException vex) {
			retval = AuthorizeContactForAccountUtil.genErrorResponse(vex.getMessage());
			res.statusCode = 200;
		} catch (AuthorizationException aex) {
			retval = AuthorizeContactForAccountUtil.genErrorResponse(aex.getMessage());
			res.statusCode = 200;
		} catch (GetServicesForSubscriptionException gex) {
			retval = GetServicesForSubscriptionUtil.genErrorResponse(system.label.Unexpected_Exception, gex.getMessage());
			res.statusCode = 200;
		} catch(Exception ex) {
			retval = GetServicesForSubscriptionUtil.genErrorResponse(system.label.Unexpected_Exception, ex.getMessage());
			res.statusCode = 500;
		}

        return retval;
	}
	
	private static GetServicesRequestParams getRequestParams(RestRequest request) {
		return new GetServicesRequestParams(request.params.get('subscription_id'));
	}
	
}