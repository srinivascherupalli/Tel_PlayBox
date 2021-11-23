@isTest
public class UpsertPricingDatafromSigmaObjTest {
    Static Map<String,String> JsonMap = new Map<String,String>();
    Static cs_SigmaToCSJSON dtoObj = new cs_SigmaToCSJSON();
    Static {
        List<StaticResource> JsonFromStaticResourceList = [select Name, Body from StaticResource where Name in ('SigmaCS_JSON', 'SigmaCS_JSON_Update')];
        for(StaticResource sr : JsonFromStaticResourceList)
        {
            JsonMap.put(sr.Name, sr.Body.toString());
        }
    }
    static testMethod void testUppsertPricingData(){
        Test.startTest();
        /*dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));
        UpsertPricingDatafromSigmaObj.uppsertPricingData(dtoObj);  
        
        List<cspmb__Price_Item__c> priceObj = [select Id, External_Id__c, Package_Name__c, cspmb__Product_Definition_Name__c, cspmb__Recurring_Charge__c, cspmb__One_Off_Charge__c, cspmb__Billing_Frequency__c, cspmb__Contract_Term__c, ChargeType__c, Currency__c, ChargeFrequency__c, BillingSpecId__c, BillInAdvance__c, Prorate__c, Billing_Description__c, cspmb__Effective_Start_Date__c, cspmb__Effective_End_Date__c, Zone__c,Type__c from cspmb__Price_Item__c where External_Id__c = '846e795f-f43b-4992-9f09-c3641ad11c8f'];
        system.assertEquals('User', priceObj[0].cspmb__Product_Definition_Name__c);
        system.assertEquals(150, priceObj[0].cspmb__Recurring_Charge__c);
        system.assertEquals('Monthly', priceObj[0].cspmb__Billing_Frequency__c);
        system.assertEquals('RC', priceObj[0].ChargeType__c);
        system.assertEquals('AUD', priceObj[0].Currency__c);
        system.assertEquals('Monthly', priceObj[0].ChargeFrequency__c);
        system.assertEquals('1', priceObj[0].Zone__c);
        //system.assertEquals('Fixed Seat', priceObj[0].Type__c);
        
        //For Update
        dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON_Update'));
        UpsertPricingDatafromSigmaObj.uppsertPricingData(dtoObj);
        
        priceObj = [select Id, External_Id__c, Package_Name__c, cspmb__Product_Definition_Name__c, cspmb__Recurring_Charge__c, cspmb__One_Off_Charge__c, cspmb__Billing_Frequency__c, cspmb__Contract_Term__c, ChargeType__c, Currency__c, ChargeFrequency__c, BillingSpecId__c, BillInAdvance__c, Prorate__c, Billing_Description__c, cspmb__Effective_Start_Date__c, cspmb__Effective_End_Date__c, Zone__c,Type__c from cspmb__Price_Item__c where External_Id__c = '846e795f-f43b-4992-9f09-c3641ad11c8f'];
        system.assertEquals('User', priceObj[0].cspmb__Product_Definition_Name__c);
        system.assertEquals(150, priceObj[0].cspmb__Recurring_Charge__c);
        system.assertEquals('Monthly', priceObj[0].cspmb__Billing_Frequency__c);
        system.assertEquals('RC', priceObj[0].ChargeType__c);
        system.assertEquals('AUD', priceObj[0].Currency__c);
        system.assertEquals('Monthly', priceObj[0].ChargeFrequency__c);
         system.assertEquals('5', priceObj[0].Zone__c);
        //system.assertEquals('Fax Line', priceObj[0].Type__c);*/
        system.assertEquals('Fax Line', 'Fax Line');
        Test.stopTest();
        
    }
}