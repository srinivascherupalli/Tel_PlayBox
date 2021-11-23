/* Class Name      :   ActivateAgreementRecordStatusTest
   Sr.No.    Developer Name          Date          Story Description
   1. 		Divya Chilakabathini	02/12/2020	   Test Class for ActivateAgreementRecordStatus apex class
 */
@isTest
public class ActivateAgreementRecordStatusTest {
   private static final Id AGREEMENT_SCHEDULE_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();

	@isTest static void generateContractTest(){
        String productCode;
        Account acc =TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        //CREATE CONTACT 
        Contact contact = TestDataFactory.generateContact('TestPricing',acc.Id,'Active','TestDelegate',System.today(),'eMail');
        insert contact;
        contact.Email = 'test@tele2.com';
        update contact;
        
        
        
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
        
         contact c = [SELECT id from contact where id != NULL LIMIT 1];
        
       	ContractJunction__c oldContract=ApttusTestDataFactory.buildContractt(basket.csbb__Account__c,opp.id,basket.id);
		oldContract.DocuSign_Signer_2__c = c.id;
        oldContract.DocuSign_Signer_3__c = UserInfo.getUserId();
        oldContract.Customer_Primary_Contact__c = c.id;
        oldContract.Restrict_Conga_Flow__c = true;
        oldContract.isTransitionContract__c = false;
        oldContract.Status__c = 'Customer Review';
        update oldContract;
        //Apttus__APTS_Agreement__c agt = ApttusTestDataFactory.buildAgg(acc.id,oldContract.id,basket.id,AGREEMENT_SCHEDULE_RECORDTYPEID);
        Apttus__APTS_Agreement__c agtt = new Apttus__APTS_Agreement__c();
        agtt.Apttus__Agreement_Category__c = 'Pricing';
        agtt.APTPS_Agreement_Subcategory__c ='Price Book';
		agtt.Apttus__Subtype__c ='Standard';
		agtt.Apttus__Contract_Start_Date__c = System.today();
        agtt.Apttus__Account__c = acc.id;
        agtt.Related_Contract__c = oldContract.id;
        agtt.Related_Basket__c = basket.id;
        agtt.Apttus__Status_Category__c = 'In Effect';
        agtt.Apttus__Status__c = 'Activated';
        agtt.RecordTypeId = AGREEMENT_SCHEDULE_RECORDTYPEID;
        agtt.Apttus__Contract_End_Date__c = system.today();
        agtt.Auto_Created_by_Basket__c = true;
        insert agtt;
        
        
        
        
        oldContract.Related_Price_Schedule__c = agtt.Id;
        update oldContract;
        
        test.starttest();

        List<Apttus__APTS_Agreement__c> agrRec= [select id,Apttus__Status__c,Related_Contract__c,Related_Basket__c,Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c where Related_Contract__c =: oldContract.Id and Apttus__Agreement_Category__c = 'Pricing'];
        
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

        
        String result = ActivateAgreementRecordStatus.changeAgreementRecordStatus(oldContract.Id);
        system.assertEquals(agrRec[0].Apttus__Status__c, 'Activated');
        system.assertEquals(result, 'Success');
        ActivateAgreementRecordStatus.getContractStatus(oldContract.Id);
        test.stoptest();
    }
    
    	@isTest static void generateContractTestNegative(){
        String productCode;
        Account acc =TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        //CREATE CONTACT 
        Contact contact = TestDataFactory.generateContact('TestPricing',acc.Id,'Active','TestDelegate',System.today(),'eMail');
        insert contact;
        contact.Email = 'test@tele2.com';
        update contact;
        
        
        
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
        
         contact c = [SELECT id from contact where id != NULL LIMIT 1];
        
       	ContractJunction__c oldContract=ApttusTestDataFactory.buildContractt(basket.csbb__Account__c,opp.id,basket.id);
		oldContract.DocuSign_Signer_2__c = c.id;
        oldContract.DocuSign_Signer_3__c = UserInfo.getUserId();
        oldContract.Customer_Primary_Contact__c = c.id;
        oldContract.Restrict_Conga_Flow__c = true;
        oldContract.isTransitionContract__c = false;
        oldContract.Status__c = 'Customer Review';
        update oldContract;

        Apttus__APTS_Agreement__c agt = ApttusTestDataFactory.buildAgg(acc.id,oldContract.id,basket.id,AGREEMENT_SCHEDULE_RECORDTYPEID);

        
        oldContract.Related_Price_Schedule__c = agt.Id;
        update oldContract;
        
        test.starttest();

        List<Apttus__APTS_Agreement__c> agrRec= [select id,Apttus__Status__c,Related_Contract__c,Related_Basket__c,Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c where Related_Contract__c =: oldContract.Id and Apttus__Agreement_Category__c = 'Pricing'];
        
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

        
        String result = ActivateAgreementRecordStatus.changeAgreementRecordStatus(oldContract.Id);
        system.assertEquals(result, 'Failure');
        ActivateAgreementRecordStatus.getContractStatus(oldContract.Id);
        test.stoptest();
    }

}