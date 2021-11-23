/**
* @Description : Future Callout for GetContactInfo.
* @Author : Anu Yadav
* @Date : 21/11/2017
* @Story : EDGE-34
*/
public class TCMGetContactFuture {
    public void futureCalloutAccount(Account acc, String sourceInterface){
        System.debug('TCMGetContactInfo - Creating Contact for : ' + acc.CIDN__c);
        List<Contact> Contacts = [Select Id, Name, AccountId,UUID__c from Contact where AccountId =:acc.Id];
        List<String> ContactUUIDs = new List<String>();
        for(Contact c : Contacts){
            ContactUUIDs.add(c.UUID__c);
        }
        if(!ContactUUIDs.isEmpty()){
            futureCalloutContactUUID(ContactUUIDs, sourceInterface);
        }
    }
    
    public void futureCalloutContactUUID(List<String> uuids, String sourceInterface){
        System.debug('TCMGetContactInfo - Future Callout for list of uuids: '+uuids);
        List<String> validUUIDs = new List<String>();
        List<Contact> contacts = [Select Id, Name,UUID__c from Contact where UUID__c IN : uuids];
        for(Contact c : contacts){
            ValidUUIDs.add(c.UUID__c);
        }
        if(!validUUIDs.isEmpty()){
            futurecallout(ValidUUIDs, sourceInterface); 
        }
    }
    //Future Callout for GetContactInfo
    @future(callout = true)
    public static void futurecallout(List<String> UUIDs, String sourceInterface){
        System.debug('TCMGetContactInfo - Future Callout for list of uuids: '+UUIDs);
        TCMGetContactInfo SearchByContactUUID = new TCMGetContactInfo(sourceInterface);
        SearchByContactUUID.contactUUIDs(UUIDs);
    }
}