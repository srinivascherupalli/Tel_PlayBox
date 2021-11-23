/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to handle the JSON response object
    INTERFACE:	/v1/customer-self-management/tcm/contacts/{id}?include=customer-accounts
*/

public class JSON2TCMContactCustomerObject {
    
    @AuraEnabled public JSON2TCMContactDataObject data {get;set;}
	
    @AuraEnabled
	public static JSON2TCMContactCustomerObject parse(String jsonString) {
		String str = jsonString.replace('"number":', '"id_number":');
		return (JSON2TCMContactCustomerObject) System.JSON.deserialize(str, JSON2TCMContactCustomerObject.class);
	}
}