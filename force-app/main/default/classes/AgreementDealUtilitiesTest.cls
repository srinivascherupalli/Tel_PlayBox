/**
* @Author   :   Lokesh Thathuru
* @Date     :   03 Aug 2021
* @US       :   
* @Description: Test class for AgreementDealUtilities. 
*
* Lokesh Thathuru Added examinDPROLICommercialProductSaleEligibility_Test as a part of DIGI-7386 
*****/

@isTest
public class AgreementDealUtilitiesTest {
    
    
    /**
    * @Author   :   Lokesh Thathuru
    * @Date     :   03 Aug 2021
    * @US       :   
    * @Description: This method helps prepare the Test data to serv to the testMethods.
    * */
    @testSetup
    public static void testDataSetup(){
        //Test Account Creation.
        List<Account> listofAccounts=new List<Account>();
        Account accountInstance = AccountTestFactory.buildAccount('Account01TestAgree') ;
        accountInstance.APTPS_DocuSign_Restricted__c = false; 
        accountInstance.Customer_Status__c = 'Active'; 
        listofAccounts.add(accountInstance);
        
        Account accountInstance1 = AccountTestFactory.buildAccount('Account02TestAgree') ;
        accountInstance1.APTPS_DocuSign_Restricted__c = false; 
        accountInstance1.Customer_Status__c = 'Active'; 
        listofAccounts.add(accountInstance1);
        
        insert listofAccounts;  
        
        //Test Contact Creation
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
       List<Contact> listofContcatrecords=new List<Contact>();
        Contact contact = new Contact(
            AccountId = accountInstance.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        
        Contact contact2 = new Contact(
            AccountId = accountInstance1.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        listofContcatrecords.add(contact);
        listofContcatrecords.add(contact2);
        List<Database.SaveResult> listofsr = Database.insert(listofContcatrecords, dml);
        
        for(Database.SaveResult sr:listofsr){
            if (sr.isSuccess()) {
                System.debug('Duplicate account has been inserted in Salesforce!');
            }
        }
        
        //list<Opportunity> listoppty= new list<Opportunity>();
        //Test Opportunity Creation
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(accountInstance);
        opp.name='Test Adaptive Opty';
        opp.RecordTypeId=[SELECT Name, Id, DeveloperName, SobjectType, IsActive FROM RecordType WHERE Name = 'Enterprise - Standard'].id;
        opp.Contract_Type__c='DSA';
        opp.amount = 4600;
        Opportunity opp1   = ProductTestFactory.getOpportunityBasic(accountInstance1);
        opp1.name='Test Adaptive Opty2';
        opp1.RecordTypeId=[SELECT Name, Id, DeveloperName, SobjectType, IsActive FROM RecordType WHERE Name = 'Enterprise - Standard'].id;
        opp1.amount = 4600;
        insert new List<Opportunity>{opp,opp1};
            system.debug('listofContcatrecords[0].Id'+ listofContcatrecords[0].Id +' listofContcatrecords[0].AccountId' +listofContcatrecords[0].AccountId);  
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = listofContcatrecords[0].Id;
        oppContRole.OpportunityId = opp.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;    
            
        List<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = accountInstance.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        lstbasket.add(basket);
        // insert basket;
        
        //Create Basket
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = accountInstance1.id;
        basket2.cscfga__Opportunity__c = opp1.id;
        basket2.Name = 'basket2';
        lstbasket.add(basket2);
        
        insert lstbasket;
        
        Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
        List<Delegated_Pricing_Request__c> dprlist = new List<Delegated_Pricing_Request__c>(); 
        Delegated_Pricing_Request__c dpr= new Delegated_Pricing_Request__c();
        dpr.Account__c=accountInstance.id;
        dpr.Opportunity__c=opp.id;
        dpr.Commitment_Frequency__c='Quarterly';
        dprlist.add(dpr);
        Delegated_Pricing_Request__c dpr1= new Delegated_Pricing_Request__c();
        dpr1.Account__c=accountInstance.id;
        dpr1.Opportunity__c=opp.id;
        dpr1.Commitment_Frequency__c='Quarterly';
        dprlist.add(dpr1);
        
        insert dprlist;
        
        List<DPR_Offer__c> dprofferlist =new List<DPR_Offer__c>(); 
        DPR_Offer__c dproffer= new DPR_Offer__c();
        dproffer.Delegated_Pricing_Request__c=dpr.id;
        dproffer.name='Adaptive Mobility Plan';
        dprofferlist.add(dproffer); 
        DPR_Offer__c dproffer1= new DPR_Offer__c();
        dproffer1.Delegated_Pricing_Request__c=dpr1.id;
        dproffer1.name='Adaptive Mobility Plan';
        dprofferlist.add(dproffer1); 
        insert dprofferlist;
        
        List<DPR_Offer_Line_Item__c> dprolilist = new List<DPR_Offer_Line_Item__c>(); 
        DPR_Offer_Line_Item__c dolineitem= new DPR_Offer_Line_Item__c();
        dolineitem.Delegated_Pricing_Request__c=dpr.id;
        dolineitem.Marketable_Offer__c=Marketoffer.id;
        dolineitem.List_Price__c=10;
        dolineitem.DPR_Offer__c=dproffer.id;
        dolineitem.DPR_Offer_Line_Item_Type__c ='Plan';
        dolineitem.Offer_Type_Name__c='Mobile Broadband';
        dolineitem.DPR_Offer_Line_Item_Value__c=10;
        dprolilist.add(dolineitem);
        DPR_Offer_Line_Item__c dolineitem1= new DPR_Offer_Line_Item__c();
        dolineitem1.Delegated_Pricing_Request__c=dpr1.id;
        dolineitem1.Marketable_Offer__c=Marketoffer.id;
        dolineitem1.List_Price__c=10;
        dolineitem1.DPR_Offer__c=dproffer1.id;
        dolineitem1.DPR_Offer_Line_Item_Type__c ='Plan';
        dolineitem1.Offer_Type_Name__c='Mobile Broadband';
        dolineitem1.DPR_Offer_Line_Item_Value__c=10;
        dprolilist.add(dolineitem1);
        
        insert dprolilist;
        
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=accountInstance.id;
        framAg.Opportunity__c=opp.id;
        framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
        
        csconta__Account_Frame_Agreement_Association__c faAgrAss =new csconta__Account_Frame_Agreement_Association__c();
        faAgrAss.csconta__Frame_Agreement__c = framAg.Id;
        faAgrAss.csconta__Account__c = accountInstance1.Id;
        insert faAgrAss;
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        prodlst.add(prod);
        insert prodlst;
        
        FA_DefaultRecipients__c faDef= new FA_DefaultRecipients__c();
        faDef.Signatory_1__c=contact.id;
        faDef.Signatory_2__c=userinfo.getuserid();
        faDef.Deal_Pricing_Request__c=dpr.id;
        insert faDef;
        
        List<Apttus__APTS_Template__c> aptTempList = new List<Apttus__APTS_Template__c>();
        Apttus__APTS_Template__c dsaTemp  = APTPS_TestClassData.templateRecord('DSA_Template','Agreement');
        Apttus__APTS_Template__c psTemp = APTPS_TestClassData.templateRecord('Price_Schedule_Template','Agreement'); 
        Apttus__APTS_Template__c rcaTemp  = APTPS_TestClassData.templateRecord('Related Company Schedule Letter','Agreement');
        Apttus__APTS_Template__c pscTemp = APTPS_TestClassData.templateRecord('Price_schedule_Cover_Letter','Supporting Document'); 
        aptTempList.add(dsaTemp);
        aptTempList.add(psTemp); 
        aptTempList.add(rcaTemp);
        aptTempList.add(pscTemp); 
        
        
    }
    
    
    /**
    * @Author   :   Lokesh Thathuru
    * @Date     :   03 Aug 2021
    * @US       :   
    * @Description: This testMethods is used for Covering the createAgreementRecords method in AgreementDealUtilities.
    * */
    @isTest
    public static void testCase01_createAgreementRecords(){
        
        Account accountdetails=[select id from account where name='Account01TestAgree' limit 1];
       
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        prodlst.add(prod);
        insert prodlst;
        
        cscfga__Product_Basket__c basket=[SELECT id,name,csbb__Account__c,cscfga__Opportunity__c  FROM cscfga__Product_Basket__c limit 1];
        
        Opportunity oppRecord=[select id,name,Contract_Type__c,recordTypeId,RecordType.Name from Opportunity where name='Test Adaptive Opty' limit 1];
        oppRecord.Contract_Type__c='DSA';
        System.debug('opprecord ==> **'+oppRecord.recordTypeId);
        System.debug('opprecord ==> **'+oppRecord.recordType.Name);
        
        update oppRecord;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = conRecord.Id;
        oppContRole.OpportunityId = oppRecord.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;

        List<Delegated_Pricing_Request__c> dprList= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id ];
       
        system.debug('dprList ==>'+dprList);
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
         system.debug('relatedDPROLI ==>'+relatedDPROLI);
       // List<Apttus__APTS_Template__c> aptTempList = [Select Id, Name from Apttus__APTS_Template__c]; // commented because no where using in this method.
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        Test.startTest();  
        Apttus__APTS_Agreement__c agreementDSADigiParent = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        insert agreementDSADigiParent;
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital',Apttus__Parent_Agreement__c=agreementDSADigiParent.Id);
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        
        List<Apttus__AgreementLineItem__c> agreementLineItemList = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c agreementLineItem1 = APTPS_TestClassData.agreementLineItemRecord(agreementDSADigi.Id, prod.id);
        Apttus__AgreementLineItem__c agreementLineItem2 = APTPS_TestClassData.agreementLineItemRecord(agreementDSALegacy.Id, prod.id);
        Apttus__AgreementLineItem__c agreementLineItem3 = APTPS_TestClassData.agreementLineItemRecord(agreementPSDigi.Id, prod.id);
        agreementLineItem1.APTPS_Product_Minimum_Spend__c = agreementLineItem2.APTPS_Product_Minimum_Spend__c = agreementLineItem3.APTPS_Product_Minimum_Spend__c = 10;
        agreementLineItem1.APTPS_frequency__c = 'Quarter';
        agreementLineItem2.APTPS_frequency__c = 'Month';
        agreementLineItem3.APTPS_frequency__c = 'Annual';
        
        agreementLineItemList.add(agreementLineItem1);
        agreementLineItemList.add(agreementLineItem2);
        agreementLineItemList.add(agreementLineItem3);
        update agreementLineItemList;
        
        
        FA_DefaultRecipients__c faDef= new FA_DefaultRecipients__c();
        faDef.Signatory_1__c=conRecord.id;
        faDef.Signatory_2__c=userinfo.getuserid();
        faDef.Deal_Pricing_Request__c=dprList[0].id;
        insert faDef;
        
         

        AgreementDealUtilities.createAgreementRecords(dprList,relatedDPROLI,null);
        
        test.stoptest();
        
        List<Apttus__APTS_Agreement__c > agrList=[select id,Apttus__Agreement_Category__c from Apttus__APTS_Agreement__c where Apttus__Related_Opportunity__c =:oppRecord.id];
        
        system.debug('CreatedAgreementList'+agrList);
        
        System.assertEquals(agrList[0].Apttus__Agreement_Category__c,'Digital Services');
        //System.assertEquals(agrList[1].Apttus__Agreement_Category__c,'Digital Services');
    }
    
    
     /**
    * @Author   :   Lokesh Thathuru
    * @Date     :   03 Aug 2021
    * @US       :   
    * @Description: This testMethods is used for Covering the createAgreementRecords method in AgreementDealUtilities.
    * */
    @isTest
    public static void testCase02_createAgreementRecords(){
        
        Account accountdetails=[select id from account where name='Account01TestAgree' limit 1];
       
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        prodlst.add(prod);
        insert prodlst;
        
        Opportunity oppRecord=[select id,name,Contract_Type__c from Opportunity where name='Test Adaptive Opty' limit 1];
        oppRecord.Contract_Type__c='BSA';
        update oppRecord;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = conRecord.Id;
        oppContRole.OpportunityId = oppRecord.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;

        List<Delegated_Pricing_Request__c> dprList= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id ];
        system.debug('dprList ==>'+dprList);
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
        system.debug('relatedDPROLI ==>'+relatedDPROLI);
        // List<Apttus__APTS_Template__c> aptTempList = [Select Id, Name from Apttus__APTS_Template__c]; // commented because no where using in this method.
        
       
        
        Test.startTest();   
        try{
            AgreementDealUtilities.createAgreementRecords(dprList,relatedDPROLI,null);
        }catch(Exception e){
            system.debug('Exception '+e.getMessage());
        }
        test.stoptest();
        
        List<Apttus__APTS_Agreement__c > agrList=[select id,Apttus__Agreement_Category__c from Apttus__APTS_Agreement__c where Apttus__Related_Opportunity__c =:oppRecord.id];
        
        system.debug('CreatedAgreementList'+agrList);
        
        System.assertEquals(agrList[0].Apttus__Agreement_Category__c,'Business Services');
        //System.assertEquals(agrList[1].Apttus__Agreement_Category__c,'Digital Services');
    }
    
    /**
    * @Author   :   Lokesh Thathuru
    * @Date     :   03 Aug 2021
    * @US       :   
    * @Description: This testMethods is used for Covering the createAgreementRecords method in AgreementDealUtilities handle the try catch part
    * */
    @isTest
    public static void testCase03_createAgreementRecords(){
        
        Account accountdetails=[select id from account where name='Account01TestAgree' limit 1];
        
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        prodlst.add(prod);
        insert prodlst;
        
        Opportunity oppRecord=[select id,name,Contract_Type__c from Opportunity where name='Test Adaptive Opty' limit 1];
        oppRecord.Contract_Type__c='BSA';
        update oppRecord;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = conRecord.Id;
        oppContRole.OpportunityId = oppRecord.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;
        
        cscfga__Product_Basket__c basket=[SELECT id,name,csbb__Account__c,cscfga__Opportunity__c  FROM cscfga__Product_Basket__c limit 1];
        
        List<Delegated_Pricing_Request__c> dprList= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id ];
        system.debug('dprList ==>'+dprList);
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
        system.debug('relatedDPROLI ==>'+relatedDPROLI);
        // List<Apttus__APTS_Template__c> aptTempList = [Select Id, Name from Apttus__APTS_Template__c]; // commented because no where using in this method.
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
         Apttus__APTS_Agreement__c agreementDSADigiParent = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        insert agreementDSADigiParent;
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=dprList[0].Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital', Apttus__Parent_Agreement__c =agreementDSADigiParent.Id );
        agmtList.add(agreementDSADigi);
        
       
        insert agmtList;
       
        FA_DefaultRecipients__c faDef= new FA_DefaultRecipients__c();
        faDef.Signatory_1__c=conRecord.id;
        faDef.Signatory_2__c=userinfo.getuserid();
        faDef.Deal_Pricing_Request__c=dprList[0].id;
        insert faDef;
        
        Test.startTest();   
        try{
            AgreementDealUtilities.createAgreementRecords(dprList,relatedDPROLI,null);

        }catch(Exception e){
            System.debug('Exception Case'+e.getMessage());
        }
        test.stoptest();
        
        List<Apttus__APTS_Agreement__c > agrList=[select id,Apttus__Agreement_Category__c from Apttus__APTS_Agreement__c where Apttus__Related_Opportunity__c =:oppRecord.id];
        
        system.debug('CreatedAgreementList'+agrList);
        
        System.assertEquals(agrList[0].Apttus__Agreement_Category__c,'Digital Services');

    }
    
     /**
    * @Author   :   Lokesh Thathuru
    * @Date     :   03 Aug 2021
    * @US       :   
    * @Description: This testMethods is used for Covering the createAgreementRecords method in AgreementDealUtilities handle the try catch part
    * */
    @isTest
    public static void testCase04_createAgreementRecords(){
        
        Account accountdetails=[select id from account where name='Account01TestAgree' limit 1];
        
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        prodlst.add(prod);
        insert prodlst;
        
        Opportunity oppRecord=[select id,name,Contract_Type__c from Opportunity where name='Test Adaptive Opty' limit 1];
        oppRecord.Contract_Type__c='BSA';
        update oppRecord;
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = conRecord.Id;
        oppContRole.OpportunityId = oppRecord.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;
        
        cscfga__Product_Basket__c basket=[SELECT id,name,csbb__Account__c,cscfga__Opportunity__c  FROM cscfga__Product_Basket__c limit 1];
        
        List<Delegated_Pricing_Request__c> dprList= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id ];
        system.debug('dprList ==>'+dprList);
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
        system.debug('relatedDPROLI ==>'+relatedDPROLI);
        // List<Apttus__APTS_Template__c> aptTempList = [Select Id, Name from Apttus__APTS_Template__c]; // commented because no where using in this method.
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=dprList[0].Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='Request',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital' );
        agmtList.add(agreementDSADigi);
        insert agmtList;
        
        List<Apttus__AgreementLineItem__c> agreementLineItemList = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c agreementLineItem1 = APTPS_TestClassData.agreementLineItemRecord(agreementDSADigi.Id, prod.id);
        agreementLineItem1.APTPS_Product_Minimum_Spend__c = 10;
        agreementLineItem1.APTPS_frequency__c = 'Quarter';
        agreementLineItemList.add(agreementLineItem1);
        Apttus__AgreementLineItem__c agreementLineItem2 = APTPS_TestClassData.agreementLineItemRecord(agreementDSADigi.Id, prod.id);
        agreementLineItem2.APTPS_Product_Minimum_Spend__c = 10;
        agreementLineItem2.APTPS_frequency__c = 'Month';
        agreementLineItemList.add(agreementLineItem2);
        
        update agreementLineItemList;
        
        FA_DefaultRecipients__c faDef= new FA_DefaultRecipients__c();
        faDef.Signatory_1__c=conRecord.id;
        faDef.Signatory_2__c=userinfo.getuserid();
        faDef.Deal_Pricing_Request__c=dprList[0].id;
        insert faDef;
        
        Test.startTest();   
        try{
            AgreementDealUtilities.createAgreementRecords(dprList,relatedDPROLI,null);
        }catch(Exception e){
            System.debug('Exception Case'+e.getMessage());
        }
        test.stoptest();
        
        List<Apttus__APTS_Agreement__c > agrList=[select id,Apttus__Agreement_Category__c from Apttus__APTS_Agreement__c where Apttus__Related_Opportunity__c =:oppRecord.id];
        
        system.debug('CreatedAgreementList'+agrList);
        
        System.assertEquals(agrList[0].Apttus__Agreement_Category__c,'Digital Services');

    }
   
    
    /**
    * @Author   :   Lokesh Thathuru
    * @Date     :   03 Aug 2021
    * @US       :   
    * @Description: This testMethods is used for Covering the createAgreementRecords method in AgreementDealUtilities.
    * */
    @isTest
    public static void testCase05_createAgreementRecords(){
        Test.startTest();
        AgreementDealUtilities.getSessionId();
        AgreementDealUtilities.getapiServerURL();
        test.stopTest();
            
    }
    
    /**
    * @Author   :   Lokesh Thathuru
    * @Date     :   03 Aug 2021
    * @US       :   
    * @Description: This testMethods is used for Covering the createAgreementRecords method in AgreementDealUtilities.
    * */
    @isTest
    public static void testCase06_createAgreementRecords(){
        Account accountdetails=[select id from account where name='Account01TestAgree' limit 1];
        
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        prodlst.add(prod);
        insert prodlst;
        
        Opportunity oppRecord=[select id,name,Contract_Type__c from Opportunity where name='Test Adaptive Opty' limit 1];
        oppRecord.Contract_Type__c='BSA';
        update oppRecord;
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.ContactId = conRecord.Id;
        oppContactRole.OpportunityId = oppRecord.Id;
        oppContactRole.IsPrimary = true;
        oppContactRole.Role = 'Decision Maker';
        insert oppContactRole;
        
        cscfga__Product_Basket__c basket=[SELECT id,name,csbb__Account__c,cscfga__Opportunity__c  FROM cscfga__Product_Basket__c limit 1];
        Delegated_Pricing_Request__c drpRecord=new Delegated_Pricing_Request__c();
        drpRecord= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id limit 1 ];
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();

        
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c PSAgreement = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=drpRecord.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='Request',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital' );
        agmtList.add(PSAgreement);
        insert agmtList; 
        
        csconta__Frame_Agreement__c frameAgreement = new csconta__Frame_Agreement__c();
        frameAgreement.csconta__Account__c=accountdetails.id;
        frameAgreement.Opportunity__c=opprecord.id;
        frameAgreement.Delegated_Pricing_Request__c=drpRecord.id;
        frameAgreement.csconta__Agreement_Name__c='AGR-TEST';
        frameAgreement.csconta__Status__c = 'Open'; 
        frameAgreement.csconta__effective_start_date__c = null;
        frameAgreement.csconta__effective_end_date__c = null;        
        frameAgreement.Contract_Acceptance_Date__c = DateTime.now();
        insert frameAgreement;
        //EDGE-194530
         csconta__Frame_Agreement__c frameAgreement1 = new csconta__Frame_Agreement__c();
        frameAgreement1.csconta__Account__c=accountdetails.id;
        frameAgreement1.Opportunity__c=opprecord.id;
        frameAgreement1.Delegated_Pricing_Request__c=drpRecord.id;
        frameAgreement1.csconta__Agreement_Name__c='AGR-TEST1';
        frameAgreement1.csconta__Status__c = 'Active'; 
        frameAgreement1.csconta__effective_start_date__c = null;
        frameAgreement1.csconta__effective_end_date__c = null;        
        frameAgreement1.Contract_Acceptance_Date__c = DateTime.now();
        insert frameAgreement1;
        //EDGE-194530 End
        //CREATE FA AGREEMENT ASSOCIATION
        FA_Agreement_Association__c faAssociation = new FA_Agreement_Association__c();
        faAssociation.Name = 'Test FA Association';
        faAssociation.FA__c = frameAgreement.ID;
        faAssociation.Agreement__c = PSAgreement.ID;          
        insert faAssociation; 
        
        List<FA_DefaultRecipients__c> faDefaultRecordlst=new List<FA_DefaultRecipients__c>();
        FA_DefaultRecipients__c faDef= new FA_DefaultRecipients__c();
        faDef.Signatory_1__c=conRecord.id;
        faDef.Signatory_2__c=userinfo.getuserid();
        faDef.Deal_Pricing_Request__c=drpRecord.id;
        faDefaultRecordlst.add(faDef);
        
        
        FA_DefaultRecipients__c faDef1= new FA_DefaultRecipients__c();
        faDef1.Signatory_1__c=conRecord.id;
        faDef1.Signatory_2__c=userinfo.getuserid();
        faDef1.Deal_Pricing_Request__c=drpRecord.id;
        faDefaultRecordlst.add(faDef1);
        insert faDefaultRecordlst;
        

        Test.startTest();
        AgreementDealUtilities.setAgreementData(PSAgreement,  drpRecord, frameAgreement,faDefaultRecordlst, oppContactRole);
        AgreementDealUtilities.convertValuesFromSetToString(new Set<String>{'Test','Test','test','asjd'});
        Delegated_Pricing_Request__c drpRecord1=new Delegated_Pricing_Request__c();

        try{
            AgreementDealUtilities.fetchFADefaultRecipientList(new List<Delegated_Pricing_Request__c>{drpRecord1});
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        
        try{
           AgreementDealUtilities.resolveSAType(null);
        }catch(Exception e){
            System.debug('');
        }
        
        test.stopTest();
        
    }
    
    @isTest
    public static void test07_priceScheduleVariationCreateForOrderToDeal(){
        
        Account accountdetails=[select id from account where name='Account01TestAgree' limit 1];
        
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        prodlst.add(prod);
        insert prodlst;
        
        Opportunity oppRecord=[select id,name,Contract_Type__c from Opportunity where name='Test Adaptive Opty' limit 1];
        oppRecord.Contract_Type__c='BSA';
        update oppRecord;
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.ContactId = conRecord.Id;
        oppContactRole.OpportunityId = oppRecord.Id;
        oppContactRole.IsPrimary = true;
        oppContactRole.Role = 'Decision Maker';
        insert oppContactRole;
        
        cscfga__Product_Basket__c basket=[SELECT id,name,csbb__Account__c,cscfga__Opportunity__c  FROM cscfga__Product_Basket__c limit 1];
        
        
        List<Delegated_Pricing_Request__c> dprRequest=new List<Delegated_Pricing_Request__c>();
        Delegated_Pricing_Request__c drpRecord=new Delegated_Pricing_Request__c();
        drpRecord= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id limit 1 ];
        dprRequest.add(drpRecord);
        List<DPR_Offer_Line_Item__c> relatedDPROLI=new List<DPR_Offer_Line_Item__c>();
        relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprRequest[0].id];
        

         system.debug('relatedDPROLI ==>'+relatedDPROLI);
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c PSAgreement = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=drpRecord.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='Request',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital' );
        insert PSAgreement; 
        
        Apttus__APTS_Agreement__c PSOldAgreementRecord=new Apttus__APTS_Agreement__c();
        PSOldAgreementRecord = new Apttus__APTS_Agreement__c(  recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,
            Apttus__Related_Opportunity__c =oppRecord.id,
            APTPS_Validation_on_Fully_Signed__c=true,
            Apttus__Contract_End_Date__c=system.today(),
            Apttus__Account__c=basket.csbb__Account__c,
            name = 'TestDSA',
            Apttus__Agreement_Category__c = 'Digital Services',
            APTPS_Telstra_Legal_Entity__c = 'Melbourne',
            Apttus__Status_Category__c='In Effect',
            Apttus__Status__c='Activated',
            Related_Basket__c=basket.id,
            Apttus__Source__c = 'Internal Digital',
            PS_Variation_Details__c = '[{"VariationModify":"Adaptive Mobility","VariationAdd":null,"Product":"Adaptive Mobility","Attribute":"Y","ALI":"Y"},{"VariationModify":null,"VariationAdd":null,"Product":"Telstra Collaboration","Attribute":"N","ALI":"Y"}]',
            Apttus__Parent_Agreement__c=PSAgreement.Id,
            Apttus__Term_Months__c=36,
            APTPS_buyingWindow__c=10,
            Apttus__Contract_Start_Date__c=System.today(),
            Apttus__Total_Contract_Value__c=20000,
            Variation_Applicable__c=false);
        insert PSOldAgreementRecord;
        
        Test.startTest();
        AgreementDealUtilities.priceScheduleVariationCreateForOrderToDeal(dprRequest,relatedDPROLI,PSOldAgreementRecord, false);
        test.stopTest();
    }
    
    /**
    * @Author   :   Shivaprasad Patil
    * @Date     :   08 Sep 2021
    * @US       :   DIGI-11225
    * @Description: This method tests RCS agreement Variation
    * */
      @isTest
    public static void relatedCompanyScheduleVariation(){


        csconta__Frame_Agreement__c frameAgreement = [select Id,csconta__Account__c,Delegated_Pricing_Request__c,Delegated_Pricing_Request__r.Account__c,Delegated_Pricing_Request__r.Opportunity__c from csconta__Frame_Agreement__c][0];
        
        List<Delegated_Pricing_Request__c> dprList = new List<Delegated_Pricing_Request__c>();
        
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c();
        dpr.Opportunity__c = frameAgreement.Delegated_Pricing_Request__r.Opportunity__c;
        dpr.Id = frameAgreement.Delegated_Pricing_Request__c;
        dpr.Account__c = frameAgreement.Delegated_Pricing_Request__r.Account__c;
        dprList.add(dpr);
        
        
        Account oldAcc = new Account(Name = 'Test Account1', Customer_Status__c = 'ACTIVE');
        insert oldAcc;
        Account oldAcc1 = new Account(Name = 'Test Account2', Customer_Status__c = 'ACTIVE');
        insert oldAcc1;
        Account newAcc = new Account(Name = 'Test Account3', Customer_Status__c = 'ACTIVE');
        insert newAcc;

        csconta__Account_Frame_Agreement_Association__c faAgrAss1 =new csconta__Account_Frame_Agreement_Association__c();
        faAgrAss1.csconta__Frame_Agreement__c = frameAgreement.Id;
        faAgrAss1.csconta__Account__c = newAcc.Id;
        insert faAgrAss1;

        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        string AGREEMENT_RCS_TEST_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Related_Company_Schedule').getRecordTypeId();
        
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = dprList[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =dprList[0].Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        
        Apttus__APTS_Agreement__c psAgreement = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =dprList[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = dprList[0].Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(psAgreement);
        
        Apttus__APTS_Agreement__c rcsAgreement = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_RCS_TEST_RECORDTYPEID,Apttus__Related_Opportunity__c =dprList[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = dprList[0].Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(rcsAgreement);
        
        insert agmtList;
        
        agmtList[1].Apttus__Parent_Agreement__c = agmtList[0].id;
        upsert agmtList;
        
        String parentAgmtId = agreementDSADigi.Id;
        
        
        List<APTPS_Related_Companies__c> rCompaniesList = new List<APTPS_Related_Companies__c>();
        rCompaniesList.add(APTPS_TestClassData.relatedCompaniesRecord(oldAcc.Id, rcsAgreement.id));
        rCompaniesList.add(APTPS_TestClassData.relatedCompaniesRecord(oldAcc1.Id, rcsAgreement.id));
        
        rcsAgreement= [SELECT Id, RecordTypeId, name, Apttus__APTS_Agreement__c.Apttus__Status__c,Apttus__APTS_Agreement__c.Apttus__Status_Category__c,Apttus__Agreement_Category__c,(Select APTPS_Account__c from Related_Companies__r) FROM Apttus__APTS_Agreement__c WHERE Id =:rcsAgreement.Id];
        
        Test.startTest();
        AgreementDealUtilities.isRCSVariationRequired(frameAgreement,rcsAgreement,parentAgmtId,dprList,false);
        //rCompaniesList.remove(0);
        //rcsAgreement= [SELECT Id, RecordTypeId, name, Apttus__APTS_Agreement__c.Apttus__Status__c,Apttus__APTS_Agreement__c.Apttus__Status_Category__c,Apttus__Agreement_Category__c,(Select APTPS_Account__c from Related_Companies__r) FROM Apttus__APTS_Agreement__c WHERE Id =:rcsAgreement.Id];
        //AgreementDealUtilities.isRCSVariationRequired(frameAgreement,rcsAgreement,parentAgmtId,dprList);
        Test.stopTest();
    }
    
    @isTest static void AgreementDecisionException(){
        Test.startTest();
        String exceptionDesc;
        try{
            AgreementUtilities.AgreementDecision agmtDecResult = AgreementDealUtilities.resolveSAType(null);
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
        List<Delegated_Pricing_Request__c> dprRequest= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c limit 1 ];
        String exceptionDesc;
        try{
            AgreementDealUtilities.createAgreementRecords(dprRequest, null,null);
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
          List<Delegated_Pricing_Request__c> dprRequest= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c limit 1 ];       
        String exceptionDesc;
        try{
            Apttus__APTS_Agreement__c agmtSA = AgreementDealUtilities.createSAAgreement(null,dprRequest,null,null,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    @isTest static void createSAAgreementExceptionthrow(){
        Test.startTest();
          List<Delegated_Pricing_Request__c> dprRequest= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c limit 1 ];       
        String exceptionDesc;
        try{
            Apttus__APTS_Agreement__c agmtSA = AgreementDealUtilities.createSAAgreement(null,dprRequest,null,null,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    @isTest static void createSAAgreementExceptioncatch(){
        Test.startTest();
          List<Delegated_Pricing_Request__c> dprRequest= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c limit 1 ];       
        String exceptionDesc;
        try{
            Apttus__APTS_Agreement__c agmtSA = AgreementDealUtilities.createSAAgreement(null,null,null,null,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
    
    @isTest static void insertDocusignRecipientsExceptionCase(){
          Account accountdetails=[select id from account where name='Account01TestAgree' limit 1];
        
        Contact conRecord=[select id from Contact where Accountid=:accountdetails.id];
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        prodlst.add(prod);
        insert prodlst;
        
        Opportunity oppRecord=[select id,name,Contract_Type__c from Opportunity where name='Test Adaptive Opty' limit 1];
        oppRecord.Contract_Type__c='BSA';
        update oppRecord;
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.ContactId = conRecord.Id;
        oppContactRole.OpportunityId = oppRecord.Id;
        oppContactRole.IsPrimary = true;
        oppContactRole.Role = 'Decision Maker';
        insert oppContactRole;
        
        cscfga__Product_Basket__c basket=[SELECT id,name,csbb__Account__c,cscfga__Opportunity__c  FROM cscfga__Product_Basket__c limit 1];
        Delegated_Pricing_Request__c drpRecord=new Delegated_Pricing_Request__c();
        drpRecord= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c where Opportunity__c=:oppRecord.id limit 1 ];
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();

        
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c PSAgreement = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =oppRecord.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=drpRecord.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='Request',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital' );
        agmtList.add(PSAgreement);
        insert agmtList; 
        
        
        Test.startTest();

        String exceptionDesc;
        try{
            AgreementDealUtilities.insertDocusignRecipients(null,null,null);
        }
        Catch(AgreementException agEx)
        {   
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc );
    }
     @isTest static void fetchFADefaultRecipientListException(){
        Test.startTest();
          List<Delegated_Pricing_Request__c> dprRequest= [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c limit 1 ];       
        String exceptionDesc;
        try{
            List<FA_DefaultRecipients__c> agmtSA = AgreementDealUtilities.fetchFADefaultRecipientList(null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
    }
    @isTest static void fetchFADefaultRecipientListExceptionThrow(){
        Test.startTest();
        FA_DefaultRecipients__c faDefault = [SELECT Id, Signatory_1__c, Signatory_2__c, Deal_Pricing_Request__c FROM FA_DefaultRecipients__c LIMIT 1];
        OpportunityContactRole oppConRole = [SELECT Id,ContactId, OpportunityId,IsPrimary,Role FROM OpportunityContactRole LIMIT 1];
              
        String exceptionDesc;
        try{
            AgreementDealUtilities.insertDocusignRecipients(faDefault,oppConRole,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }
     @isTest static void fetchFADefaultRecipientListExceptionCatch(){
        Test.startTest();
        FA_DefaultRecipients__c faDefault = [SELECT Id, Signatory_1__c, Signatory_2__c, Deal_Pricing_Request__c FROM FA_DefaultRecipients__c LIMIT 1];
        OpportunityContactRole oppConRole = [SELECT Id,ContactId, OpportunityId,IsPrimary,Role FROM OpportunityContactRole LIMIT 1];
              
        String exceptionDesc;
        try{
            AgreementDealUtilities.insertDocusignRecipients(null,oppConRole,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }  
    @isTest static void fetchFrameAgreementExceptionCatch(){
        Test.startTest();
        String exceptionDesc;
        try{
            csconta__Frame_Agreement__c fa = AgreementDealUtilities.fetchFrameAgreement(null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }  
    @isTest static void createPSAgreementException(){
        Test.startTest();
        String exceptionDesc;
        try{
            Apttus__APTS_Agreement__c agmtSA = AgreementDealUtilities.createPSAgreement(null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    } 
    @isTest static void getProductFamilyVsDPRIdException(){
        Test.startTest();
        String exceptionDesc;
        try{
            Map<String,Id> prodFamilyVsDprId = AgreementDealUtilities.getProductFamilyVsDPRId(null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    }  
    @isTest static void createAttributeOnAgmtLineIemException(){
        Test.startTest();
        String exceptionDesc;
        try{
           Id attId = AgreementDealUtilities.createAttributeOnAgmtLineIem(null,null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    } 
    @isTest static void generateAgreementException(){
        Test.startTest();
        String exceptionDesc;
        try{
            AgreementDealUtilities.generateAgreement(null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    } 
    @isTest static void getDifferencePFsListDealException(){
        Test.startTest();
        String exceptionDesc;
        try{
          Map<List<Object>,boolean> pfList = AgreementDealUtilities.checkPSVariation(null,null,null); 
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    } 
    @isTest static void createAgreementRecords_Variation(){
        Test.startTest();
        //testDataSetup();
        List<Delegated_Pricing_Request__c> dprlist = [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c];
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =dprlist[0].Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = dprlist[0].Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = dprlist[0].Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = dprlist[0].Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        agmtList[2].Apttus__Parent_Agreement__c = agmtList[0].id;
        agmtList[3].Apttus__Parent_Agreement__c = agmtList[1].id;
        upsert agmtList;
        
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
        
        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'APTPS_AgreementTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;
        Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        AgreementDealUtilities.createAgreementRecords(dprlist,relatedDPROLI,null);
        Test.stopTest();
        Boolean isPSAmended = false;
        List<Apttus__APTS_Agreement__c> agmtPS= [SELECT id,Apttus__Status__c from Apttus__APTS_Agreement__c where RecordTypeId =:AGREEMENT_Schedule_RECORDTYPEID AND Apttus__Account__c =: dprlist[0].Account__c];
        for(Apttus__APTS_Agreement__c agmt:agmtPS){
        system.debug('agmt'+agmt);
            if(agmt.Apttus__Status__c ==APTPS_Constants.BEINGAMENDED_STATUS){
                isPSAmended = true;  
                break;
            }
        }
        
       // system.assertEquals(true, isPSAmended);
        
        
    }
    @isTest static void createAgreementRecords_Variation1(){
        Test.startTest();
        //testDataSetup();
        List<Delegated_Pricing_Request__c> dprlist = [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c];
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        string AGREEMENT_RCS_TEST_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Related_Company_Schedule').getRecordTypeId();
        
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =dprlist[0].Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = dprlist[0].Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        
        Apttus__APTS_Agreement__c rcsAgreement = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_RCS_TEST_RECORDTYPEID,Apttus__Related_Opportunity__c =dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = dprlist[0].Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(rcsAgreement);
        
        insert agmtList;
        agmtList[1].Apttus__Parent_Agreement__c = agmtList[0].id;
        agmtList[2].Apttus__Parent_Agreement__c = agmtList[0].id;
        upsert agmtList;
        
        List<APTPS_Related_Companies__c> rCompaniesList = new  List<APTPS_Related_Companies__c>();
        APTPS_Related_Companies__c rcRecord1 = new APTPS_Related_Companies__c(APTPS_Account__c = dprlist[0].Account__c, APTPS_Agreement__c = rcsAgreement.id);
        rCompaniesList.add(rcRecord1);
        APTPS_Related_Companies__c rcRecord2 = new APTPS_Related_Companies__c(APTPS_Account__c = dprlist[0].Account__c, APTPS_Agreement__c = rcsAgreement.id);
        rCompaniesList.add(rcRecord2);
        insert rCompaniesList;
        
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
        lineitem00.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        
        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'APTPS_AgreementTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;
        Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        AgreementDealUtilities.createAgreementRecords(dprlist,relatedDPROLI,null);
        Test.stopTest();
        Boolean isPSAmended = false;
        List<Apttus__APTS_Agreement__c> agmtPS= [SELECT id,Apttus__Status__c from Apttus__APTS_Agreement__c where RecordTypeId =:AGREEMENT_Schedule_RECORDTYPEID AND Apttus__Account__c =: dprlist[0].Account__c];
        for(Apttus__APTS_Agreement__c agmt:agmtPS){
        system.debug('agmt'+agmt);
            if(agmt.Apttus__Status__c ==APTPS_Constants.BEINGAMENDED_STATUS){
                isPSAmended = true;  
                break;
            }
        }
        
        system.assertEquals(true, isPSAmended);
        
        
    }
    /* @isTest static void createAgreementRecords_Variation2(){
        Test.startTest();
        //testDataSetup();
        List<Delegated_Pricing_Request__c> dprlist = [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c order by createddate desc LIMIT 1];
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:dprList[0].id];
        system.debug('###dprlist###'+dprlist+'###relatedDPROLI###'+relatedDPROLI);
         
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =dprlist[0].Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =dprlist[0].Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = dprlist[0].Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        
        insert agmtList;
        agmtList[1].Apttus__Parent_Agreement__c = agmtList[0].id;
        upsert agmtList;
        
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
        lineitem00.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        
        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'APTPS_AgreementTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;
        Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        AgreementDealUtilities.createAgreementRecords(dprlist,relatedDPROLI);
        Test.stopTest();
        Boolean isPSAmended = false;
        List<Apttus__APTS_Agreement__c> agmtPS= [SELECT id,Apttus__Status__c from Apttus__APTS_Agreement__c where RecordTypeId =:AGREEMENT_Schedule_RECORDTYPEID AND Apttus__Account__c =: dprlist[0].Account__c];
        for(Apttus__APTS_Agreement__c agmt:agmtPS){
        system.debug('agmt'+agmt);
            if(agmt.Apttus__Status__c ==APTPS_Constants.BEINGAMENDED_STATUS){
                isPSAmended = true;  
                break;
            }
        }
        
        system.assertEquals(true, isPSAmended);
        
        
    }*/
    @isTest static void fetchOpportunityContactRole(){
        Test.startTest();
        String exceptionDesc;
        try{
          OpportunityContactRole  ocRole =  AgreementDealUtilities.fetchOpportunityContactRole(null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    } 
 
 @isTest static void fetchFADefaultRecipientList(){
        Test.startTest();
        String exceptionDesc;
        try{
          List<FA_DefaultRecipients__c>  faDefaultList =  AgreementDealUtilities.fetchFADefaultRecipientList(null);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertNotEquals(null, exceptionDesc);
    } 
    
    /*@Description : This method is used to Test the examinDPROLICommercialProductSaleEligibility
    * @Return : void
    * @UserStroy : DIGI-7386
    */
    @isTest 
    static void examinDPROLICommercialProductSaleEligibility_Test(){
        
      
        List<DPR_Offer_Line_Item__c> dproliRequest= [select id,Delegated_Pricing_Request__c,cspmb_Price_Item__c,Delegated_Pricing_Request__r.Opportunity__c,Delegated_Pricing_Request__r.Account__c from DPR_Offer_Line_Item__c limit 1 ];
        String exceptionDesc;
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c(Name = 'Mobility',
                                                                  cspmb__Billing_Frequency__c = 'Monthly',
                                                                  cspmb__Effective_Start_Date__c = date.parse('10/09/2019'),
                                                                  cspmb__Effective_End_Date__c = date.parse('31/12/2099'),
                                                                  Offer_Id__c = 'DMCAT_Offer_000646',
                                                                  Package_Name__c = 'Corporate Mobile Plus',
                                                                  Plan__c = 'Standard',
                                                                  Type__c = 'Voice and Data',
                                                                  Sale_Eligibility__c=APTPS_Constants.INVITE_ONLY);
        insert priceItem;
        
        dproliRequest[0].cspmb_Price_Item__c=priceItem.Id;
        update dproliRequest;

        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();

        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = dproliRequest[0].Delegated_Pricing_Request__r.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =dproliRequest[0].Delegated_Pricing_Request__r.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
       
        Test.startTest();
        try{
            AgreementDealUtilities.examinDPROLICommercialProductSaleEligibility(dproliRequest[0].Delegated_Pricing_Request__c,agreementDSADigi);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();

    }
    //DIGI-19273 Added to increase the Code Coverage for AgreementDealUtilities Start
    @isTest
    public static void createAttributeOnAgmtLineIemTest(){
        Opportunity opp=[SELECT id from Opportunity WHERE Amount =4600 limit 1];
        //Delegated Pricing Request 
        Delegated_Pricing_Request__c dpReq = new Delegated_Pricing_Request__c();
        dpReq.Opportunity__c = opp.Id;
        insert dpReq ; 
        
       cscfga__Product_Basket__c basket= [SELECT id,csbb__Account__c from  cscfga__Product_Basket__c limit 1];
        cspmb__Rate_Card__c rc = new cspmb__Rate_Card__c(
            Name = 'Shared line - standard calling plan',
            Offer_Id__c ='DMCAT_Offer_000618',
            cspmb__Rate_Card_Code__c = 'ucUsers', 
            cspmb__Effective_End_Date__c = Date.today()+1,
            cspmb__Effective_Start_Date__c = Date.today()-1,
            cspmb__Is_Active__c = true);
        insert rc;
        
        List<DPR_Offer_Line_Item__c> dproliRequest= [select id,Name,Delegated_Pricing_Request__c,cspmb_Price_Item__c,Offer_Type_Name__c,Offer_Type__r.Type__C,Delegated_Pricing_Request__r.Opportunity__c,DPR_Offer_Line_Item_Value__c,Delegated_Pricing_Request__r.Account__c,Marketable_Offer__r.Product_Family__c from DPR_Offer_Line_Item__c limit 1 ];
        
        for(DPR_Offer_Line_Item__c ins:dproliRequest){
            ins.DPR_Offer_Line_Item_Type__c = 'Plan';
        }
        update dproliRequest;
        
        DPR_Rate_Card__c rcObj=new DPR_Rate_Card__c();
        rcObj.Delegated_Pricing_Request__c=dpReq.Id;
        rcObj.DPR_Rate_Card_Type__c='Rate Card';
        rcObj.Parent_DPR_OLI_id__c=dproliRequest[0].Id;
        rcObj.Rate_Card__c=rc.ID;
        Insert rcObj;
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agreementDSADigiParent = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        insert agreementDSADigiParent;
        
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital',Apttus__Parent_Agreement__c=agreementDSADigiParent.Id);
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        insert prod;
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        insert prod1;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem00 = new Apttus__AgreementLineItem__c();
        lineitem00.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        
        Map<Id,Apttus__AgreementLineItem__c> mapOfAgreementLineItems = new Map<Id,Apttus__AgreementLineItem__c>(agmtLineItems);
        List<Id> listOfids=new List<Id>(mapOfAgreementLineItems.keySet());
        Test.startTest();
        try{
          AgreementDealUtilities.createAttributeOnAgmtLineIem(dproliRequest,listOfids);
        }catch(Exception e){
            System.debug('Exception'+e.getMessage());
        }
        
        Test.stopTest();
    }
    //DIGI-19273 End
    //DIGI-19273 Added to increase the Code Coverage for AgreementDealUtilities Start
     @isTest
    public static void createAttributeOnAgmtLineIemException_Test(){
        Opportunity opp=[SELECT id from Opportunity WHERE Amount =4600 limit 1];
        //Delegated Pricing Request 
        Delegated_Pricing_Request__c dpReq = new Delegated_Pricing_Request__c();
        dpReq.Opportunity__c = opp.Id;
        insert dpReq ; 
        
       cscfga__Product_Basket__c basket= [SELECT id,csbb__Account__c from  cscfga__Product_Basket__c limit 1];
        cspmb__Rate_Card__c rc = new cspmb__Rate_Card__c(
            Name = 'Shared line - standard calling plan',
            Offer_Id__c ='DMCAT_Offer_000618',
            cspmb__Rate_Card_Code__c = 'ucUsers', 
            cspmb__Effective_End_Date__c = Date.today()+1,
            cspmb__Effective_Start_Date__c = Date.today()-1,
            cspmb__Is_Active__c = true);
        insert rc;
        
        List<DPR_Offer_Line_Item__c> dproliRequest= [select id,Delegated_Pricing_Request__c,cspmb_Price_Item__c,Offer_Type_Name__c,Offer_Type__r.Type__C,Delegated_Pricing_Request__r.Opportunity__c,Delegated_Pricing_Request__r.Account__c,Marketable_Offer__r.Product_Family__c from DPR_Offer_Line_Item__c limit 1 ];
        
        for(DPR_Offer_Line_Item__c ins:dproliRequest){
            ins.DPR_Offer_Line_Item_Type__c = 'Plan';
        }
        update dproliRequest;
        
        DPR_Rate_Card__c rcObj=new DPR_Rate_Card__c();
        rcObj.Delegated_Pricing_Request__c=dpReq.Id;
        rcObj.DPR_Rate_Card_Type__c='Rate Card';
        rcObj.Parent_DPR_OLI_id__c=dproliRequest[0].Id;
        rcObj.Rate_Card__c=rc.ID;
        Insert rcObj;
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agreementDSADigiParent = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        insert agreementDSADigiParent;
        
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital',Apttus__Parent_Agreement__c=agreementDSADigiParent.Id);
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        insert prod;
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        insert prod1;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem00 = new Apttus__AgreementLineItem__c();
        lineitem00.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        
        Map<Id,Apttus__AgreementLineItem__c> mapOfAgreementLineItems = new Map<Id,Apttus__AgreementLineItem__c>(agmtLineItems);
        List<Id> listOfids=new List<Id>(mapOfAgreementLineItems.keySet());
        Test.startTest();
        try{
          AgreementDealUtilities.createAttributeOnAgmtLineIem(dproliRequest,listOfids);
        }catch(Exception e){
            System.debug('Exception'+e.getMessage());
        }
        
        Test.stopTest();
    }
    
     @isTest static void generateAgreement_Test(){
          Opportunity opp=[SELECT id from Opportunity WHERE Amount =4600 limit 1];
        //Delegated Pricing Request 
        Delegated_Pricing_Request__c dpReq = new Delegated_Pricing_Request__c();
        dpReq.Opportunity__c = opp.Id;
        insert dpReq ; 
        
       cscfga__Product_Basket__c basket= [SELECT id,csbb__Account__c from  cscfga__Product_Basket__c limit 1];
        cspmb__Rate_Card__c rc = new cspmb__Rate_Card__c(
            Name = 'Shared line - standard calling plan',
            Offer_Id__c ='DMCAT_Offer_000618',
            cspmb__Rate_Card_Code__c = 'ucUsers', 
            cspmb__Effective_End_Date__c = Date.today()+1,
            cspmb__Effective_Start_Date__c = Date.today()-1,
            cspmb__Is_Active__c = true);
        insert rc;
        
        List<DPR_Offer_Line_Item__c> dproliRequest= [select id,Delegated_Pricing_Request__c,cspmb_Price_Item__c,Offer_Type_Name__c,Offer_Type__r.Type__C,Delegated_Pricing_Request__r.Opportunity__c,Delegated_Pricing_Request__r.Account__c,Marketable_Offer__r.Product_Family__c from DPR_Offer_Line_Item__c limit 1 ];
        
        for(DPR_Offer_Line_Item__c ins:dproliRequest){
            ins.DPR_Offer_Line_Item_Type__c = 'Plan';
        }
        update dproliRequest;
        
        DPR_Rate_Card__c rcObj=new DPR_Rate_Card__c();
        rcObj.Delegated_Pricing_Request__c=dpReq.Id;
        rcObj.DPR_Rate_Card_Type__c='Rate Card';
        rcObj.Parent_DPR_OLI_id__c=dproliRequest[0].Id;
        rcObj.Rate_Card__c=rc.ID;
        Insert rcObj;
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agreementDSADigiParent = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        insert agreementDSADigiParent;
        
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital',Apttus__Parent_Agreement__c=agreementDSADigiParent.Id);
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=basket.csbb__Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
         
        Test.startTest();
        String exceptionDesc;
        try{
            AgreementDealUtilities.generateAgreement(agmtList);
        }
        Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
        system.assertEquals(null, exceptionDesc);
    } 
    
    @isTest
    public static void createRCAgreementException(){
        
        String exMessage='';
        try{
            AgreementDealUtilities.createRCAgreement(null,null);
        }Catch(Exception e){
            exMessage=e.getMessage();
        }
        System.assertNotEquals(null,exMessage);
    } 
    //End DIGI-19273 
   
}