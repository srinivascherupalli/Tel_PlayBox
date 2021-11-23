/*
===============================================================================================================================
Class : Model_attachmenttest
Developer Name : shubhi
Edge-185856
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.              Shubhi V            15-12-2020          Edge-185856 
===============================================================================================================================
*/
@isTest
public class Model_attachmenttest {
  @TestSetup
   public static void testSetup(){
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
        //CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE');
        insert acc;
        //CREATE CONTACT 
        Contact con1 = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
         );
        insert con1;    
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
       
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Enterprise Mobility Plan';
        productDefinition.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_001196';
        insert productDefinition;
        
       //CREATE BASKET
        cscfga__Product_Basket__c basket4 = ProductTestFactory.buildEmptyBasket();
        basket4.csbb__Account__c = acc.id;
        basket4.cscfga__Opportunity__c = opp.id;
        basket4.Project_ID__c = 'basket4';      
        basket4.cscfga__Basket_Status__c = 'Valid';     
        insert new List<cscfga__Product_Basket__c>{basket4};
        
        
       
        Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='Adaptive Mobility',Name = 'Adaptive Mobility',
                                                     Offer_ID__c = 'DMCAT_Offer_001',
                                                     isNonChargeable__c=false,
                                                     Solution_Template__c='Adaptive Mobility');
        Insert mo;
       
        List<csord__Solution__c> solLst = new List<csord__Solution__c>();   
        csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
        solLst.add(sol1);
        csord__Solution__c sol2= PricingTestDataFactory.generateSolution('nextgenEM_positive');
        solLst.add(sol2);
        insert solLst;
        
        //CREATE PC
        List<cscfga__Product_Configuration__c> transitionConfigs = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c();
        pc1.subType__c = '';
        pc1.cscfga__product_basket__c = basket4.id;
        pc1.cscfga__Product_Definition__c=productDefinition.id;
        pc1.cssdm__solution_association__c =sol1.id;
        transitionConfigs.add(pc1);
        cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c();
        pc2.subType__c = '';
        //pc2.cscfga__product_basket__c = basket4.id;
        pc2.cscfga__Product_Definition__c=productDefinition.id;
        pc2.cssdm__solution_association__c =sol2.id;
        transitionConfigs.add(pc2);
        insert transitionConfigs;
        
        pc1.csordtelcoa__Replaced_Product_Configuration__c=pc2.id;
        update pc1;
        
    
        List<csord__Subscription__c> subSet= new List<csord__Subscription__c>();
        csord__Subscription__c sub1 = new csord__Subscription__c();         
        sub1.cssdm__solution_association__c = sol2.id;
        sub1.MarketableOffer__c=mo.id;
        sub1.csordtelcoa__Product_Configuration__c=pc1.id;
        sub1.csord__Identification__c = 'Subscription_0';
        subSet.add(sub1);
        
        csord__Subscription__c sub2 = new csord__Subscription__c();         
        sub2.cssdm__solution_association__c = sol2.id;
         sub2.csordtelcoa__Product_Configuration__c=pc1.id;
        sub2.csord__Identification__c = 'Subscription_1';
        subSet.add(sub2);
        insert subSet; 
     
        List<csord__Service__c> servlist=new List<csord__Service__c>();
        for(csord__Subscription__c testSubs:subSet)
        {
           csord__Service__c serv = new csord__Service__c();
           serv.name ='testService_'+testSubs.id;
           serv.csord__Identification__c  = 'testIdentify_4';
           serv.csordtelcoa__Service_Number__c = '3';
           serv.csord__Subscription__c = testSubs.Id;
           serv.csord__Status__c = 'Disconnected';
           serv.Scenario_Type__c = '';
           serv.csord__Deactivation_Date__c=date.today();
           serv.csordtelcoa__Product_Configuration__c=testSubs.csordtelcoa__Product_Configuration__c;
           serv.cssdm__solution_association__c=testSubs.cssdm__solution_association__c;
           servlist.add(serv);
        }
        insert servlist;
		// Shubhi V            15-12-2020          Edge-185856 
	 List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"a4e2O000000D1aKQAS","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"40.90","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_8121","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"70c4e2dd-0a78-18ff-4971-66d3bc343b18","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2O000000giNjUAI","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = servlist[0].Id;
        atts.add(att1);
        
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"a4e2O000000D1aKQAS","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"40.90","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_8121","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"70c4e2dd-0a78-18ff-4971-66d3bc343b18","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2O000000giNjUAI","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"}]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = servlist[1].Id;
        atts.add(att2);
        
        insert atts;
        
       
       pc1.csordtelcoa__Replaced_Subscription__c=sub1.id;
       update pc1;
       
    }
    
    //Desc: Positive scenario for getServiceSpecs
	@IsTest
	public static void getDisconnectedServicesFromSolutionTest(){
		Test.startTest();
        	List<String> subsNumlist=new List<String>();
            for(csord__Subscription__c sub :[select id,csordtelcoa__subscription_number__c,MarketableOffer__r.Offer_ID__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c from csord__Subscription__c]){
                subsNumlist.add(sub.csordtelcoa__subscription_number__c);
            }
			User sales = [select name,id, lastname from  User where email='salesuser@testsales.com' limit 1 ];
			System.runAS(sales){
				List<Attachment> serviceList = new List<Attachment>();  
				serviceList = Model_attachment.getServiceSpecs(subsNumlist);
				for(Attachment att : serviceList){
					 System.assertEquals('ServiceSpecifications.json', att.name);          
				}
			}
		Test.stopTest();  
	}
  
	//Desc: Negative scenario for getServiceSpecs
	@IsTest
	public static void getServicesFromSolutionNegativeTest(){
		Test.startTest();
		List<String> subsNumlist=new List<String>();
			User sales = [select name,id, lastname from  User where email='salesuser@testsales.com' limit 1 ];
			System.runAS(sales){
				List<Attachment> serviceList = new List<Attachment>();  
				serviceList = Model_attachment.getServiceSpecs(subsNumlist);
				System.assertEquals(0, serviceList.size());          
			}
		Test.stopTest();
	}
    
}