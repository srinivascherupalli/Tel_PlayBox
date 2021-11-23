/****************************************************************************************************************************************************
Main Class : Model_PriceItem
Test Class : Model_PriceItemTest 
=============================================================================================================================================
Sr.No.    Developer Name      Date            Story          Sprint               Description
1.        Aman Soni           03/07/2020      EDGE-148667    20.09(New Class)     To collate all the queries related to Price Item Object
2.        Aman Soni           07/23/2020      EDGE-154026    20.10                Added by Aman Soni
2.        Aman Soni           11/23/2020      EDGE-178210    20.16                Added by Aman Soni
4.  Vamsi Krishna Vaddipalli  13MAY2021       EDGE-212162    21.07                To fetch SKUID's
=============================================================================================================================================
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_PriceItemTest{
   @TestSetup
   public static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    
    cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
    testPriceItem.Name = 'Mobile Device';
    testPriceItem.Manufacturer__c = 'TestMan';
    testPriceItem.Model__c = 'TestMod';
    testPriceItem.Type__c= 'TestDev';
    testPriceItem.Colour__c = 'TestCol';
    testPriceItem.cspmb__Contract_Term__c = '12';
    testPriceItem.ChargeType__c = 'RC';
    testPriceItem.cspmb__Recurring_Charge__c = 75;
    
    cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
    testPriceItem2.Name = 'Mobile Device';
    testPriceItem2.Manufacturer__c = 'TestMan';
    testPriceItem2.Model__c = 'TestMod';
    testPriceItem2.Type__c= 'TestDev';
    testPriceItem2.Colour__c = 'TestCol';
    testPriceItem2.ChargeType__c = 'OC';
    testPriceItem2.cspmb__One_Off_Charge__c = 1000;
    
    cspmb__Price_Item__c testPlanType = new cspmb__Price_Item__c();
    testPlanType.offer_id__C = 'DMCAT_Offer_000646';
    testPlanType.offer__c = 'Aggregated Data';
    testPlanType.plan__c = 'Local';
    
    cspmb__Price_Item__c testPlanTypeD = new cspmb__Price_Item__c();
    testPlanTypeD.Name = 'Next Generation Mobile Device';
    testPlanTypeD.offer_id__C = 'DMCAT_Offer_000646';
    testPlanTypeD.offer__c = 'Aggregated Data';
    testPlanTypeD.plan__c = 'Local';
    testPlanTypeD.Type__c = 'Data';
    
    cspmb__Price_Item__c testPlanTypeVnD = new cspmb__Price_Item__c();
    testPlanTypeVnD.Name = 'Next Generation Mobile Device';
    testPlanTypeVnD.offer_id__C = 'DMCAT_Offer_000646';
    testPlanTypeVnD.offer__c = 'Aggregated Data';
    testPlanTypeVnD.plan__c = 'Local';
    testPlanTypeVnD.Type__c = 'Voice and Data';
    
    cspmb__Price_Item__c testPlanTypeBlank = new cspmb__Price_Item__c();
    testPlanTypeBlank.Name = 'Next Generation Mobile Device';
    testPlanTypeBlank.offer_id__C = 'DMCAT_Offer_000646';
    testPlanTypeBlank.offer__c = 'Aggregated Data';
    testPlanTypeBlank.plan__c = 'Local';
    testPlanTypeBlank.Type__c = '';

    cspmb__Price_Item__c testSKUIds = new cspmb__Price_Item__c();
    testSKUIds.Name = 'Next Generation Mobile Device';
    testSKUIds.offer_id__C = 'DMCAT_Offer_000646';
    testSKUIds.offer__c = 'Aggregated Data';
    testSKUIds.Type__c = '';
    testSKUIds.SKU__c = '100114769';
    testSKUIds.ProdSpecId__c = 'DMCAT_ProductSpecification_000423';

    
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testPriceItem,testPriceItem2,testPlanType,testPlanTypeD,testPlanTypeVnD,testPlanTypeBlank,testSKUIds};
    insert PIList; 
   }
    @IsTest
  private static void getDeviceTypePositive(){
        List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, Type__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c,cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];     
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = 'DMCAT_Offer_000646'; 
        String itemcode = 'Next Generation Mobile Device';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQueryData = mdPI.getDeviceType(offerId,'Data',itemcode);
            System.assert(true, !String.isBlank(searchQueryData));
            
            String searchQueryVnD = mdPI.getDeviceType(offerId,'Voice and Data',itemcode);
            System.assert(true, !String.isBlank(searchQueryVnD));
            
            String searchQueryBlankPlan = mdPI.getDeviceType(offerId,'',itemcode);
            System.assert(true, !String.isBlank(searchQueryBlankPlan)); 
        }       
        Test.stopTest();
    }
    @IsTest
  private static void getDeviceTypeNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = ''; 
        String PlanType = '';
        String itemcode = '';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getDeviceType(offerId,PlanType,itemcode);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getManufacturerPositive(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String searchValue = 'TestSearch'; 
        String offerId = 'DMCAT_Offer_000646'; 
        String deviceTypeString = 'TestDev';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            if(String.isEmpty(searchValue)){
                String searchQuery = mdPI.getManufacturer(searchValue,offerId,deviceTypeString);
                System.assert(true, !String.isBlank(searchQuery));
            }else{
                String searchQuery = mdPI.getManufacturer(searchValue,offerId,deviceTypeString);
                System.assert(true, !String.isBlank(searchQuery));
            }
        }
        Test.stopTest();
    }
    @IsTest
  private static void getManufacturerNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String searchValue = ''; 
        String offerId = 'DMCAT_Offer_000646'; 
        String deviceTypeString = 'TestDev';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getManufacturer(searchValue,offerId,deviceTypeString);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getModelPositive(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String searchValue = 'TestSearch'; 
        String offerId = 'DMCAT_Offer_000646'; 
        String deviceTypeString = 'TestDev';
        String selectedManufacturer = 'TestMan';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            if(String.isEmpty(searchValue)){
                String searchQuery = mdPI.getModel(searchValue,offerId,selectedManufacturer,deviceTypeString);
                System.assert(true, !String.isBlank(searchQuery));
            }else{
                String searchQuery = mdPI.getModel(searchValue,offerId,selectedManufacturer,deviceTypeString);
                System.assert(true, !String.isBlank(searchQuery));
            }
        }
        Test.stopTest();
    }
    @IsTest
  private static void getModelNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String searchValue = ''; 
        String offerId = 'DMCAT_Offer_000646'; 
        String deviceTypeString = 'TestDev';
        String selectedManufacturer = 'TestMan';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getModel(searchValue,offerId,selectedManufacturer,deviceTypeString);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getColourPositive(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String searchValue = 'TestSearch'; 
        String offerId = 'DMCAT_Offer_000646'; 
        String selectedModel = 'TestMod';
        String selectedManufacturer = 'TestMan';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            if(String.isEmpty(searchValue)){
                String searchQuery = mdPI.getColour(searchValue,offerId,selectedManufacturer,selectedModel);
                System.assert(true, !String.isBlank(searchQuery));
            }else{
                String searchQuery = mdPI.getColour(searchValue,offerId,selectedManufacturer,selectedModel);
                System.assert(true, !String.isBlank(searchQuery));
            }
        }
        Test.stopTest();
    }
    @IsTest
  private static void getColourNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String searchValue = ''; 
        String offerId = 'DMCAT_Offer_000646'; 
        String selectedModel = 'TestMod';
        String selectedManufacturer = 'TestMan';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getColour(searchValue,offerId,selectedManufacturer,selectedModel);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getPayTypePositive(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = 'DMCAT_Offer_000646'; 
        String manufacturerString = 'TestMan';
        String modelString = 'TestMod';
        String colourString = 'TestCol';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getPayType(offerId,manufacturerString,modelString,colourString);
            System.assert(true, !String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getPayTypeNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = ''; 
        String manufacturerString = '';
        String modelString = '';
        String colourString = '';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getPayType(offerId,manufacturerString,modelString,colourString);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getContractTermPositive(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = 'DMCAT_Offer_000646'; 
        String manufacturerString = 'TestMan';
        String modelString = 'TestMod';
        String colourString = 'TestCol';
        String paymentTypeString = 'TestPayType';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getContractTerm(offerId,manufacturerString,modelString,paymentTypeString,colourString);
            System.assert(true, !String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getContractTermNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = ''; 
        String manufacturerString = '';
        String modelString = '';
        String colourString = '';
        String paymentTypeString = '';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getContractTerm(offerId,manufacturerString,modelString,paymentTypeString,colourString);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    //Added by Aman Soni as a part of EDGE-154026 || Start 
    @IsTest
  private static void getPlanTypePositive(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = 'DMCAT_Offer_000646'; 
        String offerTypeString = 'TestOffer';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getPlanType(offerId,offerTypeString);
            System.assert(true, !String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getPlanTypeNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = 'DMCAT_Offer_000646'; 
        String offerTypeString = '';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getPlanType(offerId,offerTypeString);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    //Added by Aman Soni as a part of EDGE-154026 || End 
    
    //Added by Aman Soni for EDGE-178210 || Start 
    @IsTest
  private static void getUCDeviceModelPositive(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = 'DMCAT_Offer_000646'; 
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getUCDeviceModel(offerId);
            System.assert(true, String.isNotBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getUCDeviceModelNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = ''; 
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getUCDeviceModel(offerId);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
     @IsTest
  private static void getCS_UC_CallingPlanPositive(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = 'DMCAT_Offer_000646'; 
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getCS_UC_CallingPlan(offerId);
            System.assert(true, String.isNotBlank(searchQuery));
        }
        Test.stopTest();
    }
    @IsTest
  private static void getCS_UC_CallingPlanNegative(){
        Model_PriceItem mdPI = new Model_PriceItem();
        String offerId = ''; 
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            String searchQuery = mdPI.getCS_UC_CallingPlan(offerId);
            System.assert(true, String.isBlank(searchQuery));
        }
        Test.stopTest();
    }
    //Added by Aman Soni for EDGE-178210 || End 

    //Added by Vamsi for EDGE-212162 on 18MAY2021 starts
    @IsTest
  private static void fetchActiveSKUPositive()
  {
    Model_PriceItem mdPI = new Model_PriceItem();
    Test.startTest();
    User sales = [SELECT id,name FROM User WHERE username='salesunifieduser@testsales.com'];
    System.runAs(sales)
    {
        Set<String> listOfProducts = new Set<String>();
        listOfProducts.add('DMCAT_ProductSpecification_000423');
        List<cspmb__Price_Item__c> sukIdlist = mdPI.fetchActiveSKU(listOfProducts);
        System.assert(true, sukIdlist != null);
    }
    Test.stopTest();
  }
  //Added by Vamsi for EDGE-212162 on 18MAY2021 starts
   //Added by Mahima Gandhe as a part of DIGI-30692 || Start 
   @IsTest
   private static void getPlanStringPositive(){
         Model_PriceItem mdPI = new Model_PriceItem();
         String offerId = 'DMCAT_Offer_000646'; 
         String planTypeString = 'TestOffer';
         Test.startTest();
         User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
         System.runAs(sales){
             String searchQuery = mdPI.getPlanString(offerId,planTypeString);
             System.assert(true, !String.isBlank(searchQuery));
         }
         Test.stopTest();
     }
     @IsTest
   private static void getPlanStringNegative(){
         Model_PriceItem mdPI = new Model_PriceItem();
         String offerId = 'DMCAT_Offer_000646'; 
         String planTypeString = '';
         Test.startTest();
         User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
         System.runAs(sales){
             String searchQuery = mdPI.getPlanString(offerId,planTypeString);
             System.assert(true, String.isBlank(searchQuery));
         }
         Test.stopTest();
     }
     //Added by Mahima Gandhe  as a part of DIGI-30692 || End
}