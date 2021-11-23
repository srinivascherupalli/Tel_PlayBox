/*
* @Author: Ritika Jaiswal
* @Date : 15 Mar 2019
* @Desc : DTO class for response to a disconnect-request
* @Jira : EDGE-66139 
*/

public class DisconnectOrderResponseDTO{
    
    public Data data;
    public Error error;
    
    //constructor for creating response of a particular type
    public DisconnectOrderResponseDTO(String responseType){
        if(responseType.equalsIgnoreCase('Success'))
            data= new Data();
        else if(responseType.equalsIgnoreCase('Error'))
            error = new Error();
            }
    
    //Inner class for representing data-block in case of success response
    public class Data{
        public String serviceMSISDN;
        public String status;
        public String transactionDate;
        public String correlationID;
    }
    
     //Inner class for representing error-block in case of error response
    public class Error{
        public String status;
        public String code;
        public String message;
        public String correlationID;      
    }
    
    public static DisconnectOrderResponseDTO parse(String json) {
        return (DisconnectOrderResponseDTO) System.JSON.deserialize(json, DisconnectOrderResponseDTO.class);
    }
    
}