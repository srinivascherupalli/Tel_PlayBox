public with sharing class TestUtil {
    // Create Account
    public Static Account createAccount(String name) {
        Account a = new Account();
        a.Name = name;
        a.Pref_Comm_Method__c = 'Phone';
        a.Phone = '0400111222';
        a.Migrated_Customer__c = true;  
        //Sprint 19.17 P2OB-4149
        //Opportunity can only be created/updated if it belongs to an 'Active' or 'Acquired' account 
        a.Customer_Status__c = 'ACTIVE';
        return a;
    }
    
    public static List<Account> createBulkAccountWithPortfolio(Integer numAccts,String name,String oldPCode) {
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<numAccts;i++) {            
            Account a = createAccount(name+String.ValueOf(i));
            a.Portfolio_Code__c=oldPCode;
            accts.add(a);
        }
        return accts;
    }
  
   
    
    public Static cscrm__Site__c createSite(Id prmyCtId, Id secCtId, Id acctId){
        cscrm__Site__c st = new cscrm__Site__c();
        st.name ='TestSite';
        st.Primary_Contact__c = prmyCtId;
        st.Secondary_Contact__c = secCtId;
        st.cscrm__Account__c = acctId;
        return st;
    }
    
    public Static Contact createContact(Id acctId,String firstName, String lastName){
        Contact ct = createContact(firstName,lastName);
        ct.AccountId = acctId;
        ct.Contact_Status__c = 'Active';
        ct.Phone = '0439876780';
        ct.MobilePhone = '0434567890';
        ct.Email = getRandomString() + 'll@gmail.com';
        ct.Title = getRandomString();
        System.debug('contact created: ' + ct);
        return ct;
    }
    
    // Create Contact
    public Static Contact createContact(String firstName, String lastName) {
        Contact c = new Contact();
        c.Salutation = 'Mr.';
        c.FirstName = firstName;
        c.LastName = lastName;
        //c.LastName = getRandomString();       
        c.Birthdate=Date.newInstance(2000, 2,18);
        return c;
    }
    
    // Create Address
    public Static cscrm__Address__c createAddress(){
        cscrm__Address__c address = new cscrm__Address__c();
        address.cscrm__External_ID__c = '12345678';
        address.cscrm__Country__c = 'AUSTRALIA';
        address.cscrm__State_Province__c = 'VIC';
        address.cscrm__Zip_Postal_Code__c = '3000';
        address.cscrm__Street_Name__c = 'Lonsdale';
        address.cscrm__Street_Type__c = 'ST';
        address.cscrm__Street_Number_Start__c = '150';
        address.Address_Line_1__c = 'Lonsdale St';   
        
        return address;
    }
    
    // Add Contact to Account
    public Static Boolean addContactToAccount(Id accountId, Id contactId) {
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
        if(!contacts.isEmpty()) {
            Contact contact = contacts.get(0); 
            contact.AccountId = accountId;
            update contact;
            return true;
        } 
        return false;
    }
    
    // Add Address to Account
    public Static Boolean addAddressToAccount(Id accountId, Id addressId) {
        List<cscrm__Address__c> addresses = [SELECT Id, cscrm__Account__c FROM cscrm__Address__c WHERE Id = :addressId];
        if(!addresses.isEmpty()) {
            cscrm__Address__c address = addresses.get(0); 
            address.cscrm__Account__c = accountId;
            update address;
            return true;
        }
        return false;
    }
    
    // Retrieve Account
    public Static Account getAccount(Id accountId){
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        if(!accounts.isEmpty()){
            return accounts[0];
        } else {
            return null;
        }
        
    }
    
    // Retrieve Contact
    public Static Contact getContact(Id contactId){
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :contactId];
        if(!contacts.isEmpty()){
            return contacts[0];
        } else {
            return null;
        }
        
    }
    
    // Retrieve Address
    public Static cscrm__Address__c getAddress(Id addressId){
        List<cscrm__Address__c> addresses = [SELECT Id, Name FROM cscrm__Address__c WHERE Id = :addressId];
        if(!addresses.isEmpty()){
            return addresses[0];
        } else {
            return null;
        }
    }
    
    // Create orchestration process template
    public static CSPOFA__Orchestration_Process_Template__c createOPTemplate(String name) {
        CSPOFA__Orchestration_Process_Template__c opt = new CSPOFA__Orchestration_Process_Template__c();
        opt.Name = name;
        return opt;
    }
    
    // Create parent orchestration process
    public static CSPOFA__Orchestration_Process__c createParentOP(String name, Id templateId) {
        CSPOFA__Orchestration_Process__c op = new CSPOFA__Orchestration_Process__c();
        op.Name = name;
        op.CSPOFA__Orchestration_Process_Template__c = templateId;
        return op;
    }    
    
    // Create child orchestration process
    public static CSPOFA__Orchestration_Process__c createChildOP(String name, Id parentId, Id templateId) {
        CSPOFA__Orchestration_Process__c op = new CSPOFA__Orchestration_Process__c();
        op.Name = name;
        op.Parent_Orchestration_Process__c = parentId;
        op.CSPOFA__Orchestration_Process_Template__c = templateId;
        op.CSPOFA__Process_Type__c = 'Cease';
        op.CSPOFA__State__c = 'Active';
        return op;
    } 
    
    //Create Test Territories in existing Portfolio Hierarchy Model
    public static List<Territory2> createPortfolioTerritories(String modelName, List<String> territoryNames){
        Id modelId = [select Id from Territory2Model where State = 'Active' LIMIT 1].Id;
        Id tTypeId = [select Id from Territory2Type where DeveloperName = 'Portfolio_Hierarchy' LIMIT 1].Id;
        List<Territory2> territories = new List<Territory2>();
        for(String s : territoryNames){
            territories.add(new Territory2(Name = s, Territory2ModelId = modelId, DeveloperName = s.replace(' ', '_'), Territory2TypeId = tTypeId));
        }
        return territories;
    }
    
    //Create Test Opportunity associated with account id provided
    public static Opportunity createOpportunity(Id accId){
        Opportunity opp =new Opportunity();
        opp.Name='testopporunity';
        opp.StageName = 'Develop';
        opp.CloseDate = Date.today();
        opp.accountId = accId;
        return opp;     
    }
    
    //Create new user records
    public static User createUser(String username, String alias, String profile){
        Profile p = [SELECT Id FROM Profile WHERE Name = :profile]; 
        User u = new User(Alias = alias, Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName=username);
        return u;
    }
    
    //Get random string to use as name or email, needed to prevent duplicate errors
    public static String getRandomString(){
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = randomInt.format().replace(',','');
        return uniqueName;
    }
    
    public static User createRoleId(String username, String alias, String profile, String Role){
        UserRole r = [Select id from UserRole where Name =: Role];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :profile]; 
        User u = new User(Alias = alias, Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName=username, userroleid=r.id);
        
        return u;
    }
    
    public static OpportunityContactRole createOCR(Contact c,Opportunity opp){
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        return ocr;
    } 
    /*----------------------------------------------------------------
Method : createBasket
Author: Kalashree Borgaonkar
Description: Create Basket record
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    public static cscfga__Product_Basket__c createBasket(Opportunity opp,Account acc){
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        return basket;
    }

    /*----------------------------------------------------------------
Method : createCustAuthorityForm
Author: Kalashree Borgaonkar
Description: Create Customer_Authority_Form__c record
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    public static Customer_Authority_Form__c createCustAuthorityForm(Opportunity opp,Account acc){
        Customer_Authority_Form__c caf = new Customer_Authority_Form__c(Opportunity__c=opp.id,Is_active__c=true,Account__c=acc.id);
        return caf;
    }
    /*----------------------------------------------------------------
Method : createBulkCAFwithPPV
Author: Aishwarya Yeware
Description: Create Customer_Authority_Form__c record
Story: EDGE-100327
-------------------------------------------------------------------------------------*/
  public static List<Customer_Authority_Form__c> createBulkCAFwithPPV(Integer numCaf,Opportunity opp,Account acc,Contact con) {
        List<Customer_Authority_Form__c> cafs = new List<Customer_Authority_Form__c>();
        for(Integer i=0;i<numCaf;i++) {            
            Customer_Authority_Form__c caf = createCustAuthorityForm(opp,acc);
            caf.Status__c = 'MPPV-ACCEPTED';
            caf.Contact__c=con.id;
            cafs.add(caf);
        }
        return cafs;
    }
    /*----------------------------------------------------------------
Method : createServiceQualification
Author: Kalashree Borgaonkar
Description: Create Service_Qualification__c record
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
     public static Service_Qualification__c createServiceQualification(Account acc,String serviceNum,String status){
        Service_Qualification__c sqRecord = new Service_Qualification__c(Service_Number__c=serviceNum,Portability_Status__c=status,Account__c=acc.id);
        return sqRecord;
    }
     /*----------------------------------------------------------------
Method : createNumber
Author: Kalashree Borgaonkar
Description: Create Service_Qualification__c record
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    // Added for DIGI-559
    public static Carriage_Solutions__c createCarriageSolutions(Id sqId){
        //Start Digi-29002 : Added maximumESABandwidth  value to check the status of service qualification 
        return new Carriage_Solutions__c(Name='Telstra Fibre Access',maximumESABandwidth__c = 34,Service_Qualification__c=sqId);
        //End Digi-29002
    }

    // Added for DIGI-559
    public static Service_Qualification_Provider_Resource__c  createSQProviderResource(Id sqId){
        return new Service_Qualification_Provider_Resource__c (Name='Test provder',Service_Qualification__c=sqId);
    }

    // Added for DIGI-559
    public static Service_Qualification_Resource_Detail__c   createSQResource(Id sqId){
        return new Service_Qualification_Resource_Detail__c(Name='Test Resource',Service_Qualification__c=sqId);
    }

    // Added for DIGI-559
    public static Service_Qualification_Port_Detail__c createPortDetails(Id resourceId){
        return new Service_Qualification_Port_Detail__c(Name='Test Resource',Service_Qualification_Resource_Detail__c=resourceId);
    }



    public static Number__c createNumber(String serviceNum,String basketid,String sqId){ 
        Number__c numberRecord = new Number__c(Service_Number__c=serviceNum,Type__c='New',  Basket__c=basketid,Service_Qualification__c= sqId,Product_Configuration__c=null);
        return numberRecord;
    }
    /*----------------------------------------------------------------
Method : createPriceItem
Author: Aishwarya Yeware
Description: Create createPriceItem Record
Story: EDGE-98400
-------------------------------------------------------------------------------------*/
    public static cspmb__Price_Item__c createPriceItem(){ 
  cspmb__Price_Item__c commerpro=new cspmb__Price_Item__c(Model__c='Apple iphone 64GB',SKU__c='13213425',name='Mobile SKU');        
        return commerpro;
    }
    /*----------------------------------------------------------------
Method : createBillingAccount
Author: Kalashree Borgaonkar
Description: Create Billing_Account__c record
Story: EDGE-88307
-------------------------------------------------------------------------------------*/
    public static Billing_Account__c createBillingAccount(String accNumber){ 
        Billing_Account__c billingAccount = new Billing_Account__c(Billing_Account_Number__c=accNumber);
        return billingAccount;
    }
/*----------------------------------------------------------------
Method : createBillingAccount
Author: Kalashree Borgaonkar
Description: Create Billing_Account__c record
Story: EDGE-88307
-------------------------------------------------------------------------------------*/
     public static Invoice__c createInvoice(String accNumber,String invNumber){ 
        Billing_Account__c billingAccount = createBillingAccount(accNumber);
        insert billingAccount;
        Invoice__c invoice =new Invoice__c(Billing_Account__c=billingAccount.id,Name=invNumber);
        return invoice;
    }

/*----------------------------------------------------------------
Method : createOpportunityTeamMember
Author:Sravanthi Velagapudi
Description: Create createOpportunityTeamMember record
Story: P2OB-3264
-------------------------------------------------------------------------------------*/
     public static OpportunityTeamMember createOpportunityTeamMember(Id UserId,String OpportunityAccessLevel,String TeamMemberRole,Id OpportunityId){ 
       return new OpportunityTeamMember(UserId =UserId,OpportunityAccessLevel = OpportunityAccessLevel,TeamMemberRole=TeamMemberRole,OpportunityId=OpportunityId);
    }
    
    /*----------------------------------------------------------------
Method : createCaseEnterprise
Author:Sravanthi Velagapudi
Description: Create case record
Story: P2OB-4310
-------------------------------------------------------------------------------------*/
     public static Case createCaseEnterprise(Id RecordTypeId,Id AccountId,Id OpportunityId,String Subject){ 
       return new Case(RecordTypeId=RecordTypeId,AccountId=AccountId,Status='New',OpportunityId__c=OpportunityId,Subject=Subject);
    }

/*----------------------------------------------------------------
Method     :   createOpportunityLineItem
Author    :  Sri
Description  :   Create OpportunityLineItem record
Story    :   P2OB-6818
-------------------------------------------------------------------------------------*/
     public static OpportunityLineItem createOpportunityLineItem(Id oppId){ 
       return new OpportunityLineItem(OpportunityID=oppId,Description='test,test,test,test', quantity=4,Domain__c='UNIFIED COMMUNICATIONS', totalprice=200);
    }

/*----------------------------------------------------------------
Method     :   createNPSS
Author    :  Sri
Description  :   Create NPSS record
Story    :   P2OB-6818
Modiefied: Added Product_Type__c as a part of Edge: 178215
-------------------------------------------------------------------------------------*/
     public static NPSS__c createNPSS(String Name){ 
       return new NPSS__c(Name = Name, Multiplier__c = 123123.0, Product_Type__c = 'Standard', SRM_Currency__c = 123123.0,Sale_Type__c = 'Claimed',Start_Date__c = Date.today());
    }
/*----------------------------------------------------------------
Method      :   createCIDNRevenueTarget
Author      :   Sri
Description :   Creates CIDN_Revenue_Targets__c instance
Story       :   P2OB-6264
-------------------------------------------------------------------------------------*/
     public static CIDN_Revenue_Targets__c createCIDNRevenueTarget(Id accountId){ 
       return new CIDN_Revenue_Targets__c(Account_Name__c=accountId, Revenue_Target__c = 999999);
    }

/*----------------------------------------------------------------
Method      :   createPortfolioCode
Author      :   Sri
Description :   Creates Portfolio_Code__c instance
Story       :   P2OB-6270
-------------------------------------------------------------------------------------*/
     public static Portfolio_Code__c createPortfolioCode(String name){ 
       return new Portfolio_Code__c(name=name, Revenue_Target__c = 999999);
    }

/*----------------------------------------------------------------
Method      :   createPortfolioTerritories
Author      :   Sri
Description :   Creates Territory2 instance
Story       :   P2OB-6270
-------------------------------------------------------------------------------------*/
    public static Territory2 createPortfolioTerritories(String modelName, String territoryName){
        Id modelId = [select Id from Territory2Model where State = 'Active' LIMIT 1].Id;
        Id tTypeId = [select Id from Territory2Type where DeveloperName = 'Portfolio_Hierarchy' LIMIT 1].Id;
        return new Territory2(Name = territoryName, Territory2ModelId = modelId, DeveloperName = territoryName.replace(' ', '_'), Territory2TypeId = tTypeId);
    }
    
/*----------------------------------------------------------------
Method      :   createUserTerritory2Association
Author      :   Sri
Description :   Creates UserTerritory2Association instance
Story       :   P2OB-6270
-------------------------------------------------------------------------------------*/
    public static UserTerritory2Association createUserTerritory2Association(Id userId, Id territoryId, String userRole){
        return new UserTerritory2Association(userId = userId, Territory2Id = territoryId, RoleInTerritory2 = userRole);
    }
    
    /*----------------------------------------------------------------
Method : createCongaQuery
Author: Kalashree Borgaonkar
Description: Create Conga query record
Story: EDGE-132716
-------------------------------------------------------------------------------------*/
        public static APXTConga4__Conga_Merge_Query__c createCongaQuery(String name,String querydetails){ 
          APXTConga4__Conga_Merge_Query__c query = new APXTConga4__Conga_Merge_Query__c();
            query.APXTConga4__Name__c = name;
            query.APXTConga4__Query__c = querydetails;
            return query;
        }
    /*----------------------------------------------------------------
Method : createCongaTemplate
Author: Kalashree Borgaonkar
Description: Create Conga Template record
Story: EDGE-132716
-------------------------------------------------------------------------------------*/
    public static APXTConga4__Conga_Template__c createCongaTemplate(String name,String tempType,String type){ 
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
        template.APXTConga4__Name__c = name;
        template.APXTConga4__Template_Type__c = tempType;
        template.Type__c=type;
        return template;
    }
    /*  Uniqueness is enforced during deployments when tests are run, so an insert call will fail if the username is already registered 

        in another org in the same environment (production or sandbox). The resolution for this is to use a guaranteed unique username for tests.

        We recommend generating globally unique usernames,

        e.g. org Id + timestamp + random value, as the below code snippet shows:
    */
    //FDR & Prod Test class failures because of DUPLICATE_USERNAME error during a deployment
    //So SFO Added blow usercreation method for unique username on date 02/09/2020 (Sprint 20.12)

    public static User createTestUser(Id roleId, Id profID, String fName, String lName) {

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'Australia/Sydney',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey='UTF-8',
                              LocaleSidKey='en_AU',
                              ProfileId = profId,
                              UserRoleId = roleId);

        return tuser;

    }
    /*
@Method Name: createAccountTeamMember
@Description: DIGI-12760, Sprint 21.12
            returns an AccountTeamMember record for the accountId with the mentioned userId and role
@Author		: Sri (Team SFO)
*/
public static AccountTeamMember createAccountTeamMember(Id userId, Id accountId, String role) {
    AccountTeamMember actTeamMember = new AccountTeamMember();
    actTeamMember.UserId = userId;
    actTeamMember.AccountId = accountId;
    actTeamMember.teammemberrole = role;
    
    return actTeamMember;
}
    
    /*----------------------------------------------------------------
    Method : createAccountTeamMember
    Author:Sravanthi Velagapudi
    Description: Create Account Team Member record
    Story: P2OB-3264
    -------------------------------------------------------------------------------------*/
     public static AccountTeamMember createAccountTeamMember(Id UserId,String AccountAccessLevel,String TeamMemberRole,Id AccountId){ 
       return new AccountTeamMember(UserId =UserId,AccountAccessLevel = AccountAccessLevel,TeamMemberRole=TeamMemberRole,AccountId=AccountId);
    }
    
    /*----------------------------------------------------------------
    Method : createSingleLead
    Author : Chhaveel Thakur
    Description: Create Single Lead record
    Story: P2OB-34437
    -------------------------------------------------------------------------------------*/
    public static Lead createLead(id accid, String fname, String lname, Id RecordId,string EmailString){ 
        Lead newLead = new Lead(Customer_Name__c = accid,
                                lastname=lname,
                                firstname=fname,
                                RecordTypeId = RecordId,
                                Email =EmailString,
                                Company ='Telstra Limited');
        return newLead;
    } 
    /*----------------------------------------------------------------
    Method : createTask
    Author : Chhaveel Thakur
    Description: Create Single Task record
    Story: P2OB-34437
    -------------------------------------------------------------------------------------*/
    public static Task createTask(id wID, String taskStatus, String taskSubject){ 
        Task newTask = new Task(WhoId =wID,
                                Status = taskStatus,
                                Subject = taskSubject);
        return newTask;
    } 
}