/*
    AUTHOR : Uday K - Orlando Team- September 24th 2018
    DESCRIPTION : This class is to look at ensuring that once the PRM is setup to use PIMs for Partner User management, that the Partner Users that are setup for MVP are updated so that they will use PIMs.
                  Initial Partner Users, will be using Saleforce for authentication.
*/

global with sharing  class ManagePIMSUsersOrgsBatch implements Database.Batchable<SObject>, Database.AllowsCallouts  {
  public String sQuery;
  public string sobjName;
  public string sRequest;
  public ManagePIMSUsersOrgsBatch(String sQuery,string sobjName) {
    
    this.sQuery = sQuery; 
    this.sobjName=sobjName;
  }
  /* Start method*/
  global Database.QueryLocator start(Database.BatchableContext context) {
    
      /*
        //Commented below code as this is no longer being used Aug 28 2019
      if(sQuery == ''){
          if(sobjName == 'Contact'){
              sQuery = 'SELECT Id,Bulk_Load_Status__c,AccountId,RecordType.Name,Account.PIMS_Sync_Status__c FROM Contact WHERE Bulk_Load_Status__c = ' + '\'PIMSuserCreate\' AND Account.PIMS_Sync_Status__c = ' + '\'Success\' AND Recordtype.Name = ' + '\'Partner Contact\'';
          }else if(sobjName == 'Account'){
              sQuery = 'SELECT Id,Account_Status__c,RecordType.Name FROM Account WHERE (Account_Status__c = ' + '\'New\' OR Account_Status__c = ' + '\'Pending Activation\' OR Account_Status__c = ' + '\'Active\') AND RecordType.Name=' + '\'Partner\' ';
          }      
      }
      //Comments eneded Aug 28 2019
      
	*/
     
   system.debug('sQuery ====>'+sQuery);
    return Database.getQueryLocator(sQuery);
  }

  global void execute(Database.BatchableContext context, List<sobject> scope) {
    /*
     //Commented below code as this is no longer being used Aug 28 2019
     
     system.debug('scope ===>' + scope);
    map<id, id> mpContactAcnt = new map<id, id>();
    map<id, List<Contact>> mpContactLst = new map<id, List<Contact>>();
    set<id> sAccountIds = new set<id>();    
    List<WrapperOrgServiceResponse> lstWrapOrgs = new List<WrapperOrgServiceResponse>();
    set<id> sValidAccnts = new set<id>();
    set<id> sErrorAccnts = new set<id>();
    map<id,string> mapOrgIds = new map<id,string>();
    system.debug('scope');
    string shandlername = 'PimsMicroserviceManageOrgBatch'; // have to use a custom lable
    string shandlernameUser = 'PimsMicroserviceManageUserBatch';// have to use a custom lable
      
    // ------------ STARTED MANAGE ORG -----------------------------
   Logger2 logger = Logger2.getLogger('ManagePimsUsersOrgBatch'); 
      try{
   if(sobjName == 'Account'){
        Logger2 logger3 = Logger2.getLogger('CreateUsersBatchAccount');
    for (sObject S : scope) {
      Account Acc = (Account)S;
              WrapperPageParameters objparams = new WrapperPageParameters();
              objparams.pageObjectID = Acc.id;
              objparams.pimsAPIType = 'MANAGEORG';
              objparams.pimsCallType = 'createOrg';
              string sParams = JSON.serialize(objparams);
              system.debug('sParams ====>'+sParams);
              HTTPResponse httpResponse = (HTTPResponse) ManagePIMSController.invoke(sParams, shandlername); 
              system.debug('httpResponse ====>'+httpResponse);

              if (httpResponse != null && httpResponse.getBody() != null) {
                  system.debug('httpResponseBody ====>'+httpResponse.getBody());
                string strResponse = httpResponse.getBody();
                WrapperOrgServiceResponse objWrapOrg = new WrapperOrgServiceResponse();
                objWrapOrg = (WrapperOrgServiceResponse)JSON.deserialize(strResponse, WrapperOrgServiceResponse.class);
                objWrapOrg.AccountId = Acc.id;
                lstWrapOrgs.add(objWrapOrg);
               system.debug('objWrapOrg.status ====>'+objWrapOrg.status);
              logger3.logMessages(PRMConstants.sRequest, httpResponse.getBody(), 'Technical', '', objWrapOrg.status, '', false, false);
              logger3.exitLogger();
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
            mapOrgIds.put(objWrapper.AccountId,objWrapper.OrgId);
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
            List<Account> lstAccountsToUpdate = [select id,isPartner,Account_Status__c,Partner_External_Id__c,PIMS_Sync_Status__c from Account where id in:sValidAccnts];
           
            if(!lstAccountsToUpdate.isEmpty()){                
                for(Account objAcnt : lstAccountsToUpdate){                    
                    objAcnt.IsPartner = true;
                    if(objAcnt.Account_Status__c == 'New')
                        objAcnt.Account_Status__c = 'Pending activation';
                    objAcnt.Partner_External_Id__c=mapOrgIds.get(objAcnt.id);
                    objAcnt.PIMS_Sync_Status__c='Success';
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
          
         
      } 
      
      if(!lstFinalAccounts.isEmpty())
          update lstFinalAccounts;
       if(!lstErrorAccounts.isEmpty())
           update lstErrorAccounts;
      
       //  END ----------  LOGIC FOR MANAGE ORG ---- ----------------------------
   
      
      //  STARTED ----------  LOGIC FOR MANAGE USER ---- ----------------------------
  }else if(sobjName == 'Contact'){
    
    List<contact> lstFContacts = new List<Contact>();
    Logger2 logger1 = Logger2.getLogger('CreateUsersBatch');
    system.debug('lstContacts ===>' + lstFContacts);
    set<id> sContacts = new set<id>();
    list<WrapperServiceResponse> lstwrap = new list<WrapperServiceResponse>();
    list<Id> lstContactIds = new list<Id>();
    map<Id, string> mapConIdUserId = new map<Id, string>();
    String profileName = 'PRM Community User - Australia';
    Boolean ISActive = True;
   // if (!lstFContacts.isEmpty()) {
      for (Sobject  S: Scope) {
          Contact Obj = (Contact)S;
        WrapperPageParameters objparams = new WrapperPageParameters();
        objparams.pageObjectID = Obj.id;
        objparams.pimsAPIType = 'MANAGEUSER';
        objparams.pimsCallType = 'createUser';
        string sParams = JSON.serialize(objparams);
        system.debug('sParams ===>' + sParams);
        // Object Response = ManagePIMSController.invoke(sParams,shandlernameUser);
        HTTPResponse httpResponse = (HTTPResponse) ManagePIMSController.invoke(sParams, shandlernameUser);
        system.debug('Response cont ==>' + httpResponse);       
        //String Jsonstr = '{\n' +' "title" :"Success",\n' +' "status" : "200",\n' +' "pimsStatus" : "0",\n' +' "description" : "Success",\n' +' "userIdCreated" : "CreateUserS"\n' +'}';
        String sResponse;
          if (HTTPResponse != null && HTTPResponse.getBody() != null){
                sResponse = HTTPResponse.getBody();
              system.debug('sResponse ====>'+sResponse);
                WrapperServiceResponse objWrap = new WrapperServiceResponse();
                objWrap = (WrapperServiceResponse)JSON.deserialize(sResponse, WrapperServiceResponse.class);
                objWrap.ContactId = Obj.Id;
              system.debug('objWrap.status ====>'+objWrap.status);
                lstwrap.add(objWrap);
              if(objWrap.status != '200'){
                  logger1.logMessages(PRMConstants.sRequest, httpResponse.getBody(), 'Technical', '', objWrap.status, '', false, false);
              	  logger1.exitLogger();
              }
              
          }
          
        system.debug('lstwrap =====>' + lstwrap);
      }
    //}
      
       
      
      set<id> sErrorContacts = new set<id>();
    if (!lstwrap.isEmpty()) {
      for (WrapperServiceResponse objWrapper : lstwrap) {
        if (objWrapper.status == '200') {
          lstContactIds.add(objWrapper.ContactId);
        }else{
            sErrorContacts.add(objWrapper.ContactId);
        }
        if (objWrapper.userPid != null && objWrapper.userPid != '') {
          mapConIdUserId.put(objWrapper.ContactId, objWrapper.userPid);
        }
        system.debug('lstContactIds ===>' + lstContactIds);
        system.debug('mapConIdUserId ===>' + mapConIdUserId);
      }
    }
    
      List<Contact> lstSuccessContacts = new list<Contact>();
      List<Contact> lstSuccessContactsToUpdate = new list<Contact>();
      if(!lstContactIds.isEmpty()){
          lstSuccessContacts = [select id,Bulk_Load_Status__c,Account.Account_Status__c,Contact_Status__c 
                                from Contact 
                                where id in: lstContactIds];
          for(Contact objCon:lstSuccessContacts){
              objCon.Bulk_Load_Status__c='Processed';
              objCon.Onboarding_Status__c = objCon.Account.Account_Status__c=='Active'?'Active':'Inactive';
              lstSuccessContactsToUpdate.add(objCon);
          }
          if(!lstSuccessContactsToUpdate.isEmpty()){
              //update lstSuccessContactsToUpdate;
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
              //update lstErrorContactsToUpdate;
          }
      }
    // End Of looping the contacts to check with PIMS system and doing the associate updates on contacts 
      
      // This method will do the upsert of users based on the Email
         PhoenixGlobalUtil.upsertUserRecordBulk(lstContactIds, mapConIdUserId, profileName, ISActive,true);
   } 
      // ------------------  END for MANAGE USER -----------------------
      }catch(Exception ex){
          
          logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
          logger.exitLogger();
      }

//Code comment ended Aug 28 2019

*/
  }
      
 
    /* Finish Method -- as of now no requirement to do anything here*/
  global void finish(Database.BatchableContext context) {
  }



  /*
   //Commented below code as this is no longer being used- Aug 28 2019
   
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
    public  String userPid;
    public Id ContactId;
  }

  public class WrapperOrgServiceResponse {
    public  String title;
    public  String status;
    public  String pimsStatus;
    public  String description;
    public Id AccountId;
    public string orgId;
  }
//Commented code ended-Aug 28 2019
*/
}