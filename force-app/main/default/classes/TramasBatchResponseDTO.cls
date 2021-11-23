/*
* @Author : Rahul Asarma
* @Date : 06 NOV 2019
* @Desc : DTO class for Batch Tramas response
* @Jira : EDGE-92541
1. ankit EDGE-101034  added one attribute
*/

public class TramasBatchResponseDTO{
  
    
    
   public oprt operations{get;set;}
   
   public class oprt {
     //public list<datalstdto> data= new list<datalstdto>();
     public list<datalstdto> data;
   }
   
   public class datalstdto{
     public outpt output{get;set;}
   }
   
   public class outpt {
      public string transitionId{get;set;}
      //public list<transitionlstdto> transitions= new list<transitionlstdto>();
      public list<transitionlstdto> transitions;
     }
     
    public class transitionlstdto{
      public prt properties{get;set;}
      
     }
     
     public class prt{
     // public list<identifierlstdto> identifiers = new list<identifierlstdto>();
      public list<identifierlstdto> identifiers;
      public string family{get;set;} //EDGE-101034
     }
     
     public class identifierlstdto{
      public string identifier{get;set;}
     }
     
     public static TramasBatchResponseDTO parse(String json) {
        return (TramasBatchResponseDTO) System.JSON.deserialize(json, TramasBatchResponseDTO.class);  
     }
 
}