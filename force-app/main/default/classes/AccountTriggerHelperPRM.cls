/* P2OB-6753 - Hawaii - 05/06/2020 - commenting the code for License Limit (Business want to remove it later they can enable it again so commenting only instead of removing the code)*/
public with sharing class AccountTriggerHelperPRM  {
    /* USER STORY- 13148 : method to update Contact Onboarding Status
added by Ramya on 11/4
* P2OB-6753 - Hawaii - 05/06/2020 - commenting the code for License Limit (Business want to remove it later they can enable it again so commenting only instead of removing the code)
*/

    public static void updateContactOnboardingStatus(Account[] oldAccounts, Map<ID, Account> oldAccountMap, Account[] updatedAccounts, Map<ID, Account> updateAccountsMap){
        List<Contact> conList = new List<Contact>();
        List<id> conidList = new List<id>();
        List<id> conidListforupdate = new List<id>();
        List<id> listOfUnaccUsers = new List<id>();
        List<id> listOfAccUsers = new List<id>();

        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();

        map<id, List<user>> userconMap = new map<id, List<user>>();
        id recType = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();  // fetch partner contact record type

        id rtypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_PartnerInternational).getRecordTypeId();
        id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();

        Map<id,Account> accMap = new Map<id,Account>([select id,IsPartner,Account_Status__c,RecordTypeId,Overall_Accreditation__c from Account where id in:updateAccountsMap.keyset() AND RecordTypeId =:rtypeId2]);
        conList = [select id,name,Onboarding_Status__c,Recordtype.Name,RecordtypeId,accountID from contact where AccountId in :accMap.keyset() and RecordtypeId =: recType];

        List<Contact> updateContList = new List<Contact>();
        List<Contact> updateAccreditation = new List<Contact>();
        for(Contact cnt: conList){
            conidList.add(cnt.id);
        }
        for(user u: [select id, name, contactid, profile.name,FederationIdentifier from user where contactid IN : conidList]){
            if(u.contactid!=null){
                if(userconMap.get(u.contactid)!=null)
                    userconMap.get(u.contactid).add(u);
                else
                    userconMap.put(u.contactid, new list<user>{u});
            }
        }

        for(Contact cnt: conList){
            if(cnt.AccountId!=null) {
                account accRef = accMap.get(cnt.AccountId);
                //updates contacts only if account status is changed and record type belongs to partners
                if(oldAccountMap.get(accRef.id).Account_Status__c!=null && accRef.Account_Status__c!=null  && oldAccountMap.get(accRef.id).Account_Status__c!=accRef.Account_Status__c && (accRef.RecordTypeId == rtypeId1 || accRef.RecordTypeId == rtypeId2))
                {
                    if((userconMap.get(cnt.id)!=null && userconMap.get(cnt.id).size()>0) && accRef.IsPartner==TRUE && (accRef.RecordTypeId == rtypeId1 || accRef.RecordTypeId == rtypeId2)){
                        {
                            system.debug('my test---');
                            if(!(oldAccountMap.get(accRef.id).Account_Status__c=='Frozen' && accRef.Account_Status__c == PRMConstants.PRM_Account_Status_Active ))
                                cnt.Onboarding_Status__c=accRef.Account_Status__c == PRMConstants.PRM_Account_Status_Active?PRMConstants.PRM_Account_Status_Active:PRMConstants.PRM_Account_Status_InActive;
                        }
                        if( oldAccountMap.get(accRef.id)!=null && oldAccountMap.get(accRef.id).Account_Status__c!=PRMConstants.PRM_Account_Status_Active && accRef.Account_Status__c == PRMConstants.PRM_Account_Status_Active && accRef.Overall_Accreditation__c != 'No Accreditation')
                            conidListforupdate.add(cnt.id);
                        // deactivate the Propect partner who completes the application and No accrediated -- added by Saran --> EDGE -70311
                        if( oldAccountMap.get(accRef.id)!=null && oldAccountMap.get(accRef.id).Account_Status__c != PRMConstants.PRM_Account_Status_Active && accRef.Account_Status__c == PRMConstants.PRM_Account_Status_Active && accRef.Overall_Accreditation__c == 'No Accreditation'){
                            cnt.Onboarding_Status__c = PRMConstants.PRM_Account_Status_InActive;
                            system.debug('cnt.Onboarding_Status__c ===>' + cnt.Onboarding_Status__c);
                            updateAccreditation.add(cnt);
                            listOfUnaccUsers.add(cnt.id);
                        }//end of if condition (EDGE -70311)

                    }

                    if(oldAccountMap.get(accRef.id)!=null  && oldAccountMap.get(accRef.id).Account_Status__c!=PRMConstants.PRM_Account_Status_Active && accRef.Account_Status__c==PRMConstants.PRM_Account_Status_Active &&  accRef.RecordTypeId == rtypeId2)
                        cnt.Community_User_Type__c=PRMConstants.PRM_Community_User_Type_Domestic;
                    else if(oldAccountMap.get(accRef.id)!=null  && oldAccountMap.get(accRef.id).Account_Status__c!=PRMConstants.PRM_Account_Status_Active && accRef.Account_Status__c ==PRMConstants.PRM_Account_Status_Active && accRef.RecordTypeId == rtypeId1)
                        cnt.Community_User_Type__c=PRMConstants.PRM_Community_User_Type_International;
                    updateContList.add(cnt);
                }
                //Activate the accrediated prospect partner -- added by Saran
                if(oldAccountMap.get(accRef.id)!=null && accRef.Overall_Accreditation__c != 'No Accreditation' && oldAccountMap.get(accRef.id).Overall_Accreditation__c!=accRef.Overall_Accreditation__c ){
                    cnt.Onboarding_Status__c = PRMConstants.PRM_Account_Status_Active;
                    system.debug('cnt.Onboarding_Status__c ===>' + cnt.Onboarding_Status__c);
                    updateAccreditation.add(cnt);
                    listOfAccUsers.add(cnt.id);
                    system.debug('listOfAccUsers ===>' + listOfAccUsers);
                }//end of if condition (EDGE -70311)

            }//close -- if account id not eqaul to null
        }//for close

        system.debug('updateContList'+updateContList);
        system.debug('conidListforupdate'+conidListforupdate);
        system.debug('listOfUnaccUsers ===>' + listOfUnaccUsers);
        system.debug('listOfAccUsers ===>' + listOfAccUsers);
        system.debug('updateAccreditation ===>' + updateAccreditation);
        if(updateContList.size()>0)
            update updateContList;
        if(updateAccreditation.size()>0)
            update updateAccreditation;
        if(conidListforupdate.size()>0)
            AccountTriggerHelperPRM.CallPIMs(conidListforupdate,'MANAGEUSER','updateUser','PimsMicroserviceManageUserBatch');
        if(listOfAccUsers.size()>0)
            AccountTriggerHelperPRM.CallPIMs(listOfAccUsers,'MANAGEUSER','updateUser','PimsMicroserviceManageUserBatch');
        if(listOfUnaccUsers.size()>0)
            AccountTriggerHelperPRM.CallPIMs(listOfUnaccUsers,'MANAGEUSER','deactivateUser','PimsMicroserviceManageUserBatch');

    }

    /*
* Method to create New TOSA application
* EDGE-30951] <Technical story > - Process Builder to Workflow /apex code - EDGE PRM Account Applicable Forms -TOSA Form
Added by SARAN
*/
    public static void createTOSAApplication(Account[] updatedAccounts,Map<ID, Account> oldAccountMap){

        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        Id partnerConRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();

        system.debug('test the ACCrecordtype'+partnerAccRecID);
        system.debug('test the CONrecordtype'+partnerConRecID);

        //updatedAccounts = PhoenixGlobalUtil.accountsByRecType(updatedAccounts, partnerAccRecID);//Jernej: trim the accounts list

        //if(updatedAccounts !=null && !updatedAccounts.isEmpty()){ //Jernej: make sure there are partner accounts before running the query
            list<Account> acc1 = [select id,name,Partner_Application__c,Telstra_Online_Service_Agreement__c,
                                  Partner_Application__r.Nominated_Contact_Person__c,Partner_Application__r.NominateContactEmail__c,Partner_Application__r.NominateContactPhone__c from Account
                                  where id IN: updatedAccounts AND RecordTypeId =: partnerAccRecID];
            system.debug('new list'+acc1);
            PRM_Default__c prmDefault = PRM_Default__c.getOrgDefaults();
            list<Application__c> applist= new list<Application__c>();
            list<Contact> conlist= new list<Contact>();
            String loggedinProfileId = UserInfo.getProfileId();
            Profile loggeduserprofile = [SELECT Id, Name FROM Profile where id = :loggedinProfileId];
            system.debug('INDIRECT'+prmconstants.PRM_Profile_IndirectChannelManager);

            if (loggeduserprofile.Name == prmconstants.PRM_Profile_IndirectChannelManager) {

                for(Account a : acc1 ){
                    if ((oldAccountMap!=null && oldAccountMap.get(a.id).Telstra_Online_Service_Agreement__c != True && a.Telstra_Online_Service_Agreement__c == True ) || (a.Telstra_Online_Service_Agreement__c == True && oldAccountMap==null))
                    {
                        //creates TOSA application
                        Application__c app= new Application__c();
                        app.RecordTypeId = prmDefault.TOSARecordTypeId__c;
                        app.Applicant_Name__c = PRMConstants.PRM_Application_Name;
                        app.Status__c = prmconstants.PRM_Application_Status;
                        app.Account__c = a.Id;
                        app.ApplicationType__c = prmconstants.PRM_ApplicationType_TOSA;
                        applist.add(app);
                    }
                    else if(oldAccountMap==null && a.Partner_Application__c != null )
                    {
                        //Creates related Contact
                        Contact con = new Contact();
                        con.AccountId = a.Id;
                        con.LastName = a.Partner_Application__r.Nominated_Contact_Person__c;
                        con.Email = a.Partner_Application__r.NominateContactEmail__c;
                        con.OTP_Mobile_Phone_Number__c = a.Partner_Application__r.NominateContactPhone__c;
                        con.RecordTypeId = partnerConRecID;
                        conlist.add(con);
                    }
                }
                try{
                    if(applist.size()>0){
                        insert applist;
                    }
                    else if(conlist.size()>0){
                        insert conlist;
                        system.debug('contactlist***'+conlist);
                    }
                }catch(Exception e ){
                    System.debug(e );
                }
            }
        //} // end if
    }//end of createTOSAApplication method SARAN


    /* Method : UpdateApplicationChecks
Description: This method will invoke a Flow and will created Application Modules
Createdby : Uday on July 16th 2018 as part of EDGE-30949.*/

    public static void UpdateApplicationChecks(Account[] oldAccounts, Map<ID, Account> oldAccountMap,
                                               Account[] updatedAccounts, Map<ID, Account> updateAccountsMap){
                                                   Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();

                                                   system.debug('oldAccountMap ===>'+oldAccountMap);
                                                   set<Id> sAccIds = new set<id>();
                                                   for (Account a : updatedAccounts) {
                                                       if (a.TPSA_Additional_Modules__c != null && (oldAccountMap== null || a.TPSA_Additional_Modules__c != oldAccountMap.get(a.Id).TPSA_Additional_Modules__c) && a.RecordTypeid == devRecordTypeId) {
                                                           sAccIds.add(a.id);
                                                       }
                                                       system.debug('sAccIds ===>'+sAccIds);
                                                       if(!sAccIds.isEmpty()){
                                                           for(Id AccID : sAccIds){
                                                               Map<String, Object> params = new Map<String, Object>();
                                                               params.put('setParentAccountIds',AccID);
                                                               Flow.Interview.Update_Application calFlow = new Flow.Interview.Update_Application(params);//this flow will create the Application modules based on the account and associated applications.
                                                               calFlow.start();
                                                           }
                                                       }

                                                   }
                                               }

    /*
* Method to update Distributor name
[EDGE-30922] <Technical story > - Process Builder to Workflow /apex code - EDGE PRM Update Nominate Account Primary Distributor Name
Added by Saran
*/
    public static void updateDistributorName(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> updateAccountsMap){
        
        Map<Id, Account> oldAccountMap=New Map<Id, Account>();
        //Will be null when called from before insert
        if(oldAccounts != null){
            oldAccountMap = new Map<Id, Account>(oldAccounts);
        }          
        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        system.debug('test the ACCrecordtype'+partnerAccRecID);
        set<ID> accountIds = new set<ID>();
        for(Account a : updatedAccounts){
            if(a.RecordTypeId == partnerAccRecID) accountIds.add(a.Primary_Distributor__c); //Jernej: added record type check
        }
        Map<id,account> myMap = new map<id,account>([select id,name,Partner_Type__c,Primary_Distributor__c,Primary_Distributor__r.name,Primary_Distributor_Name__c from Account 
                                                     where id IN: accountIds AND RecordTypeId=:partnerAccRecID ]);
        
        system.debug('map'+myMap);
        updateDistributorNameExt(updatedAccounts, oldAccountMap, myMap, partnerAccRecID);//EDGE-127537 Cyclomatic Complexity Changes

    }// end of method updateDistributorName
    //EDGE-127537 Cyclomatic Complexity Changes
    private static void updateDistributorNameExt(Account[] updatedAccounts, Map<Id, Account> oldAccountMap, Map<id,account> myMap, Id partnerAccRecID){
        list<Account> acclist1 = new list<Account>();
        list<Account> acclist2 = new list<Account>();        
        for(Account acc : updatedAccounts){
            if(acc.RecordTypeId == partnerAccRecID ){
                if( acc.Primary_Distributor__c != null && acc.Partner_Type__c=='Nominate' && oldAccountMap.ContainsKey(acc.id) && (oldAccountMap.get(acc.id).Primary_Distributor__c != acc.Primary_Distributor__c || oldAccountMap.get(acc.id).Partner_Type__c != acc.Partner_Type__c))
                {    
                    if(myMap.containskey(acc.Primary_Distributor__c) )
                    { 
                        acc.Primary_Distributor_Name__c = myMap.get(acc.Primary_Distributor__c).name;
                        acclist1.add(acc);
                    }
                    //if(myMap != null && myMap.get(acc.id) != null && myMap.get(acc.id).Primary_Distributor__r.name != null)
                }
                else if(acc.Primary_Distributor__c == null)
                {
                    acc.Primary_Distributor_Name__c = '';
                    acclist2.add(acc);
                    
                }
            }  
        }   
    }


    /*
[EDGE-30913] <Technical story >Process Builder to Workflow /apex code - EDGE PRM Deactivate PRM user
added by saran
*/
    public static void deactivateReactivateOrg(Account[] oldAccounts, Account[] updatedAccounts,
    Map<ID, Account> oldAccountMap, Map<ID, Account> newAccountsMap){   
       Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();//Jernej: we need to add a stop so that the code doesn't run on non=partner accounts
       List<id> AccIdListforupdate = new List<id>();
       for(Account a : updatedAccounts){
           if(a.RecordTypeId == partnerAccRecId){ //Jernej: run only for partner accounts
               AccIdListforupdate.add(a.id);
               if(a.Account_Status__c == 'Frozen' && oldAccountMap.get(a.id).Account_Status__c =='Pending Activation')
               {
                   AccountTriggerHelperPRM.CallPIMsToManage(AccIdListforupdate,'MANAGEORG','deactivateOrg','PimsMicroserviceManageOrgBatch');
               }
               else if(a.Last_Login_Extension_Date__c !=null && (oldAccountMap== null || a.Last_Login_Extension_Date__c != oldAccountMap.get(a.Id).Last_Login_Extension_Date__c) )
               {
                   a.Account_Status__c = 'Pending Activation';
                   system.debug('inside login block');
                   if(a.Account_Status__c == 'Pending Activation' && oldAccountMap.get(a.id).Account_Status__c =='Frozen')
                   {
                       system.debug('reactivate org');
                       AccountTriggerHelperPRM.CallPIMsToManage(AccIdListforupdate,'MANAGEORG','reactivateOrg','PimsMicroserviceManageOrgBatch');
                   }
               }
           }  
       }       
    }// end of method deactivateReactivateOrg


    //Added by uday on 29082018 as per the EDGE-37549
    /* This method will update the PRM License Limit on Account based on the Accreditation field from the CMD(PRM_Partner_License_Limit__mdt)*/
    /* P2OB-6753 - Hawaii - Commented the method as business do not want it now but in later release might be they want it again later */
   /* public static void PopulatePRMLicenseonAccount(Account[] oldAccounts, Map<ID, Account> oldAccountsMap, Account[] updatedAccounts, Map<ID, Account> newAccountsMap){

        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        
        Map<String, PRM_Partner_License_Limit__mdt> mpPartnerLicense = new Map<String, PRM_Partner_License_Limit__mdt>();
        set<string> sAccreditationlvl = new set<string>();
        
        set<id> sAccountIds = new set<id>();
        List<Account> lstUpdatedAccounts = new List<Account>();

        //updatedAccounts = PhoenixGlobalUtil.accountsByRecType(updatedAccounts, partnerAccRecID);//Jernej: trim the accounts list

        //if(updatedAccounts !=null && !updatedAccounts.isEmpty()){
            for(Account objAcc : updatedAccounts)
            {
                if(String.isNotBlank(objAcc.Overall_Accreditation__c) && objAcc.RecordTypeId == partnerAccRecID){
                    sAccreditationlvl.add(objAcc.Overall_Accreditation__c); 
                    sAccountIds.add(objAcc.id);
                }

            }
        //}
        system.debug('sAccountIds'+sAccountIds);
        map<object, object> mpLicense = new map<object, object>();
        AggregateResult[] groupedResults  = [SELECT AccountId, count(id)
                                             FROM User
                                             where AccountId in:sAccountIds
                                             and isActive = true and AccountId != null   GROUP BY AccountId];

        for (AggregateResult agr : groupedResults) {
            mpLicense.put(agr.get('AccountId'), agr.get('expr0'));
        }
        system.debug('mpLicense'+mpLicense);
        if(!sAccreditationlvl.isEmpty()){
            for(PRM_Partner_License_Limit__mdt objPRMLicnses : [SELECT Accreditation_Level__c,License_Limit__c FROM PRM_Partner_License_Limit__mdt WHERE Accreditation_Level__c IN: sAccreditationlvl])
            {
                mpPartnerLicense.put(objPRMLicnses.Accreditation_Level__c, objPRMLicnses);
            }
        }
        
        
        List<Account> lstAccounts =[select id,PRM_License_Limit__c,RecordTypeId,Overall_Accreditation__c from Account where id in:sAccountIds];
       
        if(oldAccounts == null){//after insert
            if(updatedAccounts !=null && !updatedAccounts.isEmpty()){
                for(Account objAcc : lstAccounts)
                {
                    if(objAcc.RecordTypeId == partnerAccRecID && objAcc.Overall_Accreditation__c != null && objAcc.Overall_Accreditation__c != ''){
                        
                        if(!mpPartnerLicense.isEmpty() && mpPartnerLicense.containsKey(objAcc.Overall_Accreditation__c) && mpPartnerLicense.get(objAcc.Overall_Accreditation__c).License_Limit__c != null){
                            objAcc.PRM_License_Limit__c = mpPartnerLicense.get(objAcc.Overall_Accreditation__c).License_Limit__c ;

                        }

                         if(objAcc.PRM_License_Limit__c != null && objAcc.PRM_License_Limit__c >0) {
                            if(!mpLicense.isEmpty() && mpLicense.containsKey(objAcc.id) && mpLicense.get(objAcc.id) != null)
                            {
                                objAcc.PRM_Remaining_License__c = objAcc.PRM_License_Limit__c - Integer.ValueOf(mpLicense.get(objAcc.id));
                                objAcc.Users_on_Account__c = Integer.ValueOf(mpLicense.get(objAcc.id));

                            }
                           else{
                                objAcc.PRM_Remaining_License__c = objAcc.PRM_License_Limit__c;
                            }


                        }

                        lstUpdatedAccounts.add(objAcc);


                    }
                }
                update lstUpdatedAccounts;
            }

        }
        else  
        if(oldAccountsMap != null && !oldAccountsMap.IsEmpty()){//before update
            if(updatedAccounts !=null && !updatedAccounts.isEmpty()){
                for(Account objAcc : updatedAccounts)
                {
                    if(objAcc.RecordTypeId == partnerAccRecID && objAcc.Overall_Accreditation__c != null && objAcc.Overall_Accreditation__c != '' && objAcc.Overall_Accreditation__c != oldAccountsMap.get(objAcc.Id).Overall_Accreditation__c ){
                        if(!mpPartnerLicense.isEmpty() && mpPartnerLicense.containsKey(objAcc.Overall_Accreditation__c) && mpPartnerLicense.get(objAcc.Overall_Accreditation__c).License_Limit__c != null)
                            objAcc.PRM_License_Limit__c = mpPartnerLicense.get(objAcc.Overall_Accreditation__c).License_Limit__c ;
                    }
                    system.debug('updatedAccounts'+updatedAccounts);
                    system.debug('mpLicense'+mpLicense);

                    if(objAcc.PRM_License_Limit__c != null && objAcc.PRM_License_Limit__c >0) {
                        if(!mpLicense.isEmpty() && mpLicense.containsKey(objAcc.id) && mpLicense.get(objAcc.id) != null)
                        {
                            // P2OB-6753 - commenting the code objAcc.PRM_Remaining_License__c = objAcc.PRM_License_Limit__c - Integer.ValueOf(mpLicense.get(objAcc.id));
                            objAcc.Users_on_Account__c = Integer.ValueOf(mpLicense.get(objAcc.id));

                        }
                        
                        {
                            objAcc.PRM_Remaining_License__c = objAcc.PRM_License_Limit__c;
                        }

                   }
                }
            }

        }


    }*/



    public static void ToupdateUsersToSuperUsers(Account[] oldAccounts, Map<ID, Account> oldAccountsMap, Account[] updatedAccounts, Map<ID, Account> newAccountsMap){

        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        set<id> sAccntIds = new set<id>();
        set<id> sConIds = new set<id>();

        for(Account objAcc:updatedAccounts){
            if(objAcc.RecordTypeId == partnerAccRecID && objAcc.PartnerPrincipalContact__c != null && objAcc.PartnerPrincipalContact__c != oldAccountsMap.get(objAcc.id).PartnerPrincipalContact__c)
            {
                sAccntIds.add(objAcc.id);
            }
        }

        if(!sAccntIds.isEmpty()){
            for(Contact objCon : [select id,AccountId from Contact where AccountId in:sAccntIds]){
                sConIds.add(objCon.id);
            }
        }
        if(!sConIds.isEmpty())
            updateUsersAsSueprUsers(sConIds);

    }

    @future
    public static void updateUsersAsSueprUsers(set<id> ScontactIds){
        system.debug('ScontactIds ====>'+ScontactIds);
        List<User> lstUsers = [select id,ContactId,IsPRMSuperUser from user where ContactId in:ScontactIds and Id != null];
        List<User> lstUsersToUpdate = new List<User>();
        system.debug('lstUsers ====>'+lstUsers);
        for(User objUser : lstUsers){
            if(objUser.IsPrmSuperUser != true){
                objUser.IsPrmSuperUser =  true;
                lstUsersToUpdate.add(objUser);
            }
        }

        if(!lstUsersToUpdate.isEmpty()&& !test.isRunningTest()){
            update lstUsersToUpdate;
        }

    }

    public static void UpdateAccreditationStatus(Map<ID, Account> oldAccountsMap, Map<ID, Account> newAccountsMap){ 
        
        Map<String, PRM_Partner_License_Limit__mdt> mpPartnerLicense = new Map<String, PRM_Partner_License_Limit__mdt>();
        //see if the query can be moved
        for(PRM_Partner_License_Limit__mdt objPRMRank : [SELECT Accreditation_Level__c,Rank__c,License_Limit__c FROM PRM_Partner_License_Limit__mdt])
            mpPartnerLicense.put(objPRMRank.Accreditation_Level__c,objPRMRank);
          Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        for(Account objAcc:newAccountsMap.values()){
            //if(oldAccountsMap!=null && oldAccountsMap.get(objAcc.id)!=null && objAcc.RecordTypeId == partnerAccRecID)
            //{//EDGE-127537 Cyclomatic Complexity Changes
                if(objAcc.RecordTypeId == partnerAccRecID && mpPartnerLicense.ContainsKey(oldAccountsMap.get(objAcc.id).Overall_Accreditation__c) && mpPartnerLicense.ContainsKey(objAcc.Overall_Accreditation__c))
                {           
                    If(mpPartnerLicense.get(oldAccountsMap.get(objAcc.id).Overall_Accreditation__c).Rank__c < mpPartnerLicense.get(objAcc.Overall_Accreditation__c).Rank__c)
                    {
                        objAcc.Old_OverallAccreditation_Status__c=oldAccountsMap.get(objAcc.id).Overall_Accreditation__c;
                        objAcc.Accreditation_Status__c=objAcc.Accreditation_Status__c=='Relegated'?'Relegated Again':objAcc.Accreditation_Status__c=='Relegated Again'?'Relegated':'Relegated';
                        objAcc.Old_PRM_License_Limit__c=oldAccountsMap.get(objAcc.id).PRM_License_Limit__c;
                        objAcc.Deactivation_Date__c= DateTime.Now().AddDays(28);
                        
                    }
                    else if(mpPartnerLicense.get(oldAccountsMap.get(objAcc.id).Overall_Accreditation__c).Rank__c > mpPartnerLicense.get(objAcc.Overall_Accreditation__c).Rank__c){
                        objAcc.Old_OverallAccreditation_Status__c=oldAccountsMap.get(objAcc.id).Overall_Accreditation__c;
                        objAcc.Old_PRM_License_Limit__c=oldAccountsMap.get(objAcc.id).PRM_License_Limit__c;
                        objAcc.Accreditation_Status__c='Promoted';
                        
                    }   
                }
            //}
        }
    }



    /*
* Method to create call PIMS when Account_status__c is changed to 'Active'
* EDGE-29560: As a channel acquisition/manager once I onboard a partner account PIMS should be synced with partner type information
Added by RaviTeja
*/

    @future(callout=true)
    public static void CallPIMs(list<id> objids,String pimsAPIType,String pimsCallType,string shandlernameUser){   
        system.debug('objids'+objids);
        list<WrapperServiceResponse> lstwrap = new list<WrapperServiceResponse>();        
        
        // Boolean ISActive = True;  
        Boolean ISActive;  
        if(pimsCallType == 'updateUser'){
            ISActive=true;
        }else if(pimsCallType == 'deactivateUser'){
            ISActive=false;
        }
                
        Logger2 logger = Logger2.getLogger('AccountTriggerHelper');
        string sParams='';
        String sResponse='';
        
        try{      
            List<contact> lstFContacts = [select id,name from contact where id in:objids];        
            if (!lstFContacts.isEmpty())
            {
                for (Contact Obj : lstFContacts) {
                    //ManagePIMSController.WrapperPageParameters objparams = new ManagePIMSController.WrapperPageParameters();
                    WrapperMSPIMSParams.WrapperPageParameters objparams = new WrapperMSPIMSParams.WrapperPageParameters();
                    objparams.pageObjectID = Obj.id;
                    objparams.pimsAPIType = pimsAPIType;  //'MANAGEUSER';
                    objparams.pimsCallType =pimsCallType; // 'updateUser' or 'deactivate user';
                    sParams = JSON.serialize(objparams);
                    HTTPResponse httpResponse = (HTTPResponse) ManagePIMSController.invoke(sParams, shandlernameUser);
                    //String Jsonstr = '{\n' +' "title" :"Success",\n' +' "status" : "200",\n' +' "pimsStatus" : "0",\n' +' "description" : "Success",\n' +' "userPid" : "P12345"\n' +'}';
                    
                    if (HTTPResponse != null && HTTPResponse.getBody() != null)
                    {
                        sResponse = HTTPResponse.getBody();  //Jsonstr;
                        system.debug('sResponse'+sResponse);
                        WrapperMSPIMSParams.MSResponse Response = new WrapperMSPIMSParams.MSResponse();
                        Response = (WrapperMSPIMSParams.MSResponse)JSON.deserialize(sResponse, WrapperMSPIMSParams.MSResponse.class);
                        //objWrap.ContactId = Obj.Id;
                        WrapperServiceResponse objWrap= new WrapperServiceResponse();
                        objWrap.ContactId=  Obj.Id;
                        objWrap.MSResponse=Response;                    
                        lstwrap.add(objWrap);
                    }
                    
                    system.debug('lstwrap =====>' + lstwrap);
                }
                if (!lstwrap.isEmpty()) {
                    CallPIMsExt(lstwrap, sParams, sResponse, ISActive);//EDGE-127537 Cyclomatic Complexity Changes
                }
            }
        }
        catch (Exception ex) {
            //refer looging in existing code
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
        }
    }
    
    /******************Extension method for CallPIMs**************************************/
    //EDGE-127537 Cyclomatic Complexity Changes
    private static void CallPIMsExt(list<WrapperServiceResponse> lstwrap, String sParams, String sResponse, Boolean ISActive) {
                String profileName = PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA; //'PRM Community User - Australia';
                List<Contact> lstContactsToUpdate = new list<Contact>();
                    list<Id> lstContactIds = new list<Id>();
                    list<Id> sErrorContacts = new list<id>();
                map<Id, string> mapConIdUserId = new map<Id, string>();
                Logger2 logger = Logger2.getLogger('AccountTriggerHelper');
                        for (WrapperServiceResponse objWrapper : lstwrap) {
                            if (objWrapper.MSResponse.status == 200) {
                                lstContactIds.add(objWrapper.ContactId);
                            }else{
                                sErrorContacts.add(objWrapper.ContactId);
                                logger.logMessages(sParams,sResponse, '', '', '', '', false, false);
                                logger.exitLogger();
                                system.debug('sErrorContacts===>' + sErrorContacts);
                            }
                            if (String.isNotEmpty(objWrapper.MSResponse.userPid)) {
                                mapConIdUserId.put(objWrapper.ContactId, objWrapper.MSResponse.userPid);
                            }
                            
                            system.debug('lstContactIds ===>' + lstContactIds);
                            system.debug('mapConIdUserId ===>' + mapConIdUserId);
                        }
                    
                    if(!lstContactIds.isEmpty()){
                        for(Contact objCon:[select id,PIMS_Sync_Status__c from Contact where id in: lstContactIds]){
                            objCon.PIMS_Sync_Status__c  = PRMConstants.PRM_PIMS_SYNC_STATUS_SUCCESS;
                            lstContactsToUpdate.add(objCon);
                        }
                    }
                    
                    if(!sErrorContacts.isEmpty()){             
                        for(Contact objCon:[select id,PIMS_Sync_Status__c from Contact where id in: sErrorContacts]){
                            objCon.PIMS_Sync_Status__c  = PRMConstants.PRM_PIMS_SYNC_STATUS_Error;
                            lstContactsToUpdate.add(objCon);
                        }
                        
                    }
                    update lstContactsToUpdate;
                    
                    //Queueable Method to update user record (to Avoid Mixed DML exception)
                    System.debug('Isactive====' + IsActive);
                    System.debug('lstContactIds====' + lstContactIds);
                    if(lstContactIds.size()>0)
                        System.enqueueJob(new QueueableupsertUserRecordBulk(lstContactIds,mapConIdUserId,profileName,ISActive,false));
    }
    public class WrapperServiceResponse {
        public  WrapperMSPIMSParams.MSResponse MSResponse;
        public Id ContactId;
        public Id AccountId;
    }

    /*
[EDGE-30913] <Technical story >Process Builder to Workflow /apex code - EDGE PRM Deactivate PRM user
added by saran
*/
    @future(callout=true)
    public static void CallPIMsToManage(list<id> Accountids,String pimsAPIType,String pimsCallType,string shandlernameUser)
    {          
        //string shandlernameUser = 'PimsMicroserviceManageUserBatch';
        list<WrapperServiceResponse> lstwrap = new list<WrapperServiceResponse>();
        list<id> listSuccessAccountIds = new list<id>();
        list<id> listErrorAccountIds = new list<id>();        
        Logger2 logger = Logger2.getLogger('AccountTriggerHelper');        
        string sParams;
        String sResponse;

        try{
            List<Account> listAccounts = [select id,name from account where id in:Accountids]; 
            for(Account obj : listAccounts){
                system.debug('inside callpimsmanage');
                //ManagePIMSController.WrapperPageParameters objparams = new ManagePIMSController.WrapperPageParameters();
                WrapperMSPIMSParams.WrapperPageParameters objparams = new WrapperMSPIMSParams.WrapperPageParameters();
                objparams.pageObjectID = Obj.id;
                objparams.pimsAPIType = pimsAPIType; //MANAGEORG
                objparams.pimsCallType = pimsCallType; //DEACTIVATE or REACTIVATE
                sParams = JSON.serialize(objparams);
                HTTPResponse httpResponse = (HTTPResponse) ManagePIMSController.invoke(sParams, shandlernameUser);
                system.debug('httpresponse' + httpResponse);
                //String Jsonstr = '{\n' +' "title" :"Error",\n' +' "status" : "400",\n' +' "pimsStatus" : "0",\n' +' "description" : "Success",\n' +' "userIdCreated" : "CreateUserS"\n' +'}';
                if (HTTPResponse != null && HTTPResponse.getBody() != null)
                {
                    //sResponse = Jsonstr ;
                    sResponse = HTTPResponse.getBody();
                    system.debug('sResponse+++++++++' + sResponse);
                    WrapperMSPIMSParams.MSResponse Response = new WrapperMSPIMSParams.MSResponse();
                    Response = (WrapperMSPIMSParams.MSResponse)JSON.deserialize(sResponse, WrapperMSPIMSParams.MSResponse.class);
                    WrapperServiceResponse objWrap= new WrapperServiceResponse();
                    objWrap.AccountId = Obj.Id;
                    //objWrap.ContactID = Obj.Id;
                    objWrap.MSResponse=Response;
                    lstwrap.add(objWrap);
                }
                system.debug('lstwrap &&&&&>' + lstwrap);
            }   
            if (!lstwrap.isEmpty()) {
                for (WrapperServiceResponse objWrapper : lstwrap) {
                    if (objWrapper.MSResponse.status == 200) {
                        listSuccessAccountIds.add(objWrapper.AccountId);
                    }else{
                        listErrorAccountIds.add(objWrapper.AccountId);
                        logger.logMessages(sParams,sResponse, '', '', '', '', false, false);
                        logger.exitLogger();
                    }
                    
                    system.debug('listSuccessAccountIds &&&>' + listSuccessAccountIds);
                    system.debug('listErrorAccountIds &&&>' + listErrorAccountIds);
                }
            }
            CallPIMsToManageExt(listSuccessAccountIds, listErrorAccountIds);//EDGE-127537 Cyclomatic Complexity Changes
        }  
        catch (Exception ex) {
            //refer looging in existing code
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
        }       
    }//end of method CallPIMsToManage
    
    private static void CallPIMsToManageExt(list<id> listSuccessAccountIds, list<id> listErrorAccountIds){//EDGE-127537 Cyclomatic Complexity Changes
        List<Account> lstSuccessAccounts = new list<Account>();
        List<ID> lstConfreeze = new list<ID>();
        list<ID> lstConUnfreeze = new list<ID>();
        List<Account> lstErrAccounts = new list<Account>();
        String taskDesc1 = Label.PartnerDeactivationTask;
        String taskDesc2 = Label.PartnerReactivationTask;
        list<Account> lstAccountsToUpdate = new list<Account>();
        List<Task> taskList = new List<Task>();
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General').getRecordTypeId();

                if(!listSuccessAccountIds.isEmpty()){
                    //lstSuccessAccounts = [select id,PIMS_Sync_Status__c,Account_Status__c,OwnerId from Account where id in: listSuccessAccountIds];
                    lstSuccessAccounts = [select id,PIMS_Sync_Status__c,Account_Status__c,OwnerId,(select id, name from Contacts) from Account where id in: listSuccessAccountIds];
                    for(Account objAcc:lstSuccessAccounts){
                        
                        objAcc.PIMS_Sync_Status__c  = PRMConstants.PRM_PIMS_SYNC_STATUS_SUCCESS;
                        if(objAcc.Account_Status__c == PRMConstants.PRM_Account_Status_Frozen){
                            for(Contact con : objAcc.contacts){
                                lstConfreeze.add(con.id);
                                system.debug('lstConfreeze &&&>' + lstConfreeze);
                            }
                            //PRMFreezePartnerUser.freezeActiveUser(listSuccessAccountIds);
                            //PRMFreezePartnerUser.freezeUsers(lstConfreeze);
                        }
                        else if(objAcc.Account_Status__c == PRMConstants.PRM_Account_Status_Pending_Activation){
                            //PRMFreezePartnerUser.unFreezeActiveUser(listSuccessAccountIds);
                            //PRMFreezePartnerUser.unfreezeUsers(listSuccessAccountIds);
                            for(Contact con : objAcc.contacts){
                                lstConUnfreeze.add(con.id);
                                system.debug('lstConUnfreeze &&&>' + lstConUnfreeze);
                            }
                        }
                        lstAccountsToUpdate.add(objAcc);
                    }//Account for close
                    PRMFreezePartnerUser.freezeUsers(lstConfreeze);
                    PRMFreezePartnerUser.unfreezeUsers(lstConUnfreeze);
                }
                
                if(!listErrorAccountIds.isEmpty()){
                    
                    //lstErrAccounts = [select id,PIMS_Sync_Status__c,Account_Status__c,OwnerId from Account where id in: listErrorAccountIds];
                    lstErrAccounts = [select id,PIMS_Sync_Status__c,Account_Status__c,OwnerId,(select id, name from Contacts) from Account where id in: listErrorAccountIds];
                    for(Account objAcc:lstErrAccounts){
                        objAcc.PIMS_Sync_Status__c  = PRMConstants.PRM_PIMS_SYNC_STATUS_Error;
                        if(objAcc.Account_Status__c == PRMConstants.PRM_Account_Status_Frozen){
                            
                            Task taskRecord = new Task();
                            taskRecord.Subject = PRMConstants.PRM_Task_Deactivate_Subject ;
                            taskRecord.Description = taskDesc1;
                            taskRecord.ActivityDate = date.today();
                            taskRecord.Priority = PRMConstants.PRM_Task_Deactivate_Priority;
                            taskRecord.Status = PRMConstants.PRM_Task_Deactivate_Staus;
                            taskRecord.RecordTypeId = taskRecordTypeId;
                            taskrecord.OwnerId = objAcc.OwnerId;
                            taskList.add( taskRecord );
                            
                            lstAccountsToUpdate.add(objAcc);
                            
                        }
                        else if(objAcc.Account_Status__c == PRMConstants.PRM_Account_Status_Pending_Activation){
                            
                            Task taskRecord = new Task();
                            taskRecord.Subject = PRMConstants.PRM_Task_Reactivate_Subject;
                            taskRecord.Description = taskDesc2;
                            taskRecord.ActivityDate = date.today();
                            taskRecord.Priority = PRMConstants.PRM_Task_Reactivate_Priority;
                            taskRecord.Status = PRMConstants.PRM_Task_Reactivate_Staus;
                            taskRecord.RecordTypeId = taskRecordTypeId;
                            taskrecord.OwnerId = objAcc.OwnerId;
                            taskList.add(taskRecord);
                            
                            lstAccountsToUpdate.add(objAcc);
                        }
                    }
                }
                //if(!lstAccountsToUpdate.isEmpty()){
                    update lstAccountsToUpdate;
                    system.debug('last &&&' +lstAccountsToUpdate);
                    insert taskList;
                    system.debug('task list &&&' +taskList);
                //}
    }

    /*
* [EDGE-88445]- Method to update partner role when Principal_Contact__c is changed
Added by Saran
*/
/*    public static void updatePartnerRole(Account[] updatedAccounts, Map<ID, Account> newAccountsMap){
        map<string,string> resultMap= new map<string,string>();
        map<string,string> finalMap= new map<string,string>();
        Set<String> setChangedPrincipalContacts= new Set<String>();
        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); //Jernej: get partner record type ID
        //updatedAccounts = PhoenixGlobalUtil.accountsByRecType(updatedAccounts, partnerAccRecID);//Jernej: trim the accounts list
        //if(updatedAccounts !=null && !updatedAccounts.isEmpty()){
        for(Account eachPartner : updatedAccounts){
            //here itself check if field is changed
            if(PhoenixGlobalUtil.isChanged(eachPartner.id,'PartnerPrincipalContact__c')){
                setChangedPrincipalContacts.add(newAccountsMap.get(eachPartner.Id).PartnerPrincipalContact__c);
                //add new and old both contacts
                setChangedPrincipalContacts.add(((Account)(Trigger.OldMap.get(eachPartner.Id))).PartnerPrincipalContact__c);
            }
        }
    //}
        //PhoenixGlobalUtil util = new PhoenixGlobalUtil();
        list<user> userlist=[SELECT Id, Name,ProfileId,Profile.Name,isPRMSuperuser,Contactid,IsActive,Contact.account.PartnerPrincipalContact__c FROM User
                             WHERE Contactid IN : setChangedPrincipalContacts];
        //Fetch all the Users who have been modified
        //find the PartnerRoles
        resultMap=PhoenixGlobalUtil.findPartnerRole(userlist);
        System.debug('userlist ' + userlist);
        System.debug('setChangedPrincipalContacts ' + setChangedPrincipalContacts);
        Logger2 logger = Logger2.getLogger('AccountTriggerHelperPRM.updatePartnerRole');
        try {
            if(resultMap != null){
                for(User u : userlist){
                    finalmap.put(u.ContactId,resultMap.get(u.id));
                }
            }
            if(finalmap != null){
                UserTriggerHelperPRM.futureUpdates(finalmap);
            }
            System.debug('resultMap ' + resultMap);
            System.debug('finalmap ' + finalmap);
        }catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            logger.exitLogger();
        }
    }// end of method updatePartnerRole */

}//end AccountTriggerHelperPRM