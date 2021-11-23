/*************************************************************************************************
Name : InflightSubmitBasketBatchTest
===============================================================================================================================    
 Sr.No.     Developer Name      Date            Story           Description
    1.      Vamsi            05/FEB/2021      EDGE-199696     Align Colombo Submit Basket functionality with Istanbul framework


===============================================================================================================================
***************************************************************************************************/
@isTest
public class InflightSubmitBasketBatchTest {
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
        insert Acc;
       
    Contact con = new Contact();
    con.LastName = 'testContact';
    con.AccountId = acc.Id;
    insert con;
       
    list<cscfga__Product_Basket__c> prodBasList= new list<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c prodBas= new cscfga__Product_Basket__c();
    prodBas.csordtelcoa__Account__c=Acc.id;
    prodBas.name='Test';
    prodBas.Order_Requester__c = con.Id;
    prodBas.csbb__Synchronised_With_Opportunity__c=true;
    prodBas.OF_Reversal_Inserted__c=true;
    prodBas.sync_job_Id__c='[{"name":"submitJobId","isCompleted":true,"id":"7072N00000L8FF2QAQ","error":true}]';
    prodBas.referencenumber__c='TNC000000000';
    Id recType = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
    prodBas.RecordtypeId = recType;
    prodBasList.add(prodBas);       
    insert prodBasList;
    
    cscfga__Product_Definition__c prodDef= new cscfga__Product_Definition__c();
    prodDef.name='Submit_BasketBatch';
    prodDef.cscfga__Description__c='Submit_BasketBatch';
    prodDef.product_Specification__c='DMCAT_ProductSpecification_000753';
    insert prodDef;
    
    List<cscfga__Product_Configuration__c> prodConfigLst = new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
    newConfig.name = 'new config';
    newConfig.Quantity_Product_Configuration__c=20;
    newConfig.cscfga__Product_Definition__c=prodDef.id;
    newConfig.cscfga__Product_Basket__c=prodBas.id;
    prodConfigLst.add(newConfig);
    insert prodConfigLst;
       
       
       
  }
    
  @isTest
  static void chekBsktStageOnSubmit(){
    Test.startTest();
    User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];      
    System.runAs(asaUser){
    cscfga__Product_Basket__c prod=[select csordtelcoa__Basket_Stage__c,id from cscfga__Product_Basket__c Where referencenumber__c='TNC000000000'];
    Set<String> productBaketId = new Set<String>();
    productBaketId.add(prod.id);
    InflightSubmitBasketBatch inflightBasket = new InflightSubmitBasketBatch(productBaketId); 
    Id ids = database.executeBatch(inflightBasket);     
    }
    Test.stopTest();
    cscfga__Product_Basket__c prod1=[select csordtelcoa__Basket_Stage__c,id,sync_job_Id__c from cscfga__Product_Basket__c Where referencenumber__c='TNC000000000'];
    String str = prod1.csordtelcoa__Basket_Stage__c;
    System.assert(prod1.sync_job_Id__c.contains('submitJobId')); 
  }
  @isTest
  static void chekBsktStageFinalElse(){
    Test.startTest();
    User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];  
    cscfga__Product_Basket__c prod=[select csordtelcoa__Basket_Stage__c,id from cscfga__Product_Basket__c Where referencenumber__c='TNC000000000'];
    Set<String> productBaketId = new Set<String>();    
    System.runAs(asaUser){
    productBaketId.add(prod.id);
    InflightSubmitBasketBatch inflightBasket = new InflightSubmitBasketBatch(productBaketId);
    inflightBasket.basketFailureList=new List<cscfga__Product_Basket__c>{prod}; 
    Id ids = database.executeBatch(inflightBasket);     
    }
    Test.stopTest();
    cscfga__Product_Basket__c prod1=[select csordtelcoa__Basket_Stage__c,id,sync_job_Id__c from cscfga__Product_Basket__c Where referencenumber__c='TNC000000000'];
    System.assert(prod1.sync_job_Id__c.contains('submitJobId')); 
  }

}