/*
* History of Updates :
* 1. 17-July-2020    :    Team Hawaii    : P2OB-6754 - Fix for failure due to AutomatedProcess
*EDITED: 04/22/2020  by Sri for Sprint 20.15 , P2OB-9604 :: Removed updateSalesContactStatus method
Edited: 25th Nov, 2020 by Amar Chakka for Sprint 20.16, P2OB-9994:: Removed UpdateTelstraConnectAdmin Method and Part of lines under updateContactFields
Edited: 06th Oct, 2021 by Pallavi B for Sprint 21.14, DIGI-4062:: Added a new method (duplicateCheckOnInvoiceNotification) and modified (lastContactwithBillingAccessCheck,contactRecordCheck)
Edited: 18th Oct, 2021 by Sri for Sprint 21.14, DIGI-3444 :: Added a new method verifyAccountOnContactUpdate
*/
public with sharing class ContactTriggerHelper{
    
    //to set opt-out fields as checked or unchecked Sprint 20.03, P2OB-4875
    private	boolean checked = true; // Don't change this value from TRUE to FALSE.
    
    /*SFO 20.05, P2OB-4924
for accMapForConOfficeAddress,addressMapConOfficeAddress variable
Values assigning in updateConOfficeAddress and using in updateconmailingAddress	
isRecursiveUpdateConOfficeAddress use is  to check Recursive in UpdateConOfficeAddress Method.
*/
    private map<id,account> accMapForConOfficeAddress = new map<id,account>(); 
    private map<id,cscrm__Address__c> addressMapConOfficeAddress = new map<id,cscrm__Address__c>();
    private static boolean isRecursiveUpdateConOfficeAddress=false;
    //End of Variable declaration as part of P2OB-4924
    private static boolean isRecursiveUpdateContactFields=false;
    //Team SFO, sprint 20.03, P2OB-4875
    private static boolean isRecursiveduplicateCheckOnInvoice=false; //Added as part of DIGI-4062 Sprint 21.14 

    
    // Sprint 20.04 , P2OB-4985 AC-4
    //static String profileName=[Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name;
    //P2OB-6754 : Fix for failure due to AutomatedProcess
    static String profileName;
    //When Account_Status__C == "Active" && IsPartner == "True" - Set Onboarding Status to Active 
    static{
        if(UserInfo.getProfileId()!=null){
            List<Profile> userProfile = [Select Id,Name from Profile where Id=:UserInfo.getProfileId() limit 1];
            if(userProfile != null && userProfile.size()>0 )
                profileName = userProfile[0].name;
        }
    }
    //P2OB-6754 : End
    public void setOnboardingStatus(List<contact> conList){
        
        //id rtypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); 
        Id rtypeId1 = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
        set<id> acid = new set<id>();    
        set<id> conIds = new set<id>();
        map<id, List<user>> userconMap = new map<id, List<user>>();
        
        for (Contact c : conList){
            if(c.RecordTypeid == rtypeId1){
                acid.add(c.accountid);
                conIds.add(c.id);
            }
        }
        
        for(user u: [SELECT id, name, contactid, profile.name,FederationIdentifier FROM user
                     WHERE contactid IN : conIds]){    
                         if(u.contactid!=null){
                             if(userconMap.get(u.contactid)!=null)
                                 userconMap.get(u.contactid).add(u);
                             else
                                 userconMap.put(u.contactid, new list<user>{u}); 
                         }
                     } 
        /*
Map<id,account> accMap = new Map<id,account>([select id,Account_Status__c,IsPartner
from Account where Account_Status__c = 'Active' 
and Account.IsPartner = true
and id in :acid]);
*/
        Map<id,account> accMap = new Map<id,account>([SELECT id,RecordType.Name,Account_Status__c,IsPartner
                                                      FROM Account WHERE id IN :acid]);                                               
        for (Contact c : conList){
            
            
            system.debug('userconMap.get(c.id) list'+userconMap.get(c.id));
            if((userconMap.get(c.id)!=null && userconMap.get(c.id).size()>0) && accmap.containsKey(c.accountid) && accMap.get(c.accountid).IsPartner == true && accMap.get(c.accountid).Account_Status__c == 'Active') 
            { 
                c.Onboarding_Status__c = 'Active';
                
            }
            
            
            system.debug('rtypeId1'+rtypeId1);
            system.debug('c.RecordTypeid'+c.RecordTypeid);
            if(accmap.containsKey(c.accountid) && c.RecordTypeid==rtypeId1)
            {
                if(accMap.get(c.accountid).Account_Status__c!='Active')
                    c.Community_User_Type__c='Prospect';
                else if(accMap.get(c.accountid).Account_Status__c=='Active' && accMap.get(c.accountid).RecordType.Name=='Partner')  
                    c.Community_User_Type__c='Domestic';
                else if(accMap.get(c.accountid).Account_Status__c=='Active' && accMap.get(c.accountid).RecordType.Name=='Partner - International')  
                    c.Community_User_Type__c='International';
            }
            
        }
    }
    
    //EDGE-27948: Method to update contact as verifed contact if difference between today's date and last verified date is less than 182
    public void markContactAsVerified(List<Contact> lstNewCon){
        for(Contact con : lstNewCon){
            //Don't procceed contact created thourgh lead conversion process
            if(!con.Is_Lead_Originated__c && con.lastVerifiedDate__c != null && con.lastVerifiedDate__c.daysBetween(Date.today()) < Integer.valueOf(System.Label.Contact_Verified_Criteria_Days)){ 
                con.Has_Reviewed__c = True;
            }
        }
    }
    
    //EDGE-27948: Method to update contact last verified date if the contact is verified
    public void updateContactLastVerifiedDate(List<Contact> lstNewCon, Map<Id,Contact> newConMap, Map<Id,Contact> oldConMap){
        for(Contact con : lstNewCon){
            //Don't procceed contact created thourgh lead conversion process
            if(!con.Is_Lead_Originated__c && con.Has_Reviewed__c && !oldConMap.get(con.id).Has_Reviewed__c){
                con.lastVerifiedDate__c = Date.today();
            } else if(!con.Is_Lead_Originated__c && con.lastVerifiedDate__c != null && con.lastVerifiedDate__c.daysBetween(Date.today()) < Integer.valueOf(System.Label.Contact_Verified_Criteria_Days)){
                con.lastVerifiedDate__c = Date.today();
                con.Has_Reviewed__c = true;
            } else if(con.lastVerifiedDate__c == null || con.lastVerifiedDate__c.daysBetween(Date.today()) > Integer.valueOf(System.Label.Contact_Verified_Criteria_Days)){
                con.Has_Reviewed__c = false;
            }
        }
    }
    
    
    /* Description   : Account's Primary Address is populated as Contact's Office Address (Primary, Active) only if Address Lookup(cscrm__Address__c) is blank.
Team          : SFO 
Sprint        : 19.08, EDGE-87718
20.05, P2OB-4924
Author        : Sravanthi
LastModifiedBy: Amar Chakka
*/
    public void updateContactOfficeAddress(List<Contact> lstNewCon){
        system.debug('Updating Contact office Address');
        Set<Id> accountIdList = new Set<Id>();
        for(Contact c :lstNewCon){
            if(string.isBlank(c.cscrm__Address__c)){
                accountIdList.add(c.AccountId);}
        }
        if(accountIdList != null && !accountIdList.isEmpty()){
            Map<Id,cscrm__Account_Address_Relationship__c> mapOfAccIdToAccAddRelRec = new Map<Id,cscrm__Account_Address_Relationship__c>();
            
            for(cscrm__Account_Address_Relationship__c accAddRel : [SELECT Id,cscrm__Account__c,cscrm__Account__r.Id,cscrm__Address__c,cscrm__Address_Type__c
                                                                    FROM cscrm__Account_Address_Relationship__c WHERE cscrm__Account__c 
                                                                    = :accountIdList AND cscrm__Address_Type__c =:Constants.ADDRESS_TYPE_PRIMARY AND cscrm__Active__c = TRUE]){
                                                                        
                                                                        mapOfAccIdToAccAddRelRec.put(accAddRel.cscrm__Account__r.Id, accAddRel);
                                                                    }
            
            List<cscrm__Contact_Address_Relationship__c> conAddRelList = new List<cscrm__Contact_Address_Relationship__c>();
            
            for(Contact con : lstNewCon){
                cscrm__Account_Address_Relationship__c accAddRelRec = mapOfAccIdToAccAddRelRec.get(con.AccountId);
                
                if(accAddRelRec != null){
                    cscrm__Contact_Address_Relationship__c conAddRel = new cscrm__Contact_Address_Relationship__c();
                    conAddRel.cscrm__Address_Type__c = 'Office Address';
                    conAddRel.cscrm__Active__c = TRUE; 
                    conAddRel.Primary__c = TRUE;
                    conAddRel.cscrm__Contact__c = con.Id;
                    conAddRel.cscrm__Address__c = accAddRelRec.cscrm__Address__c;
                    //conAddRel.ContactToCAR__c = True;
                    conAddRelList.add(conAddRel);
                }
            }
            
            if(conAddRelList != null && !conAddRelList.isEmpty() && Schema.sObjectType.cscrm__Contact_Address_Relationship__c.isCreateable()){
                Database.insert(conAddRelList, false);
            }
            
        }
    }
    
    
    /*
This method called in "checkAllMarketingOptOut" method ,to check if the new contact records's AllMarketingOptOut is True or existing contact records's AllMarketingOptOut is changed from false to true.	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isAllMarketingOptOutTrue(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null && con.All_Marketing_Opt_Out__c ) || 
            (mapOldCon != Null && con.All_Marketing_Opt_Out__c && (con.All_Marketing_Opt_Out__c != mapOldCon.get(con.Id).All_Marketing_Opt_Out__c)) ;
    }
    /*
This method called in "checkAllMarketingOptOut" method ,to check if the new contact records's AllMarketingOptOut is False or existing contact records's AllMarketingOptOut is changed from true to false.	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isAllMarketingOptOutFalse(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null && !con.All_Marketing_Opt_Out__c ) || 
            (mapOldCon != Null && !con.All_Marketing_Opt_Out__c && (con.All_Marketing_Opt_Out__c != mapOldCon.get(con.Id).All_Marketing_Opt_Out__c)) ;
    }
    /*
This method called in "updateContactFields" method, to set contact records's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	To set contact record Opt Out Values.	
*/	
    private void checkAllMarketingOptOut(Contact con, Map<id,Contact> mapOldCon){
        if(isAllMarketingOptOutTrue(con,mapOldCon)){
            con.Opt_Out_All_Direct_Marketing__c = checked;
            con.Opt_Out_Direct_Mail_White_Mail__c = checked;
            con.Opt_Out_Telemarketing__c = checked;
            con.Opt_Out_Electronic_Marketing__c = checked;
            con.Opt_Out_SMS_MMS__c = checked;
            con.Opt_Out_Emails__c = checked;			
        }else	if(isAllMarketingOptOutFalse(con,mapOldCon)){
            con.Opt_Out_All_Direct_Marketing__c = !checked;
            con.Opt_Out_Direct_Mail_White_Mail__c = !checked;
            con.Opt_Out_Telemarketing__c = !checked;
            con.Opt_Out_Electronic_Marketing__c = !checked;
            con.Opt_Out_SMS_MMS__c = !checked;
            con.Opt_Out_Emails__c = !checked;			
        }
    }
    /*
This method called in "checkAllDirectMarketingOptOut" method ,to check if the new contact records's AllDirectMarketingOptOut is True or existing contact records's AllDirectMarketingOptOut is changed from false to true.	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isAllDirectMarketingOptOutTrue(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null && con.Opt_Out_All_Direct_Marketing__c ) || 
            (mapOldCon != Null && con.Opt_Out_All_Direct_Marketing__c && (con.Opt_Out_All_Direct_Marketing__c != mapOldCon.get(con.Id).Opt_Out_All_Direct_Marketing__c)) ;
    }
    /*
This method called in "checkAllDirectMarketingOptOut" method ,to check if the new contact records's AllDirectMarketingOptOut is False or existing contact records's AllDirectMarketingOptOut is changed from true to false.	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isAllDirectMarketingOptOutFalse(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null && !con.Opt_Out_All_Direct_Marketing__c ) || 
            (mapOldCon != Null && !con.Opt_Out_All_Direct_Marketing__c && (con.Opt_Out_All_Direct_Marketing__c != mapOldCon.get(con.Id).Opt_Out_All_Direct_Marketing__c)) ;
    }
    /*
This method called in "checkElectronicMarketingOptOut" method, to check if the new contact records's ElectronicMarketingOptOut is True or existing contact records's ElectronicMarketingOptOut is changed from false to true.	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isElectronicMarketingOptOutTrue(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null && con.Opt_Out_Electronic_Marketing__c ) || 
            (mapOldCon != Null && con.Opt_Out_Electronic_Marketing__c && (con.Opt_Out_Electronic_Marketing__c != mapOldCon.get(con.Id).Opt_Out_Electronic_Marketing__c)) ;
    }
    /*
This method called in "checkElectronicMarketingOptOut" method, to check if the new contact records's ElectronicMarketingOptOut is False or existing contact records's ElectronicMarketingOptOut is changed from true to false.	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isElectronicMarketingOptOutFalse(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null && !con.Opt_Out_Electronic_Marketing__c ) || 
            (mapOldCon != Null && !con.Opt_Out_Electronic_Marketing__c && (con.Opt_Out_Electronic_Marketing__c != mapOldCon.get(con.Id).Opt_Out_Electronic_Marketing__c)) ;
    }
    /*
This method called in "setElectronicMarketing" method, to check if the contact record's Opt_Out_SMS or Opt_Out_Emails changed	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isSMSorEmailChanged(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null) ||
            ((mapOldCon != Null) && ((con.Opt_Out_SMS_MMS__c != mapOldCon.get(con.Id).Opt_Out_SMS_MMS__c) ||
                                     (con.Opt_Out_Emails__c != mapOldCon.get(con.Id).Opt_Out_Emails__c)));
    }
    /*
This method called in "setAllDirectMarketing" method, to check if the contact record's Opt_Out_Direct_Mail or Opt_Out_Telemarketing changed	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isDirectorTelemarketingChanged(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null) ||
            ((mapOldCon != Null) && ((con.Opt_Out_Direct_Mail_White_Mail__c != mapOldCon.get(con.Id).Opt_Out_Direct_Mail_White_Mail__c) ||
                                     (con.Opt_Out_Telemarketing__c != mapOldCon.get(con.Id).Opt_Out_Telemarketing__c)));
    }
    /*
This method called in "setAllMarketing" method, to check if the contact record's Opt_Out_All_Direct_Marketing or Opt_Out_Electronic_Marketing changed	
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	boolean
*/	
    private boolean isAllDirectorElectronicChanged(Contact con, Map<id,Contact> mapOldCon){
        return (mapOldCon == Null) ||
            ((mapOldCon != Null) && ((con.Opt_Out_Electronic_Marketing__c != mapOldCon.get(con.Id).Opt_Out_Electronic_Marketing__c) ||
                                     (con.Opt_Out_All_Direct_Marketing__c != mapOldCon.get(con.Id).Opt_Out_All_Direct_Marketing__c)));
    }
    /*
This method called in "updateContactFields" method, to set contact records's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	To set contact record Opt Out Values.	
*/	
    private void checkAllDirectMarketingOptOut(Contact con, Map<id,Contact> mapOldCon){
        if(isAllDirectMarketingOptOutTrue(con,mapOldCon)){
            con.Opt_Out_Direct_Mail_White_Mail__c = checked;
            con.Opt_Out_Telemarketing__c = checked;
        }else	if(isAllDirectMarketingOptOutFalse(con,mapOldCon)){
            con.Opt_Out_Direct_Mail_White_Mail__c = !checked;
            con.Opt_Out_Telemarketing__c = !checked;
        }		
    }
    /*
This method called in "updateContactFields" method, to set contact records's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	To set contact record Opt Out Values.	
*/	
    private void checkElectronicMarketingOptOut(Contact con, Map<id,Contact> mapOldCon){
        if(isElectronicMarketingOptOutTrue(con,mapOldCon)){
            con.Opt_Out_SMS_MMS__c = checked;
            con.Opt_Out_Emails__c = checked;			
        }else	if(isElectronicMarketingOptOutFalse(con,mapOldCon)){
            con.Opt_Out_SMS_MMS__c = !checked;
            con.Opt_Out_Emails__c = !checked;			
        }		
    }
    /*
This method called in "updateContactFields" method, to set contact records's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	To set contact record Opt Out Values.	
*/	
    private void setElectronicMarketing(Contact con, Map<id,Contact> mapOldCon){
        if(isSMSorEmailChanged(con,mapOldCon)){
            if(con.Opt_Out_SMS_MMS__c && con.Opt_Out_Emails__c) con.Opt_Out_Electronic_Marketing__c = checked;
            else con.Opt_Out_Electronic_Marketing__c = !checked;
        }		
    }
    /*
This method called in "updateContactFields" method, to set contact records's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	To set contact record Opt Out Values.	
*/	
    private void setAllDirectMarketing(Contact con, Map<id,Contact> mapOldCon){
        if(isDirectorTelemarketingChanged(con,mapOldCon)){
            if(con.Opt_Out_Direct_Mail_White_Mail__c && con.Opt_Out_Telemarketing__c) con.Opt_Out_All_Direct_Marketing__c = checked;
            else con.Opt_Out_All_Direct_Marketing__c = !checked;
        }		
    }
    /*
This method called in "updateContactFields" method, to set contact records's Opt_Out_*(Opt Out Values).
Sprint 20.03, P2OB-4875
inputs	: 	New contact from Trigger.new
Map<id,Contact> mapOldCon --> (Map of Old Contacts)
Output	:	To set contact record Opt Out Values.	
*/	
    private void setAllMarketing(Contact con, Map<id,Contact> mapOldCon){
        if(isAllDirectorElectronicChanged(con,mapOldCon)){
            if(con.Opt_Out_Electronic_Marketing__c && con.Opt_Out_All_Direct_Marketing__c) con.All_Marketing_Opt_Out__c = checked;
            else con.All_Marketing_Opt_Out__c = !checked;
        }		
    }
    
    /*
Description	:	Team SFO, sprint 20.03, P2OB-4875 :: As a system I want all of these existing Process Builder items relating to the ACR Object
now reflecting on the Contact object for the same fields
Coverage	:	testupdateContactFieldsPositive and testupdateContactFieldsNegative and testContactLimtedAuth from ContactTriggerTest
Author		:	Sri
*/
    public void updateContactFields(List<Contact> lstNewCon, Map<id,Contact> mapOldCon){
        if(!isRecursiveUpdateContactFields){
            //For START
            for(Contact con : lstNewCon){
                
                // Sprint 20.04 , P2OB-4985 AC-4 to update the lastVerifiedDate__c and Has_Reviewed__c
                if(!System.isBatch() && profileName!=System.Label.Profile_SystemAdmin){
                    con.lastVerifiedDate__c=System.today();
                    con.Has_Reviewed__c=checked;
                }
                
                if(con.ACRToContact__c) continue;
                updateRelationShipEndDate(con,mapOldCon); //Added as part of P2OB-4979
                checkAllMarketingOptOut(con,mapOldCon);
                checkAllDirectMarketingOptOut(con,mapOldCon);
                checkElectronicMarketingOptOut(con,mapOldCon);
                setElectronicMarketing(con,mapOldCon);
                setAllDirectMarketing(con,mapOldCon);
                setAllMarketing(con,mapOldCon);
                
                
            } //For END
        }
        
        isRecursiveUpdateContactFields=True;
    }
    
    
    /*      
Description     : Populating mailing/Office Address from cscrm__Address__c, Invoked in Before Insert and Before Update Methods.
Sprint          : 20.05 P2OB-4924 
Input Param     : trigger.oldmap, trigger.new, trigger.newmap 
Output Result:  : Contact Office/Mailing Address will get populated.
*/
    public void updateConOfficeAddress(map<id, Contact> oldContactMap,list<Contact> newContactList, map<id, Contact> newContactMap){
        try{
            if(!isRecursiveUpdateConOfficeAddress){
                system.debug('Check For Recurssion'+ ContactTriggerHandler.recursiveCheckForAddress);
                //list<cscrm__Address__c> addressLst = new list<cscrm__Address__c>();
                set<Id> addressId = new set<id>();
                set<Id> accountIdSet = new set<id>();
                
                
                for(Contact con : newContactList){
                    if(con.accountid !=null){
                        accountIdSet.add(con.accountId);
                    }
                    if(con.cscrm__Address__c != null){
                        addressId.add(con.cscrm__Address__c);
                    }
                }
                
                if(!accountIdSet.isEmpty()){
                    accMapForConOfficeAddress.putall([SELECT id,recordType.Name FROM Account WHERE id IN: accountIdSet]);
                }
                if(!addressId.isEmpty()){
                    addressMapConOfficeAddress.putall([SELECT id,locality__c,cscrm__State_Province__c,cscrm__Zip_Postal_Code__c,cscrm__Country__c,Sub_Address_Level_1_calc__c,Sub_Address_Level_2_calc__c,Sub_Address_Level_3_calc__c,Sub_Address_Level_4_calc__c,cscrm__Building_Name__c,Street_calc__c FROM cscrm__Address__c where id in: addressId]);
                }
                
                //Invoked by updateconmailingAddress Method
                updateconmailingAddress(oldContactMap,newContactList);				
                
            }
            isRecursiveUpdateConOfficeAddress=true;
        }catch(Exception ex){
            system.debug('Exception:::: ContactTriggerHelper Class:::: updateConOfficeAddress Method'+ Ex.getMessage());
        }
    }
    
    /*      
Description     : Populating mailing/Office Address from cscrm__Address__c, Invoked in updateConOfficeAddress Methods.
Sprint          : 20.05 P2OB-4924 
Input Param     : trigger.oldmap, trigger.new, trigger.newmap 
Output Result:  : Contact Office/Mailing Address will get populated.
*/
    private void updateconmailingAddress(map<id, Contact> oldContactMap, list<Contact> newContactList){
        String accountRecordTypeName;
        cscrm__Address__c cscrmAddress;
        Account accountRecord;
        // Start For loop
        for(contact newCon : newContactList){
            if(!accMapForConOfficeAddress.isEmpty()){
                accountRecord=accMapForConOfficeAddress.get(newCon.accountId);
            }
            if(accountRecord!= null){
                accountRecordTypeName=accountRecord.RecordType.Name;
                Boolean ifCheck=((accountRecordTypeName == Label.Account_RecordType_Enterprise && 
                                  !string.isBlank(newCon.cscrm__Address__c)) && 
                                 (oldContactMap != Null && 
                                  newCon.cscrm__Address__c != oldContactMap.get(newCon.Id).cscrm__Address__c || 
                                  oldContactMap == Null));
                
                Boolean elseIfCheck=(accountRecordTypeName == Label.Account_RecordType_Enterprise && 
                                     string.isBlank(newCon.cscrm__Address__c)  && 
                                     oldContactMap != Null);
                if(ifCheck){
                    if(!addressMapConOfficeAddress.isEmpty()){
                        cscrmAddress=addressMapConOfficeAddress.get(newCon.cscrm__Address__c);
                    }
                    if(cscrmAddress!=null){
                        newCon.mailingstreet = offcieStreeAddress(cscrmAddress);
                        newCon.mailingcity = cscrmAddress.Locality__c;
                        newCon.mailingstate = cscrmAddress.cscrm__State_Province__c;
                        newCon.mailingcountry = cscrmAddress.cscrm__Country__c;
                        newCon.mailingpostalcode = cscrmAddress.cscrm__Zip_Postal_Code__c;
                    }
                }
                else if(elseIfCheck){
                    newCon.mailingstreet = '';
                    newCon.mailingcity = '';
                    newCon.mailingstate = '';
                    newCon.mailingcountry = '';
                    newCon.mailingpostalcode = '';
                }
            }
        }
        //End For loop
    }
    /*      
Description     : This Method returns mailing street. Invoked from updateConOfficeAddress Method.
Sprint          : 20.05 P2OB-4924 
Input Param     : newCon (Contact Record), cscrmAddress (addresses Map) 
Output Result:  : Contact Office/Mailing Street will get populated.
*/
    
    private string offcieStreeAddress(cscrm__Address__c cscrmAddress){
        
        string subAddressLevel1 = cscrmAddress.Sub_Address_Level_1_calc__c;
        string subAddressLevel2 = cscrmAddress.Sub_Address_Level_2_calc__c;
        string subAddressLevel3 = cscrmAddress.Sub_Address_Level_3_calc__c;
        string subAddressLevel4 = cscrmAddress.Sub_Address_Level_4_calc__c;
        string buildingName = cscrmAddress.cscrm__Building_Name__c;
        string street = cscrmAddress.Street_calc__c;
        string mailingStreet = '';
        if(!string.isBlank(subAddressLevel1)){
            mailingStreet = mailingStreet + subAddressLevel1 + ' ';
        }
        if(!string.isBlank(subAddressLevel2)){
            mailingStreet = mailingStreet + subAddressLevel2 + ' ';
        }
        if(!string.isBlank(subAddressLevel3)){
            mailingStreet = mailingStreet + subAddressLevel3 + ' ';
        }
        if(!string.isBlank(subAddressLevel4)){
            mailingStreet = mailingStreet + subAddressLevel4 + ' ';
        }
        if(!string.isBlank(buildingName)){
            mailingStreet = mailingStreet + buildingName + ' ';
        }
        if(!string.isBlank(street)){
            mailingStreet = mailingStreet + street + ' ';
        }
        return mailingStreet;
    }
    
    
    /*
Description	:	Team SFO, sprint 20.04, P2OB-4979 :: As a sales user I want update the Contact status to either Active or Inactive So that I can maintain the most updated contact information	
Author		:	Pallavi B
*/
    public void updateRelationShipEndDate(Contact con,Map<id,Contact> mapOldCon){
        if(((mapOldCon == Null) && (con.Contact_Status__c =='Inactive')) ||((mapOldCon != Null) && ((con.Contact_Status__c != mapOldCon.get(con.Id).Contact_Status__c))&&(con.Contact_Status__c =='Inactive'))){
            con.Relationship_End_Date__c = Date.today();
        }else{
            con.Relationship_End_Date__c = Null;
        }
        
    }
    
    /*-------------------------------------------------------------------------------
EDGE        -171189
Method      -updateContactStatus
Description -Check if Notifiaction preferences associated with contact before making it inactive
Author      -Aishwarya 
---------------------------------------------------------------------------------*/ 
    public void updateContactStatus(Map<Id,Contact> newMap,Map<Id,Contact> oldMap){
        if(newMap !=null && oldMap !=null){
            List<Notification_Preference__c> listOfNotificationRecords=[SELECT id,Contact_Id__c from Notification_Preference__c WHERE Contact_Id__c IN :newMap.keyset()];
            for(ID key :newMap.keyset()){
                if(newMap.get(key).Contact_Status__c != oldMap.get(key).Contact_Status__c && newMap.get(key).Contact_Status__c=='Inactive' && listOfNotificationRecords.size()>0){
                    system.debug('NewMap'+newMap.get(key));
                    String Name=(newMap.get(Key).FirstName !=null)?newMap.get(Key).FirstName:'';
                    newMap.get(key).addError(Name+ newMap.get(Key).LastName +' is currently receiving IR/Domestic notification preferences. Please click on Edit Notification to reassign preferences to another contact'); 
                    //newMap.get(key).addError(newMap.get(Key).Name +' is currently receiving IR/Domestic notification preferences. Please click on Edit Notification to reassign preferences to another contact'); 
                    
                }
            }
        }
    }
    
    /* Description :     TO check if the contact is being deactivated or Remove
     *  				 "Billing or create and edit user permissions"
     *  			     is not last contact with this access on Account
     * Team        :     SFO 
     * Sprint      :     21.11 
     * Stroy       :     DIGI-4057 
     * Author      :     Chhaveel Thakur
     * Test Class  :     ContactTriggerHelper_Test
     * Modified Info :   DIGI-4062 Sprint 21.14 ,pallavi B(Team SFO)
     */ 
 public void lastContactwithBillingAccessCheck(Map<Id,Contact> newMap,Map<Id,Contact> oldMap){
        integer contactRecordCount;
        
        List<Id> accountIdList=new List<Id>();
        List<Id> contactIdList=new List<Id>();
        if(newmap != null && !newMap.isEmpty() && oldmap !=null && !oldmap.isEmpty()){
            for(ID key : newmap.keyset()){
                if(newmap.containskey(key) && newmap.get(key)!=null ){
                    contactIdList.add(key);
                    accountIdList.add(newmap.get(key).AccountId);
                }
            }
            if(!accountIdList.isEmpty() && !contactIdList.isEmpty()){
                //fetching all the related contact for concerened accounts
                Map<Id,Contact> contactMap=recordcheck(accountIdList, contactIdList);
                for(ID key : newmap.keyset()){
                    
                    
                    if(newmap.containskey(key) && oldmap.containskey(key) && newmap.get(key)!=null && oldmap.get(key)!=null && 
                       oldmap.get(key).Contact_Status__c == 'Active' ){
                           // Getting the error messge from Custom Metadata : SFO_Custom_Labels__mdt
                                String firstConditionErrroMsg = SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ newmap.get(key).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_Billing_Error_1')?.Label_Value__c ;
                                String secondConditionErrroMsg = SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ newmap.get(key).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_User_Management_Error_1')?.Label_Value__c ;
                                String thirdConditionErrroMsg = SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ newmap.get(key).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_User_Management_Error_2')?.Label_Value__c ;
                                String fourthConditionErrroMsg =  newmap.get(key).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_Billing_Error_2')?.Label_Value__c ;                    
                                String fifthConditionErrroMsg = SFO_Custom_Labels__mdt.getInstance('ContactError')?.Label_Value__c +' '+ newmap.get(key).Account_Name__c +' '+ SFO_Custom_Labels__mdt.getInstance('Contact_Invoice_notification')?.Label_Value__c ;
                           
                           // AC1 first scenario
                           // checking if billing permission is changed
                           if(newmap.get(key).Raise_Billing_Disputes__c == false && 
                              newmap.get(key).Raise_Billing_Disputes__c != oldmap.get(key).Raise_Billing_Disputes__c ){
                                  //checking the contact record count with same characterstics
                                  contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'first');
                                  if(contactRecordCount == 0){
                                      newmap.get(key).adderror(firstConditionErrroMsg );
                                  }
                              }
                           
                           // AC1 second scenario
                           // checking if billing permission is changed when Telstra_Connect_Admin__c permission is also true
                           if(newmap.get(key).Raise_Billing_Disputes__c == false && 
                              oldmap.get(key).Telstra_Connect_Admin__c == True &&
                              newmap.get(key).Raise_Billing_Disputes__c != oldmap.get(key).Raise_Billing_Disputes__c){
                                  //checking the contact record count with same characterstics
                                  contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'third');
                                  if(contactRecordCount == 0){
                                      newmap.get(key).adderror(fourthConditionErrroMsg );
                                  }
                              }
                           
                           // AC2 scenario
                           // checking if Telstra_Connect_Admin__c permission is changed when Telstra_Connect_Status__c and Telstra_Connect_Opt_Out__c is not considered
                           if(newmap.get(key).Telstra_Connect_Admin__c == false &&
                              newmap.get(key).Telstra_Connect_Admin__c != oldmap.get(key).Telstra_Connect_Admin__c &&
                              oldmap.get(key).Telstra_Connect_Status__c != System.Label.ContactTconnectStatusRA){
                                  //checking the contact record count with same characterstics
                                  contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'second');
                                  if(contactRecordCount == 0){
                                      newmap.get(key).adderror(secondConditionErrroMsg);
                                  }
                              }
                           // AC3 scenario
                           // checking if Telstra_Connect_Admin__c permission is changed
                           if(newmap.get(key).Telstra_Connect_Admin__c == false &&
                              newmap.get(key).Telstra_Connect_Admin__c != oldmap.get(key).Telstra_Connect_Admin__c && 
                              oldmap.get(key).Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA){
                                  //checking the contact record count with same characterstics
                                  contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'third');
                                  if(contactRecordCount == 0){
                                      newmap.get(key).adderror(thirdConditionErrroMsg);
                                  }
                              }
                           // AC2 and AC3 scenario
                           // checking if the Contact_Status__c changed when Telstra_Connect_Admin__c is true ( for each value of Telstra_Connect_Status__c )
                           if(newmap.get(key).Contact_Status__c != oldmap.get(key).Contact_Status__c){
                               if(oldmap.get(key).Telstra_Connect_Admin__c == True){
                                   if(oldmap.get(key).Telstra_Connect_Status__c != System.Label.ContactTconnectStatusRA){
                                       //checking the contact record count with same characterstics
                                       contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'second');
                                       if(contactRecordCount == 0){
                                           newmap.get(key).adderror(secondConditionErrroMsg);
                                       }
                                   } else {
                                       contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'third');
                                       if(contactRecordCount == 0){
                                           newmap.get(key).adderror(thirdConditionErrroMsg );
                                       }
                                   }
                                   // AC1 first scenario
                                   // checking if the Contact_Status__c changed when Raise_Billing_Disputes__c is true
                               }else if(oldmap.get(key).Raise_Billing_Disputes__c == True){
                                   
                                   //checking the contact record count with same characterstics
                                   contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'first');
                                   if(contactRecordCount == 0){
                                       newmap.get(key).adderror(firstConditionErrroMsg);
                                   }
                               }
                           }
                           // AC3 scenario
                           // checking if the Telstra_Connect_Opt_Out__c changed when Telstra_Connect_Admin__c is true
                           if(newmap.get(key).Telstra_Connect_Opt_Out__c != oldmap.get(key).Telstra_Connect_Opt_Out__c &&
                              oldmap.get(key).Telstra_Connect_Opt_Out__c == false && 
                              oldmap.get(key).Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA ){
                                  if(oldmap.get(key).Telstra_Connect_Admin__c == True){
                                      
                                      //checking the contact record count with same characterstics
                                      contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'third');
                                      if(contactRecordCount == 0){
                                          newmap.get(key).adderror(thirdConditionErrroMsg);
                                      }
                                      // AC1 first scenario
                                      // checking if the Telstra_Connect_Opt_Out__c changed when Raise_Billing_Disputes__c is true
                                  } else if(oldmap.get(key).Raise_Billing_Disputes__c == True){
                                      
                                      //checking the contact record count with same characterstics
                                      contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'first');
                                      if(contactRecordCount == 0){
                                          newmap.get(key).adderror(firstConditionErrroMsg);
                                      }
                                  }
                              }
                           //Added below code as part of DIGI-4062 Sprint 21.14.starts here
                           boolean oldRecContainsInvArvNotf = (oldmap.get(key).Invoice_notifications__c <> null && oldmap.get(key).Invoice_notifications__c.contains(System.Label.ContactInvoiceArrivalNotification));
                           //old and new records or not null so chcking the Invoice_notifications__c
                            if(oldRecContainsInvArvNotf && newMap.get(key).Invoice_notifications__c <> null && !newmap.get(key).Invoice_notifications__c.contains(System.Label.ContactInvoiceArrivalNotification)){
                               contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'fourth');
                               if(contactRecordCount == 0){
                                   newmap.get(key).adderror(fifthConditionErrroMsg);
                               }
                            }
                            //new Invoice_notifications__c is null and old Invoice_notifications__c is not null so chcking old Invoice_notifications__c
                            else if(oldRecContainsInvArvNotf && newMap.get(key).Invoice_notifications__c == null){
                               contactRecordCount = contactRecordCheck( newmap.get(key).AccountId, key,contactMap,'fourth');
                               if(contactRecordCount == 0){
                                   newmap.get(key).adderror(fifthConditionErrroMsg);
                               }
                            }
                           //DIGI-4062 ENDS here
                       }
                }
            }
        }
    }    
    /* Description :     TO check if the contact is being deactivated or Remove
     *  				 "Billing or create and edit user permissions"
     *  			     is not last contact with this access on Account
     * Team        :     SFO 
     * Sprint      :     21.11 
     * Stroy       :     DIGI-4057 
     * Author      :     Chhaveel Thakur
     * Test Class  :     ContactTriggerHelper_Test
     * Modified Info :   DIGI-4062 Sprint 21.14 ,pallavi B(Team SFO)
	 */
    private Map<Id,Contact> recordcheck(List<id> accIdList, List<id> conIdList){
        //getting the records that are associated with te same Account
        Map<ID, AccountContactRelation> listofActiveContact = new Map<ID, AccountContactRelation>([SELECT id,AccountId, contactId from AccountContactRelation
                                                                                                   WHERE AccountId IN: accIdList and
                                                                                                   ContactId NOT IN: conIdList ]);
        set<id> contactIdSet = new set<id>();
        for(ID acrId : listofActiveContact.keyset()){
            contactIdSet.add(listofActiveContact.get(acrId).contactId);
        }
        //Checking if contact record with same characterstics exists
        //fetching all related contact for the Account reclated to contact that calls the trigger
        Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id,AccountId, Raise_Billing_Disputes__c , Telstra_Connect_Admin__c ,
                                                          Contact_Status__c,Telstra_Connect_Opt_Out__c,Telstra_Connect_Status__c,Invoice_notifications__c
                                                          from contact where id IN :contactIdSet
                                                          and Contact_Status__c = 'Active']); //Modified as part of DIGI-4062 BY adding a new field(Invoice_notifications__c) in query
        return contactMap;
    }
    
    /* Description :     TO check if the contact is being deactivated or Remove
     *  				 "Billing or create and edit user permissions"
     *  			     is not last contact with this access on Account
     * Team        :     SFO 
     * Sprint      :     21.11 
     * Stroy       :     DIGI-4057 
     * Author      :     Chhaveel Thakur
     * Test Class  :     ContactTriggerHelper_Test
     * Modified Info :   DIGI-4062 Sprint 21.14 ,pallavi B(Team SFO)
	 */
    private Integer contactRecordCheck( Id accId, Id conId,Map<Id,Contact> contactMap,String whichScenario){
        integer recordcountfirst = 0;
        integer recordcountsecond = 0;
        integer recordcountthird = 0;
        integer recordcountfourth = 0; //Added as part of DIGI-4062 Sprint 21.14 . to store count of same ACR recods with invoice arrival notification 
        if(!contactMap.isEmpty()){
            for (Contact cc: contactMap.values()){
                //Checking if contact records with Raise_Billing_Disputes__c true exists with matching criteria
                if(cc.Contact_Status__c == 'Active' && cc.AccountId == accId){
                    if(whichScenario == 'first' && 
                       cc.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA && 
                       cc.Raise_Billing_Disputes__c == true  &&
                       cc.Telstra_Connect_Opt_Out__c == false){
                           recordcountfirst++;
                       }
                    //Checking if contact records with Telstra_Connect_Admin__c true exists with matching criteria(Telstra_Connect_Opt_Out__c and Telstra_Connect_Status__c not considered here)
                    else if(whichScenario == 'second' && cc.Telstra_Connect_Admin__c == true){
                        recordcountsecond++;
                    }
                    //Checking if contact records with Telstra_Connect_Admin__c true exists with matching criteria
                    else if(whichScenario == 'third' && 
                            cc.Telstra_Connect_Admin__c == true &&                            
                            cc.Telstra_Connect_Opt_Out__c == false && 
                            cc.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA){
                                recordcountthird++;  
                            }
                    //Added as part of DIGI-4062 .
                     else if(whichScenario == 'fourth' && 
                               cc.Telstra_Connect_Status__c == System.Label.ContactTconnectStatusRA && 
                               cc.Raise_Billing_Disputes__c == true  &&
                               cc.Telstra_Connect_Opt_Out__c == false &&
                               cc.Invoice_notifications__c!= null && cc.Invoice_notifications__c.contains(System.Label.ContactInvoiceArrivalNotification)){
                                   recordcountfourth++;
                               }
                }
            }
            
            if(whichScenario == 'first'){
                return recordcountfirst;
            }else if(whichScenario == 'second'){
                return recordcountsecond;
            }else if(whichScenario == 'third'){
                return recordcountthird;
            }
            //Added as part of DIGI-4062
            else if(whichScenario == 'fourth'){
                return recordcountfourth;
            }
            
            // returing 1 will not fire any error 
            return 1;
        } else{
            // No record in contactMap means no related record found on Account so throw error
            return 0;
        }
    }
    
    /* Description :  To avoid for duplicate values in Invoice NOtificatio field on contact from backend 
     * Team        :     SFO 
     * Sprint      :     21.14 
     * Stroy       :     DIGI-4062
     * Author      :     Pallavi B
     * Test Class  :     ContactTriggerHelper_Test
	 */ 
    public void duplicateCheckOnInvoiceNotification(Map<Id,Contact> oldMap,List<Contact> lstNewCon){
        List<String> splitInvoiceValues = new List<String>();
        String InvoiceValues;
        if(!isRecursiveduplicateCheckOnInvoice){
            if(!lstNewCon.isEmpty()){
                for(contact con : lstNewCon){
                    InvoiceValues= con.Invoice_notifications__c;
                    if(InvoiceValues == null || InvoiceValues == ''){
                        continue; // skip this iteration if Invoice_notifications__c is null or empty 
                    }
                    //split Invoice_notifications__c multi select picklist value and keep them in array 
                    if((oldMap==null && con!=null) || (oldMap.Containskey(con.id) && con.Invoice_notifications__c != oldMap.get(con.id).Invoice_notifications__c)){
                        splitInvoiceValues = con.Invoice_notifications__c!=null && con.Invoice_notifications__c!=''?con.Invoice_notifications__c.split(';') : new List<String>{};
                            }
                    //loop over the list of invoice notifcaiton values for this contact
                    if(splitInvoiceValues!=null){
                        for(String invValue : splitInvoiceValues){
                            //each invoice notification should have the single refernece(indexOf() && lastIndexOf() should return the same index) in Invoice_notifications__c
                            ////if not add an error to this contact
                            if(InvoiceValues.indexOf(invValue) <> InvoiceValues.lastIndexOf(invValue)){ 
                                con.addError(System.Label.DuplicateContactInvoiceArrNotf);
                            }
                        }
                  }
                }
            }
            isRecursiveduplicateCheckOnInvoice=true;
        }
    }   


/*******************************************************************
@Class Name     :   verifyAccountOnContactUpdate
@Description    :   Method Which Returns User Profile Info
@Sprint         :   21.14 (DIGI-3444)
@Author         :   Sri (Team SFO)
@CreateDate     :   13/10/2021
@References     :   beforeupdate
@TestCoverage   :   ContactTriggerHelper_Test.verifyAccountOnContactUpdateTest
*********************************************************************/
    //to control the recurssion
    private	boolean isFirstRunVerifyAccountOnContactUpdate = false; 
    private Id conEntRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.label.Contact_layout_record_type)?.getRecordTypeId();
    public void verifyAccountOnContactUpdate(list<Contact> conList, Map<id,Contact> mapOldCon){
        //isFirstRunVerifyAccountOnContactUpdate deafult false and on first run make it true
        if(isFirstRunVerifyAccountOnContactUpdate){
            return;
        }
        isFirstRunVerifyAccountOnContactUpdate = true;
        //Contact_Layout recodtype
        conEntRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.label.Contact_layout_record_type)?.getRecordTypeId();
        Set<Id> accountIDs = new Set<Id>(); //holds accountId's of the contacts
        String errMsgForNotSameHierarchy = System.label.errMsgActUpdateOnContact; 
        
        for(Contact con :conList){ //loop over list of contacts and capture accountIds to get account information 
            //contact should be enterprise contact and accountid should not be null
            Boolean isAccountNotChanged = (conEntRecTypeId == null || con.RecordTypeId <> conEntRecTypeId || con.AccountId == null || (mapOldCon?.get(con.Id)?.AccountId == null) || (con.AccountId == mapOldCon?.get(con.Id)?.AccountId));
            if(isAccountNotChanged){
                continue;
            }
            //if account of this contact is changed then add the old and new accounts to set for query the CIDN info 
            if(con.AccountId != mapOldCon.get(con.Id).AccountId){
                accountIDs.add(con.AccountId);
                accountIDs.add(mapOldCon.get(con.Id).AccountId);
            }
        }
        
        if(accountIDs.isEmpty()){
            return; //in the given contactlist if there were no records for which account is not changed then no need of running the next code
        }
        
        Map<id,Account> accountIdMap = new Map<id,Account>([select id, name, 	CIDN__c, Ultimate_Parent_CIDN__c from Account where id =:accountIDs ]);
        Boolean isAccountIdNotChanged, actIdChangedUlti2Ulti, oldActIsNotFromNewActHierarchy, newActIsNotFromOldActHierarchy, bothAreChildActsNotFromSameHierarchy;
        Account oldAct, newAct;
        for(Contact con :conList){ //loop over list of contacts and capture accountIds to get account information 
            //contact should be enterprise contact 
            //and old & new accountid's should not be null 
            //and old & new accountid's should not be equal            
            isAccountIdNotChanged = (conEntRecTypeId == null || con.RecordTypeId <> conEntRecTypeId || con.AccountId == null || (mapOldCon?.get(con.Id)?.AccountId == null) || (con.AccountId == mapOldCon?.get(con.Id)?.AccountId));
            if(isAccountIdNotChanged){
                continue;
            }
            oldAct = accountIdMap.get(mapOldCon.get(con.Id).AccountId);
            newAct = accountIdMap.get(con.AccountId);
            if(oldAct == null || newAct == null){
                continue;
            }
            //both old and new account's are ULTIMATEs (Ultimate_Parent_CIDN__c values are null)
            actIdChangedUlti2Ulti = ((newAct.Ultimate_Parent_CIDN__c == null) && (newAct.Ultimate_Parent_CIDN__c == oldAct.Ultimate_Parent_CIDN__c));
            
            //new account is ULTIMATE & old account is NOT ULTIMATE then old account's Ultimate_Parent_CIDN__c should be equal to new account's CIDN__c
            oldActIsNotFromNewActHierarchy = ((newAct.Ultimate_Parent_CIDN__c == null) && (oldAct.Ultimate_Parent_CIDN__c <> null) && (newAct.CIDN__c <> oldAct.Ultimate_Parent_CIDN__c));
            
            //new account is NOT ultimate & old account is ULTIMATE then old account's CIDN__c should be equal to new account's Ultimate_Parent_CIDN__c
            newActIsNotFromOldActHierarchy = ((newAct.Ultimate_Parent_CIDN__c <> null) && (oldAct.Ultimate_Parent_CIDN__c == null) && (oldAct.CIDN__c <> newAct.Ultimate_Parent_CIDN__c));
            
            //new account is NOT ultimate & old account is NOT ULTIMATE then old account's Ultimate_Parent_CIDN__c should be equal to new account's Ultimate_Parent_CIDN__c
            bothAreChildActsNotFromSameHierarchy = ((newAct.Ultimate_Parent_CIDN__c <> null) && (oldAct.Ultimate_Parent_CIDN__c <> null) && (oldAct.Ultimate_Parent_CIDN__c <> newAct.Ultimate_Parent_CIDN__c));
            
            if(actIdChangedUlti2Ulti || oldActIsNotFromNewActHierarchy || newActIsNotFromOldActHierarchy || bothAreChildActsNotFromSameHierarchy){
                con.addError(errMsgForNotSameHierarchy);
            }

        }
        
    }
}