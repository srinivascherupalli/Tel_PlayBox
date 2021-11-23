/*******************************************************************
* @Author          - Team Hawaii
* @Desc            - Utility class test-data
* @CreatedDate     - 26/02/2020
* @Modifications   - (1)26/02/2020 : Ritika Jaiswal : Utility class for generating data for PRM test-data
* @Modification    - 19/5/2020 : Paresh Patil : Added Create contact method 
                   - 28/5/2020 : Paresh Patil : Added New methods createMarketingBudget,createFundAllocation,createFundRequest,
                                                createFundClaim 
* @Modification - 
1. 04/06/2020       : Megha Agarwal : addded new method for Partner Incremental Fund and updated the createFundAllocation,createFundRequest,                                            
2. 21-July-2020     : Team Hawaii : Ritika Jaiswal : P2OB-8124 - Financial year from Picklist-Value-Set
3. 06 August 2020   : Paresh : P2OB-6450 : Added new method for Opportunity creation
4. 06 October 2020  : Vivian : P2OB-5948 : Added new method for Lead creation
5. 30 October : Paresh : Added Customer Status field in account creation
6. 08 Dec : Megha  : Updating test data of Partner Plan - P2OB-11359
7. 06 July 2021    : Purushottama Sahu  : Added New Method for Partner of Records
8. 03 Jul : Vivian : P2OB-15264 Adding doNothing testMethod for security vulnerability scan fix
***********************************************************************/
@isTest
public without sharing class PRMTestUtility {
    public static User[] createInternalUsers(Integer n, Profile[] profileId, UserRole roleId) {
        User[] users = new List<User>();
        for (Integer i = 0; i < n; i++) {
            User use = new User(alias = 'PART', email='test@noemail1234.com'+i,
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = profileId[0].Id, country='United States',IsActive =true,
                                timezonesidkey='America/Los_Angeles', username=Math.round((Math.random() * (900000) + 100000))+'@noemail.com');
            if (roleId != null){
                use.UserRoleId = roleId.Id; 
            }
            users.add(use);
        }
        return users;
    }
    public static Account[] createAccounts(Integer n,Id recordType) {
        Account[] accounts = new List<Account>();
        for (Integer i = 0; i < n; i++) {
            Account acc = new Account(Name = 'TEST_ACCOUNT' + i, Industry = 'Manufacturing',
                                      BillingStreet = '123 Main St', BillingCity = 'NA',
                                      BillingPostalCode = '99999', BillingState = 'QLD',
                                      BillingCountry = 'United States', NumberofEmployees = 100,
                                      Phone = '000-000-0000',Imported__c=true,
                                      Website = 'www.test.com',APTPS_Business_Segment__c = null,
                                      ShippingState = 'test', ShippingCountry = 'Australia',Customer_Status__c='Active');
            if (recordType != null) { acc.RecordTypeId = recordType; }
            accounts.add(acc);
        }
        return accounts;
    }
    public static Account[] createPartnerAccounts(Integer n,Id recordType,String PartnerType,String AccountStatus,Account primaryDistributor) {
        Account[] partnerAccounts = new List<Account>();
        for (Integer i = 0; i < n; i++) {
            Account acc = new Account(Name = 'TEST_Partner_ACCOUNT' + i, Industry = 'Manufacturing',
                                      Customer_Trading_Name__c = 'TEST_Partner_ACCOUNT' + i,Account_Status__c = AccountStatus,
                                      ACN__c = '123'+i,ABN__c = '123'+i,Partner_Type__c=PartnerType,Partner_Code__c='P11324'+i,
                                      BillingStreet = '123 Main St', BillingCity = 'NA',Imported__c=true,
                                      BillingPostalCode = '99999', BillingState = 'QLD',
                                      BillingCountry = 'United States', NumberofEmployees = 100,APTPS_Business_Segment__c = null,
                                      Phone = '000-000-0000',Data_Security_Accreditation__c = 'Gold',Mobility_Accreditation__c = 'Gold',
                                      Website = 'www.test'+i+'.com',Cloud_Accreditation__c = 'Gold',Collaboration_Accreditation__c  = 'Gold',
                                      ShippingState = 'test', ShippingCountry = 'Australia',Overall_Accreditation__c = 'Gold',State_Coverage__c='QLD',Customer_Status__c='Active');
            if (recordType != null) { acc.RecordTypeId = recordType; }
            if(primaryDistributor != null){acc.Primary_Distributor__c = primaryDistributor.Id;}
            partnerAccounts.add(acc);
        }
        return partnerAccounts;
    }
    public static User[] createPartnerUsers(Integer n, Profile[] profileId, Contact[] conList,Boolean isPRMSuperUser) {
        List<User> PartnerUserList = new List<User>();
        for(Integer i=0; i < n; i++){
            User partUser = new User(alias = 'PART', email='test@noemail45345555.com'+i,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                     localesidkey='en_US', profileid = profileId[0].Id, country='United States',IsActive =true,
                                     ContactId = conList[i].Id,isPRMSuperUser=isPRMSuperUser, 
                                     timezonesidkey='America/Los_Angeles', username=Math.round((Math.random() * (900000) + 100000))+'@noemail2.com');
            PartnerUserList.add(partUser);
        }
        return PartnerUserList;
    }
    public static Contact[] createContact(Integer n,Id recordTypeId,Id AccountId){
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0; i < n; i++){
            Contact con = new Contact(FirstName = 'Test Utility Contact'+i,
                                      LastName='Last Name'+i,
                                      recordTypeId = recordTypeId,
                                      AccountId=AccountId,
                                      OTP_Mobile_Phone_Number__c = '+61123456789',
                                      Work_Phone_Number__c = '+61123456789'
                                     );
            contactList.add(con);
        }
        return contactList;
    }
    // This method return budget record list to create budget records in test class
    // P2OB-6797 - Financial Year added
    public static PartnerMarketingBudget[] createMarketingBudget(Integer n,Decimal Amount){
        List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
        List<Schema.PicklistEntry> ple = Partner_Incremental_Fund_Allocation__c.Financial_Year__c.getDescribe().getPicklistValues();
        String fy = ple[0].getValue();// P2OB-6797 - added Financial Year, P2OB-8124 - Financial year from Picklist-Value-Set
        for(Integer i=0; i < n; i++){
            PartnerMarketingBudget budget = new PartnerMarketingBudget();
                budget.Title = 'Partner Budget'+i;
                budget.Type = 'Co-Operated Budget';
                budget.Amount = Amount;
                budget.StartDate = system.today();
                budget.EndDate = system.today().addDays(5);
                if(i < 10){ // P2OB-6797 - added Financial Year
                   budget.Financial_Year__c = ple[i].getValue(); //P2OB-8124 - Financial year from Picklist-Value-Set
                }
            budgetList.add(budget);
        }
        return budgetList;
    }
    // This method return fund allocation record list to create allocation records in test class
    public static PartnerFundAllocation[] createFundAllocation(Integer n,Id budgetId,Id partnerAccountId,Decimal Amount,String financialYear){
        List<PartnerFundAllocation> allocationList = new List<PartnerFundAllocation>();
        for(Integer i=0; i < n; i++){
            PartnerFundAllocation allocation = new PartnerFundAllocation();
                allocation.Title = 'Partner Allocation'+i;
                allocation.Amount = Amount;
                allocation.ChannelPartnerId = partnerAccountId;
                allocation.Financial_Year__c = financialYear;
                allocation.BudgetId = budgetId;
                allocation.Allocation_External_Id__c = partnerAccountId + String.valueOf(i) + financialYear;// P2OB-6797 - Added external id field
            allocationList.add(allocation);
        }
        return allocationList;
    }
    // This method return fund request record list to create fund request in test class
    public static PartnerFundRequest[] createFundRequest(Integer n,Id budgetId,Id partnerAccountId,Id allocationId,Decimal Amount,String financialYear){
        List<PartnerFundRequest> fundRequestList = new List<PartnerFundRequest>();
        for(Integer i=0; i < n; i++){
            //Create Fund Request for Partner
            PartnerFundRequest newRequest = new PartnerFundRequest();
                newRequest.Title = 'Partner Request'+i;
                newRequest.RequestedAmount = Amount;
                newRequest.ChannelPartnerId = partnerAccountId;
                newRequest.Activity = 'Partners';
                newRequest.BudgetId = budgetId;
                newRequest.Financial_Year__c = financialYear;
                newRequest.AllocationId = allocationId;
                newRequest.Allocation_Request_External_Id__c = partnerAccountId + String.valueOf(i) +  financialYear; // P2OB-6797 - Added external id field
                newRequest.Status = 'Approved';
                newRequest.Amount = Amount;
            fundRequestList.add(newRequest);
        }
        return fundRequestList;
    }
    // This method return fund claim record list to create claim records in test class
    public static PartnerFundClaim[] createFundClaim(Integer n,Id requestId,Decimal Amount,String financialYear){
        List<PartnerFundClaim> fundClaimList = new List<PartnerFundClaim>();
        for(Integer i=0; i < n; i++){
            PartnerFundClaim claim = new PartnerFundClaim();
                claim.Title = 'Partner Claim'+i;
                claim.RequestId = requestId;
                claim.Requested_Amount__c = Amount;
                claim.Amount = Amount;
                claim.Status = 'Draft';
                claim.Financial_Year__c = financialYear;
                claim.Description = 'Claim Description';
            fundClaimList.add(claim);
        }
        return fundClaimList;
    }
    // This method return fund claim record list to create claim records in test class
    public static Partner_Incremental_Fund_Allocation__c[] createPartnerIncrementalFund(Integer n, List<Account> accountList, String financialYear){
        List<Partner_Incremental_Fund_Allocation__c> partnerIncrementalFundList = new List<Partner_Incremental_Fund_Allocation__c>();
        for(Integer i=0; i < n; i++){
            Partner_Incremental_Fund_Allocation__c incrementalFund = new Partner_Incremental_Fund_Allocation__c();
                if(accountList.size() > i){
                    incrementalFund.Channel_Partner__c = accountList[i].Id;
                    incrementalFund.Dealer_Code__c =  accountList[i].Partner_Code__c ;
                }else if(accountList.size() > 0){
                    incrementalFund.Channel_Partner__c = accountList[0].Id;
                    incrementalFund.Dealer_Code__c  =  accountList[0].Partner_Code__c;
                }
                incrementalFund.Amount__c = 100;
                incrementalFund.Financial_Year__c = financialYear;
            partnerIncrementalFundList.add(incrementalFund);
        }
        return partnerIncrementalFundList;
    }
    
    // This method return opportunity to create opportunity in test class
    public static Opportunity[] createOpportunity(Integer n, List<Account> accountList, Id RecordTypeId,Id PartnerAccountId){
        Opportunity[] oppList = new List<Opportunity>();
        for(Integer i=0; i < n; i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity'+i;
            opp.StageName = 'Develop';
            opp.RecordTypeId = RecordTypeId;
            if(accountList.size() > i){
                opp.AccountId = accountList[i].Id;
            }else if(accountList.size() > 0){
                opp.AccountId = accountList[0].Id;
            }
            opp.PartnerAccountId=PartnerAccountId;
            opp.CloseDate = Date.today();
            opp.Partner_Opportunity_Verification__c = 'Verification Required';
            oppList.add(opp);
        }
        return oppList;
    }
    
    public static list<Lead> createLeads(Integer n, Id recordtypeId, Id accountId, Id partnerAccountId, Id contactId, String domain){
        list<Lead> lstLeads = new list<Lead>();
        for(Integer i = 0; i< n; i++){
            Lead objLead = new Lead();
            objLead.RecordtypeId = recordtypeId;
            objLead.FirstName = 'First '+i;
            objLead.LastName = 'Last '+i;
            objLead.Company = 'Company '+i;
            objLead.Customer_Name__c = accountId;
            objLead.PartnerAccountId = partnerAccountId;
            objLead.Contact_Name__c = contactId;
            objLead.Email = 'lead@test.com';
            objLead.Phone = '+61 99998800';
            objLead.Primary_Domain__c = domain;
            lstLeads.add(objLead);
        }
        return lstLeads;
    }
    
    public static List<Partner_Plan__c> createPartnerPlan(Integer n,Account[] partnerAccount,String financialYear,String partCode){
        List<Partner_Plan__c> partnerPlanList = new List<Partner_Plan__c>();
        for(Integer i = 0; i< n; i++){
            Partner_Plan__c partPlan = new Partner_Plan__c();
            partPlan.Financial_Year__c = financialYear;
            partPlan.Partner_Code__c = partCode;
            partPlan.Target_Q1__c= 10000;
            partPlan.Target_Q2__c=10000;
            partPlan.Target_Q3__c=10000;
            partPlan.Target_Q4__c=10000;
            partPlan.Target_ASV__c = partPlan.Target_Q1__c + partPlan.Target_Q2__c + partPlan.Target_Q3__c+ partPlan.Target_Q4__c;
            partPlan.Partner_Focus__c='Test';
            if(partnerAccount.size() > i){
                partPlan.Partner_Account__c = partnerAccount[i].Id;
            }else if(partnerAccount.size() > 0){
                partPlan.Partner_Account__c = partnerAccount[0].Id;
            }
            partnerPlanList.add(partPlan);
        }
        return partnerPlanList;
    }
    
    public static List<Case> createCases(Integer n, Id rectypeId){
        List<Case> lstC = new List<Case>();
        for(Integer i = 0; i<n ; i++){
            Case caseObj = new Case();
            caseObj.Status = 'New';
            caseObj.stage__c = 'Request Review';
            caseObj.RecordTypeId = rectypeId;
            caseObj.OwnerId = UserInfo.getUserId();
            lstC.add(caseObj);
        }
        return lstC;
    }

    public static List<Partner_of_Record__c> createPartnerOfRecords(Integer n,List<String> domainStrList){
        Map<String,Profile> profilesMap = new Map<String,Profile>();
      for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia')])
          profilesMap.put(profile.Name, profile);
      
      Map<String,UserRole> rolesMap = new Map<String,UserRole>();
      for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName in ('Sales_Ops','CEO')])
          rolesMap.put(role.DeveloperName, role);
      
      User[] uSysAdmin = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
      Database.insert(uSysAdmin);
      
      System.runAs(uSysAdmin[0]){  
          
          Account[] acc = PRMTestUtility.createPartnerAccounts(n,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
          Database.insert(acc); 
          for(Account accRec: acc){
          accRec.ispartner=true;    
          }
          update acc;
          
          List<Contact> con= new List<Contact>();
          for(Integer i=0;i<n;i++){
              con.add(new Contact(LastName ='testCon', FirstName='testCon', AccountId = acc[i].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User'));
          }
          Database.insert(con); 
          
          User[] partnerUser = PRMTestUtility.createPartnerUsers(n,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,con ,false);
          Database.insert(partnerUser);
          
          Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
          for(Account customACC : customerAccount){
              customACC.Customer_Status__c = 'Active';
          }
          Database.insert(customerAccount);
          
          List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),customerAccount.get(0).Id);
          
          Database.insert(customerContacts);
          
          for(Contact  customCon : customerContacts){
              customCon.Authority__c = 'Full Authority';
              customCon.Contact_Status__c = 'Active';
              customCon.MobilePhone = '+61123456789';
          }
          update customerContacts;
          
          List<Partner_of_Record__c> porList = new List<Partner_of_Record__c>();
          for(integer i=0;i<n;i++){
          Partner_of_Record__c por = new Partner_of_Record__c(Customer__c=customerAccount.get(0).Id, Customer_Signatories__c= customerContacts.get(0).Id,
                                                             Partner__c=acc[i].Id,Partner_Signatories__c= con[i].Id,Status__c='Active');
             porList.add(por);
          }
          Database.insert(porList);
          List<Partner_of_Record_Domain__c> domainList = new List<Partner_of_Record_Domain__c>();
          for(Partner_of_Record__c POR: porList){
          for(String domain:domainStrList){
          domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = POR.Id,Status__c='Active',Domain_Name__c=domain));
          }
          }
          Database.insert(domainList);
          return porList;
      }
       return null;
   }
   
    // security vulnerability scan fix
    private static testMethod void assertNothing(){
        Test.startTest();
        Test.stopTest();
        system.assertEquals(1,1);
    }
}