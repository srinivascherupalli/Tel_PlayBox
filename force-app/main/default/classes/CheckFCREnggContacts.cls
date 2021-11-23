/*****************************************************************
@Name: CheckFCREnggContacts
@Author: Ravi Shankar
@JIRA Reference: EDGE-136074
@CreateDate: 27/02/2019
@Description: This is used by Add Users Button for Portam Admins
******************************************************************/
public class CheckFCREnggContacts {
    @InvocableMethod
    public static List<String> checkContactsExist(List<String> fcrId) {  
        List<String> resStr = new List<String>();
        Id partAccId = null;
        List<User> usrLst = new List<User>();
        set<id> fcrConIdSet = new set<id>();
        List<Functional_Contact_Role__c> fcrLst = [select id, SubscriptionID__c, Fulfillment_Task__c, ContactID__r.AccountId 
            from Functional_Contact_Role__c where Id = :fcrId];
        if(fcrLst.size()>0){
            partAccId = fcrLst[0].ContactID__r.AccountId;
            List<Functional_Contact_Role__c> fcrEngLst = [select id, SubscriptionID__c, ContactID__c, Fulfillment_Task__c 
                from Functional_Contact_Role__c 
                where recordtype.developername = :'Portal_Engineer' and SubscriptionID__c = :fcrLst[0].SubscriptionID__c 
                and Fulfillment_Task__c = :fcrLst[0].Fulfillment_Task__c];
            for(Functional_Contact_Role__c fcr :fcrEngLst){
                fcrConIdSet.add(fcr.ContactID__c);
            }
            if(fcrConIdSet.size()>0){
                usrLst = [select id, username, ContactId, Contact.LastName, Contact.FirstName, Contact.email, P_Number__c from user 
                    where Contact.Partner_Role__c INCLUDES ('Engineering User') and Contact.AccountId = :partAccId 
                        and ContactId not IN :fcrConIdSet];
            }
            else{
                usrLst = [select id, username, ContactId, Contact.LastName, Contact.FirstName, Contact.email, P_Number__c from user 
                    where Contact.Partner_Role__c INCLUDES ('Engineering User') and Contact.AccountId = :partAccId];
            }            
        }
        if(usrLst.size()>0){
            resStr.add('Yes');
        }            
        else{
            resStr.add('No');
        }
        return resStr;
    }
}