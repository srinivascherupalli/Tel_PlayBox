/**
* Data Factory class for Unit Testing
*
* @author  	Nandan Narasappa
* @version 	1.0
* @since   	15/04/2020
*
*/
@isTest
public with sharing class SYS_TestDataFactory {


    //Variables
    private static Map<String,Schema.RecordTypeInfo> accountRecordTypesMap = new Map<String,Schema.RecordTypeInfo>();
    private static Map<String,Schema.RecordTypeInfo> contactRecordTypesMap = new Map<String,Schema.RecordTypeInfo>();
    private static Map<String,Schema.RecordTypeInfo> caseRecordTypesMap = new Map<String,Schema.RecordTypeInfo>();
    private static Map<String,Schema.RecordTypeInfo> taskRecordTypesMap = new Map<String,Schema.RecordTypeInfo>();

    /**
	* This method creates user instance for testing
	*
    * @param    profileName     profile Name for the user
	* @return   User    	    instance of User object
    */
    public static User createUser(String profileName) {
        Profile prof = getProfile(profileName);
        User usrObj = (User) SYS_TestFactory.createSObject(User.sObjectType);
        usrObj.ProfileId = prof.Id;
        return usrObj;
    }

    /**
	* This method creates User with a given Role as portal user owner must have a role
	*
    * @param    roleName       Role Name for the user
	* @return   User    	   instance of User object
    */
    public static User createUser(String profileName, String userRole) {
        UserRole usrRoleObj = createUserRole(userRole);
		User usrObj = createUser(profileName);
        usrObj.userRoleId = usrRoleObj.Id;
        return usrObj;
    }

    /**
	* This method creates UserRole as portal user owner must have a role
	*
    * @param    roleName        Role Name for the user
	* @return   UserRole   	    DB instance of UserRole object
    */
    public static UserRole createUserRole(String roleName) {
        UserRole usrRoleObj = (UserRole) SYS_TestFactory.createSObject(UserRole.sObjectType);
        usrRoleObj.Name = roleName;
        usrRoleObj.DeveloperName = roleName + System.now().millisecond();
        Database.insert(usrRoleObj);
        return usrRoleObj;
    }

    /**
	* This method creates portal user instance for testing
	*
    * @param    profileName     profile Name for the user
    * @param    contactId       Id of the contact for the community user
	* @return   User    	    instance of User object
    */
    public static User createCommunityUser(String profileName,Id contactId) {
        Profile prof = getProfile(profileName);
        User usrObj = (User) SYS_TestFactory.createSObject(User.sObjectType);
        usrObj.ProfileId = prof.Id;
        usrObj.ContactId = contactId;
        return usrObj;
    }

    /**
	* This method assigns permissionset to a user
	*
    * @param    userId          profile Name for the user
    * @param    permSetName     name of the permission set
    */
    public static void assignPermissionSets(Id userId,String permSetName){
        assignPermissionSets(userId,new Set<String>{permSetName});
    }

    /**
    * This method assigns permissionset to a user
    *
    * @param    userId              profile Name for the user
    * @param    permSetNameList     Set of permisssion set name
    */
    public static void assignPermissionSets(Id userId,Set<String> permSetNameList){
        List<PermissionSet> permSetList= [SELECT Id FROM PermissionSet WHERE Label IN: permSetNameList];
        List<PermissionSetAssignment> permSetAssignmentList=new List<PermissionSetAssignment>();
        for(PermissionSet permSet:permSetList){
            PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permSet.Id);
            permSetAssignmentList.add(permSetAssignment);
        }
        Database.insert(permSetAssignmentList);
    }

    /**
	* This method creates permissionset
	*
    * @param    permSetName     name of the permission set
    */
    public static PermissionSet createPermissionSet(String permSetName){
        PermissionSet permSet = new PermissionSet(Label = permSetName, Name = permSetName.deleteWhitespace());
        return permSet;
    }

    /**
	* This method creates custom permission for a permissionset
	*
    * @param    permSetId     Id of permissionset
    * @param    setupEntityId Id of setupEntity
    */
    public static SetupEntityAccess createCustomPermission(Id permSetId, Id setupEntityId){
        SetupEntityAccess setupEntityAccess = new SetupEntityAccess(
			ParentId = permSetId,
			SetupEntityId = setupEntityId
        );
        return SetupEntityAccess;
    }


    /**
	* This method creates account instance for testing
	*
	* @return   Account    	    instance of Account object
    */
    public static Account createAccount(String cidn){
        Account accObj = (Account) SYS_TestFactory.createSObject(Account.sObjectType);
        accObj.cidn__c = cidn;
        return accObj;
    }

    /**
    * This method creates account instance for testing
    *
    * @param    recordType      type of account
	* @return   Account    	    instance of User object
    */
    public static Account createAccount(String cidn,String recordType){
        Account accObj = (Account) SYS_TestFactory.createSObject(Account.sObjectType);
        accObj.cidn__c = cidn;
        accObj.RecordTypeId = getRecordTypeId(Account.sObjectType,recordType);
        return accObj;
    }

    /**
	* This method creates contact instance for testing
	* Author : P.M
    * @param    cidn       			Id of the cidn__c for account to be linked
    * @param    recordType  		Id of the record type for account to be linked
    * @param    contactId  			Id of the principal contact for account to be linked
	* @return   Account    	    		instance of Opportunity object
    */
    public static Account createPrincipalAccount(String cidn,String recordType, String contactId){
        Account accObj = createAccount(cidn, recordType);
        accObj.Imported__c = true;
        accObj.Account_Status__c = 'Active';
        accObj.Customer_Status__c = 'ACTIVE';
        accObj.Customer_Trading_Name__c = 'test';
        accObj.ABN__c = 'test';
        accObj.ACN__c = 'test';
        accObj.PartnerPrincipalContact__c = contactId;
        accObj.State_Coverage__c = 'VIC';
        accObj.Partner_Type__c = 'Associate';
        accObj.Website = 'https://test.salesforce.com/';
        accObj.Phone = '1234567890';
        accObj.Overall_Accreditation__c = 'Platinum';
        accObj.Mobility_Accreditation__c = 'Platinum';
        accObj.Cloud_Accreditation__c = 'Platinum';
        accObj.Data_Security_Accreditation__c = 'Platinum';
        accObj.Collaboration_Accreditation__c = 'Platinum';
        accObj.Partner_Code__c = 'testCode';
        return accObj;
    }

    /**
	* This method creates opp instance for testing
	*
	* @return   Opportunity instance of Opportunity object
    */
    public static Opportunity createOpportunity(String accountId){
        Opportunity oppObj = (Opportunity) SYS_TestFactory.createSObject(Opportunity.sObjectType);
        oppObj.accountId = accountId;
        return oppObj;
    }

    /**
	* This method creates contact instance for testing
	* Author : P.M
    * @param    accountId       			Id of the account for opportunity to be linked
    * @param    principalAccountId       	Id of the principal account for opportunity to be linked
	* @return   Opportunity    	    		instance of Opportunity object
    */
    public static Opportunity createPrincipalOpportunity(String accountId, String principalAccountId){
        Opportunity oppObj = createOpportunity(accountId);
        oppObj.PartnerAccountId = principalAccountId;
        oppObj.Amount = 200000;
        oppObj.In_Contract_MAC__c = 'Yes';
        oppObj.Customer_Contact_Email__c = 'test@test.com';
        oppObj.Opportunity_Source__c = 'Partner';
        return oppObj;
    }

    /**
	* This method creates opportunity records for testing
	* @param    accountId			accountId to be associated with Opps
    * @param    numberOfRecords     number of records to be created
	* @return   List<Opportunity>    	collection of account records
    */
    public static List<Opportunity> createOpportunities(String accountId,Integer numberOfRecords){
        List<Opportunity> oppList = (List<Opportunity>) SYS_TestFactory.createSObjectList(Opportunity.sObjectType,numberOfRecords);
        for(Opportunity opp : oppList){
            opp.AccountId = accountId;
        }
        return oppList;
    }

    /**
	* This method creates contact instance for testing
	*
    * @param    accountId       Id of the account for contact to be linked
	* @return   Contact    	    instance of User object
    */
    public static Contact createContact(Id accountId){
        Contact cont = (Contact) SYS_TestFactory.createSObject(Contact.sObjectType);
        cont.AccountId = accountId;
        return cont;
    }

    /**
    * This method creates contact records for testing
    *
	* @param    accountId       	Id of the account to be linked
    * @param    numberOfRecords     number of records to be created
    * @return   List<Contact>       collection of contact records
    */
    public static List<Contact> createContacts(Integer numberOfRecords,Id accountId){
        List<Contact> conList = (List<Contact>) SYS_TestFactory.createSObjectList(Contact.sObjectType,numberOfRecords);
        for(Contact conRec : conList){
            conRec.AccountId = accountId;
        }
        return conList;
    }


    /**
	* This method creates Case instance for testing
	*
    * @param    accountId       Id of the account for case to be linked
    * @param    recordType      type of case
	* @return   Case    	    instance of case object
    */
    public static Case createCase(Id accountId,String recordTypeName){
        Case caseRec = (Case) SYS_TestFactory.createSObject(Case.sObjectType);
        caseRec.AccountId = accountId;
        caseRec.RecordTypeId = getRecordTypeId(Case.sObjectType,recordTypeName);
        return caseRec;
    }

	/**
	* This method creates case records for testing
	*
	* @param numberOfRecords number of records to be created
	* @param accountId Id of the account for case to be linked
	* @param recordTypeName type of case
	* @return List<Case> collection of Case records
	*/
    public static List<Case> createCases(Integer numberOfRecords,Id accountId,String recordTypeName){
        List<Case> caseList = (List<Case>) SYS_TestFactory.createSObjectList(Case.sObjectType,numberOfRecords);
        for(Case caseRec : caseList){
            caseRec.AccountId = accountId;
            caseRec.RecordTypeId = getRecordTypeId(Case.sObjectType,recordTypeName);
        }
        return caseList;
    }


    /**
	* This method returns profile from the database
	*
    * @param    profileName     profile Name for the user
	* @return   Profile    	    instance of Profile object
    */
    private static Profile getProfile(String profileName){
        return [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
    }

    /**
	* This method returns profile from the database
	*
    * @param    profileName     profile Name for the user
	* @return   Profile    	    instance of Profile object
    */
    private static Id getRecordTypeId(Schema.sObjectType objType, String recordTypeName){
        Id recordTypeId = null;

        // account object recordtypes
        if(Account.sObjectType == objType){
            if(accountRecordTypesMap.isEmpty()){
                accountRecordTypesMap = objType.getDescribe().getRecordTypeInfosByName();
            }
            recordTypeId = accountRecordTypesMap.get(recordTypeName).getRecordTypeId();
        }
        else if(Contact.sObjectType == objType){ // contact object recordtypes
            if(contactRecordTypesMap.isEmpty()){
                contactRecordTypesMap = objType.getDescribe().getRecordTypeInfosByName();
            }
            recordTypeId = contactRecordTypesMap.get(recordTypeName).getRecordTypeId();
        }
        else if(Case.sObjectType == objType){    // case object recordtypes
            if(caseRecordTypesMap.isEmpty()){
                caseRecordTypesMap = objType.getDescribe().getRecordTypeInfosByName();
            }
            recordTypeId = caseRecordTypesMap.get(recordTypeName).getRecordTypeId();
        }
        else if(Task.sObjectType == objType){
            if(taskRecordTypesMap.isEmpty()){
                taskRecordTypesMap = objType.getDescribe().getRecordTypeInfosByName();
            }
            recordTypeId = taskRecordTypesMap.get(recordTypeName).getRecordTypeId();
        }

        else{
            recordTypeId = objType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        return recordTypeId;
    }


	/**
	* This method creates task instance for testing
	*
    * @param    whatId       	Id of the case for task to be linked
    * @param    recordType      type of task
	* @return   task    	    instance of task object
    */
    public static Task createTask(Id whatId, String recordTypeName){
        Task taskRec = (Task) SYS_TestFactory.createSObject(Task.sObjectType);
        taskRec.WhatId = whatId;
        taskRec.RecordTypeId = getRecordTypeId(Task.sObjectType,recordTypeName);
        return taskRec;
    }

    /**
	* This method creates task instance for testing
	*
    * @param    whatId       	Id of the case for task to be linked
    * @return   task    	    instance of task object
    */
    public static Task createTask(Id whatId){
        Task taskRec = (Task) SYS_TestFactory.createSObject(Task.sObjectType);
        taskRec.WhatId = whatId;
        return taskRec;
    }

    /**
    *  This method creates task instance for testing
    *
	* @param 	numberOfRecords 	number of records to be created
    * @param    whatId          	Id of the case for task to be linked
    * @return 	List<Task> 			collection of Task records
    */
    public static List<Task> createTasks(Id whatId, Integer numberOfRecords){
        List<Task> taskList = (List<Task>) SYS_TestFactory.createSObjectList(Task.sObjectType,numberOfRecords);
        for(Task tc : taskList){
            tc.WhatId = whatId;
        }
        return taskList;
    }



    /**
	* This method creates Case Management custom setting for testing
	*
	* @return   Sobject	instance of a custom setting
    */
    public static SObject createCustomSetting(SObjectType customSetting){
        Sobject custAuthority = SYS_TestFactory.createSObject(customSetting);
        return custAuthority;
    }


    /**
    * This method returns an instance of "nguc" cspmb__Price_Item__c for testing
    *
    * @return   cspmb__Price_Item__c
    */
    public static cspmb__Price_Item__c createNGUCPriceItem(String externalId, String name, String contractType){
        cspmb__Price_Item__c ngucPriceItem = (cspmb__Price_Item__c) SYS_TestFactory.createSObject(cspmb__Price_Item__c.sObjectType,'SYS_TestFactoryDefaults.NgUCPriceItemDefaults');
        ngucPriceItem.Name = name;
        ngucPriceItem.External_Id__c = externalId;
        ngucPriceItem.Contract_Type__c = contractType;
        return ngucPriceItem;

    }


    /**
    * This method returns an instance of "mobile" cspmb__Price_Item__c for testing
    *
    * @return   cspmb__Price_Item__c
    */
    public static cspmb__Price_Item__c createMobilePriceItem(String externalId){
        cspmb__Price_Item__c mobilePriceItem = (cspmb__Price_Item__c) SYS_TestFactory.createSObject(cspmb__Price_Item__c.sObjectType,'SYS_TestFactoryDefaults.PriceItemDefaults');
        mobilePriceItem.Name = 'Mobility';
        mobilePriceItem.cspmb__Price_Item_Code__c = 'Mobility';
        mobilePriceItem.Commercial_Product_Code__c = 'Mobility';
        mobilePriceItem.cspmb__Product_Definition_Name__c = 'Mobility';
        mobilePriceItem.Package_Name__c = 'Corporate Mobile Plus';
        mobilePriceItem.Type__c = 'Data';
        mobilePriceItem.Unit_Of_Measure__c = 'per Mobility Plan';
        mobilePriceItem.External_Id__c = externalId;
        return mobilePriceItem;

    }

    /**
	* This method to creates contact record
	* Author : P.M
	* @return Contact
	*/
    public static Contact createContact(Id accountId, String recordType){
        Contact cont = (Contact) SYS_TestFactory.createSObject(Contact.sObjectType);
        cont.AccountId = accountId;
        cont.RecordTypeId = getRecordTypeId(Contact.sObjectType,recordType);
        return cont;
    }

    /**
	* This method to creates product record
	* Author : P.M
	* @return Product2
	*/
	public static Product2 createProduct(){
        Product2 product = (Product2) SYS_TestFactory.createSObject(Product2.sObjectType);
        insert product;
        return product;
    }

    /**
	* This method to creates PricebookEntry record
	* Author : P.M
	* @return PricebookEntry
	*/
    public static PricebookEntry createPricebookEntry() {
        Product2 product = createProduct();
        PricebookEntry priceBookEntryObj = (PricebookEntry) SYS_TestFactory.createSObject(PricebookEntry.sObjectType);
        priceBookEntryObj.Pricebook2Id = Test.getStandardPricebookId();
        priceBookEntryObj.Product2Id = product.Id;
        priceBookEntryObj.UnitPrice = 10000;
        priceBookEntryObj.IsActive = true;
        return priceBookEntryObj;
    }

    /**
	* This method to creates accountshare record
	* Author : P.M
	* @param accountId 				Id of the account id to link
	* @param userId 				Id of the user Id to link
	* @return AccountShare
	*/
    public static AccountShare createAccountShare(Id accountId, Id userId) {
        AccountShare accountShareObj = (AccountShare) SYS_TestFactory.createSObject(AccountShare.sObjectType);
        accountShareObj.AccountId = accountId;
        accountShareObj.UserOrGroupId = userId;
        return accountShareObj;
    }

    /**
	* This method to creates OpportunityShare record
	* Author : P.M
	* @param OpptyId 				Id of the Opportunity id to link
	* @param userId 				Id of the user Id to link
	* @return OpportunityShare
	*/
    public static OpportunityShare createOpptyShare(Id OpptyId, Id userId) {
        OpportunityShare oppShareObj = (OpportunityShare) SYS_TestFactory.createSObject(OpportunityShare.sObjectType);
        oppShareObj.OpportunityId  = OpptyId;
        oppShareObj.UserOrGroupId = userId;
        oppShareObj.OpportunityAccessLevel = 'Edit';
        return oppShareObj;
    }


    /**
	* This method to creates opportunitylineitem record
	* Author : P.M
	* @param priceBookEntry 	Id of the pricebookentry to link
	* @param oppId 				Id of the opportuniy to link
	* @return OpportunityLineItem
	*/
    public static OpportunityLineItem createOpportunityLineItem(Id priceBookEntry, Id oppId) {
        OpportunityLineItem oli = (OpportunityLineItem) SYS_TestFactory.createSObject(OpportunityLineItem.sObjectType);
        oli.PriceBookEntryId = priceBookEntry;
        oli.OpportunityID = oppId;
        return oli;
    }

    /**
	* This method is used to create Partner_of_Record__c
	* Author : P.M
    * @param accId 	Id of the account to link
	* @return Partner_of_Record__c
	*/
    public static Partner_of_Record__c createPOR(Id accountId) {
        Partner_of_Record__c partnerOfrecord = (Partner_of_Record__c) SYS_TestFactory.createSObject(Partner_of_Record__c.sObjectType);
        partnerOfrecord.Customer__c = accountId;
        partnerOfrecord.Partner__c = accountId;
        return partnerOfrecord;
    }

    /**
	* This method is used to create Marketable_Offer__c record
	* Author : P.M
    * @param offerId  offer id to link
	* @return Marketable_Offer__c
	*/
    public static Marketable_Offer__c createMarketableOffer(String offerId) {
        Marketable_Offer__c marketableOffer = (Marketable_Offer__c) SYS_TestFactory.createSObject(Marketable_Offer__c.sObjectType);
        marketableOffer.Name = 'TestMarketableOffer';
        marketableOffer.Offer_ID__c = offerId;
        return marketableOffer;
    }

    /**
	* This method is used to create ContractJunction__c record
	* Author : P.M
    * @param oppId 	Id of the opportuniy to link
	* @return ContractJunction__c
	*/
    public static ContractJunction__c createContractJunction(Id oppId) {
        ContractJunction__c contractJunctionRec = (ContractJunction__c) SYS_TestFactory.createSObject(ContractJunction__c.sObjectType);
        contractJunctionRec.Name = 'TestContract';
        contractJunctionRec.Related_Opportunity__c = oppId;
        return contractJunctionRec;
    }

    /**
	* This method is used to create Apttus__APTS_Agreement__c record
	* Author : P.M
    * @param name  Name of the agreement
	* @return Apttus__APTS_Agreement__c
	*/
    public static Apttus__APTS_Agreement__c createAgreement(String name) {
        Apttus__APTS_Agreement__c agreement = (Apttus__APTS_Agreement__c) SYS_TestFactory.createSObject(Apttus__APTS_Agreement__c.sObjectType);
        agreement.Name = name;
        return agreement;
    }

    /**
	* This method is used to create cscfga__Product_Basket__c record
	* Author : P.M
    * @param accId 	Id of the account to link
	* @param oppId 	Id of the opportuniy to link
	* @return cscfga__Product_Basket__c
	*/
    public static cscfga__Product_Basket__c createProductBasket(Id accId, Id oppId) {
        cscfga__Product_Basket__c productBasket = (cscfga__Product_Basket__c) SYS_TestFactory.createSObject(cscfga__Product_Basket__c.sObjectType);
        productBasket.csbb__Account__c = accId;
        productBasket.cscfga__Opportunity__c = oppId;
        productBasket.Name = 'TestProductBasket';
        return productBasket;
    }

    /**
	* This method is used to create cscfga__Product_Definition__c record
	* Author : P.M
    * @param definition  Name of definition
	* @param productSpecification 	product_Specification__c of record
	* @return cscfga__Product_Definition__c
	*/
    public static cscfga__Product_Definition__c createProductDefinition(String definition, String productSpecification) {
        cscfga__Product_Definition__c productDefinition = (cscfga__Product_Definition__c) SYS_TestFactory.createSObject(cscfga__Product_Definition__c.sObjectType);
        productDefinition.Name = definition;
        productDefinition.cscfga__Description__c = definition;
        productDefinition.product_Specification__c = productSpecification;
        return productDefinition;
    }

    /**
	* This method is used to create cscfga__Product_Configuration__c record
	* Author : P.M
    * @param name  Name of Product Configuration
	* @param basketId   Id of the basket to link
    * @param definitionId   Id of the definition to link
	* @return cscfga__Product_Configuration__c
	*/
    public static cscfga__Product_Configuration__c createProductDefinition(String name, Id basketId, Id definitionId) {
        cscfga__Product_Configuration__c productConfig = (cscfga__Product_Configuration__c) SYS_TestFactory.createSObject(cscfga__Product_Configuration__c.sObjectType);
        productConfig.Name = name;
        productConfig.cscfga__Product_Basket__c = basketId;
        productConfig.cscfga__Product_Definition__c = definitionId;
        return productConfig;
    }

    /**
	* This method is used to create cscfga__Attribute__c record
	* Author : P.M
    * @param name  Name of Attribute
	* @param configId   Id of the Product Configuration to link
	* @return cscfga__Attribute__c
	*/
    public static cscfga__Attribute__c createAttribute(String name, Id configId) {
        cscfga__Attribute__c productConfig = (cscfga__Attribute__c) SYS_TestFactory.createSObject(cscfga__Attribute__c.sObjectType);
        productConfig.Name = name;
        productConfig.cscfga__Product_Configuration__c = configId;
        return productConfig;
    }

    /**
	* This method is used to create csord__Service__c record
	* Author : P.M
    * @param subscriptionId  Id of the subscription to link
	* @return csord__Service__c
	*/
    public static csord__Service__c createService(Id subscriptionId) {
        csord__Service__c service = (csord__Service__c) SYS_TestFactory.createSObject(csord__Service__c.sObjectType,'SYS_TestFactoryDefaults.ServiceDefaults');
        service.csord__Subscription__c = subscriptionId;
        return service;
    }

    /**
	* This method is used to create order
	* Author : P.M
    * @param accId 	Id of the account to link
	* @param oppId 	Id of the opportuniy to link
	* @return csord__Order__c
	*/
    public static csord__Order__c createOrder(Id accId, Id oppId) {
        csord__Order__c order = (csord__Order__c) SYS_TestFactory.createSObject(csord__Order__c.sObjectType,'SYS_TestFactoryDefaults.OrderDefaults');
        order.csord__Account__c = accId;
        order.csordtelcoa__Opportunity__c = oppId;
        return order;
    }

    /**
	* This method is used to create csord__Subscription__c record
	* Author : P.M
    * @param name  Name of Attribute
    * @param accId 	Id of the account to link
    * @param orderId 	Id of the order to link
	* @param configId   Id of the Product Configuration to link
	* @return csord__Subscription__c
	*/
    public static csord__Subscription__c createSubscription(String name, Id accountId, Id orderId, Id configId) {
        csord__Subscription__c subscription = (csord__Subscription__c) SYS_TestFactory.createSObject(csord__Subscription__c.sObjectType, 'SYS_TestFactoryDefaults.SubscriptionDefaults');
        subscription.Name = name;
        subscription.csord__Account__c = accountId;
        subscription.csord__Order__c = orderId;
        subscription.csordtelcoa__Product_Configuration__c = configId;
        subscription.csord__Identification__c = 'test';
        subscription.csord__Status__c = 'NA';
        subscription.stage__c = 'NA';
        return subscription;
    }

    /**
	* This method to creates cscfga__Configuration_Offer__c record
	* Author : Uday
	* @param Offer Name
	* @return cscfga__Configuration_Offer__c
	*/
    public static cscfga__Configuration_Offer__c createConfigurationOfferRec(String offerNme){
        cscfga__Configuration_Offer__c offername = new cscfga__Configuration_Offer__c();
        offername.Offer_Spec_Id__c = 'DMCAT_Offer_000649';
        offername.name = offerNme;
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Test';
        return offername;
    }

    /**
	* This method to creates basket record
	* Author : Sudheendra
	* @param Offer Name
	* @return cscfga__Configuration_Offer__c
	*/
    public static cscfga__Product_Configuration__c createProductConfigurationRec(Map<String, String> params){
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        for(String p:params.keySet()){
            prodConfig.put(p,params.get(p));
        }
        return prodConfig;
    }

    /**
	* This method to creates charge line item record
	* Author : Uday Dunna
	* @param Offer Name
	* @return Charge_Line_Item__c
	*/
    public static Charge_Line_Item__c createChargeineItem(String guid){
        Charge_Line_Item__c cli = new Charge_Line_Item__c();
        cli.guid__c = guid;
        return cli;
    }
     
    /**
	* This method to creates marketale offer record
	* Author : Uday Dunna
	* @param Offer Name
	* @return Marketable_Offer__c
	*/
    public static Marketable_Offer__c createMarketOffer(String name){
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.Name = name;
        return moMob;
    }

    /**
	* This method creates Number records for testing
	*
	* @param numberList list of numbers
	* @param status numbert status
	* @return List<Number__c> collection of Number__c records
	*/
    public static List<Number__c> createNumbers(List<String> numberList, string status){        
        List<Number__c> numList = (List<Number__c>) SYS_TestFactory.createSObjectList(Number__c.sObjectType,numberList.size());
        for(integer i = 0; i<numList.size(); i++) {
            numList[i].Service_Number__c = numberList[i];
            numList[i].Subscription_Number__c = 'SN-000000001';
            numList[i].Status__c = status;
        }
        return numList;
    }
 
    /**
	* This method creates Number records for testing
	*
	* @param numberOfRecords number of records to be created
	* @param status number status
	* @return List<Number__c> collection of Number__c records
	*/
    public static List<Number__c> createNumbers(Integer numberOfRecords, string status){    
        List<Number__c> numList = (List<Number__c>) SYS_TestFactory.createSObjectList(Number__c.sObjectType, numberOfRecords);
        Integer startNumber = Integer.valueOf('61000000001');
        for(integer i = 0; i<numberOfRecords; i++) {
            numList[i].Service_Number__c = String.valueOf(startNumber + i);
            numList[i].Subscription_Number__c = 'SN-000000001';
            numList[i].Status__c = status;
        }
        return numList;
    }
}