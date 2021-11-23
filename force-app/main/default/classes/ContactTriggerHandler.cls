/*
*AUTHOR : Vineeth Batreddy/Shambo Ray/Anu Yadav
*DESCRIPTION : This class handles the invocations from Contact Trigger
*EDITED: 05/02/2018  by Shambo Ray STORY :EDGE-38 
*EDITED: 03/27/2019  by Sri for Sprint 19.04 , EDGE-69468 
*EDITED: 15/06/2020  by Sri for Sprint 20.08 , P2OB-6850.
*EDITED: 04/22/2020  by Sri for Sprint 20.15 , P2OB-9604 :: Removed updateSalesContactStatus method call
*EDITED: 25th Nov, 2020 by Amar Chakka for Sprint 20.16, P2OB-9994:: Removed UpdateTelstraConnectAdmin
*EDITED: 08/16/2021, by Chhaveel from SFO for Sprint 21.11, DIGI-4057 P2OB-15009
*EDITED: 06/10/2021, by pallavi from Team SFO sprint 21.14, DIGI-4062 
*EDITED: 18/10/2021, by Sri from Team SFO sprint 21.14, DIGI-3444 
*/

/*
 * Modified By : Team Hawaii
 * Date : 3/6/2020
 * Jira : P2OB-6527 & P2OB-6037
 * Description : Remove call to this method 'ContactTriggerHelperPRM.UpdateUserToSuperUser(newList,newMap,oldMap)' from prmLogicAfterUpdate method as logic is moved 
 *               to process builder for this functionality and called method is deleted from ContactTriggerHelperPRM class
 * Updates :
 * 1. 07-09-2020 : Team Hawaii : P2OB-7962 : Commented call to ContactTriggerHelperPRM.updatePartnerRole from method prmLogicAfterUpdate

*/
/*
 * Modified By : Team Lisbon
 * Date : 22/10/2020
 * Jira : P2OB-9530 
 * Description : making changes in After update trigger hander of Contact and AccountContactRelation Object. 
				 So that specific field update for this object will trigger CustomerMS event. To Monitor Fields we have 
				 created CustomMetadata.Utility Class check Update against specific Field: FieldUpdateIdentifier

 * Updates : List of test classes that gave coverage to  ContactTriggerHandler:

		AccountContactRelationshipTRGTest
		AccountLOCROUCalculationTest
		AccountsOpportunityUpdatesTest
		AccountTriggerTest
		ContactTriggerTest
		ManageContactTest
		TCMCustomerHandlerQueueableTest
*/
public without sharing class ContactTriggerHandler {
    /*private static Boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }*/
    
    public static List<Contact> contacts {get;set;}
    public static boolean stopRecursiveAfterInsert = false;
    private static Boolean manageEventSent = false;
    private IntegrationSettings__c iSettings = null;
    private UpdateContactOwner updateContactOwn = null;
    public ContactTriggerHelper conTriggerHelper = null;//EDGE-27948
    Interface_Activation__c iActivation = null;

    // Using in calculateLOC to get ContactId's and values assign in getAccountContactIdsForCalculateLOC
    private static Set<Id> locAccountIds = new Set<Id>();
    // Using in calculateLOC to get AccountId's and values assign in getAccountContactIdsForCalculateLOC
    private static Set<Id> locContactIds = new Set<Id>();
    public static boolean stopRecursiveAfterupdate = false;
    //Using in updateContactFields in ContactTriggerHelper class to handle recursive 
    public static Boolean isFirstTime = true;
    public static boolean recursiveCheckForAddress = false; //SFO 20.05, P2OB-4924
    private static boolean stopRecursiveBeforeInsert=false;
    public static boolean stopRecursiveBeforeUpdate=false;
    public ContactTriggerHandler(){
        iSettings = IntegrationSettings__c.getOrgDefaults();
        updateContactOwn = new UpdateContactOwner();
        conTriggerHelper = new ContactTriggerHelper();//EDGE-27948
        iActivation = Interface_Activation__c.getValues(Label.Process_Builder); //EDGE-68099 Removed Hard Coding
    }
    
    public void onBeforeInsert(List<Contact> newContactList){
        // below logic for update field values before insert, so skipped for including in Recursive : comment added in SFO 20.05
        if(iActivation!=null && iActivation.Status__c){
            conTriggerHelper.markContactAsVerified(newContactList);//EDGE-27948
        }
        conTriggerHelper.updateContactFields(newContactList, null); //Sprint 20.03,Team SFO,Added as per the User Story P2OB-4875
        // above logic for update field values before insert, so skipped for including in Recursive : comment added in SFO 20.05
        
         //Added as part of DIGI-4062 Sprint 21.14 Team SFO 
         conTriggerHelper.duplicateCheckOnInvoiceNotification(null, newContactList);

        // SFO: Recursive check  added in 20.05 to resolve SOQL 101 issues everytime
        if(!stopRecursiveBeforeInsert){
            conTriggerHelper.setOnboardingStatus(newContactList);//EDGE-27948
            //updateContactOwn.updateContactOwnerBeforeInsert(newContactList);  // Sprint 19.04 ,Team SFO ,Commented as per the User Story EDGE-69468
            
            //conTriggerHelper.updateRelationShipEndDate(newContactList);            
            /* Sprint 20.03 ,Team SFO ,Commented as per the User Story P2OB-4916
                conTriggerHelper.mandatoryEmailForMandatoryContact(newContactList);
                conTriggerHelper.addressMandatoryForDiamondMember(newContactList);
                */
            //SFO 20.05 P2OB-4924 
            conTriggerHelper.updateConOfficeAddress(null, newContactList, null);
        }
        stopRecursiveBeforeInsert=true;
    }
    
    public void onAfterInsert(List<Contact> newContactList,Map<Id,contact> newMap){
        if(!stopRecursiveAfterInsert){  // Nirvana Production Fix Case Number : 00018544
        if(!EnvironmentalSettings.isSeedingEnabled()){
            //changeAccountOwner(newContactList,newMap);
            List<Contact> conList = filterPRMContacts(newContactList);//EDGE-150897
            if(conList.size()>0){
                publishCreateEvents(conList, EventConstants.CREATE_OPERATION);
            }
            if(iSettings!=null && iSettings.EnableManageInterfaces__c){
                manageContact(); 
            }
            if(AccountTriggerHelper.isLOCROUCalculationRequired()){
                //     conTriggerHelper.setOnboardingStatus(newMap.keyset());
            }
        }
            conTriggerHelper.updateContactOfficeAddress(newContactList);
      }
      stopRecursiveAfterInsert = true;
    }
    
    public void sendManageEvent(List<ManageContactDAO> manageContacts){
        if(!manageContacts.isEmpty() && !Test.isRunningTest()){
            sendManageContacts(manageContacts);    
        }
    }
    
    //Sprint 19.17, P2OB-4310 (splited because of Cyclometric Issues)
    public void onAfterUpdate(List<Contact> newList,Map<Id,contact> newMap,Map<Id,contact> oldMap){
        if(!stopRecursiveAfterupdate){
            stopRecursiveAfterupdate=true;
            if(!EnvironmentalSettings.isSeedingEnabled()){
                nonPRMLogicAfterUpdate(newList,newMap,oldMap);
            }  
            prmLogicAfterUpdate(newList,newMap,oldMap);
        }
        //Testing only need to remove below 2 lines
       // system.debug('Testingggggg Handler');
       // DataReplicationbtwConAndACR dr = new DataReplicationbtwConAndACR();
       // dr.copyFromConToACR(oldMap, newList);
        
    }
    
    /*
    This Method Calling in onAfterUpdate(List<Contact> newList,Map<Id,contact> newMap,Map<Id,contact> oldMap)  Method 
    to call the non PRM logic which is run after Updating the list of Contacts.
    In Future Any NoN-PRM logic should be place in this method Only.
    Sprint 19.17, P2OB-4310 (splited because of Cyclometric Issues)
    */
    private void nonPRMLogicAfterUpdate(List<Contact> newList,Map<Id,contact> newMap,Map<Id,contact> oldMap){
    /*if(ContactTriggerHandler.runOnce()){
    changeAccountOwner(newList,newMap);
    }*/

        List<Contact> conList = filterPRMContacts(newList);//EDGE-150897
            //P2OB-9530 : CustomerMS event for only for specific field Update
                List<Contact> CustomerMSconList = new List<Contact>();
                Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner_Contact').getRecordTypeId();
            
        if(conList.size()>0){
                FieldUpdateIdentifier fui = new FieldUpdateIdentifier(Contact.SobjectType,Label.CustomerMS_Integration);
                Map<id, sobject> matches = fui.identifyUpdatesToMonitoredFields(newMap, oldMap);
                system.debug('Match Contact Record :'+matches);             
    			// CustomerMS Event will trigger for all valid Partner Contact , For Non Partner Contact only when Monitored fields Updated. 
                for(contact c:conList){              
                    if(c.RecordTypeId != null && c.RecordTypeId == recordTypeId){
                            CustomerMSconList.add(c);
                    }
                    else{
                            if(matches.containsKey(c.Id)){
                                CustomerMSconList.add(c);                        
                            }
        }
                }
                
                System.debug('ContactTriggerHandler - identifyFieldUpdates');
                if(CustomerMSconList!=null && !CustomerMSconList.isEmpty()){
                    System.debug('ContactTriggerHandler - identifyFieldUpdates, CustomerMS field updated event will be triggered'); 
                    publishCreateEvents(CustomerMSconList, EventConstants.UPDATE_OPERATION);
                }
			
        }

        if(AccountTriggerHelper.isLOCROUCalculationRequired()){
            calculateLOC();//EDGE-60
            contactNameConcatenation();//EDGE-42
        }
        if(system.isBatch() == false && system.isFuture() == false){
            PhoenixGlobalUtil.assignPermissionset(newMap,oldMap,label.PRM_PARTNER_ACTIVE_PERMMISIONSETS); //EDGE-13148
        }        
        //EDGE-9769, Shambo : Condition check for ACR of contacts
        if(iSettings!=null && iSettings.EnableManageInterfaces__c &&  roleCheckForACR(oldMap)){
            //Edge-38, Shambo : Manage Invocation
            identifyFieldUpdates(newMap,oldMap);  
        }
    }
    /*
    This Method Calling in onAfterUpdate(List<Contact> newList,Map<Id,contact> newMap,Map<Id,contact> oldMap)  Method 
    to call the  PRM logic which is run after Updating the list of Contacts. In Future Any PRM logic should be place in this method Only.
    Sprint 19.17, P2OB-4310 (splited because of Cyclometric Issues)
    */
    private void prmLogicAfterUpdate(List<Contact> newList,Map<Id,contact> newMap,Map<Id,contact> oldMap){
        //EDGE-74065-Updated user as Super user if Partner role is Sales Manager.
        
        if(StaticUtilForRecursion.runOnceContactRoleupdate()) //EDGE-74065To avoid recursion as of user updates will again trigger contact update
        {
         List<Id> conIdList = new List<Id>();
         for(contact con:newList){ 
             conIdList.add(con.id);
         }
         ContactTriggerHelperPRM.freezeUnfreezeUser(conIdList,newMap,oldMap); 
         //PRMFreezePartnerUser.unfreezeUsers(conIdList);
         //09-09-2020 : P2OB-7962 - Call commented as functionality is handled vis flow 'PRM_Manage_User_Onboarding'
         //ContactTriggerHelperPRM.updatePartnerRole(newList,newMap); 
        }
    }
    
        
    //EDGE-9769, Shambo : Condition check for ACR of contacts
    public void sendManageEvent(String event, List<Contact> manageContactEventList){
        List<ManageContactDAO> manageContacts = new List<ManageContactDAO>();
        for(Contact createContactInTCM : manageContactEventList){
            manageContacts.add(new ManageContactDAO(createContactInTCM,event));
        }
        System.debug('Event : ' + event + ', size : ' + manageContacts.size());
        if(!manageContacts.isEmpty() && !Test.isRunningTest()){
            sendManageContacts(manageContacts);    
        }
    }
    
    public static Boolean roleCheckForACR(Map<Id,Contact> oldMap){
        Boolean flag=false;
        List<AccountContactRelation> acrList=[SELECT id,roles FROM AccountContactRelation WHERE contactid in : oldMap.keySet() and IsDirect =true ];
        if(acrList!=null  && !acrList.isEmpty() &&  acrList[0].Roles!=null && !acrList[0].Roles.contains(Label.ACR_Role_Non_Authorised)){ //EDGE-68099 Removed Hard Coding
            flag=true;
        }
        system.debug('ContactTriggerHandler - roleCheckForACR - flag value --'+flag);
        return flag; 
    }
    
    //EDGE-38, Shambo : calling field update method from handler for manage invocation
    public static void identifyFieldUpdates(Map<Id,Contact> newMap,Map<Id,Contact> oldMap){
        FieldUpdateIdentifier fui = new FieldUpdateIdentifier(Contact.SobjectType);
        Interface_Activation__c iActivation = Interface_Activation__c.getValues(Label.Manage_Contact); //EDGE-68099 Removed Hard Coding
        IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
        Map<id, sobject> matches=null;
        if(iSettings!=null && iActivation!=null && iActivation.Status__c && System.UserInfo.getUserName() != iSettings.Integration_API_User__c && !ContactAddressRelationshipTriggerHelper.hasManageFiredFromContactAddress){
            matches = fui.identifyUpdatesToMonitoredFields(newMap, oldMap);
        }
       System.debug('ContactTriggerHandler - identifyFieldUpdates');
        if(matches!=null && !matches.isEmpty()){
            System.debug('ContactTriggerHandler - identifyFieldUpdates, tcm field updated manage will be triggered'); 
            manageContact();
        }
    }
    /* //EDGE-13739 :: Change Contact Owner According it's Parent Account 
    public void changeAccountOwner(List<Contact> newList,Map<Id,Contact> newMap){
        List<Id> accountidList=new List<Id> ();
        List<Id> contactIdList=new List<Id> ();
        List<Contact> contactSaveList=new List<Contact> ();
        Map<Id,Id> accountToOwnerMap=new Map<Id,Id>();
        for(Contact cons:newList){
            accountidList.add(cons.accountId);
            contactIdList.add(cons.id);
        }
        List<Account> accountList=getAccount(accountidList);
        if(!accountList.isEmpty()){
            for(Account acc:accountList){
        accountToOwnerMap.put(acc.Id,acc.ownerId);
            }
        }
        List<Contact> contactList=getContact(contactIdList);
        if(!contactList.isEmpty()){
            for(Contact cons:contactList){  
                if(!cons.AccountContactRelations.isEmpty() && cons.AccountContactRelations.size()==1 && accountToOwnerMap.get(newMap.get(cons.Id).AccountId)!=Null){
                    cons.OwnerId=accountToOwnerMap.get(newMap.get(cons.Id).AccountId);
                    contactSaveList.add(cons);
                }
            }
        }
        System.debug('ContactTriggerHandler.changeAccountOwner----method----conList---'+contactSaveList);
        if(contactSaveList!=null && contactSaveList.size()>0 && Schema.sObjectType.Contact.isUpdateable()){
            update contactSaveList;
        }
    }
    //Getting Account And Acrs from this Method
    private List<Account> getAccount(List<Id> accountIdList){
        return [SELECT id,ownerId FROM Account WHERE id IN:accountidList];
    }
    //Geting Contacts FROM this method as operation on Trigger.old and Trigger.new is prohibited in after Triggerss
    private List<Contact> getContact(List<Id> contactIdList){
        return [SELECT id,ownerId,(SELECT id FROM AccountContactRelations) FROM Contact WHERE id IN:contactIdList];
    }
    */
    
    public static void manageContact(){
        System.debug('!@#$% ContactTriggerHandler.ManagerContact() is invoked');
        IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
        Interface_Activation__c iActivation = Interface_Activation__c.getValues(Label.Manage_Contact); //EDGE-68099 Removed Hard Coding
        List<ManageContactDAO> manageContact = new List<ManageContactDAO>();
        String event=null;
        contacts = Trigger.new;
        system.debug('!@#$% contacts'+contacts);
        Set<String> types =  new Set<String>{'Advocate','3rd Party','Asset User','Billing Contact','Full Authority','Legal Lessee', 'Limited Authority' , 'Nominated Serv Cust','Non-Authorised'};
            
        // START SOQL Query  replace from for-Loop Sprint 19.11 Story-99887
        Set<Id> conIdList = new Set<Id>();
        Set<Id> accIdList = new Set<Id>();
        
        for(Contact con : contacts){
            conIdList.add(con.Id);
            accIdList.add(con.AccountId);
        }
        
        Map<String, AccountContactRelation> mapOfKeyToACR = new Map<String, AccountContactRelation>();
        for(AccountContactRelation acr : [Select id, contactid, AccountId,Contact_Type__c,Contact_Usage__c,Composite_Key__c,Relationship_End_Date__c,Roles  from AccountContactRelation where ContactId IN : conIdList AND AccountId IN : accIdList]){
            mapOfKeyToACR.put(String.valueOf(acr.ContactId) + String.valueOf(acr.AccountId), acr);
        }
        
        // END SOQL Query  replace from for-Loop Sprint 19.11 Story-99887
            for(Contact c : contacts) {
                if(String.isNotBlank(c.UUID__c) && !EnvironmentalSettings.isSeedingEnabled()){
                AccountContactRelation acrRecord = mapOfKeyToACR.get(String.valueOf(c.Id) + String.valueOf(c.AccountId));//Sprint 19.11 Story-99887
                
                if(acrRecord != null && types.Contains(acrRecord.Roles)){
                        
                        if(Trigger.isInsert){
                            if(System.UserInfo.getUserName() == iSettings.Integration_API_User__c) {
                                event = ManageContactHandler.EVENT_ACTION_CROSSREF;    
                            } else {
                                if(!c.Imported__c && iActivation!=null && iActivation.Status__c){
                                    System.debug('!@#$% Not an imported contact. Setting event to Create');
                                    event = ManageContactHandler.EVENT_ACTION_CREATE;     
                                } else if(c.Imported__c) {
                                    System.debug('!@#$% Imported Contact. Setting event to Cross Ref');
                                    event = ManageContactHandler.EVENT_ACTION_CROSSREF;   
                                    TestRun.UirunContact = false;
                                }    
                            }
                        } else if(Trigger.isUpdate){
                            System.debug('ContactTriggerHandler - tcm cross reference sent in current transaction : ' + TestRun.UirunContact);
                            if(iSettings!=null && iActivation!=null && System.UserInfo.getUserName() != iSettings.Integration_API_User__c && iActivation.Status__c) {
                                System.debug('ContactTriggerHandler - iActivation status -- '+iActivation.Status__c );
                                event = ManageContactHandler.EVENT_ACTION_UPDATE;  
                            }
                            if(TestRun.UirunContact == false){
                                event = ManageCustomerHandler.EVENT_ACTION_UPDATE;
                                TestRun.UirunContact = true;
                            }
                        }
                        //Overriding Event Action temporarily
                        if(c.Send_Create_Event__c){
                            event = ManageContactHandler.EVENT_ACTION_CREATE;           
                        }
                        System.debug('!@#$% Event is set to : ' + event);
                        system.debug('****Customer Seeding Field value in the Trigger:'+EnvironmentalSettings.isSeedingEnabled());
                        //Prepare request
                        if(event != null && String.isNotBlank(event) && !EnvironmentalSettings.isSeedingEnabled()) {
                            manageContact.add(new ManageContactDAO(c,event));
                            //sendManageContact(event,c);
                        }
                    }     
                }
                    
            }
        if(!manageContact.isEmpty() && !Test.isRunningTest() && !manageEventSent){
            sendManageContacts(manageContact);
        }
    }
    @TestVisible
    private static void sendManageContacts(List<ManageContactDAO> manageContacts){
        String manageContactSerializedObj = JSON.serialize(manageContacts); 
        if(system.isBatch() || System.isFuture()){
            //  System.enqueueJob(new TCMContactQueueable(mcReq, event, c.UUID__c));
        } else {
            ManageContactHandler.sendmanageContactList(manageContactSerializedObj);
            manageEventSent = true;
        }
    }
    
    /**private static void sendManageContact(String event, Contact c){
        System.debug('!@#$% Invoking ManageContact with ' + event + ' event');
        // Prepare request
        String mcReq = ManageContactHandler.generateManageContactRequest(c, event);
        System.debug('++mcReq=='+ mcReq);
        
        //Send request
        //Modified as per Merge batch functionality
        if(system.isBatch()){
            //  System.enqueueJob(new TCMContactQueueable(mcReq, event, c.UUID__c));
        } else {
            ManageContactHandler.sendManageContact(mcReq, event, c.UUID__c);
        }
        System.debug('!@#$% ManageContact request sent to TCM | Contact ID : ' + c.Id);
    }*/
    
    //EDGE-60, Anu
    //Sprint 19.17, P2OB-4310 (splited because of Cyclometric Issues)
    public static void calculateLOC(){
        
        Map<String,Customer_Type__c> mapCustomerTypeCode= new Map<String,Customer_Type__c>();
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Account> accountUpdated = new List<Account>();
        List<String> customerTypes = new List<String>();  //Better to use Set insted of List
        //List<Contact> contacts = Trigger.new;
        getAccountContactIdsForCalculateLOC(Trigger.new); // to get Set of locAccountIds,locContactIds
        //EDGE-68099 Removed Hard Coding in SOQL Query.
        if(!locContactIds.isEmpty() && !locAccountIds.isEmpty()){
            for(AccountContactRelation acr : [SELECT AccountId,ContactId,Account.Id,Account.Name,Account.Type,
                                              Account.Loc__c,Account.Customer_Status__c,Contact.Id,Contact.Birthdate,
                                              Contact.FirstName,Contact.LastName,Contact.Driver_License_Id__c,
                                              Contact.Driver_Licence_State__c FROM AccountContactRelation 
                                              WHERE Roles =: system.label.LegalLessee And 
                                              ContactId IN :locContactIds AND AccountId IN :locAccountIds]){
                                                  accountList.add(acr.Account);
                                                  customerTypes.add(acr.Account.Type);
                                                  contactList.add(acr.Contact);
                                              }
        }
        boolean listCheck=(!customerTypes.isEmpty() && !contactList.isEmpty()&& !accountList.isEmpty());
        if(listCheck){
            mapCustomerTypeCode=customerTypeMap(customerTypes);
            accountUpdated=listAccountsToUpdateLOC(accountList,contactList,mapCustomerTypeCode);
        }
        // Added Null Check By Team SFO, Sprint 19.04
        if(accountUpdated!=null && !accountUpdated.isEmpty() && Schema.sObjectType.Account.isUpdateable()){
            update accountUpdated;
        }
    }
    
    
    /*
    This Method called in calculateLOC to return set of accountIds,contactIds in specified conditions.
    Input params: List<Contact> contacts
    output  :add values to class variable "locAccountIds,locContactIds" and same used in 
    contactNameConcatenation method and inputs for conNameConcatenationAccountwithContactList method.
    Sprint 19.17, P2OB-4310 (splited because of Cyclometric Issues)
    */
    private static void getAccountContactIdsForCalculateLOC(List<Contact> contacts){
        for(Contact con : contacts){
            if(Trigger.oldMap != NULL){
                sObject oldCon = Trigger.oldMap.get(con.Id);
                sObject newCon = Trigger.newMap.get(con.Id);
                if((oldCon.get(Schema.Contact.Birthdate) != newCon.get(Schema.Contact.Birthdate))
                   || (oldCon.get(Schema.Contact.Driver_License_Id__c) != newCon.get(Schema.Contact.Driver_License_Id__c))
                   || (oldCon.get(Schema.Contact.FirstName) != newCon.get(Schema.Contact.FirstName))){                  
                       locAccountIds.add(con.AccountId);    
                       locContactIds.add(con.Id);
                   } 
            }
        }
    }   
    
    
    
    /*
    The use of customerTypeMap method is to get the customer code with the help of customerTypes return the Map of customerty and Customer record.
    Input param     :   List<String> customerTypes (inputs are passing in calculateLOC method).
    output          :   return type is Map<String,Customer_Type__c> i.e. key is Customer Type , value is : Customer_Type__c record.
    Sprint 19.17, P2OB-4310 (splited because of Cyclometric Issues)
    */
    private static Map<String,Customer_Type__c> customerTypeMap(List<String> customerTypes){
        Map<String,Customer_Type__c> mapCustomerTypeCode= new Map<String,Customer_Type__c>();
        for(Customer_Type__c ct : [SELECT Id,Name,Code__c,Customer_Type__c FROM Customer_Type__c WHERE Customer_Type__c IN: customerTypes]){
            mapCustomerTypeCode.put(ct.Customer_Type__c,ct);
        }           
        return mapCustomerTypeCode;
    }
    
    /*
    The Use of listAccountsToUpdateLOC is, to assign the LOC value to account with the help of accountLocFromContacts method.
    Input param:    List<Account> accountList,List<Contact> contactList, Map<String,Customer_Type__c> mapCustomerTypeCode
    these inputs passing from calculateLOC method.
    Output     :    Return List of accounts with LOC value.
    Sprint 19.17, P2OB-4310 (splited because of Cyclometric Issues)
    */
    private static List<Account> listAccountsToUpdateLOC(List<Account> accountList,List<Contact> contactList, Map<String,Customer_Type__c> mapCustomerTypeCode){
        List<Account> accountLocUpdated = new List<Account>();      
        for(Account a : accountList){
            if(String.isNotBlank(a.Type) && (a.Customer_Status__c == Label.Acc_Customer_Status || a.Customer_Status__c == Label.Acc_Customer_Status_Acquired) && (a.Type == Label.Acc_Residential ||a.Type == Label.Acc_Type_SoleTrader)){ //EDGE-68099 Removed Hard Coding
                String code = ((!mapCustomerTypeCode.isEmpty()) && mapCustomerTypeCode.get(a.Type).Code__c != NULL) ? mapCustomerTypeCode.get(a.Type).Code__c:''; 
                a.Loc__c = accountLocFromContacts(contactList,code);
            } else{
                a.LOC__c = NULL; 
            }
            accountLocUpdated.add(a);           
        }
        return accountLocUpdated;
    }
    
    /*
    The use of accountLocFromContacts method is, return the LOC value to assign to the account in listAccountsToUpdateLOC method.
    Input param     :   List<Contact> contactList,String code , here code is Customer_Type__c.code
    Output          :   return the LOC value.
    Sprint 19.17, P2OB-4310 (splited because of Cyclometric Issues)
    */
    private static String accountLocFromContacts(List<Contact> contactList,String code){
        String loc;
        String DOB;
        String licence;
        String firstName = '';
        for(Contact con :contactList){
            DateTime birthdate = con.Birthdate;
            DOB = (birthdate == null)? null :birthdate.format('MM/dd/yyyy');
            licence = con.Driver_License_Id__c;
            firstName = (con.Driver_License_Id__c == null) ?
                ((con.FirstName != null && con.FirstName.length()>17)? con.FirstName.substring(0,17):con.FirstName) :
            ((con.FirstName != null && con.FirstName.length()>8)? con.FirstName.substring(0,8):con.FirstName);
                }
        
        loc = (firstName == null || DOB == null) ? '' :
        ((licence != NULL)?code+DOB+licence+firstName:code+DOB+firstName);
            return loc;
    }
    
    //EDGE-42, Nikita
    //EDGE-68099 Removed Hard Coding
    public static void contactNameConcatenation(){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        List<Account> accList = new List<Account>();
        List<Account> accountUpdated = new List<Account>();
        List<Contact> contacts = Trigger.new;
        for(Contact con : contacts){
            if(Trigger.oldMap != NULL){
                sObject oldCon = Trigger.oldMap.get(con.Id);
                sObject newCon = Trigger.newMap.get(con.Id);  
                if(oldCon.get(Schema.Contact.FirstName) != newCon.get(Schema.Contact.FirstName) 
                   || oldCon.get(Schema.Contact.MiddleName) != newCon.get(Schema.Contact.MiddleName) 
                   || oldCon.get(Schema.Contact.LastName) != newCon.get(Schema.Contact.LastName)){
                       contactIds.add(con.Id);
                       accountIds.add(con.AccountId);                  
                   }
            } 
        } // 09-09-2020 : P2OB-7962 - Fix given by SFO to move SQL outside loop
            //EDGE-68099 Removed Hard Coding in SOQL Query.
            if(!contactIds.isEmpty()){
                for(AccountContactRelation acr : [SELECT AccountId,ContactId,Contact.Id,Contact.FirstName,Contact.MiddleName,Contact.LastName,Account.Name,Account.Id,Account.Account_name_Concatenate__c FROM AccountContactRelation WHERE Roles =: system.label.LegalLessee AND (Account.Type =: system.label.Acc_Residential OR Account.Type =: system.label.Acc_Type_SoleTrader) AND ContactId IN :contactIds AND AccountId IN :accountIds]){
                   contactList.add(acr.Contact);
                    accList.add(acr.Account);
                } 
            }  
            
            if(!accList.isEmpty()){
                for(Account acc : accList){
                    for(Contact c : ContactList) {
                        acc.Account_name_Concatenate__c = TRUE;
                        if(String.isNotBlank(c.FirstName) && String.isNotBlank(c.MiddleName)){
                            acc.Name = c.FirstName +' '+c.MiddleName+' '+c.LastName;
                            accountUpdated.add(acc);  
                        }
                        else if(c.FirstName == NULL && String.isNotBlank(c.MiddleName)){
                            acc.Name =c.MiddleName+' '+c.LastName;
                            accountUpdated.add(acc);  
                        }
                        else if(String.isNotBlank(c.FirstName) && c.MiddleName == NULL){
                            acc.Name =c.FirstName+' '+c.LastName;
                            accountUpdated.add(acc);  
                        }
                        else if(c.FirstName == NULL && c.MiddleName == NULL){
                            acc.Name =c.LastName;
                            accountUpdated.add(acc);  
                        }
                    }
                }
            } 
    //} Commented as the for-loop is closed at line #483 // P2OB-7962 : Fix given by SFO to move SQL outside loop
        // Added Null Check By Team SFO, Sprint 19.04
        // DML moved out from for loop In Sprint 19.10
            if(accountUpdated!=null && accountUpdated.size()>0 && Schema.sObjectType.Account.isUpdateable()){
              update accountUpdated;
            }
        }
    //EDGE-68099 Removed Hard Coding in SOQL Query.   
    @TestVisible private List<AccountContactRelation> getLegalLesseRelatedAccounts(List<Id> accountIds, List<Id> contactIds){
        return [SELECT AccountId,ContactId,Contact.Id,Contact.FirstName,Contact.MiddleName,Contact.LastName,Account.Name,Account.Id FROM AccountContactRelation WHERE Roles =: system.label.LegalLessee AND ContactId IN :contactIds AND AccountId IN :accountIds];
    }
    
    private void publishCreateEvents(List<Contact> newContacts,String event){
        //Dynamic Binding
        PublishEvents publishIntface=PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newContacts,'Contact',event);
        publishIntface.createEvent();
    }
    
          //EDGE-13148 (242-249), Ramya 
    public static void managePartnerPermissions(){
        //if(Trigger.isAfter && Trigger.isUpdate){
            //ContactTriggerHelper.manageUserPartnerPermSet(Trigger.newMap.keyset());  
        //} else if(Trigger.isAfter && Trigger.isInsert){
            //conTriggerHelper.setOnboardingStatus(Trigger.newMap.keyset());  
        //}
    }
    
    //EDGE-27948: Added Handler method for before udpate trigger context
    public void onBeforeUpdate(List<Contact> lstNewCon,Map<Id,contact> newConMap,Map<Id,contact> oldConMap){
        
        conTriggerHelper.updateContactStatus(newConMap, oldConMap);//EDGE-171189
            // below logic for update field values before Update : comment added in 20.05
            if(iActivation!=null && iActivation.Status__c){
                conTriggerHelper.updateContactLastVerifiedDate(lstNewCon, newConMap, oldConMap);//EDGE-27948
                     }
            conTriggerHelper.updateContactFields(lstNewCon, oldConMap); //Sprint 20.03,Team SFO,Added as per the User Story P2OB-4875
            // Above logic for update field values before Update in Both : comment added in 20.05
            
           //Added as part of DIGI-4062 Sprint 21.14 Team SFO 
           conTriggerHelper.duplicateCheckOnInvoiceNotification(oldConMap, lstNewCon);
        
           //Added as part of DIGI-3444 Sprint 21.14 Team SFO 
           conTriggerHelper.verifyAccountOnContactUpdate(lstNewCon, oldConMap);

        // Above logic for update Name of the Contact before Update in Both 
        // Recursive check  added in 20.05 to resolve SOQL 101 issues everytime
        if(!stopRecursiveBeforeUpdate){    
        /* Sprint 20.03 ,Team SFO ,Commented as per the User Story P2OB-4916
            conTriggerHelper.mandatoryEmailForMandatoryContact(newContactList);
            conTriggerHelper.addressMandatoryForDiamondMember(newContactList);
            */
            
            //SFO 20.05 P2OB-4924
            conTriggerHelper.updateConOfficeAddress(oldConMap, lstNewCon, newConMap);
            //SFO 21.11 DIGI-4057 P2OB-15009
            conTriggerHelper.lastContactwithBillingAccessCheck(newConMap, oldConMap);
        }
        stopRecursiveBeforeUpdate=true; 
    }
    private List<Contact> filterPRMContacts(List<Contact> contactLst){//EDGE-150897
        List<Contact> conList = new List<Contact>();
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner_Contact').getRecordTypeId();
        for(Contact c:contactLst){
            if(c.RecordTypeId != null && c.RecordTypeId == recordTypeId){
                if(String.isNotBlank(c.P_Number__c))
                    conList.add(c);
            }
            else
                conList.add(c);
        }
        return conList;
    }    
}