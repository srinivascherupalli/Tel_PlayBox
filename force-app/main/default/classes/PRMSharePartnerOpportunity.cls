/*
Version     Author                         Last Modified Date      Description
v1.0        Vivian Charlie (Team Hawaii)   31 Oct 2019             Initial Draft
*/
public with sharing class PRMSharePartnerOpportunity{
    
    @AuraEnabled(cacheable = true)
    public static Distributor_Model_Setting__c fetchDistributorSettingDetails(){
        Distributor_Model_Setting__c CS = Distributor_Model_Setting__c.getInstance();
        system.debug('*****CS*****'+CS);
        return CS;
    }

    @AuraEnabled(cacheable = true)
    public static Opportunity fetchOpportunityDetails(Id opportunityId){
        system.debug('*****opportunityId DEBUG ONLY*****'+opportunityId);
        Opportunity objO;
        if(opportunityId != null){
            objO = [Select Id
                         , Name
                         , Associated_Distributor__c
                         , Associated_Distributor__r.Name
                         , Distributor_Contact__c
                         , Distributor_Contact__r.Name
                         , SubmittoPartnerStatus__c
                         , Associated_Distributor_Name__c
                         , Partner_Opportunity_Verification__c
                         , DCHOwner__c
                         , DCHOwner__r.ContactId
                         , DCHOwner__r.Contact.AccountId
                         , DCHOwner__r.Contact.Account.Partner_Code__c
                         , OwnerId
                         , Owner.ContactId
                         , Owner.Contact.AccountId
                         , Owner.Contact.Account.Partner_Type__c
                         , Owner.Contact.Account.Partner_Code__c
                         , PartnerAccountId
                         , PartnerAccount.Name
                         , CreatedById
                         , CreatedBy.Contact.Account.Partner_Type__c
                         , IsClosed
                    From Opportunity 
                    Where Id =: opportunityId];
        }
        system.debug('*****objO*****'+objO);
        return objO;
    }

    @AuraEnabled(cacheable = true)
    public static User fetchPartnerDetails(){
        User objUser;
        objUser = [Select Id
                        , Contact.Account.Partner_Type__c
                        , Contact.AccountId
                        , Dealer_Code__c
                    From User 
                    Where Id =:UserInfo.getUserId() 
                    LIMIT 1];
        system.debug('objUser*****'+objUser);
        return objUser;
    } // end of fetchPartnerDetails
    
    @AuraEnabled
    public static string updateOpportunity(String accountJson, String opportunityJson, String partnerType){
        try{
            system.debug('accountJson*****'+accountJson);
            system.debug('opportunityJson*****'+opportunityJson);
            system.debug('partnerType*****'+partnerType);
            Opportunity objO = (Opportunity)JSON.deserialize(opportunityJson, Opportunity.class);
            Account objA = (Account)JSON.deserialize(accountJson, Account.class);
            objO.SubmittoPartnerStatus__c = 'Submitted';
            if(partnerType == 'Partner'){
                objO.Associated_Distributor__c = objA.Id;
                objO.Associated_Distributor_Name__c = objA.Name;
                objO.DCHOwner__c = objO.OwnerId;
                //objO.PartnerAccountId = objA.Id;
                for(User objU : [Select Id, ContactId from User where ContactId =:objA.PartnerPrincipalContact__c LIMIT 1]){
                    objO.Distributor_Contact__c = objU.Id;
                }
            }
            if(partnerType == 'Distributor'){
                //objO.Associated_Distributor__c = objA.Primary_Distributor__c;
                objO.PartnerAccountId = objA.Id;   
            }
            
            system.debug('objO *****'+objO);
            update objO;
            return 'Success';
        }catch (Exception ex){
            system.debug('Stack Trace*****'+ex.getStackTraceString());
            system.debug('Cause*****'+ex.getCause());
            return ex.getMessage();
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<SObject> findRecords(String searchKey, String objectName, String partnerType, Id partnerAccount){
        system.debug('returnPartnerAccounts searchKey*****'+searchKey);
        system.debug('returnPartnerAccounts objectName*****'+objectName);
        system.debug('returnPartnerAccounts partnerType*****'+partnerType);
        system.debug('returnPartnerAccounts partnerAccountId *****'+partnerAccount);
        String stPartner = 'Partner';
        String stNominate = 'Nominate';
        String stDistributor = 'Distributor';
        String strAccountStatus = PRMConstants.PRM_Account_Status_Active;
        String strRecordType = PRMConstants.PRM_RecordType_Partner;
        String key = '%' + searchKey + '%';
        String QUERY = 'Select Id, Name, Partner_Type__c, Primary_Distributor__c, Account_Status__c, PartnerPrincipalContact__c From '+objectName +' Where IsPartner = true and Account_Status__c =:strAccountStatus and RecordType.DeveloperName =:strRecordType and Name LIKE :key';
        if(partnerType == 'Distributor'){
            Query = Query + ' and (Partner_Type__c =: stPartner or (Partner_Type__c =: stNominate and Primary_Distributor__c =\'' +partnerAccount+'\'))';
        }else if(partnerType == 'Partner'){
            Query = Query + ' and Partner_Type__c =: stDistributor';
        }
        System.debug(System.LoggingLevel.DEBUG, QUERY);
        List<SObject> sObjectList = Database.query(QUERY);
        system.debug('sObjectList********8'+sObjectList);
        return sObjectList;
    }
} // end of class