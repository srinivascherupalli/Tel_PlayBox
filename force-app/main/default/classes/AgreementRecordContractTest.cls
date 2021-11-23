/**
 * @Author   :   Lokesh
 * @Date     :   Sept 2020
 * @Desc     :   This class is written for testing AgreementRecordContract class.
 * @US       :   EDGE-165484, EDGE-165483,EDGE-165485
 * 
 * */
@IsTest
public with sharing class AgreementRecordContractTest {
    
    @testSetup
    static void setupTestData(){
        
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.APTPS_DocuSign_Restricted__c = false;
        acc.Customer_Status__c = 'Active';

        insert acc;
        
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+61123456789',
            Email = 'test@tele2.com'   
        );
        Insert contact;
    
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp';
        opp.AccountID = acc.id;
        opp.StageName = 'Committed';
        opp.CloseDate = System.today();
        opp.Product_Type__c = 'Modular';
        opp.Amount = 4600;
        insert opp;
   
        
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
       basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        lstbasket.add(basket);
       // insert basket;
        
         //Create Basket
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
       basket2.cscfga__Opportunity__c =opp.id;
        basket2.Name = 'basket2';
        lstbasket.add(basket2);
        
        insert lstbasket;
        
        Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility Device';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
        
        cscfga__Product_Configuration__c prodconfig=new cscfga__Product_Configuration__c();
        prodconfig.Name='Next Generation Enterprise Mobility_700000562533';
        prodconfig.cscfga__Product_Basket__c=lstbasket[0].id;
        prodconfig.Marketable_Offer__c=Marketoffer.Id;
        insert prodconfig;
        
        ContractJunction__c contractJunctionRec = new ContractJunction__c();
        contractJunctionRec.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contractJunctionRec.Related_Basket__c = basket.id;
        contractJunctionRec.CongaStatus__c = 'NotStarted';
        
        contractJunctionRec.Account__c = basket.csbb__Account__c;
        contractJunctionRec.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        contractJunctionRec.Contract_Activated_Date__c = System.today();
        contractJunctionRec.Contract_Term_Months__c = 36;
        contractJunctionRec.Name = 'CN' + basket.Name.substring(2);
        contractJunctionRec.GPTVersion__c=1.2;
        contractJunctionRec.OFTVersion__c=1.4;
        contractJunctionRec.BSAVersion__c=1.3;
        contractJunctionRec.isDSAGenerated__c=true;
        contractJunctionRec.Status__c='In Effect';
        //contractJunctionRec.Account__r.Owner.Id=acc.id;
        insert contractJunctionRec;
        
         ContractJunction__c contractJunctionRec1 = new ContractJunction__c();
        contractJunctionRec1.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contractJunctionRec1.Related_Basket__c = basket.id;
        contractJunctionRec1.CongaStatus__c = 'NotStarted';
        
        contractJunctionRec1.Account__c = basket.csbb__Account__c;
        contractJunctionRec1.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        contractJunctionRec1.Contract_Activated_Date__c = System.today();
        contractJunctionRec1.Contract_Term_Months__c = 12;
        contractJunctionRec1.Name = 'CN' + basket.Name.substring(2);
        contractJunctionRec1.GPTVersion__c=1.2;
        contractJunctionRec1.OFTVersion__c=1.4;
        contractJunctionRec1.BSAVersion__c=1.3;
        contractJunctionRec1.isDSAGenerated__c=true;
        contractJunctionRec1.Status__c='In Effect';
        //contractJunctionRec.Account__r.Owner.Id=acc.id;
        insert contractJunctionRec1;
        
        Product2 prod=new Product2();
        prod.name='Adaptive Mobility';
        prod.Marketable_Product_Family__c='Adaptive Mobility';
        insert prod;
       
        test.starttest();
        list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
        string AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        string AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_SA_RECORDTYPEID,Apttus__Account__c=contractJunctionRec.Account__c,Apttus__Contract_End_Date__c=system.today(),name = 'Test', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne');
        Agglist.add(agreement1);
        Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_Schedule_RECORDTYPEID,Apttus__Account__c=contractJunctionRec.Account__c,Apttus__Contract_End_Date__c=system.today(),name = 'Test', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne');
        Agglist.add(agreement2);
        
     //   insert Agglist;
        Marketable_Offer__c offerRec=new Marketable_Offer__c();
        offerRec.Name='Adaptive Mobility Device';
        offerRec.Contract_Type__c='DSA';
        offerRec.Product_Family__c='Adaptive Mobility';
        offerRec.Offer_ID__c='DMCAT_Offer_0012';
        insert offerRec;
        
        list<cscfga__Product_Basket__c> proddlst=new list<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c prodbasket =new cscfga__Product_Basket__c();
        prodbasket.Name='Next Generation Enterprise';
        //insert prodbasket;
        
        cscfga__Product_Basket__c prodbasket1 =new cscfga__Product_Basket__c();
        prodbasket1.Name='GOOGLE PIXEL 3';
        //insert prodbasket1;
        proddlst.add(prodbasket);
        proddlst.add(prodbasket1);
        insert proddlst;
        
       /*  list<Apttus__agreementlineitem__c> insertAgreementlineitems = new list<Apttus__agreementlineitem__c>();
             Apttus__agreementlineitem__c AgreementLineItem = new Apttus__agreementlineitem__c();
                AgreementLineItem.Apttus__AgreementId__c =Agglist[1].id;
                AgreementLineItem.Apttus__ProductId__c = prod.Id;
           Apttus__agreementlineitem__c AgreementLineItem1 = new Apttus__agreementlineitem__c();
                AgreementLineItem1.Apttus__AgreementId__c =Agglist[1].id;
                AgreementLineItem1.Apttus__ProductId__c = prod.Id;
        insertAgreementlineitems.add(AgreementLineItem);
                insertAgreementlineitems.add(AgreementLineItem1);
        insert insertAgreementlineitems; */
        
        list<ContentVersion> ContentVersionList = New list<ContentVersion>();
        for(Integer i=1; i<= 9; i++){
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins'+i+'.pdf',
                PathOnClient = 'Penguins'+i+'.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            ContentVersionList.add(contentVersion);
        }
        insert ContentVersionList;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        list<ContentDocumentLink> ContentDocumentLinkList = New list<ContentDocumentLink>();
        for(ContentDocument document : documents){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = contractJunctionRec.id;
            cdl.ContentDocumentId = document.Id;
            cdl.shareType = 'V';
            ContentDocumentLinkList.add(cdl);
        }
        insert ContentDocumentLinkList;
        insert new EnvironmentVariable__c(Name= 'ContractInitiate', Value__c = '1');
        insert new EnvironmentVariable__c(Name= 'AgreementGenerateContract', Value__c = '1');
        Insert new CustomConfigurationOptions__c(Name = 'ContractInitiate',Enrichment_Basket_Stage__c ='Contract Initiated' , External_Id__c ='7842', MarketableOfferList__c = '', Opportunity_Stage__c = 'Propose');
        
          //create ContentDocumentLink  record 
        list<ContentDocumentLink> ContentDocumentLinkList1 = New list<ContentDocumentLink>();
        for(ContentDocument document : documents){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = contractJunctionRec1.id;
            cdl.ContentDocumentId = document.Id;
            cdl.shareType = 'V';
            ContentDocumentLinkList1.add(cdl);
        }
        insert ContentDocumentLinkList1;
       
       test.stoptest();
        
    }
    
    @isTest
    static void contractJunctionRecordWithStatus(){
        Test.startTest();
        try{
             List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c'
            + ' where BSAVersion__c > 0';
        List<ContractJunction__c> contractJunctionList = Database.query(soql);
            contractJunctionList[0].Status__c = 'In Effect';
        contractJunctionList[0].Agreement_Number__c = '1';
        update contractJunctionList;
        AgreementRecordContract.createAgreementForContract(contractJunctionList);
         System.assert(contractJunctionList.Size()>0);
         }
          catch(Exception e){
              System.debug(e.getMessage());
        
          }
        Test.stopTest();
        }
    @isTest
    static void contractJunctionRecorcheck(){
        Test.startTest();
        try{
             List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c'
            + ' where BSAVersion__c > 0';
        List<ContractJunction__c> contractJunctionList = Database.query(soql);
            contractJunctionList[0].Status__c = 'Contract Accepted';
        contractJunctionList[0].Agreement_Number__c = '1';
        update contractJunctionList;
        AgreementRecordContract.createAgreementForContract(contractJunctionList);
         System.assert(contractJunctionList.Size()>0);
         }
          catch(Exception e){
              System.debug(e.getMessage());
        
          }
        Test.stopTest();
        }
     @isTest
    static void contractJunctionlineitemCreation(){
        Test.startTest();
        try{
             List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c'
            + ' where BSAVersion__c > 0';
        List<ContractJunction__c> contractJunctionList = Database.query(soql);
            contractJunctionList[0].Status__c = 'Contract Accepted';
        contractJunctionList[0].Agreement_Number__c = '1';
        update contractJunctionList;
       Apttus__APTS_Agreement__c agmtrec=[select id,name from Apttus__APTS_Agreement__c where Apttus__Agreement_Category__c='Pricing' limit 1];
            agmtrec.Apttus__Parent_Agreement__c=null;
            delete agmtrec;
        AgreementRecordContract.createAgreementForContract(contractJunctionList);
         System.assert(contractJunctionList.Size()>0);
         }
          catch(Exception e){
              System.debug(e.getMessage());
          }
        Test.stopTest();
        
    }
    
}