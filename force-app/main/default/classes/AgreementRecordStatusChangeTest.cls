/* Class Name      :   AgreementRecordStatusChangeTest
   Sr.No.    Developer Name          Date          Story Description
   1.     Divya Chilakabathini  03/11/2020     Test Class for AgreementRecordStatusChange apex class
   
 */

@isTest 
public without sharing class AgreementRecordStatusChangeTest {
    private static final Id AGREEMENT_SCHEDULE_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();

    @isTest static void generateAgreementTest(){
        String productCode;
        Account acc =TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Contact_Status__c = 'Active',
            Pref_Comm_Method__c = 'Email'
        );
        Insert contact;
        
        
        
        Opportunity opp  = ApttusTestDataFactory.buildOpportunity(acc);
        insert opp;
        
        //CREATE OPP CONTACT ROLE
        OpportunityContactRole ocr = ApttusTestDataFactory.buildOpportunityContactRole(contact,opp);
        insert ocr; 
        
        cscfga__Product_Definition__c pd = TestDataFactory.generateProductDefinition('DMCAT_ProductSpecification_000965','Test Record');
        
        
        // CREATE MARKETABLE OFFERS
        Marketable_Offer__c moMob = ApttusTestDataFactory.buildMarketableOffer();
        insert moMob;
        
        // CREATE PRODUCT
        Product2 prd = TestDataFactory.generateProduct('Adaptive Mobility',true,productCode);
        insert prd;
        prd.Telstra_Marketable_Product_Family__c = 'Adaptive Mobility'; 
        update prd;
        
        cscfga__Product_Basket__c basket = ApttusTestDataFactory.buildProductBasket(acc,opp);
        insert basket;
        
        cscfga__Product_Configuration__c pconfig = ApttusTestDataFactory.buildProductConfiguration(moMob,pd,basket);
        insert pconfig;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 pb = ApttusTestDataFactory.buildPricebook2();
        
        PricebookEntry pbEntry = ApttusTestDataFactory.buildPricebookEntry(prd,pricebookId);
        
        cscfga__Attribute__c attr0 = ApttusTestDataFactory.buildAtrribute(pconfig);
        
        OpportunityLineItem oli = ApttusTestDataFactory.generateOpportunityLineItem(pbEntry,basket,pconfig,attr0);

        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Order Form',
            PathOnClient = 'Order Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        ContentVersion contentVersionn = new ContentVersion(
            Title = 'Form',
            PathOnClient = 'Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersionn; 
        
        
        List<Apttus__APTS_Template__c> apttem = ApttusTestDataFactory.buildApttusTemplate();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        
        ContractJunction__c oldContract=ApttusTestDataFactory.buildContractt(basket.csbb__Account__c,opp.id,basket.id);
        oldContract.DocuSign_Signer_2__c = c.id;
        oldContract.DocuSign_Signer_3__c = UserInfo.getUserId();
        oldContract.Customer_Primary_Contact__c = c.id;
        oldContract.Restrict_Conga_Flow__c = true;
        oldContract.isTransitionContract__c = false;
        //oldContract.Status__c = 'Customer Review';
        update oldContract;
        
        Apttus__APTS_Agreement__c agt = ApttusTestDataFactory.buildAgg(acc.id,oldContract.id,basket.id,AGREEMENT_SCHEDULE_RECORDTYPEID);
        agt.Apttus__Status_Category__c = 'Request';
        agt.Apttus__Status__c = 'Request';  
        agt.Apttus__Version_Number__c = 0.0;//EDGE-193826
        update agt;
        
        oldContract.Related_Price_Schedule__c = agt.Id;
        update oldContract;
        
        
        test.starttest();

        List<Apttus__APTS_Agreement__c> agrRec= [select id,Apttus__Status__c,Related_Contract__c,Related_Basket__c,Apttus__Parent_Agreement__c,Apttus__Version_Number__c from Apttus__APTS_Agreement__c where Related_Contract__c =: oldContract.Id limit 1];
        system.debug('agrRec::' + agrRec);
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cc = new List<ContentDocumentLink>();
        ContentDocumentLink ccd = new ContentDocumentLink();
        ccd.LinkedEntityId = agrRec[0].Id;        
        ccd.ContentDocumentId = documents1[0].Id;
        ccd.shareType = 'V';
        cc.add(ccd);
        ContentDocumentLink ccdd = new ContentDocumentLink();
        ccdd.LinkedEntityId = agrRec[0].Id;        
        ccdd.ContentDocumentId = documents1[1].Id;
        ccdd.shareType = 'V';
    cc.add(ccdd);
        insert cc; 

        List<Id> contractIds = new List<Id>();
        List<Id> prdBsktIds = new List<Id>();
        List<Id> dsaAgrIds = new List<Id>();
        List<Id> psIds = new List<Id>();
        set<Id> cjActiveId = new set<Id>();
        list<Id> cjId = new list<id>();
        
        for(Apttus__APTS_Agreement__c a : agrRec){
            prdBsktIds.add(a.Related_Basket__c);
            //dsaAgrIds.add(a.Apttus__Parent_Agreement__c);
            contractIds.add(a.Related_Contract__c);
            psIds.add(a.Id);
            cjId.add(a.Related_Contract__c);
        }
        system.assertEquals(agrRec[0].Apttus__Status__c, 'Request');
        AgreementRecordStatusChange.changeAgreementStatus(agrRec);
        
        AgreementRecordStatusChange.activateAgreementDocuments(dsaAgrIds,psIds,cjId,cjActiveId);

        //AgreementRecordStatusChange.generateChatterPost(agrRec[0].Id);

        test.stoptest();
        
        
    }
    // Added test method for EDGE-184432
    @isTest static void activateDPRAgreementDocumentsTest(){
           Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
       User u = new User(Alias = 'admin', Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName='admin@test.com.portfoliotest');
        
        u.Phone = '3433233223';
        
        insert u;
        
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
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Contact_Status__c = 'Active',
            Pref_Comm_Method__c = 'Email'
        );
        Insert contact;
        //list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test Adaptive Opty';
        opp.amount = 4600;
        opp.OwnerId = u.Id;
       insert opp;
       
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = contact.Id;
        oppContRole.OpportunityId = opp.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;

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
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
        basket2.cscfga__Opportunity__c = opp.id;
        basket2.Name = 'basket2';
        lstbasket.add(basket2);
        
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
        
         list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
             
            string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
            string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
            Apttus__APTS_Agreement__c agreementDSA = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', Delegated_Pricing_Request__c=dpr.id,APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Authoring',Apttus__Status__c='Author Contract',Apttus__Version_Number__c=0.0);//EDGE-193826 - Added version number
            // Agglist.add(agreementDSA); 
             insert agreementDSA;
            
           Apttus__APTS_Agreement__c agreementPS = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Parent_Agreement__c=agreementDSA.id,Apttus__Related_Opportunity__c =opp.id,Delegated_Pricing_Request__c=dpr.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Authoring',Apttus__Status__c='Author Contract',Apttus__Version_Number__c=0.0);//EDGE-193826 - Added version number
            Agglist.add(agreementPS);
            Apttus__APTS_Agreement__c agreementPS1 = new Apttus__APTS_Agreement__c(APTPS_Customer_Primary_Contact__c=contact.Id,recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Parent_Agreement__c=agreementDSA.id,Apttus__Related_Opportunity__c =opp.id,Delegated_Pricing_Request__c=dpr.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Authoring',Apttus__Status__c='Author Contract',Apttus__Version_Number__c=1.0);//EDGE-202386 - Added version number
                        
             Agglist.add(agreementPS1);
        
        insert  Agglist ; 
        
        String jsona='test';
        list<Id> dsaAgrIds= new list<Id>();
        list<Id> psIds= new list<Id>();
        dsaAgrIds.add(agreementDSA.id);
        psIds.add(Agglist[0].id);
        list<Apttus__APTS_Agreement__c> agreementRec= new list<Apttus__APTS_Agreement__c>();
        agreementRec.add(Agglist[0]);
        list<Apttus__APTS_Agreement__c> agreementRecV= new list<Apttus__APTS_Agreement__c>();
        agreementRecV.add(agreementPS1);
        Attachment attDSA = new Attachment();
                attDSA.Name =  'DSA';
                attDSA.ParentId = agreementDSA.id;
                attDSA.Body = blob.valueof(jsona);
                insert attDSA;
        
        Attachment attPS = new Attachment();
                attPS.Name =  'Price Schedule';
                attPS.ParentId = Agglist[0].id;
                attPS.Body = blob.valueof(jsona);
                insert attPS;
                test.starttest();
                
                /*Agglist[0].Apttus__Status_Category__c='In Signatures';
                Agglist[0].Apttus__Status__c='Fully Signed';
                update Agglist[0];*/
                AgreementRecordStatusChange.changeAgreementStatus(agreementRec);
        		AgreementRecordStatusChange.changeAgreementStatus(agreementRecV);
                AgreementRecordStatusChange.activateDPRAgreementDocuments(dsaAgrIds,psIds);
                AgreementRecordStatusChange.generateChatterPost(agreementPS1.Id); //EDGE-202386 
         		AgreementRecordStatusChange.generateChatterPost(agreementDSA.Id); //EDGE-202386
                test.stoptest(); 
                system.debug('Agglist[0]'+Agglist[0]);
        Apttus__APTS_Agreement__c agreementPSRecord=[select id,Apttus__Status_Category__c,Apttus__Status__c from Apttus__APTS_Agreement__c where id=:Agglist[0].id limit 1];
        Attachment attRecord=[select id,name from attachment where id=:attDSA.id];
        system.assertEquals(attRecord.name,'DSA');// Assert for EDGE-184432
        

    }
    
    @isTest static void checkgenerateChatterPost(){
        
         String productCode;
        Account acc =TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Contact_Status__c = 'Active',
            Pref_Comm_Method__c = 'Email'
        );
        Insert contact;
        
         
        
        
         Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
       User u = new User(Alias = 'admin', Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName='admin@test.com.portfoliotest');
        
        u.Phone = '3433233223';
        
        insert u;
        
        Opportunity opp  = ApttusTestDataFactory.buildOpportunity(acc);
        opp.OwnerId=u.id;
        insert opp;
        
        //CREATE OPP CONTACT ROLE
        OpportunityContactRole ocr = ApttusTestDataFactory.buildOpportunityContactRole(contact,opp);
        insert ocr; 
        
        cscfga__Product_Definition__c pd = TestDataFactory.generateProductDefinition('DMCAT_ProductSpecification_000965','Test Record');
        
        
        // CREATE MARKETABLE OFFERS
        Marketable_Offer__c moMob = ApttusTestDataFactory.buildMarketableOffer();
        insert moMob;
        
        // CREATE PRODUCT
        Product2 prd = TestDataFactory.generateProduct('Adaptive Mobility',true,productCode);
        insert prd;
        prd.Telstra_Marketable_Product_Family__c = 'Adaptive Mobility'; 
        update prd;
        
        cscfga__Product_Basket__c basket = ApttusTestDataFactory.buildProductBasket(acc,opp);
        insert basket;
        
        cscfga__Product_Configuration__c pconfig = ApttusTestDataFactory.buildProductConfiguration(moMob,pd,basket);
        insert pconfig;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 pb = ApttusTestDataFactory.buildPricebook2();
        
        PricebookEntry pbEntry = ApttusTestDataFactory.buildPricebookEntry(prd,pricebookId);
        
        cscfga__Attribute__c attr0 = ApttusTestDataFactory.buildAtrribute(pconfig);
        
        OpportunityLineItem oli = ApttusTestDataFactory.generateOpportunityLineItem(pbEntry,basket,pconfig,attr0);

        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Order Form',
            PathOnClient = 'Order Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        ContentVersion contentVersionn = new ContentVersion(
            Title = 'Form',
            PathOnClient = 'Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersionn; 
        
        
        List<Apttus__APTS_Template__c> apttem = ApttusTestDataFactory.buildApttusTemplate();
        contact c = [SELECT id from contact where id != NULL LIMIT 1];
        
        ContractJunction__c oldContract=ApttusTestDataFactory.buildContractt(basket.csbb__Account__c,opp.id,basket.id);
        oldContract.DocuSign_Signer_2__c = c.id;
        oldContract.DocuSign_Signer_3__c = UserInfo.getUserId();
        oldContract.Customer_Primary_Contact__c = c.id;
        oldContract.Restrict_Conga_Flow__c = true;
        oldContract.isTransitionContract__c = false;
        //oldContract.Status__c = 'Customer Review';
        update oldContract;
        
                list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
             
            string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
            string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
            Apttus__APTS_Agreement__c agreementDSA = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', Related_Contract__c= oldContract.id, APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Authoring',Apttus__Status__c='Author Contract',Apttus__Version_Number__c=0.0);//EDGE-193826 - Added version number
            // Agglist.add(agreementDSA); 
             insert agreementDSA;
        
         test.starttest();
        Apttus__APTS_Agreement__c agrRec= [select id,Apttus__Status__c,Related_Contract__c,Apttus__Related_Opportunity__r.Id,Related_Basket__c,Apttus__Parent_Agreement__c,Apttus__Version_Number__c from Apttus__APTS_Agreement__c where id=:agreementDSA.id limit 1];
        system.debug('agrRec::' + agrRec);
        system.assertEquals('Author Contract', agrRec.Apttus__Status__c);
        //system.assertEquals(attRecord.name,'DSA');
        AgreementRecordStatusChange.generateChatterPost(agrRec.id);
        test.stoptest();

    }
}