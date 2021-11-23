/**
* Class for custom button skip contract test.
* Modified by - Pooja/Gunjan      11-02-2021      EDGE-191824|| EDGE-192931
* Modified by - Aman Soni         22-04-2021      EDGE-207355
*                Shubhi                           13-9-2021        fdr test class fix
*/
@isTest
public class CustomButtonSkipContractTest {
    
    @testSetup static void testdataMethod(){
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia','Migration BOH user')])
            profilesMap.put(profile.Name, profile);
        
        User migrationUser = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =profilesMap.get('Migration BOH user').id, country='United States',IsActive =true,                
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser@test.com');
        insert migrationUser;
        
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration'); 
        customSetting.Name = 'CommercialConfiguration';
        customSetting.External_Id__c = 'CCO_T_1';
        customSetting.Opportunity_Stage__c = 'Develop';
        insert customSetting;
        CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Quote'); 
        customSetting1.Name = 'Quote';
        customSetting1.External_Id__c = 'CCO_T_12';
        customSetting1.Opportunity_Stage__c = 'Develop';
        insert customSetting1;
        CustomConfigurationOptions__c customSetting2= new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Contract Accepted'); 
        customSetting2.Name = 'ContractAccepted';
        customSetting2.External_Id__c = 'CCO_T_123';
        customSetting2.Opportunity_Stage__c = 'Develop';
        insert customSetting2;
        
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        List<Opportunity>opportunityList=new List<Opportunity>();
        Id recodtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        //opp.RecordtypeId = recodtypeId;
        opp.Model_Change__c=true;
        opp.stageName='Define';
        //opp.Billing_Solution__c = 'Standard';
        opportunityList.add(opp);
        
        System.debug('Id '+recodtypeId);
        Opportunity migrationOpp = new Opportunity();
        migrationOpp.RecordtypeId = recodtypeId;
        migrationOpp.AccountId = acc.Id;
        migrationOpp.Name = 'Migration Opportunity';
        migrationOpp.Product_Domain__c = 'OTHER';
        migrationOpp.StageName = 'Develop';
        migrationOpp.Product_Type__c = 'Modular';
        migrationOpp.CloseDate = System.Date.today();
        migrationOpp.Description__c = 'test';
        migrationOpp.Type = 'Migration';
        migrationOpp.Billing_Solution__c = 'Standard';
        //migrationOpp.In_Contract_MAC__c = 'No';
        opportunityList.add(migrationOpp);
        
        
        Opportunity migrationOpp1 = new Opportunity();
        migrationOpp1.RecordtypeId = recodtypeId;
        migrationOpp1.AccountId = acc.Id;
        migrationOpp1.Name = 'MigrationOpportunityTCM';
        migrationOpp1.Product_Domain__c = 'OTHER';
        migrationOpp1.StageName = 'Develop';
        migrationOpp1.Product_Type__c = 'Modular';
        migrationOpp1.CloseDate = System.Date.today();
        migrationOpp1.Description__c = 'test';
        migrationOpp1.Type = 'Migration';
        migrationOpp1.Billing_Solution__c = 'Standard';
        //migrationOpp1.In_Contract_MAC__c = 'No';
        opportunityList.add(migrationOpp1);
        
        insert opportunityList;
        
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        //basket.name='test 1234';        
        basket.cscfga__Opportunity__c=opp.id;
        basket.Express_Flow__c=true;
        update basket;
        
        //EDGE-191824|| EDGE-192931 start
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Opportunity opp1 = ProductTestFactory.getOpportunity(acc, pb);
        opp1.StageName = 'Develop';
        opp1.Product_Type__c = 'Modular';
        opp1.Name = 'TestingOpp1';
        insert opp1;
        
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        insert ordReq2;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq2.id);
        primaryOrd.csord__Order_Request__c = ordReq2.Id;
        primaryOrd.csordtelcoa__Opportunity__c = opp1.Id;
        insert primaryOrd; 
        //EDGE-226364 changes start
        csord__Order__c primaryOrd1 = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq2.id);
        primaryOrd1.csord__Order_Request__c = ordReq2.Id;
        primaryOrd1.csordtelcoa__Opportunity__c = migrationOpp.Id;
        insert primaryOrd1;
        //EDGE-226364 changes End
        String PBrecordTypeID = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        cscfga__Product_Basket__c basket5 = new cscfga__Product_Basket__c();
        basket5.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket5.cscfga__Opportunity__c = opp1.id;
        basket5.csbb__Account__c = acc.Id;
        basket5.Name = 'TestInflightBakset';
        basket5.cscfga__Basket_Status__c = 'Valid';

        //EDGE-191824|| EDGE-192931 end
        
        List<cscfga__Product_Basket__c> basketList=new List<cscfga__Product_Basket__c>();
        basketList.add(basket5);
        cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
        migrationOppBasket.csbb__Account__c = acc.Id;
        migrationOppBasket.Name = 'Migration Opportunity Basket';
        migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
        migrationOppBasket.cscfga__Basket_Status__c  = 'Valid';  
        basketList.add(migrationOppBasket);
        
        cscfga__Product_Basket__c migrationOppBasketTCM = new cscfga__Product_Basket__c();
        migrationOppBasketTCM.csbb__Account__c = acc.Id;
        migrationOppBasketTCM.Name = 'Migration Opportunity Basket TCM';
        migrationOppBasketTCM.cscfga__Opportunity__c = migrationOpp1.Id;
        migrationOppBasketTCM.cscfga__Basket_Status__c  = 'Valid';   
        basketList.add(migrationOppBasketTCM);
        
        insert basketList;
        
        //Added by Aman Soni for EDGE-207355|| Start
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com'   
        );
        insert contact; 

        csord__Solution__c solution= PricingTestDataFactory.generateSolution('AdaptiveMobility');
        csord__Solution__c solution1= PricingTestDataFactory.generateSolution('AdaptiveMobility1');
        insert new List<csord__Solution__c>{solution,solution1};

        cscfga__Product_Configuration__c config = PricingTestDataFactory.generateProductConfiguration('SolutionComponent','New',migrationOppBasket.id,solution.id,'');
        cscfga__Product_Configuration__c config1 = PricingTestDataFactory.generateProductConfiguration('','New',migrationOppBasketTCM.id,solution1.id,'');
        insert new List<cscfga__Product_Configuration__c>{config,config1};

        Billing_Account__c billAcc1=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=contact.Id, status__c='Allocated',Account__c=acc.id);
        Billing_Account__c billAcc2=new Billing_Account__c(Billing_Account_Number__c='123456789011',Billing_Account_Owner__c=contact.Id, status__c='Final',Account__c=acc.id);
        insert new List<Billing_Account__c>{billAcc1,billAcc2};

        cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc1.id , config.id);
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , config1.id);
        insert new List<cscfga__Attribute__c>{attr0,attr1};
        //Added by Aman Soni for EDGE-207355 || End

        ContractJunction__c  contract = new ContractJunction__c();
        contract.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contract.Related_Basket__c = migrationOppBasket.id;
        contract.CongaStatus__c = 'NotStarted';
        contract.Account__c = migrationOppBasket.csbb__Account__c;
        contract.Related_Opportunity__c = migrationOppBasket.cscfga__Opportunity__c;
        contract.Contract_Activated_Date__c = System.today();
        contract.Contract_Term_Months__c = 36;
        contract.Name = 'CN' + 'Migration Opportunity Basket';
        contract.GPTVersion__c=1.2;
        contract.OFTVersion__c=0.0;
        contract.BSAVersion__c=0.0;
        contract.isDSAGenerated__c=true;
        insert contract;

        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();//EDGE-226364 added
        
         Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=contract.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
        insert agreement;
        
        Apttus__APTS_Agreement__c agreementPS = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=contract.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Parent_Agreement__c=agreement.id);
        insert agreementPS;
               
    }
    @isTest 
    static void performActionTest() {       
        cscfga__Product_Basket__c basket=[Select id,name,Express_Flow__c from cscfga__Product_Basket__c limit 1];
        Test.startTest();
        CustomButtonSkipContract newCustomButtonSkipContract = new CustomButtonSkipContract();
        newCustomButtonSkipContract.performAction(basket.Id);
        string basketid='';
        newCustomButtonSkipContract.performAction(basketid);
        System.assert(basket!=null);
        Test.stopTest();    
    }
    @isTest  static void performActionForMigrationOppBasketTest() {
        cscfga__Product_Basket__c basket=[Select id,name,csbb__Account__c,cscfga__Opportunity__r.Name from cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'Migration Opportunity' limit 1];
        Test.startTest();
        CustomButtonSkipContract newCustomButtonSkipContract = new CustomButtonSkipContract();
        newCustomButtonSkipContract.performAction(basket.Id);
        List<Apttus__APTS_Agreement__c> existingDSAAgreementOnAccount= [SELECT Id, RecordTypeId,name,Apttus__Agreement_Number__c,Apttus__Status_Category__c, Apttus__Agreement_Category__c FROM Apttus__APTS_Agreement__c where Apttus__Account__c=:basket.csbb__Account__c ];
        List<ContractJunction__c> existingContract = [select id,Contract_Activated_Date__c,Agreement_Number__c,Related_Price_Schedule__c from ContractJunction__c LIMIT 1];
        System.assertEquals(existingDSAAgreementOnAccount[1].Apttus__Agreement_Number__c,existingContract[0].Agreement_Number__c);
        Test.stopTest();
        
    }
    @isTest 
    static void migrationOrderTM2FlowTest() {
        cscfga__Product_Basket__c basket=[Select id,name,cscfga__Opportunity__r.Name from cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'MigrationOpportunityTCM' limit 1];
        User u = [SELECT Id FROM User WHERE username ='migrationBOHUser@test.com' LIMIT 1];
        Test.startTest();
        CustomButtonSkipContract newCustomButtonSkipContract = new CustomButtonSkipContract();
        newCustomButtonSkipContract.performAction(basket.Id);
        List<ContractJunction__c> newContract = [SELECT id,IsMigratedContract__c,Related_Basket__c from ContractJunction__c WHERE Related_Basket__c =: basket.id LIMIT 1];
        system.assertEquals(newContract[0].IsMigratedContract__c,true);       
        Test.stopTest();       
    }
    
    //EDGE-191824|| EDGE-192931 start
    @isTest static void performActionTest1(){
        Test.startTest();
         cscfga__Product_Basket__c basket = [SELECT id, recordType.Name FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp1' and cscfga__Basket_Status__c ='Valid' LIMIT 1];             
        Id recordtypeId = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        basket.RecordTypeId = recordtypeId;
        update basket;
        CustomButtonSkipContract newCustSkipContract = new CustomButtonSkipContract();
        String returnVal = newCustSkipContract.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals(true, returnVal.containsIgnoreCase('error') );
    }
    //EDGE-191824|| EDGE-192931 end
    //EDGE-226364 Added test Method
    @isTest  static void performActionForMigrationOppBasketTestNew() {
        Test.startTest();
        cscfga__Product_Basket__c basket=[Select id,name,csbb__Account__c,cscfga__Opportunity__r.Name from cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'Migration Opportunity' limit 1];
        Id recordtypeId = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        basket.RecordTypeId = recordtypeId;
        update basket;       
        CustomButtonSkipContract newCustomButtonSkipContract = new CustomButtonSkipContract();
        newCustomButtonSkipContract.performAction(basket.Id);
        Test.stopTest();
        List<Apttus__APTS_Agreement__c> existingDSAAgreementOnAccount= [SELECT Id, RecordTypeId,name,Apttus__Agreement_Number__c,Apttus__Status_Category__c, Apttus__Agreement_Category__c FROM Apttus__APTS_Agreement__c where Apttus__Account__c=:basket.csbb__Account__c ];
        List<ContractJunction__c> existingContract = [select id,Contract_Activated_Date__c,Agreement_Number__c,Related_Price_Schedule__c from ContractJunction__c LIMIT 1];
        system.debug('existingContract'+existingContract);
        system.debug('existingDSAAgreementOnAccount'+existingDSAAgreementOnAccount);
        System.assertEquals(existingDSAAgreementOnAccount[1].Apttus__Status_Category__c,'In Effect');        
        
    }
    
}