/*This class is written to send chatter notificatin when a MAC based contract is created and signed. 
Name              Date          Description
Monali Golhar     19/03/2021    EDGE-202386 to send chatter notificatin when a MAC based contract is created and signed 
*/
public class QuoteAndContractSendChatterPost{
  
    @InvocableMethod
    public static void generateChatterPost(List<dsfs__DocuSign_Recipient_Status__c> dsRecord){
        System.debug('DCSN******************' +dsRecord);
        List<dsfs__DocuSign_Recipient_Status__c> dsList  = [select id ,ContractJunction__r.Id,ContractJunction__r.Customer_Primary_Contact__r.FirstName, ContractJunction__r.Customer_Primary_Contact__r.LastName , dsfs__Account__r.Name ,ContractJunction__r.Contract_Number__c,ContractJunction__r.Related_Opportunity__r.Id, ContractJunction__r.Related_Opportunity__r.ownerId from dsfs__DocuSign_Recipient_Status__c    Where Id =: dsRecord[0].Id ];
        for(dsfs__DocuSign_Recipient_Status__c ag : dsList){
        String fn =  ag.ContractJunction__r.Customer_Primary_Contact__r.FirstName;
        String ln =  ag.ContractJunction__r.Customer_Primary_Contact__r.LastName;
        System.debug('FN' +ag.ContractJunction__r.Customer_Primary_Contact__r.FirstName);
        System.debug('LN' +ag.ContractJunction__r.Customer_Primary_Contact__r.LastName);
        System.debug('Op' +ag.ContractJunction__r.Related_Opportunity__r.ownerId);
        ConnectApiHelper.postFeedItemWithMentions(null, ag.ContractJunction__r.Related_Opportunity__r.OwnerId, 'An update to the Agreement for ' +fn +' '+ ln + '  from  ' + ag.dsfs__Account__r.Name + '  has been executed. You can now access this customer’s latest Order Request {record:' +ag.ContractJunction__r.Id+ '}  ' ); 
        }
    }     
}