/***********************************************************************************************
Name          : MobileSubscriptionGetDiscountDataTest
Created By    : Laxmi Rahate
Created Date  : July 25, 2019
Description   : This is a test class to simulate and test the logic of MobileSubscriptionGetDiscountData
**********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class MobileSubscriptionGetDiscountDataTest {
    
    
    @testSetup static void setup() {
        
        cspmb__Price_Item__c priceItem1 =  new cspmb__Price_Item__c(Name='Mobile Device', cspmb__Is_Active__c = true); // Governing 
        cspmb__Price_Item__c priceItem2 =  new cspmb__Price_Item__c(Name='Mobility', cspmb__Is_Active__c = true); // Goverened = plan
      
        insert priceItem1 ;
        insert priceItem2;
       
    }

    static testmethod void getDataTest() {
       
        Map<String,Object> inputMap = new Map<String,Object>();
        //TestDataFactory.generatePriceItem();
        //cspmb__Price_Item__c priceItem1 =  new cspmb__Price_Item__c(Name='Mobile Device', cspmb__Is_Active__c = true); // Governing 
       // cspmb__Price_Item__c priceItem2 =  new cspmb__Price_Item__c(Name='Mobility', cspmb__Is_Active__c = true); // Goverened = plan
      
        //insert priceItem1 ;
        //insert priceItem2;
        String planRecordId;
        String deviceRecordid;
        for (cspmb__Price_Item__c priceItem : [select id, name from cspmb__Price_Item__c limit 2] )
        {
            if (priceItem.name == 'Mobile Device')
            {
                deviceRecordid = priceItem.id;
            }
               if (priceItem.name == 'Mobility')
            {
                planRecordId = priceItem.id;
            }

        }
        inputMap.put ('planRecord', planRecordId);
        inputMap.put ('deviceRecord', deviceRecordid );
        Map<String,Object> result = new Map<String,Object>();
        
        Product_To_Product_Association__c productAllowance = new Product_To_Product_Association__c ( Governed_Attribute_Name__c = 'PlanDiscount', Effective_Start_Date__c    = Date.today(), Effective_End_Date__c = Date.today()+10, Recurring_Charge__c = 21,Governed_Attribute_Value_Type__c='C',Contract_Term__c='24',Governed_Product__c = planRecordId, Governing_Product__c = deviceRecordid);
        INSERT productAllowance;
        Test.startTest();
        result = MobileSubscriptionGetDiscountData.getData(inputMap);
        Test.stopTest();
        System.assertNotEquals(NULL, result);

    }
}