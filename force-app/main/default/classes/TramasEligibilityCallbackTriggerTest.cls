/*
* @Author : Robin Chawla
* @Date : 20 May 2019
* @Desc : Test class for Trigger classes TramasElgibilityCallbackResponseTrigger, TramasElgibilityCallbackTriggerHandler, TramasEligibilityCallBackTriggerAction
* @Jira : EDGE-84282 Notify Sales user when TM1 check has completed.
*/
@isTest
public with sharing class TramasEligibilityCallbackTriggerTest {
    
    public static List<TramasElgibilityCallbackResponse__c> callBackRes;
    
     

    Public static Integer getNewsFeedCount() {

        ConnectApi.FeedElementPage elements =ConnectApi.ChatterFeeds.getFeedElementsFromFeed(null,ConnectApi.FeedType.News, 'me');

        return elements.elements.size();

    }


    
    
    public static void  creatTestData(){
        
        Account acc = new Account(Name = 'Test Account for TramasElgibilityCallbackResponseTrigger');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        
       	Opportunity opp  = new Opportunity();
        opp.Name = 'TestOpp';
        opp.AccountID = acc.id;
       	opp.StageName = 'Committed';
        opp.CloseDate = System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.OwnerId=userinfo.getuserid();
      	insert opp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        //START: Added by Sajal for DIGI-24043
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);
        insert pdList;

        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = basket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        insert prodconfigList;
        //END for DIGI-24043

      	callBackRes=new List<TramasElgibilityCallbackResponse__c>();
        
        TramasElgibilityCallbackResponse__c res1=new TramasElgibilityCallbackResponse__c();
        res1.Name='TestTrigger1';
        res1.Correlation_ID__c='12903eew34';
        res1.Product_Basket__c=basket.Id;
        res1.Eligibility_Criteria__c='Not Accessed';
        callBackRes.add(res1);
       
        TramasElgibilityCallbackResponse__c res2=new TramasElgibilityCallbackResponse__c();
        res2.Name='TestTrigger2';
        res2.Correlation_ID__c='22903eew34';
		res2.Product_Basket__c=basket.Id;
        res2.Eligibility_Criteria__c='Not Accessed';
        callBackRes.add(res2);
        
        insert callBackRes;
        
    }
   @IsTest()
    Public static void sendNoficationSuccess(){
        
        creatTestData();
        
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;

        
        // Set the test data
 	  	ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null,ConnectApi.FeedType.News, 'me', testPage);

    
        for(TramasElgibilityCallbackResponse__c res:callBackRes){
            
			res.Eligibility_Criteria__c='Eligible';            
        }
        Test.startTest();
        update callBackRes;
      
		System.assertEquals(2, getNewsFeedCount());

        Test.stopTest();
       
        
    }
    @IsTest()
   Public  static void  sendNoticationFailure(){
        creatTestData();
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testPage.elements = testItemList;
       ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null,ConnectApi.FeedType.News, 'me', testPage);
       if(!callBackRes.isEmpty()){
     	TramasElgibilityCallbackResponse__c res= callBackRes[0];
       	res.Eligibility_Criteria__c='Eligible';
        Test.startTest();
        update res;
       
        System.assertEquals(0, getNewsFeedCount());   
        Test.stopTest();
       
       
       }
    } 
    
    //START: Added by Sajal for DIGI-24043
    @isTest
    static void testAfterInsertStatusUpdate(){
        creatTestData();

        cscfga__Product_Basket__c basket = [SELECT Id FROM cscfga__Product_Basket__c][0];
        cscfga__Product_Configuration__c testConfig = [SELECT Id FROM cscfga__Product_Configuration__c][0];
        List<TramasElgibilityCallbackResponse__c> callBackRes=new List<TramasElgibilityCallbackResponse__c>();
        Test.startTest();

        TramasElgibilityCallbackResponse__c res1=new TramasElgibilityCallbackResponse__c();
        res1.Name='TestTrigger1';
        res1.Correlation_ID__c='12903eew90';
        res1.Product_Basket__c=basket.Id;
        res1.Eligibility_Criteria__c='Not Accessed';
        res1.Product_Configuration__c = testConfig.Id;
        callBackRes.add(res1);
       
        TramasElgibilityCallbackResponse__c res2=new TramasElgibilityCallbackResponse__c();
        res2.Name='TestTrigger2';
        res2.Correlation_ID__c='22903eew87';
		res2.Product_Basket__c=basket.Id;
        res2.Eligibility_Criteria__c='Not Accessed';
        res1.Product_Configuration__c = testConfig.Id;
        callBackRes.add(res2);
        
        insert callBackRes;

        Test.stopTest();

        System.assertEquals(true,callBackRes.size()>0 );
    }
    //END for DIGI-24043
    
}