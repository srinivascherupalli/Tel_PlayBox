/*************************************************************************************************
   Name : ValidationsForBasketOperationsTest
   Description : Test class of ValidationsForBasketOperations,CustomButtonOpportunitySyncRF.

Sr.No.    Developer Name      Date          Story Description

1.        Gokul            29/09/2020      /EDGE-174747 - OpportunityButtonSync refactoring
2.        Pooja Gupta      05/01/2021       EDGE-191824 - PONR Check before initiating Contract/Skip Contract/Quote
3.        Aditya           10/05/2021       Edge-207352 - MAC, CHOWN, Inflight Amend journey changes to support Billing Account capture at individual subscription level
4.		  Radhika Uppal		   27/05/2021       DIGI-931
**************************************************************************************************/
@isTest
public class ValidationsForBasketOperationsTest {
    
    @testSetup static void createTestData() {      
         
        Sync_Control_and_Constants__c s1 = new Sync_Control_and_Constants__c(Name = 'cwp');
        Sync_Control_and_Constants__c s2 = new Sync_Control_and_Constants__c(Name = 'Telstra Collaboration');
        Sync_Control_and_Constants__c s3 = new Sync_Control_and_Constants__c(Name = 'Corporate Mobile Plus');
        Sync_Control_and_Constants__c s4 = new Sync_Control_and_Constants__c(Name = 'Basket_Not_Valid_For_Sync',value__c = 'test');
        Sync_Control_and_Constants__c s5 = new Sync_Control_and_Constants__c(Name = 'BillingAccountAttName',value__c = 'BillingAccountLookup');
        Sync_Control_and_Constants__c s6 = new Sync_Control_and_Constants__c(Name = 'BillingAccountStatus',value__c = 'Pending Finalisation,Final');
        Sync_Control_and_Constants__c s7 = new Sync_Control_and_Constants__c(Name = 'BillingAccountStatusValidation',value__c = 'test');
        Sync_Control_and_Constants__c s8 = new Sync_Control_and_Constants__c(Name = 'CWP_ProDefNames',value__c = 'Mobility,IP Site,Connected Workplace');
        Sync_Control_and_Constants__c s9 = new Sync_Control_and_Constants__c(Name = 'EAP_QuoteError',value__c = 'test');
        Sync_Control_and_Constants__c s10 = new Sync_Control_and_Constants__c(Name = 'Make_Primary_Basket_Error',value__c = 'test');
        Sync_Control_and_Constants__c s11 = new Sync_Control_and_Constants__c(Name = 'Modular',value__c = 'Modular');
        Sync_Control_and_Constants__c s12 = new Sync_Control_and_Constants__c(Name = 'NextGenUC',value__c = 'Telstra Collaboration');
        Sync_Control_and_Constants__c s13 = new Sync_Control_and_Constants__c(Name = 'No_Contact_Role_on_Opportunity',value__c = 'Modify,New');
        Sync_Control_and_Constants__c s14 = new Sync_Control_and_Constants__c(Name = 'PRM_CommunityAdmin_User',value__c = 'PRM Admin - Australia');
        Sync_Control_and_Constants__c s15 = new Sync_Control_and_Constants__c(Name = 'PRM_Community_User',value__c = 'PRM Community User - Australia');
        Sync_Control_and_Constants__c s16 = new Sync_Control_and_Constants__c(Name = 'PRM_Indirect_Channel_Mangr',value__c = 'Indirect Channel Manager');
        Sync_Control_and_Constants__c s17 = new Sync_Control_and_Constants__c(Name = 'PRM_Indirect_channel_mgrIntl',value__c = 'Indirect channel manager - International');
        Sync_Control_and_Constants__c s18 = new Sync_Control_and_Constants__c(Name = 'UC_Config_Name',value__c = 'Unified Communication');
        Sync_Control_and_Constants__c s19 = new Sync_Control_and_Constants__c(Name = 'UC_Enterprise',value__c = 'Unified Communication Enterprise');
        Sync_Control_and_Constants__c s20 = new Sync_Control_and_Constants__c(Name = 'UnifiedCommTenancyPresent',value__c = 'test');
        Sync_Control_and_Constants__c s21 = new Sync_Control_and_Constants__c(Name = 'UnifiedCommunicationTenancy',value__c = 'Unified Communication Tenancy');
        Sync_Control_and_Constants__c s22 = new Sync_Control_and_Constants__c(Name = 'UnifiedCommunicationTenancyNotPresent',value__c = 'test');
        Sync_Control_and_Constants__c s23 = new Sync_Control_and_Constants__c(Name = '  UnifiedCommunicationTenancyPresent',value__c = 'test');
        Sync_Control_and_Constants__c s24 = new Sync_Control_and_Constants__c(Name = 'notAllowedTypes',value__c = 'Modify,New');
        Sync_Control_and_Constants__c s25 = new Sync_Control_and_Constants__c(Name = 'EAP_ContractError',value__c = 'test');
        Sync_Control_and_Constants__c s26 = new Sync_Control_and_Constants__c(Name = 'OpenContractAlreadyExists',value__c = 'test');
        Sync_Control_and_Constants__c s27 = new Sync_Control_and_Constants__c(Name = 'Insufficient_OnFund_Balance',value__c = 'test');
        Sync_Control_and_Constants__c s28 = new Sync_Control_and_Constants__c(Name = 'SOW_Generate_Notification',value__c = 'test');
        Sync_Control_and_Constants__c s29 = new Sync_Control_and_Constants__c(Name = 'SOW_Approval_Notification',value__c = 'test');
        Sync_Control_and_Constants__c s30 = new Sync_Control_and_Constants__c(Name = 'TramasResponseMsg',value__c = 'test');
        Sync_Control_and_Constants__c s31 = new Sync_Control_and_Constants__c(Name = 'ContractInitiatedSuccessfully',value__c = 'test');
        Sync_Control_and_Constants__c s32 = new Sync_Control_and_Constants__c(Name = 'Contract_Initiated_Failed',value__c = 'test');
        Sync_Control_and_Constants__c s33 = new Sync_Control_and_Constants__c(Name = 'Contract_User_Validation',value__c = 'test');
        Sync_Control_and_Constants__c s34 = new Sync_Control_and_Constants__c(Name = 'Quote_User_Validation',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s35 = new Sync_Control_and_Constants__c(Name = 'Site_Validation',value__c = 'This Basket cannot be moved forward as there is another order on same site.');
        Sync_Control_and_Constants__c s36 = new Sync_Control_and_Constants__c(Name = 'Ddate_Validation',value__c = 'Disconnection Date is required for cancel order. Please Edit and Enter Disconnection Date in IP Site or Mobility.');
        Sync_Control_and_Constants__c s37 = new Sync_Control_and_Constants__c(Name = 'CWP',value__c = '');
        Sync_Control_and_Constants__c s38 = new Sync_Control_and_Constants__c(Name = 'BillingAccountStatusValidation1',value__c = 'test');
        Sync_Control_and_Constants__c s39 = new Sync_Control_and_Constants__c(Name = 'BillingAccountStatusValidation2',value__c = 'test');
        list<Sync_Control_and_Constants__c> slist = new list<Sync_Control_and_Constants__c>{s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21
            ,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36,s37,s38,s39};
                insert slist;
        
        Account acc = ProductTestService.getNewAccount('Test Account');
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Account__c = acc.id;
        billingAccount.Status__c = 'Final';
        insert billingAccount;
        
        
        Contact cont = new Contact(FirstName='Test',LastName='Test',Email='test@test.com',AccountId=acc.id,Phone='');
        insert cont;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        //opp.Basket_Redemption_amount__c = 100.20;
        insert opp;
        
        Opportunity opp1  = new Opportunity();
		opp1.Name = 'SDWAN Opportunity';
		opp1.AccountID = acc.id;
		opp1.StageName = 'Develop';
		opp1.CloseDate = System.today();
        opp1.RecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        opp1.Billing_Solution__c = 'Standard';
        opp1.Type = 'New To Market';
        insert opp1;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'IoT Basket';
        basket.Device_Care_Contact__c = cont.Id;
        basket.cscfga__Basket_Status__c = 'valid';
        basket.Order_Requester__c =cont.Id;
        basket.csordtelcoa__Basket_Stage__c ='Draft';
        basket.csbb__Synchronised_with_Opportunity__c =false;
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp1.id;
        basket1.Name = 'SDWAN Basket';
        basket1.Device_Care_Contact__c = cont.Id;
        basket1.cscfga__Basket_Status__c = 'valid';
        basket1.Order_Requester__c =cont.Id;
        basket1.csordtelcoa__Basket_Stage__c ='Draft';
        basket1.csbb__Synchronised_with_Opportunity__c =false;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>{basket,basket1};
		insert basketList; 
        
        //START: Added by Sajal for EDGE-215103
        List<CustomConfigurationOptions__c> customConfigOpsList = new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c customConfig1 = new CustomConfigurationOptions__c(Name='ContractInitiate',Enrichment_Basket_Stage__c='Contract Initiated',External_Id__c='7842',MarketableOfferList__c='');
        CustomConfigurationOptions__c customConfig2 = new CustomConfigurationOptions__c(Name='ContractAccepted',Enrichment_Basket_Stage__c='Contract Accepted',External_Id__c='7843',MarketableOfferList__c='');
        CustomConfigurationOptions__c customConfig3 = new CustomConfigurationOptions__c(Name='Submitted',Enrichment_Basket_Stage__c='Submitted',External_Id__c='7844',MarketableOfferList__c='');
        CustomConfigurationOptions__c customConfig4 = new CustomConfigurationOptions__c(Name='ServiceDetailing',Enrichment_Basket_Stage__c='Enriched',External_Id__c='7845',MarketableOfferList__c='');
        customConfigOpsList.add(customConfig1);
        customConfigOpsList.add(customConfig2);
        customConfigOpsList.add(customConfig3);
        customConfigOpsList.add(customConfig4);
        insert customConfigOpsList;

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User tuser = new User(  firstname = 'Test',
                                lastName = 'basket user',
                                email = 'testbasket123@domain.org',
                                Username ='testbasket123@domain.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = 'tem123',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = pf.Id);

                                insert tuser;
        //END for EDGE-215103
		//START for 931        
		cscfga__Product_Definition__c sdwanpd1 = new cscfga__Product_Definition__c(Name = 'SDWAN ADAPT S1', cscfga__Description__c = 'SDWAN ADAPT S1',product_Specification__c= 'DMCAT_Offer_001343');
		cscfga__Product_Definition__c sdwanpd2 = new cscfga__Product_Definition__c(Name = 'SecureEdge', cscfga__Description__c = 'SecureEdge',product_Specification__c= 'DMCAT_Offer_001367');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{sdwanpd1,sdwanpd2};
		insert pdList;   
        cscfga__Product_Configuration__c sdwanpc1 = new cscfga__Product_Configuration__c(Name = 'SDWAN ADAPT S1', cscfga__Product_Basket__c = basket1.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                  cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
       insert sdwanpc1;
        //END for 931
        Profile apf = [SELECT Id FROM Profile WHERE Name = 'Assurance Service Agent'];
        User atuser = new User(  firstname = 'Test12',
                                lastName = 'basket user12',
                                email = 'testbasket12345676@domain.org',
                                Username ='testbasket12345676@domain.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = 'tel123',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = apf.Id);
                                insert atuser;
    }
    // START for DIGI-931
    @istest static void validateSDWANAllOffersTest(){
		cscfga__Product_Basket__c basket = [select id,name,Opportunity_Type__c from cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'SDWAN Opportunity' limit 1];
   		System.Test.startTest();
       CustomButtonOpportunitySyncRF bs = new CustomButtonOpportunitySyncRF();
     string response = bs.performAction(basket.id);
    system.debug('responseoppRF--'+response);
      system.assertEquals(true,response.contains('error'));
      System.Test.stopTest();
       
    }
    // END for DIGI-931
    @istest static void checkBasketIsInvalidTest(){
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        list<cscfga__Product_Configuration__c> configList = new list<cscfga__Product_Configuration__c>();
        basket.cscfga__Basket_Status__c = 'Invalid';
        update basket;
       System.Test.startTest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.debug('responsevalid--'+response);
         system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    
    @istest static void ConfigNullCheck(){
        
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        list<cscfga__Product_Configuration__c> configList = new list<cscfga__Product_Configuration__c>();
        System.Test.startTest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    
    @istest static void checkProductsinConfigTest(){
        opportunity opp = [select id,Product_Type__c from opportunity limit 1];
        opp.Product_Type__c = 'Non Modular';
        update opp;
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basket.Id,
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        cscfga__Attribute__c at1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configList1[0].Id,
            Name = 'Product',cscfga__Value__c = ''
        );
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>{at1};
            insert attList;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c
                                                                                                                                                                FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    
    @istest static void primaryBasketErrorTest(){
         cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
       basket.Primary_Basket__c = false;
        update basket;
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(csordtelcoa__Basket_Stage__c = 'Enriched',cscfga__Basket_Status__c = 'valid', Primary_Basket__c = true,cscfga__Opportunity__c = basket.cscfga__Opportunity__c);
        insert basket1;
        
            cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basket.Id,
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList;
        
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.debug('responsepb--'+response);
        system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    
    @istest static void checkOppContactRoleTest(){
        
        contact con = [select id from contact limit 1];
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__c,cscfga__Opportunity__r.id,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basket.Id,
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList;
        
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.debug('responseopprole--'+response);
        system.assertEquals(response.contains('error'), true);
        System.Test.stopTest();
    }
    
    @istest static void validateBasketforBillingAccTest(){
        
        contact con = [select id from contact limit 1]; 
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        OpportunityContactRole opp = new OpportunityContactRole(contactId = con.id,opportunityId = basket.cscfga__Opportunity__c);
        insert opp;
        string billAccId = [select id from  Billing_Account__c limit 1].id;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'SolutionComponent',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
         cscfga__Attribute__c at1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configList1[0].Id,
            Name = 'BillingAccountLookup',cscfga__Value__c = billAccId
        );
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>{at1};
            insert attList;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c
                                                                                                                                                                                              FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];
        system.debug('configList---'+configList);
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.debug('responsebill--'+response);
        system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    @istest static void validationSuccessfulTest(){
        account acc = [select id from account limit 1];
        contact con = [select id from contact limit 1];
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        OpportunityContactRole opp = new OpportunityContactRole(contactId = con.id,opportunityId = basket.cscfga__Opportunity__c);
        insert opp;
        string billAccId = [select id from  Billing_Account__c limit 1].id;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        cscfga__Attribute__c at1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configList1[0].Id,
            Name = 'BillingAccountLookup',cscfga__Value__c = ''
        );
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>{at1};
            insert attList;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];        
        System.Test.startTest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.debug('responsesuccl--'+response);
        system.assertEquals(true,response.contains('Ok'));
        System.Test.stopTest();
    }
    @istest static void validateOffersIfTest(){
        EnvironmentVariable__c en = new EnvironmentVariable__c(Name = 'ValidationIPUCE',Value__c = '1');
        insert en;
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        offer.Name = 'Telstra Collaboration';
        offer.Offer_ID__c = 'DMCAT_Offer_000618';
        offer.Config__c = '{"skipBasketSyncValidations":false}';
        insert offer;
        
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Connected Workplace',  Marketable_Offer__c= offer.id,cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        
        account acc = [select id from account limit 1];
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Name = 'test';
        update sub;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,cscfga__Product_Definition__r.name,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c
                                                                                                                                                                                                                                 FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];
        system.debug('configList---'+configList);
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
       string response = bs.performValidation(basket,configList,'sync');
      system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    
    @istest static void validateOffersElseTest(){
        EnvironmentVariable__c en = new EnvironmentVariable__c(Name = 'ValidationIPUCE',Value__c = '2');
        insert en;
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        offer.Name = 'Telstra Collaboration';
        offer.Offer_ID__c = 'DMCAT_Offer_000618';
        offer.Config__c = '{"skipBasketSyncValidations":false}';
        insert offer;
        
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Connected Workplace',  Marketable_Offer__c= offer.id,cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        
        account acc = [select id from account limit 1];
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        sub.Name = 'test';
        update sub;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,cscfga__Product_Definition__r.name,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c
                                                                                                                                                                                                                                 FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];
        system.debug('configList---'+configList);
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    
    @istest static void validateOffersNextGenUnifiedCommTest(){
        
        EnvironmentVariable__c en = new EnvironmentVariable__c(Name = 'ValidationIPUCE',Value__c = '2');
        insert en;
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        Marketable_Offer__c offer1 = new Marketable_Offer__c(OfferDefinationName__c ='Telstra Collaboration',Name = 'Telstra Collaboration',Offer_ID__c = 'DMCAT_Offer_000618',Config__c = '{"skipBasketSyncValidations":false}');
        Marketable_Offer__c offer2 = new Marketable_Offer__c(OfferDefinationName__c ='Unified Communication Tenancy',Name = 'Unified Communication Tenancy',Offer_ID__c = 'DMCAT_Offer_000618',Config__c = '{"skipBasketSyncValidations":false}');
        list<Marketable_Offer__c> marketOfferList = new list<Marketable_Offer__c>{offer1,offer2};
            insert marketOfferList;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Connected Workplace',  Marketable_Offer__c= marketOfferList[0].id,cscfga__Product_Basket__c = basket.Id,Type__c = 'New',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec',ConfigurationType1__c='SolutionComponent');
        cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c(Name = 'Connected Workplace',  Marketable_Offer__c=  marketOfferList[1].id,cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1,pc2};
            insert configList1;
        
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,cscfga__Product_Definition__r.name,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c
                                                                                                                                                                                                                                 FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];
        system.debug('configList---'+configList);
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    } 
    
    @istest static void validateOffersNextGenTest(){
        
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        Marketable_Offer__c offer1 = new Marketable_Offer__c(OfferDefinationName__c ='Telstra Collaboration',Name = 'Telstra Collaboration',Offer_ID__c = 'DMCAT_Offer_000618',Config__c = '{"skipBasketSyncValidations":false}');
        Marketable_Offer__c offer2 = new Marketable_Offer__c(OfferDefinationName__c ='Unified Communication Tenancy',Name = 'Unified Communication Tenancy',Offer_ID__c = 'DMCAT_Offer_000618',Config__c = '{"skipBasketSyncValidations":false}');
        list<Marketable_Offer__c> marketOfferList = new list<Marketable_Offer__c>{offer1,offer2};
            insert marketOfferList;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Connected Workplace',  Marketable_Offer__c= marketOfferList[0].id,cscfga__Product_Basket__c = basket.Id,Type__c = 'New',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec',ConfigurationType1__c='SolutionComponent');
        
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,cscfga__Product_Definition__r.name,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c
                                                                                                                                                                                                                                 FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];
        system.debug('configList---'+configList);
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'sync');
        system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    
    @istest static void validateOffersUnifiedCommTest(){
        
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        Marketable_Offer__c offer1 = new Marketable_Offer__c(OfferDefinationName__c ='Telstra Collaboration',Name = 'Telstra Collaboration',Offer_ID__c = 'DMCAT_Offer_000618',Config__c = '{"skipBasketSyncValidations":false}');
        Marketable_Offer__c offer2 = new Marketable_Offer__c(OfferDefinationName__c ='Unified Communication Tenancy',Name = 'Unified Communication Tenancy',Offer_ID__c = 'DMCAT_Offer_000618',Config__c = '{"skipBasketSyncValidations":false}');
        list<Marketable_Offer__c> marketOfferList = new list<Marketable_Offer__c>{offer1,offer2};
            insert marketOfferList;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Connected Workplace',  Marketable_Offer__c= marketOfferList[1].id,cscfga__Product_Basket__c = basket.Id,Type__c = 'New',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec',ConfigurationType1__c='SolutionComponent');
        
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,cscfga__Product_Definition__r.name,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c
                                                                                                                                                                                                                                 FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];
        system.debug('configList---'+configList);
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
       string response = bs.performValidation(basket,configList,'sync');
       system.assertEquals(true,response.contains('error'));
        System.Test.stopTest();
    }
    
    @istest static void CustomButtonOpportunitySyncRFTest(){
        
        contact con = [select id from contact limit 1];
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        OpportunityContactRole opp = new OpportunityContactRole(contactId = con.id,opportunityId = basket.cscfga__Opportunity__c);
        insert opp;
        string billAccId = [select id from  Billing_Account__c limit 1].id;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        cscfga__Attribute__c at1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configList1[0].Id,
            Name = 'BillingAccountLookup',cscfga__Value__c = ''
        );
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>{at1};
            insert attList;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];        
        System.Test.startTest();
        CustomButtonOpportunitySyncRF bs = new CustomButtonOpportunitySyncRF();
       string response = bs.performAction(basket.id);
        system.debug('responseoppRF--'+response);
        system.assertEquals(true,response.contains('ok'));
        System.Test.stopTest();
    }
    
    @istest static void checkIfPrimaryPresent(){
        
        cscfga__Product_Basket__c basket = [select id,Opportunity_Type__c,cscfga__Opportunity__r.AccountId,Primary_Basket__c,cscfga__Opportunity__r.Id,cscfga__Opportunity__r.Product_Type__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c,cscfga__Basket_Status__c,csbb__Account__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        basket.Primary_Basket__c = false;
        update basket ;
        String basketId = basket.id;
        list<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
            prodConfigList = [
              SELECT id, Name, OfferName__c,Type__c,Marketable_Offer__c,cscfga__Product_Basket__c,cscfga__Product_Definition__c  
              FROM cscfga__Product_Configuration__c
              WHERE cscfga__Product_Basket__c = :basketId 
            ];
       System.Test.starttest();
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.csbb__Account__c = basket.csbb__Account__c;
        basket1.cscfga__Opportunity__c = basket.cscfga__Opportunity__c;
        basket1.Name = 'IoT Basket1';
        basket1.cscfga__Basket_Status__c = 'valid';
        basket1.Primary_Basket__c = true;
        basket1.csbb__Synchronised_with_Opportunity__c  = true;
        basket1.csordtelcoa__Basket_Stage__c  = 'Contract Initiated';
        insert basket1;
        
        System.debug('Basket is' +basket );
        System.debug('Basket1 is' +basket1 );
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,prodConfigList,'contract');
        string response1 = ValidationsForBasketOperations.checkSOW(basketId);
        system.assertEquals(false,response.contains('ok'));
       System.Test.stopTest();
    }


    @istest static void checkReedemptionAmount(){
        
        Account acc1 = ProductTestService.getNewAccount('Test Account');
        Opportunity opp1 = ProductTestFactory.getOpportunityBasic(acc1);
        opp1.Product_Type__c = 'Modular';
        opp1.Basket_Redemption_amount__c = 999999;
        insert opp1;
        cscfga__Product_Basket__c basket = [select id,Opportunity_Type__c,cscfga__Opportunity__r.AccountId,Primary_Basket__c,cscfga__Opportunity__r.Basket_Redemption_amount__c,cscfga__Opportunity__r.Id,cscfga__Opportunity__r.Product_Type__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c,cscfga__Basket_Status__c,csbb__Account__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        basket.cscfga__Opportunity__c = opp1.id; 
        update basket;
        String basketId = basket.id;
        list<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
            prodConfigList = [
              SELECT id, Name, OfferName__c,Type__c,Marketable_Offer__c,cscfga__Product_Basket__c,cscfga__Product_Definition__c  
              FROM cscfga__Product_Configuration__c
              WHERE cscfga__Product_Basket__c = :basketId 
            ];
       System.Test.starttest();
        string response1 = ValidationsForBasketOperations.checkRedemptionAmount(basket);
        system.assertEquals(true,response1.contains('Ok'));
        System.Test.stopTest();
    }

    @istest static void checkReedemptionNegativeCase(){
        
        Opportunity opp = [Select id,Basket_Redemption_amount__c from Opportunity Limit 1];
        opp.Basket_Redemption_amount__c = 99999999;
        update opp;
        cscfga__Product_Basket__c basket = [select id,Opportunity_Type__c,Primary_Basket__c,cscfga__Opportunity__r.AccountId,cscfga__Opportunity__r.Basket_Redemption_amount__c,cscfga__Opportunity__r.Id,cscfga__Opportunity__r.Product_Type__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c,cscfga__Basket_Status__c,csbb__Account__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        basket.csbb__Synchronised_With_Opportunity__c = true;
        String basketId = basket.id;
        
        list<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
            prodConfigList = [
              SELECT id, Name, OfferName__c,Type__c,Marketable_Offer__c,cscfga__Product_Basket__c,cscfga__Product_Definition__c  
              FROM cscfga__Product_Configuration__c
              WHERE cscfga__Product_Basket__c = :basketId 
            ];
        System.Test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,prodConfigList,'contract');
        string response1 = ValidationsForBasketOperations.checkSOW(basketId);
        system.assertEquals(false,response.contains('Ok'));
        System.Test.stopTest();
    }
    @istest static void checkQuote(){
        
        cscfga__Product_Basket__c basket = [select id,Opportunity_Type__c,cscfga__Basket_Status__c,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c limit 1];
        list<cscfga__Product_Configuration__c> configList = new list<cscfga__Product_Configuration__c>();
        basket.cscfga__Basket_Status__c = 'Invalid';
        update basket;
        System.test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'quote');
        system.debug('responsevalid--'+response);
         system.assertEquals(true,response.contains('error'));
        System.test.stoptest();
    }
    @istest static void checkSubmitOrder(){
        
        cscfga__Product_Basket__c basket = [select id,Opportunity_Type__c,cscfga__Basket_Status__c,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,csbb__Synchronised_with_Opportunity__c,Order_Requester__c from cscfga__Product_Basket__c limit 1];
        list<cscfga__Product_Configuration__c> configList = new list<cscfga__Product_Configuration__c>();
        basket.cscfga__Basket_Status__c = 'Invalid';
        update basket;
        System.test.starttest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basket,configList,'SubmitOrder');
        system.debug('responsevalid--'+response);
         system.assertEquals(true,response.contains('error'));
        System.test.stoptest();
    }
    
    //Created for EDGE-191824 changes
    @istest static void CheckPONRforServicesTest(){

        cscfga__Product_Basket__c basket = [select id,Opportunity_Type__c,cscfga__Basket_Status__c,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,csbb__Synchronised_with_Opportunity__c,Order_Requester__c, recordType.Name from cscfga__Product_Basket__c limit 1];

        Id recordtypeId = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        basket.RecordTypeId = recordtypeId;
        update basket;
        System.test.starttest();
        string response = ValidationsForBasketOperations.CheckPONRforServices(basket);
        system.debug('responsevalid--'+response);
        system.assertEquals('Ok',response);
        System.test.stoptest();
    }
    
    @istest static void CustomButtonOpportunitySyncRFPRMProfileTest(){
        
        contact con = [select id from contact limit 1];

        cscfga__Product_Basket__c basket = [select id,Opportunity_Type__c,sync_job_Id__c ,cscfga__Basket_Status__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.id,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];

        basket.sync_job_Id__c = '123';
        update basket;
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        OpportunityContactRole opp = new OpportunityContactRole(contactId = con.id,opportunityId = basket.cscfga__Opportunity__c);
        insert opp;
        string billAccId = [select id from  Billing_Account__c limit 1].id;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        cscfga__Attribute__c at1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configList1[0].Id,
            Name = 'BillingAccountLookup',cscfga__Value__c = ''
        );
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>{at1};
            insert attList;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];        
        System.Test.startTest();
        CustomButtonOpportunitySyncRF bs = new CustomButtonOpportunitySyncRF();
        string response = bs.performAction(basket.id);
        system.assertEquals(false,response.contains('ok'));
        
        System.Test.stopTest();
    }

    
    //Vishal
    /*
     * @istest static void checkCompareAvailableAmtRedemptionAmt(){
        
        Account acc1 = ProductTestService.getNewAccount('Test Account');
        Opportunity opp1 = ProductTestFactory.getOpportunityBasic(acc1);
        opp1.Product_Type__c = 'Modular';
        opp1.Basket_Redemption_amount__c = 999999;
        insert opp1;
        cscfga__Product_Basket__c basket = [select id,Opportunity_Type__c,cscfga__Opportunity__r.AccountId,Primary_Basket__c,cscfga__Opportunity__r.Basket_Redemption_amount__c,cscfga__Opportunity__r.Id,cscfga__Opportunity__r.Product_Type__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c,cscfga__Basket_Status__c,csbb__Account__c,csbb__Account__r.OwnerId,cscfga__Opportunity__r.OwnerId,Name,Device_Care_Contact__c from cscfga__Product_Basket__c limit 1];
        basket.cscfga__Opportunity__c = opp1.id; 
        update basket;
        String basketId = basket.id;
        list<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
            prodConfigList = [
              SELECT id, Name, OfferName__c,Type__c,Marketable_Offer__c,cscfga__Product_Basket__c,cscfga__Product_Definition__c  
              FROM cscfga__Product_Configuration__c
              WHERE cscfga__Product_Basket__c = :basketId 
            ];
        System.Test.starttest();
        string response1 = ValidationsForBasketOperations.compareAvailableAmtRedemptionAmt(basket);
        system.assertEquals(true,response1.contains('Ok'));
        System.Test.stopTest();
    }*/

    //START: Added by Sajal for EDGE-215103
    @isTest
    public static void isProductEndDateExpiredSkipContractTest(){
        User u = [SELECT Id FROM User WHERE Username = 'testbasket123@domain.org'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1 ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
        cscfga__Product_Basket__c basketNew = new cscfga__Product_Basket__c();
        basketNew.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basketNew.cscfga__Opportunity__c = opp.id;
        basketNew.csbb__Account__c = acc.Id;
        basketNew.Name = 'ServiceBasket';
        basketNew.csbb__Synchronised_with_Opportunity__c = true;
        Insert basketNew;
        System.debug('---basketNew skip contract---'+[SELECT Id, RecordtypeId, RecordType.Name FROM cscfga__Product_Basket__c WHERE Id = :basketNew.Id]);

        String basketId =  basketNew.id;
        
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '';
        legacyRec.Product_Basket__c = basketNew.Id;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        Insert legacyRec;
        
        Service_Add_On__c addOnRecNew = new Service_Add_On__c();
        addOnRecNew.Legacy_Service__c = legacyRec.Id;
        addOnRecNew.Contract_Type__c = 'MRO';
        addOnRecNew.Charging_Option__c = 'Keep monthly repayment';
        addOnRecNew.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecNew.Status__c = 'Sync Completed';
        addOnRecNew.Product_End_Date__c = Date.today().addDays(-3);
        Insert addOnRecNew;
        
        contact con = [select id from contact limit 1];

        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
        insert pdList;
        OpportunityContactRole oppRole = new OpportunityContactRole(contactId = con.id,opportunityId = opp.Id);
        insert oppRole;
        string billAccId = [select id from  Billing_Account__c limit 1].id;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Mobility', cscfga__Product_Basket__c = basketNew.Id,Type__c = 'Cancel',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        cscfga__Attribute__c at1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configList1[0].Id,
            Name = 'BillingAccountLookup',cscfga__Value__c = ''
        );
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>{at1};
            insert attList;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];        

        //ValidationsForBasketOperations validatebasket = new ValidationsForBasketOperations();
        Boolean showValidationMessage = false;
        Test.startTest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basketNew,configList,'Skip Contract');
        //string response1 = ValidationsForBasketOperations.checkSOW(basketId);
        showValidationMessage =  ValidationsForBasketOperations.isProductEndDateExpired(basketNew);
        Test.stopTest();

        System.assertEquals(true, showValidationMessage, 'Validation message for expired products');
    }

    @isTest
    public static void isProductEndDateExpiredContractTest(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1 ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
        opp.Basket_Redemption_amount__c = 10;
        update opp;
        cscfga__Product_Basket__c basketNew = new cscfga__Product_Basket__c();
        basketNew.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basketNew.cscfga__Opportunity__c = opp.id;
        basketNew.csbb__Account__c = acc.Id;
        basketNew.Name = 'ServiceBasket';
        basketNew.csbb__Synchronised_with_Opportunity__c = true;
        Insert basketNew;
        System.debug('---basketNew contract---'+[SELECT Id, RecordtypeId, RecordType.Name FROM cscfga__Product_Basket__c WHERE Id = :basketNew.Id]);
        String basketId =  basketNew.id;
        
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '';
        legacyRec.Product_Basket__c = basketNew.Id;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        Insert legacyRec;
        
        Service_Add_On__c addOnRecNew = new Service_Add_On__c();
        addOnRecNew.Legacy_Service__c = legacyRec.Id;
        addOnRecNew.Contract_Type__c = 'MRO';
        addOnRecNew.Charging_Option__c = 'Keep monthly repayment';
        addOnRecNew.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecNew.Status__c = 'Sync Completed';
        addOnRecNew.Product_End_Date__c = Date.today().addDays(-2);
        Insert addOnRecNew;

        contact con = [select id from contact limit 1];

        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
        insert pdList;
        OpportunityContactRole oppRole = new OpportunityContactRole(contactId = con.id,opportunityId = opp.Id);
        insert oppRole;
        string billAccId = [select id from  Billing_Account__c limit 1].id;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Mobility', cscfga__Product_Basket__c = basketNew.Id,Type__c = 'Cancel',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        cscfga__Attribute__c at1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configList1[0].Id,
            Name = 'DisconnectionDate',cscfga__Value__c = ''
        );
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>{at1};
            insert attList;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];        
        
        
        //ValidationsForBasketOperations validatebasket = new ValidationsForBasketOperations();
        Boolean showValidationMessage = false;
        Test.startTest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(basketNew,configList,'Contract');
        //string response1 = ValidationsForBasketOperations.checkSOW(basketId);
        showValidationMessage =  ValidationsForBasketOperations.isProductEndDateExpired(basketNew);
        Test.stopTest();

        System.assertEquals(true, showValidationMessage, 'Validation message for expired products');
    }

    @isTest
    public static void isProductEndDateExpiredQuoteTest(){
        User u = [SELECT Id FROM User WHERE Username = 'testbasket123@domain.org'];
        Id productRecordTypeId = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1 ];
        acc.OwnerId = u.Id;
        update acc;
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
        //opp.Basket_Redemption_amount__c = 10;
        //update opp;
        cscfga__Product_Basket__c basketNew = new cscfga__Product_Basket__c();
        basketNew.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basketNew.cscfga__Opportunity__c = opp.id;
        basketNew.csbb__Account__c = acc.Id;
        basketNew.Name = 'ServiceBasket';
        basketNew.RecordTypeId = productRecordTypeId;
        basketNew.csbb__Synchronised_with_Opportunity__c = true;
        Insert basketNew;
        cscfga__Product_Basket__c bskNew = [SELECT Id, RecordtypeId, RecordType.Name, csbb__Account__r.OwnerId, cscfga__Opportunity__r.OwnerId, csbb__Synchronised_With_Opportunity__c,csordtelcoa__Change_Type__c  FROM cscfga__Product_Basket__c WHERE Id = :basketNew.Id];
        String basketId =  basketNew.id;
        
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '';
        legacyRec.Product_Basket__c = basketNew.Id;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        Insert legacyRec;
        
        Service_Add_On__c addOnRecNew = new Service_Add_On__c();
        addOnRecNew.Legacy_Service__c = legacyRec.Id;
        addOnRecNew.Contract_Type__c = 'MRO';
        addOnRecNew.Charging_Option__c = 'Keep monthly repayment';
        addOnRecNew.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecNew.Status__c = 'Sync Completed';
        addOnRecNew.Product_End_Date__c = Date.today().addDays(-1);
        Insert addOnRecNew;

        contact con = [select id from contact limit 1];

        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
        insert pdList;
        OpportunityContactRole oppRole = new OpportunityContactRole(contactId = con.id,opportunityId = opp.Id);
        insert oppRole;
        string billAccId = [select id from  Billing_Account__c limit 1].id;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'IoT Sub', cscfga__Product_Basket__c = basketNew.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        cscfga__Attribute__c at1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = configList1[0].Id,
            Name = 'DisconnectionDate',cscfga__Value__c = ''
        );
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>{at1};
            insert attList;
        list<cscfga__Product_Configuration__c> configList = [select id,name,cscfga__Product_Basket__c,ConfigurationType1__c,Type__c,cscfga__Product_Definition__c,csedm__CFS_Mapping_List__c,(SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c];        
        
        
        //ValidationsForBasketOperations validatebasket = new ValidationsForBasketOperations();
        Boolean showValidationMessage = false;
        Test.startTest();
        ValidationsForBasketOperations bs = new ValidationsForBasketOperations();
        string response = bs.performValidation(bskNew,configList,'Quote');
        //string response1 = ValidationsForBasketOperations.checkSOW(basketId);
        showValidationMessage =  ValidationsForBasketOperations.isProductEndDateExpired(basketNew);
        Test.stopTest();

        System.assertEquals(true, showValidationMessage, 'Validation message for expired products');
    }
    //END for EDGE-215103
    //START: Added for DIGI-9338 to increase coverage
    @istest static void checkReferenceNumberTest(){
        
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__c,Name,Device_Care_Contact__c,referencenumber__c from cscfga__Product_Basket__c limit 1];
        User u = [Select id From User Where username='testbasket12345676@domain.org' limit 1];
        System.Test.startTest();
        System.runAs(u){
        	string response = ValidationsForBasketOperations.checkReferenceNumber(basket);
        	system.debug('responsevalid--'+response);
        	system.assertEquals(true,response!=null);
        }
        System.Test.stopTest();
    }
    @istest static void compareAvailableAmtRedemptionAmtTest(){
        
        cscfga__Product_Basket__c basket = [select id,cscfga__Basket_Status__c,Opportunity_Type__c,csbb__Account__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Basket_Redemption_amount__c,cscfga__Opportunity__r.AccountId,Name,Device_Care_Contact__c,referencenumber__c from cscfga__Product_Basket__c where cscfga__Opportunity__c!=null limit 1];
        System.Test.startTest();
        string response = ValidationsForBasketOperations.compareAvailableAmtRedemptionAmt(basket);
        system.debug('responsevalid--'+response);
        system.assertEquals(true,response!=null);
        System.Test.stopTest();
    }
    //END for DIGI-9338

}