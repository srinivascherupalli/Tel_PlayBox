/*
*  History of modifications - 
*  1. 17/03/2020 : Ritika Jaiswal : Team Hawaii : P2OB-4844 - Assigning permission-set group to partner-users 
*  2. 24/03/2020 : Ritika Jaiswal : Team Hawaii : P2OB-4844 - Removed code for assignment of permission-sets
*  3. 07-09-2020 : Team Hawaii : P2OB-7962 : Modified method assignPermissionSet,manageUserPartnerPermSet and onboardingActiveInsertPSAList and removed method findPartnerRole
*  4. 15-09-2020 : Team Hawaii : P2OB-7962 : SCA P1 : Resolved ApexSOQLInjection : Added escapeSingleQuotes
*  5. 29-10-2020 : Team Hawaii : P2OB-5898 : Set defaults on partner new-user using custom-setting
*/
public without sharing class PhoenixGlobalUtil {
    private static Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();
    private static map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = null; 
    /*
public static void apexShare(Set<String> setsObjectIdToBeShared,
Set<String> setSharedWithAccounts,
List<User> listShareWithUsers,
String shareObject,
String sAccessLevel) {
list<User> listPRMUsers = new List<User>();
if (null != setSharedWithAccounts) {
listPRMUsers =  [select Id
from User
where AccountId in : setSharedWithAccounts
and  IsPortalEnabled = TRUE];
} else
if (null != listShareWithUsers) {
listPRMUsers = listShareWithUsers;
}
system.debug('Here!!!');
List<Sobject> listSObject = new List<Sobject> ();
for (String eachObjectId : setsObjectIdToBeShared) {
for (User eachUser : listPRMUsers) {
System.debug(eachUser);
// Create new sharing object for the custom object Job.
DynamicSobject ds = new DynamicSobject();
Sobject shareObjectInstance = ds.getNewSObject(shareObject + 'Share');
shareObjectInstance.put(shareObject + 'AccessLevel', 'Read');
if ('Account'.equalsIgnoreCase(shareObject)) {
shareObjectInstance.put('CaseAccessLevel', 'None');
shareObjectInstance.put('OpportunityAccessLevel', 'None');
}
shareObjectInstance.put(shareObject + 'AccessLevel', sAccessLevel);
shareObjectInstance.put(shareObject + 'Id', eachObjectId);
shareObjectInstance.put('UserOrGroupId', eachUser.Id);
listSObject.add(shareObjectInstance);
}
}
if (!listSObject.isEmpty())
PhoenixGlobalUtil.insertRecords(listSObject);
}
public static void insertRecords (List<Sobject> shareObjectInstance) {
System.debug('listSObject**' + shareObjectInstance);
Database.SaveResult[] listResults = Database.insert(shareObjectInstance, false);
System.debug('Succes!!!!' + listResults);
for (Database.SaveResult sr : listResults) {
if (!sr.isSuccess()) {
for (Database.Error err : sr.getErrors()) {
system.debug('Error' + err.getMessage());
// These sharing records are not required and thus an insert exception is acceptable.
if (err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&
err.getMessage().contains('AccessLevel')) {
// Indicates success.
// return true;
}
}
}
}
}
public class DynamicSobject {
public SObject getNewSobject(String t) {
// Call global describe to get the map of string to token. 
Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
//Get the token for the sobject based on the type. 
Schema.SObjectType st = gd.get(t);
System.assert(st != null, 'Type provided: "' + t + '" doesnt map to an sobject token in this org.');
// Instantiate the sobject from the token. 
Sobject s = st.newSobject();
return s;
}
}
*/
    
    /*
public static list<sObject> getRecord(String sObjectname,
String whereClause) {

String FROM_STRING=' FROM '; 
String SELECT_STRING=' SELECT '; 
system.debug('*********whereClause'+whereClause) ;                                     
String queryStr =String.escapeSingleQuotes(SELECT_STRING)+
'DeveloperName,End_User_Message__c,Id,Label,Language,MasterLabel,Message_Type__c,NamespacePrefix,PIMS_Interface__c,PIMS_Status_Code__c,QualifiedApiName,STATUS_CODE__c,User_Error_Code__c'
+ String.escapeSingleQuotes(FROM_STRING) + String.escapeSingleQuotes(sObjectname) + String.escapeSingleQuotes(whereClause);

System.debug(queryStr + '---queryStr');
return Database.query(queryStr);
}

*/
    
    
    @future
    public static void UpdateContactRecord(string Pimscalltype,string Contactid) {
        
        Logger2 logger = Logger2.getLogger('PhoenixGlobalUtil.UpdateContactrecord');
        try{          
            Contact contstatus = [Select Id, Name, Community_User_Type__c,PIMS_User_Status__c,Onboarding_Status__c from Contact where Id = :Contactid];
            
            if(Pimscalltype.equalsIgnoreCase('elevateToPDUA'))
            {
                contstatus.Community_User_Type__c = 'PRM Community Admin'; 
                contstatus.PIMS_User_Status__c = 'Elevated to Admin';
                
            }
            else if(Pimscalltype.equalsIgnoreCase('removePDUA'))
            {
                contstatus.Community_User_Type__c = 'PRM Community User'; 
                contstatus.PIMS_User_Status__c = 'Removed Admin access';
            }          
            else if(Pimscalltype.equalsIgnoreCase('deactivateUser'))
            {
                contstatus.Onboarding_Status__c = 'Inactive';
                contstatus.PIMS_User_Status__c = 'Deactivated';
            }
            
            update contstatus;
            
        }
        catch (Exception e) {
            System.debug(e.getStackTraceString() + 'e.getStackTraceString()****');
            System.debug(e.getMessage() + 'e.getStackTraceString()****');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
    }
    @future
    public static void upsertUserRecord(id cntid, String fedid, string pname, boolean isActive) {
        
        list<id>  lstContactIds= new list<id>();
        lstContactIds.add(cntid);
        map<Id, string> mapConIdUserId = new map<Id, string>();
        mapConIdUserId.put(cntid,fedid);
        upsertUserRecordBulk(lstContactIds,mapConIdUserId,pname,isActive,true);
        
        
    }
    @future
    public static void inactivatePortalUsers(Set<String> setContactId) {
        //Inactivate user record
        List<User> userRecords = new list<user>();
        for (user eachUser : [SELECT id, name , IsPortalEnabled
                              FROM User
                              where isportalenabled = true
                              and contactId in :setContactId]) {
                                  eachUser.isactive = false;
                                  userRecords.add(eachUser);
                              }
        database.update(userRecords, false);
    }
    
    //Method to check onboarding status of contacts to assign permission set
    //P2OB-7962 : Method Updated to handle permission-set assignment for partner_role updates as well
    public static void assignPermissionSet(map<id,contact> contactMap, 
                                           map<id,contact> contactOldMap,
                                           String setPermissinSets){
                                               set<id> contactIds=new set<id>();
                                               for(contact c:contactMap.values()){
                                                   //P2OB-7962 : Condition modified to trigger permission-set-assignments when new user is onboarded or contact-role is updated
                                                   //if((c.Onboarding_Status__c!=contactOldMap.get(c.id).Onboarding_Status__c && (c.Onboarding_Status__c=='Active'|| c.Onboarding_Status__c=='Inactive'))|| (c.Partner_Role__c !=contactOldMap.get(c.id).Partner_Role__c))
                                                   if(c.Partner_Role__c != null && contactOldMap.get(c.id)==null || (c.Partner_Role__c != contactOldMap.get(c.id).Partner_Role__c))
                                                   {
                                                         contactIds.add(c.id);
                                                     }
                                               }
                                               manageUserPartnerPermSetContact(contactIds,setPermissinSets);
                                           }
    
    
    // Method to assign CS and Partner Permission sets to partner users
    @future 
    public static void manageUserPartnerPermSetContact(set<id> cntids, 
                                                       String setPermissinSets){
                                                           manageUserPartnerPermSet(cntids,setPermissinSets);
                                                       }
    
    // Method to assign CS and Partner Permission sets to partner users
    // Team Hawaii : Ritika : Update for P2OB-4844, auto-assignment of permission-set-group, and removal of code of auto-assignment of permission-set.
    public static void manageUserPartnerPermSet(set<id> cntids, String setPermissinSets){
        Set<String> setPSId;
        Set<String> setPSName= new Set<String>();
        Set<String> setActivePersmissionSets = new Set<String>(setPermissinSets.split(','));            
        Map<Id,PermissionSetGroup> psagMap  =new Map<Id,PermissionSetGroup>(); //Team Hawaii : Ritika : P2OB-4844 : Map of permission-set-groups mentioned in CustomMetadata(Partner_Permission_Sets__mdt) and custom-Label(PRM_PARTNER_ACTIVE_PERMMISIONSETS)
        list<PermissionSetAssignment> insertPSAList = new list<PermissionSetAssignment>();      
        list<UserPackageLicense> insertUserLicenseList = new list<UserPackageLicense>();
        Set<String> LicenceNamespace = new Set<String>(label.PRM_PARTNER_LICENCES.split(','));
        id recType = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
        List<Profiles__c> profiles = Profiles__c.getall().values();
        
        Map<Id,PackageLicense> packLicMap= new Map<Id,PackageLicense>([SELECT Id  FROM PackageLicense WHERE NamespacePrefix in :LicenceNamespace]); 
        
        //Fetching Permissionset Names 
        //P2OB-7962 : Modified to get permission-set-groups from metadata
        Map<Id,Partner_Permission_Sets__mdt> permission_set_mdt = new Map<Id,Partner_Permission_Sets__mdt>([SELECT Permission_Set_Name__c,Required_by_Roles__c  FROM Partner_Permission_Sets__mdt WHERE label in :setActivePersmissionSets]);   
        For(Partner_Permission_Sets__mdt eachPS : permission_set_mdt.values())
        {setPSName.add(eachPS.Permission_Set_Name__c);}        
        if(setPSName.size()>0){  
            psagMap = new Map<Id,PermissionSetGroup>([SELECT Id,DeveloperName FROM PermissionSetGroup WHERE DeveloperName in :setPSName]); //Team Hawaii : Ritika : P2OB-4844 : Query permission-set-group records on developer-name 
        }
        
        map<id, contact> onboardingActiveConts= new map<id, contact>();
        map<id,contact> onboardingInactiveConts=new map<id, contact>();
        //Fetch the contact records
        for(contact cnt: [SELECT id,Onboarding_Status__c,Partner_Role__c FROM contact WHERE Onboarding_Status__c in ('Active' ,'Inactive')
                                                 AND id in :cntids
                                                 AND RecordTypeId = : recType])
        {
            if(cnt.Onboarding_Status__c == 'Active'){ 
                onboardingActiveConts.put(cnt.id,cnt);
                }
            else
                onboardingInactiveConts.put(cnt.id,cnt);
        }
        System.debug('onboardingActiveConts: '+ onboardingActiveConts);
        System.debug('onboardingInactiveConts: '+ onboardingInactiveConts);
        
        
        //Insert Permissions,Licences if Onboarding status is Active
        if(!onboardingActiveConts.isEmpty())
        {       
           /*EDGE-127154 - Added by Purushottam : Tech Debt Changes - Start*/
           //Team Hawaii : Ritika : P2OB-4844 : Passing Permission-Set-Group for assignment to partner-user, and removed permission-set parameter
           onboardingActiveInsertPSAList(onboardingActiveConts,psagMap,permission_set_mdt); 
            /*
            list<user> activeUserList = [select id,name,profile.name from user where contactid =: onboardingActiveConts.keyset()];
            
            //Filter PRM Profiles
            set<User> addUserList = new set<User>();
            for(Profiles__c pf:profiles){
                for(User u:activeUserList){
                    if(u.profile.name==pf.name){
                        addUserList.add(u);
                    }
                }
            }
            
            
           
            for(user eachUser : addUserList){ 
                   for(PermissionSet eachPS : psaMap.values()){
                        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = eachPS.id, 
                                                                                  AssigneeId = eachUser.id);
                        system.debug('persetAssignmnt'+psa);
                        insertPSAList.add(psa);
                }
                
                    for(PackageLicense eachPL : packLicMap.values()){                   
                        UserPackageLicense UPL= new UserPackageLicense(UserId = eachUser.id, PackageLicenseId = eachPL.id);
                        insertUserLicenseList.add(UPL);                  
                    }                    
                
            }
            
            if(insertPSAList.size()>0)
                database.insert(insertPSAList,false);
            
            if(insertUserLicenseList.size()>0)
                database.insert(insertUserLicenseList,false);
           */
        } 
        
        
        //Deleting Permissions if Onboarding status is in-active        
        
        
        //Team Hawaii : Ritika : P2OB-4844:Replacing permission-set by permission-set-group for auto-removal
        if(!onboardingInactiveConts.isEmpty()){
            onboardingInActiveInsertPSAList(onboardingInactiveConts,psagMap);
            /*
            list<user> inActiveUserList = [select id,name,profile.name 
                                           from user 
                                           where contactid in :onboardingInactiveConts.keyset()]; 
            list<User> delUserList = new list<User>();
            for(Profiles__c pf:profiles){
                for(User eachUser:inActiveUserList){
                    if(eachUser.profile.name==pf.name){
                        delUserList.add(eachUser);
                    }
                }
            } 
            //remove permission set assignment
            Map<id,user> inactiveUsrMap = new Map<id,user>(delUserList);
                //remove permission set               
                List<PermissionSetAssignment> deletePSAList = [SELECT Id 
                                                               FROM PermissionSetAssignment 
                                                               WHERE AssigneeId IN :inactiveUsrMap.keyset() 
                                                               AND PermissionSetId in: psaMap.keySet()];                             
                
                
                if(deletePSAList.size()>0)
                    delete deletePSAList;
            
            
            //remove Licences               
                List<UserPackageLicense> deletePkglicList = [SELECT Id 
                                                             FROM UserPackageLicense 
                                                             WHERE UserId IN :inactiveUsrMap.keyset() 
                                                             AND PackageLicenseId in: packLicMap.keySet()];                             
                
                if(deletePkglicList.size()>0)
                    delete deletePkglicList;
            */
            /*EDGE-127154 - Added by Purushottam : Tech Debt Changes - End*/   
        }
        
    }
    
    
    public static list<sObject> getRecords(String sObjectname,
                                           map<String,String> FieldMap) {                                      
                                               String FROM_STRING=' FROM '; 
                                               String SELECT_STRING=' SELECT '; 
                                               String WHERE_STRING=' WHERE '; 
                                               String AND_STRING=' AND '; 
                                               String queryStr ='';
                                               queryStr+=String.escapeSingleQuotes(SELECT_STRING);        
                                               queryStr+='DeveloperName,End_User_Message__c,Id,PIMS_ERROR__c,Label,Language,MasterLabel,Message_Type__c,NamespacePrefix,PIMS_Interface__c,PIMS_Status_Code__c,QualifiedApiName,STATUS_CODE__c,User_Error_Code__c';
                                               queryStr+= String.escapeSingleQuotes(FROM_STRING);
                                               queryStr+= String.escapeSingleQuotes(sObjectname);      
                                               queryStr+= String.escapeSingleQuotes(WHERE_STRING);
                                               
                                               integer i=0;
                                               for(String FieldName:FieldMap.keyset()){
                                                   if(FieldMap.get(FieldName)!=null){
                                                       i++;             
                                                       //P2OB-7962 :Resolved ApexSOQLInjection : Added escapeSingleQuotes
                                                       queryStr+=String.escapeSingleQuotes(FieldName)+'=\''+String.escapeSingleQuotes(FieldMap.get(FieldName))+'\'';
                                                       
                                                       if(FieldMap.values().size()>i)
                                                           queryStr+= String.escapeSingleQuotes(AND_STRING);
                                                   }
                                               }                                   
                                               //queryStr=queryStr.removeEnd(String.escapeSingleQuotes(AND_STRING));
                                               
                                               system.debug('*****queryStr '+queryStr);
                                               return Database.query(queryStr);
                                           }
    /* Method to Update or insert user records based on PIMS response ***************/
    public static boolean upsertUserRecordBulk(list<id> lstContactIds, 
                                               map<Id, string> mapConIdUserId, 
                                               string pname, 
                                               boolean isActive,boolean isProfileUpdatable)  {
                                                   boolean isError=false;
                                                   Logger2 logger = Logger2.getLogger('PhoenixGlobalUtil');
                                                   System.debug('@@@PhoenixGlobalUtil');
                                                   list<user> updateuserlist= new list<user>();  
                                                   list<user> insertuserlist= new list<user>();  
                                                   map<id,user> ContactUserMap= new map<id,user> ();   
                                                   list <AccountShare> accshareList= new list<AccountShare>();
                                                   Profile profile;
                                                   system.debug('lstContactIds'+lstContactIds);
                                                   try {
                                                       if(!String.isEmpty(pname))
                                                           profile = [Select id, Name from Profile where Name = :pname];  
                                                       
                                                              List<contact> conlist= [select id, Work_Phone_Number__c,AccountId,Account.Name, FirstName, LastName, email,MailingCountry,MailingStreet,MailingCity from contact where id IN :lstContactIds];

                                                       for(user u:[select id, name,contactid,ProfileId ,profile.name, FederationIdentifier,Contact.MailingCountry,Contact.MailingStreet,Contact.MailingCity from user where contactid in : lstContactIds]){
                                                           ContactUserMap.put(u.contactid,u);
                                                       }                       
                                                       
                                                       
                                                       for(contact Con: conlist){ 
                                                           if (con != null && pname != null && con.email != null) {           
                                                               User newUser = new User();
                                                               system.debug('@@@@@@@@Con'+Con.id); 
                                                               if (ContactUserMap.get(Con.id)!=null) { 
                                                                   newUser.id = ContactUserMap.get(Con.id).id;
                                                                   system.debug('ContactUserMap.get(Con.id).id'+ContactUserMap.get(Con.id).id);
                                                               }
                                                               system.debug('isactive====>'+isActive);
                                                               //update user fields from contact
                                                               newUser.FirstName = con.FirstName;
                                                               newUser.isActive = isActive;
                                                               newUser.LastName = con.LastName;
                                                               newUser.Country = con.MailingCountry;
                                                               newUser.Street = con.MailingStreet;
                                                               newUser.City=con.MailingCity;
                                                               newUser.Email = con.Email;
                                                               newUser.Phone=con.Work_Phone_Number__c; //EDGE-16787
                                                               newUser.MobilePhone=con.Work_Phone_Number__c; //EDGE-16787
                                                               newUser.Username = con.Email + '.prm';
                                                               newUser.CompanyName=con.Account.Name;     
                                                               //CommunityNickname = managepimsinterface to generate auto number
                                                               //update profile name to prm-admin
                                                               
                                                               
                                                               
                                                               /*if(profile!=null && ContactUserMap.ContainsKey(Con.id) && ContactUserMap.get(Con.id).profile.name!=PRMConstants.PRM_PROFILE_PRM_Admin_Australia  && pname!=PRMConstants.PRM_PROFILE_PRM_Admin_Australia){
newUser.ProfileId = profile.Id;

if(profile!=null && ContactUserMap.ContainsKey(Con.id) && ContactUserMap.get(Con.id).profile.name!=PRMConstants.PRM_PROFILE_PRM_Admin_Australia  && pname!=PRMConstants.PRM_PROFILE_PRM_Admin_Australia){
newUser.ProfileId = profile.Id;
}
*/
//system.debug('profile'+profile.Name);
                                                               
system.debug('isProfileUpdatable'+isProfileUpdatable);
if((profile!=null && isProfileUpdatable) || (!isProfileUpdatable && !ContactUserMap.ContainsKey(Con.id)) ){
//if(profile!=null){
                                                                   system.debug('profile'+profile.Name);
                                                                   newUser.ProfileId = profile.Id;
                                                               }
                                                               
                                                               if (newUser.id != null) {
                                                                   if(mapConIdUserId.containskey(Con.id))
                                                                       newUser.FederationIdentifier = mapConIdUserId.get(Con.id);
                                                                   
                                                                   updateuserlist.add(newUser);
                                                                   
                                                                   /*   if(pname == PRMConstants.PRM_PROFILE_PRM_Admin_Australia)
{
AccountShare share = new AccountShare();
share.AccountId=con.AccountId;
share.UserOrGroupId=newUser.id;
share.AccountAccessLevel='Edit';
share.ContactAccessLevel='Edit';
share.OpportunityAccessLevel='Read';
share.CaseAccessLevel='Read';
accshareList.add(share);                  
}else{
AccountShare shareCUser = new AccountShare();
shareCUser.AccountId=con.AccountId;
shareCUser.UserOrGroupId=newUser.id;
shareCUser.AccountAccessLevel='Read';
shareCUser.ContactAccessLevel='Read';
shareCUser.OpportunityAccessLevel='Read';
shareCUser.CaseAccessLevel='Read';
accshareList.add(shareCUser);  

}*/
                                                                   //update newUser;
                                                               } else {
                                                                   //P2OB-5898 : Start : Setting default values through Custom-Settings  
                                                                   PRM_Default__c prmDefaults = PRM_Default__c.getOrgDefaults();                                                       
                                                                   newUser.LocaleSidKey = String.isNotBlank(prmDefaults.Default_Locale_for_new_user__c)? prmDefaults.Default_Locale_for_new_user__c : 'en_AU';
                                                                   newUser.TimeZoneSidKey = String.isNotBlank(prmDefaults.Default_Time_Zone_for_new_user__c)? prmDefaults.Default_Time_Zone_for_new_user__c : 'Australia/Sydney';
                                                                   newUser.LanguageLocaleKey = String.isNotBlank(prmDefaults.Default_Language_for_new_user__c)? prmDefaults.Default_Language_for_new_user__c : 'en_US';
                                                                   newUser.EmailEncodingKey = String.isNotBlank(prmDefaults.Default_Email_Encoding_for_new_user__c)? prmDefaults.Default_Email_Encoding_for_new_user__c:'UTF-8';
                                                                   //P2OB-5898 : End
                                                                   newUser.CommunityNickname = (con.LastName + ManagePIMSInterface.generateUniqueId());
                                                                   newUser.Alias = (con.FirstName + ManagePIMSInterface.generateUniqueId()).substring(0, 6);
                                                                   
                                                                   if(mapConIdUserId.get(Con.id)!=null)
                                                                       newUser.FederationIdentifier = mapConIdUserId.get(Con.id);
                                                                   
                                                                   newUser.ContactId = con.Id;
                                                                   
                                                                   insertuserlist.add(newUser);
                                                               }
                                                               
                                                               
                                                           }
                                                       }
                                                       /* if(accshareList.size() > 0){
System.debug('accshareList'+accshareList);
System.enqueueJob(new QueueableForUpsertSobject(accshareList));
}*/
                                                       
                                                       if(updateuserlist.size()>0)
                                                           update updateuserlist; 
                                                       
                                                       
                                                       if(insertuserlist.size()>0)
                                                           insert insertuserlist;
                                                       
                                                       
                                                       return false;
                                                   }
                                                   catch (Exception e) {
                                                       System.debug(e.getStackTraceString() + 'e.getStackTraceString()****');
                                                       System.debug(e.getMessage() + 'e.getStackTraceString()****');
                                                       //Capture Exception in Application log object
                                                       //log.debug(e);
                                                       logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                                                       logger.exitLogger();
                                                       throw(e);
                                                       return true;
                                                   }
                                               }
    public static Map<String, Schema.RecordTypeInfo> getRecordTypeByName(String sObjectName) {
        Schema.SObjectType s;
        Schema.DescribeSObjectResult resSchema;
        s = sObjectMap.get(sObjectName) ; // getting Sobject Type
        resSchema   = s.getDescribe() ;
        return resSchema.getRecordTypeInfosByName(); //getting all Recordtype for the Sobject
    }
    public static Map<Id, Schema.RecordTypeInfo> getRecordTypeById(String sObjectName) {
        Schema.SObjectType s;
        Schema.DescribeSObjectResult resSchema;
        s = sObjectMap.get(sObjectName) ; // getting Sobject Type
        resSchema = s.getDescribe() ;
        return resSchema.getRecordTypeInfosById(); //getting all Recordtype for the Sobject
    }
    
    public static List<Accountshare> AccountSharebasedOnPRMAccess(List<user> lstUsers){
        list <AccountShare> accshareList= new list<AccountShare>();
        set<id> sProfileId = new set<id>();
        
        for(User obj: lstUsers){
            sProfileId.add(obj.ProfileId);
        }
        map<id,Profile> mpProfile = new map<id,Profile>([select id,Name from Profile where id in:sProfileId]);
        if(!lstUsers.IsEmpty()){
            for(User objUser : lstUsers){
                if(!mpProfile.IsEmpty() && mpProfile.ContainsKey(objUser.ProfileId)&& mpProfile.get(objUser.ProfileId).Name == PRMConstants.PRM_PROFILE_PRM_Admin_Australia)
                {
                    AccountShare share = new AccountShare();
                    system.debug('AccountID =====>'+objUser.AccountId);
                    share.AccountId=objUser.AccountId;
                    share.UserOrGroupId=objUser.Id;
                    share.AccountAccessLevel='Edit';
                    //share.ContactAccessLevel='Edit';
                    share.OpportunityAccessLevel='Read';
                    share.CaseAccessLevel='Read';
                    accshareList.add(share);                  
                }else if(!mpProfile.IsEmpty() && mpProfile.ContainsKey(objUser.ProfileId)&& mpProfile.get(objUser.ProfileId).Name == PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA){
                    AccountShare shareCUser = new AccountShare();
                    system.debug('AccountID intooo=====>'+objUser.AccountId);
                    shareCUser.AccountId=objUser.AccountId;
                    shareCUser.UserOrGroupId=objUser.Id;
                    shareCUser.AccountAccessLevel='Read';
                    //shareCUser.ContactAccessLevel='Read';
                    shareCUser.OpportunityAccessLevel='Read';
                    shareCUser.CaseAccessLevel='Read';
                    accshareList.add(shareCUser);  
                    
                }
            }
        }
        
        
        return accshareList;
        //
        /* if(accshareList.size() > 0){
System.debug('accshareList'+accshareList);
System.enqueueJob(new QueueableForUpsertSobject(accshareList));
}
*/       
    }
    public class ReCaptcha{
        public String endpoint;
        public String token;
        public String secret;
        public Boolean success;
        public String remoteip;
        public String challenge_ts;
        public String hostname;
        public String[] errors;
    }
    public static ReCaptcha validatecaptcha(ReCaptcha recaptcha){
        Logger2 logger = Logger2.getLogger('WebToLead-PRM'); 
        string strReq;
        string strResp;
        try{
            system.debug(recaptcha);
            HttpRequest req= new HttpRequest();
            strReq='secret='+EncodingUtil.urlEncode(recaptcha.secret,'UTF-8')+'&response='+EncodingUtil.urlEncode(recaptcha.token,'UTF-8')+'&';
            
            if(!String.isBlank(recaptcha.remoteip)){
                strReq+='remoteip='+EncodingUtil.urlEncode(recaptcha.remoteip,'UTF-8');
            }              
            
            system.debug(strReq);
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setBody(strReq); 
            req.setEndpoint(recaptcha.endpoint);
            req.setMethod('POST');
            strReq = string.valueOf(req);
            Http http = new Http();
            HttpResponse Resp = http.send(req);
            system.debug('Resp ==>'+Resp);
            system.debug('Resp ==>'+Resp.getBody());
            strResp = string.valueOf(Resp);
            return (ReCaptcha)JSON.deserialize(Resp.getBody(),ReCaptcha.class); 
        }Catch(Exception ex){
            //system.debug('Exception =====>'+ex.getMessage());
        } 
        return null;
    }
    /*Below method checks if the permission set is assigned to user or not 
EDGE-85502 - Added by Saran
*/   
    public static boolean validatePermission(String PerName){          
        List<PermissionSetAssignment> lstcurrentUserPerSet =   [SELECT Id, PermissionSet.Name,AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :Userinfo.getUserId()
                                                                AND PermissionSet.Name =: PerName];        
        system.debug('lstcurrentUserPerSet==' + lstcurrentUserPerSet);
        system.debug('PermissionSet.Name==' + PermissionSet.Name);               
        return !lstcurrentUserPerSet.isEmpty()?true:false;    
    }//validatePermission close
    
      /**
* Determines if field value is changed.
*
* @param      objectId  The object identifier
* @param      fieldApi  The field api
*
* @return     True if changed, False otherwise.
*/
public static boolean isChanged(String objectId, String fieldApi) {
sObject oldObject = !Trigger.oldMap.isEmpty() ? Trigger.oldMap.get(objectId): null;
sObject newObject = !Trigger.newMap.isEmpty() ? Trigger.newMap.get(objectId): null;
    System.debug('oldObject  ' + oldObject );
    System.debug('newObject  ' + newObject );
if (null != oldObject.get(fieldApi) && null != newObject.get(fieldApi) && oldObject.get(fieldApi) != newObject.get(fieldApi)) {
//if (null != newObject.get(fieldApi) && oldObject.get(fieldApi) != newObject.get(fieldApi)) {
return true;
}
return false;
}
 
    public static Account[] accountsByRecType(Account[] accs, Id rt){
        List<Account> newAccs = new List<Account>();
        for(Account a : accs){
            if(a.RecordTypeId == rt) newAccs.add(a);
        }
        return newAccs;
    }
    public static Map<Id,Account> mapAccountsByRecType(Map<Id,Account> aMap, Id rt){
        Map<Id,Account> newMap= new map<Id,Account>();
        
        for(Account a : aMap.values()){
            if(a.RecordTypeId == rt) newMap.put(a.Id,a);
        }
        return newMap;
    }
    /*EDGE-127154 - Added by Purushottam : Tech Debt Changes - Start*/
    /*P2OB-4844 - Modified for adding permission-group assignment*/
    /*P2OB-4844 - Removed code for permission-set-assignment*/
    /*P2OB-7962 - Modified below method to assign permission-set-group based on contact's partner-role*/
    public static void onboardingActiveInsertPSAList(map<id, contact> onboardingactiveConts,Map<Id,PermissionSetGroup> psgaMap,Map<Id,Partner_Permission_Sets__mdt> permission_set_mdt)
    {
        List<Profiles__c> profiles = Profiles__c.getall().values();
        List<String> allowedProfiles = new List<String>();

        list<PermissionSetAssignment> insertPSAGList = new list<PermissionSetAssignment>(); //Team Hawaii : Ritika : P2OB-4844 : List of permission-set-assignment records, to be inserted     
        list<PermissionSetGroup> enablemodularPSG=[SELECT Id,DeveloperName FROM PermissionSetGroup WHERE DeveloperName= :PRMConstants.Enabled_to_sell_Modular_Products limit 1];
       
       for(Profiles__c pf:profiles)
            allowedProfiles.add(pf.name);
        Map<String,PermissionSetGroup> psgaMap_modified = new Map<String,PermissionSetGroup>();
        for(PermissionSetGroup record : psgaMap.values())
            psgaMap_modified.put(record.developerName,record);
        
        Map<id,User> activeUserList = new Map<id,User>([select id,name,profile.name,contact.Partner_Role__c,contact.Account.CWP_Eligible_Partner__c,contactId from user where contactid =: onboardingactiveConts.keyset()]);
        Map<String,Set<String>> roleVsPSG = new Map<String,Set<String>>();
        
         //P2OB-7962 : A Map for storing roles and its associated permission-set-groups
        for(Partner_Permission_Sets__mdt mdt_record : permission_set_mdt.values()){
            list<String> required_by_roles = mdt_record.Required_by_Roles__c!=null && mdt_record.Required_by_Roles__c!='' ? mdt_record.Required_by_Roles__c.split(',') : new List<String>{};
            for(String role : required_by_roles){
                if(!roleVsPSG.containsKey(role))
                    roleVsPSG.put(role,new Set<String>());
                roleVsPSG.get(role).add(mdt_record.Permission_Set_Name__c);


                	}
                }
        
        //P2OB-7962 : A Map for storing user and list of permisssion-set-groups that user should have
        Map<String,Set<String>> userAndPSgroup = new Map<String,Set<String>>(); 
            for(User u:activeUserList.values()){
               if(allowedProfiles.contains(u.profile.name)){
               
                if(u.contact.Account.CWP_Eligible_Partner__c == true){ //EDGE-181607
                            if(enablemodularPSG.size()>0){
                               PermissionSetAssignment psagenablemodular = new PermissionSetAssignment(PermissionSetGroupId =enablemodularPSG[0].id ,AssigneeId = u.id);
                               insertPSAGList.add(psagenablemodular); 
                           }
            }
        

                    if(!userAndPSgroup.containsKey(u.Id))
                        userAndPSgroup.put(u.id,new Set<String>());
                    if(u.Contact.partner_role__c != null){
                        for(String role : u.Contact.partner_role__c.split(';')){
                            if( roleVsPSG != null && roleVsPSG.get(role) != null)  
                            userAndPSgroup.get(u.id).addAll(roleVsPSG.get(role));
                        }
                    }
                }
            }
        
        System.debug('***Telstra:PhoenixGlobalUtil:onboardingActiveInsertPSAList:userAndPSgroup:'+userAndPSgroup);
        list<PermissionSetAssignment> deletePSAGList = new list<PermissionSetAssignment>(); //P2OB-7962 : List of permission-set-assignments to be removed
        //Start : P2OB-4844 :Team Hawaii:Ritika: Assign Permission-set-Group when onboarding a new Partner-User
        //P2OB-7962 : Role based assignment of permission-set-group assignment
        for(String eachUser : userAndPSgroup.keySet()){         
                  for(String eachPSG : userAndPSgroup.get(eachUser)) {   
             		//for given permission-set-groups, create permission-set-assignment for each user 
                		PermissionSetAssignment psag = new PermissionSetAssignment(PermissionSetGroupId = psgaMap_modified.get(eachPSG).id, 
                       		                                                       AssigneeId = eachUser);
                		system.debug('***Telstra:PhoenixGlobalUtil:PermissionSetGroup_Assignment:'+psag);
                		insertPSAGList.add(psag);
                  }                       
        }
        //P2OB-7962 : Read users permission-set assignments to find if some needs to be deleted
        Map<id,PermissionSetAssignment> psa_list = new Map<id,PermissionSetAssignment>([select id,AssigneeId,PermissionSetGroup.DeveloperName from PermissionSetAssignment where AssigneeId in :activeUserList.keySet() and PermissionSetGroupId in:psgaMap.keySet()]);
        for(PermissionSetAssignment psa : psa_list.values()){
            system.debug('***Telstra:PhoenixGlobalUtil:'+psa);
            	if(userAndPSgroup!= null && userAndPSgroup.get(psa.AssigneeId) != null){
            		if(!(userAndPSgroup.get(psa.AssigneeId).contains(psa.PermissionSetGroup.DeveloperName))){
                		system.debug('***Telstra:PhoenixGlobalUtil:To Delete PermissionSetGroup_Assignment:'+psa);
                		deletePSAGList.add(psa); 
            }
          }
        }
        
        
        if(insertPSAGList.size()>0){
            Database.SaveResult[] resultI = database.insert(insertPSAGList,false);
            System.debug('***PhoenixGlobalUtil:onboardingActiveInsertUserLicense:SaveresultI:'+resultI);
        }
        //P2OB-7962 :Remove PSG which do not associate with any role on contact
        if(deletePSAGList.size()>0){
             Database.DeleteResult[] resultD = database.delete(deletePSAGList,false);
            System.debug('***PhoenixGlobalUtil:onboardingActiveInsertUserLicense:SaveresultD:'+resultD);
        }
        //End : P2OB-4844 :Team Hawaii:Ritika: Assign Permission-set-Group when onboarding a new Partner-User        
          onboardingActiveInsertUserLicense(new set<User>(activeUserList.Values()));
} 
    
    public static void onboardingActiveInsertUserLicense(set<User> addUserList){
        list<UserPackageLicense> userLicenseList = new list<UserPackageLicense>();
        Set<String> LicenceNamespace = new Set<String>(label.PRM_PARTNER_LICENCES.split(','));
        Map<Id,PackageLicense> packLicMap= new Map<Id,PackageLicense>([SELECT Id  FROM PackageLicense WHERE NamespacePrefix in :LicenceNamespace]); 
        
        for(user eachUser : addUserList){
                    for(PackageLicense eachPL : packLicMap.values()){                   
                        UserPackageLicense UPL= new UserPackageLicense(UserId = eachUser.id, PackageLicenseId = eachPL.id);
                        userLicenseList.add(UPL);                  
                    }
            }
        System.debug('***PhoenixGlobalUtil:onboardingActiveInsertUserLicense:userLicenseList:'+userLicenseList);
        if(userLicenseList.size()>0){
             Database.SaveResult[] result = database.insert(userLicenseList,false);
            System.debug('***PhoenixGlobalUtil:onboardingActiveInsertUserLicense:Saveresult:'+result);
        }
    }
    
    //Team Hawaii :Ritika : P2OB-4844: Modified signature to accept permission-set-group in parameter
    public static void onboardingInActiveInsertPSAList(map<id, contact> onboardingInactiveConts, Map<Id,PermissionSetGroup> psagMap)
    {
        list<user> inActiveUserList = [select id,name,profile.name  
                                           from user 
                                           where contactid in :onboardingInactiveConts.keyset()]; 
        List<Profiles__c> profiles = Profiles__c.getall().values();
        
            //Filter PRM Profiles
            list<User> delUserList = new list<User>();
            for(Profiles__c pf:profiles){
                for(User eachUser:inActiveUserList){
                    if(eachUser.profile.name==pf.name){
                        delUserList.add(eachUser);
                    }
                }
            } 
        Map<id,user> inactiveUsrMap = new Map<id,user>(delUserList);
        //Team Hawaii: Ritika : P2OB-4844: Replaced permissionSetId by permissionSetGroupId
        List<PermissionSetAssignment> deletePSAList = [SELECT Id 
                                                               FROM PermissionSetAssignment 
                                                               WHERE AssigneeId IN :inactiveUsrMap.keyset() 
                                                               AND PermissionSetGroupId in: psagMap.keySet()]; 
		//P2OB-7962 : Added exception-handling 
        if(deletePSAList.size()>0){
            try{
                delete deletePSAList;
            }catch(Exception e){
                System.debug('***Telstra:PhoenixGlobalUtil:onboardingInActiveInsertPSAList');
            }
        }
                    
        
        onboardingInActiveDeleteUserLicense(inactiveUsrMap);
    }
    public static void  onboardingInActiveDeleteUserLicense(Map<id,user> inactiveUsrMap){
        Set<String> LicenceNamespace = new Set<String>(label.PRM_PARTNER_LICENCES.split(','));
        Map<Id,PackageLicense> packLicMap= new Map<Id,PackageLicense>([SELECT Id  FROM PackageLicense WHERE NamespacePrefix in :LicenceNamespace]); 
        
        list<UserPackageLicense> deletePkglicList = [SELECT Id FROM UserPackageLicense 
                                                     WHERE UserId IN :inactiveUsrMap.keyset() 
                                                     AND PackageLicenseId in: packLicMap.keySet()];                             
		System.debug('***PhoenixGlobalUtil:onboardingInActiveDeleteUserLicense:'+deletePkglicList);        
        if(deletePkglicList.size()>0)
            delete deletePkglicList;
    }
    /*EDGE-127154 - Added by Purushottam : Tech Debt Changes - End*/
	
	
	public static map<String, CSPOFA__Orchestration_Process_Template__c> getorchesTemplates() {
        if(orchesTemplates == null){
            system.debug('orchesTemplates'+orchesTemplates);
            orchesTemplates= new map<String, CSPOFA__Orchestration_Process_Template__c>();
          for(CSPOFA__Orchestration_Process_Template__c orctemp: [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c]){
            orchesTemplates.put(orctemp.Name, orctemp);
        }
        }
        system.debug('orchesTemplates'+orchesTemplates);
      return orchesTemplates;
    }
}