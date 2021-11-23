@RestResource(urlMapping = '/OnlineOrdering/*')
global with sharing class OnlineOrderingService {
    // private constructor to prevent instantiation
    private OnlineOrderingService() {
        // do nothing
    }

	// generic method to handle GET requests for the context URL mapped above
    @HttpGet
    global static void get() {
    	OnlineOrderingResponse retval;
    	
    	final RestRequest request = RestContext.request;
        final RestResponse response = RestContext.response;
        response.addHeader('Content-Type','application/json');

		// get the last part of request URI representing the API to be called
		Integer startPos = request.requestURI.lastIndexOf('/OnlineOrdering') + 15;
        String api = request.requestURI.substring(request.requestURI.indexOf('/', startPos) + 1);

        // get the handler for that API and invoke it
        APIHandler handler = APIHandlerFactory.getHandler(api);
    	retval = handler.handle(request, response);
    	
    	System.debug('retval: ' + retval);

		// check for any errors in return value from the handler
		if(null == retval || retval.hasError()) {
			// if handler does not set HTTP response statusCode, set it to 500
            if (null == response.statusCode) {
            	response.statusCode = 500;
            }
            // else do not overwrite the statusCode set by handler
        } else {
        	// no errors from the handler, set HTTP response success
            response.statusCode = 200;
		}

    	// set the HTTP response body from the handler response
    	response.responseBody = Blob.valueOf(JSON.serialize(retval));

    }
}