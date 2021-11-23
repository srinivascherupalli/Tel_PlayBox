public with sharing class CreateSiteController {
    
    private CreateSiteController(){
        
    }
        
    @AuraEnabled
    public static String saveNewSite(String siteName, String account, String address){
        try{
            system.debug('Create site Apex Controller Save function ');
            system.debug('Site Name ' + siteName);
            system.debug('account ' + account);
            system.debug('address ' + address);
            cscrm__Site__c site = new cscrm__Site__c();
            site.Name = siteName;
            site.cscrm__Account__c = account;
            site.cscrm__Installation_Address__c = address;
            Account accountForCIDN=Database.query('SELECT CIDN__c   FROM Account WHERE ID =:account');
            cscrm__Address__c addressForID=Database.query('SELECT Address_ID__c FROM cscrm__Address__c WHERE ID =:address');
            site.Composite_Key__c=accountForCIDN.CIDN__c+addressForID.Address_ID__c;
            return AddressAndSiteObjectUtility.siteSaveUtility(site);
        }
        catch(Exception e){
            system.debug('Exception message ' + e.getMessage());
            return 'Failed';
        }
    }
    @AuraEnabled
    public static sObject getAddressType(String address){
        sObject AddressType;       
        AddressType = Database.query('select cscrm__Address_Type__c from cscrm__Address__c where Id = : address'); 
        return AddressType;
    }

    @AuraEnabled
    public static String getSiteNameSFDC(String addressId){
        String siteName = '';
        try{
            if(!String.isEmpty(addressId)){
                cscrm__Address__c addressRecord = [SELECT Street_Number_Start_calc__c, Street_Number_End_calc__c, cscrm__Street_Name__c, Street_Type_calc__c, Locality__c FROM cscrm__Address__c WHERE Id =:addressId];
                system.debug('addressRecord---------->'+addressRecord);
                String streetNumberStart = (null != String.valueOf(addressRecord.Street_Number_Start_calc__c)? String.valueOf(addressRecord.Street_Number_Start_calc__c) : '');
                String streetNumberEnd = (null != String.valueOf(addressRecord.Street_Number_End_calc__c)? String.valueOf(addressRecord.Street_Number_End_calc__c) : '');
                String streetName = (null != String.valueOf(addressRecord.cscrm__Street_Name__c)? String.valueOf(addressRecord.cscrm__Street_Name__c) : '');
                String streetType = (null != String.valueOf(addressRecord.Street_Type_calc__c)? String.valueOf(addressRecord.Street_Type_calc__c) : '');
                String locality = (null != String.valueOf(addressRecord.Locality__c)? String.valueOf(addressRecord.Locality__c) : '');
                
                /**
                *   @Description - If site name is start with '0' or 'null' or BLANK values then ignore value.
                *   @Jira Story Ref - EDGE-77460
                *   @ModifiedBy - Ramesh Somalagari,OSAKA
                **/
                system.debug('streetNumberStart : '+streetNumberStart);
                system.debug('streetNumberEnd : '+streetNumberEnd);
                if(streetNumberStart == null || streetNumberStart == '' || streetNumberStart.equals('0') || streetNumberStart.equals('null')) {
                   streetNumberStart = '';
                } else {
                    siteName = streetNumberStart + ' ';
                }
                if(streetNumberEnd == null || streetNumberEnd == '' || streetNumberEnd.equals('0') || streetNumberEnd.equals('null')) {
                   streetNumberEnd = '';
                } else {
                    siteName += streetNumberEnd + ' ';
                }
                
                siteName += streetName + ' ' + streetType + '  ' + locality;
                siteName = siteName.trim();
            }
            system.debug('Site Name : '+siteName);
            return siteName;
        }catch(Exception e){
            system.debug('Exception while getting address details :'+e.getMessage());
        }
        system.debug('Site Name : '+siteName);
        return siteName;
    }
    /* Author : Maq;*/
    @AuraEnabled
   public static sObject getParentAccount(String accountId){
        Account accountRecord = New Account();
        try{
            if(!String.isEmpty(accountId)){
                Account accountDetails =Database.query('SELECT Id, Name FROM Account WHERE ID =:accountId');
                accountRecord = accountDetails;
               }
            return accountRecord;
        }catch(Exception e){
            system.debug('Exception while loading account details :'+e.getMessage());
        }
        return accountRecord;
    }
       /* Author : Maq;*/
    @AuraEnabled
   public static cscrm__Site__c getParaSaveAndNew(){
        
        cscrm__Site__c siteRecord = New cscrm__Site__c();
       
        id currentUser = UserInfo.getUserId();
        try{
                cscrm__Site__c siteDetails =Database.query('SELECT Id, cscrm__Account__c FROM cscrm__Site__c WHERE LastModifiedById =:currentUser Order By LastModifiedDate DESC LIMIT 1');
                siteRecord = siteDetails;
            return siteRecord;
        }catch(Exception e){
            system.debug('Exception while loading account details :'+e.getMessage());
        }
       
        return siteRecord;
    }
    @auraEnabled // Added Class to get Sites for EDGE-155275 
    public static list<cscrm__Site__c> getAllsites(string accountId)
    {
        system.debug(accountId+'accountId*****');
        list<cscrm__Site__c> siteList = new list<cscrm__Site__c>();
        String query;
        String criteria;   
        try{
            
            siteList = [SELECT Name,Address__c,address_Status__c,source_system__c,LastModifiedById FROM cscrm__Site__c WHERE cscrm__Account__c =:accountId  LIMIT 6];
           return siteList;
            
       }
      catch(Exception e){
            system.debug('Exception while loading account details :'+e.getMessage());
        }
        return siteList;
                 
        
    }
    @auraEnabled 
 public static boolean checkcreatesiteaccess(Id accountId){
        Boolean isPartner = FeatureManagement.checkPermission('Partner_User');
       Boolean cancreateSite=false; 
        if(isPartner){
            User userRecord=[select id,accountid from user where id=:UserInfo.getUserId()];
            Boolean isPOR=getPORs.isPOR(userRecord.accountid,accountId,'Active');          
            cancreateSite=(isPOR) ? true:false;
        }
     return cancreateSite;
    }
}