@isTest
public class NumberManagementMobilityControllerTest {
    
    @isTest
    public static void unit_test1(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
         insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        cscfga__attribute__c attr3 = new cscfga__attribute__c();
        attr3.name = 'Device';
		attr3.name = 'iPhone';
        attr3.cscfga__Product_Configuration__c = config.Id;
        insert attr3;
		cscfga__attribute__c attr1 = new cscfga__attribute__c();
        attr1.name = 'VoiceToText';
		attr1.name = 'no';
        attr1.cscfga__Product_Configuration__c = config.Id;
        insert attr1;
		cscfga__attribute__c attr2 = new cscfga__attribute__c();
        attr2.name = 'DeviceQuantity';
		attr2.name = '10';
        attr2.cscfga__Product_Configuration__c = config.Id;
        insert attr2;
         cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000074';
         insert prodDef1; 
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Root_Configuration__c = config.id;
         config1.name = 'User-Fixed Seat-Zone1';
        config1.User_Type__c = 'User-Fixed Seat-Zone1';
         config1.Quantity_Product_Configuration__c =20;
        insert config1;
         
         cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config2.cscfga__Contract_Term__c = 12;
        config2.cscfga__total_contract_value__c = 325;
        config2.cscfga__Product_Basket__c = basket.id;
        config2.cscfga__Root_Configuration__c = config.id;
         config2.name = 'User-Fax Line-Zone1';
        config2.User_Type__c ='User-Fax Line-Zone1';
         config2.Quantity_Product_Configuration__c =20;
        insert config2;
        List<cscfga__Attribute__c> detailsList =new List<cscfga__Attribute__c>();
         cscfga__attribute__c attr = new cscfga__attribute__c();
         attr.name = 'VoiceToText';
         attr.cscfga__Product_Configuration__c = config2.Id;
         //attr.cscfga__Value__c='a3T2O000000GI23UAG';
         //insert attr;
        detailsList.add(attr);
        //insert detailsList;
        

        basketId =  basket.id;
        rootConfigId = config.id;
        //Integer toBeReserve=quantity-totalReservedQty;
        
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        //Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('success_Search'));
        //FNNDTO dto = new FNNDTO();
        //FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
        NumberManagementMobilityController nmc = new NumberManagementMobilityController();
        //FNNResponseDTO fnnRes=MSISDNService.searchMSISDN(dto);
		
        List<String> msisdnList=new List<String>();
        msisdnList.add('6123456782');
        msisdnList.add('6123456783');
        Integer quantity=10;
        Integer totalReservedQty=5;
        nmc.tobeReserved=0;
        nmc.device='Apple iPhoneX';
        nmc.reqQuantity=70;
        nmc.reqPattern='*61';
        nmc.setProductDetails();
        nmc.getSearchTypes();
        nmc.getToBeReservedQty(quantity,totalReservedQty);
        nmc.getTotalReservedQty(totalReservedQty);
        nmc.doSearch();
        //nmc.checkjobStatus();
        //nmc.getAccounts();
        nmc.createReserveWrap(msisdnList);
        nmc.reserveSelected();
        nmc.getUnreserveNumbers(msisdnList);

        nmc.unreserveSelected();
        nmc.searchMSISDN();
        nmc.reserveMSISDN(msisdnList);
        nmc.unReserveMSISDN(msisdnList);
        nmc.sendChatterNotification();
        nmc.clearAll();
        System.assertNotEquals(msisdnList, NULL);

    }
    
    @isTest
    public static void unit_test2()
    {
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
         insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        List<String> msisdnList=new List<String>();
        msisdnList.add('6123456782');
        msisdnList.add('6123456783');
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementMobilityController nmc = new NumberManagementMobilityController();
        nmc.tobeReserved=5;
        nmc.device='Apple iPhoneX';
        nmc.reqQuantity=10;
        nmc.reqPattern='*61';
        nmc.doSearch();
       	//nmc.autoReserveMSISDN();
        System.assertNotEquals(msisdnList, NULL);


    }
    
    @isTest
    public static void unit_autoReserve()
    {
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
         insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        List<String> msisdnList=new List<String>();
        NumberManagementMobilityController nmc = new NumberManagementMobilityController();
        nmc.totalReserved=5;
        nmc.device='Apple iPhoneX';
        nmc.quantity=10;
        nmc.reqPattern='*61';
        nmc.isAutoRes=true;
       	nmc.doAutoReserve();
        System.assertNotEquals(nmc.totalReserved, NULL);


    }
    @isTest
    public static void unit_validation()
    {
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
         insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        List<String> msisdnList=new List<String>();
        msisdnList.add('6123456782');
        msisdnList.add('6123456783');
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementMobilityController nmc = new NumberManagementMobilityController();
		nmc.reqQuantity=0;
		nmc.doSearch();
		nmc.reqQuantity=60;
		nmc.doSearch();
		nmc.reqQuantity=5;
		nmc.tobeReserved=0;
		nmc.doSearch();
		nmc.tobeReserved=5;
		nmc.doSearch();
        nmc.device='Apple iPhoneX';
        nmc.reqPattern=null;
        nmc.doSearch();
        nmc.reqPattern='abc';
        System.assertNotEquals(msisdnList, NULL);
    }
    

}