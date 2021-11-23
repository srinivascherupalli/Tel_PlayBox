/*************************************************************************************************
Name 		: DynamicDataTableController
Description :Controller class for Dynamic Data Table 
Author		:Abinash Barik
Story		: EDGE-140792
***************************************************************************************************/
@isTest
public class DynamicDataTableControllerTest {
	@testSetup 
    public static void setupdata(){
        Data_Table_Configuration__c dtConfig = new Data_Table_Configuration__c();
        dtConfig.Header__c='Test';
        dtConfig.Name='Testtable';
        dtConfig.IsShowCSV__c= false;
        dtConfig.key_Value__c='Id';
        dtConfig.Show_Header__c=true;
        dtConfig.Page_Size__c=5;
        
        insert dtConfig;
        NumberReservationHelperTest.setupdataForMobile();
    }
    @isTest
    public static void getProdConfigFixedTest(){
        Test.startTest();
        Data_Table_Configuration__c objdata = DynamicDataTableController.getdataTable('Testtable');
        System.assertEquals(objdata.Name,'Testtable','Fixed details fetched');
        Test.stopTest();
    }
    
   @isTest
    public static void checkResetError(){
        List<Number__c> numbList = [SELECT service_number__c FROM Number__c WHERE service_number__c = '61459834542'];
        Test.startTest();
        Boolean result = DynamicDataTableController.resetErrorCheckBoxOnNumbers(numbList);
        system.assertEquals(result, true, 'Reset done');
        test.stopTest();
    }
        
  
}