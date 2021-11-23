/**
* @Author   :   Aniket Srivastava
* @Date     :   08 July 2019
* @Desc     :   DTO class for TM callback response
* @US       :   EDGE-94797
* @Status   :   Developemnt
* */

public with sharing class TM2CallbackResponseDTO {
    public String transitionId{get;set;}
    public List<steps> steps {get;set;}

//Inner class 
public class links{
    public String rel;
    public String href;
    
  }

public class steps{
    public String name;
    public String status;
    public List<results> results {get;set;}
}
 

    
public class results{
    public String code;
    public String description;
    public List<links> links {get;set;}
}
    
 
public static TM2CallbackResponseDTO parse(String json) {
        return (TM2CallbackResponseDTO) System.JSON.deserialize(json, TM2CallbackResponseDTO.class);  
}
}