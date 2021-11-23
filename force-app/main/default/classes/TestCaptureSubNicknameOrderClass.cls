/********************************************************************************************************************************
Main Class : CaptureSubNicknameOrderClass
Test Class : TestCaptureSubNicknameOrderClass
=================================================================================================================================
Sr.No.    Developer Name      Date            Story          Sprint               Description
1.        Aman Soni           25/03/2021      EDGE-199911    21.04(New Class)     To cover CaptureSubNicknameOrderClass functionality  
********************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class TestCaptureSubNicknameOrderClass{

  @TestSetup 
  static void setup(){
    
  Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
    lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = pf.id,timezonesidkey='Australia/Sydney',
    username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
  
  List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();         
    basket.name = 'Test Basket';
    basketLst.add(basket);
    insert basketLst;
  
  
  List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>();
  cscfga__Product_Definition__c prodDefMS = new cscfga__Product_Definition__c();
  prodDefMS.product_Specification__c ='DMCAT_ProductSpecification_000420';
  prodDefMS.cscfga__Description__c ='Mobile Subscription';
  prodDefList.add(prodDefMS);
  insert prodDefList;
  
  List<cscfga__Product_Configuration__c> configLst = new List<cscfga__Product_Configuration__c>();
  cscfga__Product_Configuration__c configMS = new cscfga__Product_Configuration__c();         
    configMS.name = 'Test Config';
    configMS.cscfga__Product_Basket__c = basket.Id;
    configMS.cscfga__Product_Definition__c = prodDefMS.Id;
    configLst.add(configMS);
  insert configLst;
  
  List<csord__Order__c> orderList = new List<csord__Order__c>();
    csord__Order__c order = new csord__Order__c();  
    order.Name = 'Test Order';
    order.csord__Identification__c = 'Order_0';
    order.Product_Basket__c = basket.Id;
    orderList.add(order);
    insert orderList;
  
  List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
  csord__Subscription__c subMS = new csord__Subscription__c();
    subMS.name = 'Mobile-Subscription';
    subMS.csord__Identification__c = 'Subscription_0';
    subMS.serviceMSISDN__c = '123456789123';
    subMS.Nickname__c = '';
    subMS.csord__Order__c = order.id;
    subMS.csordtelcoa__Product_Configuration__c = configMS.id;
    subList.add(subMS);
    insert subList;  
  }

  //Positive Scenario 
    @isTest static void getSubscriptionsRecordsPosTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
        System.runAs(sales){
      List<SubscriptionWrapperData> subsFinalList = new List<SubscriptionWrapperData>();
      csord__Subscription__c sub = [select id,name,serviceMSISDN__c,Nickname__c from csord__Subscription__c where name = 'Mobile-Subscription'];
            csord__Order__c order = [select id,name from csord__Order__c limit 1];  
            String orderId = order.Id;
            subsFinalList = CaptureSubNicknameOrderClass.getSubscriptionsRecords(orderId);
      if(!subsFinalList.isEmpty()){
        for(SubscriptionWrapperData servWrapper : subsFinalList){
          System.assertEquals(sub.serviceMSISDN__c, subsFinalList[0].serviceID, 'Mobile Number matched successfully');
        }      
      }    
        }
        Test.stopTest();
    }
  
    //Negative Scenario
    @isTest static void getSubscriptionsRecordsNegTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];        
        System.runAs(sales){
      List<SubscriptionWrapperData> subsFinalList = new List<SubscriptionWrapperData>();
            String orderId = '';
            subsFinalList = CaptureSubNicknameOrderClass.getSubscriptionsRecords(orderId);
            System.assertEquals(subsFinalList.size(), 0,'Blank List');           
        }
        Test.stopTest();
    }
	
	//Positive Scenario 
    @isTest static void toBeUpdatedSubNicknamesPosTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
        System.runAs(sales){
			List<csord__Subscription__c> subsFinalList = new List<csord__Subscription__c>(); 
            String subscriptions = '[{"billingAccNumber":"700000661954","Id":"a4g2N0000002vScQAI","nickname":"Satish","serviceID":"34567890320","subscriptionName":"Handheld-Enhanced_3","subscriptionNumber":"SN-000221204"}]';
            subsFinalList = CaptureSubNicknameOrderClass.toBeUpdatedSubNicknames(subscriptions);
			System.assertEquals(0,subsFinalList.size(), 'Size is 0');   
        }
        Test.stopTest();
    }
}