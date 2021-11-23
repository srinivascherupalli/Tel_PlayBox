/**
 * Author:Yash Rathod
 * Description: Test class for SubEmailService class
//Last Modified : updated only MobilePhone value (none of other) to valid format on contact creation, to fix the testclass failure because of new validation implemented as part of DIGI-4056 (Team SFO :: 21.14)
 **/


@isTest
public class SubEmailServiceTest {
    
    @Testsetup
    static void dataSetup(){
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>();
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Account_Status__c='Active';
        acc.Customer_Status__c  = 'Active';
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.name='opp1';
        opp.StageName='Closed Won';
        opp.CloseDate=Date.newInstance(2016, 12, 9);
        opp.AccountId = acc.id;
        insert opp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        insert basket;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        contact.Pref_Comm_Method__c='eMail';
        contact.MobilePhone='0476543210';
        contact.email='k@gmail.com';
        contact.AccountId = acc.id;
        insert contact;
        
        Billing_Account__c ba=new Billing_Account__c();
        ba.Billing_Account_Name__c='Test Billing Account';
        ba.Billing_Account_Number__c='123456789123';
        ba.Account__c=acc.Id;
        ba.Billing_Account_Owner__c=contact.Id;
        
        insert ba;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        ocr.ROLE = 'Decision Maker';
        insert ocr;
        List<csord__Order_Request__c> ordReqs=new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq);
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq2);
        csord__Order_Request__c ordReq3 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq3);
        csord__Order_Request__c ordReq4 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq4);
        csord__Order_Request__c ordReqMobility = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReqMobility);
        insert ordReqs;
        //73057
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('TestProduct', 'TestPlan');
        prodDef.product_Specification__c = 'DMCAT_Offer_000646';
        prodDefList.add(prodDef);
        
        cscfga__Product_Definition__c prodDefMobility = ProductTestFactory.buildProductDefinition('TestProduct', 'TestPlan');
        prodDefMobility.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        prodDefList.add(prodDefMobility);
        
        insert prodDefList;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.Type__c = 'Cancel';
        prodConfigList.add(prodConfig);
        
        cscfga__Product_Configuration__c prodConfigModify = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfigModify.Type__c='Cancel';
        prodConfigList.add(prodConfigModify);
                
        cscfga__Product_Configuration__c prodConfigMobility = ProductTestFactory.buildProductConfig(prodDefMobility.Id);
        prodConfigList.add(prodConfigMobility);
        
        insert prodConfigList;
        
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.Offer_Spec_Id__c = 'DMCAT_Offer_000646';
        insert offer;
        
        //73057
        //Modified
        List<APXTConga4__Conga_Email_Template__c> templates=new List<APXTConga4__Conga_Email_Template__c>();
        APXTConga4__Conga_Email_Template__c congaTemplate =new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        //congaTemplate.Name = 'CET-00024';
        congaTemplate.APXTConga4__Name__c = 'OfferCancellation';
        insert congaTemplate;
        
        //End
        List<Customer_Notify_Metadata__c> custNotifyList=new List<Customer_Notify_Metadata__c>();
        Customer_Notify_Metadata__c custNotify = new Customer_Notify_Metadata__c();
        custNotify.productDefinitionCode__c ='DMCAT_Offer_000646';
        custNotify.offerID__c = 'DMCAT_Offer_000646';
        custNotify.monitorObjectStatus__c = 'Inactive';
        custNotify.scenarioType__c='';
        custNotify.monitorObject__c='Subscription';
        custNotify.orderType__c='Cancel';
        custNotify.emailTemplate__c = congaTemplate.id;
        custNotifyList.add(custNotify);
        
        insert custNotifyList;
        
        
        List<csord__Order__c> ords=new List<csord__Order__c>();
        csord__Order__c primaryOrdMobility = ProductTestFactory.buildOrder('PrimaryOrderMobility', acc.id, 'Created', ordReqMobility.id);
        primaryOrdMobility.csord__Order_Request__c = ordReqMobility.Id;
        primaryOrdMobility.csord__Status2__c='In Progress';
        primaryOrdMobility.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdMobility.csordtelcoa__Product_Configuration__c = prodConfigMobility.Id;
        primaryOrdMobility.Billing_Account__c=ba.Id;
        ords.add(primaryOrdMobility);
        
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrderInProress', acc.id, 'Created', ordReq.id);
        primaryOrd.csord__Order_Request__c = ordReq3.Id;
        primaryOrd.csord__Status2__c='In Progress';
        primaryOrd.csordtelcoa__Opportunity__c =opp.id;
        primaryOrd.Billing_Account__c=ba.Id;
        ords.add(primaryOrd);
        
        csord__Order__c primaryOrd2 = ProductTestFactory.buildOrder('PrimaryOrderComplete', acc.id, 'Created', ordReq.id);
        primaryOrd2.csord__Order_Request__c = ordReq2.Id;
        primaryOrd2.csord__Status2__c='Complete';
        primaryOrd2.csordtelcoa__Opportunity__c =opp.id;
        primaryOrd2.csordtelcoa__Product_Configuration__c = prodConfigModify.Id;
        primaryOrd2.Billing_Account__c=ba.Id;
        ords.add(primaryOrd2);
        
        csord__Order__c primaryOrd3 = ProductTestFactory.buildOrder('PrimaryOrderIn Progresss', acc.id, 'Created', ordReq.id);
        primaryOrd3.csord__Order_Request__c = ordReq3.Id;
        primaryOrd3.csord__Status2__c='In Progress';
        primaryOrd3.csordtelcoa__Opportunity__c =opp.id;
        primaryOrd3.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        primaryOrd3.Billing_Account__c=ba.Id;
        ords.add(primaryOrd3);
        
        csord__Order__c primaryOrdNew = ProductTestFactory.buildOrder('PrimaryOrderNew', acc.id, 'Created', ordReq.id);
        primaryOrdNew.csord__Order_Request__c = ordReq4.Id;
        primaryOrdNew.csord__Status2__c='Complete';
        primaryOrdNew.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdNew.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        primaryOrdNew.Billing_Account__c=ba.Id;
        ords.add(primaryOrdNew);
        
       
        
        csord__Order__c ordMobility = ProductTestFactory.buildOrder('TestOrderMoblity', acc.id, 'Created', ordReqMobility.id);
        ordMobility.csord__Order_Request__c = ordReqMobility.Id;
        ordMobility.csord__Status2__c='In Progress';
        ordMobility.name = 'TestOrderMobility';
        ordMobility.csordtelcoa__Opportunity__c =opp.id;
        ordMobility.csord__Primary_Order__c = primaryOrdMobility.id;
        
        ords.add(ordMobility);
        
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Status2__c='Complete';
        ord.name = 'TestOrder';
        ord.csordtelcoa__Opportunity__c =opp.id;
        ord.csord__Primary_Order__c = primaryOrd.id;
        ords.add(ord);
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrder2', acc.id, 'Created', ordReq2.id);
        ord.csord__Order_Request__c = ordReq2.Id;
        ord2.csord__Status2__c='Complete';
        ord2.name = 'TestOrder2';
        ord2.csordtelcoa__Opportunity__c =opp.id;
        ord2.Project_Manager_Email__c='testpmmanager@gmail.com';
        ord2.csord__Primary_Order__c = primaryOrd2.id;
        ords.add(ord2);
        
        csord__Order__c ord3 = ProductTestFactory.buildOrder('TestOrder3', acc.id, 'Created', ordReq3.id);
        ord3.csord__Order_Request__c = ordReq3.Id;
        ord3.csord__Status2__c='In Progress';
        ord3.Project_Manager_Email__c='testpmmanager@gmail.com';
        ord3.name = 'TestOrder3';
        ord3.csordtelcoa__Opportunity__c =opp.id;
        //ord3.csord__Primary_Order__c = primaryOrd3.id;
        ords.add(ord3);
        
        csord__Order__c ord4 = ProductTestFactory.buildOrder('TestOrder4', acc.id, 'Created', ordReq4.id);
        ord4.csord__Order_Request__c = ordReq4.Id;
        ord4.csord__Status2__c='Complete';
        ord4.name = 'TestOrder4';
        ord4.csordtelcoa__Opportunity__c =opp.id;
        ord4.csord__Primary_Order__c = primaryOrdNew.id;
        ords.add(ord4);
        
        insert ords;
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
        
        
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        csord__Subscription__c subsMobility=new csord__Subscription__c();
        subsMobility.name  = 'test subs Mobility';
        subsMobility.csord__Identification__c = 'test identity';
        subsMobility.csord__Order__c = ordMobility.Id;
        subsMobility.csord__Status__c = 'Provisioning In Progress';
        subsMobility.Sub_status__c = 'Inactive';
        subsMobility.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subsMobility.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        
        subsMobility.csord__Order_Request__c = ordReqMobility.Id;
        //modified for 73057
        subsMobility.emailSent__c = false;
        subsMobility.csordtelcoa__Product_Configuration__c = prodConfigMobility.Id;
        subsMobility.Offer__c =offer.Id;
        subsMobility.Site__c = null;
        subsMobility.Primary_Order__c = primaryOrdMobility.Id;
        subList.add(subsMobility);
        
        
      
        Test.StartTest();
        
        List<Contact> contacts=new List<Contact>();
        Contact cntct1 = new Contact();
        cntct1.LastName = 'Primary';
        cntct1.Phone = '111222';
        cntct1.email='Primary@gmail.com';
        contacts.add(cntct1);
        
        Contact cntct2 = new Contact();
        cntct2.LastName = 'Secondary';
        cntct2.Phone = '22223333';
        cntct2.email='Secondary@gmail.com';
        contacts.add(cntct2);
        Contact cntct3 = new Contact();
        cntct3.LastName = 'Site';
        cntct3.Phone = '33334444';
        cntct3.email='Site@gmail.com';
        contacts.add(cntct3);
        
        Contact cntct4 = new Contact();
        cntct4.LastName = 'billing';
        cntct4.Phone = '33334444';
        cntct4.email='billing@gmail.com';
        contacts.add(cntct4);
        
        Contact cntct5 = new Contact();
        cntct5.LastName = 'Delivery';
        cntct5.Phone = '33334444';
        cntct5.email='Delivery@gmail.com';
        contacts.add(cntct5);
        insert contacts;
        
        List<Functional_Contact_Role__c> fnRoles=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole4 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole5 = new Functional_Contact_Role__c();
        
        fcRole1.Role__c = 'Primary Site Contact';
        fcRole2.Role__c = 'Technical Contact';
        fcRole3.Role__c = 'Project Contact';
        fcRole4.Role__c = 'Billing Contact';
        fcRole4.Is_Primary__c=true;
        fcRole5.Role__c = 'Delivery Contact';
        
        
        fcRole1.ContactID__c = cntct1.id;
        fcRole2.ContactID__c = cntct2.id;
        fcRole3.ContactID__c = cntct3.id;
        fcRole4.ContactID__c = cntct4.id;
        fcRole5.ContactID__c = cntct5.id;
        
        fcRole1.SiteID__c = site.id;
        fcRole2.SiteID__c = site.id;
        fcRole3.SiteID__c = site.id;
        fcRole4.SiteID__c = site.id;
        fcRole5.SiteID__c = site.id;
        
        fnRoles.add(fcRole1);
        fnRoles.add(fcRole2);
        fnRoles.add(fcRole3);
        fnRoles.add(fcRole4);
        fnRoles.add(fcRole5);
        insert fnRoles;
        
        
        csord__Subscription__c subs3=new csord__Subscription__c();
        subs3.name  = 'test subs3';
        subs3.csord__Identification__c = 'test identity';
        subs3.csord__Order__c = ord3.Id;
        subs3.csord__Status__c = 'Inactive';
        subs3.Sub_status__c = 'Inactive';
        subs3.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294F';
        subs3.csordtelcoa__Subscription_Number__c = 'SN-123456';
        subs3.Site__c = site.Id;
        subs3.csord__Order_Request__c = ordReq3.Id;
        //modified for 73057
        subs3.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        subs3.Offer__c =offer.Id;
        //subs3.Primary_Order__c = primaryOrd2.Id;
               subList.add(subs3);
        
       
         
         insert subList;
        
        Test.StopTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User SignatoryContact3 = New User(Alias = 'newUser', Email='new1_kiran@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='new1_kiran@testorg.com');
        insert SignatoryContact3;
        
        ContractJunction__c CJ=new ContractJunction__c();
        CJ.name='testCJ';
        CJ.account__c=acc.id;
        CJ.Related_Opportunity__c = opp.id;
        CJ.Customer_Primary_Contact__c = contact.id;
        CJ.Related_Basket__c = basket.id;
        CJ.DocuSign_Signer_2__c = contact.id;
        CJ.DocuSign_Signer_3__c = SignatoryContact3.id;
        insert CJ;
        
    }

  
  @isTest
  static void processSubscriptionRecordTest(){
        System.debug('processSubscriptionRecordTest');
        csord__Subscription__c sub = [SELECT Id, csord__Order__r.csord__Primary_Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name,Sub_status__c from csord__Subscription__c where Name = 'test subs3'AND csordtelcoa__Product_Configuration__r.Type__c = 'Cancel' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.Id);
        List<Customer_Notify_Metadata__c> custMetadaList = [SELECT ID, emailTemplate__c, offerID__c,monitorObject__c From Customer_Notify_Metadata__c LIMIT 1];
        System.debug('custMetadaList++'+custMetadaList);
        Test.startTest();
        SubEmailService.processSubRecord(parameters);
        Test.stopTest();
        System.assertEquals('Inactive', sub.Sub_status__c);
    }

    
}