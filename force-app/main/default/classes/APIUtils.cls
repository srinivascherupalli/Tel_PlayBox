/**
 * Class for common API Utility Methods.
 */
public with sharing class APIUtils {

   /**
     * Gets the token from okapi.
     *
     * @param      tnUrl  The tn url
     * @param      event  The event
     *
     * @return     The token.
     */
    public static String getToken(String tnUrl, String event) {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tnUrl);

        // retrieve tokenurl from custom settings
        req.setBody('client_id=' + EncodingUtil.urlEncode(EnvironmentVariable.get('okapi_client_id'), 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(EnvironmentVariable.get('okapi_client_secret') , 'UTF-8') +
                    '&grant_type=' + EncodingUtil.urlEncode('client_credentials', 'UTF-8') +
                    '&scope=' + EncodingUtil.urlEncode(event, 'UTF-8'));

        req.setMethod('POST');
        HttpResponse res = h.send(req);

        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');

        return token;
    }

}