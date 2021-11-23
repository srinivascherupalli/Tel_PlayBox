/*
* @Author Robin Chawla
* @Date : 10 May 2019
* @Desc : Json coming from Tramas is parsed in this class 
* @Jira : EDGE-80464 TM1 Eligibility - Additional logic to determine Eligibility based on response received from TRAMAS
*/

public with sharing class TramasDataObject {
    
    //public String Correlation_ID {get; set;} 
    
    //public String UUID {get; set;} 
    
    Public List<Discovered_Objects> Discovered_Objects{get;set;}
    
    Public Class Discovered_Objects{
        
        Public String Product_Technology_Family{get;set;}   
        Public String Eligible{get;set;}
        Public String PIID{get;set;}
        Public List<String> Reason{get;set;}
        Public Map<String,String> Characteristics_Of_Interest{get;set;}
        //Public Map<String,String> List_of_Relationships{get;set;}
        public List<Map<String,String>>List_of_Relationships{get;set;}
        
    }
    
    
    
    public static TramasDataObject parse(String json) {
        System.debug('Reached here');
        return (TramasDataObject) System.JSON.deserialize(json, TramasDataObject.class);
    } 
}