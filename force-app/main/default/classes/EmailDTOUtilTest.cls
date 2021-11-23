@isTest
private class EmailDTOUtilTest {
  
   @Testsetup
    static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Account_Status__c='Active';
        acc.Customer_Status__c	= 'Active';
        insert acc;
        System.debug('Account::'+acc);
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        contact.Email = 'r@gmail.com';
        insert contact;
        System.debug('contact::'+contact);
        opportunity opp = new opportunity();
        opp.Name='TestOpp';
        opp.StageName='Closed Won';
        opp.CloseDate=System.today();
        opp.OwnerId = UserInfo.getUserId();
        opp.AccountId = acc.id;
        insert opp;
        System.debug('opp::'+opp);
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        System.debug('ordReq::'+ordReq);
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        insert ord;
        
        cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
        insert addr;
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
        insert site;
        //Added for 73057
		
		cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
		offer.Offer_Spec_Id__c = 'DMCAT_Offer_000303';
		insert offer;
		
        APXTConga4__Conga_Email_Template__c congaTemplatesubs =new APXTConga4__Conga_Email_Template__c();
        congaTemplatesubs.APXTConga4__HTMLBody__c = 'test conga';
		//congaTemplatesubs.Name = 'CET-00026';
		congaTemplatesubs.APXTConga4__Name__c = 'SubscriptionStatusActive';
        insert congaTemplatesubs;
        
		Customer_Notify_Metadata__c custNotify = new Customer_Notify_Metadata__c();
        custNotify.productDefinitionCode__c ='DMCAT_ProductSpecification_000304';
        custNotify.offerID__c = 'DMCAT_Offer_000303';
        custNotify.monitorObjectStatus__c = 'Active';
        custNotify.emailTemplate__c = congaTemplatesubs.id;
        insert custNotify;
		
		
		
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.csord__Status__c = 'Provisioning In Progress';
        subs.Sub_status__c = 'Active';
        subs.emailSent__c = false;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        subs.Site__c = site.Id;
		subs.offer__c = offer.Id;
        insert subs;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='IP Site';
        serv.Primary_Contact__c = contact.id;
        serv.Project_Contact__c = contact.id;
        serv.Technical_Contact__c = contact.id;
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        insert serv;
        
        APXTConga4__Conga_Email_Template__c congaTemplate =new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        insert congaTemplate;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        insert basket;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        ocr.ROLE = 'Decision Maker';
        insert ocr;
        
        acc = new Account(Name = 'Burlington',Account_Status__c='Active');
        insert acc;
        
        Test.startTest();
      	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User SignatoryContact3 = New User(Alias = 'newUser', Email='new1_kiran@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='new1_kiran@testorg.com');
        insert SignatoryContact3;
        cscfga__Product_Basket__c basket1 = [SELECT Id,csbb__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE csordtelcoa__Basket_Stage__c = 'Contract Accepted' order by id desc LIMIT 1][0];


      	system.debug('basket1 '+basket1);
       	Contact contact1 = AccountTestFactory.buildContact(acc, 'Joe');
        contact1.FirstName = 'Kiran';
        contact1.LastName = 'S';
        contact1.Pref_Comm_Method__c='eMail';
        contact1.MobilePhone='0423456789'; //FDR Fix for sprint 21.14
        contact1.email='k@gmail.com';
        contact1.AccountId = acc.id;
        insert contact1;
          
        ContractJunction__c CJ=new ContractJunction__c();
        CJ.name='testCJ1';
        CJ.account__c=acc.id;
        CJ.Related_Opportunity__c = basket1.cscfga__Opportunity__c;
        CJ.Customer_Primary_Contact__c = contact1.id;
        CJ.Related_Basket__c = basket1.id;
        CJ.DocuSign_Signer_2__c = contact1.id;
        CJ.DocuSign_Signer_3__c = SignatoryContact3.id;
        insert CJ;
       Test.stopTest(); 
    }

    @isTest
  static void testProcessSubscriptionRecord(){
    List<String> parameters = new List<String>();
     Test.startTest();
      csord__Subscription__c sub = [SELECT Id, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1][0];
      parameters.add(sub.csordtelcoa__Subscription_Number__c+':::'+sub.id);
      EmailDTOUtil.processSubscriptionRecord(parameters);
    Test.stopTest();
    System.assertNotEquals(sub.csord__Status__c, null);
  }
}