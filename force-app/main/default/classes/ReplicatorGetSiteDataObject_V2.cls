/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 06 April 2019
 * Description : Get Site interface's JSON formatted response is deserialize to an instance of ReplicatorGetSiteDataObject_V2 
 * Revision :
 * 
 * *****************************************************************************/

public with sharing class ReplicatorGetSiteDataObject_V2 {
    @AuraEnabled
    public String cidn{get;set;}
    @AuraEnabled
    public String correlationId {get; set;}
  
    @AuraEnabled
    public String Error_Code {get; set;}
    @AuraEnabled
    public String Error_Description {get; set;}     

    
    @AuraEnabled
    public List<addressListDTO> addressList {get; set;}
    
   
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 06 April 2019
 * Description : Sub Class to hold addressList value's of API
 * Revision :
 * 
 * *****************************************************************************/
    public class addressListDTO {
       
        @AuraEnabled
        public String addressType {get; set;}
        @AuraEnabled
        public String addressValue {get; set;}
        @AuraEnabled
        public String replicatorUpdateDateTime {get; set;}
        

        
        
        @AuraEnabled
        public List<addressCharacteristicsDTO> addressCharacteristics {get; set;}
        
    }
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 06 April 2019
 * Description : Sub Class to hold addressCharacteristics value's of API
 * Revision :
 * 
 * *****************************************************************************/
    
     public class addressCharacteristicsDTO {
        @AuraEnabled
        public String name{get; set;}
         
        @AuraEnabled
        public String value{get; set;}
        
    }
    
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 06 April 2019
 * Description : Method to parse json 
 * Parameter : String of json
 * 
 * *****************************************************************************/
    public static ReplicatorGetSiteDataObject_V2 parse(String json) {
        return (ReplicatorGetSiteDataObject_V2) System.JSON.deserialize(json, ReplicatorGetSiteDataObject_V2.class);
    }
}