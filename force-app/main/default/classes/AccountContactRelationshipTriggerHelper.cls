/*
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
: 21/06/2021 21.09 by pallavi , Team SFO
Added a not null condition in validateLegalLessee(Method) as part of P2OB-13388
: 17/08/2021 21.11 by Chhaveel , Team SFO
Added a onDelete check condition in onACRDelete(Method) as part of DIGI-4057
: 12/10/2021 21.14 by Pallavi B , Team SFO
Added a onDelete Invoice NOtification check condition in onACRDelete(Method) as part of DIGI-4062
*/
public without sharing class AccountContactRelationshipTriggerHelper {
    
    public static Boolean hasManageEventSent = false;
    //to set opt-out fields as checked or unchecked Sprint 20.03, P2OB-4875
    private  boolean checked = true;
    public static boolean isRecursive = false;
    
    //ACRHistory Mapping For EDGE-16057
    public void trackHistoryOfACRToACRHistoryObj(Map<Id,AccountContactRelation> oldMap,Map<Id,AccountContactRelation> newMap){
        AccountContactRelationHistoryTracking acrHistoryTracking=new AccountContactRelationHistoryTracking();
        acrHistoryTracking.trackHistoryOfACRToACRHistoryObj(oldMap,newMap);
    } 
    
    public void publishCreateEvents(List<AccountContactRelation> newList,String event){
        //Dynamic Binding
        if(!isRecursive){
            PublishEvents publishIntface=PublishEventsImpl.getInstance();
            publishIntface.createEventObject(newList,null,event);
            publishIntface.createEvent();
            isRecursive = true;
        }
    }
    
    public void onBeforeLegallesse(List<AccountContactRelation> newList){
        List<ID> accIdList=new List<id>();
        List<AccountContactRelation> acrListLL=new List<AccountContactRelation>();
        List<AccountContactRelation> acrListST=new List<AccountContactRelation>();
        for(AccountContactRelation acr:newList){
            accIdList.add(acr.AccountId);
        }
        Map<ID,Account> accountMap=new Map<ID,Account>();
        List<Account> acrList=[select id,name,type,(SELECT Roles,Relationship_End_Date__c,isPrimary__c, Id, ContactId, AccountId, IsDirect, IsActive, Contact_Type__c FROM AccountContactRelations where (Roles='Legal Lessee' or Roles='Full Authority')) from Account where id in :accIdList];
        
        for(Account acc:acrList){
            accountMap.put(acc.id, acc);
            for(AccountContactRelation acr:acc.accountcontactrelations){
                if(acr.Roles.contains('Legal Lessee')){
                    acrListLL.add(acr);
                } else if(acr.Roles.contains('Full Authority')){
                    acrListST.add(acr);
                }
            }
        }
        validateLegalLessee(acrListLL,newList,accountMap);
        //Commeting this validation as per the bug P2OB-6496 and mail discussion 
        //validateFullAuthority(acrListST,newList,accountMap);
    }
    
    private void validateLegalLessee(List<AccountContactRelation> acrListLL,List<AccountContactRelation> newList,Map<ID,Account> accountMap){
        if(!acrListLL.isEmpty()){
            Map<ID,Account> acc2ACRMap=new  Map<ID,Account>();
            Map<ID,AccountContactRelation> acrMap=new  Map<ID,AccountContactRelation>();
            for(AccountContactRelation acr:acrListLL){
                acc2ACRMap.put(acr.accountId,accountMap.get(acr.AccountId));
                acrMap.put(acr.accountId,acr);
            }
            for(AccountContactRelation newACR:newList){
                if((newACR.Roles != null &&('Legal Lessee'.contains(newACR.Roles))) && (!acc2ACRMap.isEmpty() && (acc2ACRMap.get(newACR.accountId)!=null &&('Sole Trader'.equals(acc2ACRMap.get(newACR.accountId).Type) || 'Residential'.equals(acc2ACRMap.get(newACR.accountId).Type))))){
                    if(((acrMap.get(newACR.accountId).Relationship_End_Date__c==null && newACR.Relationship_End_Date__c> System.today())||(acrMap.get(newACR.accountId).Relationship_End_Date__c==null && newACR.Relationship_End_Date__c==NULL))&& newACR.id!=acrMap.get(newACR.accountId).id){
                        newACR.addError('Only one legal lessee contact is allowed per Sole Trader account. Please end date the existing legal lessee contact/account relationship and try again');
                    }
                    else if(newACR.Relationship_End_Date__c<=System.today()){
                        newACR.isprimary__c=false; 
                    }
                }    
            }
        } else if(acrListLL.isEmpty()&& newList!=null){
            for(Integer i=0;i<newList.size();i++){
                if(i==0 && newList[i]!=null && newList[i].roles!=null && newList[i].roles.contains('Legal Lessee')){
                    if(newList[i].Relationship_End_Date__c<=System.today()){
                        newList[i].isprimary__c=false; 
                        AccountContactRelationshipTriggerHandler.insertFlag=true;
                    } else {
                        newList[i].isprimary__c=true; 
                        AccountContactRelationshipTriggerHandler.insertFlag=true;  
                    }
                } else if(i>0 && newList[i]!=null && newList[i].roles!=null && newList[i].roles.contains('Legal Lessee')  ){
                    newList[i].addError('Only one legal lessee contact is allowed per Sole Trader account. Please end date the existing legal lessee contact/account relationship and try again');
                    AccountContactRelationshipTriggerHandler.insertFlag=true;    
                }
            }
        }
    }
    
    
    //Send MANAGE CONTACT event to TCM.
    public void sendManageContact(Map<Id,AccountContactRelation> newACRMap,Map<Id,AccountContactRelation> oldACRMap){
        ContactTriggerHandler cth = new ContactTriggerHandler();
        List<ManageContactDAO> manageCreateEventTrigger = new List<ManageContactDAO>();
        List<ManageContactDAO> manageUpdateEventTrigger = new List<ManageContactDAO>();
        Boolean isTrackingHistoryRequest = false;
        Set<Id> acrEndDatedContIdSet = new Set<Id>(); //Added for EDGE-2921(AC6)
        Map<Id,Contact> contactMap = getContactMap(newACRMap.values());
        FieldUpdateIdentifier fui = new FieldUpdateIdentifier(AccountContactRelation.SobjectType);
        Map<id, sobject> matches = fui.identifyUpdatesToMonitoredFields(newACRMap, oldACRMap);
        Interface_Activation__c iActivation = Interface_Activation__c.getValues('Manage Contact Create'); 
        System.debug('FUI changes size : ' + matches.size());
        for(Id notifyACRId : matches.keySet()){
            Contact con = contactMap.get(newACRMap.get(notifyACRId).ContactId);
            if(hasChangedfromNonAuthorised(oldACRMap.get(notifyACRId), newACRMap.get(notifyACRId)) && String.isBlank(con.UUID__c) && isCreateEventEnabled(iActivation)){
                System.debug('Contact creation ' + con.Id);
                manageCreateEventTrigger.add(new ManageContactDAO(con,ManageContactHandler.EVENT_ACTION_CREATE,newACRMap.get(notifyACRId).AccountId));
            } else if(String.isNotBlank(con.UUID__c)){
                System.debug('Contact updation ' + con.UUID__c);
                ManageContactDAO mcDAO = new ManageContactDAO(con,ManageContactHandler.EVENT_ACTION_UPDATE,newACRMap.get(notifyACRId).AccountId);
                if(newACRMap.get(notifyACRId).Relationship_End_Date__c != null && newACRMap.get(notifyACRId).Relationship_End_Date__c == Date.today()){
                    isTrackingHistoryRequest = false;
                    mcDAO.isACREndDated = true;
                    mcDAO.acrRole = newACRMap.get(notifyACRId).Roles;
                    acrEndDatedContIdSet.add(con.Id);
                }
                manageUpdateEventTrigger.add(mcDAO);
            }
        }
        if(!hasManageEventSent){
            cth.sendManageEvent(manageCreateEventTrigger);
            cth.sendManageEvent(manageUpdateEventTrigger);
            hasManageEventSent = true;
            if(isTrackingHistoryRequest){
                trackHistoryOfACRToACRHistoryObj(oldACRMap,newACRMap);
            }
        }
        // In Notify/Get Interface/Customer seeding, If we get contacts whose ACR is end datated 
        // then as per EDGE-2921(AC6) (i) Set the role to Non-Authorised and (ii) Clean the Relationship End date.
        if(!acrEndDatedContIdSet.isEmpty()){
            updateACRRoleandCleanRelEndDate(acrEndDatedContIdSet,newACRMap);
        }
    }
    
    private Boolean isCreateEventEnabled(Interface_Activation__c iActivation){
        return (iActivation!=null && iActivation.Status__c) ? true : false;
    }   
    
    private Map<Id,Contact> getContactMap(List<AccountContactRelation> acrList){
        List<Id> acrContactIds = new List<Id>();
        for(AccountContactRelation acrIds : acrList){
            acrContactIds.add(acrIds.ContactId);
        }
        return getContactList(acrContactIds);
    }
    
    //querying contact list
    private Map<Id,Contact> getContactList(List<Id> idList){
        return new Map<Id,Contact>([select ID,name,Imported__c,salutation,MiddleName,Send_Create_Event__c,UUID__c,Birthdate,FirstName,LastName,Driver_License_Id__c,Driver_License_State__c,accountID,Source_System__c,Home_Email__c,Home_Fax__c,HomePhone,HomePhone__c,Email,Fax,Phone,MobilePhone,Contact_Status__c,Online_Flag__c,Pref_Comm_Method__c,lastVerifiedDate__c,Notes__c,numberInHousehold__c,Occupation__c,timeZone__c,Has_Reviewed__c,Language_Preference__c,Title From Contact where id in :idList]);
    }
    
    private Boolean hasChangedfromNonAuthorised(AccountContactRelation oldACR, AccountContactRelation newACR){
        return ('Non-Authorised'.equals(oldACR.Roles) && !'Non-Authorised'.equals(newACR.Roles)) ? true : false;
    }
    
    //Author: nileshdethe
    //Description: Helper method to validate that if the provided contacts has any FCR availbale, 
    //then update the ACR role to Non-Authorised and Clean the Relationship End date. 
    //Please refer above story EDGE-2921 for more details.
    public void updateACRRoleandCleanRelEndDate(Set<Id> setContId, Map<Id,AccountContactRelation> newACRMap){
        //List to store the ACR records which needs to be updated for contact which has other FCR available.
        List<AccountContactRelation> lstUpdACR = new List<AccountContactRelation>();
        //List of contact with related FCR and ACR.
        List<Contact> lstContact = [SELECT Id,Contact_Status__c,
                                    (SELECT Id FROM Functional_Contact_Roles__r),
                                    (SELECT Id,Roles,Relationship_End_Date__c,Relationship_Expiry_Date__c FROM AccountContactRelations)
                                    FROM Contact
                                    WHERE Id In :setContId];
        for(Contact cnt : lstContact){
            if(!cnt.Functional_Contact_Roles__r.isEmpty() && !cnt.AccountContactRelations.isEmpty()){
                for(AccountContactRelation acr: cnt.AccountContactRelations){
                    AccountContactRelation acrtoUpdate = newACRMap.get(acr.Id);
                    if(acrtoUpdate != null){
                        acrtoUpdate.Roles = 'Non-Authorised';
                        acrtoUpdate.Relationship_End_Date__c = null;
                    }
                }
            }
        }
    }
    
    
    /*
This method called in "checkAllMarketingOptOut" method ,to check if the new AccountContactRelation record's AllMarketingOptOut is True or existing AccountContactRelation record's AllMarketingOptOut is changed from false to true.  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isAllMarketingOptOutTrue(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null && acr.Not_Re_searchable__c ) || 
            (mapOldACRs != Null && acr.Not_Re_searchable__c && (acr.Not_Re_searchable__c != mapOldACRs.get(acr.Id).Not_Re_searchable__c)) ;
    }
    /*
This method called in "checkAllMarketingOptOut" method ,to check if the new AccountContactRelation record's AllMarketingOptOut is False or existing AccountContactRelation record's AllMarketingOptOut is changed from true to false.  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isAllMarketingOptOutFalse(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null && !acr.Not_Re_searchable__c ) || 
            (mapOldACRs != Null && !acr.Not_Re_searchable__c && (acr.Not_Re_searchable__c != mapOldACRs.get(acr.Id).Not_Re_searchable__c)) ;
    }
    /*
This method called in "updateContactFields" method, to set AccountContactRelation record's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  To set contact record Opt Out Values.  
*/  
    private void checkAllMarketingOptOut(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        if(isAllMarketingOptOutTrue(acr,mapOldACRs)){
            acr.Opt_Out_All_Direct_Marketing__c = checked;
            acr.Opt_Out_Direct_Mail_White_Mail__c = checked;
            acr.Opt_Out_Telemarketing__c = checked;
            acr.Opt_Out_Electronic_Marketing__c = checked;
            acr.Opt_Out_SMS_MMS__c = checked;
            acr.Opt_Out_Emails__c = checked;      
        }else  if(isAllMarketingOptOutFalse(acr,mapOldACRs)){
            acr.Opt_Out_All_Direct_Marketing__c = !checked;
            acr.Opt_Out_Direct_Mail_White_Mail__c = !checked;
            acr.Opt_Out_Telemarketing__c = !checked;
            acr.Opt_Out_Electronic_Marketing__c = !checked;
            acr.Opt_Out_SMS_MMS__c = !checked;
            acr.Opt_Out_Emails__c = !checked;      
        }
    }
    /*
This method called in "checkAllDirectMarketingOptOut" method ,to check if the new AccountContactRelation record's AllDirectMarketingOptOut is True or existing AccountContactRelation record's AllDirectMarketingOptOut is changed from false to true.  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isAllDirectMarketingOptOutTrue(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null && acr.Opt_Out_All_Direct_Marketing__c ) || 
            (mapOldACRs != Null && acr.Opt_Out_All_Direct_Marketing__c && (acr.Opt_Out_All_Direct_Marketing__c != mapOldACRs.get(acr.Id).Opt_Out_All_Direct_Marketing__c)) ;
    }
    /*
This method called in "checkAllDirectMarketingOptOut" method ,to check if the new AccountContactRelation record's AllDirectMarketingOptOut is False or existing AccountContactRelation record's AllDirectMarketingOptOut is changed from true to false.  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isAllDirectMarketingOptOutFalse(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null && !acr.Opt_Out_All_Direct_Marketing__c ) || 
            (mapOldACRs != Null && !acr.Opt_Out_All_Direct_Marketing__c && (acr.Opt_Out_All_Direct_Marketing__c != mapOldACRs.get(acr.Id).Opt_Out_All_Direct_Marketing__c)) ;
    }
    /*
This method called in "checkElectronicMarketingOptOut" method, to check if the new AccountContactRelation record's ElectronicMarketingOptOut is True or existing AccountContactRelation record's ElectronicMarketingOptOut is changed from false to true.  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isElectronicMarketingOptOutTrue(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null && acr.Opt_Out_Electronic_Marketing__c ) || 
            (mapOldACRs != Null && acr.Opt_Out_Electronic_Marketing__c && (acr.Opt_Out_Electronic_Marketing__c != mapOldACRs.get(acr.Id).Opt_Out_Electronic_Marketing__c)) ;
    }
    /*
This method called in "checkElectronicMarketingOptOut" method, to check if the new AccountContactRelation record's ElectronicMarketingOptOut is False or existing AccountContactRelation record's ElectronicMarketingOptOut is changed from true to false.  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isElectronicMarketingOptOutFalse(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null && !acr.Opt_Out_Electronic_Marketing__c ) || 
            (mapOldACRs != Null && !acr.Opt_Out_Electronic_Marketing__c && (acr.Opt_Out_Electronic_Marketing__c != mapOldACRs.get(acr.Id).Opt_Out_Electronic_Marketing__c)) ;
    }
    /*
This method called in "setElectronicMarketing" method, to check if the AccountContactRelation record's Opt_Out_SMS or Opt_Out_Emails changed  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isSMSorEmailChanged(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null) ||
            ((mapOldACRs != Null) && ((acr.Opt_Out_SMS_MMS__c != mapOldACRs.get(acr.Id).Opt_Out_SMS_MMS__c) ||
                                      (acr.Opt_Out_Emails__c != mapOldACRs.get(acr.Id).Opt_Out_Emails__c)));
    }
    /*
This method called in "setAllDirectMarketing" method, to check if the AccountContactRelation record's Opt_Out_Direct_Mail or Opt_Out_Telemarketing changed  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isDirectorTelemarketingChanged(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null) ||
            ((mapOldACRs != Null) && ((acr.Opt_Out_Direct_Mail_White_Mail__c != mapOldACRs.get(acr.Id).Opt_Out_Direct_Mail_White_Mail__c) ||
                                      (acr.Opt_Out_Telemarketing__c != mapOldACRs.get(acr.Id).Opt_Out_Telemarketing__c)));
    }
    /*
This method called in "setAllMarketing" method, to check if the AccountContactRelation record's Opt_Out_All_Direct_Marketing or Opt_Out_Electronic_Marketing changed  
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  boolean
*/  
    private boolean isAllDirectorElectronicChanged(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        return (mapOldACRs == Null) ||
            ((mapOldACRs != Null) && ((acr.Opt_Out_Electronic_Marketing__c != mapOldACRs.get(acr.Id).Opt_Out_Electronic_Marketing__c) ||
                                      (acr.Opt_Out_All_Direct_Marketing__c != mapOldACRs.get(acr.Id).Opt_Out_All_Direct_Marketing__c)));
    }
    /*
This method called in "updateContactFields" method, to set AccountContactRelation record's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  To set contact record Opt Out Values.  
*/  
    private void checkAllDirectMarketingOptOut(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        if(isAllDirectMarketingOptOutTrue(acr,mapOldACRs)){
            acr.Opt_Out_Direct_Mail_White_Mail__c = checked;
            acr.Opt_Out_Telemarketing__c = checked;
        }else  if(isAllDirectMarketingOptOutFalse(acr,mapOldACRs)){
            acr.Opt_Out_Direct_Mail_White_Mail__c = !checked;
            acr.Opt_Out_Telemarketing__c = !checked;
        }    
    }
    /*
This method called in "updateContactFields" method, to set AccountContactRelation record's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  To set contact record Opt Out Values.  
*/  
    private void checkElectronicMarketingOptOut(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        if(isElectronicMarketingOptOutTrue(acr,mapOldACRs)){
            acr.Opt_Out_SMS_MMS__c = checked;
            acr.Opt_Out_Emails__c = checked;      
        }else  if(isElectronicMarketingOptOutFalse(acr,mapOldACRs)){
            acr.Opt_Out_SMS_MMS__c = !checked;
            acr.Opt_Out_Emails__c = !checked;      
        }    
    }
    /*
This method called in "updateContactFields" method, to set AccountContactRelation record's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  To set contact record Opt Out Values.  
*/  
    private void setElectronicMarketing(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        if(isSMSorEmailChanged(acr,mapOldACRs)){
            if(acr.Opt_Out_SMS_MMS__c && acr.Opt_Out_Emails__c) acr.Opt_Out_Electronic_Marketing__c = checked;
            else acr.Opt_Out_Electronic_Marketing__c = !checked;
        }    
    }
    /*
This method called in "updateContactFields" method, to set AccountContactRelation record's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  To set contact record Opt Out Values.  
*/  
    private void setAllDirectMarketing(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        if(isDirectorTelemarketingChanged(acr,mapOldACRs)){
            if(acr.Opt_Out_Direct_Mail_White_Mail__c && acr.Opt_Out_Telemarketing__c) acr.Opt_Out_All_Direct_Marketing__c = checked;
            else acr.Opt_Out_All_Direct_Marketing__c = !checked;
        }    
    }
    /*
This method called in "updateContactFields" method, to set AccountContactRelation record's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs  :   New contact from Trigger.new
Map<id,AccountContactRelation> mapOldACRs  
Output  :  To set contact record Opt Out Values.  
*/  
    private void setAllMarketing(AccountContactRelation acr, Map<id,AccountContactRelation> mapOldACRs){
        if(isAllDirectorElectronicChanged(acr,mapOldACRs)){
            if(acr.Opt_Out_Electronic_Marketing__c && acr.Opt_Out_All_Direct_Marketing__c) acr.Not_Re_searchable__c = checked;
            else acr.Not_Re_searchable__c = !checked;
        }    
    }
    
    /*
Description  :  Team SFO, sprint 20.03, P2OB-4875 :: As a system I want all of these existing Process Builder items relating to the ACR Object now reflecting on the Contact object for the same fields
Coverage  :  ContactTriggerTest and AccountContactRelationshipTRGTest classes
Author    :  Sri
*/
    public void updateACRFields(List<AccountContactRelation> lstNewACRs, Map<id,AccountContactRelation> mapOldACRs){
        for(AccountContactRelation acr : lstNewACRs){
            if(acr.ContactToACR__c) continue;
            checkAllMarketingOptOut(acr,mapOldACRs);
            checkAllDirectMarketingOptOut(acr,mapOldACRs);
            checkElectronicMarketingOptOut(acr,mapOldACRs);
            setElectronicMarketing(acr,mapOldACRs);
            setAllDirectMarketing(acr,mapOldACRs);
            setAllMarketing(acr,mapOldACRs);
        } //For END
    }
    
    /* Description :     TO check if the contact is being deactivated or Remove
*  				 "Billing or create and edit user permissions"
*  			     is not last contact with this access on Account
* Team        :     SFO 
* Sprint      :     21.11 
* Stroy       :     DIGI-4057 
* Author      :     Chhaveel Thakur
* Test Class  :     AccountContactRelationshipTRGTest
* Last MOdified Info: DIGI-4062 Sprint 21.14 Pallavi B(Team SFO)
*/
    
    public void onACRDelete(Map<ID,AccountContactRelation> oldMap){
        Set<Id> accountIDs = new Set<Id>();
        Set<Id> oldConIDs = new Set<Id>();
        Set<Id> exisistingConIDs = new Set<Id>();
        Map<Id,list<Id>> mapOfExisistingActIdConIds = new Map<Id,list<Id>>();
        
        
        Map<Id,Contact> mapOfConIDContact = new Map<Id,Contact>();
        Map<Id,list<Contact>> mapOfActIdContact = new Map<Id,List<Contact>>();
        
        
        Contact currentACRCon = new Contact(); //current contact
        Boolean isBillingRecord = false; //is the current contact needed to check for last man logic with Raise_Billing_Disputes__c Permission
        Boolean isAdminStatusRecord = false; //is the current contact needed to check for last man logic with Telstra_Connect_Admin__c and Telstra_Connect_Status__c Permission
        Boolean isAdminRecord = false; //is the current contact needed to check for last man logic with Telstra_Connect_Admin__c Permission
        boolean isInvoiceNotificationEnabled = false; //is the current contact needed to check for last man logic with Invoice_notifications__c Permission
        
        
        //loop to get the current acr record's contactid and accountid
        for(AccountContactRelation currentACR:oldMap.values()){
            accountIDs.add(currentACR.AccountId);
            oldConIDs.add(currentACR.ContactId);
        }
        
        //loop to get the exisisting acr record's related to the current acr's account and not the contact
        for(AccountContactRelation exisistingACR: [SELECT id, AccountId, contactId from AccountContactRelation WHERE AccountId IN: accountIDs and contactId NOT IN :oldConIDs ]){
            exisistingConIDs.add(exisistingACR.ContactId);
            //AccountID and Contact Id map
            if(mapOfExisistingActIdConIds.containsKey(exisistingACR.AccountId)){
                mapOfExisistingActIdConIds.get(exisistingACR.AccountId).add(exisistingACR.contactId);
            }else{
                mapOfExisistingActIdConIds.put(exisistingACR.AccountId, new list<Id>{exisistingACR.contactId});
            }
        } // for loop ends
        
        
        // loop to fetch all the related Contact records under the mapOfConIDContact
        for(Contact con : [Select Id,AccountId, Raise_Billing_Disputes__c , Telstra_Connect_Admin__c , Contact_Status__c,Telstra_Connect_Opt_Out__c,Telstra_Connect_Status__c,Invoice_notifications__c from contact where (id IN :oldConIDs OR id IN :exisistingConIDs) and Contact_Status__c = 'Active']){
            //contactID and Contact rec map
            mapOfConIDContact.put(con.id, con);
            
            //AccountID and Contact rec map
            if(mapOfActIdContact.containsKey(con.AccountId)){
                mapOfActIdContact.get(con.AccountId).add(con);
            }else{
                mapOfActIdContact.put(con.AccountId, new list<Contact>{con});
            }
        } // for loop ends
        
        // Loop to check all the acr for related records on contact level
        for(AccountContactRelation currentACR:oldMap.values()){
            Boolean isValidContactExisist = false; //sets to TRUE when is there any exisiting cotnact for the related ACR's account matchs the valid criteria 
            Boolean isValidContact = false; 
            currentACRCon = mapOfConIDContact.get(currentACR.contactId);
            isBillingRecord = (currentACRCon.Raise_Billing_Disputes__c == true && 
                               currentACRCon.Telstra_Connect_Opt_Out__c == false && 
                               currentACRCon.Contact_Status__c == 'Active' && 
                               currentACRCon.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA);
            isAdminStatusRecord = (currentACRCon.Telstra_Connect_Admin__c == true && 
                                   currentACRCon.Telstra_Connect_Opt_Out__c == false && 
                                   currentACRCon.Contact_Status__c == 'Active' && 
                                   currentACRCon.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA);
            isAdminRecord = (currentACRCon.Telstra_Connect_Admin__c == true && 
                             currentACRCon.Contact_Status__c == 'Active' );   
            isInvoiceNotificationEnabled = (currentACRCon.Invoice_notifications__c != NULL  && 
                                            currentACRCon.Raise_Billing_Disputes__c == true && 
                                            currentACRCon.Telstra_Connect_Opt_Out__c == false && 
                                            currentACRCon.Contact_Status__c == 'Active' && 
                                            currentACRCon.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA &&
                                            currentACRCon.Invoice_notifications__c.contains(System.Label.ContactInvoiceArrivalNotification));
            
            // Below if checks for the records where Telstra_Connect_Admin__c is True and Telstra_Connect_Status__c is Registered-Actiavted
            if(isAdminStatusRecord){
                // throw an error if there are no other exisiting ACR's assoicated for the current ACR's account                
                if(!mapOfExisistingActIdConIds.containsKey(currentACR.AccountId)){
                    oldMap.get(currentACR.Id).adderror(SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ oldmap.get(currentACR.Id).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_User_Management_Error_2')?.Label_Value__c);
                    continue;
                }
                
                //loop over exisisting contact for the current acr's account
                for(Id exstgConId : mapOfExisistingActIdConIds.get(currentACR.AccountId)){
                    Contact exstgCon = mapOfConIDContact.get(exstgConId);
                    isValidContact = (exstgCon.Telstra_Connect_Admin__c == true && 
                                      exstgCon.Telstra_Connect_Opt_Out__c == false && 
                                      exstgCon.Contact_Status__c == 'Active' && 
                                      exstgCon.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA);
                    if(exstgCon.Id <> currentACRCon.Id && isValidContact){
                        isValidContactExisist = true;
                    }
                    
                } // for loop ends
                if(!isValidContactExisist ){
                    oldMap.get(currentACR.Id).adderror(SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ oldmap.get(currentACR.Id).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_User_Management_Error_2')?.Label_Value__c);
                }
            } else
                // Below if checks for the records where Raise_Billing_Disputes__c is True and Telstra_Connect_Status__c is Registered-Actiavted
                if(isBillingRecord){
                    // throw an error if there are no other exisiting ACR's assoicated for the current ACR's account                
                    if(!mapOfExisistingActIdConIds.containsKey(currentACR.AccountId)){
                        oldMap.get(currentACR.Id).adderror(SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ oldmap.get(currentACR.Id).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_User_Management_Error_1')?.Label_Value__c);
                        continue;
                    }
                    //loop over exisisting contact for the current acr's account
                    for(Id exstgConId : mapOfExisistingActIdConIds.get(currentACR.AccountId)){
                        Contact exstgCon = mapOfConIDContact.get(exstgConId);
                        isValidContact = (exstgCon.Raise_Billing_Disputes__c == true && 
                                          exstgCon.Telstra_Connect_Opt_Out__c == false && 
                                          exstgCon.Contact_Status__c == 'Active' && 
                                          exstgCon.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA);
                        if(exstgCon.Id <> currentACRCon.Id && isValidContact){
                            isValidContactExisist = true;
                        }
                        
                    } // for loop ends
                    if(!isValidContactExisist ){
                        oldMap.get(currentACR.Id).adderror(SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ oldmap.get(currentACR.Id).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_User_Management_Error_1')?.Label_Value__c);
                    }
                } else    
                    // Below if checks for the records where Telstra_Connect_Admin__c is True and Telstra_Connect_Status__c is not considered
                    if(isAdminRecord){
                        // throw an error if there are no other exisiting ACR's assoicated for the current ACR's account                
                        if(!mapOfExisistingActIdConIds.containsKey(currentACR.AccountId)){
                            oldMap.get(currentACR.Id).adderror(SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ oldmap.get(currentACR.Id).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_User_Management_Error_1')?.Label_Value__c);
                            continue;
                        }
                        //loop over exisisting contact for the current acr's account
                        for(Id exstgConId : mapOfExisistingActIdConIds.get(currentACR.AccountId)){
                            Contact exstgCon = mapOfConIDContact.get(exstgConId);
                            isValidContact = (exstgCon.Telstra_Connect_Admin__c == true && 
                                              exstgCon.Contact_Status__c == 'Active');
                            if(exstgCon.Id <> currentACRCon.Id && isValidContact){
                                isValidContactExisist = true;
                            }
                            
                        } // for loop ends
                        if(!isValidContactExisist ){
                            oldMap.get(currentACR.Id).adderror(SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ oldmap.get(currentACR.Id).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_User_Management_Error_1')?.Label_Value__c);
                        }
                    }    
            //Added below code as part of DIGI-4062 Sprint 21.14 .Starts here.
            // Below if checks for the records where Invoice_notifications__c is populated
            if(isInvoiceNotificationEnabled){
                isValidContactExisist = false;
                // throw an error if there are no other exisiting ACR's assoicated for the current ACR's account 
                if(!mapOfExisistingActIdConIds.containsKey(currentACR.AccountId)){
                    oldMap.get(currentACR.Id).adderror(SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ oldmap.get(currentACR.Id).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_Invoice_notification')?.Label_Value__c);
                    continue;
                }
                //loop over exisisting contact for the current acr's account
                for(Id exstgConId : mapOfExisistingActIdConIds.get(currentACR.AccountId)){
                    Contact exstgCon = mapOfConIDContact.get(exstgConId);
                    isValidContact = (exstgCon.Invoice_notifications__c != NULL &&
                                      exstgCon.Raise_Billing_Disputes__c == true && 
                                      exstgCon.Telstra_Connect_Opt_Out__c == false && 
                                      exstgCon.Contact_Status__c == 'Active' && 
                                      exstgCon.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA &&
                                      exstgCon.Invoice_notifications__c.contains(System.Label.ContactInvoiceArrivalNotification));
                    if(exstgCon.Id <> currentACRCon.Id && isValidContact){
                        isValidContactExisist = true;
                    }
                } // for loop ends
                if(!isValidContactExisist ){
                    oldMap.get(currentACR.Id).adderror(SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ oldmap.get(currentACR.Id).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_Invoice_notification')?.Label_Value__c);
                }
            }
            //Added below code as part of DIGI-4062 Sprint 21.14 .Ends here.
            
        }  // for loop from line 460 ends here
    }
}