/*************************************************************************************************
EDGE : EDGE-143860
Name:AdvancedStockCheckControllerTest
Description: Test class for AdvacedStockCheck 
Author:Pradeep Bhumi
Modified: Shresth Dixit(DPG-3510 : Added extra parameter filter in method calling for fetchLookUpStockCheck)
***************************************************************************************************/

@isTest
public class AdvancedStockCheckControllerTest
{
    
    public static void setupdata(){
        
        cspmb__Price_Item__c commerpro=TestUtil.createPriceItem();
        commerpro.Colour__c='Black';
        commerpro.ProdSpecId__c='DMCAT_ProductSpecification_000423';
        commerpro.Type__c='Mobile Handset';
        commerpro.Manufacturer__c='Apple';
        insert commerpro;  
    }
    
    @isTest
    public static void setProductDetailsPostive()
    {
        setupdata();
        String listResult;
        Map<String,Object> resultLookUpMap = new Map<String,Object> ();
        resultLookUpMap.put('Type__c','Mobile Handset');
        resultLookUpMap.put('Manufacturer__c','Apple');
        resultLookUpMap.put('Model__c','Apple iphone 64GB');
        resultLookUpMap.put('Colour__c','Black');
        Test.startTest();
        List<StockCheckController.DeviceModelWrapper> result=AdvancedStockCheckController.setProductDetails(resultLookUpMap);
        Test.stopTest();
        for (StockCheckController.DeviceModelWrapper resultData:result){
        listResult=resultData.skuId;    }
        system.assertEquals(listResult == '13213425',true); 
    }
    
    
    @isTest
    public static void setProductDetailsNegative()
    {
        setupdata();
        Map<String,Object> resultLookUpMap = new Map<String,Object> ();
        resultLookUpMap.put('Type__c','');
        resultLookUpMap.put('Manufacturer__c','');
        resultLookUpMap.put('Model__c','');
        resultLookUpMap.put('Colour__c','');
        Test.startTest();
        List<StockCheckController.DeviceModelWrapper> result=AdvancedStockCheckController.setProductDetails(resultLookUpMap);
        Test.stopTest();
        System.assertEquals(result.size()==0,true);    
        
    }
    
      @isTest
    public static void checkAdvStockQuantityPostive()
    {
        setupdata();
        String listResult;
        List<String> skuidList = new List<String> ();
        skuidList.add('100158856');
        List<StockCheckController.DeviceModelWrapper> displayWrapper = new List<StockCheckController.DeviceModelWrapper> ();
        List<StockCheckController.DeviceModelWrapper> stockList= new List<StockCheckController.DeviceModelWrapper> ();
        StockCheckController.DeviceModelWrapper device1 =new StockCheckController.DeviceModelWrapper();
        device1.device='Samsung Galaxy S10 128GB Black';
        device1.skuId='100158856';
    stockList.add(device1); 
    Test.startTest();
        List<StockCheckController.DeviceModelWrapper> wrapper=AdvancedStockCheckController.checkAdvStockQuantity(skuidList,stockList);
        Test.stopTest();
         for (StockCheckController.DeviceModelWrapper resultData:wrapper){
        listResult=resultData.skuId; 
         }
        system.assertEquals(listResult == '100158856',true); 
    }
          @isTest
    public static void checkAdvStockQuantityNegative()
    {
        setupdata();
        List<String> skuidList = new List<String> ();
        List<StockCheckController.DeviceModelWrapper> stockList= new List<StockCheckController.DeviceModelWrapper> ();
    Test.startTest();
        List<StockCheckController.DeviceModelWrapper> wrapper=AdvancedStockCheckController.checkAdvStockQuantity(skuidList,stockList);
        Test.stopTest();
        system.assertEquals(wrapper.isEmpty(),true);
    }
    
    @isTest
    public static void fetchLookUpStockCheckPositive()
    {
        setupdata();
        String listResult;
        String searchKeyWord='';
        String ObjectName='cspmb__Price_Item__c';
        String identifier='cspmb__Price_Item__c.Type__c';
        Map<String,Object> resultLookUpMap = new Map<String,Object> ();
        resultLookUpMap.put('Type__c','Mobile Handset');
        resultLookUpMap.put('Manufacturer__c','Apple');
        resultLookUpMap.put('Model__c','Apple iphone 64GB');
        resultLookUpMap.put('Colour__c','Black');
        String identifierType='cspmb__Price_Item__c.Type__c';
        String identifierManu='cspmb__Price_Item__c.Manufacturer__c';
        String identifierModel='cspmb__Price_Item__c.Model__c';
        String identifieColor='cspmb__Price_Item__c.Colour__c';
        
        Test.startTest();
        List <sObject> resultType=AdvancedStockCheckController.fetchLookUpStockCheck(searchKeyWord, ObjectName,identifierType,resultLookUpMap,NULL);
        List <sObject> resultManu=AdvancedStockCheckController.fetchLookUpStockCheck(searchKeyWord, ObjectName,identifierManu,resultLookUpMap,NULL);
        List <sObject> resultModel=AdvancedStockCheckController.fetchLookUpStockCheck(searchKeyWord, ObjectName,identifierModel,resultLookUpMap,NULL);
        List <sObject> resultColor=AdvancedStockCheckController.fetchLookUpStockCheck(searchKeyWord, ObjectName,identifieColor,resultLookUpMap,NULL);
        Test.stopTest();
        for (sObject resultData:resultColor){
        listResult=String.valueOf(resultData.get('Colour__c'));    }
        system.assertEquals(listResult == 'Black',true); 
    }
    
    @isTest
    public static void fetchLookUpStockCheckNegative()
    {
        setupdata();
        String searchKeyWord='';
        String ObjectName='cspmb__Price_Item__c';
        String identifier='cspmb__Price_Item__c.Manufacturer__c';
        Map<String,Object> resultSearchMap = new Map<String,Object> ();
        resultSearchMap.put('Type__c','');
        List <sObject> result=AdvancedStockCheckController.fetchLookUpStockCheck(searchKeyWord, ObjectName,identifier,resultSearchMap,NULL);
        System.assertEquals(result.size()==0,true);    
    }
    
/*************************************************************************************************
EDGE :155450  
Name:getMetaProdValTest
Description: Stock Check_Greying Out Manufacture and Colour fields for accessories
Author: Zeeshan
***************************************************************************************************/
 @isTest
    public static void getMetaProdValTest(){
        cspmb__Price_Item__c commerpro=TestUtil.createPriceItem();
        commerpro.Colour__c='Black';
        commerpro.ProdSpecId__c='DMCAT_ProductSpecification_000423';
        commerpro.Type__c='Mobile Handset';
        commerpro.Manufacturer__c='Apple';
        insert commerpro; 
        Test.startTest();
        List <StockProductSpecID__mdt>  fetchMetaVal = AdvancedStockCheckController.getMetaProdVal('Mobile Handset');
        system.debug('fetchMetaVal-->'+fetchMetaVal);
        Test.stopTest();
        system.assertEquals(fetchMetaVal[0].Colour__c,true);
    }    
/*************************************************************************************************
EDGE : EDGE-148587
Name:getUserInfoTestPositive
Description: Test class for running user as partner user
Author: Manjunath Ediga
***************************************************************************************************/
    @isTest
    public static void getUserInfoTestPositive()
    {
      User partnerUser;  
      UserRole usrRole = new UserRole(Name = 'CEO');
      insert usrRole;
      profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User adminUser = new User(Alias = 'admUsr',Country='Australia',UserRoleId=usrRole.id,Email='admintest@partneruser.com',EmailEncodingKey='UTF-8', LastName='Admin Test', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = adminProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='adminprofileusr@telstra.com');
      insert adminUser;
      System.runAs(adminUser) {
      Account acc = new Account (Name = 'newAcc1');   
      insert acc;
      Contact con = new Contact (AccountId = acc.id,LastName = 'portalTestUser',Pref_Comm_Method__c ='eMail',Authority__c='Full Authority');
      con.Email='testacc@sfdc.com';
      insert con;
      Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='PRM Admin - Australia'];
      partnerUser = new User(Alias = 'pnrUsr',contactId =con.id,Country='Australia',Email='test@partneruser.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = partnerProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='partnerprofileusr@telstra.com');
      insert partnerUser;
      }
      System.runAs(partnerUser){
           Test.startTest();         
           Boolean partnerTrue = AdvancedStockCheckController.getUserInfo();
           system.assertEquals(true, partnerTrue);
           Test.stopTest();
        }
    }
    
/*************************************************************************************************
EDGE : EDGE-148587
Name:getUserInfoTestPositive
Description: Test class for running user as other than partner user
Author: Manjunath Ediga
***************************************************************************************************/
    @isTest
    public static void getUserInfoTestNegative()
    {
       Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User partnerUser = new User(Alias = 'pnrUsr',Country='Australia',Email='test@partneruser.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = partnerProfile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='partnerprofileusr@telstra.com');
       insert partnerUser;
       System.runAs(partnerUser){
           Test.startTest();         
           Boolean partnerfalse = AdvancedStockCheckController.getUserInfo();
           system.assertEquals(false, partnerfalse);
           Test.stopTest();
       }
       
    }
}