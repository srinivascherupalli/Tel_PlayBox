/**
     * @Author   :   Rahul Asarma
     * @Date     :   23 Nov 2020
     * @US       :   EDGE-176686
     * @Description: Test class for AgreementUtilities that creates Agreeemnts for deal Pricing.
     * Aniket Srivastava:30/07/2011 TED-104 : Refactored the class
 * **/
@IsTest 
public with sharing class AgreementUtilities_Test {
@testSetup
  static void setupTestData(){
        
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.APTPS_DocuSign_Restricted__c = false; 
        acc.Customer_Status__c = 'Active'; 

         insert acc;  
        //CREATE CONTACT 
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        Database.SaveResult sr = Database.insert(contact, dml);
        if (sr.isSuccess()) {
            System.debug('Duplicate account has been inserted in Salesforce!');
        }
        
        //list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test Adaptive Opty';
        opp.amount = 4600;
       insert opp;
       
        

         list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        lstbasket.add(basket);
       // insert basket;
        
         //Create Basket
       /* cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
        basket2.cscfga__Opportunity__c = opp.id;
        basket2.Name = 'basket2';
        lstbasket.add(basket2);*/
        
        insert lstbasket;
       Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
       
        Delegated_Pricing_Request__c dpr= new Delegated_Pricing_Request__c();
        dpr.Account__c=acc.id;
        dpr.Opportunity__c=opp.id;
        dpr.Commitment_Frequency__c='Quarterly';
        insert dpr;
        
        DPR_Offer__c dproffer= new DPR_Offer__c();
        dproffer.Delegated_Pricing_Request__c=dpr.id;
        dproffer.name='Adaptive Mobility Plan';
        insert dproffer;
        
        DPR_Offer_Line_Item__c dolineitem= new DPR_Offer_Line_Item__c();
        dolineitem.Delegated_Pricing_Request__c=dpr.id;
        dolineitem.Marketable_Offer__c=Marketoffer.id;
        dolineitem.List_Price__c=10;
        dolineitem.DPR_Offer__c=dproffer.id;
        dolineitem.DPR_Offer_Line_Item_Type__c ='Plan';
        dolineitem.Offer_Type_Name__c='Mobile Broadband';
        dolineitem.DPR_Offer_Line_Item_Value__c=10;
        insert dolineitem;
        
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=acc.id;
        framAg.Opportunity__c=opp.id;
        framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
        List<Apttus__APTS_Template__c> aptTempList = new List<Apttus__APTS_Template__c>();
        Apttus__APTS_Template__c dsaTemp  = APTPS_TestClassData.templateRecord('DSA_Template','Agreement');
        Apttus__APTS_Template__c psTemp = APTPS_TestClassData.templateRecord('Price_Schedule_Template','Agreement'); 
        aptTempList.add(dsaTemp);
        aptTempList.add(psTemp); 

  }
  @isTest 
     static void checkExistingAgreementRecords_Positive_test(){

        Account accountdetails=[select id from account where name='Test Account' limit 1];
        /*acc.APTPS_DocuSign_Restricted__c = false;
        acc.Customer_Status__c = 'Active';
        insert acc;*/  
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
       list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        /*Product2 prod1=new Product2();
        prod1.Name='Adaptive Mobility1';*/
        prodlst.add(prod);
        //prodlst.add(prod1);
        insert prodlst;
        
        Opportunity oppRecord=[select id,name from Opportunity where name='Test Adaptive Opty' limit 1];
        //Added test Changes for EDGE-184432
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = conRecord.Id;
        oppContRole.OpportunityId = oppRecord.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;
        

        List<Delegated_Pricing_Request__c> dprList= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id];
        
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];

    
         List<Apttus__APTS_Template__c> aptTempList = [Select Id, Name from Apttus__APTS_Template__c];

        Test.startTest();
        AgreementUtilities.AgreementUtilDetails(dprList,relatedDPROLI);
        //AgreementUtilities.checkExistingAgreementRecords(accountdetails);
        test.stoptest();
        List<Apttus__APTS_Agreement__c > agrList=[select id,Apttus__Agreement_Category__c from Apttus__APTS_Agreement__c where Apttus__Related_Opportunity__c =:oppRecord.id];
        system.debug('CreatedAgreementList'+agrList);
        System.assertEquals(agrList[0].Apttus__Agreement_Category__c,'Digital Services');
        System.assertEquals(agrList[1].Apttus__Agreement_Category__c,'Pricing');
     }
    //Added test Method for EDGE-184432
    @isTest 
     static void checkExistingAgreementRecords_Positive_testWithFA_default_Signatory(){

        Account accountdetails=[select id from account where name='Test Account' limit 1];
        /*acc.APTPS_DocuSign_Restricted__c = false;
        acc.Customer_Status__c = 'Active';
        insert acc;*/  
        
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        /*Product2 prod1=new Product2();
        prod1.Name='Adaptive Mobility1';*/
        prodlst.add(prod);
        //prodlst.add(prod1);
        insert prodlst;
        
        Opportunity oppRecord=[select id,name from Opportunity where name='Test Adaptive Opty' limit 1];
        

        List<Delegated_Pricing_Request__c> dprList= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id];
        
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];

    
         List<Apttus__APTS_Template__c> aptTempList = [Select Id, Name from Apttus__APTS_Template__c];
         
        FA_DefaultRecipients__c faDef= new FA_DefaultRecipients__c();
        faDef.Signatory_1__c=conRecord.id;
        faDef.Signatory_2__c=userinfo.getuserid();
        faDef.Deal_Pricing_Request__c=dprList[0].id;
        insert faDef;

        Test.startTest();
        AgreementUtilities.AgreementUtilDetails(dprList,relatedDPROLI);
        //AgreementUtilities.checkExistingAgreementRecords(accountdetails);
        test.stoptest();
        List<Apttus__APTS_Agreement__c > agrList=[select id,Apttus__Agreement_Category__c from Apttus__APTS_Agreement__c where Apttus__Related_Opportunity__c =:oppRecord.id];
        system.debug('CreatedAgreementList'+agrList);
        System.assertEquals(agrList[0].Apttus__Agreement_Category__c,'Digital Services');//EDGE-184432
        System.assertEquals(agrList[1].Apttus__Agreement_Category__c,'Pricing');//EDGE-184432
     }
    @isTest 
     static void checkExistingAgreementRecords_ExistingAgreementRecord_test(){
        Test.startTest();
        setupTestData();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'OpportunityTrigger';
        insert disabledTriggersProfile;
        
        Account accountdetails=[select id from account where name='Test Account' limit 1];
        Opportunity oppRecord=[select id,name from Opportunity where name='Test Adaptive Opty' limit 1];
         list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
             
            string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
            string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
            Apttus__APTS_Agreement__c agreementDSA = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=accountdetails.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
             Agglist.add(agreementDSA); 
            
            Apttus__APTS_Agreement__c agreementBSA = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=accountdetails.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Business Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
             Agglist.add(agreementBSA); 
            
           Apttus__APTS_Agreement__c agreementPS = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=accountdetails.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
            
            
            Agglist.add(agreementPS); 
        
        insert  Agglist ; 

        
         list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        /*Product2 prod1=new Product2();
        prod1.Name='Adaptive Mobility1';*/
        prodlst.add(prod);
        //prodlst.add(prod1);
        insert prodlst;

        Apttus__AgreementLineItem__c lineitem = new Apttus__AgreementLineItem__c();
        lineitem.Apttus__AgreementId__c = Agglist[2].id;
        lineitem.Apttus__ProductId__c= prod.id;
        insert lineitem;
       
        
        
        List<Delegated_Pricing_Request__c> dprList= [select id,Account__c,Opportunity__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id];
        
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
        
        //AgreementUtilities.checkExistingAgreementRecords(accountdetails);
        AgreementUtilities.AgreementUtilDetails(dprList,relatedDPROLI);
        AgreementUtilities.logException('GenerateAgreement', '', Agglist[0].id, 'testClassRun', 'Generation of Agreement Document Failed.');
        test.stoptest();
        List<Apttus__APTS_Agreement__c > agrList=[select id,Apttus__Agreement_Category__c from Apttus__APTS_Agreement__c where Apttus__Related_Opportunity__c =:oppRecord.id and Apttus__Agreement_Category__c='Pricing'];
        
        System.assertEquals(agrList[0].Apttus__Agreement_Category__c,'Pricing');
     }
    @isTest 
    static void checkExistingAgreementRecords_ExistingAgreementPSRecord_test(){
        Test.startTest();
        setupTestData();
        /* EnvironmentalSettings es = new EnvironmentalSettings();
        EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger');*/
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'OpportunityTrigger';
        insert disabledTriggersProfile;
        
        
        Account accountdetails=[select id from account where name='Test Account' limit 1];
        
        
          
         list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
            string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
            string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
            Apttus__APTS_Agreement__c agreementDSA = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=accountdetails.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
             Agglist.add(agreementDSA); 
            
            Apttus__APTS_Agreement__c agreementBSA = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=accountdetails.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Business Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
             Agglist.add(agreementBSA); 
            
          Apttus__APTS_Agreement__c agreementPS = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=accountdetails.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
            
            
            Agglist.add(agreementPS); 
        insert  Agglist ; 

        
         list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Adaptive Mobility1';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;

        Apttus__AgreementLineItem__c lineitem = new Apttus__AgreementLineItem__c();
        lineitem.Apttus__AgreementId__c = Agglist[2].id;
        lineitem.Apttus__ProductId__c= prod.id;
        insert lineitem;
        
        Opportunity oppRecord=[select id,name from Opportunity where name='Test Adaptive Opty' limit 1];
        
        List<Delegated_Pricing_Request__c> dprList= [select id,Account__c,Opportunity__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id];
        
        
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
        
        //AgreementUtilities.checkExistingAgreementRecords(accountdetails);
        AgreementUtilities.AgreementUtilDetails(dprList,relatedDPROLI);
        
        test.stoptest();
        List<Apttus__AgreementLineItem__c> agreementLineitemsList= [select id,Product__c from Apttus__AgreementLineItem__c where Apttus__AgreementId__c =: Agglist[2].id];
        system.debug('agreementLineitemsListdetails'+agreementLineitemsList);
         System.assertEquals(agreementLineitemsList[0].Product__c,'Adaptive Mobility');
     }
  @isTest
    static void validationForContractCreationTest(){

        Test.startTest();
        String psProductFamilies = 'Adaptive Mobility';
        list<cscfga__Product_Basket__c> basketRecord = [SELECT Id, Name, csbb__Account__c from cscfga__Product_Basket__c order by createddate desc];
         system.debug( '<-->basketRecord--> ' +basketRecord);
        map<String, boolean> validationForContractCreation = AgreementUtilities.validationForContractCreation(basketRecord[0], psProductFamilies.split(';'), 'DSA');
        System.assert(validationForContractCreation.get('isAgreementGeneratedBSA') == false);
        test.stoptest();
    }
    
    @isTest
    static void createAgreementTest(){
    Test.startTest();
        Apttus__APTS_Agreement__c agmtSA = new Apttus__APTS_Agreement__c();
        Apttus__APTS_Agreement__c agmtPS = new Apttus__APTS_Agreement__c();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        prod.Telstra_Marketable_Product_Family__c = 'Adaptive Mobility';
        prod.IsActive = true;
        insert prod;
        set<String> prodFamily = new Set<String>{'Adaptive Mobility'};
        agmtSA = AgreementUtilities.createSAAgreement('Digital Services');
        insert agmtSA;
        agmtPS = AgreementUtilities.createPSAgreement(agmtSA);
        insert agmtPS;
        list<Id> agmtLineItemId = AgreementUtilities.createAgreementLineItem_RF(agmtPS.Id,prodFamily,null);
        test.stoptest();
        Apttus__agreementlineitem__c agreementLineItem = [SELECT id,Apttus__ProductId__c from Apttus__agreementlineitem__c where id=:agmtLineItemId[0]];
        system.debug('agmtSA:' + agmtSA);
        system.debug('agmtPS:' + agmtPS);
        system.debug('agmtLineItemId:' + agmtLineItemId);
        system.assertEquals('Internal Digital', agmtSA.Apttus__Source__c);
        system.assertEquals('Internal Digital', agmtPS.Apttus__Source__c);
        system.assertEquals(prod.Id, agreementLineItem.Apttus__ProductId__c);
        
    }
    
    @isTest
    static void insertDocusignRecipientsTest(){
    Test.startTest();
        Apttus__APTS_Agreement__c agmtSA = new Apttus__APTS_Agreement__c();
        Apttus__APTS_Agreement__c agmtPS = new Apttus__APTS_Agreement__c();
        Contact customerContact;
        User companyContact;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        customerContact = new Contact(email = 'tst@gmail.com',phone = '2345654569',FirstName = 'test',LastName='test');
        insert customerContact;
        list<Profile> prof = [select id from profile where name LIKE 'Sales-Enterprise-Unified' OR name like 'System Administrator' Order by Name ASC];
        UserRole roleUser = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
        companyContact = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',MobilePhone = '9993550124',
                                    localesidkey='en_US', profileid =prof[0].id, country='United States',IsActive =true,                
                                    timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=roleUser.id);
        insert companyContact;
       }
        set<String> prodFamily = new Set<String>{'Adaptive Mobility'};
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
        agmtSA = AgreementUtilities.createSAAgreement('Digital Services');
        agmtList.add(agmtSA);
        agmtPS = AgreementUtilities.createPSAgreement(agmtList[0]);
        agmtList.add(agmtPS);
        insert agmtList;
        AgreementUtilities.insertDocusignRecipients(agmtList,customerContact,companyContact);
        test.stoptest();
        system.debug('agmtSA:' + agmtSA);
        system.assertEquals('Internal Digital', agmtSA.Apttus__Source__c);
        
        
    }
    
    //Added on DIGI-434 started 
    @isTest
    static void generateContractSupportCaseTest(){
        Test.startTest();
        List<Opportunity> listOfOpps=[SELECT id,name,AccountId from opportunity WHERE Amount=4600];
        Case caseInstance = AgreementUtilities.generateContractSupportCase('test Class Case', UserInfo.getUserId(), 'test Case', listOfOpps[0].Id );
        insert caseInstance;
        System.assertNotEquals(null, caseInstance);
        Test.stopTest();
    } //End DIGI-434
  

}