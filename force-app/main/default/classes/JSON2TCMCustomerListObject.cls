/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to handle the JSON response object
    INTERFACE:	/v1/customer-self-management/tcm/customer-accounts?abn={abn}&acn={acn}&firstName={firstName}&lastName={lastName}&birthDate={birthdate}&cac={cac}&cidn={cidn}
*/

public class JSON2TCMCustomerListObject {

	@AuraEnabled public JSON2TCMCustomerDataObject[] data {get;set;} 
	
	
	@AuraEnabled
	public static JSON2TCMCustomerListObject parse(String jsonString) {
		JSON2TCMCustomerListObject obj = (JSON2TCMCustomerListObject)JSON.deserialize(jsonString, JSON2TCMCustomerListObject.class);
		return obj;
	}
}