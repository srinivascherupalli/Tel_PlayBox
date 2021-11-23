/****************************************************************************************************************************************************
Main Class : Model_AssetObj
Test Class : Model_AssetObjTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story          Sprint               Description
1.        Ankit Goswami      03/07/2020      EDGE-148733    20.09(New Class)     To collate all the queries related to Asset Object
=====================================================================================================================================================
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class Model_AssetObjTest{
  @TestSetup
      private static void testSetup(){
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        
          Account acc = new Account(Name = 'Burlington');
         insert Acc;
        
         List<cscfga__Product_Configuration__c> prodConfigLst = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name = 'new config';
        prodConfigLst.add(newConfig);
        
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
        config.name = 'prod config';
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        prodConfigLst.add(config);
        
        insert prodConfigLst;
         
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subs';
        subs1.csord__Identification__c = 'test identity';
        subs1.csordtelcoa__Product_Configuration__c = config.id;
        insert subs1;
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service1';
        serv2.csord__Identification__c  = 'test identify1';
        serv2.csord__Status__c = 'Service created';
        serv2.csord__Subscription__c  = subs1.id;
        serv2.csordtelcoa__Service_Number__c = '3';
        serv2.Initial_Activation_Date__c = System.today()-365;
        serv2.csordtelcoa__Product_Configuration__c = config.id;
        insert serv2;
    
        List<Asset> AssetLst = new List<Asset>();
        Asset AssetId= new Asset();
        AssetId.Name='test';
        AssetId.AccountId=acc.id;
        AssetId.AssetID__c='12345';
        AssetId.Status='Installed';
        AssetId.Price=10;
        AssetId.csord__Service__c=serv2.id;
        AssetId.Subscription__c=subs1.id;
        AssetLst.add(AssetId);
        insert AssetLst;
   }
    /*******************************************************************************************************
    * Method Name : getAssetIdTestPositive
    * Description : EDGE-148733- For GetAssetForConfiguration method
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetAssetTestPositive(){
            Set<String> configIds= new set<String>();
        list<Asset> returnList= new list<Asset>(); 
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        //System.runAs(sales){
        cscfga__Product_Configuration__c testConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'prod config'];
        list<csord__Service__c> serviceList=[Select id,name,csordtelcoa__Product_Configuration__c from csord__Service__c where name = 'tst service1'];
       
        configIds.add(testConfig.id);
        
        list<Asset>AssetList=[select id,AssetID__c,csord__Service__r.csordtelcoa__Product_Configuration__c from Asset where csord__Service__r.csordtelcoa__Product_Configuration__c In : configIds];
        
        system.debug('AssetList:::::::'+AssetList);
        Test.startTest();
        
        returnList= Model_AssetObj.getAssetId(configIds);
        //}
        system.debug('returnList:::::::'+returnList);
        Test.stopTest();
        System.assert(!returnList.isEmpty());      
    }
   /*******************************************************************************************************
    * Method Name : getAssetIdTestNegative
    * Description : EDGE-148733- For GetAssetForConfiguration method
    * Parameters  : NA
    * Return      : NA
    ******************************************************************************************************/
    static testmethod void GetAssetTestNegative(){
        cscfga__Product_Configuration__c testConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'new config'];
        Set<String> configIds= new set<String>();
        list<Asset> returnList=new list<Asset>(); 
        configIds.add((string)testConfig.id);
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        returnList= Model_AssetObj.getAssetId(configIds);
        }
        Test.stopTest();
        System.assert(returnList.isEmpty());  
      
    }
    /*******************************************************************************************************
    * Method Name : GetServiceIDTest
    * Description : DIGI-27111
    * Parameters  : NA
    * Return      : NA
    ******************************************************************************************************/
    static testmethod void GetServiceIDTest(){
      Set<id> serviceIds = new set<id>();
     list<Asset> returnList= new list<Asset>(); 
     User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
     //System.runAs(sales){
     cscfga__Product_Configuration__c testConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'prod config'];
     list<csord__Service__c> serviceList=[Select id,name,csordtelcoa__Product_Configuration__c from csord__Service__c where name = 'tst service1'];
    
     serviceIds.add(testConfig.id);
     
     list<Asset> AssetList=[Select id,AssetID__c,csord__Service__c,Subscription__c,Subscription__r.Logistics_Order_Number__c from Asset where csord__Service__r.id In('') and AssetID__c=null];
     
     system.debug('AssetList:::::::'+AssetList);
     Test.startTest();
     
     returnList= Model_AssetObj.fetchAssetfromService(serviceIds);
     //}
     system.debug('returnList:::::::'+returnList);
     Test.stopTest();
     System.assert(returnList.isEmpty());      
 }
}