/*
* @Desc : CMP Utility test class
* @Jira : DIGI-518
*/
@isTest
public class CMP_UtilitiesTest {
    
    @isTest static void getCMPCommittedDataSuccess(){
        ProductBasketDataHandler testclass= new ProductBasketDataHandler();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        CMP_Utilities handler = new CMP_Utilities();
        List<Map<String,Object>> rows = handler.getCMPCommittedData(basketId,new Map<String,String>{'Query_Type'=>'CMPCommittedData','Type'=>'New'});
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        System.assert(rows[0].get('Product_Module_Name') == 'Committed'); //EDGE-146809 | Filtering Committed Data PCs
        System.debug('rows[0] '+rows[0]+' Rows: '+rows);
        System.assert(rows[1].get('Bonus_Data') == '40'); //EDGE-148067 | Positive scenario
    }
    @isTest static void getCMPCommittedDataFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
         RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         CMP_Utilities handler = new CMP_Utilities();
         List<Map<String,Object>> rows = handler.getCMPCommittedData(null,null);
         Test.stopTest();
         System.assert(rows.isEmpty() == true);
    }
    @isTest static void getCMPCancelProductsFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        CMP_Utilities handler = new CMP_Utilities();
        List<Map<String,Object>> rows = handler.getCMPCancelProducts(null,null);
        Test.stopTest();
        System.assert(rows.isEmpty() == true);
    }
    @isTest static void getCMPDevicesTestSuccess(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        CMP_Utilities handler = new CMP_Utilities();
        List<Map<String,Object>> rows = handler.getCMPDevices(basketId,new Map<String,String>{'Order_Type'=>'Device', 'Query_Type'=>'CMPDeviceDetails','Type'=>'New'});
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
        system.assert(rows[0].get('Product_Module_Name')=='V2T Samsung Galaxy S9+ 256GB Black first');//EDGE-154662 Fix Assert
    }
    @isTest static void getCMPDevicesModifyTestFailure(){
        ProductBasketDataHandlerTest testclass= new ProductBasketDataHandlerTest();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
         rftestclass.setupdata();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         CMP_Utilities handler = new CMP_Utilities();
         List<Map<String,Object>> rows = handler.getCMPDevices(basketId,new Map<String,String>{'Order_Type'=>'Device', 'Query_Type'=>'CMPDeviceDetails','Type'=>'Modify'});
         Test.stopTest();
         System.assert(!rows.isEmpty() == false);
    }
    @isTest static void getCMPServicesTestSuccess(){
        ProductBasketDataHandler testclass= new ProductBasketDataHandler();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        //rftestclass.setup();
        rftestclass.setupGetCMPServiceData();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        CMP_Utilities handler = new CMP_Utilities();
        List<Map<String,Object>> rows = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'New'});
        system.debug('getCMPServicesTestSuccessdebug'+rows);
        Test.stopTest();       
        System.assertEquals(1,rows[0].get('Quantity'));//EDGE-140420 AND EDGE-143435
        System.assert(rows.isEmpty() == false);
        System.assertEquals('3G Standard Retail',rows[2].get('Product_Module_Name'));//EDGE-162025
    }
     @isTest static void getCMPServicesTestModify(){
        ProductBasketDataHandler testclass= new ProductBasketDataHandler();
         RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        //testclass.setup();
        rftestclass.setupGetCMPServiceData();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         CMP_Utilities handler = new CMP_Utilities();
         List<Map<String,Object>> rows = handler.getCMPServices(basketId,new Map<String,String>{'Query_Type'=>'CMPServiceDetails','Type'=>'Modify'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
    }
}