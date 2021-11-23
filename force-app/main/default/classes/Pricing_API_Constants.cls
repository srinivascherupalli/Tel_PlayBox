/***********************************************************************************************************
Class Name : Pricing_API_Constants
Description : Defined all API response codes in constant variables
Created By : Team Nirvana
User Story : DIGI-32339,DIGI-16483,DIGI-16567
************************************************************************************************************/

public class Pricing_API_Constants {


    //If Request is not valid
    public static final String  INVALID_REQUEST= 'Invalid Request';
    public static final String MISSING_REQ_ATTRIBUTES = 'One or more Mandatory parameters are missing';

    //Bad Request
    public static final String  BAD_REQUEST   = 'Bad Request';

    //Error
    public static final String  ERROR = 'Error';

    //Request is Null
    public static final String  REQ_IS_NULL = 'Request is null';
    
    //The request couldn’t be understood, usually, because the JSON or XML body contains an error.
    public static final String  ERROR_CODE_400 = '400'; // 400 - INVALID_ID_FIELD
    public static final String  ERROR_CIDN = 'Customer not found or doesn’t exist';

    //The requested resource couldn’t be found. Check the URI for errors, and verify that there are no sharing issues.
    public static final String  ERROR_CODE_404 = '404';

    //“OK” success code with a response.
    public static final String  SUCCESS_CODE_200 = '200';

    //An error has occurred within Lightning Platform, so the request couldn’t be completed. Contact Salesforce Customer Support.
    public static final String  INVALID_REQUEST_500 = '500';

    //The entity in the request is in a format that’s not supported by the specified method.
    public static final String  INVALID_REQUEST_FORMAT_415 = '415';

    //The request has been refused. Verify that the logged-in user has appropriate permissions. If the error code is REQUEST_LIMIT_EXCEEDED, you’ve exceeded API request limits in your org.
    public static final String  INVALID_USER_PERMISSION_403 = '403';

    //The session ID or OAuth token used has expired or is invalid. The response body contains the message and errorCode.
    public static final String  INVALID_TOKEN_401 = '401';

    //public static final String PRODUCT_CODE_NOTFOUND = 'Product code is invalid or doesn’t exist';
    public static final String ERROR_PRODCODE = 'Product code is invalid or doesn’t exist';

    public static final String INVALID_OFFER_NAME = 'Offer id is invalid';
    public static final String INVALID_ID_FIELD = 'INVALID_ID_FIELD';

    

    
}