// APIHandler for unmatched URIs
// returns 404 error
public class FallbackHandler implements APIHandler {
	public static APIHandler getInstance() {
		if(instance == null) {
			return new FallbackHandler();
		}
		return instance;
	}

	public OnlineOrderingResponse handle(RestRequest request, RestResponse response) {
		response.statusCode = 404;
		return new FallbackResponse();
	}

	private static FallbackHandler instance = null;
	
	private class FallbackResponse extends OnlineOrderingResponse {
		FallbackResponse () {
			this.isError = true;
			this.message = 'Unknown URI';
		}
	}
}