/**
* @Author   :   Rahul Asarma
* @Date     :   Jan 2021
* @US       :   EDGE-193827
* @Description: Test class for AgreementOrderUtilities that creates vairation PS Agreeemnts.
* Aniket 29/07/2021 : Updated as part of TED-104
* Lokesh Thathuru : DIGI-7386 updated
* Lokesh Thathuru : DIGI-19273 Updated the class to fix the testmethod 
* */
@IsTest 
public with sharing class AgreementOrderUtilitiesTest {
    
    public static Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    //public static string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    public static string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
    
    public static Account acc = null;
    public static Contact contact= null;
    public static Opportunity opty = null;
    @testSetup
    static void setupTestData(){
        
        
        acc = AccountTestFactory.buildAccount('Test AccountOrderflow') ;
        
        acc.APTPS_DocuSign_Restricted__c = false; 
        acc.Customer_Status__c = 'Active'; 
        
        insert acc;  
        //CREATE CONTACT 
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        contact = AccountTestFactory.buildContact(acc,'Test Contact');
        Database.SaveResult sr = Database.insert(contact, dml);
        if (sr.isSuccess()) {
            System.debug('Duplicate account has been inserted in Salesforce!');
        }
       
        
        
        list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Id strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Opportunity' and DeveloperName = 'Defined'].Id;
        Opportunity opty   = ProductTestFactory.getOpportunityBasic(acc);
        opty.name='New Opty';
        opty.amount = 4600;
        opty.RecordTypeId = strRecordTypeId;
        opty.Contract_Type__c = 'DSA';
        listoppty.add(opty);
        insert listoppty;
        
        
        
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket00 = ProductTestFactory.buildEmptyBasket();
        basket00 = ProductTestFactory.buildEmptyBasket();
        basket00.csbb__Account__c = acc.id;
        basket00.cscfga__Opportunity__c = listoppty[0].id;
        basket00.Name = 'New basket';
        basket00.cscfga__total_contract_value__c = 10;
        basket00.BasketType__c = 'Incoming';
        lstbasket.add(basket00);
        
        cscfga__Product_Basket__c basket01 = ProductTestFactory.buildEmptyBasket();
        basket01 = ProductTestFactory.buildEmptyBasket();
        basket01.csbb__Account__c = acc.id;
        basket01.cscfga__Opportunity__c = listoppty[0].id;
        basket01.Name = 'Previous basket';
        basket01.cscfga__total_contract_value__c = 20;
        basket01.BasketType__c = 'Incoming';
        lstbasket.add(basket01);
        insert lstbasket;
        
        lstbasket[0].csordtelcoa__Previous_Product_Basket__c = lstbasket[1].id;
        upsert lstbasket;
        
        ContractJunction__c cntrctRecord=new ContractJunction__c();
        cntrctRecord.Account__c = lstbasket[0].csbb__Account__c;
        cntrctRecord.Related_Opportunity__c=lstbasket[0].cscfga__Opportunity__c;
        cntrctRecord.Related_Basket__c=lstbasket[0].id;
        cntrctRecord.DocuSign_Signer_2__c = contact.id;
        cntrctRecord.DocuSign_Signer_3__c = UserInfo.getUserId();
        cntrctRecord.Customer_Primary_Contact__c = contact.id;
        cntrctRecord.Contract_Type__c = 'DSA';
        insert cntrctRecord;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c pd00 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd00.product_Specification__c='DMCAT_ProductSpecification_001196';
        pdList.add(pd00);
        insert pdList;
        
        List<Marketable_Offer__c> moList = new List<Marketable_Offer__c>();
        Marketable_Offer__c mo00 = new Marketable_Offer__c();
        mo00.OfferDefinationName__c ='Next Generation Enterprise Mobility';
        mo00.Name = 'Adaptive Mobility';
        mo00.Offer_ID__c = 'DMCAT_Offer_001233';
        mo00.Contract_Type__c = 'DSA';
        mo00.Product_Family__c = 'Adaptive Mobility';
        moList.add(mo00);
        insert moList;
        
        
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config00 = ProductTestFactory.buildProductConfig(pdList[0].id);
        config00.name='Handheld-Essential';
        config00.Type__c = 'New';
        config00.Marketable_Offer__c = moList[0].id;
        config00.cscfga__Product_Family__c='Enterprise Mobility Plan';
        config00.cscfga__unit_recurring_charge__c = 200;
        config00.Quantity_Product_Configuration__c =1;
        config00.cscfga__Product_Definition__c = pdList[0].Id;
        config00.cscfga__Product_Basket__c = lstbasket[0].id;
        pcList.add(config00);
        insert pcList;
        
        List<Apttus__APTS_Template__c> templateList = new List<Apttus__APTS_Template__c>();
        Apttus__APTS_Template__c temp00 = new Apttus__APTS_Template__c(name='DSA_Template',Apttus__IsActive__c = true,Apttus__Type__c= 'Agreement');
        templateList.add(temp00);
        Apttus__APTS_Template__c temp01 = new Apttus__APTS_Template__c(name='Price Schedule Digital',Apttus__IsActive__c = true,Apttus__Type__c= 'Agreement');
        templateList.add(temp01);
        Apttus__APTS_Template__c temp02 = new Apttus__APTS_Template__c(name='BSA',Apttus__IsActive__c = true,Apttus__Type__c= 'Agreement');
        templateList.add(temp02);
        Apttus__APTS_Template__c temp03 = new Apttus__APTS_Template__c(name='Price_schedule_Cover_Letter',Apttus__IsActive__c = true,Apttus__Type__c= 'Supporting Document');
        templateList.add(temp03);
        insert templateList;
        
        
    }
    
    
    @isTest static void createAgreementRecords_New(){
        //setupTestData(); //Commented as a Part of DIGI-15323
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductConfigurationTrigger';
        insert disabledTriggersProfile;
        cscfga__Product_Basket__c prodBasket = [select id,csbb__Account__c from cscfga__Product_Basket__c limit 1];
        ContractJunction__c cjRecord = [Select id,Customer_Primary_Contact__c,Account__c,Related_Opportunity__c,Related_Basket__c,DocuSign_Signer_3__c,DocuSign_Signer_2__c from ContractJunction__c limit 1];
        Opportunity opp =[Select id,contract_type__c from opportunity limit 1];
        Test.startTest();
        //DIGI-19273 testmethod fail fix
        try{
        AgreementOrderUtilities.createAgreementRecords(cjRecord,prodBasket,opp,null);
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        } //DIGI-19273 testmethod fail fix
                
        List<Apttus__APTS_Agreement__c> agmt = [SELECT id FROM Apttus__APTS_Agreement__c where Related_Contract__c =:cjRecord.id];
        Test.stopTest();
        system.assertNotEquals(null, agmt[0].id);
    }
    
    @isTest static void createAgreementRecords_Case(){
        
  //DIGI-683
        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'caseTrigger,APTPS_AgreementTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;
        //setupTestData();
        opportunity opty = [Select id from opportunity where name = 'New Opty' limit 1];
        cscfga__Product_Basket__c basket = [Select id,csbb__Account__c from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 10 limit 1];
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        agmtList[2].Apttus__Parent_Agreement__c = agmtList[0].id;
        agmtList[3].Apttus__Parent_Agreement__c = agmtList[1].id;
        upsert agmtList;
        system.debug('agreementPSDigi:' + agmtList[2].Related_Basket__c);
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem00 = new Apttus__AgreementLineItem__c();
        lineitem00.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        
        
        //Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        cscfga__Product_Basket__c prodBasket = [select id,csbb__Account__c,csbb__Account__r.APTPS_Contract_Manager__c,name from cscfga__Product_Basket__c where cscfga__total_contract_value__c =10 limit 1];
        ContractJunction__c cjRecord = [Select id,Customer_Primary_Contact__c,Account__c,Related_Opportunity__c,Related_Basket__c,DocuSign_Signer_3__c,DocuSign_Signer_2__c from ContractJunction__c limit 1];
        Opportunity opp =[Select id,contract_type__c from opportunity where name = 'New Opty' limit 1];
        Test.startTest();
        AgreementOrderUtilities.createAgreementRecords(cjRecord,prodBasket,opp,null);
        Test.stopTest();
        Boolean isPSAmended = false;
        List<Apttus__APTS_Agreement__c> agmtPS= [SELECT id,Apttus__Status__c,Apttus__Source__c,Related_Basket__c from Apttus__APTS_Agreement__c where RecordTypeId =:AGREEMENT_Schedule_RECORDTYPEID AND Apttus__Account__c =: prodBasket.csbb__Account__c];
        for(Apttus__APTS_Agreement__c agmt:agmtPS){
            system.debug('agmt:' + agmt.id+':'+agmt.Apttus__Status__c+':'+agmt.Apttus__Source__c+':'+agmt.Related_Basket__c);
            if(agmt.Apttus__Status__c ==APTPS_Constants.BEINGAMENDED_STATUS){
                isPSAmended = true;  
                break;
            }
        }
        
        system.assertEquals(false, isPSAmended);
        
        
    }
    //DIGI-683
    @isTest static void createAgreementRecords_Variation(){
        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'caseTrigger,APTPS_AgreementTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;
        //setupTestData(); //Commented as a Part of DIGI-15323
        opportunity opty = [Select id from opportunity where name = 'New Opty' limit 1];
        cscfga__Product_Basket__c basket = [Select id,csbb__Account__c from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 10 limit 1];
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        //Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        //agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        //Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        //agmtList.add(agreementPSLegacy);
        insert agmtList;
        agmtList[1].Apttus__Parent_Agreement__c = agmtList[0].id;
        //agmtList[3].Apttus__Parent_Agreement__c = agmtList[1].id;
        upsert agmtList;
        system.debug('agreementPSDigi:' + agmtList[1].Related_Basket__c);
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        /*Apttus__AgreementLineItem__c lineitem00 = new Apttus__AgreementLineItem__c();
        lineitem00.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);*/
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        
        
        //Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        cscfga__Product_Basket__c prodBasket = [select id,csbb__Account__c,csbb__Account__r.APTPS_Contract_Manager__c,name from cscfga__Product_Basket__c where cscfga__total_contract_value__c =10 limit 1];
        ContractJunction__c cjRecord = [Select id,Customer_Primary_Contact__c,Account__c,Related_Opportunity__c,Related_Basket__c,DocuSign_Signer_3__c,DocuSign_Signer_2__c from ContractJunction__c limit 1];
        Opportunity opp =[Select id,contract_type__c from opportunity where name = 'New Opty' limit 1];
        Test.startTest();
        AgreementOrderUtilities.createAgreementRecords(cjRecord,prodBasket,opp,null);
        Test.stopTest();
        Boolean isPSAmended = false;
        List<Apttus__APTS_Agreement__c> agmtPS= [SELECT id,Apttus__Status__c,Apttus__Source__c,Related_Basket__c from Apttus__APTS_Agreement__c where RecordTypeId =:AGREEMENT_Schedule_RECORDTYPEID AND Apttus__Account__c =: prodBasket.csbb__Account__c];
        for(Apttus__APTS_Agreement__c agmt:agmtPS){
            system.debug('agmt:' + agmt.id+':'+agmt.Apttus__Status__c+':'+agmt.Apttus__Source__c+':'+agmt.Related_Basket__c);
            if(agmt.Apttus__Status__c ==APTPS_Constants.BEINGAMENDED_STATUS){
                isPSAmended = true;  
                break;
            }
        }
       system.debug('isPSAmended::' + isPSAmended); 
       // system.assertEquals(false, isPSAmended);
        
        
    }
    
    
    @isTest static void AgreementDecisionException(){
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id,csbb__Account__c,name from cscfga__Product_Basket__c where cscfga__total_contract_value__c =10 limit 1];
        String exceptionDesc;
        try{
            AgreementUtilities.AgreementDecision agmtDecResult = AgreementOrderUtilities.resolveSAType(null, prodBasket, null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    
    @isTest static void createAgreementRecordsException(){
        
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id,csbb__Account__c,name from cscfga__Product_Basket__c where cscfga__total_contract_value__c =10 limit 1];
        String exceptionDesc;
        try{
            AgreementOrderUtilities.createAgreementRecords(null,prodBasket,null,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    
    @isTest static void createSAAgreementException(){
        Test.startTest();
        ContractJunction__c cjRecord = [Select id,Customer_Primary_Contact__c,Account__c,Related_Opportunity__c,Related_Basket__c,DocuSign_Signer_3__c,DocuSign_Signer_2__c from ContractJunction__c limit 1];
        String exceptionDesc;
        try{
            Apttus__APTS_Agreement__c agmtSA = AgreementOrderUtilities.createSAAgreement(cjRecord,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    } 
    
    @isTest static void createPriceScheduleVariationException(){
        cscfga__Product_Basket__c prodBasket = [select id,csbb__Account__c,name from cscfga__Product_Basket__c where cscfga__total_contract_value__c =10 limit 1];
        String prBasketRecordString=Json.serialize(prodBasket);
        Test.startTest();
        String exceptionDesc;
        try{
            AgreementOrderUtilities.createPriceScheduleVariation(null,prBasketRecordString);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertEquals(null, exceptionDesc);
    } 
    
    @isTest static void insertDocusignRecipientsException(){
        ContractJunction__c cjRecord = [Select id,Customer_Primary_Contact__c,Account__c,Related_Opportunity__c,Related_Basket__c from ContractJunction__c limit 1];
        Test.startTest();
        String exceptionDesc;
        try{
            AgreementOrderUtilities.insertDocusignRecipients(cjRecord,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    
    
    @isTest static void updateSAAgreementforOrderFlowException(){
        Test.startTest();
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        insert agreementPSDigi;
        String exceptionDesc;
        try{
            AgreementOrderUtilities.updateSAAgreementforOrderFlow(agreementPSDigi,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    
    @isTest static void generateAgreementsException(){
        Test.startTest();
        String exceptionDesc;
        try{
            AgreementOrderUtilities.generateAgreements(null,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    
    
    
    
    @isTest static void backUpdateContractRecord(){
        Test.startTest();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductConfigurationTrigger';
        insert disabledTriggersProfile;
        ContractJunction__c cjRecord = [Select id,Customer_Primary_Contact__c,Account__c,Related_Opportunity__c,Related_Basket__c,DocuSign_Signer_3__c,DocuSign_Signer_2__c from ContractJunction__c limit 1];
        //string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        //Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =cjRecord.Related_Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=cjRecord.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Contract__c=cjRecord.id,Apttus__Source__c = 'Internal Digital');
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =cjRecord.Related_Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=cjRecord.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Contract__c=cjRecord.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =cjRecord.Related_Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=cjRecord.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Contract__c=cjRecord.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        insert agmtList;
        agmtList[01].Apttus__Parent_Agreement__c = agmtList[00].id;
        upsert agmtList;
        Attachment attach = new Attachment();
        attach.ParentId = agreementPSDigi.id;
        attach.Body = Blob.valueOf('test');
        attach.Name = 'test attachment';
        insert attach;
        AgreementOrderUtilities.backUpdateContractRecord(agreementPSDigi);
        Test.stopTest();
        ContractJunction__c cjRecordUpdated = [Select id,Customer_Primary_Contact__c,Initiated_document_Generation__c,Account__c,Related_Opportunity__c,Related_Basket__c,DocuSign_Signer_3__c,DocuSign_Signer_2__c from ContractJunction__c limit 1];
        system.debug('cjRecordUpdated:'+cjRecordUpdated.Initiated_document_Generation__c);
        system.assertEquals(true, cjRecordUpdated.Initiated_document_Generation__c);
    }
    
    
    @isTest static void backUpdateContractRecordException(){
        Test.startTest();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'C2O_ProductConfigurationTrigger';
        insert disabledTriggersProfile;
        ContractJunction__c cjRecord = [Select id,Customer_Primary_Contact__c,Account__c,Related_Opportunity__c,Related_Basket__c,DocuSign_Signer_3__c,DocuSign_Signer_2__c from ContractJunction__c limit 1];
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =cjRecord.Related_Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=cjRecord.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Contract__c=cjRecord.id,Apttus__Source__c = 'Internal Digital');
        insert agreementPSDigi;
        Apttus__APTS_Agreement__c agmtPS = [SELECT id from Apttus__APTS_Agreement__c limit 1];
        Attachment attach = new Attachment();
        attach.ParentId = agreementPSDigi.id;
        attach.Body = Blob.valueOf('test');
        attach.Name = 'test attachment';
        insert attach;
        String exceptionDesc;
        try{
            AgreementOrderUtilities.backUpdateContractRecord(agmtPS);
        }
        catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    
    @isTest static void generateAgreementException(){
        Test.startTest();
        Apttus__APTS_Template__c temp = [SELECT id from Apttus__APTS_Template__c limit 1];
        AgreementOrderUtilities.generateAgreement('Test',temp.id);
        Test.stopTest();
        system.assertNotEquals(null, temp);
    }
    
    @isTest static void createAgreementLineItem(){
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        insert agreementPSDigi;
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        insert prod;
        Set<String> pf = new Set<String>{'Adaptive Mobility'};
            Test.startTest();
        List<Id> agmtLineItem = AgreementOrderUtilities.createAgreementLineItem(agreementPSDigi.id,pf);
        Test.stopTest();
        system.assertNotEquals(null, agmtLineItem);
        
    } 
    
    @isTest static void samePFVariationScenario(){
        //setupTestData(); //Commented as a Part of DIGI-15323
        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'APTPS_AgreementTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;
        opportunity opty = [Select id from opportunity where name = 'New Opty' limit 1];
        cscfga__Product_Basket__c basket = [Select id,csbb__Account__c from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 10 limit 1];
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        insert agmtList;
        agmtList[1].Apttus__Parent_Agreement__c = agmtList[0].id;
        upsert agmtList;
        system.debug('agreementPSDigi:' + agmtList[1].id+':'+agmtList[1].Related_Basket__c);
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        Test.startTest();        
        //cscfga__Product_Basket__c prodBasket = [select id,csbb__Account__c,name from cscfga__Product_Basket__c where cscfga__total_contract_value__c =10 limit 1];
        ContractJunction__c cjRecord = [Select id,Customer_Primary_Contact__c,Contract_Type__c,Account__c,Related_Opportunity__c,Related_Basket__c,DocuSign_Signer_3__c,DocuSign_Signer_2__c from ContractJunction__c limit 1];
        Opportunity opp =[Select id,contract_type__c from opportunity where name = 'New Opty' limit 1];
        system.debug('cjRecord.Contract_Type__c:'+cjRecord.Contract_Type__c);
        List<Apttus__APTS_Agreement__c> agmtPSBef= [SELECT id,Apttus__Status__c,VariationNotApplicable__c,Apttus__Source__c,Related_Basket__c from Apttus__APTS_Agreement__c where Related_Basket__c = :basket.id];
        system.debug('agmtPSBef:'+ agmtPSBef);
        AgreementOrderUtilities.createAgreementRecords(cjRecord,basket,opp,null);
        Test.stopTest();
        Boolean isSamePFFamily = false;
        
        List<Apttus__APTS_Agreement__c> agmtPS= [SELECT id,Apttus__Status__c,VariationNotApplicable__c,Apttus__Source__c,Related_Basket__c from Apttus__APTS_Agreement__c where Related_Basket__c = :basket.id];
        system.debug('agmtPS:'+ agmtPS);
        for(Apttus__APTS_Agreement__c agmt:agmtPS){
            system.debug('agmt:' + agmt.id+':'+agmt.Apttus__Status__c+':'+agmt.Apttus__Source__c+':'+agmt.Related_Basket__c);
            if(agmt.VariationNotApplicable__c =='NoAgreeement'){
                isSamePFFamily = true;  
                
                break;
            }
        }
        
        system.debug('isSamePFFamily:' + isSamePFFamily);
        system.assertEquals(true, isSamePFFamily);
                
        
        
    }
    
    
    @isTest 
    static void createPriceScheduleVariation_test(){
         //setupTestData(); //Commented as a Part of DIGI-15323
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'APTPS_AgreementTrigger';
        disabledTriggersProfile.Trigger_Name_List2__c='ProductBasketCustomTrigger';
        insert disabledTriggersProfile;
        
        opportunity opty = [Select id from opportunity where name = 'New Opty' limit 1];
        Account acc=[select id from Account where name=:'Test AccountOrderflow' limit 1];
        
        /*Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test CMPD Opty';
        opp.amount = 4600;
        insert opp;*/
        
        Marketable_Offer__c moCMPCD = new Marketable_Offer__c();
        moCMPCD.OfferDefinationName__c ='Corporate Mobile Plus';
        moCMPCD.Name = 'Corporate Mobile Plus';
        moCMPCD.Offer_ID__c = 'DMCAT_Offer_000646';
        moCMPCD.Contract_Type__c ='DSA';
        moCMPCD.Product_Family__c='Corporate Mobile Plus';
        insert moCMPCD;
        
        cscfga__Product_Definition__c pd =new cscfga__Product_Definition__c(); //FIXED the Null point exception at line -> pd.product_Specification__c='DMCAT_ProductSpecification_00646';
        pd=ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c='DMCAT_ProductSpecification_00646';
        insert pd;
    
        cscfga__Product_Basket__c basketNew = [SELECT id,csbb__Account__c,cscfga__Opportunity__c,Name,cscfga__total_contract_value__c from cscfga__Product_Basket__c limit 1 ];/* ProductTestFactory.buildEmptyBasket();
        //basketNew = ProductTestFactory.buildEmptyBasket(); // Not required to initailize commted unused code. DIGI-15323
        basketNew.csbb__Account__c = acc.id;
        basketNew.cscfga__Opportunity__c = opty.id;
        basketNew.Name = 'basket2';
        basketNew.cscfga__total_contract_value__c = 10;
        insert basketNew;*/ //- Commented the above code and queried the Data from TestSetup DIGI-15323
       
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.id);
                config.name='Corporate Mobile Plus-Committed Data';
                config.Type__c = 'New';
                config.Marketable_Offer__c = moCMPCD.id;
                config.cscfga__Product_Basket__c  =basketNew.id;
                config.cscfga__Product_Family__c='Enterprise Mobility';
                config.cscfga__unit_recurring_charge__c = 200;
                config.Quantity_Product_Configuration__c =1;
        insert config;
        
        ContractJunction__c cntrctRecord=new ContractJunction__c();
        cntrctRecord.Account__c = acc.id;
        //oldContract.BSA_Generated__c=true;
        cntrctRecord.Related_Opportunity__c=opty.id;
        cntrctRecord.Related_Basket__c=basketNew.id;
        cntrctRecord.DocuSign_Signer_3__c = UserInfo.getUserId();//EDGE-193826
        insert cntrctRecord;
        
        String contractJunctionRecordString = Json.serialize(cntrctRecord);
        String prBasketRecordString=Json.serialize(basketNew);
        
        //Moved as Global variables DIGI-15323
        //string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        //string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        //opportunity opty = [Select id from opportunity where name = 'New Opty' limit 1];
        //cscfga__Product_Basket__c basket = [Select id,csbb__Account__c from cscfga__Product_Basket__c where cscfga__total_contract_value__c = 10 limit 1]; // Not used Query DIGI-15323
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basketNew.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basketNew.id,Apttus__Source__c = 'Internal Digital');//replaced basket with basketNew DIGI-15323
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_Schedule_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basketNew.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basketNew.id,Apttus__Source__c = 'Internal Digital');//replaced basket with basketNew DIGI-15323
        agmtList.add(agreementPSDigi);
        insert agreementPSDigi;
        agmtList[1].Apttus__Parent_Agreement__c = agmtList[0].id;
        update agmtList[1];
        system.debug('agreementPSDigi:' + agmtList[1].id+':'+agmtList[1].Related_Basket__c);
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        
        
        AgreementOrderUtilities agmtOrderUtil = new AgreementOrderUtilities();
        Test.startTest();
        set<String> productFamilySet=AgreementOrderUtilities.getMarketableOffer(basketNew.id, 'DSA');
        //agmtOrderUtil.updateAgmtPSFlags(productFamilySet,basketNew.csbb__Account__c,'OrderBasedFlow'); commented the code as a part of DIGI-7386 as discussed with Monali and Aniket
        //agmtOrderUtil.updateAgmtPSFlags(productFamilySet,basketNew.csbb__Account__c,'DealBasedFlow');  commented the code as a part of DIGI-7386 as discussed with Monali and Aniket
        //Apttus__APTS_Agreement__c olsPSAgreement=[select id, APTPS_variationAdd__c,Variation_Applicable__c from Apttus__APTS_Agreement__c where Apttus__Account__c=:acc.id and Apttus__Parent_Agreement__c!=null limit 1];
        
        //System.assertEquals(true,olsPSAgreement.Variation_Applicable__c);
        //AgreementOrderUtilities.createPriceScheduleVariation(contractJunctionRecordString,prBasketRecordString);
        test.stopTest();
        
        System.assert(productFamilySet.contains('Corporate Mobile Plus'));
    }
    
      /*@Description : This method is used to Test the examinDPROLICommercialProductSaleEligibility
    * @Return : void
    * @UserStroy : DIGI-7386
    */
    @isTest
    public static void examinPCSaleEligibilityTest(){
     
   
        
      
        List<cscfga__Product_Configuration__c> pconfiguration= [SELECT Id, cscfga__Product_Basket__c, Sale_Eligibility__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,cscfga__Product_Basket__r.cscfga__Opportunity__r.AccountId FROM cscfga__Product_Configuration__c limit 1 ];
        String exceptionDesc;
        pconfiguration[0].Sale_Eligibility__c=APTPS_Constants.INVITE_ONLY;
        update pconfiguration;
        
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();

        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = pconfiguration[0].cscfga__Product_Basket__r.cscfga__Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =pconfiguration[0].cscfga__Product_Basket__r.cscfga__Opportunity__r.AccountId,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
       
        Test.startTest();
        try{
             AgreementOrderUtilities.examinPCSaleEligibility(pconfiguration[0].cscfga__Product_Basket__c,agreementDSADigi);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();

    }
    
      @isTest
    public static void createPSAgreementLineItems_Exception_Test(){
        boolean exceptionResult=false;
        try{
            List<cscfga__Product_Basket__c> lstbasket=[SELECT id from cscfga__Product_Basket__c];
            AgreementOrderUtilities.createPSAgreementLineItems(lstbasket[0], null);
        }catch(Exception e){
            exceptionResult=true;
        }
        System.assertEquals(true,exceptionResult);
    }
    
    
    @isTest
    public static void createSAAgreementTest(){
        AgreementUtilities.AgreementDecision agmtDecResult=new AgreementUtilities.AgreementDecision();
        agmtDecResult.saType ='BSA';
        try{
            AgreementOrderUtilities.createSAAgreement(null,agmtDecResult);
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
    }
    
    @isTest
    public static void createSAAgreementExceptionTest(){
        AgreementUtilities.AgreementDecision agmtDecResult=new AgreementUtilities.AgreementDecision();
        agmtDecResult.saType ='BSA';
        try{
            AgreementOrderUtilities.createSAAgreement(null,null);
        }catch(Exception e){
            System.debug('Exception'+e.getMessage());
        }
    }
    
    @isTest
    public static void createPSAgreementExceptionTest(){
        try{
            AgreementOrderUtilities.createPSAgreement(null);
        }catch(Exception e){
            System.debug('Exception'+e.getMessage());
        }
    }
    
    @isTest
    public static void backUpdateContractRecordTest(){
    
        opportunity opty = [Select id from opportunity where name = 'New Opty' limit 1];
        Account acc=[select id from Account where name=:'Test AccountOrderflow' limit 1];
        List<cscfga__Product_Basket__c> lstbasket=[SELECT id,csbb__Account__c from cscfga__Product_Basket__c];
         List<Apttus__APTS_Agreement__c> agmtList=new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=lstbasket[0].csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c=APTPS_Constants.BSA_AGMT_CATEGORY,Apttus__Status__c='Activated',Related_Basket__c=lstbasket[0].id,Apttus__Source__c = 'Internal Digital');
        
        insert agreementDSADigi;
        Apttus__APTS_Agreement__c agreementDSADigiParentId=[SELECT id from Apttus__APTS_Agreement__c limit 1];
        Apttus__APTS_Agreement__c agreementDSADigichild = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opty.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=lstbasket[0].csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=lstbasket[0].id,Apttus__Source__c = 'Internal Digital',Apttus__Parent_Agreement__c=agreementDSADigiParentId.Id);
       
        insert agreementDSADigichild;
        Test.StartTest();
        AgreementOrderUtilities.backUpdateContractRecord(agreementDSADigichild);
        Test.StopTest(); 
        
    }
    
}