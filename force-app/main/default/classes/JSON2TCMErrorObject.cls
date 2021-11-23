public with sharing class JSON2TCMErrorObject {
	public String status {get;set;}
	public String code {get;set;}
	public String message {get;set;}
	
    public static JSON2TCMErrorObject parse(String jsonString) {

    	JSON2TCMErrorObject o = new JSON2TCMErrorObject();
        Map<String, Object> m = (Map<String, Object>)System.JSON.deserializeUntyped(jsonString);
        
        o.status = String.valueof(m.get('status'));
        o.code = String.valueof(m.get('code'));
        o.message = (String)m.get('message');
        
        return o;
    }
}