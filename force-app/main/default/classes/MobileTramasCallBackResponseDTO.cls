/*
* @Author Rahul Asarma
* @Date : 26 July 2019
* @Desc : Json coming from Callback Response of Failled Individual Numbers.
* @Jira : EDGE-85161 want to reserve the numbers being transition once a Contract is accepted So that I can ensure a clean ticket of work.
*/
Public with sharing class MobileTramasCallBackResponseDTO {
 
 Public String identifier{get; set;}
 Public String state{get; set;} //Edge-EDGE-207443
 public String transitionId{get;set;} //EDGE-203022
 Public validationDto validation{get; set;}
 public Error error;
    
 public class validationDto {
     
     public String status{get;set;}
    public List<resultsdto>results{get;set;}
 }
 
 public class resultsdto{
   public String code{get;set;}//EDGE-198276/202815
   public String description{get;set;}
 }
 
public class Error {
        public String code;
        public String message;
        public String details;
        public String timestamp;
}
 public static MobileTramasCallBackResponseDTO parse(String json) {
        System.debug('Reached here');
        return (MobileTramasCallBackResponseDTO ) System.JSON.deserialize(json, MobileTramasCallBackResponseDTO.class);
    } 
}