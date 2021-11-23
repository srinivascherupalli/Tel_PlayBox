/*-------------------------------------------------------------------------------
EDGE        -150285
Class       -CustomButtonGenerateCAformTest
Description -Test Class for CustomButtonGenerateCAform class
Author      -Aishwarya yeware
---------------------------------------------------------------------------------*/
@isTest
public class CustomButtonGenerateCAformTest {
    @TestSetup public static void testDataSetup(){
        account acc=TestDataFactory.generateAccount();
        acc.name='PortOutReversal Account';
        acc.Customer_Status__c='ACTIVE';
        update acc;
        
        Opportunity opp=new Opportunity(Name='Port Out Reversal Opportunity');
        opp.AccountId=acc.id;
        opp.StageName='Propose';
        opp.CloseDate=system.today();
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Mobile Subscription';
        productDefinition.cscfga__Description__c = 'Mobile Subscription';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert productDefinition;
        
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        productConfig.Remaining_Term__c  = 24;
        productConfig.cscfga__Product_Basket__c=basket.id;
        pcList.add(productConfig);
        insert pcList;
        
        Number__c num= new Number__c(Service_Number__c='61459812342',Type__c='Port Out Reversal', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        insert num;  
    }
    /*-------------------------------------------------------------------------------
EDGE        -150285
Method      -testPerformActionTest
Description -Test method for testPerformAction method in CustomButtonGenerateCAform class 
Author      -Aishwarya Yeware
---------------------------------------------------------------------------------*/
    @isTest
    static void testPerformActionTest()
    {
        String result;
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        CustomButtonGenerateCAform testClass = new CustomButtonGenerateCAform();
        Test.startTest();
        result = testClass.performAction(testProductConfiguration.cscfga__Product_Basket__c);
        Test.stopTest();
        System.assertEquals(result!=null,true, 'Result was not the expected return string');    
    }
    /*-------------------------------------------------------------------------------
EDGE        -150285
Method      -checkPortInPortOutBasketTest
Description -Test method for checkPortInPortOutBasket method in CustomButtonGenerateCAform class 
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------*/
    @IsTest public static void checkPortInPortOutBasketTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name='PortOutReversal Account' LIMIT 1];
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.regenerateCA')); 
        System.currentPageReference().getParameters().put('basketId', basket.Id);
        CustomButtonGenerateCAform.checkPortInPortOutBasket();
        system.assert(CustomButtonGenerateCAform.isPortOut);
        Test.stopTest();
        
    }
    
}