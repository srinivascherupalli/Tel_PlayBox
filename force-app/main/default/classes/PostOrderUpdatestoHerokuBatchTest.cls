/*************************************************************************************************
Name : PostOrderUpdatestoHerokuBatchTest
===============================================================================================================================    
 Sr.No.     Developer Name      Date            Story           Description
    1.      Vamsi            25/MAR/2021       EDGE-178892     Device Id to be updated in Heroku to enable quick search in solution console
===============================================================================================================================
***************************************************************************************************/
@isTest
public class PostOrderUpdatestoHerokuBatchTest {
    
     @TestSetup
   public static void testSetup(){
       
               Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        List<User> listOfUsers = new List<User>();
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        //insert sales;
        listOfUsers.add(sales);

        Profile asaProfile = [select id from profile where name = 'Assurance Service Agent'];
        User asa = new User(alias = 'asauser',email='asauser@testasauser.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='ASA_Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = asaProfile.id,
                              timezonesidkey='Australia/Sydney',
                              username='asauser@testasauser.com',phone='0424289156');
        listOfUsers.add(asa);
        Insert listOfUsers;
       
        Account acc = new Account(Name = 'Burlington');
        insert acc;
       
    Contact con = new Contact();
    con.LastName = 'testContact';
    con.AccountId = acc.Id;
    insert con;
       
        /*Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        opp.AccountId = acc.id;
        insert opp;*/
       
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        //basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert basket;
       
        csord__Solution__c solution = new csord__Solution__c();
        solution.Name = 'Test Solution';
        solution.csord__Identification__c = 'Solution Management';
        insert solution;
       
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c='DMCAT_ProductSpecification_000935';
        insert pd;
       
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.id);
        config.cscfga__Product_Definition__c = pd.id;
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description CMP';
        config.cscfga__Contract_Term__c = 36;
        config.Commercial_Config__c='Yes';
        config.Quantity_Product_Configuration__c=1;
        config.cscfga__total_one_off_charge__c=100;
        config.cscfga__total_recurring_charge__c=100;
        config.name='Corporate Mobile Plus-Committed Data';
        config.Type__c = 'New';
        config.cscfga__Product_Family__c='Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.configGUID__c = '2b07b38f-4176-f866-3006-643c269b8a39';
        config.Quantity_Product_Configuration__c =1;
        config.cssdm__solution_association__c = solution.Id;
        insert config;
       
       csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        
        csord__Subscription__c subscrip = ProductTestFactory.buildSubscription('SubscriptionProd', acc.id, ord.Id, ordReq.id);
        insert subscrip;

        List<csord__Service__c> serList = new List<csord__Service__c>();
        csord__Service__c serv2 = ProductTestFactory.buildService('ServiceProd1', ord.Id, subscrip.Id, ordReq.id);
        serv2.csordtelcoa__Product_Configuration__c = config.Id;
        serv2.TenancyPrimaryContact__c= con.Id;
        serv2.Site_Delivery_Contact__c = con.Id;
        serv2.csord__status__c = 'Pending';
        serv2.Scenario_Type__c = System.Label.Device_Replacement;
        serv2.csordtelcoa__Service_Number__c = '3';
        serv2.cssdm__solution_association__c = solution.Id;
        serList.add(serv2); 
       
        csord__Service__c serv3 = ProductTestFactory.buildService('ServiceProd2', ord.Id, subscrip.Id, ordReq.id);
        serv3.csordtelcoa__Product_Configuration__c = config.Id;
        serv3.TenancyPrimaryContact__c= con.Id;
        serv3.Site_Delivery_Contact__c = con.Id;
        serv3.csord__status__c = 'Pending';
        serv3.Scenario_Type__c = System.Label.Device_Replacement;
        serv3.csordtelcoa__Service_Number__c = '3';
        serv3.cssdm__solution_association__c = solution.Id;
        serList.add(serv3);
       
       insert serList;
       
      List<Asset> assetlst = new List<Asset>();
       Asset ast = new Asset();
       ast.Name = 'TestAsset1';
       ast.Status = 'Active';
       ast.AccountId = acc.id;
       ast.ContactId = con.id;
       ast.AssetID__c = 'Test@ABC';
       ast.csord__Service__c = serv2.id;
       ast.HerokuUpdateStatus__c = 'Retry 1';
       assetlst.add(ast);
       
       Asset ast1 = new Asset();
       ast1.Name = 'TestAsset2';
       ast1.Status = 'Active';
       ast1.AccountId = acc.id;
       ast1.ContactId = con.id;
       ast1.AssetID__c = 'Test@999';
       ast1.csord__Service__c = serv3.id;
       ast1.HerokuUpdateStatus__c = 'Retry 2';
       assetlst.add(ast1);
       insert assetlst;
       
   }
       
  @isTest
  static void assetCheck(){
    Test.startTest();
    User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];      
    System.runAs(asaUser){
    List<Asset> asstList = [SELECT id,Name,HerokuUpdateStatus__c FROM Asset where AssetID__c = 'Test@ABC' LIMIT 1];
        Set<Id> asstSet = new Set<Id>();
        for(Asset obj:asstList)
        {
            asstSet.add(obj.id);  
        }
          String startKey = 'startAsset';
          String executeKey = 'executeAsset';
          String finishKey = 'finishAsset';
    PostOrderUpdatestoHerokuBatch batchInstance = new PostOrderUpdatestoHerokuBatch(asstSet,startKey,executeKey,finishKey); 
    Id ids = database.executeBatch(batchInstance);
    }
    Test.stopTest();
      Asset asst = [SELECT id,HerokuUpdateStatus__c FROM Asset LIMIT 1];
      system.assertEquals('Retry 1',asst.HerokuUpdateStatus__c );

  }
    
      @isTest
  static void assetCheckNegative(){
    Test.startTest();
    User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];      
    System.runAs(asaUser){
    List<Asset> asstList = [SELECT id,Name,HerokuUpdateStatus__c FROM Asset];
        Set<Id> asstSet = new Set<Id>();
        for(Asset obj:asstList)
        {
            asstSet.add(obj.id);  
        }
          String startKey = 'startAsset';
          String executeKey = 'executeAsset';
          String finishKey = 'finishAsset';
    PostOrderUpdatestoHerokuBatch batchInstance = new PostOrderUpdatestoHerokuBatch(asstSet,startKey,executeKey,finishKey); 
    Id ids = database.executeBatch(batchInstance);
    }
    Test.stopTest();
      Asset asst = [SELECT id,HerokuUpdateStatus__c FROM Asset LIMIT 1];
      system.assertEquals('Retry 1',asst.HerokuUpdateStatus__c );

  }

}