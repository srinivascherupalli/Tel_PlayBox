/*
===============================================================================================================================
Test Class : CS_DeviceModelFromPriceItemManagedDTest
Developer Name : Pankaj Sharma
Date : 02/02/2018
Class : CS_DeviceModelFromPriceItemManagedDevice
===============================================================================================================================
Sr.No.		Developer Name			Date			Story Description
1.			Pankaj Sharma			02/02/2018		
===============================================================================================================================
*/

@isTest 
public class CS_DeviceModelFromPriceItemManagedDTest {
    @testsetup static void CS_DeviceModelFromPriceItemManagedDTestDataSetup()
    {
        Profile pf = [select Id,Name from profile where name ='Sales Manager - Enterprise'];
        //CREATE USER
        User usr = new User(Alias = 'standt', Email='standarduser@telestra.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = pf.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@telestra.com');
        
        insert usr;
        System.runAs(usr){
            cspmb__Price_Item__c piSeat = new cspmb__Price_Item__c();
            Date today = Date.valueOf(System.now());
            piSeat.Name = 'Price Item';
            piSeat.Model__c = '1117';
            piSeat.Contract_Type__c = 'Test Contract';
            piSeat.Package_Name__c = 'Connected Workplace';
            piSeat.Type__c ='Router';
            piseat.cspmb__Recurring_Charge__c = 300;
            piseat.cspmb__One_Off_Charge__c = 300;
            piseat.Vendor__c = 'Cisco';
            piSeat.cspmb__Effective_Start_Date__c = today+1;
            piSeat.cspmb__Effective_End_Date__c =today;
            piSeat.External_Id__c = '2359abc9-8088-4e56-a5c0-19de77555527';
            piSeat.cspmb__Product_Definition_Name__c ='Managed Router';
            insert piSeat;
        }
    }
    static testmethod void testDoLookupSearchForSalesManagerEnterprise()
    {   
        User usr = [select Id,UserName from User where UserName = 'standarduser@telestra.com'];
        System.runAs(usr)
        {
            Test.startTest();
            CS_DeviceModelFromPriceItemManagedDevice manDivModel = new CS_DeviceModelFromPriceItemManagedDevice();
            Map<String,String> searchFields = new Map<String,String>();
        	String sDeviceTypeValue = manDivModel.getRequiredAttributes();
            searchFields.put('DeviceTypeValue','Router');
            searchFields.put('VendorValue','Cisco');
            system.assertEquals('["DeviceTypeValue","VendorValue"]', sDeviceTypeValue);
            List<cspmb__Price_Item__c> lstPrItem = (List<cspmb__Price_Item__c>)manDivModel.doLookupSearch(searchFields, null, null, null, null);
            system.assertEquals('1117', lstPrItem[0].model__c);
            Test.stopTest();
        }
    }
    
}