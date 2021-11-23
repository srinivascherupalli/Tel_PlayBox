/* ****************************************************************************
Class Name      : SolutionHelperCancelledCLITest
* Author        : Ankit Goswami : EDGE-134880
* Date          : 18-03-2020
* Description   : Remote Action Class for checking if  is OneFund or not
* *****************************************************************************/

 

@isTest(SeeAllData=FALSE)
public class SolutionHelperCancelledCLITest {
 @TestSetup static void CreateData()
{
        Account accDeal = AccountTestFactory.buildAccount ('accDeal');
        insert accDeal;
       
        Opportunity  opp = ProductTestFactory.getOpportunityBasic (accDeal);
        opp.CloseDate = Date.today();
        opp.Product_Type__c = 'Modular';
        opp.Pricing_Method__c = 'Delegated Pricing';
        opp.StageName ='Define';
        insert Opp;
        
        list<Charge_Line_Item__c> CLattrList= new list<Charge_Line_Item__c>();
        Charge_Line_Item__c CLattr= new Charge_Line_Item__c();
        CLattr.guid__c='c20a039b-80fe-8876-5328-4006a5143cce';
        CLattr.CorrelationId__c='123455666666';
        CLattr.BusinessID__c='DMAT_Discount_000450';
        CLattr.contractTerm__c=20.0;
        CLattr.status__c='Active';
        CLattr.Product_Charge_Identifier__c ='Price Item';
        CLattr.componentName__c='Test';
        CLattr.totalContractValue__c=20.0;
        CLattrList.add(CLattr);
        
        Charge_Line_Item__c CLattr1= new Charge_Line_Item__c();
        CLattr1.guid__c='c20a039b-80fe-8876-5328-4006a5143cce';
        CLattr1.CorrelationId__c='123455666666';
        CLattr1.BusinessID__c='DMAT_Discount_000450';
        CLattr1.contractTerm__c=20.0;
        CLattr1.basketId__c='1234566';
        CLattr1.solutionId__c='542272547474';
        CLattr1.componentName__c='Test';
        CLattr1.totalContractValue__c=20.0;
        CLattrList.add(CLattr1);
        insert CLattrList;
        
        
}
  /******************************************************************************************************
    * Method Name : getPaymentFundPositiveTest
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    @isTest static void getUpdateTCVTest(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> returnMap = new Map<String, Object>();
        Account accDeal =[Select name,id from Account where name = 'accDeal'];
        list<Charge_Line_Item__c> CList =[Select name,id,guid__c,CorrelationId__c,BusinessID__c,contractTerm__c,basketId__c,solutionId__c,componentName__c,totalContractValue__c from Charge_Line_Item__c where guid__c = 'c20a039b-80fe-8876-5328-4006a5143cce'];
        //Account accDeal = AccountTestFactory.buildAccount ('accDeal');
     
        inputMap.put ('guid','c20a039b-80fe-8876-5328-4006a5143cce');
        inputMap.put ('basketId', '1234566' );
        inputMap.put ('solutionID', '542272547474' );
       
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseB2B]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        System.runAs(sales)
        {   
        Test.startTest();
        SolutionHelperCancelledCLI solnHelper = new SolutionHelperCancelledCLI();
        returnMap = solnHelper.getData(inputMap);
        system.debug('returnMap :::'+returnMap.get('avgDiscountedPricePlan') );
        Test.stopTest();
        System.assertEquals(20.00,returnMap.get('avgDiscountedPricePlan'));
        }
    }
    
    
    @isTest static void getPaymentFundNegativeTest(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> returnMap = new Map<String, Object>();
        inputMap.put ('guid','c20a039b-80fe-8876-5328-4006a5143cce');
        inputMap.put ('basketId', '1238994566' );
        inputMap.put ('solutionID', '542272547474' );
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        System.runAs(sales) {   
        Test.startTest();
        SolutionHelperCancelledCLI solnHelper = new SolutionHelperCancelledCLI();
        returnMap = solnHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals(false, returnMap.containsKey('avgDiscountedPricePlan'));
        }
    }
}