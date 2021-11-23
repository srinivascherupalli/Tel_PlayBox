/*
* @Author : Ritika Jaiswal
* @Date : 15 Mar 2019
* @Desc : REST API for TRAMAS to call when it receives a port-out request. 
* @Jira : EDGE - 66139 REST API for Disconnect Request
*/

@RestResource(urlMapping='/DisconnectUtil/*')
global with sharing class REST_DisconnectOrderServiceUtil{    
    
    @HttpPost
    global static void doPost(){
        RestRequest request = RestContext.request;
        DisconnectOrderHandler handler= new DisconnectOrderHandler ();
        DisconnectOrderRequestDTO createRequest ; 
        try{
            String reqBody = request.requestBody.toString();
            system.debug('***Telstra: DisconnectUtil reqBody: '+ reqBody);
            createRequest = DisconnectOrderRequestDTO.parse(reqBody);
            system.debug('***Telstra: DisconnectUtil valueofCreateRequest : '+createRequest.data );    
            handler.getSubcriptionDetailsForDisconnectRequest(createRequest );       
        }
        catch(Exception e){
            System.debug('***Telstra: DisconnectUtil: '+ e.getMessage());
            handler.setResponse(true,'FAILURE', '500', 'BAD_REQUEST', createRequest.Data.correlationID , '' );       
        }
    }
}