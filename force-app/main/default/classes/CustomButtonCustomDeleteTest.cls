@isTest
private class CustomButtonCustomDeleteTest {
     @testsetup
	 static void testdata() {
        //CREATE ACCOUNT
         Account acc = AccountTestFactory.buildAccount('Test Account12345') ;
         acc.Customer_Status__c = System.Label.Active;
         insert acc;
         System.assertNotEquals(null,acc);

         
         //CREATE OPPORTUNITY
         Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
         //opp.IsActiveAccount__c = true;
         insert opp;
         System.assertNotEquals(null,opp);
         
          //Create Basket
          cscfga__Product_Basket__c prodBasket  = ProductTestFactory.buildEmptyBasket();
          prodBasket .csbb__Account__c = acc.id;
          prodBasket .cscfga__Opportunity__c = opp.id;
          prodBasket .Name = 'basket1';
          insert prodBasket ;
               

        
		 List<cscfga__Product_Configuration__c> configList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;       
		cscfga__Product_Configuration__c config6= ProductTestFactory.buildProductConfig(pd.Id);
        config6.name= System.Label.IP_Network;
        config6.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config6);
		cscfga__Product_Configuration__c config7= ProductTestFactory.buildProductConfig(pd.Id);
        config7.name= System.Label.UC_Config_Name;
        config7.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config7);
		cscfga__Product_Configuration__c config8= ProductTestFactory.buildProductConfig(pd.Id);
        config8.name= 'Mobile 1';
        config8.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config8);
		cscfga__Product_Configuration__c config9= ProductTestFactory.buildProductConfig(pd.Id);
        config9.name= 'Mobile 2';
        config9.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config9);
		cscfga__Product_Configuration__c config10= ProductTestFactory.buildProductConfig(pd.Id);
        config10.name= 'Mobile 3';
        config10.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config10);

        insert configList;
		
		List <csbb__Product_Configuration_Request__c> pcrList = new List <csbb__Product_Configuration_Request__c>();
		csbb__Product_Configuration_Request__c  pcr6=ProductTestFactory.buildConfigRequest(prodBasket.id,config6.id);               
        pcr6.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr6);
		
		csbb__Product_Configuration_Request__c  pcr7=ProductTestFactory.buildConfigRequest(prodBasket.id,config7.id);               
        pcr7.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr7);
		csbb__Product_Configuration_Request__c  pcr8=ProductTestFactory.buildConfigRequest(prodBasket.id,config8.id);               
        pcr8.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr8);
		csbb__Product_Configuration_Request__c  pcr9=ProductTestFactory.buildConfigRequest(prodBasket.id,config9.id);               
        pcr9.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr9);
		csbb__Product_Configuration_Request__c  pcr10=ProductTestFactory.buildConfigRequest(prodBasket.id,config10.id);               
        pcr10.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr10);
		
		insert pcrList;
		List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
		
		
		csord__Subscription__c IpSite = new csord__Subscription__c(
        Name = System.Label.IP_Site,
		csord__Status__c = System.Label.Active,
        csord__Identification__c = 'Subscription_a3T2O000000G',
        csord__Account__c = acc.id );
		lstSubs.add(IpSite);

        csord__Subscription__c IpSite1 = new csord__Subscription__c(
        Name = System.Label.IP_Site,
		csord__Status__c = System.Label.Active,
        csord__Identification__c = 'Subscription_a3T2O000000G111',
        csord__Account__c = acc.id );
		lstSubs.add(IpSite1);

	    csord__Subscription__c IpSite2 = new csord__Subscription__c(
        Name = System.Label.IP_Site,
		csord__Status__c = System.Label.Active,
        csord__Identification__c = 'Subscription_a3T2O000000G111',
        csord__Account__c = acc.id );
		lstSubs.add(IpSite2);
        insert lstSubs;
		       
    }
    @isTest
    private static void performActionDeleteIPModifyUCEINW() {
		cscfga__Product_Basket__c prodBasket = [Select id from cscfga__Product_Basket__c];
		 List<cscfga__Product_Configuration__c> configList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
		cscfga__Product_Configuration__c config3= ProductTestFactory.buildProductConfig(pd.Id);
        config3.name= System.Label.Connected_Workplace;
        config3.Type__c= System.Label.Cancel;
        config3.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config3);
		cscfga__Product_Configuration__c config4= ProductTestFactory.buildProductConfig(pd.Id);
        config4.name= System.Label.Connected_Workplace;
        config4.Type__c= System.Label.Cancel;
        config4.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config4);
		cscfga__Product_Configuration__c config5= ProductTestFactory.buildProductConfig(pd.Id);
        config5.name= System.Label.Connected_Workplace;
        config5.Type__c= System.Label.Cancel;
        config5.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config5);
		
		
		insert configList;
		List <csbb__Product_Configuration_Request__c> pcrList = new List <csbb__Product_Configuration_Request__c>();
		csbb__Product_Configuration_Request__c  pcr3=ProductTestFactory.buildConfigRequest(prodBasket.id,config3.id);               
        pcr3.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr3);
		csbb__Product_Configuration_Request__c  pcr4=ProductTestFactory.buildConfigRequest(prodBasket.id,config4.id);               
        pcr4.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr4);
		csbb__Product_Configuration_Request__c  pcr5=ProductTestFactory.buildConfigRequest(prodBasket.id,config5.id);               
        pcr5.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr5);
		insert pcrList;
		List <csbb__Product_Configuration_Request__c> allPCRIDs = new List <csbb__Product_Configuration_Request__c> ([Select id, csbb__Product_Basket__c ,csbb__Product_Category__c , Type__c, Product_Configuration_Name__c ,csbb__Product_Configuration__r.Id , csbb__Product_Configuration__r.Name  from csbb__Product_Configuration_Request__c  where Product_Configuration_Name__c = 'Connected Workplace' limit 2]);

		String PCRID ;
		String basketId = ''+ prodBasket.id;
		String regex = 'null|\\,]';
		for (csbb__Product_Configuration_Request__c pcr: allPCRIDs){
			
			PCRID = PCRID +'\"' + pcr.Id +'\",' ;
			
		}
		PCRID = PCRID.replaceAll(regex, '');
		PCRID = '[' + PCRID + ']' ;
		
		Test.startTest();
		
		CustomButtonCustomDelete CustDelete = new CustomButtonCustomDelete ();
		String returnVal = CustDelete.performAction(basketId,PCRID);

        Test.stopTest();
    }
    
        @isTest
    private static void performActionDeleteIPModifyUCEINW2() {
		List <csbb__Product_Configuration_Request__c> allPCRIDs = new List <csbb__Product_Configuration_Request__c> ([Select id, csbb__Product_Basket__c ,csbb__Product_Category__c , Type__c, Product_Configuration_Name__c ,csbb__Product_Configuration__r.Id , csbb__Product_Configuration__r.Name  from csbb__Product_Configuration_Request__c  where Product_Configuration_Name__c in ('Mobile 1','Mobile 2','Connected Workplace')]);
		cscfga__Product_Basket__c pb = [Select id from cscfga__Product_Basket__c ];
		String PCRID ;
		String basketId = ''+ pb.id;
		String regex = 'null|\\,]';
		for (csbb__Product_Configuration_Request__c pcr: allPCRIDs){
			
			PCRID = PCRID +'\"' + pcr.Id +'\",' ;
			
		}
		PCRID = PCRID.replaceAll(regex, '');
		PCRID = '[' + PCRID + ']' ;
		
		Test.startTest();
		
		CustomButtonCustomDelete CustDelete = new CustomButtonCustomDelete ();
		String returnVal = CustDelete.performAction(basketId,PCRID);

        Test.stopTest();
    }
        @isTest
    private static void performActionDeleteIPUCEDelete() {
		List <csbb__Product_Configuration_Request__c> allPCRIDs = new List <csbb__Product_Configuration_Request__c> ([Select id, csbb__Product_Basket__c ,csbb__Product_Category__c , Type__c, Product_Configuration_Name__c ,csbb__Product_Configuration__r.Id , csbb__Product_Configuration__r.Name  from csbb__Product_Configuration_Request__c  where Product_Configuration_Name__c = 'IP Network' OR  Product_Configuration_Name__c = 'Unified Communication' limit 5]);
		cscfga__Product_Basket__c prodBasket = [Select id from cscfga__Product_Basket__c];
        
		String PCRID ;
		String basketId = ''+ prodBasket.id;
		String regex = 'null|\\,]';
		for (csbb__Product_Configuration_Request__c pcr: allPCRIDs){
			
			PCRID = PCRID +'\"' + pcr.Id +'\",' ;
			
		}
		PCRID = PCRID.replaceAll(regex, '');
		PCRID = '[' + PCRID + ']' ;
		
		Test.startTest();
		
		CustomButtonCustomDelete CustDelete = new CustomButtonCustomDelete ();
		String returnVal = CustDelete.performAction(basketId,PCRID);

        Test.stopTest();
    }
     @isTest
    private static void performActionDeleteIPUCEDelete2() {
		
		cscfga__Product_Basket__c prodBasket = [Select id from cscfga__Product_Basket__c];
       	List<cscfga__Product_Configuration__c> configList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
		cscfga__Product_Configuration__c config3= ProductTestFactory.buildProductConfig(pd.Id);
        config3.name= System.Label.IP_Site_Label;
        config3.Type__c = System.Label.Cancel;
        config3.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config3);
		cscfga__Product_Configuration__c config4= ProductTestFactory.buildProductConfig(pd.Id);
        config4.name= System.Label.IP_Site_Label;
        config4.Type__c = System.Label.Cancel;
        config4.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config4);
		cscfga__Product_Configuration__c config5= ProductTestFactory.buildProductConfig(pd.Id);
        config5.name= System.Label.IP_Site_Label;
        config5.Type__c = System.Label.Cancel;
        config5.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config5);
		
		
		insert configList;
		List <csbb__Product_Configuration_Request__c> pcrList = new List <csbb__Product_Configuration_Request__c>();
		csbb__Product_Configuration_Request__c  pcr3=ProductTestFactory.buildConfigRequest(prodBasket.id,config3.id);               
        pcr3.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr3);
		csbb__Product_Configuration_Request__c  pcr4=ProductTestFactory.buildConfigRequest(prodBasket.id,config4.id);               
        pcr4.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr4);
		csbb__Product_Configuration_Request__c  pcr5=ProductTestFactory.buildConfigRequest(prodBasket.id,config5.id);               
        pcr5.csbb__Product_Basket__c = prodBasket.Id;
		pcrList.add(pcr5);
		insert pcrList;
        List <csbb__Product_Configuration_Request__c> allPCRIDs = new List <csbb__Product_Configuration_Request__c> ([Select id, csbb__Product_Basket__c ,csbb__Product_Category__c , Type__c, Product_Configuration_Name__c ,csbb__Product_Configuration__r.Id , csbb__Product_Configuration__r.Name  from csbb__Product_Configuration_Request__c  where Product_Configuration_Name__c = 'IP Site'  limit 2]);
		String PCRID ;
		String basketId = ''+ prodBasket.id;
		String regex = 'null|\\,]';
		for (csbb__Product_Configuration_Request__c pcr: allPCRIDs){
			PCRID = PCRID +'\"' + pcr.Id +'\",' ;
		}
		PCRID = PCRID.replaceAll(regex, '');
		PCRID = '[' + PCRID + ']' ;
		
		Test.startTest();
		
		CustomButtonCustomDelete CustDelete = new CustomButtonCustomDelete ();
		String returnVal = CustDelete.performAction(basketId,PCRID);

        Test.stopTest();
    }
}