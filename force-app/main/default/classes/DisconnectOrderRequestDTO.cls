/*
* @Author : Ritika Jaiswal
* @Date : 15 Mar 2019
* @Desc : DTO class for Disconnect Request 
* @Jira : EDGE-66139 
*/

public class DisconnectOrderRequestDTO{
public Data data{get;set;}

//Inner class that represents the request-body
public class Data{
    public String serviceMSISDN{get;set;}
    public String originatingSystem{get;set;}
    //Request Reason from TRAMAS's request 
    public String requestReason{get;set;}
    public String requestedDate{get;set;}
    public String correlationID{get;set;}
    public String subscriptionID{get;set;} //EDGE-76399 changed subscriptionNumber to subscriptionID
    }

public static DisconnectOrderRequestDTO parse(String json) {
        return (DisconnectOrderRequestDTO) System.JSON.deserialize(json, DisconnectOrderRequestDTO.class);
    }

}