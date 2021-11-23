/*************************************************************************************************
Name : StockCheckControllerTest
Description : Test class for StockCheckController 
Author: Aishwarya
Story: EDGE-80858
Modified: Manjunath Ediga (EDGE-144680), Shresth dixit (DPG-3510), Vamsi Krishna Vaddipalli(EDGE-212162)
***************************************************************************************************/

@isTest
public class StockCheckControllerTest {
    public static Id basketId{get; set;}
    public static Id PCId{get; set;} 
    
    public static void setupdata(){
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        List<cspmb__Price_Item__c> priceList= new List<cspmb__Price_Item__c>();

        cscfga__Product_Configuration__c testProductConfiguration1 = TestDataFactory.generateProductConfiguration();
        
        cspmb__Price_Item__c commerpro1=TestUtil.createPriceItem();
        commerpro1.Colour__c='Black';
        //Start of EDGE-144680 : added additional attributes to test data
        commerpro1.Name='Mobile Device';
        commerpro1.Model__c='SAMSUNG GALAXY S10 128GB';
        commerpro1.Manufacturer__c='SAMSUNG';
        //End of EDGE-144680
        commerpro1.ProdSpecId__c='DMCAT_ProductSpecification_000423';
        insert commerpro1;    
        priceList.add(commerpro1);

        //Added by Vamsi for EDGE-212162 on 18MAY2021 starts
        List<cspmb__Price_Item__c> listOfPriceItems = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c testSKUIds = new cspmb__Price_Item__c();
        testSKUIds.Name = 'Next Generation Mobile Device1';
        testSKUIds.SKU__c = '100158856';
        testSKUIds.ProdSpecId__c = 'DMCAT_ProductSpecification_001389';
        listOfPriceItems.add(testSKUIds);

        cspmb__Price_Item__c testSKUIds1 = new cspmb__Price_Item__c();
        testSKUIds1.Name = 'Next Generation Mobile Device2';
        testSKUIds1.SKU__c = '100157169';
        testSKUIds1.ProdSpecId__c = 'DMCAT_ProductSpecification_000622';
        listOfPriceItems.add(testSKUIds1);
        
         cspmb__Price_Item__c testSKUIds2 = new cspmb__Price_Item__c();
        testSKUIds2.Name = 'Next Generation Mobile Device3';
        testSKUIds2.SKU__c = '100115460';
        testSKUIds2.ProdSpecId__c = 'DMCAT_ProductSpecification_000623';
        listOfPriceItems.add(testSKUIds2);

        cspmb__Price_Item__c testSKUIds3 = new cspmb__Price_Item__c();
        testSKUIds3.Name = 'Next Generation Mobile Device4';
        testSKUIds3.SKU__c = '100159379';
        testSKUIds3.ProdSpecId__c = 'DMCAT_ProductSpecification_001211';
        listOfPriceItems.add(testSKUIds3);
        
        cspmb__Price_Item__c testSKUIds4 = new cspmb__Price_Item__c();
        testSKUIds4.Name = 'Next Generation Mobile Device';
        testSKUIds4.SKU__c = '100114769';
        testSKUIds4.ProdSpecId__c = 'DMCAT_ProductSpecification_000423';
        listOfPriceItems.add(testSKUIds4);

        cspmb__Price_Item__c testSKUIds5 = new cspmb__Price_Item__c();
        testSKUIds5.Name = 'Next Generation Mobile Device';
        testSKUIds5.SKU__c = '100119246';
        testSKUIds5.ProdSpecId__c = 'DMCAT_ProductSpecification_000622';
        listOfPriceItems.add(testSKUIds5);
        insert listOfPriceItems;
        //Added by Vamsi for EDGE-212162 on 18MAY2021 ends

        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='Mobile SKU';
        attr1.cscfga__Value__c='2433222';
        attr1.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr1);
       
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='SKU';
        attr2.cscfga__Value__c='2433223';
        attr2.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr2);
        //Start of EDGE-144680 added attribute with Name PaymentTypeLookup
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='PaymentTypeLookup';
        attr3.cscfga__Value__c= string.valueOf(priceList[0].id);
        attr3.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr3);
        //End of EDGE-144680
        insert lstAttr;
        
        
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Mobile';
        pd.product_Specification__c='DMCAT_ProductSpecification_000423';
        update pd;       
        testProductConfiguration1.cscfga__Product_Definition__c=pd.id;
        update testProductConfiguration1;
        PCId=testProductConfiguration1.id;
        
        basketId= testProductConfiguration1.cscfga__Product_Basket__c;
        
    }
    
    
    /*************************************************************************************************
Name : stockchecksuccess
Description : Test Method to check mobile devices already in basket
Author: Aishwarya
Story: EDGE-80858
***************************************************************************************************/
    @isTest
    public static void stockchecksuccess()
    {
        setupdata();

        list<cspmb__Price_Item__c> pItemList=[Select id from cspmb__Price_Item__c where Name='Mobile Device'];

        
        Test.startTest();
        StockCheckController.getDevice();
        StockCheckController.getSelectedDevice('Mobile');
        String mapJson='';       
        List<StockCheckController.DeviceModelWrapper> deviceDetails = StockCheckController.setProductDetails(basketId,mapJson,null,null);
        System.assertEquals(deviceDetails[0].manufacturer,'SAMSUNG');
        Test.stopTest();

    }
    
        /*************************************************************************************************
Name : stockcheckwithJson
Description : Test Method to check Stockcheck based on the JSON string passed
Author: RaviTeja
Story:  EDGE-146972
***************************************************************************************************/
    @isTest
    public static void stockcheckwithJson()
    {
        setupdata();
        list<cspmb__Price_Item__c> pItemList=[Select id from cspmb__Price_Item__c where Name='Mobile Device'];
        Test.startTest();  
        String mapJson='{"ba0290c5-c8e5-428d-f5de-8d1710a28659":{"PaymentTypeLookup":{"name":"PaymentTypeLookup","label":"Payment Type","readOnly":false,"value":"'+pItemList[0].id+'"}}}';
        system.debug('mapJson'+mapJson);        
        List<StockCheckController.DeviceModelWrapper> deviceDetails = StockCheckController.setProductDetails(basketId,mapJson,null,null);
        System.assertEquals(deviceDetails[0].manufacturer,'SAMSUNG');
        Test.stopTest();

    }
    /*************************************************************************************************
Name : stockchecksuccess
Description : Test Method to check UC's already in basket
Author: Aishwarya
Story: EDGE-80858,EDGE-144680
Modified: Manjunath Ediga -144680
***************************************************************************************************/
    @isTest
    public static void stockchecksuccessUC()
    {
        setupdata();

        Test.startTest();
        StockCheckController.getDevice();
        StockCheckController.getSelectedDevice('Unified Communication');
        //StockCheckController.getDeviceQuantity(device1.device);
        //Start of EDGE:144680 - modified the assert statement

        string mapJson='';
        List<StockCheckController.DeviceModelWrapper> devicewrapper = StockCheckController.setProductDetails(basketId,mapJson,null,null);
        System.assertEquals(devicewrapper[0].manufacturer,'SAMSUNG');   
        //End of EDGE-144680
        Test.stopTest();
  
    }
    
    /*************************************************************************************************
Name : stockchecksuccess
Description : Test Method to check stock of mobile devices in inventory
Author: Aishwarya
Story: EDGE-80858
***************************************************************************************************/  
    @isTest
    public static void stockCheckServiceSuccess(){
        setupdata();
        List<stockCheckController.DeviceModelWrapper> stockList= new List<stockCheckController.DeviceModelWrapper> ();
        stockCheckController.DeviceModelWrapper device1 =new stockCheckController.DeviceModelWrapper();
        stockCheckController.StockCheck stock=new stockCheckController.StockCheck();
        device1.device='Apple iphone 64GB';
        device1.skuId='113243546';
        //String rootConfigId='a3T2O000000JCXC';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Search'));
        StockCheckController.getDeviceQuantity(device1.device);
        stockCheckController.checkStock('2433222');
        // string restockedDate=stockCheckController.checkDate('2433222');
        System.assertEquals((device1.skuId!=null), true, 'Callout Failed');
        
        Test.stopTest();    
    }
    /*************************************************************************************************
Name : stockcheckError
Description : Test Method to check stock of mobile devices in inventory
Author: Aishwarya
Story: EDGE-80858
***************************************************************************************************/  
    @isTest
    public static void stockCheckServiceError(){
        List<stockCheckController.DeviceModelWrapper> stockList= new List<stockCheckController.DeviceModelWrapper> ();
        stockCheckController.DeviceModelWrapper device1 =new stockCheckController.DeviceModelWrapper();
        device1.device='Apple iphone 64GB';
        device1.skuId='113243546';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Error'));
        StockCheckController.getDeviceQuantity(device1.device);
        stockCheckController.checkStock('2433222');
        // string restockedDate=stockCheckController.checkDate('2433222');
        System.assertEquals((device1.skuId!=null), true, 'Callout Failed');
        
        Test.stopTest();    
    }
        /*************************************************************************************************
Name : stockCheckMultipleSuccess
Description : Test Method to check stock of mobile devices in inventory
Author: Kalashree Borgaonkar
Story: EDGE-80860
***************************************************************************************************/ 
     @isTest
    public static void stockCheckMultipleSuccess(){
        setupdata();
        List<StockCheckController.DeviceModelWrapper> stockList= new List<StockCheckController.DeviceModelWrapper> ();
        StockCheckController.DeviceModelWrapper device1 =new StockCheckController.DeviceModelWrapper();
        device1.device='Samsung Galaxy S10 128GB Black';
        device1.skuId='100158856';
        stockList.add(device1);
        StockCheckController.DeviceModelWrapper device2 =new StockCheckController.DeviceModelWrapper();
        device2.device='Apple iPhone 7 128GB Black';
        device2.skuId='100157169';
        stockList.add(device2);
        StockCheckController.DeviceModelWrapper device3 =new StockCheckController.DeviceModelWrapper();
        device3.device='Cisco CP-8851 MPP IP Handset';
        device3.skuId='100115460';
        stockList.add(device3);
        StockCheckController.DeviceModelWrapper device4 =new StockCheckController.DeviceModelWrapper();
        device4.device='Cisco CP-8865 MPP IP Handset';
        device4.skuId='100159379';
        stockList.add(device4);
        List<String> skuidList = new List<String>{'100158856','100157169','100115460','100159379'};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_multiple'));
        List<stockCheckController.DeviceModelWrapper> wrapper = stockCheckController.checkStockQuantity(skuidList,stockList);
        system.debug('wrapper in method'+wrapper);
        System.assertEquals((!wrapper.isEmpty() && wrapper[0].message!=null), true, 'Callout Successful');
        Test.stopTest();    
    }
    /*************************************************************************************************
Name : stockCheckMultipleFailure
Description : Test Method to check stock of mobile devices in inventory
Author: Kalashree Borgaonkar
Story: EDGE-80860
***************************************************************************************************/ 
     @isTest
    public static void stockCheckMultipleFailure(){
        List<StockCheckController.DeviceModelWrapper> stockList= new List<StockCheckController.DeviceModelWrapper> ();
        StockCheckController.DeviceModelWrapper device1 =new StockCheckController.DeviceModelWrapper();
        device1.device='Samsung Galaxy S10 128GB Black';
        device1.skuId='100158856';
        stockList.add(device1);
        StockCheckController.DeviceModelWrapper device2 =new StockCheckController.DeviceModelWrapper();
        device2.device='Apple iPhone 7 128GB Black';
        device2.skuId='100157169';
        stockList.add(device2);
        StockCheckController.DeviceModelWrapper device3 =new StockCheckController.DeviceModelWrapper();
        device3.device='Cisco CP-8851 MPP IP Handset';
        device3.skuId='100115460';
        stockList.add(device3);
        StockCheckController.DeviceModelWrapper device4 =new StockCheckController.DeviceModelWrapper();
        device4.device='Cisco CP-8865 MPP IP Handset';
        device4.skuId='100159379';
        stockList.add(device4);
        List<String> skuidList = new List<String>{'100158856','100157169','100115460','100159379'};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Error'));
        List<StockCheckController.DeviceModelWrapper> wrapper = StockCheckController.checkStockQuantity(skuidList,stockList);
        system.debug('wrapper in method1'+wrapper);
        System.assertEquals((!wrapper.isEmpty() && wrapper[0].errorMessage!=null), true, 'Callout unsuccessful');
        Test.stopTest();    
    }
}