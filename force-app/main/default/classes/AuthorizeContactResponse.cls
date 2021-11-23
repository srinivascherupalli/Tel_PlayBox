/*

author: nagu <nagaraja_sr@infosys.com>

represents the response object for AuthorizeContactForAccount API
automatically serialized to JSON by Apex REST API Framework

*/

global with sharing class AuthorizeContactResponse extends OnlineOrderingResponse {
    
    public AuthorizeContactResponse(APIConstants.AUTHORIZE_CONTACT_STATUS status, String code, Boolean isError) {
        this.status = status;
        this.code = code;
        this.isError = isError;
        this.message = AuthorizeContactForAccountErrorCodes.getErrorMessage(code);
    }
    
    public AuthorizeContactResponse(APIConstants.AUTHORIZE_CONTACT_STATUS status, String code) {
        this.status = status;
        this.code = code;
        this.isError = false; // success response
        this.message = AuthorizeContactForAccountErrorCodes.getErrorMessage(code);
    }
    
    public APIConstants.AUTHORIZE_CONTACT_STATUS status { get; set; }
    public String AccountId { get; set; }
    public String ContactId { get; set; }
    
}