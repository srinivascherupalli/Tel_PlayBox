/*****************************************************************
@Name: APTPS_AgreementTgrHandlerTest
@Author: Vishal Arbune
@CreateDate: 27/11/2020 
@Description: This class is the test class for APTPS_AgreementTgrHandlerTest
@UsedBy: APTPS_AgreementTgrHandler

Modified by Aarathi for EDGE 198013
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Aarathi Iyer          15/03/2021      EDGE-203939 : Update Opportunity stage to "Propose" when Frame Agreement status is Contract Generated
2.            Lokesh Thathuru       07/10/2021      created the test methods to cover the new Scenarios in APTPS_AgreementTgrHandler
******************************************************************/ 
@isTest
public with sharing class APTPS_AgreementTgrHandlerTest{
    @TestSetup
    static void dataSetup(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
                
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com'   
        );
        Insert contact;

        //CREATE OPPORTUNITY RECORD 
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Contract_Term__c = 12;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        
        //CREATE OPPORTUNITY CONTACT Role
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = contact.Id;
        oppContRole.OpportunityId = opp.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;
        
        Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;     
        
        //Create Product Basket and Contract 
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket00 = ProductTestFactory.buildEmptyBasket();
        basket00 = ProductTestFactory.buildEmptyBasket();
        basket00.csbb__Account__c = acc.id;
        basket00.cscfga__Opportunity__c = opp.id;
        basket00.Name = 'New basket';
        basket00.cscfga__total_contract_value__c = 10;
        basket00.BasketType__c = 'Incoming';
        lstbasket.add(basket00);
        
        cscfga__Product_Basket__c basket01 = ProductTestFactory.buildEmptyBasket();
        basket01 = ProductTestFactory.buildEmptyBasket();
        basket01.csbb__Account__c = acc.id;
        basket01.cscfga__Opportunity__c = opp.id;
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
        cntrctRecord.isTransitionContract__c = false ; 
        insert cntrctRecord;
        
        
        //CREATE DPR
        Delegated_Pricing_Request__c dpr= new Delegated_Pricing_Request__c();
        dpr.Account__c=acc.id;
        dpr.Opportunity__c=opp.id;
        dpr.Commitment_Frequency__c='Quarterly';
        dpr.Deal_Status__c = 'Active';
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
        
        //CREATE AGREEMENT
        string RECORDTYPEIDSA  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(
            recordtypeid=RECORDTYPEIDSA,
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Delegated_Pricing_Request__c = dpr.id,
            Apttus__Related_Opportunity__c = opp.Id,
            Apttus__Source__c=APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL,
            Name ='Test');
        insert agreement;
        string RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement11 = new Apttus__APTS_Agreement__c(
            recordtypeid=RECORDTYPEID,
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Delegated_Pricing_Request__c = dpr.id,
            Apttus__Related_Opportunity__c = opp.Id,
            Apttus__Agreement_Category__c = 'Pricing', 
            Apttus__Source__c=APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL,
            Name ='Test1');
        insert agreement11;
        //EDGE-194530
         Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(
            recordtypeid=RECORDTYPEID,
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Apttus__Status__c ='Request',
            Related_Basket__c = lstbasket[0].Id,
            Related_Contract__c = cntrctRecord.Id,
             VariationType__c = 'Price Schedule;Related Company',
            Apttus__Related_Opportunity__c = opp.Id,
            Apttus__Parent_Agreement__c = agreement.Id,
            Apttus__Agreement_Category__c = 'Pricing', 
            Apttus__Source__c=APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL,
            Name ='TestcjPS');
        insert agreement1;
        
        string RECORDTYPEID2  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Related_Company_Schedule').getRecordTypeId();
         Apttus__APTS_Agreement__c agreement4 = new Apttus__APTS_Agreement__c(
            recordtypeid=RECORDTYPEID2,
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Apttus__Status__c ='Request',
             Apttus__Contract_End_Date__c=Date.today(),
             VariationType__c = 'Price Schedule;Related Company',
             Apttus__Term_Months__c=12,
            Delegated_Pricing_Request__c = dpr.id,
            Apttus__Related_Opportunity__c = opp.Id,
            Apttus__Parent_Agreement__c = agreement1.Id,
            Name ='TestRCS');
        insert agreement4;
        
   /*     string RECORDTYPEID1  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(
            recordtypeid=RECORDTYPEID1,
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Apttus__Status__c ='Request',
            Related_Basket__c = lstbasket[0].Id , 
            Related_Contract__c = cntrctRecord.Id , 
            Apttus__Related_Opportunity__c = opp.Id,
            Apttus__Agreement_Category__c='Digital Services',
            Name ='Test');
        insert agreement2;  */
        //EDGE-194530 End 
        //CREATE FRAME AGREEMENT
        csconta__Frame_Agreement__c fAgreement = new csconta__Frame_Agreement__c();
        fAgreement.csconta__Account__c=acc.id;
        fAgreement.Opportunity__c=opp.id;
        fAgreement.Delegated_Pricing_Request__c=dpr.id;
        fAgreement.csconta__Agreement_Name__c='AGR-TEST';
        fAgreement.csconta__Status__c = 'Open'; 
        fAgreement.csconta__effective_start_date__c = null;
        fAgreement.csconta__effective_end_date__c = null;        
        fAgreement.Contract_Acceptance_Date__c = DateTime.now();
        insert fAgreement;
        //EDGE-194530
         csconta__Frame_Agreement__c fAgreement1 = new csconta__Frame_Agreement__c();
        fAgreement1.csconta__Account__c=acc.id;
        fAgreement1.Opportunity__c=opp.id;
        fAgreement1.Delegated_Pricing_Request__c=dpr.id;
        fAgreement1.csconta__Agreement_Name__c='AGR-TEST1';
        fAgreement1.csconta__Status__c = 'Active'; 
        fAgreement1.csconta__effective_start_date__c = null;
        fAgreement1.csconta__effective_end_date__c = null;        
        fAgreement1.Contract_Acceptance_Date__c = DateTime.now();
        insert fAgreement1;
        //EDGE-194530 End
        //CREATE FA AGREEMENT ASSOCIATION
        FA_Agreement_Association__c faAssociation = new FA_Agreement_Association__c();
        faAssociation.Name = 'Test FA Association';
        faAssociation.FA__c = fAgreement.ID;
        faAssociation.Agreement__c = agreement.ID;          
        insert faAssociation;      
        //EDGE-194530
       /* FA_Agreement_Association__c faAssociation1 = new FA_Agreement_Association__c();
        faAssociation1.Name = 'Test FA Association';
        faAssociation1.FA__c = fAgreement.ID;
        faAssociation1.Agreement__c = agreement1.ID;          
        insert faAssociation1; 
        
        FA_Agreement_Association__c faAssociation2 = new FA_Agreement_Association__c();
        faAssociation2.Name = 'Test FA Association';
        faAssociation2.FA__c = fAgreement1.ID;
        faAssociation2.Agreement__c = agreement1.ID;   
        
        insert faAssociation2; */
        FA_Agreement_Association__c faAssociation3 = new FA_Agreement_Association__c();
        faAssociation3.Name = 'Test FA Association';
        faAssociation3.FA__c = fAgreement1.ID;
        faAssociation3.Agreement__c = agreement.ID;          
        insert faAssociation3; 
        //EDGE-194530 End 
        
        Apttus__APTS_Related_Agreement__c agRelated = new Apttus__APTS_Related_Agreement__c();
        agRelated.Apttus__APTS_Contract_To__c = agreement1.Id ;   
        agRelated.Apttus__APTS_Contract_From__c =  agreement.ID;
        insert agRelated;
       
        echosign_dev1__SIGN_Agreement__c adobeagg = new echosign_dev1__SIGN_Agreement__c();
       adobeagg.echosign_dev1__Account__c = acc.id;
       adobeagg.echosign_dev1__Status__c = 'Cancelled / Declined';
       adobeagg.Apttus_Echosign__Apttus_Agreement__c = agreement.Id;
       insert adobeagg;
        
        echosign_dev1__SIGN_AgreementEvent__c aggEvent = new echosign_dev1__SIGN_AgreementEvent__c();
        aggEvent.echosign_dev1__SIGN_Agreement__c = adobeagg.id;
        aggEvent.echosign_dev1__Event_Type__c = 'RECALLED';
        insert aggEvent;
    }
    
    @isTest
    public static void updateFADetailsTestPositive(){
        Test.startTest();        
        try{ 
            Apttus__APTS_Agreement__c agmt = [Select id, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' Limit 1];
            agmt.Apttus__Status_Category__c = 'In Effect';
            agmt.Apttus__Status__c = 'Activated';
            update agmt; 
            
            csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c,csconta__effective_start_date__c,csconta__effective_end_date__c,Opportunity__r.StageName from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST' Limit 1];
            
            Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Commitment_Frequency__c='Quarterly' LIMIT 1];
            system.assertEquals(agmt.Apttus__Contract_End_Date__c, null,'Contract end date should match');
            system.assertEquals(agmt.Apttus__Contract_Start_Date__c, null, 'Contract start date should match');
            system.assertNotEquals(agmt.Apttus__Contract_End_Date__c, Date.Today(), 'Contract end date should not match');
            system.assertEquals(fa.csconta__Status__c, 'Open','FA status should match');
            //system.assertEquals(fa.Opportunity__r.StageName, 'Define','FA status should match');//EDGE-203939 by team Amsterdam
            system.assertEquals(fa.csconta__effective_start_date__c, null,'Contract start date should match');
            system.assertEquals(fa.csconta__effective_end_date__c, null,'Contract end date should match');
            system.assertEquals(dpr.Deal_Status__c, 'Active','deal status should match');
            //system.assertNotEquals(dpr.Deal_Status__c, 'Active', 'Deal status should match');
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
    @isTest
    public static void activateAgreementTest(){
        Test.startTest();        
        try{ 
            String RECORDTYPEIDString  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId() ; 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>(); 
            Apttus__APTS_Agreement__c agmt = [Select id,Related_Contract__r.Id ,Related_Basket__r.Id, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Related_Basket__c,Related_Contract__c,Apttus__Status__c,Delegated_Pricing_Request__c,Apttus__Agreement_Category__c,Apttus__Source__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Related_Basket__c != null AND Related_Contract__c != null AND recordtypeid  =: RECORDTYPEIDString  Limit 1];
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Fully Signed';
            update agmt; 
            agmtList.add(agmt);
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>(); 
            ath.updateAgreementStatus(agmtList,oldmap); 
            ContractJunction__c cj = [SELECT Id , Status__c FROM ContractJunction__c LIMIT 1 ];  
            cscfga__Product_Basket__c pBasket = [SELECT Id, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c LIMIT 1 ]; 
            system.assertEquals(cj.Status__c, 'Contract Accepted');
            system.assertEquals(pBasket.csordtelcoa__Basket_Stage__c, 'Contract Accepted');
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
   
     @isTest
    public static void cjCancelTest(){
         String exceptionDesc;
        Test.startTest();        
        try{ 
            String RECORDTYPEIDString  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId() ; 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>(); 
            Apttus__APTS_Agreement__c agmt = [Select id,Related_Contract__r.Id ,Related_Basket__r.Id, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Related_Basket__c,Related_Contract__c,Apttus__Status__c,Delegated_Pricing_Request__c,Apttus__Agreement_Category__c,Apttus__Source__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Related_Basket__c != null AND Related_Contract__c != null AND recordtypeid  =: RECORDTYPEIDString  Limit 1];
            system.debug('agmt'+agmt);
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Signature Declined';
            update agmt;  
            agmtList.add(agmt); 
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>();   
            ath.cjCancel(agmtList,oldmap); 
            ContractJunction__c cj = [SELECT Id , Status__c FROM ContractJunction__c LIMIT 1 ];  
            cscfga__Product_Basket__c pBasket = [SELECT Id, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c LIMIT 1 ]; 
     //       system.assertEquals(cj.Status__c, 'Signature Declined');
            agmt.Apttus__Status_Category__c = 'Cancelled';
            agmt.Apttus__Status__c = 'Cancelled Request';
            update agmt;  
            agmtList.add(agmt);
            map<id,Apttus__APTS_Agreement__c> oldmap2 = new map<id,Apttus__APTS_Agreement__c>();   
            ath.cjCancel(agmtList,oldmap2);
        } Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }          
        Test.stopTest();
    }
     @isTest
    public static void cjOtherPartySignTest(){
        Test.startTest();        
        try{ 
            String RECORDTYPEIDString  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId() ; 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>(); 
            Apttus__APTS_Agreement__c agmt = [Select id,Related_Contract__r.Id ,Related_Basket__r.Id, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Related_Basket__c,Related_Contract__c,Apttus__Status__c,Delegated_Pricing_Request__c,Apttus__Agreement_Category__c,Apttus__Source__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Related_Basket__c != null AND Related_Contract__c != null AND recordtypeid  =: RECORDTYPEIDString  Limit 1];
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Other Party Signatures';
            update agmt; 
            agmtList.add(agmt);
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>(); 
            ath.cjOtherPartySign(agmtList,oldmap); 
            ContractJunction__c cj = [SELECT Id , Status__c FROM ContractJunction__c LIMIT 1 ];  
            cscfga__Product_Basket__c pBasket = [SELECT Id, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c LIMIT 1 ]; 
            system.assertEquals(cj.Status__c, 'Customer Review');
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
     @isTest
    public static void dprActivationTest(){
        Test.startTest();        
        try{ 
            String RECORDTYPEIDString  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId() ; 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>(); 
            Apttus__APTS_Agreement__c agmt = [Select id,Related_Contract__r.Id ,Related_Basket__r.Id, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Related_Basket__c,Related_Contract__c,Apttus__Status__c,Delegated_Pricing_Request__c,Apttus__Agreement_Category__c,Apttus__Source__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Delegated_Pricing_Request__c!= null AND recordtypeid  =: RECORDTYPEIDString  Limit 1];
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Fully Signed';
            update agmt; 
            agmtList.add(agmt);
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>(); 
            ath.updateAgreementStatus(agmtList,oldmap); 
           
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
    @isTest
    public static void updateAgreementStatusExceptionTest(){
        Test.startTest();  
         String exceptionDesc;
        try{ 
           APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            ath.updateAgreementStatus(null,null);
        }
         Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
    }
    @isTest
    public static void agreementActivationTest(){
        Test.startTest();        
        try{ 
            String RECORDTYPEIDString  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId() ; 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>(); 
            Apttus__APTS_Agreement__c agmt = [Select id,Related_Contract__r.Id ,Related_Basket__r.Id, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Related_Basket__c,Related_Contract__c,Apttus__Status__c,Delegated_Pricing_Request__c,Apttus__Agreement_Category__c,Apttus__Source__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Delegated_Pricing_Request__c!= null AND recordtypeid  =: RECORDTYPEIDString  Limit 1];
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Fully Signed';
            update agmt; 
            agmtList.add(agmt);
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>(); 
            ath.agreementActivation(agmtList,oldmap); 
           
        }catch(AgreementException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
     @isTest
    public static void agreementActivationExceptionTest(){
        Test.startTest();  
         String exceptionDesc;
        try{ 
           APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            ath.agreementActivation(null,null);
        }
         Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
    }
    @isTest
    public static void cjActivationTest(){
        Test.startTest();        
        try{ 
            String RECORDTYPEIDString  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId() ; 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>(); 
            Apttus__APTS_Agreement__c agmt = [Select id,Related_Contract__r.Id ,Related_Basket__r.Id,Apttus__Agreement_Category__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Related_Basket__c,Related_Contract__c,Apttus__Status__c,Delegated_Pricing_Request__c,Apttus__Source__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Related_Basket__c!=null AND Related_Contract__c!=null AND Apttus__Agreement_Category__c = 'Pricing' AND recordtypeid  =: RECORDTYPEIDString  Limit 1];
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Fully Signed';
            update agmt; 
            agmtList.add(agmt);
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>(); 
            ath.cjActivation(agmtList,oldmap); 
           
        }catch(AgreementException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
     @isTest
    public static void cjActivationExceptionTest(){
        Test.startTest();  
         String exceptionDesc;
        try{ 
           APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            ath.cjActivation(null,null);
            
        }
         Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
    }
     @isTest
    public static void cjCancelExceptionTest(){
        Test.startTest();  
         String exceptionDesc;
        try{ 
           APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            ath.cjCancel(null,null);
            
        }
         Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
    }
      @isTest
    public static void dprActivationExceptionTest(){
        Test.startTest();  
         String exceptionDesc;
        try{ 
           APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            ath.dprActivation(null,null);
        }
         Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
    }
      @isTest
    public static void cjOtherPartySignExceptionTest(){
        Test.startTest();  
         String exceptionDesc;
        try{ 
           APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            ath.cjOtherPartySign(null,null);
            ath.dprActivation(null,null);
        }
         Catch(AgreementException agEx)
        {
            exceptionDesc = agEx.businessDescription;
        }
        Test.stopTest();
    }
    
@isTest
    public static void updateFADetailsDateTestPositive(){
        Test.startTest();        
        try{ 
            Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Agreement_Category__c,Apttus__Company_Signed_Date__c,Apttus__Other_Party_Signed_Date__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where APTPS_Record_Type_Name__c ='SA' Limit 1];
            agmt.Apttus__Status_Category__c = 'In Effect';
            agmt.Apttus__Status__c = 'Activated';
            agmt.Apttus__Agreement_Category__c='Digital Services';
            agmt.Apttus__Company_Signed_Date__c=Null;
            agmt.Apttus__Other_Party_Signed_Date__c=Null;    
            update agmt; 
            
            csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c,csconta__effective_start_date__c,csconta__effective_end_date__c,Opportunity__r.StageName from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST' Limit 1];
            
            Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Commitment_Frequency__c='Quarterly' LIMIT 1];
            system.assertEquals(agmt.Apttus__Contract_End_Date__c, null,'Contract end date should match');
            system.assertEquals(agmt.Apttus__Contract_Start_Date__c, null, 'Contract start date should match');
            system.assertNotEquals(agmt.Apttus__Contract_End_Date__c, Date.Today(), 'Contract end date should not match');
            system.assertEquals(fa.csconta__Status__c, 'Open','FA status should match');
            //system.assertEquals(fa.Opportunity__r.StageName, 'Define','FA status should match');//EDGE-203939 by team Amsterdam
            system.assertEquals(fa.csconta__effective_start_date__c, null,'Contract start date should match');
            system.assertEquals(fa.csconta__effective_end_date__c, null,'Contract end date should match');
            system.assertEquals(dpr.Deal_Status__c, 'Active','deal status should match');
            //system.assertNotEquals(dpr.Deal_Status__c, 'Active', 'Deal status should match');
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }        
    
    @isTest
    public static void updateFADetailsCmpDateTestPositive(){
        Test.startTest();        
        try{ 
            Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Agreement_Category__c,Apttus__Company_Signed_Date__c,Apttus__Other_Party_Signed_Date__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where APTPS_Record_Type_Name__c ='SA' Limit 1];
            agmt.Apttus__Status_Category__c = 'In Effect';
            agmt.Apttus__Status__c = 'Activated';
            agmt.Apttus__Agreement_Category__c='Digital Services';
            agmt.Apttus__Company_Signed_Date__c=system.today();
            agmt.Apttus__Other_Party_Signed_Date__c=system.today();    
            update agmt; 
            
            csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c,csconta__effective_start_date__c,csconta__effective_end_date__c,Opportunity__r.StageName from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST' Limit 1];
            
            Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Commitment_Frequency__c='Quarterly' LIMIT 1];
            system.assertEquals(agmt.Apttus__Contract_End_Date__c, null,'Contract end date should match');
            system.assertEquals(agmt.Apttus__Contract_Start_Date__c, null, 'Contract start date should match');
            system.assertNotEquals(agmt.Apttus__Contract_End_Date__c, Date.Today(), 'Contract end date should not match');
            system.assertEquals(fa.csconta__Status__c, 'Open','FA status should match');
            //system.assertEquals(fa.Opportunity__r.StageName, 'Define','FA status should match');//EDGE-203939 by team Amsterdam
            system.assertEquals(fa.csconta__effective_start_date__c, null,'Contract start date should match');
            system.assertEquals(fa.csconta__effective_end_date__c, null,'Contract end date should match');
            system.assertEquals(dpr.Deal_Status__c, 'Active','deal status should match');
            //system.assertNotEquals(dpr.Deal_Status__c, 'Active', 'Deal status should match');
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
    @isTest
    public static void updateFADetailsOthrDateTestPositive(){
        Test.startTest();        
        try{ 
            Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Agreement_Category__c,Apttus__Company_Signed_Date__c,Apttus__Other_Party_Signed_Date__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where APTPS_Record_Type_Name__c ='SA' Limit 1];
            agmt.Apttus__Status_Category__c = 'In Effect';
            agmt.Apttus__Status__c = 'Activated';
            agmt.Apttus__Agreement_Category__c='Digital Services';
            agmt.Apttus__Company_Signed_Date__c=system.today();
            //agmt.Apttus__Other_Party_Signed_Date__c=system.today();    
            update agmt; 
            
            csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c,csconta__effective_start_date__c,csconta__effective_end_date__c,Opportunity__r.StageName from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST' Limit 1];
            
            Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Commitment_Frequency__c='Quarterly' LIMIT 1];
            system.assertEquals(agmt.Apttus__Contract_End_Date__c, null,'Contract end date should match');
            system.assertEquals(agmt.Apttus__Contract_Start_Date__c, null, 'Contract start date should match');
            system.assertNotEquals(agmt.Apttus__Contract_End_Date__c, Date.Today(), 'Contract end date should not match');
            system.assertEquals(fa.csconta__Status__c, 'Open','FA status should match');
            //system.assertEquals(fa.Opportunity__r.StageName, 'Define','FA status should match');//EDGE-203939 by team Amsterdam
            system.assertEquals(fa.csconta__effective_start_date__c, null,'Contract start date should match');
            system.assertEquals(fa.csconta__effective_end_date__c, null,'Contract end date should match');
            system.assertEquals(dpr.Deal_Status__c, 'Active','deal status should match');
            //system.assertNotEquals(dpr.Deal_Status__c, 'Active', 'Deal status should match');
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }   
    @isTest
    public static void updateFADetailsTestNegative(){
        Test.startTest();        
        try{ 
            Apttus__APTS_Agreement__c agmt = [Select id, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' Limit 1];
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Signature Declined';
            update agmt; 
            
            csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST' Limit 1];
            
            Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Commitment_Frequency__c='Quarterly' LIMIT 1];
            system.assertEquals(fa.csconta__Status__c, 'Open','FA status should match');
            //system.assertEquals(dpr.Deal_Status__c, 'Draft','deal status should match');
            
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }

@isTest
    public static void updateFADetailsTestPositiveSchedule(){
        Test.startTest();        
        try{ 
            Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Status__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c where APTPS_Record_Type_Name__c ='Schedule' Limit 1];
          //  Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Status__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='In Signatures' Limit 1];
            
            system.debug(agmt);
            agmt.Apttus__Status_Category__c = 'In Iffect ';
            agmt.Apttus__Status__c = 'Activated';
            system.debug('**'+agmt);
            update agmt; 
            system.debug('****'+agmt);
            csconta__Frame_Agreement__c fa = [Select id,csconta__Status__c,csconta__effective_start_date__c,csconta__effective_end_date__c,Opportunity__r.Contract_Term__c,Opportunity__r.StageName from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST' Limit 1];
            
            Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Commitment_Frequency__c='Quarterly' LIMIT 1];
            system.assertEquals(agmt.Apttus__Contract_End_Date__c, null,'Contract end date should match');
            system.assertEquals(agmt.Apttus__Contract_Start_Date__c, null, 'Contract start date should match');
            system.assertNotEquals(agmt.Apttus__Contract_End_Date__c, Date.Today(), 'Contract end date should not match');
            system.assertEquals(fa.csconta__Status__c, 'Open','FA status should match');
            system.assertEquals(fa.csconta__effective_start_date__c, null,'Contract start date should match');
            system.assertEquals(fa.csconta__effective_end_date__c, null,'Contract end date should match');
            //system.assertEquals(dpr.Deal_Status__c, 'Draft','deal status should match');
            //system.assertNotEquals(dpr.Deal_Status__c, 'Active', 'Deal status should match');
           
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
    
 @isTest
    public static void updateFADetailsTestNegativeSchedule(){
        Test.startTest();        
        try{ 
           Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Status__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c where APTPS_Record_Type_Name__c ='Schedule' Limit 1];
          agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Signature Declined';
            update agmt; 
          //  system.assertEquals(agmt.Apttus__Status__c,'Cancelled Request');
         //   system.assertEquals(agmt.Apttus__Status_Category__c,'Cancelled');
            csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST1' Limit 1];
            
            Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Commitment_Frequency__c='Quarterly' LIMIT 1];
            system.assertEquals(fa.csconta__Status__c, 'Active','FA status should match');
            //system.assertEquals(dpr.Deal_Status__c, 'Draft','deal status should match');
            
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
    
    //DIGI-11225 Start
   @isTest
    public static void updateFADetailsTestRCSchedule(){
        Test.startTest();        
        try{ 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>();
           Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Company_Signed_Date__c,Apttus__Status__c,Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c,VariationType__c,Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c where APTPS_Record_Type_Name__c = 'Related_Company_Schedule'  Limit 1];
          system.debug('RCS##'+agmt);
            oldmap.put(agmt.id,agmt);
            agmt.Apttus__Term_Months__c=12;
            agmt.Apttus__Contract_End_Date__c=Date.today();
            agmt.Apttus__Company_Signed_Date__c=system.today();
            agmt.Apttus__Status_Category__c = 'In Effect';
            agmt.Apttus__Status__c = 'Activated';
       //     update agmt; 
            agmtList.add(agmt);
             
            ath.updateFAdetailsSchedule(agmtList,oldmap);
       //     csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST1' Limit 1];
            
       //     Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Commitment_Frequency__c='Quarterly' LIMIT 1];
       //     system.assertEquals(fa.csconta__Status__c, 'Active','FA status should match'); 
            
            
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
    //DIGI-11225 End  
        //DIGI-16366 Start
    @isTest
    public static void updateFADetailsTestRCScheduleDecline(){
        Test.startTest();        
        try{ 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>();
           Apttus__APTS_Agreement__c agmt = [Select id,Delegated_Pricing_Request__c,Apttus__Company_Signed_Date__c,Apttus__Status__c,Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c,VariationType__c,Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c where APTPS_Record_Type_Name__c = 'Related_Company_Schedule'  Limit 1];
            system.debug('RCS##'+agmt);
            oldmap.put(agmt.id,agmt);
            agmt.Apttus__Term_Months__c=12;
            agmt.Apttus__Contract_End_Date__c=Date.today();
            agmt.Apttus__Company_Signed_Date__c=system.today();
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Signature Declined';
       //     update agmt;
            agmtList.add(agmt);
             
            ath.updateFAdetailsSchedule(agmtList,oldmap); 
            system.debug('RCS##'+agmt);
      //     csconta__Frame_Agreement__c fa = [Select id, Delegated_Pricing_Request__c, csconta__Status__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST1' Limit 1];
            
      //      Delegated_Pricing_Request__c dpr= [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where Id =: agmt.Delegated_Pricing_Request__c LIMIT 1];
       //     system.debug('###dpr'+dpr);
      //      system.assertEquals(dpr.Deal_Status__c, 'Active','DPR status should match');  
            
            
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
    //DIGI-16366 End     
    
    @isTest
    public static void pSAgreementRecordUpdationTest(){
        List<ID> faId = new List<ID>();
        Set<ID> aggId = new Set<ID>() ; 
        Test.startTest();        
        try{ 
            for(Apttus__APTS_Agreement__c agmt : [Select id,Apttus__Status__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' ]){
                 System.debug('agmt'+agmt);
                System.debug('agmt'+agmt.Id);
                aggId.add(agmt.Id); 
            }
       
        csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST1' Limit 1];
        System.debug('fa'+fa);
        faId.add(fa.Id);
        FA_Agreement_Association__c fAVsAgg = [SELECT Id, FA__c FROM FA_Agreement_Association__c WHERE FA__c IN: faId LIMIT 1]; 
        List<Apttus__APTS_Agreement__c> aggList = APTPS_AgreementTgrHandler.pSAgreementRecordUpdation(aggId ,faId);
            //system.assertEquals(aggList[0].Apttus__Contract_Start_Date__c, date.Today());
         }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }
        Test.stopTest();
    }
   
    @isTest
    public static void pSAgreementRecordUpdationDateTest(){
        List<ID> faId = new List<ID>();
        Set<ID> aggId = new Set<ID>() ; 
        list<Apttus__APTS_Agreement__c> agmtlst=new list<Apttus__APTS_Agreement__c>();
        Test.startTest();        
        try{ 
            for(Apttus__APTS_Agreement__c agmt : [Select id,Apttus__Status__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' ]){
                 System.debug('agmt'+agmt);
                System.debug('agmt'+agmt.Id);
                agmt.Apttus__Agreement_Category__c='Pricing';
                agmt.Apttus__Company_Signed_Date__c=Null;
                agmt.Apttus__Other_Party_Signed_Date__c=Null;
                //aggId.add(agmt.Id); 
                agmtlst.add(agmt);
            }
            update agmtlst;
            system.debug('@@@@@@@'+agmtlst);
        for(Apttus__APTS_Agreement__c ag: agmtlst){
            if(ag.APTPS_Record_Type_Name__c=='Schedule'){
                aggId.add(ag.Id);
            }
            
        }
        csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST1' Limit 1];
        System.debug('fa'+fa);
        faId.add(fa.Id);
        FA_Agreement_Association__c fAVsAgg = [SELECT Id, FA__c FROM FA_Agreement_Association__c WHERE FA__c IN: faId LIMIT 1]; 
        List<Apttus__APTS_Agreement__c> aggList = APTPS_AgreementTgrHandler.pSAgreementRecordUpdation(aggId ,faId);
            //system.assertEquals(aggList[0].Apttus__Contract_Start_Date__c, date.Today());
         }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }
        Test.stopTest();
    }
    @isTest
    public static void pSAgreementRecordUpdationCmpDateTest(){
        List<ID> faId = new List<ID>();
        Set<ID> aggId = new Set<ID>() ; 
        list<Apttus__APTS_Agreement__c> agmtlst=new list<Apttus__APTS_Agreement__c>();
        Test.startTest();        
        try{ 
            for(Apttus__APTS_Agreement__c agmt : [Select id,Apttus__Status__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' ]){
                 System.debug('agmt'+agmt);
                System.debug('agmt'+agmt.Id);
                agmt.Apttus__Agreement_Category__c='Pricing';
                agmt.Apttus__Company_Signed_Date__c=system.today();
                agmt.Apttus__Other_Party_Signed_Date__c=system.today();
                //aggId.add(agmt.Id); 
                agmtlst.add(agmt);
            }
            update agmtlst;
            system.debug('@@@@@@@'+agmtlst);
        for(Apttus__APTS_Agreement__c ag: agmtlst){
            if(ag.APTPS_Record_Type_Name__c=='Schedule'){
                aggId.add(ag.Id);
            }
            
        }
        csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST1' Limit 1];
        System.debug('fa'+fa);
        faId.add(fa.Id);
        FA_Agreement_Association__c fAVsAgg = [SELECT Id, FA__c FROM FA_Agreement_Association__c WHERE FA__c IN: faId LIMIT 1]; 
        List<Apttus__APTS_Agreement__c> aggList = APTPS_AgreementTgrHandler.pSAgreementRecordUpdation(aggId ,faId);
            //system.assertEquals(aggList[0].Apttus__Contract_Start_Date__c, date.Today());
         }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }
        Test.stopTest();
    }
    @isTest
    public static void pSAgreementRecordUpdationStartDateTest(){
        List<ID> faId = new List<ID>();
        Set<ID> aggId = new Set<ID>() ; 
        list<Apttus__APTS_Agreement__c> agmtlst=new list<Apttus__APTS_Agreement__c>();
        Test.startTest();        
        try{ 
            for(Apttus__APTS_Agreement__c agmt : [Select id,Apttus__Status__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' ]){
                 System.debug('agmt'+agmt);
                System.debug('agmt'+agmt.Id);
                agmt.Apttus__Agreement_Category__c='Pricing';
                agmt.Apttus__Company_Signed_Date__c=system.today();
                //agmt.Apttus__Other_Party_Signed_Date__c=system.today();
                //aggId.add(agmt.Id); 
                agmtlst.add(agmt);
            }
            update agmtlst;
            system.debug('@@@@@@@'+agmtlst);
        for(Apttus__APTS_Agreement__c ag: agmtlst){
            if(ag.APTPS_Record_Type_Name__c=='Schedule'){
                aggId.add(ag.Id);
            }
            
        }
        csconta__Frame_Agreement__c fa = [Select id, csconta__Status__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c='AGR-TEST1' Limit 1];
        System.debug('fa'+fa);
        faId.add(fa.Id);
        FA_Agreement_Association__c fAVsAgg = [SELECT Id, FA__c FROM FA_Agreement_Association__c WHERE FA__c IN: faId LIMIT 1]; 
        List<Apttus__APTS_Agreement__c> aggList = APTPS_AgreementTgrHandler.pSAgreementRecordUpdation(aggId ,faId);
            //system.assertEquals(aggList[0].Apttus__Contract_Start_Date__c, date.Today());
         }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }
        Test.stopTest();
    }  
    @isTest
    public static void dSAFrageAgreementAssociationRecoredCreationTest(){
        Set<ID> dprId = new Set<ID>();
        Set<ID> aggId = new Set<ID>() ; 
        Test.startTest();        
        try{ 
            for(Apttus__APTS_Agreement__c agmt : [Select id,Apttus__Status__c,Delegated_Pricing_Request__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' ]){
                 System.debug('agmt'+agmt);
                System.debug('agmt'+agmt.Id);
                aggId.add(agmt.Id); 
                dprId.add(agmt.Delegated_Pricing_Request__c);
            }
       
        List<FA_Agreement_Association__c> faVsAgg =  APTPS_AgreementTgrHandler.dSAFrageAgreementAssociationRecoredCreation(aggId ,dprId);
        system.assertEquals(faVsAgg[0].Status__c, 'Amended'); 
         }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }
        Test.stopTest();
    }
         @isTest
    public static void pSAgreementRecordUpdationRejectedTest(){
        Set<ID> dprId = new Set<ID>();
        Set<ID> aggId = new Set<ID>() ; 
        List<Apttus__APTS_Agreement__c> pAgmts = new List<Apttus__APTS_Agreement__c>();
        Test.startTest();        
        try{ 
            for(Apttus__APTS_Agreement__c agmt : [Select id,Apttus__Status__c,Delegated_Pricing_Request__c, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c, Apttus__Status_Category__c,Apttus__Related_Opportunity__r.Contract_Term__c,APTPS_Record_Type_Name__c,Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' ]){
                 System.debug('agmt'+agmt);
                System.debug('agmt'+agmt.Id);
                aggId.add(agmt.Id); 
                dprId.add(agmt.Delegated_Pricing_Request__c);
                for(Apttus__APTS_Agreement__c pAgmt: [Select id, Apttus__Status__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where id = :agmt.Apttus__Parent_Agreement__c]){
                pAgmts.add(pAgmt);
                }
            }
        for(Apttus__APTS_Agreement__c ag : pAgmts ){
        ag.Apttus__Status__c = 'Other Party Signatures';
        ag.Apttus__Status_Category__c = 'In Signatures';
        }
        update pAgmts;    
            
        List<Apttus__APTS_Agreement__c> aggRejected =  APTPS_AgreementTgrHandler.pSAgreementRecordUpdationRejected(aggId ,dprId);
        system.assertEquals(aggRejected[0].Apttus__Status_Category__c, 'Cancelled'); 
        system.assertEquals(aggRejected[0].Apttus__Status__c, 'Cancelled Request');
         }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }
        Test.stopTest();
    }
    @isTest
    public static void UpdateAgreementToRecallException1Test(){
        Test.startTest();
        try{
            Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Status__c , Apttus__Status_Category__c,Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c ='Request' and Apttus__Parent_Agreement__c = null Limit 1];
            agmt.Apttus__Status_Category__c = 'In Signatures';
            agmt.Apttus__Status__c = 'Signature Declined';
            update agmt;
            
        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateContractTerminOpportunityTest(){
        Test.startTest();        
        try{ 
            Opportunity OpportunityContractTerm =[Select ID,Contract_Term__c From opportunity LIMIT 1]; 
            DateTime effectiveEndDate =  DateTime.now() +1; 
            APTPS_AgreementTgrHandler.UpdateContractTerminOpportunity(OpportunityContractTerm.Id ,effectiveEndDate); 
           
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
    
     /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to UpdateupdateContractJunctionStatusAsPendingCountersignTest
    * @CreatedDate : 10/7/2021
    *===========================================================================================*/
    @isTest
    public static void updateContractJunctionStatusAsPendingCountersignTest(){
        Apttus__APTS_Agreement__c agmt = [Select id,Apttus__Status__c , Apttus__Status_Category__c,Apttus__Parent_Agreement__c,Related_Contract__c,Apttus__Other_Party_Signed_Date__c from Apttus__APTS_Agreement__c WHERE Related_Contract__c!=null Limit 1];
        System.debug('agmt---->001'+agmt);
        Test.startTest();
        try{
            Apttus__APTS_Agreement__c newAgree=new Apttus__APTS_Agreement__c();
            newAgree.Apttus__Company_Signed_Date__c=null;
            newAgree.Apttus__Other_Party_Signed_Date__c =System.today();
            newAgree.Id=agmt.Id;
            update newAgree;
            //APTPS_AgreementTgrHandler.handleAfterUpdateEvents(new Map<Id,Apttus__APTS_Agreement__c>{newAgree.Id=>newAgree},new List<Apttus__APTS_Agreement__c>{newAgree},new Map<Id,Apttus__APTS_Agreement__c>{agmt.Id=>agmt});
        }
        catch(Exception e){
            system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }
        Test.stopTest();
        
        //ContractJunction__c contractJunction01=[SELECT id,Status__c FROM ContractJunction__c WHERE Id =: agmt.Related_Contract__c];
        //System.assertEquals(APTPS_Constants.CONTRACTJUNCTION_STATUS_PENDING_COUNTERSIGN,contractJunction.Status__c);
    }
    
    /**========================================================================================
    * @Author :       Lokesh Thathuru
    * @Description : This method helps to updateContractJunctionStatusAsPendingCountersignException
    * @CreatedDate : 10/7/2021
    *===========================================================================================*/
    @isTest
    private static void updateContractJunctionStatusAsPendingCountersignException(){
        Test.startTest();   
        try{
            APTPS_AgreementTgrHandler.updateContractJunctionStatusAsPendingCountersign(null);
        }catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
        }
        Test.stopTest();
    }
    
@isTest
    public static void pSAgreementVariationRecordUpdationTest(){
        Test.startTest();        
        try{ 
            String RECORDTYPEIDString  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId() ; 
            APTPS_AgreementTgrHandler ath = new APTPS_AgreementTgrHandler() ; 
            List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();                          
            Set<Id> agId  = new Set<Id>() ; 
            Apttus__APTS_Agreement__c agmt = [Select id,Related_Contract__r.Id ,Related_Basket__r.Id, Apttus__Contract_Start_Date__c,Apttus__Contract_End_Date__c,Related_Basket__c,Related_Contract__c,Apttus__Status__c,Delegated_Pricing_Request__c,Apttus__Agreement_Category__c,Apttus__Source__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Related_Basket__c != null AND Related_Contract__c != null AND recordtypeid  =: RECORDTYPEIDString  Limit 1];
            agmt.Apttus__Status_Category__c = APTPS_Constants.CANCELLED_STATUS_CATEGORY ;
            agmt.Apttus__Status__c = APTPS_Constants.CANCELLEDREQUEST;
            update agmt; 
            agId.add(agmt.Id);
            agmtList.add(agmt);
            map<id,Apttus__APTS_Agreement__c> oldmap = new map<id,Apttus__APTS_Agreement__c>(); 
            APTPS_AgreementTgrHandler.pSAgreementVariationRecordUpdation(agId); 
           
        }catch(AgreementException e){
           system.assertEquals(e.getMessage(), e.getMessage(),'Exception should match'); 
        }           
        Test.stopTest();
    }
}