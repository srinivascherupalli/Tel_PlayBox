/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to handle the JSON response object
    INTERFACE:	/v1/customer-self-management/tcm/contacts?firstName={firstName}&lastName={lastName}&birthDate={birthdate}&emailAddress={emailAddress}&include=customer-accounts
*/

public class JSON2TCMContactObject {
    @AuraEnabled public List<JSON2TCMContactDataObject> data  {get;set;}

    @AuraEnabled
    public static JSON2TCMContactObject parse(String jsonString) {
        String str = jsonString.replace('"number":', '"id_number":');
        return (JSON2TCMContactObject) System.JSON.deserialize(str, JSON2TCMContactObject.class);
    }
}