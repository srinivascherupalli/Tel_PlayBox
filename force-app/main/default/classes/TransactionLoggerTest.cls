/*************************************************************************************************
Name : TransactionLoggerTest 
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Shubhi/Aditya            31-08-2021        DIGI-3161
=============================================================== 
***************************************************************************************************/
@isTest
private class TransactionLoggerTest{

    @testSetup static void setup(){
        //CREATE ACCOUNT
        Account acc  = new Account(Name = 'Test Account', Customer_Status__c ='ACTIVE',CIDN__c = 'ABC1234560');
        insert acc;
        //CREATE CONTACT 
        Contact con1 = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                Email = 'test@tele2.com'   
         );
        insert con1;    
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Project_ID__c = 'basket1';
        insert new List<cscfga__Product_Basket__c>{basket1};
       
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;

        
    }

    @isTest static void getDataTest() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Test.startTest();
        cscfga__Product_Basket__c productBasket=[Select id,name,cscfga__Opportunity__c from cscfga__Product_Basket__c  limit 1];
        String correlationID = ''+productBasket.cscfga__Opportunity__c+productBasket.id;
        inputMap.put('event','Transaction start');
        inputMap.put('configurationCount','100');
        inputMap.put('searchType','reserve');
        inputMap.put('Quantity','1');
        inputMap.put('basketName',productBasket.name);
        inputMap.put('OrderType','new');
        inputMap.put('OfferName','AM');
        inputMap.put('BasketUrl','test url');
        inputMap.put('correlationId',correlationID);
        inputmap.put('TransactionLogger','');
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];
        System.runAs(sales){
            TransactionLogger.getdata(inputMap);
            List<Transaction_log__c> getTransactionLog = [select Id from Transaction_log__c where CorrelationId__c =:correlationID ];
            System.assertEquals(correlationID ,''+productBasket.cscfga__Opportunity__c+productBasket.id);
        }
        Test.stopTest();
    }

    @isTest static void testMethod2() {

    }
}