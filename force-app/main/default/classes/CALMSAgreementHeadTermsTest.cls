@isTest
public class CALMSAgreementHeadTermsTest {
	@isTest
    static void testCreateHeadTermRecord(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '0423456789',
            Email = 'test@tele2.com'   
        );
        insert contact;
        
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        
        insert pbe;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        
        
        //create Product Configuration
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        
        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Description__c = 'test Description 1';
        config1.cscfga__Contract_Term__c = 24;
        
        cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
        config2.cscfga__Product_Basket__c = basket.id;
        config2.cscfga__Description__c = 'test Description 2';
        config2.cscfga__Contract_Term__c = 12;
        
        
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>{config, config1, config2};
            update configList;
        
        //Creation of Attributes with different attrbiutes Name and values.
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config0:configList){
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config0.id);
            attList.add(attr0);
            
            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config0.id);
            attList.add(attr1);
            
            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', config0.id);
            attList.add(attr2);
            
            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '300.00', config0.id);
            attList.add(attr3);
            
            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('ContractTerms', '500.00', config0.id);
            attList.add(attr4);
            
            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('ProductStatus', 'Lost', config0.id);
            attList.add(attr5);
            
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('RC', '700.00', config0.id);
            attList.add(attr6);
            
            cscfga__Attribute__c attr8 = ProductTestFactory.buildAttribute('Product', 'testproduct', config0.id);
            attList.add(attr8);
            
            cscfga__Attribute__c attr9 = ProductTestFactory.buildAttribute('AcquisitionRevenue', '100.00', config0.id);
            attList.add(attr9);
            
            cscfga__Attribute__c attr10 = ProductTestFactory.buildAttribute('AvgAnnualisedRevenue', '200.00', config0.id);
            attList.add(attr10);
            
            cscfga__Attribute__c attr11 = ProductTestFactory.buildAttribute('Competitor', '300.00', config0.id);
            attList.add(attr11);
            
            cscfga__Attribute__c attr12 = ProductTestFactory.buildAttribute('CurrentRevenue', '400.00', config0.id);
            attList.add(attr12);
            
            cscfga__Attribute__c attr13 = ProductTestFactory.buildAttribute('IncrementalRevenue', '600.00', config0.id);
            attList.add(attr13);
            
            cscfga__Attribute__c attr14 = ProductTestFactory.buildAttribute('Domain', 'FIXED TELEPHONY', config0.id);
            attList.add(attr14);
            
            cscfga__Attribute__c attr15 = ProductTestFactory.buildAttribute('ProductCode', '1345', config0.id);
            attList.add(attr15);
            
            cscfga__Attribute__c attr16 = ProductTestFactory.buildAttribute('ProductMaximName', 'Elvin', config0.id);
            attList.add(attr16);
            
            cscfga__Attribute__c attr17 = ProductTestFactory.buildAttribute('RenewalRevenue', '900.00', config0.id);
            attList.add(attr17);
            
            
        }
        
        insert attList;
        
        List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
        for(cscfga__Attribute__c attr : attList){
            if(attr.Name == 'Product'){
                newattrList.add(attr);
            }
            
        }
        
        OpportunityContactRole oppContact = new OpportunityContactRole();
        oppContact.ContactId = contact.Id;
        oppContact.IsPrimary = true;
        oppContact.OpportunityId = basket.cscfga__Opportunity__c;
        oppContact.Role = 'Inside Sales Account Manager';
        insert oppContact;
        
        //CREATE OPPORTUNITY PRODUCT
        OpportunityLineItem oli = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=2000,Quantity = 2,OpportunityID = basket.cscfga__Opportunity__c, Description = configList[0].cscfga__Description__c,cscfga__Attribute__c = attList[0].id,Product_Status__c = 'Lost',Product_Name__c='test prod');
        OpportunityLineItem oli1 = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=3000,Quantity = 3,OpportunityID = basket.cscfga__Opportunity__c, Description = configList[1].cscfga__Description__c,cscfga__Attribute__c = attList[1].id, Product_Status__c = 'won',Product_Name__c='test1');
        OpportunityLineItem oli2 = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=4000,Quantity = 4,OpportunityID = basket.cscfga__Opportunity__c, Description = configList[2].cscfga__Description__c,cscfga__Attribute__c = attList[2].id,Product_Status__c = 'withdrawn',Product_Name__c='test2');
        
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>{oli, oli1, oli2};
            insert oLIList;
        
        List<sObject> lstSnapshotData = [select Id,OfferName__c, PricebookEntry.Product2.Name, Product_Name__c, cscfga__Attribute__c ,cscfga__Attribute__r.OneOffCharge__c,Product2Id,cscfga__Attribute__r.RecurringCharge__c,TotalPrice from OpportunityLineItem where cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__c =:basket.Id];
        
        
        Test.startTest();
        CALMSAgreementHeadTerms agreeHeadTerm = new CALMSAgreementHeadTerms(opp, lstSnapshotData);
        Apttus__APTS_Agreement__c agree = agreeHeadTerm.createHeadTermsRecord(basket.Id, oppContact.Id);
        
        Test.stopTest();
        
        system.assertEquals(opp.Id, agree.Apttus__Related_Opportunity__c);
    }
    
    static void createCustomSettingValues() { 
        List<CustomConfigurationOptions__c> lstConfigOptions = new List<CustomConfigurationOptions__c>();
        
        CustomConfigurationOptions__c configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Contract Accepted';
        configOptions.External_Id__c = 'CCO6';
        configOptions.Opportunity_Stage__c = 'Propose';
        configOptions.Name = 'ContractAccepted';
        lstConfigOptions.add(configOptions);
        
        configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Contract Sent';
        configOptions.External_Id__c = 'CCO7';
        configOptions.Opportunity_Stage__c = 'Propose';
        configOptions.Name = 'ContractSent';
        lstConfigOptions.add(configOptions);
        
        configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Closed Won';
        configOptions.External_Id__c = 'CCO1';
        configOptions.Opportunity_Stage__c = 'Closed Won';
        configOptions.Name = 'ClosedWon';
        lstConfigOptions.add(configOptions);
        
        configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Cancelled';
        configOptions.External_Id__c = 'CCO2';
        configOptions.Opportunity_Stage__c = '';
        configOptions.Name = 'CancelBasket';
        lstConfigOptions.add(configOptions);
        
        insert lstConfigOptions;
        
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        insert subsSettings;
        
     }
    
    static void disableCSTrigger() {
        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = [Select id,csordtelcoa__Disable_Triggers__c,csordtelcoa__Opportunity_Stages_creating_orders__c from csordtelcoa__Orders_Subscriptions_Options__c where SetupOwnerId =: Userinfo.getOrganizationId()];
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = True ; 
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Closed Won';
        update subsSettings ; 
    }
}