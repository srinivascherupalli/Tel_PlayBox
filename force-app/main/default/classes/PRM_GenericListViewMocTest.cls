/*********** 
 * Team : Hawaii
 * Description : Mock response to get query key value.
 * Jira : 
 * Created Date : 09 Feb 2021
*****************/
@isTest
public class PRM_GenericListViewMocTest implements HTTPCalloutMock{
    // Creating a fake response
    public HTTPResponse respond(HTTPRequest request) {
        HTTPResponse response = new HTTPResponse();
        // Setting the response body
        response.setBody('{"query" : "SELECT Name, Account.Name, toLabel(StageName), CloseDate, Amount, Top_Priority__c, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, Account.Id, AccountId, Account.RecordTypeId FROM Opportunity USING SCOPE mine ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST"}');
        // Setting the response header
        response.setHeader('Content-Type', 'application/json');
        // Setting the response code
        response.setStatusCode(200);
        // Returning the response
        return response;
    }
}