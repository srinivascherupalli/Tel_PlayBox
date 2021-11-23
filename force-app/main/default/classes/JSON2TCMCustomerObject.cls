/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to handle the JSON response object
    INTERFACE:	/v1/customer-self-management/tcm/customer-accounts/{id}
*/

public class JSON2TCMCustomerObject {
	
	@AuraEnabled public JSON2TCMCustomerDataObject data {get;set;}  

	@AuraEnabled
	public static JSON2TCMCustomerObject parse(String input) {
		JSON2TCMCustomerObject obj = (JSON2TCMCustomerObject)JSON.deserialize(input, JSON2TCMCustomerObject.class);
		return obj;
	}
}