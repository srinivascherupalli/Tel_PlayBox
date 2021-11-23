/*********************************************************************************************************************************
* Class Name      :   AgreementRecordCreationDSATest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.      Divya Chilakabathini    03/11/2020     Test Class for AgreementRecordCreationDSA apex class
2.      Shashank   				10/04/2021	 	DIGI-20842: Enabling Adobe Sign Flow
*/

@isTest
public class AgreementRecordCreationDSATest {
    
    @isTest static void generateContractTest() {
        String productCode;
        
        Account acc = TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        //CREATE CONTACT 
        Contact contact = TestDataFactory.generateContact('TestPricing',acc.Id,'Active','TestDelegate',System.today(),'eMail');
        insert contact;
        contact.Email = 'test@tele2.com';
        update contact;
        
       	Contact contactPrimaryContact = APTPS_TestClassData.contactRecord('George','Washington',acc.id);
        
        
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
        
        ContractJunction__c oldContract1=ApttusTestDataFactory.buildContractt(basket.csbb__Account__c,opp.id,basket.id);
        oldContract1.DocuSign_Signer_2__c = c.id;
        oldContract1.DocuSign_Signer_3__c = UserInfo.getUserId();
        oldContract1.Customer_Primary_Contact__c = c.id;
        oldContract1.Restrict_Conga_Flow__c = true;
        oldContract1.isTransitionContract__c = false;
        //oldContract.Status__c = 'Customer Review';
        update oldContract1;
        
        test.starttest();
        
        ContractJunction__c cj = [Select Id,Related_Basket__c,DocuSign_Signer_2__c,Account__c,Related_Opportunity__c,DocuSign_Signer_3__c,Customer_Primary_Contact__c From ContractJunction__c Where Id =: oldContract.id LIMIT 1];
                ContractJunction__c cjj = [Select Id,Related_Basket__c,DocuSign_Signer_2__c,Account__c,Related_Opportunity__c,DocuSign_Signer_3__c,Customer_Primary_Contact__c From ContractJunction__c Where Id =: oldContract1.id LIMIT 1];

        system.debug('cj:'+cj);
        AgreementRecordCreationDSA.createAgreemnetDSASChrecordandGenratedoc(cj);
        
        Apttus__APTS_Agreement__c agrRec= [select id,APTPS_Sales_Account_Executive__c from Apttus__APTS_Agreement__c where Related_Contract__c =: cj.Id limit 1];
    system.debug('UserInfo.getUserId()' + UserInfo.getUserId());//EDGE-198932 Defect Fix
    system.debug('agrRec' + agrRec.APTPS_Sales_Account_Executive__c);//EDGE-198932 Defect Fix
    system.assert(agrRec.APTPS_Sales_Account_Executive__c == UserInfo.getUserId());//EDGE-198932 Defect Fix
        agrRec.APTPS_Customer_Primary_Contact__c = contactPrimaryContact.Id;
        update agrRec;
        system.assertEquals(agrRec!=null, true); 
        Apttus_DocuApi__DocuSignDefaultRecipient2__c ds = [select Id from Apttus_DocuApi__DocuSignDefaultRecipient2__c where Apttus_CMDSign__AgreementId__c =: agrRec.id limit 1];
        system.assertEquals(ds!=null, true); 
        Apttus__APTS_Agreement__c psAgr = ApttusTestDataFactory.buildAgreement(acc,contact,opp,cjj);
		psAgr.APTPS_Customer_Primary_Contact__c = contactPrimaryContact.Id;
        update psAgr;
        AgreementRecordCreationDSA.createOrderForm(psAgr.Id);
        
        test.stopTest();
    }
   /* 
        @isTest static void generateContractTestNegative() {
        String productCode;
        
        Account acc = TestDataFactory.generateAccount();
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


        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 pb = ApttusTestDataFactory.buildPricebook2();
        
        PricebookEntry pbEntry = ApttusTestDataFactory.buildPricebookEntry(prd,pricebookId);

        String result = AgreementRecordCreationDSA.getProductFamilies(basket.id,'DSA');    
        system.assertEquals(result==null,true); 
        
    }*/
}