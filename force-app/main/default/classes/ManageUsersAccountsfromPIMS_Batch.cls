/*
    AUTHOR : Uday K - Orlando Team- June 8th 2018
    DESCRIPTION : This class is to look at ensuring that once the PRM is setup to use PIMs for Partner User management, that the Partner Users that are setup for MVP are updated so that they will use PIMs.
                  Initial Partner Users, will be using Saleforce for authentication.
*/

global class ManageUsersAccountsfromPIMS_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts  {
  public String sQuery;
      public ManageUsersAccountsfromPIMS_Batch(String sQuery) {
    this.sQuery = sQuery; 
  }

  /* public Batch_ManagePIMSInterface() {
    this.sQuery = sQuery;
  }*/

    
  /* Start method*/
  global Database.QueryLocator start(Database.BatchableContext context) {
    sQuery = null != sQuery
             ? sQuery
             : 'SELECT Id,Bulk_Load_Status__c,AccountId FROM Contact WHERE Bulk_Load_Status__c = ' + '\'PIMSuserCreate\'';
    string strPIMSuserCreate = 'PIMSuserCreate';
    boolean bIsPartner = False;
    //return Database.getQueryLocator('SELECT Id,Bulk_Load_Status__c,AccountId FROM Contact WHERE Bulk_Load_Status__c =: '+strPIMSuserCreate+' and Account.IsPartner =: '+bIsPartner+'');
    return Database.getQueryLocator(sQuery);
  }

  global void execute(Database.BatchableContext context, List<Contact> scope) {
   /* 
    //Commented below code as this is no longer being used Aug 28 2019
     
     system.debug('scope ===>' + scope);
    map<id, id> mpContactAcnt = new map<id, id>();
    map<id, List<Contact>> mpContactLst = new map<id, List<Contact>>();
    set<id> sAccountIds = new set<id>();
      //Building the set of accounts related to the contacts and constructing a map with Account as key and contacts as list
    for (Contact objCon : scope) {
      if (objCon.AccountId != null) {
        sAccountIds.add(objCon.AccountId);
        mpContactAcnt.put(objCon.Id, objCon.AccountId);
      }
      if (objCon.AccountId != null) {
        if (mpContactLst.get(objCon.AccountId) != null) {
          List<contact> lstcons = mpContactLst.get(objCon.AccountId);
          lstcons.add(objCon);
          mpContactLst.put(objCon.AccountId, lstcons);
        } else {
          List<Contact> lst = new List<Contact>();
          lst.add(objCon);
          mpContactLst.put(objCon.AccountId, lst);
        }
      }
    }
      // End Of --- Building the set of accounts related to the contacts and constructing a map with Account as key and contacts as list
    // List<Account> lstAccounts = [select id,isPartner from account where id=:'0012N000002QQNw'];
    List<Account> lstAccounts = [select id, isPartner,Account_Status__c
                                 from account
                                 where id In : sAccountIds and Account_Status__c != 'Inactive'];
    List<WrapperOrgServiceResponse> lstWrapOrgs = new List<WrapperOrgServiceResponse>();
    set<id> sValidAccnts = new set<id>();
    set<id> sErrorAccnts = new set<id>();
    system.debug('lstAccounts');
    string shandlername = 'PimsMicroserviceManageOrgBatch'; // have to use a custom lable
    string shandlernameUser = 'PimsMicroserviceManageUserBatch';// have to use a custom lable
    // Looping the list of account which needs to check with PIMS system  and doing the associate updates as per the business 
    for (Account Acc : lstAccounts) {
      
              WrapperPageParameters objparams = new WrapperPageParameters();
              objparams.pageObjectID = Acc.id;
              objparams.pimsAPIType = 'MANAGEORG';
              objparams.pimsCallType = 'createOrg';
              string sParams = JSON.serialize(objparams);
              system.debug('sParams');
              HTTPResponse httpResponse = (HTTPResponse) ManagePIMSController.invoke(sParams, shandlername);
              system.debug('httpResponse ==>' + httpResponse);
              system.debug('httpResponse ==>' + httpResponse.getBody());
              if (httpResponse != null && httpResponse.getBody() != null) {
                string strResponse = httpResponse.getBody();
                WrapperOrgServiceResponse objWrapOrg = new WrapperOrgServiceResponse();
                objWrapOrg = (WrapperOrgServiceResponse)JSON.deserialize(strResponse, WrapperOrgServiceResponse.class);
                objWrapOrg.AccountId = Acc.id;
                lstWrapOrgs.add(objWrapOrg);
                system.debug('lstWrapOrgs ===>'+lstWrapOrgs);
              }
      }    
    if (!lstWrapOrgs.isEmpty()) {
        system.debug('lstWrapOrgs111 ===>'+lstWrapOrgs);
      for (WrapperOrgServiceResponse objWrapper : lstWrapOrgs) {
          system.debug('objWrapperstatus ===>'+objWrapper.status);
        if (objWrapper.status == '200') {
            system.debug('objWrapperstatusinnn ===>'+objWrapper.status);
          sValidAccnts.add(objWrapper.AccountId);
        }else{ 
            
           sErrorAccnts.add(objWrapper.AccountId);
            system.debug('sErrorAccnts ===>'+sErrorAccnts);
        }
      }
    } 
      system.debug('sValidAccnts ===>'+sValidAccnts);
      system.debug('sErrorAccnts ===>'+sErrorAccnts);
       List<Account> lstFinalAccounts = new List<Account>();
        if(!sValidAccnts.isEmpty()){
            List<Account> lstAccountsToUpdate = [select id,isPartner,Account_Status__c from Account where id in:sValidAccnts and Account_Status__c = 'new'];
           
            if(!lstAccountsToUpdate.isEmpty()){                
                for(Account objAcnt : lstAccountsToUpdate){                    
                    objAcnt.Account_Status__c = 'Pending application';
                    objAcnt.isPartner = true;
                    lstFinalAccounts.add(objAcnt);                    
                }                
               
            }
        }
      List<Account> lstErrorAccounts = new List<Account>();
      List<Contact> lstContactsToUpdateErrors = new List<Contact>();
      if(!sErrorAccnts.isEmpty()){
          List<Account> lstAccountsErrors = [select id,PIMS_Sync_Status__c from Account where id in:sErrorAccnts];
          
            if(!lstAccountsErrors.isEmpty()){                
                for(Account objAcnt : lstAccountsErrors){
                    objAcnt.PIMS_Sync_Status__c='Not Synced';//PIMS Error';
                    lstErrorAccounts.add(objAcnt);                    
                }                
                
            }
         // End Of --Looping the list of account which needs to check with PIMS system  and doing the associate updates as per the business 
          
          // Start Of looping the contacts to check with PIMS system and doing the associate updates on contacts 
          List<Contact> lstContacts = [select id,AccountId,Bulk_Load_Status__c from Contact where AccountId in:sErrorAccnts];
          
          for(Contact objContact : lstContacts){
              objContact.Bulk_Load_Status__c = 'PIMS Account Error';
              lstContactsToUpdateErrors.add(objContact);
          }
         
      } 
    
    List<contact> lstFContacts = new List<Contact>();
    if (!sValidAccnts.isEmpty()) {
      system.debug('mpContactLst ===>' + mpContactLst);
      for (id sAcntID : sValidAccnts) {
        if (mpContactLst.get(sAcntID) != null && lstFContacts != null) {
          list<contact> templist = new list<contact>();
          templist = mpContactLst.get(sAcntID);
          lstFContacts.addAll(templist);
        } else {
          lstFContacts = mpContactLst.get(sAcntID);
          
        }
      }
    } 
      system.debug('lstContacts ===>' + lstFContacts);
    set<id> sContacts = new set<id>();
    list<WrapperServiceResponse> lstwrap = new list<WrapperServiceResponse>();
    list<Id> lstContactIds = new list<Id>();
    map<Id, string> mapConIdUserId = new map<Id, string>();
    String profileName = 'PRM Community User - Australia';
    Boolean ISActive = True;
    if (!lstFContacts.isEmpty()) {
      for (Contact Obj : lstFContacts) {
        WrapperPageParameters objparams = new WrapperPageParameters();
        objparams.pageObjectID = Obj.id;
        objparams.pimsAPIType = 'MANAGEUSER';
        objparams.pimsCallType = 'createUser';
        string sParams = JSON.serialize(objparams);
        system.debug('sParams ===>' + sParams);
        // Object Response = ManagePIMSController.invoke(sParams,shandlernameUser);
        HTTPResponse httpResponse = (HTTPResponse) ManagePIMSController.invoke(sParams, shandlernameUser);
        system.debug('Response cont ==>' + httpResponse);
        system.debug('Response body ==>' + httpResponse.getbody());
        //String Jsonstr = '{\n' +' "title" :"Success",\n' +' "status" : "200",\n' +' "pimsStatus" : "0",\n' +' "description" : "Success",\n' +' "userIdCreated" : "CreateUserS"\n' +'}';
        String sResponse;
          if (HTTPResponse != null && HTTPResponse.getBody() != null){
                sResponse = HTTPResponse.getBody();
                WrapperServiceResponse objWrap = new WrapperServiceResponse();
                objWrap = (WrapperServiceResponse)JSON.deserialize(sResponse, WrapperServiceResponse.class);
                objWrap.ContactId = Obj.Id;
                lstwrap.add(objWrap);
          }
          
        system.debug('lstwrap =====>' + lstwrap);
      }
    }
      
       if(!lstFinalAccounts.isEmpty())
          update lstFinalAccounts;
       if(!lstErrorAccounts.isEmpty())
           update lstErrorAccounts;
      if(!lstContactsToUpdateErrors.isEmpty())
          update lstContactsToUpdateErrors;
           
      set<id> sErrorContacts = new set<id>();
    if (!lstwrap.isEmpty()) {
      for (WrapperServiceResponse objWrapper : lstwrap) {
        if (objWrapper.status == '200') {
          lstContactIds.add(objWrapper.ContactId);
        }else{
            sErrorContacts.add(objWrapper.ContactId);
        }
        if (objWrapper.userIdCreated != null && objWrapper.userIdCreated != '') {
          mapConIdUserId.put(objWrapper.ContactId, objWrapper.userIdCreated);
        }
        system.debug('lstContactIds ===>' + lstContactIds);
        system.debug('mapConIdUserId ===>' + mapConIdUserId);
      }
    }
    
      List<Contact> lstSuccessContacts = new list<Contact>();
      List<Contact> lstSuccessContactsToUpdate = new list<Contact>();
      if(!lstContactIds.isEmpty()){
          lstSuccessContacts = [select id,Bulk_Load_Status__c,Contact_Status__c from Contact where id in: lstContactIds];
          for(Contact objCon:lstSuccessContacts){
              objCon.Bulk_Load_Status__c='Processed';
              objCon.Contact_Status__c = 'Active';
              lstSuccessContactsToUpdate.add(objCon);
          }
          if(!lstSuccessContactsToUpdate.isEmpty()){
              update lstSuccessContactsToUpdate;
          }
      }
      
     List<Contact> lstErrorContacts = new List<Contact>();
     List<Contact> lstErrorContactsToUpdate = new List<Contact>();
     
      if(!sErrorContacts.isEmpty()){
          lstErrorContacts = [select id,Bulk_Load_Status__c,Contact_Status__c from Contact where id in: sErrorContacts];
          for(Contact objCon:lstErrorContacts){
              objCon.Bulk_Load_Status__c='PIMS Error';             
              lstErrorContactsToUpdate.add(objCon);
          }
          if(!lstErrorContactsToUpdate.isEmpty()){
              update lstErrorContactsToUpdate;
          }
      }
     // End Of looping the contacts to check with PIMS system and doing the associate updates on contacts 
      
      //This method will do the upsert of users based on the Email
         PhoenixGlobalUtil.upsertUserRecordBulk(lstContactIds, mapConIdUserId, profileName, ISActive,true);

//Code comments ended-Aug 28 2019
      */
  }
 
    /* Finish Method -- as of now no requirement to do anything here*/
  global void finish(Database.BatchableContext context) {
  }


/*
 //Commented below code as its no longer used -Aug 28 2019
 
  public class WrapperPageParameters {
    public  String pageObjectID;
    public  String pimsAPIType;
    public  String pimsCallType;
  }

  public class WrapperResponse {
    public  string Status;
    public  string Statuscode;
  }

  public Class WrapperPIMSresponseBulk {
    public HttpResponse httpresponse;
    public Contact contact;
    //- collect all the response in a WrapperOf HttpResponse and Contact Object
  }

  public static WrapperResponse parsePageParams(Object Response) {
    return (WrapperResponse)JSON.deserialize((String)Response, WrapperResponse.class);
  }

  public class WrapperServiceResponse {
    public  String title;
    public  String status;
    public  String pimsStatus;
    public  String description;
    public  String userIdCreated;
    public Id ContactId;
  }

  public class WrapperOrgServiceResponse {
    public  String title;
    public  String status;
    public  String pimsStatus;
    public  String description;
    public Id AccountId;
  }
//Code comments ended Aug 28 2019
*/
}