/**================================================================
 * Appirio, Inc
 * Name: Orchestration_CallOutResponse
 * Description: This class is use to store HTTP response of callout
 * Created Date: June 11, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/
public with sharing class Orchestration_CallOutResponse {
    //To store the callout related object id related to step
    public String recordId;
    //To store the request payload
    public String reqBody;
    //To store the callout response
    public String responseBody;
    //To store callout response status code
    public String statusCode;
    //To store the OAUTH Token Handler
    public String loggerName;
    //To store debug level
    public String debugLevel;
    //To store error type - OAUTH or callout
    public String errorCategory;
    //To store unique id
    public String correlationId;
    //To store error response status code
    public String errorCode;
    //To store current time stamp
    public DateTime currentStamp;
    //To store logged in user Id
    public String usrId;
    //To store Status code
    public String httpCode;
    //To store time taken by request and response
    public Long requestTime;
    //To store request method - GET or POST
    public String requestMethod;
    //To store exception - stack trace
    public String stackTrace;
    /** --Not in use-- **/
    public String errorDesc;
    public String cac;
    public String uuid;
    public String errorType;
    public String eventType;

    public Orchestration_CallOutResponse(String recordId, String reqBody, String responseBody, String statusCode, String loggerName, String debugLevel, String errorCategory, String correlationId, String errorCode, Long requestTime, String requestMethod) {
        this.recordId = recordId;
        this.reqBody = reqBody;
        this.responseBody = responseBody;
        this.statusCode = statusCode;
        this.loggerName = loggerName;
        this.debugLevel = debugLevel;
        this.errorCategory = errorCategory;
        this.correlationId = correlationId;
        this.errorCode = errorCode;
        this.currentStamp = System.now();
        this.usrId = UserInfo.getUserId();
        this.httpCode = statusCode;
        this.requestTime = requestTime;
        this.requestMethod = requestMethod;
    }

    public Orchestration_CallOutResponse(String recordId, String reqBody, String responseBody, String statusCode, String loggerName, String debugLevel, 
                                            String errorCategory, String correlationId, String errorCode, Long requestTime, String requestMethod, String uuid, String errorDesc) {
        this.recordId = recordId;
        this.reqBody = reqBody;
        this.responseBody = responseBody;
        this.statusCode = statusCode;
        this.loggerName = loggerName;
        this.debugLevel = debugLevel;
        this.errorCategory = errorCategory;
        this.correlationId = correlationId;
        this.errorCode = errorCode;
        this.currentStamp = System.now();
        this.usrId = UserInfo.getUserId();
        this.httpCode = statusCode;
        this.requestTime = requestTime;
        this.requestMethod = requestMethod;
        this.uuid = uuid;
        this.errorDesc = errorDesc;
    }
}