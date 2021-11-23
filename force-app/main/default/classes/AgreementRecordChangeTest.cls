/**
* @Author   :   Lokesh, Monali
* @Date     :   March 2021
* @Desc     :   This class is written for testing AgreementRecordChange class.
* @US       :   EDGE-205307
* */
@isTest
public with sharing class AgreementRecordChangeTest {
    
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
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        basket.csordtelcoa__Basket_Stage__c='Contract Accepted';
        insert basket;
        
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = basket.csbb__Account__c;
        //oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        oldContract.Related_Basket__c=basket.id;
        oldContract.Status__c='Contract Accepted';
        insert oldContract;
        
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Delegated_Pricing_Request__c = dpr.id,
            Apttus__Related_Opportunity__c = opp.Id,
            Name ='Test');
        insert agreement;
        
        //EDGE-194530
        string RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
         Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(
            recordtypeid=RECORDTYPEID,
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Apttus__Status__c ='Request',
            Delegated_Pricing_Request__c = dpr.id,
            Apttus__Related_Opportunity__c = opp.Id,
            Apttus__Parent_Agreement__c = agreement.Id,
            Name ='TestPS');
        insert agreement1;
        
        string RECORDTYPEID1  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
         Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(
            recordtypeid=RECORDTYPEID1,
            Apttus__Account__c = acc.id,
            Apttus__Status_Category__c ='Request',
            Apttus__Status__c ='Request',
            Delegated_Pricing_Request__c = dpr.id,
            Apttus__Related_Opportunity__c = opp.Id,
            Apttus__Parent_Agreement__c = agreement.Id,
            Related_Basket__c=basket.id,
            Related_Contract__c=oldContract.id,
            Name ='TestPS1');
        insert agreement2;
        
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
        
        //CREATE FA AGREEMENT ASSOCIATION
        FA_Agreement_Association__c faAssociation = new FA_Agreement_Association__c();
        faAssociation.Name = 'Test FA Association';
        faAssociation.FA__c = fAgreement.ID;
        faAssociation.Agreement__c = agreement.ID;          
        insert faAssociation;      
      
        FA_Agreement_Association__c faAssociation3 = new FA_Agreement_Association__c();
        faAssociation3.Name = 'Test FA Association';
        faAssociation3.FA__c = fAgreement1.ID;
        faAssociation3.Agreement__c = agreement.ID;          
        insert faAssociation3; 
        
        Apttus__APTS_Related_Agreement__c agRelated = new Apttus__APTS_Related_Agreement__c();
        agRelated.Apttus__APTS_Contract_To__c = agreement1.Id ;   
        agRelated.Apttus__APTS_Contract_From__c =  agreement.ID;
        insert agRelated;
    }
    
    @isTest
    public static void updatePsagreement(){
        Test.startTest();
        list<Apttus__APTS_Agreement__c> agmt = [Select id, name, Apttus__Status_Category__c,Apttus__Status__c,Delegated_Pricing_Request__c,Related_Basket__c,Related_Contract__c,APTPS_Record_Type_Name__c from Apttus__APTS_Agreement__c ];
		AgreementRecordChange.changeAgreement(agmt);
        System.assertEquals('Request',agmt[0].Apttus__Status__c);
        System.assert(agmt.Size()>0);
        Test.stopTest();
    }
   
}