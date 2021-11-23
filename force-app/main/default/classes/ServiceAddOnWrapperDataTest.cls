/******************************************************************************************************************************
Class Name : ServiceAddOnWrapperDataTest
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           10/02/2021    EDGE-191077(New Class)           21.02
*******************************************************************************************************************************/

@IsTest(SeeAllData=FALSE)
private class ServiceAddOnWrapperDataTest {

  @IsTest 
  static void testServiceAddOnWrapperData(){   
    Service_Add_On__c servAddOn = new Service_Add_On__c();
    servAddOn.Device_Id__c = '1234568';
    servAddOn.Name = 'Test Service Add On';
    servAddOn.Status__c = 'Ready for Sync';
    servAddOn.Instance_Id__c = '43227651';
    servAddOn.Contract_Type__c = 'MRO';
    servAddOn.Product_Basket__c = null;
    servAddOn.Solution_Id__c = '';
    servAddOn.Monthly_Amount__c = 5;
    servAddOn.Legacy_Billing_Account_Number__c = '3456789';
    servAddOn.Residual_Remaining_Amount__c =2;
    servAddOn.Residual_Remaining_Term__c=3;
    servAddOn.Transaction_Type__c = 'Migration';
    //START: Added for EDGE-215103
    servAddOn.Product_End_Date__c = Date.today();
    //END for EDGE-215103
    insert servAddOn;
    
    ServiceAddOnWrapperData servAddWrapObj = new ServiceAddOnWrapperData();
    servAddWrapObj.legacyBillingAccount = servAddOn.Legacy_Billing_Account_Number__c;
    servAddWrapObj.deviceType = 'IMEI';
    servAddWrapObj.deviceIDType = 'IMEI Type';
    servAddWrapObj.deviceID = servAddOn.Device_Id__c;
    servAddWrapObj.deviceManufacturer = 'TestMan';
    servAddWrapObj.deviceModel = 'TestMod';
    servAddWrapObj.deviceDescription = 'TestDes';
    servAddWrapObj.paymentType = servAddOn.Contract_Type__c;
    servAddWrapObj.remainingBalance = servAddOn.Residual_Remaining_Amount__c;
    servAddWrapObj.remainingTerm = servAddOn.Residual_Remaining_Term__c;
    servAddWrapObj.recChargeIncGst =servAddOn.Monthly_Amount__c;
    servAddWrapObj.Id = servAddOn.id;
    servAddWrapObj.deviceInstanceId = servAddOn.Instance_Id__c;                
    servAddWrapObj.status = servAddOn.Status__c;
    servAddWrapObj.isgreyedout = true;
    //START: Added for EDGE-215103
    servAddWrapObj.ProductEndDate = servAddOn.Product_End_Date__c;
    servAddWrapObj.TermStatus = 'Active';
    //END for EDGE-215103
    system.assertEquals(servAddWrapObj.legacyBillingAccount, servAddOn.Legacy_Billing_Account_Number__c);
  }
}