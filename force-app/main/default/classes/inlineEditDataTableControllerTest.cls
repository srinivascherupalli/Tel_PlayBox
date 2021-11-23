/*************************************************************************************************
Name 		: inlineEditDataTableController
Description : This test is covered inlineEditDataTableController
Author		: Abinash Barik
Story		: 
Revision	: 
***************************************************************************************************/
@isTest
public class inlineEditDataTableControllerTest {
    //@testSetup method created by Abhishek(Osaka) as a part of EDGE-207158
    @testSetup static void testSetupMethod(){
        //Start of EDGE-207158 by Abhishek(Osaka)
        csord__Subscription__c subRec = new csord__Subscription__c();
        subRec.csord__Identification__c='abcdeee';
        subRec.Nickname__c = '';
        subRec.serviceMSISDN__c='61474714986';
        insert subRec;
        
        csord__Subscription__c subRecNew = new csord__Subscription__c();
        subRecNew.csord__Identification__c='123456';
        subRecNew.Nickname__c = '';
        subRecNew.serviceMSISDN__c='61474714988';
        insert subRecNew;
        //End of EDGE-207158 by Abhishek(Osaka)
        
    }
    
    @isTest
    public static void initiateDataTableTest(){
        inlineEditDataTableController.dataTableWrapper objdataTable = new inlineEditDataTableController.dataTableWrapper();
        objdataTable = inlineEditDataTableController.initiateDataTable('PC_Adaptive_Mobility_Transition');
        Test.startTest();
        objdataTable = inlineEditDataTableController.initiateDataTable('PC_Adaptive_Mobility_Transition');
        System.assertEquals(objdataTable.fielddetails.size() > 0,true);
        System.assertEquals(objdataTable.columndetail.size() > 0,true);
        System.assertEquals(objdataTable.dataTableConfig != null,true);
        Test.stopTest();
    }
    @isTest
    public static void initiateDataTableNegativeTest(){
        inlineEditDataTableController.dataTableWrapper objdataTable = new inlineEditDataTableController.dataTableWrapper();
        objdataTable  = inlineEditDataTableController.initiateDataTable(null);
        Test.startTest();
        System.assertEquals(objdataTable.error !=null,true);
        Test.stopTest();
    }
    @isTest
    public static void initiateDataTableNegativeTest2(){
        inlineEditDataTableController.dataTableWrapper objdataTable = new inlineEditDataTableController.dataTableWrapper();
        objdataTable  = inlineEditDataTableController.initiateDataTable('PCAdaptiveMobility');
        system.debug('objdataTable>>>'+objdataTable);
        Test.startTest();
        System.assertEquals(objdataTable!=null,true);
        Test.stopTest();
    }
    //Start of EDGE-207158 By Abhishek(Osaka)
    @isTest
    public static void updateNickNameTest(){
        List<String> subList = new List<String>();
        
        List <csord__Subscription__c> subRecTest = new List <csord__Subscription__c>();
        subRecTest  = [Select id,csordtelcoa__Subscription_Number__c,Nickname__c from csord__Subscription__c LIMIT 2 ];
        
        for(csord__Subscription__c sub : subRecTest){
            subList.add(sub.csordtelcoa__Subscription_Number__c);
        }
        
        System.debug('Sub Rec::'+subRecTest);
        System.debug('Sub List::'+subList);
        String metaDataRecName = 'SubscriptionNicknameOrder';
        String csvData = 'Subscription Name,Subscription Number,Service ID,Billing Account,Nickname\r\nHandheld-Epic_1,'+ subList[0]+',61474714986,700000730296,\r\nHandheld-Epic_1,'+ subList[1]+',61474714986,700000730297,\r\n';
        String base64Data = JSON.serialize(csvData);
        String result = '';
        result = inlineEditDataTableController.uploadFile(base64Data,metaDataRecName);
        test.startTest();
        System.assertEquals(result,Label.UploadFileSuccessMessage);
        test.stopTest();
        
    }
    
    @isTest
    public static void updateNickNameTestNegative(){
        
        String metaDataRecName = 'SubscriptionNicknameOrder';
        String csvData = 'Subscription Name,Subscription Number,Service ID,Billing Account\r\nHandheld-Epic_1,SN-000235372,61474714986,700000730296\r\nHandheld-Epic_1,SN-000235373,61474714986,700000730297\r\n';
        String base64Data = JSON.serialize(csvData);
        String result = '';
        result = inlineEditDataTableController.uploadFile(base64Data,metaDataRecName);
        test.startTest();
        System.assertEquals(result,Label.UploadFileFailedMessage);
        test.stopTest();
        
    }
    //End of EDGE-207158 By Abhishek(Osaka)
    
}