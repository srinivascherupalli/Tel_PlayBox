/*
===============================================================================================================================
Class : Model_serviceTest
Developer Name : shubhi
EDGE-185011
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.        shubhi              26.11.2020		EDGE-185011(new) 
===============================================================================================================================
//updated only MobilePhone value (none of other) to valid format on contact creation, to fix the testclass failure because of new validation implemented as part of DIGI-4056 (Team SFO :: 21.14)
*/
@isTest
public class Model_serviceTest {
   @TestSetup
   public static void testSetup(){
    	Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    	User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
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
                MobilePhone = '0423456789',
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
        
        //CREATE PC
        List<cscfga__Product_Configuration__c> transitionConfigs = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c();
        pc1.subType__c = '';
        pc1.cscfga__product_basket__c = basket4.id;
       	pc1.cscfga__Product_Definition__c=productDefinition.id;
        transitionConfigs.add(pc1);
        insert transitionConfigs;
       
    	Marketable_Offer__c mo = new Marketable_Offer__c(OfferDefinationName__c ='Adaptive Mobility',Name = 'Adaptive Mobility',
                                                     Offer_ID__c = 'DMCAT_Offer_001',
                                                     isNonChargeable__c=false,
                                                     Solution_Template__c='Adaptive Mobility');
		Insert mo;
       
    	List<csord__Solution__c> solLst = new List<csord__Solution__c>();	
    	csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
    	solLst.add(sol1);
    	insert solLst;
       
        List<csord__Subscription__c> subSet= new List<csord__Subscription__c>();
        csord__Subscription__c sub1 = new csord__Subscription__c();         
        sub1.cssdm__solution_association__c = sol1.id;
        sub1.MarketableOffer__c=mo.id;
        sub1.csordtelcoa__Product_Configuration__c=pc1.id;
        sub1.csord__Identification__c = 'Subscription_0';
		sub1.cssdm__solution_association__c=sol1.id;
        subSet.add(sub1);
        
        csord__Subscription__c sub2 = new csord__Subscription__c();         
        sub2.cssdm__solution_association__c = sol1.id;
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
           serv.serviceMSISDN__c='1234';
		   serv.csordtelcoa__Product_Configuration__c=testSubs.csordtelcoa__Product_Configuration__c;
		   serv.cssdm__solution_association__c=testSubs.cssdm__solution_association__c;
		   servlist.add(serv);
		}
        csord__Service__c serv = new csord__Service__c();
		   serv.name ='testService_'+sub2.id;
		   serv.csord__Identification__c  = 'testIdentify_4';
		   serv.csordtelcoa__Service_Number__c = '3';
		   serv.csord__Subscription__c = sub2.Id;
		   serv.csord__Status__c = 'Connected';
		   serv.Scenario_Type__c = '';
		   serv.csord__Deactivation_Date__c=date.today();
           serv.serviceMSISDN__c='1234';
		   serv.csordtelcoa__Product_Configuration__c=sub2.csordtelcoa__Product_Configuration__c;
		   serv.cssdm__solution_association__c=sub2.cssdm__solution_association__c;
		   servlist.add(serv);
		insert servlist;
       
  	}
	
	//Desc: Positive scenario for getServicesFromSolution
	@IsTest
	public static void getDisconnectedServicesFromSolutionTest(){
		Test.startTest();
			csord__Subscription__c sub = [select id,csordtelcoa__subscription_number__c,MarketableOffer__r.Offer_ID__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c from csord__Subscription__c where MarketableOffer__c!=null limit 1];
		
			User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
			System.runAS(sales){
				List<csord__Service__c> serviceList = new List<csord__Service__c>();  
				serviceList = Model_Service.getDisconnectedServicesFromSolution(sub.csordtelcoa__subscription_number__c,sub.MarketableOffer__r.Offer_ID__c,sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,28);
				for(csord__Service__c serv : serviceList){
					 System.assertEquals('Disconnected', serv.csord__Status__c);          
				
				}
			}
		Test.stopTest();  
	}
  
	//Desc: Negative scenario for returnSyncTransDevice
	@IsTest
	public static void getServicesFromSolutionNegativeTest(){
		Test.startTest();
		csord__Subscription__c sub = [select id,csordtelcoa__subscription_number__c,MarketableOffer__r.Offer_ID__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c from csord__Subscription__c where MarketableOffer__c=null limit 1];

		User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
		System.runAS(sales){

			List<csord__Service__c> serviceList = new List<csord__Service__c>();  
			serviceList = Model_Service.getDisconnectedServicesFromSolution(sub.csordtelcoa__subscription_number__c,sub.MarketableOffer__r.Offer_ID__c,sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,28);
			System.assertEquals(0, serviceList.size());          
		}
		Test.stopTest();
	}
     // INC000095032613 start-------------
    // method to filter service based  MSIDN number
    //Desc: Positive scenario for getActiveMisDNService
	@IsTest
	public static void getActiveMisDNServiceTest(){
		Test.startTest();
            Set<String> msidnNumerSet=new Set<String>();
            msidnNumerSet.add('1234');
			User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
			System.runAS(sales){
				List<csord__Service__c> serviceList = new List<csord__Service__c>();  
				serviceList = Model_Service.getActiveMisDNService(msidnNumerSet);
				for(csord__Service__c serv : serviceList){
					 System.assertEquals('Connected', serv.csord__Status__c);          
				}
			}
		Test.stopTest();  
	}
  
	//Desc: Negative scenario for getActiveMisDNService
	@IsTest
	public static void getActiveMisDNServiceNegativeTest(){
		Test.startTest();
        Set<String> msidnNumerSet=new Set<String>();
		User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
		System.runAS(sales){
			List<csord__Service__c> serviceList = new List<csord__Service__c>();  
			serviceList = Model_Service.getActiveMisDNService(msidnNumerSet);
			System.assertEquals(0, serviceList.size());          
		}
		Test.stopTest();
	}
    // INC000095032613 end-------------
}