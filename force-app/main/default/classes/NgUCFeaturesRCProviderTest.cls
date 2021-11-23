/********************************************************
Class Name      :   NgUCFeaturesRCProviderTest
Main Class : NgUCFeaturesRCProvider
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Venkata Ramanan G     29/10/2019      EDGE-112869 Created for fetching the RC for NgUC features
2.            Hitesh Gandhi         20/01/2020      EDGE-130739  Changed Billing description

********************************************************************/

@isTest
private class NgUCFeaturesRCProviderTest{
    @testSetup
static void dataSetup() {

cspmb__Price_Item__c commercialPrd = ProductTestFactory.buildPriceItem('New Plan',324,564.23,'User','Commercial');
        commercialPrd.Offer_Id__c = 'DMCAT_Offer_000618';
        commercialPrd.Plan__c ='Premium';
        commercialPrd.cspmb__Price_Item_Code__c ='Next Generation Voice';
        commercialPrd.cspmb__Effective_End_Date__c  = system.today()+30;
        commercialPrd.cspmb__Effective_Start_Date__c  = system.today();
        commercialPrd.ProdSpecId__c ='DMCAT_ProductSpecification_000871';
        //EDGE-130739   - CHange in Billing Description value
        commercialPrd.Billing_Description__c = 'Group feature - hunt group';
        commercialPrd.Unit_Of_Measure__c = 'per Hunt Group';
        commercialPrd.rangeFrom__c = '1' ;
        commercialPrd.rangeTo__c = '10';
        commercialPrd.cspmb__Recurring_Charge__c = 10;
        commercialPrd.cspmb__Effective_End_Date__c = system.today()+10;
        commercialPrd.cspmb__Effective_Start_Date__c = system.today();
        insert commercialPrd;
        }
        @isTest
static void getdata(){
        
        cspmb__Price_Item__c commercialProd= [Select id,Name, Offer_Id__c,Device_Type__c,cspmb__Price_Item_Code__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c from cspmb__Price_Item__c where Name='New Plan'];
        
            Map<String,String> searchFields = new Map<String,String>();
            searchFields.put('Offer_Id__c',commercialProd.Offer_Id__c);
            searchFields.put('Attribute_Name','HuntGroupQuantity');
            searchFields.put('quantity','2');
            NgUCFeaturesRCProvider helper = new NgUCFeaturesRCProvider();
            Test.startTest();
            Map<String,Object> lookupResult = NgUCFeaturesRCProvider.getData(searchFields);
            System.assertEquals(true,lookupResult!=null);
           // System.assertEquals(1,lookupResult.size());
            Test.stopTest();
}
        }