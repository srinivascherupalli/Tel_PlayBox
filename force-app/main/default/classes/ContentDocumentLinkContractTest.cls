/*****************************************************************************
@Name: ContentDocumentLinkContract
@Author: Maqsood Alam.
@CreateDate: 11/08/2021.
@Description: Test class of ContentDocumentLinkContract.

*******************************************************************************/
@isTest
public with sharing class ContentDocumentLinkContractTest {
    public static Id agmtRecord;
    @istest
    Private static  void ContentDocumenContractTest(){
        Test.startTest();

        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'OpportunityTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;

        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.APTPS_Off_Shore_Restricted__c=false;
        acc.Customer_Status__c = 'Active';
        //acc.APTPS_Tier__c='1';
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
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;

        opp.Product_Type__c='Modular';

        opp.AccountId = acc.id;
        insert opp;
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        OpportunityContactRole oppContact = new OpportunityContactRole();
        oppContact.ContactId = contact.Id;
        oppContact.IsPrimary = true;
        oppContact.OpportunityId = basket.cscfga__Opportunity__c;
        oppContact.Role = 'Inside Sales Account Manager';
        insert oppContact;
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
        template.APXTConga4__Name__c = 'OrderForm';
        template.Sequence__c = 1;
        template.APXTConga4__Template_Group__c = 'Contract'; 
        insert template;
        APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
        query1.APXTConga4__Name__c = 'BasketSnapshot'; 
        insert query1;
        APXTConga4__Conga_Merge_Query__c query2 = new APXTConga4__Conga_Merge_Query__c();
        query2.APXTConga4__Name__c = 'AccountDetails'; 
        insert query2;
        APXTConga4__Conga_Merge_Query__c query3 = new APXTConga4__Conga_Merge_Query__c();
        query3.APXTConga4__Name__c = 'BasketProductDetails'; 
        insert query3;
        APXTConga4__Conga_Merge_Query__c query4 = new APXTConga4__Conga_Merge_Query__c();
        query4.APXTConga4__Name__c = 'OpportunityDetails'; 
        insert query4;
        ContractJunction__c record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        record.Email__c = oppContact.contact.Email;
        record.Phone__c = oppContact.contact.MobilePhone;
        record.Customer_Primary_Contact__c = oppContact.ContactId;
        record.Related_Basket__c = basket.id;
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.Name = 'CN' + basket.Name.substring(2);
        //record.Status__c='In Signature';
        insert record;
        list<ContentVersion> ContentVersionList = New list<ContentVersion>();
        for(Integer i=1; i<= 8; i++){
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
            cdl.LinkedEntityId = record.id;
            cdl.ContentDocumentId = document.Id;
            cdl.shareType = 'V';
            ContentDocumentLinkList.add(cdl);
        }
        insert ContentDocumentLinkList;
        system.assertEquals(8, ContentVersionList.size());


        Test.stopTest();       
    }
    @istest
    Private static  void shareAgreementVariationTest(){
        Test.startTest();

        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'OpportunityTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;

          //CREATE ACCOUNT
          Account acc = AccountTestFactory.buildAccount('Test Account') ;
          acc.APTPS_DocuSign_Restricted__c = false;
          acc.Customer_Status__c = 'ACTIVE';
          insert acc;  
          System.assert(acc.id != null);
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
          System.assert(contact.id != null);
          list<Opportunity> listoppty= new list<Opportunity>();
          //CREATE OPPORTUNITY
          Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
          opp.amount = 4600;
          opp.Product_Type__c='Modular';
          opp.AccountId = acc.id;
          insert opp;
          
          list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
          //Create Basket
          cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
          basket.csbb__Account__c = acc.id;
          basket.cscfga__Opportunity__c = opp.id;
          basket.Name = 'basket1';
          basket.csordtelcoa__Basket_Stage__c = 'Draft';
          lstbasket.add(basket);
          insert lstbasket;
          System.assert(lstbasket.Size()>0);
          
        ContractJunction__c Contractrecord = new ContractJunction__c();
          Contractrecord.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
          Contractrecord.Related_Basket__c = lstbasket[0].id;
          Contractrecord.CongaStatus__c = 'NotStarted';
         
          Contractrecord.Related_Opportunity__c = opp.Id;
          Contractrecord.Contract_Activated_Date__c = System.today();
          Contractrecord.Contract_Term_Months__c = 36;
          Contractrecord.Name = 'CN' ;
         
           Contractrecord.Status__c = 'Initiated';
           Contractrecord.Account__c = acc.id;
  
           insert Contractrecord; 
  
          list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
  
          string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
          string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
          Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated', Related_Contract__c=Contractrecord.Id);
          Agglist.add(agreement1); 
  
          Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
          Agglist.add(agreement2);
  
          list<Product2> prodlst =new list<Product2>();
          Product2 prod=new Product2();
          prod.Name='Adaptive Mobility';
  
          Product2 prod1=new Product2();
          prod1.Name='Adaptive Mobility1';
          prodlst.add(prod);
          prodlst.add(prod1);
          insert prodlst;
  
          insert  Agglist ;  
          agmtRecord = agreement1.Id;
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
       insert sales;
       system.runas(sales){
        ContentDocumentLinkContract.shareAgreementVariation(agmtRecord);
        ContentDocumentLinkContract.getUserEmail(sales.Id);
        system.assertEquals('salesuser@testsales.com', ContentDocumentLinkContract.getUserEmail(sales.Id));
    }
        Test.stopTest();       
    }
    @istest
    Private static  void AgreementVariationTest(){
        Test.startTest();

        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'OpportunityTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;

          //CREATE ACCOUNT
          Account acc = AccountTestFactory.buildAccount('Test Account') ;
          acc.APTPS_DocuSign_Restricted__c = false;
          acc.Customer_Status__c = 'ACTIVE';
          insert acc;  
          System.assert(acc.id != null);
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
          System.assert(contact.id != null);
          list<Opportunity> listoppty= new list<Opportunity>();
          //CREATE OPPORTUNITY
          Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
          opp.amount = 4600;
          opp.Product_Type__c='Modular';
          opp.AccountId = acc.id;
          insert opp;
          
          list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
          //Create Basket
          cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
          basket.csbb__Account__c = acc.id;
          basket.cscfga__Opportunity__c = opp.id;
          basket.Name = 'basket1';
          basket.csordtelcoa__Basket_Stage__c = 'Draft';
          lstbasket.add(basket);
          insert lstbasket;
          System.assert(lstbasket.Size()>0);
          
        ContractJunction__c Contractrecord = new ContractJunction__c();
          Contractrecord.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
          Contractrecord.Related_Basket__c = lstbasket[0].id;
          Contractrecord.CongaStatus__c = 'NotStarted';
         
          Contractrecord.Related_Opportunity__c = opp.Id;
          Contractrecord.Contract_Activated_Date__c = System.today();
          Contractrecord.Contract_Term_Months__c = 36;
          Contractrecord.Name = 'CN' ;
         
           Contractrecord.Status__c = 'Initiated';
           Contractrecord.Account__c = acc.id;
  
           insert Contractrecord; 
  
          list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
  
          string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
          string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
          Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Being Amended', Related_Contract__c=Contractrecord.Id);
          Agglist.add(agreement1); 
          Apttus__APTS_Agreement__c agreementVar = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne', Related_Contract__c=Contractrecord.Id, Apttus__Version__c = 1);
          Agglist.add(agreementVar); 
  
          Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
          Agglist.add(agreement2);
  
          list<Product2> prodlst =new list<Product2>();
          Product2 prod=new Product2();
          prod.Name='Adaptive Mobility';
  
          Product2 prod1=new Product2();
          prod1.Name='Adaptive Mobility1';
          prodlst.add(prod);
          prodlst.add(prod1);
          insert prodlst;
  
          insert  Agglist ;  
        agmtRecord = agreement1.Id;
        Map<Id,Id> amendedAgmts= new Map<Id,Id>();
        amendedAgmts.put(agreement1.Id,agreementVar.id);
        APTPS_CreateAgreementVariationController aptsVariationController= new APTPS_CreateAgreementVariationController ();
        aptsVariationController.createRelatedAgreement(amendedAgmts);
        ContentDocumentLinkContract.updateAgreementOnRetract(agreementVar);
        system.assertEquals('Adaptive Mobility', prod.Name);
        Test.stopTest();       
    }
    //DIGI-19515 Start
    @istest
    Private static  void shareAgreementList(){
        Test.startTest();
        list<Disabled_Triggers__c> triggersDisabled = new List<Disabled_Triggers__c>();
        Disabled_Triggers__c disabledTriggersProfile01 = new Disabled_Triggers__c();
        disabledTriggersProfile01.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile01.Trigger_Name_List1__c = 'OpportunityTrigger';
        triggersDisabled.add(disabledTriggersProfile01);
        insert triggersDisabled;
        
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.APTPS_DocuSign_Restricted__c = false;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;  
       
        
        list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        system.debug('AGREEMENT_KEYFACTS_RECORDTYPEID::'+AGREEMENT_KEYFACTS_RECORDTYPEID);
        RecordType sRec = [SELECT id,sObjectType,RecordType.DeveloperName from RecordType where id = :AGREEMENT_KEYFACTS_RECORDTYPEID];
        system.debug('sRec::'+sRec);
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
        Agglist.add(agreement1); 
        
        Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
        Agglist.add(agreement2);
        insert  Agglist ; 
        system.debug('retractedAgreement.RecordType.DeveloperName::'+Agglist[0].recordtypeid);
        Agglist[0].Apttus__Parent_Agreement__c = Agglist[1].id;
        update Agglist;
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        system.runas(sales){
            ContentDocumentLinkContract.shareAgreements(acc.id);
            Set<string> setofAcc=new Set<string>();
            setofAcc.add(acc.id);
             ContentDocumentLinkContract.shareAgreementsBulk(setofAcc);
            system.debug('retractedAgreement.RecordType.DeveloperName::'+Agglist[0].RecordType.DeveloperName);
            Boolean sShared = ContentDocumentLinkContract.updateAgreementOnRetract(Agglist[0]);
            system.assertEquals('salesuser@testsales.com', ContentDocumentLinkContract.getUserEmail(sales.Id));
        }
        Test.stopTest();       
    }
    //DIGI-19515 End  
}