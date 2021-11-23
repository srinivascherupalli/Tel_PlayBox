/*
* @Author : Robin/Ritika
* @Date : 5 June 2019
* @Desc : DTO class for TM1EligibilityCheckServiceV2
* @Jira Cloud : EDGE-85155
*/

public with sharing class MobileTransitionTM1DTO {
    public List<transitionsDTO> transitions=new List<transitionsDTO>();
    //Public String Correlation_ID {get;set;}
   
    public class transitionsDTO{
        public String type  {get; set;}
        public PropertiesDTO properties {get; set;}
        public TargetDTO target {get; set;}
    }
    
    public class TargetDTO{
        public String type {get; set;}
    }
    
    public class PropertiesDTO{
        public String identifier {get; set;}
        public String family {get; set;}
        public List<attributesDTO> attributes =new List<attributesDTO>();
    }
    
    public class attributesDTO{
        public String key {get; set;}
        public String value {get; set;}
    }
    
}