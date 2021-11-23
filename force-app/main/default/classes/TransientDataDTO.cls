/********************************************************
Class Name      :   TransientDataDTO
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vaibhav Deshpande     13/04/2020      EDGE-144219 fix
**********************************************************
*/

public with sharing class TransientDataDTO {
    public List<DataDTO> dataDTOList {get;set;}
    public class DataDTO {
        public String offerID {get;set;}
        public String specCode {get;set;}
        public String specGUID {get;set;}
        public String changeType {get;set;} 
        public List<TransientAttribute> attributes {get;set;}
    }
    public class TransientAttribute {
        public String name {get;set;}
        public String value {get;set;}       
    }
    
    public static String parse(List<DataDTO> dataDTOList) {
        return (String) System.JSON.serialize(dataDTOList);
    }
     public static String parse(DataDTO data) {
        return (String) System.JSON.serialize(data);
    }
    public static TransientDataDTO unParse(String json) {
        return (TransientDataDTO) System.JSON.deserialize(json, TransientDataDTO.class);
    }
    public static List<DataDTO> parseDataDTO(String json) { //added method as part of EDGE-144219
        return (List<DataDTO>) System.JSON.deserialize(json, List<DataDTO>.class);
    }
}