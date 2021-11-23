/* ****************************************************************************
Class Name      : SolutionHelperPaymentTypeOneFundTest
* Author        : Laxmi Rahate : EDGE-127421
* Date          : 05 Feb 2020
* Description   : Remote Action Class for checking if PaymentType is OneFund or not
* *****************************************************************************/
@isTest(SeeAllData=FALSE)
public class SolutionHelperPaymentOneFundTest {
 @TestSetup static void CreateData()
{
        //Laxmi Added State as Active for Account 
        Account accDeal = AccountTestFactory.buildAccount ('accDeal');
        insert accDeal;
        System.debug ('Account -----' + accDeal.id);
        Opportunity  opp = ProductTestFactory.getOpportunityBasic (accDeal);
        opp.CloseDate = Date.today();
        opp.Product_Type__c = 'Modular';
        opp.Pricing_Method__c = 'Delegated Pricing';
        opp.StageName ='Define';
    	insert Opp;
        system.debug('Opp--------'+Opp);
        Delegated_Pricing_Request__c  DPRS = new Delegated_Pricing_Request__c(Opportunity__c = Opp.id );
        insert DPRS;       
        system.debug('DPRS::::'+DPRS);
        Marketable_Offer__c MarkOffer= new Marketable_Offer__c(Name='TestMO',Offer_ID__c='DMCAT_Offer_000646'); 
        insert MarkOffer;      
        system.debug('MarkOffer::::'+MarkOffer);
        DPR_Offer__c DPROffer =new DPR_Offer__c(Name='TestDPR',Delegated_Pricing_Request__c=DPRS.Id,Marketable_Offer__c=MarkOffer.Id,Hardware_Option__c = 'One Fund');
        insert DPROffer;   
       Opp.Pricing_Method__c = 'Delegated Pricing';
       opp.StageName ='Closed Won';
       update Opp;
}
  /******************************************************************************************************
    * Method Name : getPaymentFundPositiveTest
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    @isTest static void getPaymentFundPositiveTest(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> returnMap = new Map<String, Object>();
        Account accDeal =[Select name,id from Account where name = 'accDeal'];
        //Account accDeal = AccountTestFactory.buildAccount ('accDeal');
        inputMap.put ('accountId',accDeal.id);
 		inputMap.put ('offerID', 'DMCAT_Offer_000646' );
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseB2B]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        System.runAs(sales)
        {   
        Test.startTest();
        SolutionHelperPaymentTypeOneFund solnHelper = new SolutionHelperPaymentTypeOneFund();
        returnMap = solnHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals(true, returnMap.get('isPaymentTypeOneFund'));
        }
    }
       @isTest static void getPaymentFundNegativeTest(){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> returnMap = new Map<String, Object>();
		inputMap.put ('accountId','xyz' );
 		inputMap.put ('offerID', '132342' );
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        System.runAs(sales) {   
        Test.startTest();
        SolutionHelperPaymentTypeOneFund solnHelper = new SolutionHelperPaymentTypeOneFund();
        returnMap = solnHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals(false, returnMap.get('isPaymentTypeOneFund'));
        }
    }
}