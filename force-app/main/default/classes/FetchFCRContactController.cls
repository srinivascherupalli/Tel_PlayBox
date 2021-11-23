/*****************************************************************
@Name: FetchFCRContactController
@Author: Ravi Shankar
@JIRA Reference: EDGE-136074
@CreateDate: 26/02/2019
@Description: This class is used by the screen flow Add Functional Contact Engg Users
******************************************************************/
public without sharing class  FetchFCRContactController{
    @AuraEnabled (cacheable=true)
    public static List<User> fetchContact(String fcrId) {        
        Id partAccId = null;
        List<User> usrLst = new List<User>();
        set<id> fcrConIdSet = new set<id>();
        List<Functional_Contact_Role__c> fcrLst = [select id, SubscriptionID__c, Fulfillment_Task__c, ContactID__r.AccountId 
            from Functional_Contact_Role__c where Id = :fcrId];
        system.debug('fcrLst'+fcrLst);
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
                usrLst = [select id,email,P_Number__c,LastName,FirstName,ContactId,username from user 
                    where Contact.Partner_Role__c INCLUDES ('Engineering User') and Contact.AccountId = :partAccId 
                        and ContactId not IN :fcrConIdSet];
                system.debug('usrLst'+usrLst);
            }
            else{
                usrLst = [select id,email,LastName,FirstName,username,ContactId, Contact.LastName, Contact.FirstName, Contact.email, P_Number__c from user 
                    where Contact.Partner_Role__c INCLUDES ('Engineering User') and Contact.AccountId = :partAccId];
                   system.debug('usrLst1'+usrLst);
            }            
        }
        return usrLst;
    }
    
     @AuraEnabled (cacheable=true)
    public static List<User> getEngineeringUsers(String recid) {        
        Id partAccId = null;
        List<User> usrLst = new List<User>();
        set<id> fcrConIdSet = new set<id>();
        FulfillmentLineItem__c fli = [select id, Ownerid from FulfillmentLineItem__c where Id = :recid];
        system.debug(fli+'*******123*******');
        user u=[select id,contact.accountid from user where id=:fli.Ownerid];
        system.debug(u+'*******321*******');
        if(u!=null){
            partAccId = u.contact.accountid;
           system.debug(partAccId+'*******333321*******');
            if(partAccId!=null){
                usrLst = [select id,email,P_Number__c,LastName,FirstName,ContactId,username from user 
                    where Contact.Partner_Role__c INCLUDES ('Engineering User') and Contact.AccountId = :partAccId];
                system.debug('usrLst'+usrLst);
            }                  
        }
        return usrLst;
    }
    
    @AuraEnabled 
    public static list<string> createPortalEngg(String userids) {
        String resStr = 'An error has occurred. Please check with your administrator.';
        try{    
            system.debug('userids'+userids);
            list<string> lstParam = userids.split('#');
            system.debug('lstParam'+lstParam);
            String selectedContacts = null;
            String fcrId = lstParam[0];
            if(lstParam.size()>1)
                selectedContacts = lstParam[1];
            list<string> conIdLst = new list<string>();
            map<string,user> mpConUser = new map<string,user>();
            string RecordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Engineer').getRecordTypeId();
            list<Functional_Contact_Role__c> fcrRecLst = new list<Functional_Contact_Role__c>();
            Functional_Contact_Role__c fcrRec;
            if(!string.isBlank(fcrId) && !string.isBlank(selectedContacts)){
                conIdLst = selectedContacts.split(',');
                system.debug('conIdLst::::'+conIdLst);
                list<Functional_Contact_Role__c> fcrLst = [select id, SubscriptionID__c, ContactID__c, ContactID__r.AccountId,
                    Partner_User__c,Fulfillment_Task__c from Functional_Contact_Role__c where Id = :fcrId];
                if(fcrLst.size()>0){
                    list<user> usrLst = [select id, ContactId from user where id /*ContactId*/ IN :conIdLst];
                    for(user u :usrLst){
                        mpConUser.put(u.id /*ContactId*/, u);
                    }
                    for(string c :conIdLst){
                        fcrRec = new Functional_Contact_Role__c();
                        fcrRec.recordtypeid = RecordTypeId;
                        fcrRec.SubscriptionID__c = fcrLst[0].SubscriptionID__c;
                        fcrRec.Fulfillment_Task__c = fcrLst[0].Fulfillment_Task__c;
                        fcrRec.Role_Type__c = 'Subscription';
                        fcrRec.Role__c = 'Engineering User';
                        fcrRec.ContactID__c = mpConUser.get(c).ContactId;
                        fcrRec.Partner_User__c =c; // mpConUser.get(c);
                        fcrRecLst.add(fcrRec);
                    }
                    insert fcrRecLst;
                    resStr = 'Users are added successfully';
                }
            }
            else
                resStr = 'Please select atleast one user';
        }
        catch(exception e){            
            system.debug('Error in FetchFCRContactController class createPortalEngg method::'+e.getMessage());
        }
        return new list<string>{resStr};
    }
      /**
     *  EDGE-140596  
     * Description:  Update Owner of fulfilement task based on selection
     **/
    
     @AuraEnabled 
    public static list<string> ReassignTask(String userids,String fcrid,String source) {
        String resStr = 'An error has occurred. Please check with your administrator.';
        try{    
            list<string> lstParam = userids.split('#');
            String selectedContacts = null;
			String RectypeId_Portal_Engineer = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Engineer').getRecordTypeId();
			list<string> conIdLst = new list<string>();

            id fliid = lstParam[0];
            if(lstParam.size()>1)
                selectedContacts = lstParam[1];
            
            if(!string.isBlank(fliid) && !string.isBlank(selectedContacts)){
                conIdLst = selectedContacts.split(',');
            	if(fliid!=null && fliid.getSObjectType().getDescribe().getName()=='FulfillmentLineItem__c'){
                    	system.debug('Hi '+conIdLst[0]);
						FulfillmentLineItem__c fli= new FulfillmentLineItem__c(id=fliid,Ownerid=conIdLst[0]);						
						update fli;
                    system.debug(source+'***source***');
						resStr = 'Owner updated successfully';
						system.debug(source+'***source***');
						
				//EDGE-145904: Reassignment of ownership to also add Engineering User to the TC Portal 
                if(source == 'Telstra Collaboration Operations User' || source == 'Engineering User' )
					{
						list<Functional_Contact_Role__c> fcrlist = [select id, SubscriptionID__c, ContactID__c, ContactID__r.AccountId,
						Partner_User__c,Fulfillment_Task__c from Functional_Contact_Role__c where Fulfillment_Task__c=:fliid and Partner_User__c =:conIdLst[0] and recordtypeid=:RectypeId_Portal_Engineer];	
						system.debug('fcrlist'+fcrlist);
						
						if(fcrlist.size()==0){					
						  list<string> engglist=createPortalEngg(fcrid+'#'+selectedContacts);
							system.debug('engglist'+engglist);
							resStr = 'Owner updated successfully';
						
					}
                } 
                //EDGE-145904-End
				}
				
              }
         }          
        
        catch(exception e){            
            system.debug('Error in FetchFCRContactController class ReassignTask method::'+e.getMessage());
        }
        return new list<string>{resStr};
    }
}