@isTest

public class BillingAccountCreateTest {
    @testSetup static void testData() {
        createTestUser();
        account acc=new account(name='TestAccount',CIDN__c='12345',ABN__c='1234');
        insert acc;
        ID id=acc.Id;
        contact con=new contact(lastname='TestContact',accountId=id,Sales_Contact_Status__c ='Eligible',Raise_Billing_Disputes__c = true);
        contact con1=new contact(lastname='TestContact1',accountId=id,Sales_Contact_Status__c ='Eligible',Raise_Billing_Disputes__c = true);
        insert con;
        insert con1;
        AccountContactRelation acr=NEW AccountContactRelation(Account=acc, Contact=con);
        AccountContactRelation acr1=NEW AccountContactRelation(Account=acc, Contact=con1);
        Billing_Account__c billAcc=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=con1.Id);
        insert billAcc;
        cscrm__Address__c add=new cscrm__Address__c(Name='TestAddress',cscrm__Country__c='India');
        insert add;
        cscrm__Account_Address_Relationship__c accAddRel = new cscrm__Account_Address_Relationship__c(cscrm__Account__c=id,cscrm__Address__c=add.id);
        insert accAddRel;
        Id recordTypeId = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Billing Account Role').getRecordTypeId();
        Billing_Account__c billAccount = new Billing_Account__c(Status__c = 'Created', Include_related_Customer_Account_Contact__c=false, 
                                                                Account__c=acc.Id, Billing_Account_Number__c='992216148101', 
                                                                Billing_Account_Owner__c=con.Id, Billing_Address__c=add.Id,Balance_Amount__c=100.00);
        insert billAccount;
        Functional_Contact_Role__c fcrole = new Functional_Contact_Role__c(Billing_Account_Number__c = billAccount.Id,ContactID__c = billAccount.Billing_Account_Owner__c, Is_Primary__c = true);
        insert fcrole;
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Enterprise Mobility Plan';
        productDefinition.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_001196';
        insert productDefinition;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.name='Enterprise Mobility Managed Service';
        productConfig.Type__c='New';
        productConfig.ConfigurationType1__c = 'SolutionComponent';
        productConfig.Quantity_Product_Configuration__c = 111;
        productConfig.cscfga__Product_Definition__c=productDefinition.id;
        insert productConfig;
        
        cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.cscfga__Product_Configuration__c = productConfig.id;
        attr.Name = 'PaymentTypeString';
        attr.cscfga__Value__c = 'Hardware Repayment';
        insert attr;
        
        csord__Order__c Order=TestDataFactory.generateOrder(acc.id,'Order Submitted','Order Submitted','Order','Order_456',system.today(),'Mobile Device Replacement','Test Order','Device_replace',UserInfo.getUserId());
        insert Order;
        
        csord__Subscription__c subscription=new csord__Subscription__c(Name = 'Test Subscription', csord__Identification__c = 'TestValue' , csord__Status__c='Pending'                                                                                          
        );
        insert subscription;
        subscription.csord__Status__c='Active';
        subscription.csord__Order__c=Order.id;
        subscription.csord__Identification__c= Order.csord__Identification__c;
        subscription.csord__Account__c=acc.id;
        subscription.Billing_Account__c=billAccount.id;
        subscription.csordtelcoa__Product_Configuration__c = productConfig.id;
        Update subscription;
        
        csord__Subscription_Line_Item__c line = new csord__Subscription_Line_Item__c();
        line.Name = 'Test Name';
        line.csord__Total_Price__c = 10.00;
        line.csord__Is_Active__c = true;
        line.csord__Is_Recurring__c = true;
        line.csord__Subscription__c = subscription.Id;
        line.csord__Identification__c = 'Test';
        insert line;
        
        cspmb__Price_Item__c maincharge = new cspmb__Price_Item__c();
        maincharge.Name = 'Enterprise Mobility';
        maincharge.cspmb__Price_Item_Code__c = 'Enterprise Mobility';
        maincharge.cspmb__Product_Definition_Name__c = 'Enterprise Mobility';
        maincharge.cspmb__Is_Active__c = true;
        maincharge.Type__c = 'Mobile Broadband'; 
        insert maincharge;
        
        List<csord__Service__c
            > serviceList=new List<csord__Service__c>();
        csord__Service__c service=new csord__Service__c();
        service.csordtelcoa__Product_Configuration__c = productConfig.id;
        service.mainCharge__c = maincharge.id; 
        service.name ='Handheld';
        service.csord__Identification__c = productConfig.id;
        service.csord__Subscription__c=subscription.id;
        service.Billing_Account__c=billAccount.id;
        insert service;
        List<Notification_Preference__c> notificationPreferenceList =new List<Notification_Preference__c>();
        Notification_Preference__c nfIRWelcome = new Notification_Preference__c();
        Notification_Preference__c nfIRUsage = new Notification_Preference__c();
        //Notification Record Preference Record creation for IRWelcome
        nfIRWelcome.Account_Id__c = acc.id;
        nfIRWelcome.Category__c	= 'Service';	
        nfIRWelcome.Contact_Id__c = billAccount.Billing_Account_Owner__c;
        nfIRWelcome.IsActive__c	= True;
        nfIRWelcome.Notification_Type__c = 'IR Welcome';
        nfIRWelcome.Service_Id__c = service.id;
        nfIRWelcome.Service_Number__c = service.csordtelcoa__Service_Number__c;   
        nfIRWelcome.Communication_Method__c ='Email';	
        
        //  Notification Record Preference Record creation for IRUsage
        nfIRUsage = nfIRWelcome.clone();                 
        nfIRUsage.Notification_Type__c = 'Usage'; 
        notificationPreferenceList.add(nfIRWelcome);
        notificationPreferenceList.add(nfIRUsage);
        Insert notificationPreferenceList;
    }
    
     @future
    public static void createTestUser(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'My Role1');
    insert r;
    profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
    User uSysAdmin1 = new User(alias = 'Con1234', email = 'Testadmin000971@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing1', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin000971@noemail.com', userroleid = r.id);
    insert uSysAdmin1;
    User  partneruser;
    System.runAs(uSysAdmin1){
        id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
        Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
        insert ac;  
        Contact con12 = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
        insert con12; 
        partneruser = new User(alias = 'test1234', email='b2btestewwr@noemail.com',
                                   emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                                   localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                                   timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua1@noemail.com',contactid=con12.id);
        insert partneruser;        

            Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : customerAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert customerAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),customerAccount.get(0).Id);
            for(Contact  customCon : customerContacts){
                customCon.Authority__c = 'Full Authority';
                customCon.Contact_Status__c = 'Active';
                customCon.MobilePhone = '+61123456789';
            }
            insert customerContacts;
        	Billing_Account__c billingAccount  = new Billing_Account__c(Billing_Account_Number__c='123456789014', Account__c=customerAccount.get(0).Id);
            insert billingAccount;	
            
            Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=customerAccount.get(0).Id,
                                                                Partner__c=ac.Id,Status__c='Active'); 
            insert POR;
            //Opportunity opp   = ProductTestFactory.getOpportunityBasic(customerAccount.get(0));  //DIGI-2055    
            //insert opp;         
        }

       
    
    
    	
    }
    @isTest
    public static void test_fetchAccount(){
        test.startTest();
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        System.debug('account ID------------->'+acc.id);
        System.debug('contact ID------------->'+con.id);
        List <AccountContactRelation> lstOfContact = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con.Id];
        System.debug('lstOfContact------------->' + lstOfContact);
        list<AccountContactRelation> acrList=BillingAccountCreate.fetchAccount('T',acc.Id,lstOfContact,true);
        ////Testing Else Part new End NG
        system.assertNotEquals(null,acrList);
        list<AccountContactRelation> acrList1=BillingAccountCreate.fetchAccount('T',acc.Id,lstOfContact,false);
        Account allAccountsInHierarachy = [Select Id, ParentId From Account where Name = :acc.Name limit 1];
        //allAccountsInHierarachy.parentid = '2424243';
        system.assertNotEquals(null,acrList);
        test.stopTest();
    }
    @isTest
    public static void test_fetchAccountDefault(){
        test.startTest();
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        String Str=BillingAccountCreate.fetchAccountDefault(acc.Id);
        system.debug('ACC VALUE IS'+acc.Name);
        system.assertNotEquals(null,Str);
        test.stopTest();
    }
    @isTest
    public static void test_fetchBillingAccount(){
        test.startTest();
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        List < AccountContactRelation  > lstOfContact = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con.Id];
        list<AccountContactRelation> acrList=BillingAccountCreate.fetchBillingAccount(acc.Id,lstOfContact,true);
        //Test Else Part NG
        list<AccountContactRelation> acrList1=BillingAccountCreate.fetchBillingAccount(acc.Id,lstOfContact,false);
        test.stopTest();
        system.assertNotEquals(null,acrList);
    }
    @isTest
    public static void test_saveRecs(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact'];
        contact con1 = [Select Id,Name from contact where lastname='TestContact1'];
        List < AccountContactRelation  > lstOfContact = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con1.Id];
        for(AccountContactRelation acr: lstOfContact){
            acr.roles = 'Full Authority';
        }
        update lstOfContact;
        AccountContactRelation acr=[SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con.id];
        acr.roles = 'Full Authority'; 
        update acr;
        cscrm__Address__c add=[select id,name,cscrm__Country__c from cscrm__Address__c where cscrm__Country__c='India'];
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        test.startTest();
        String sTest = BillingAccountCreate.fetchban(billAcc.Id);
        system.debug('acc.id ------------------------->'+acc.id);
        system.debug('con.id ------------------------->'+con.id);
        //String str= BillingAccountCreate.fetchAccountContactRelObj(acc.id,con.id);
        //Id id=BillingAccountCreate.saveRecs( billAcc.Billing_Account_Number__c,'14','10',String.valueOf(acc.id),acr,add,lstOfContact,true,true);		//Commented For EDGE-198145
        Id id=BillingAccountCreate.saveRecs( billAcc.Billing_Account_Number__c,'14','10',String.valueOf(acc.id),acr,add,lstOfContact,true,true,true); 	//Added For EDGE-198145
        Id ids=BillingAccountCreate.saveEditedRecords(billAcc.Billing_Account_Number__c,String.valueOf(acr.ContactId),
                                                      String.ValueOf(add.id),lstOfContact,true, 'Final',true,'10');
        test.stopTest();
        system.assertNotEquals(null,id);
    }
    @isTest
    public static void test_fetchBillingAccountNumber(){
        try{
            test.startTest();
            string billNum=BillingAccountCreate.fetchBillingAccountNumber();
            test.stopTest();
            system.assertEquals(null,billNum);
        }
        catch(Exception e)
        {
            system.debug(' '+e.getMessage());
        }
    }
    @isTest
    public static void test_fetchBillingAddress(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        test.startTest();
        List < cscrm__Address__c >  billadd=BillingAccountCreate.fetchBillingAddress(acc.id,true);
        test.stopTest();
        system.assertNotEquals(null,billadd[0].Name);
    }
    @isTest
    public static void test_fetchAdd(){
        test.startTest();
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        List < cscrm__Address__c >  billadd=BillingAccountCreate.fetchAdd('T',acc.id,true);
        test.stopTest();
        system.assertNotEquals(null,billadd);
    }
    @isTest
    public static void testFetchAccountSecondaryContact(){
        test.startTest();
        contact con = [Select Id,Name from contact where lastname='TestContact'];
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con1 = [Select Id,Name from contact where lastname='TestContact1'];
        Boolean isAllCon = true;
        List < AccountContactRelation  > lstOfContact = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con1.Id];
        list<AccountContactRelation> acrList=BillingAccountCreate.fetchAccountSecondaryContact('T',acc.Id,con.id,lstOfContact,isAllCon);
        //Tetsing else Part NG
        list<AccountContactRelation> acrList1=BillingAccountCreate.fetchAccountSecondaryContact('',acc.Id,con.id,lstOfContact,isAllCon);
        //Testing Else Part with aalcon as false NG
        list<AccountContactRelation> acrList2=BillingAccountCreate.fetchAccountSecondaryContact('T',acc.Id,con.id,lstOfContact,false);
        test.stopTest();
        system.assertNotEquals(null,acrList);
    }
    @isTest
    public static void testFetchSecondaryContact(){
        test.startTest();
        contact con = [Select Id,Name from contact where lastname='TestContact'];
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con1 = [Select Id,Name from contact where lastname='TestContact1'];
        Boolean isAllCon = true;
        List < AccountContactRelation  > lstOfContact = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con1.Id];
        list<AccountContactRelation> acrList=BillingAccountCreate.fetchSecondaryContact(acc.Id,con.id,lstOfContact,isAllCon);
        //Testign Else Part AS well - NG
        list<AccountContactRelation> acrList1=BillingAccountCreate.fetchSecondaryContact(acc.Id,con.id,lstOfContact,false);
        test.stopTest();
        system.assertNotEquals(null,acrList);
    }
    @isTest
    public static void testFetchBillingAccountNumberFromBDS(){
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        test.startTest();
        String str= BillingAccountCreate.fetchBillingAccountNumberFromBDS(billAcc.Billing_Account_Number__c);
        test.stopTest();
        System.assertNotEquals(null, str);
    }
    @isTest static void testGetInstance()
    {
        BillingAccountCreate.getInstance();
        system.assertNotEquals(null,BillingAccountCreate.getInstance());
    }
    @isTest static void testGetCreatedBy(){
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        test.startTest();
        User user = BillingAccountCreate.getCreatedBy(billAcc.id);
        test.stopTest();
        System.assertNotEquals(null, user);
    }
    @isTest static void testGetModifiedBy(){
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        test.startTest();
        User user = BillingAccountCreate.getModifiedBy(billAcc.id);
        test.stopTest();
        System.assertNotEquals(null, user);
    }
    @isTest static void testGetLabels(){
        test.startTest();
        Map<String, String> fieldsLabel = BillingAccountCreate.getLabels();
        test.stopTest();
        System.assertNotEquals(null, fieldsLabel);
    }
    @isTest
    static void fetchBillingAccountViewTest(){
        Account parentAcc = new Account(Name='ParentAccount');
        insert parentAcc;
        Account acct = new Account(Name='ChildAccount',ParentId = parentAcc.Id);
        insert acct;	
        Test.startTest();
        BillingAccountCreate.fetchBillingAccountView(acct.Id,'bill',false);
        //Test Else Part
        BillingAccountCreate.fetchBillingAccountView(acct.Id,'bill',true);
        Test.stopTest();
        System.assertNotEquals(null, acct.ID);
    }
    @isTest
    static void fetchOtherContactListForViewTest(){
        Account acct = [Select Id,Name from Account where Name = 'TestAccount'];
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        Test.startTest();
        BillingAccountCreate.fetchOtherContactListForView(acct.ID, billAcc.Billing_Account_Number__c);
        Test.stopTest();
        System.assertEquals('123456789012', billAcc.Billing_Account_Number__c);
    }
    @isTest
    static void saveEditedRecordsFromViewTest() {
        Billing_Account__c billAcc=[select id, Status__c, Include_related_Customer_Account_Contact__c, Account__c, Billing_Account_Number__c,Billing_Account_Owner__c,Billing_Address__c from Billing_Account__c where Billing_Account_Number__c='992216148101'];
        Billing_Account__c ba=[select id, Status__c, Account__c, Billing_Account_Number__c,Billing_Account_Owner__c,Billing_Address__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        List<AccountContactRelation> contactList = [Select Id from AccountContactRelation];
        Test.startTest();
        BillingAccountCreate.saveEditedRecordsFromView(billAcc.Billing_Account_Number__c,ba.Billing_Account_Owner__c,billAcc.Billing_Address__c,contactList,true);
        BillingAccountCreate.featureToggle();
        BillingAccountCreate.checkBillingAccountStatus(billAcc.Id);
        BillingAccountCreate.BillingAccountStatus(billAcc.Id);
        Test.stopTest();
        System.assertEquals('992216148101', billAcc.Billing_Account_Number__c);
    }
    /******************************************************************
EDGE        -147506
Method      -handleDisplay 
Description -handle displaying of fields on create and edit screen
Author      -Kalashree Borgaonkar
******************************************************************/
    @isTest
    static void handleDisplayTest(){
        /*Profile p = [SELECT id 
FROM 
Profile 
WHERE 
name='Billing Consultant']; 
User billingConsultant = new user(alias = 'test123', email='test123@noemail.com', 
emailencodingkey='UTF-8', firstName='test123', lastname='Testing', languagelocalekey='en_US',
localesidkey='en_IN', profileid = p.Id, country='India',
timezonesidkey='Asia/Kolkata', username='test_g@noemail.com'); 
insert billingConsultant;*/
        User billingConsultant =TestDataFactory.createTestUser('Billing Consultant');
        List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('Insolvency_for_Billing_Consultant','Collection_agent_permission')];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for(PermissionSet ps: psList){
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = billingConsultant.id, PermissionSetId = ps.Id);
            psaList.add(psa);
        }   
        if(!psaList.isEmpty()){
            insert psaList; 
        }
        BillingAccountCreate.HandleDisplay handleDisplay;
        System.runAs(billingConsultant){
            Test.startTest();
            handleDisplay = BillingAccountCreate.handleDisplay(true);
            Test.stopTest();
        } 
        System.assertEquals(handleDisplay.showPreDebt=true,true,'Involvency agent');
    }
    /******************************************************************
EDGE        -147506
Method      -getWriteoffApprovalDisplayTest 
Description -handle displaying of submit approval button
Author      -Kalashree Borgaonkar
******************************************************************/
    @isTest
    static void getWriteoffApprovalDisplayTest(){
        Billing_Account__c billAcc=[SELECT id,Balance_Amount__c,Write_off_in_U2C__c,Written_Off__c,Status__c 
                                    FROM Billing_Account__c 
                                    WHERE Billing_Account_Number__c='992216148101'];
        /*Profile p = [SELECT id 
FROM 
Profile 
WHERE 
name='Billing Consultant']; 
User billingConsultant = new user(alias = 'test123', email='test123@noemail.com', 
emailencodingkey='UTF-8', firstName='test123', lastname='Testing', languagelocalekey='en_US',
localesidkey='en_IN', profileid = p.Id, country='India',
timezonesidkey='Asia/Kolkata', username='test_g@noemail.com'); 
insert billingConsultant;*/
        User billingConsultant =TestDataFactory.createTestUser('Billing Consultant');
        List<Group> Level3Group = [SELECT id FROM Group where DeveloperName  = 'Credit_Management_Level3'];
        GroupMember member = new GroupMember(GroupId=Level3Group[0].id,UserOrGroupId=billingConsultant.id);
        insert member;
        List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('Insolvency_for_Billing_Consultant','Collection_agent_permission')];
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for(PermissionSet ps: psList){
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = billingConsultant.id, PermissionSetId = ps.Id);
            psaList.add(psa);
        }   
        if(!psaList.isEmpty()){
            insert psaList; 
        }
        BillingAccountCreate.HandleDisplay handleDisplay;
        System.runAs(billingConsultant){
            billAcc.status__c = 'Final';
            billAcc.Write_off_in_U2C__c = false;
            billAcc.Written_Off__c = false;
            billAcc.Balance_Amount__c = 15000.00;
            update billAcc;
            Test.startTest();
            handleDisplay = BillingAccountCreate.getWriteoffApprovalDisplay(billAcc.id);
            Test.stopTest();
        } 
        System.assertEquals(handleDisplay!=null,true,'Involvency agent');
    }
    /******************************************************************
EDGE        -151581
Method      -getApprovalButtonWithoutGroupTest 
Description -handle displaying of submit approval button
Author      -Kalashree Borgaonkar
******************************************************************/
    /******************************************************************
EDGE        -151581
Method      -initiateApprovalProcessTest 
Description -initiate Approval Process
Author      -Kalashree Borgaonkar
******************************************************************/
    @isTest
    static void initiateApprovalProcessTest(){
        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'TestAccount'];
        contact con = [SELECT Id,Name FROM contact WHERE lastname='TestContact1'];
        Billing_Account__c billAcc=[SELECT id,Write_off_in_U2C__c,Written_Off__c,Status__c,Balance_Amount__c
                                    FROM Billing_Account__c 
                                    WHERE Billing_Account_Number__c='992216148101'];
        billAcc.status__c = 'Final';
        billAcc.Write_off_in_U2C__c = false;
        billAcc.Written_Off__c = false;
        billAcc.Balance_Amount__c = 15000.00;
        update billAcc;
        Test.startTest();
        Boolean approvalInitiated = BillingAccountCreate.initiateApprovalProcess(billAcc.id);
        Test.stopTest();
        System.assertEquals(approvalInitiated!=null,true,'User is not involvency agent');
    }
    /******************************************************************
EDGE        -151581
Method      -initiateApprovalProcessExceptionTest 
Description -initiate Approval process
Author      -Kalashree Borgaonkar
******************************************************************/
    @isTest
    static void initiateApprovalProcessExceptionTest(){
        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'TestAccount'];
        contact con = [SELECT Id,Name FROM contact WHERE lastname='TestContact1'];
        Billing_Account__c billAcc=[SELECT id,Write_off_in_U2C__c,Written_Off__c,Status__c,Balance_Amount__c
                                    FROM Billing_Account__c 
                                    WHERE Billing_Account_Number__c='992216148101'];
        Test.startTest();
        Boolean approvalInitiated = BillingAccountCreate.initiateApprovalProcess(billAcc.id);
        Test.stopTest();
        System.assertEquals(!approvalInitiated,true,'User is not involvency agent');
    }
    /******************************************************************
EDGE        -147506
Method      -handleDisplay 
Description -handle displaying of fields on create and edit screen
Author      -Kalashree Borgaonkar
******************************************************************/
    @isTest
    static void handleDisplayNoInsolvencyTest(){
        Test.startTest();
        BillingAccountCreate.HandleDisplay handleDisplay = BillingAccountCreate.handleDisplay(false);
        Test.stopTest();
        System.assertEquals(handleDisplay!=null,true,'User is not involvency agent');
    }
    @isTest
    static void findPicklistOptionsTest(){
        Test.startTest();
        List<ConstantMetadataUtility.picklistWrapper> data = BillingAccountCreate.findPicklistOptions('Billing_Account__c', 'Status__c');
        Test.stopTest();
        System.assertEquals(data.size()!=null,true);
    }
    @isTest
    public static void fetchAccountContactRelObjTest(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        System.debug('account ID------------->'+acc.id);
        System.debug('contact ID------------->'+con.id);
        String data;
        Test.startTest();
        data = BillingAccountCreate.fetchAccountContactRelObj(acc.Id, con.Id);
        Test.stopTest();
        System.assertEquals(acc!=null,true);
    }
    @isTest
    public static void isCheckForFinalTest(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        System.debug('account ID------------->'+acc.id);
        System.debug('contact ID------------->'+con.id);
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = acc.Id;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.RetiedAccOpp__c = true;
        insert testOpp;
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = acc.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        insert basket;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        //Marketable_Offer__c
        Marketable_Offer__c marktoffer=new Marketable_Offer__c();
        marktoffer.Name='testoffer';
        marktoffer.Offer_ID__c='DMCAT1234';         
        insert marktoffer;
        cscfga__Configuration_Offer__c offer=new cscfga__Configuration_Offer__c();
        offer.name='Mobile';
        offer.Offer_Spec_Id__c='DMCAT1234';
        insert offer;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
            cscfga__Product_Definition__c = pd.Id,   
            cscfga__Product_Basket__c = basket.Id,
            Marketable_Offer__c=marktoffer.id,
            Offer_Reference__c=offer.id,
            ConfigurationType1__c = 'SolutionComponent',
            Name='IP Site'
        );
        insert pc;
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Cancelled';
        subs.Billing_Account__c =  billAcc.id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Product_Configuration__c = pc.id;
        insert subs;
        boolean data;
        Test.startTest();
        data = BillingAccountCreate.isCheckForFinal(billAcc.Id);
        Test.stopTest();
        System.assertEquals(data,false);
    }
    /******************************************************************
EDGE        -153317
Method      -isActiveBasketTest 
Description -Checks if any active baskets are associated with billing account
Author      -Aishwarya
******************************************************************/
    @isTest
    public static void isActiveBasketTest(){
        Test.startTest();
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        Billing_Account__c billAcc=[select id, Status__c, Include_related_Customer_Account_Contact__c, Account__c, Billing_Account_Number__c,Billing_Account_Owner__c,Billing_Address__c from Billing_Account__c where Billing_Account_Number__c='992216148101'];
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = acc.Id;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.RetiedAccOpp__c = true;
        insert testOpp;
        
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = acc.Id,
            csordtelcoa__Basket_Stage__c = 'Submitted',
            Billing_Account__c=billAcc.id
        );
        insert basket;
        
        cscfga__Product_Configuration__c testProductConfiguration1 = TestDataFactory.generateProductConfiguration();
        testProductConfiguration1.cscfga__Product_Basket__c=basket.id;
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='BillingAccountLookup';
        attr1.cscfga__Value__c=billAcc.id;
        attr1.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr1);
        insert lstAttr;
        
        
        List<cscfga__Product_Basket__c> isActiveBasket = BillingAccountCreate.fetchActiveBaskets(billAcc.Id);
        Test.stopTest();
        System.assertEquals(isActiveBasket.isEmpty(),true,'Active Baskets found');
    }
    /******************************************************************
EDGE        -167053
Method      -isPartnerusertest 
Description -Checks if login user is partner user
Author      -Raviteja
******************************************************************/
    @isTest
    public static void isPartnerusertest() 
    {  
        test.startTest();
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        User uSysAdmin = new User(alias = 'Con123', email = 'Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin00097@noemail.com', userroleid = r.id);
        insert uSysAdmin;
        User  partneruser;
        System.runAs(uSysAdmin){
            id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
            Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
            insert ac;  
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
            insert con; 
            partneruser = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                   localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                                   timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua@noemail.com',contactid=con.id);
            insert partneruser;
            
            PermissionSet ps = new PermissionSet();
            ps.Name = 'Test';
            ps.Label = 'Test';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Partner_User'][0].Id;
            insert sea;
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = partneruser.id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
        Test.stoptest();
        System.runAs(partneruser){
            boolean ispartner = BillingAccountCreate.isPartner();            
            System.assertEquals(ispartner,true);
        }
        System.runAs(uSysAdmin){
            boolean ispartner = BillingAccountCreate.isPartner();
            System.assertEquals(ispartner,false);
        }
        
        
    }
    @isTest
    static void showBillCycleDaysTest(){
        Test.startTest();
        List<Integer> data = BillingAccountCreate.showBillCycleDays();
        Test.stopTest();
        System.assertEquals(data.size()!=null,true);
    }
    /******************************************************************
EDGE        -131005
Method      -testBillCycleday 
Author      -Aishwarya
******************************************************************/
    @isTest
    public static void testBillCycleday(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact'];
        contact con1 = [Select Id,Name from contact where lastname='TestContact1'];
        List < AccountContactRelation  > lstOfContact = [SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con1.Id];
        for(AccountContactRelation acr: lstOfContact){
            acr.roles = 'Full Authority';
        }
        update lstOfContact;
        AccountContactRelation acr=[SELECT Id, AccountId, ContactId,Contact.Name FROM AccountContactRelation where AccountId = :acc.id and ContactId=:con.id];
        acr.roles = 'Full Authority'; 
        update acr;
        cscrm__Address__c add=[select id,name,cscrm__Country__c from cscrm__Address__c where cscrm__Country__c='India'];
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c,BillCycleday__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        test.startTest();
        String sTest = BillingAccountCreate.fetchban(billAcc.Id);
        
        //Id id=BillingAccountCreate.saveRecs( billAcc.Billing_Account_Number__c,'14','10',String.valueOf(acc.id),acr,add,lstOfContact,true,true);   //Commented For EDGE-198145
        Id id=BillingAccountCreate.saveRecs( billAcc.Billing_Account_Number__c,'14','10',String.valueOf(acc.id),acr,add,lstOfContact,true,true,true);//Added For EDGE-198145
        test.stopTest();
        
        Billing_Account__c billCycle=[select BillCycleday__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        system.assertEquals(billCycle.BillCycleday__c,10);
    }
    @IsTest public static void checkNotificationPreferenceForExistingPrimaryContactTest(){
        Test.startTest();
        Contact con=[SELECT Id,LastName FROM Contact WHERE LastName='TestContact' LIMIT 1];
        Boolean value=BillingAccountCreate.checkNotificationPreferenceForExistingPrimaryContact(con.id);
        system.assertEquals(true, value);
        Test.stoptest();
    }
    @IsTest public static void checkNotificationPreferenceForExistingPrimaryContactNegativeTest(){
        Test.startTest();
        Contact con=[SELECT Id,LastName FROM Contact WHERE LastName='TestContact1' LIMIT 1];
        Boolean value=BillingAccountCreate.checkNotificationPreferenceForExistingPrimaryContact(con.id);
        system.assertEquals(false, value);
        Test.stoptest();
    }
    @IsTest public static void changeNotificationPreferenceToNewPrimaryContactTest(){
        Test.startTest();
        Contact con=[SELECT Id,LastName FROM Contact WHERE LastName='TestContact' LIMIT 1];
        Contact con1=[SELECT Id,LastName FROM Contact WHERE LastName='TestContact1' LIMIT 1];
        BillingAccountCreate.changeNotificationPreferenceToNewPrimaryContact(con.id,con1.id);
        Notification_Preference__c notification=[SELECT id,Contact_Id__c From Notification_Preference__c LIMIT 1];
        system.assertEquals(con1.id, notification.Contact_Id__c);
        Test.stoptest();
    }
    @IsTest public static void changeNotificationPreferenceToNewPrimaryContactNegativeTest(){
        Test.startTest();
        Contact con=[SELECT Id,LastName FROM Contact WHERE LastName='TestContact' LIMIT 1];
        Contact con1=[SELECT Id,LastName FROM Contact WHERE LastName='TestContact1' LIMIT 1];
        BillingAccountCreate.changeNotificationPreferenceToNewPrimaryContact(con.id,con.id);
        Notification_Preference__c notification=[SELECT id,Contact_Id__c From Notification_Preference__c LIMIT 1];
        system.assertNotEquals(con1.id, notification.Contact_Id__c);
        Test.stoptest();
    }
    @IsTest public static void checkFieldPermissonTest(){
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        User uSysAdmin = new User(alias = 'Con123', email = 'Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin00097@noemail.com');
        insert uSysAdmin;
        system.runAs(uSysAdmin){
            boolean permission = BillingAccountCreate.checkFieldpermission('Edit');
            system.debug('permission**********'+permission);
            system.assertEquals(false, permission);
        }  
    }
    @isTest
    static void isisCheckForFinaliseTest(){
        Billing_Account__c billAcc=[SELECT id,Balance_Amount__c,Write_off_in_U2C__c,Written_Off__c,Status__c 
                                    FROM Billing_Account__c 
                                    WHERE Billing_Account_Number__c='992216148101'];
        
        User billingConsultant =TestDataFactory.createTestUser('Billing Consultant');
        
        System.runAs(billingConsultant){
            billAcc.status__c = 'Final';
            billAcc.Write_off_in_U2C__c = false;
            billAcc.Written_Off__c = false;
            billAcc.Balance_Amount__c = 15000.00;
            update billAcc;
            test.startTest();
            BillingAccountCreate.isCheckForFinalise(billAcc.Id);
            Test.stopTest();
            //System.assertEquals(data,false);
            system.assertEquals('Final', billAcc.status__c);
        } 
    }
  /*  @isTest
    public static void testValid2(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        System.debug('account ID------------->'+acc.id);
        System.debug('contact ID------------->'+con.id);
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = acc.Id;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.RetiedAccOpp__c = true;
        insert testOpp;
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = acc.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        insert basket;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        //Marketable_Offer__c
        Marketable_Offer__c marktoffer=new Marketable_Offer__c();
        marktoffer.Name='testoffer';
        marktoffer.Offer_ID__c='DMCAT1234';         
        insert marktoffer;
        cscfga__Configuration_Offer__c offer=new cscfga__Configuration_Offer__c();
        offer.name='Mobile';
        offer.Offer_Spec_Id__c='DMCAT1234';
        insert offer;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
            cscfga__Product_Definition__c = pd.Id,   
            cscfga__Product_Basket__c = basket.Id,
            Marketable_Offer__c=marktoffer.id,
            Offer_Reference__c=offer.id,
            ConfigurationType1__c = 'SolutionComponent',
            Name='IP Site'
        );
        insert pc;
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Cancelled';
        subs.csord__Status__c = 'Active';
        subs.Billing_Account__c =  billAcc.id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Product_Configuration__c = pc.id;
        insert subs;
        boolean data;
        Test.startTest();
        list<csord__Subscription__c> listSub = BillingAccountCreate.isCheckForFinalise(billAcc.Id);
        Test.stopTest();
        //System.assertEquals(data,false);
        System.assert(listSub.size() > 0);
    }*/
    @isTest
    public static void testValid3(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        System.debug('account ID------------->'+acc.id);
        System.debug('contact ID------------->'+con.id);
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = acc.Id;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.RetiedAccOpp__c = true;
        insert testOpp;
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = acc.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        insert basket;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        //Marketable_Offer__c
        Marketable_Offer__c marktoffer=new Marketable_Offer__c();
        marktoffer.Name='testoffer';
        marktoffer.Offer_ID__c='DMCAT1234';         
        insert marktoffer;
        cscfga__Configuration_Offer__c offer=new cscfga__Configuration_Offer__c();
        offer.name='Mobile';
        offer.Offer_Spec_Id__c='DMCAT1234';
        insert offer;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
            cscfga__Product_Definition__c = pd.Id,   
            cscfga__Product_Basket__c = basket.Id,
            Marketable_Offer__c=marktoffer.id,
            Offer_Reference__c=offer.id,
            ConfigurationType1__c = 'SolutionComponent1',
            Name='IP Site'
        );
        insert pc;
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Enterprise Mobility Plan';
        productDefinition.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000940';
        insert productDefinition;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.name='Enterprise Mobility Managed Service';
        productConfig.Type__c='New';
        productConfig.ConfigurationType1__c = 'SolutionComponent1';
        productConfig.Quantity_Product_Configuration__c = 111;
        productConfig.cscfga__Product_Definition__c=productDefinition.id;
        insert productConfig;
        
        cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.cscfga__Product_Configuration__c = pc.id;
        attr.Name = 'PaymentTypeString';
        attr.cscfga__Value__c = 'Hardware Repayment';
        insert attr;
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Cancelled';
        subs.autoExpiry__c = false;
        subs.csord__Status__c = 'Active';
        //subs.ConfigSpecID__c = 'DMCAT_ProductSpecification_000940';
        subs.Billing_Account__c =  billAcc.id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Product_Configuration__c = pc.id;
        insert subs;
        boolean data;
        Test.startTest();
        list<csord__Subscription__c> listSub = BillingAccountCreate.isCheckForFinalise(billAcc.Id);
        Test.stopTest();
        //System.assertEquals(data,false);
        System.assert(listSub.size() > 0);
    }
    @isTest
    public static void testValid4(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        System.debug('account ID------------->'+acc.id);
        System.debug('contact ID------------->'+con.id);
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = acc.Id;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.RetiedAccOpp__c = true;
        insert testOpp;
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = acc.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        insert basket;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        //Marketable_Offer__c
        Marketable_Offer__c marktoffer=new Marketable_Offer__c();
        marktoffer.Name='testoffer';
        marktoffer.Offer_ID__c='DMCAT1234';         
        insert marktoffer;
        cscfga__Configuration_Offer__c offer=new cscfga__Configuration_Offer__c();
        offer.name='Mobile';
        offer.Offer_Spec_Id__c='DMCAT1234';
        insert offer;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
            cscfga__Product_Definition__c = pd.Id,   
            cscfga__Product_Basket__c = basket.Id,
            Marketable_Offer__c=marktoffer.id,
            Offer_Reference__c=offer.id,
            ConfigurationType1__c = 'SolutionComponent1',
            Name='IP Site'
        );
        insert pc;
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Cancelled';
        subs.csord__Status__c = 'Pending';
        subs.Billing_Account__c =  billAcc.id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Product_Configuration__c = pc.id;
        insert subs;
        boolean data;
        Test.startTest();
        list<csord__Subscription__c> listSub = BillingAccountCreate.isCheckForFinalise(billAcc.Id);
        Test.stopTest();
        System.assert(listSub.size() > 0);
    }
     @isTest
    public static void testValid5(){
        Account acc = [Select Id,Name from Account where Name = 'TestAccount'];
        contact con = [Select Id,Name from contact where lastname='TestContact1'];
        System.debug('account ID------------->'+acc.id);
        System.debug('contact ID------------->'+con.id);
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = acc.Id;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.RetiedAccOpp__c = true;
        insert testOpp;
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = acc.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        insert basket;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        //Marketable_Offer__c
        Marketable_Offer__c marktoffer=new Marketable_Offer__c();
        marktoffer.Name='testoffer';
        marktoffer.Offer_ID__c='DMCAT1234';         
        insert marktoffer;
        cscfga__Configuration_Offer__c offer=new cscfga__Configuration_Offer__c();
        offer.name='Mobile';
        offer.Offer_Spec_Id__c='DMCAT1234';
        insert offer;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
            cscfga__Product_Definition__c = pd.Id,   
            cscfga__Product_Basket__c = basket.Id,
            Marketable_Offer__c=marktoffer.id,
            Offer_Reference__c=offer.id,
            ConfigurationType1__c = 'SolutionComponent1',
            Name='IP Site'
        );
        insert pc;
        Billing_Account__c billAcc=[select id,Billing_Account_Number__c from Billing_Account__c where Billing_Account_Number__c='123456789012'];
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Enterprise Mobility Plan';
        productDefinition.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000940';
        insert productDefinition;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.name='Enterprise Mobility Managed Service';
        productConfig.Type__c='New';
        productConfig.ConfigurationType1__c = 'SolutionComponent1';
        productConfig.Quantity_Product_Configuration__c = 111;
        productConfig.cscfga__Product_Definition__c=productDefinition.id;
        insert productConfig;
        
        cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.cscfga__Product_Configuration__c = productConfig.id;
        attr.Name = 'PaymentTypeString';
        attr.cscfga__Value__c = 'Hardware Repayment';
        insert attr;
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Cancelled';
        subs.autoExpiry__c = false;
        subs.csord__Status__c = 'Active';
        //subs.ConfigSpecID__c = 'DMCAT_ProductSpecification_000940';
        subs.Billing_Account__c =  billAcc.id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Product_Configuration__c = pc.id;
        insert subs;
               
        boolean data;
        Test.startTest();
        list<csord__Subscription__c> listSub = BillingAccountCreate.isCheckForFinalise(billAcc.Id);
        Test.stopTest();
        System.assert(listSub.size() <= 0);
    }
  /******************************************************************
EDGE        -217496
Method      -testActivePOR 
Author      -Yogesh
******************************************************************/    
    @isTest
    public static void testActivePOR(){
        user u = [select id from user where username='b2btestewwrpdua1@noemail.com'];
        list<Billing_Account__c> billAccount=[select id,Account__c from Billing_Account__c where Billing_Account_Number__c='123456789014'];
        Id accId = billAccount[0].Id;
        system.runAs(u){
			String resStr = BillingAccPymtAdjController.checkPRMActivePOR(accId);
            Boolean b = BillingAccountCreate.checkActivePOR(accId);
            System.assertEquals(false,b);            
        }
    }
    
    @isTest
    public static void testNegativeScenario(){
        User partneruser = [select id from user where username='b2btestewwrpdua1@noemail.com'];
        System.runAs(partneruser){
            Boolean b = BillingAccountCreate.checkActivePOR('');
            System.assertEquals(false,b);       
        }
    }   
    @isTest
    public static void testExceptionScenario(){
        Boolean b=null;
        User partneruser = [select id from user where username='b2btestewwrpdua1@noemail.com'];
        System.runAs(partneruser){
            try{
                b = BillingAccountCreate.checkActivePOR(null);
            }
            catch(Exception e){}
            System.assertEquals(false,b);       
        }
    } 
    @isTest
    public static void testBillingtestaccess(){
        Boolean b=null;
        User partneruser = [select id from user where username='b2btestewwrpdua1@noemail.com'];
        System.runAs(partneruser){
            try{
                b = BillingAccountCreate.billcycleAcc();
            }
            catch(Exception e){}
            System.assertEquals(false,b);       
        }
    } 
}