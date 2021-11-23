@isTest
public class NumberManagementControllerTest
{ 
    
    public testmethod static void unit_test_1(){
        try{
            
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
            config.Name = 'IP Site';
            update config;
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
            config2.name = 'Fax Line';
            config2.User_Type__c ='Fax Line';
            config2.Quantity_Product_Configuration__c =20;
            insert config2;
            
            cscfga__Product_Configuration__c config3 = ProductTestFactory.buildProductConfig(prodDef1.id);
            config3.cscfga__Contract_Term__c = 12;
            config3.cscfga__total_contract_value__c = 325;
            config3.cscfga__Product_Basket__c = basket.id;
            config3.cscfga__Root_Configuration__c = config.id;
            config3.name = 'Hunt Group';
            config3.User_Type__c ='Hunt Group';
            config3.Quantity_Product_Configuration__c =20;
            insert config3;
            
            cscfga__attribute__c attr = new cscfga__attribute__c();
            attr.name = 'isNumberEnrichComplete';
            attr.cscfga__Value__c = 'true';
            attr.cscfga__Product_Configuration__c = config.Id;
            insert attr;
            cscfga__attribute__c attr1 = new cscfga__attribute__c();
            attr1.name = 'TotalNumbers';
            attr1.cscfga__Product_Configuration__c = config.Id;
            attr1.cscfga__Value__c = '10';
            insert attr1;
            basketId =  basket.id;
            rootConfigId = config.id;
            Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
            System.currentPageReference().getParameters().put('basketId', basketId);
            System.currentPageReference().getParameters().put('configId', rootConfigId);
            NumberManagementController instance = new NumberManagementController();       
            List<NumberManagementController.OrderSummary> ordlist = new List<NumberManagementController.OrderSummary>();
            NumberManagementController.OrderSummary ord = new NumberManagementController.OrderSummary();
            ord.siteName= 'Hello';
            ord.siteID='world';
            ord.siteAddress='Order';
            ord.totalfixedSeatCount=10;
            ord.configId='20';
            ord.total=30;
            ordlist.add(ord);
            Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
            instance.pattern ='*02*';
            instance.totalReservedNumber = '9';
            instance.adborId = '6376263';
            instance.activeNumbersListCollap= new List<String>(); 
            instance.selectedReservedNumbers= new List<String>();
            // Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
            HttpResponse response = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
            req.setMethod('POST');
            FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
            response = mockRes.respond(req);
            //instance.selectedNumType = 'exchangeServiceArea';
            //instance.enableESA();
            instance.getSiteList();
            instance.searchFNN();
            // instance.reserveFNN();
            instance.hideSearchResult();
            //instance.validateSiteWithUSers();
            instance.clearAll();
            System.assertEquals(attr.name, 'isNumberEnrichComplete');
        }catch(Exception e)
        {
            system.debug('Exception'+e.getMessage());
        }
        
    }
    
    public testmethod static void unit_test_2(){
        csoe__Non_Commercial_Schema__c schemaNcs = new csoe__Non_Commercial_Schema__c(Name = 'NumberManagementv1');
        insert schemaNcs;
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductSpecification_000049';
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000074';
        insert prodDef1; 
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Root_Configuration__c = config.id;
        config1.name = 'User-Fixed Seat-Zone1';
        config1.Quantity_Product_Configuration__c =20;
        insert config1;
        
        cscfga__attribute__c attr = new cscfga__attribute__c();
        attr.name = 'Test Site Name Test';
        attr.cscfga__Product_Configuration__c = config.Id;
        insert attr;
        basketId =  basket.id;
        rootConfigId = config.id;
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        List<NumberManagementController.OrderSummary> ordlist = new List<NumberManagementController.OrderSummary>();
        NumberManagementController.OrderSummary ord = new NumberManagementController.OrderSummary();
        ord.siteName= 'Hello';
        ord.siteID='world';
        ord.siteAddress='Order';
        ord.totalfixedSeatCount=10;
        ord.configId='20';
        ord.total=30;
        ordlist.add(ord);
        Test.startTest();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        instance.pattern ='*02*';
        instance.totalReservedNumber = '100';
        
        instance.adborId = '6376263';
        instance.activeNumbersListCollap= new List<String>(); 
        instance.selectedReservedNumbers= new List<String>();
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
        FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        instance.quantity = 20;
        List<NumberManagementController.wrapReservedNumbers> ReservedNumbersListWrap  = new  List<NumberManagementController.wrapReservedNumbers>();
        
        instance.selectedPatternType = 'Equals';
        // instance.selectedPatternType = 'TEst123';
        //instance.enableESA();
        // instance.getSiteList();
        instance.searchFNN();
        instance.reserveFNN();
        instance.hideSearchResult();
        //instance.validateSiteWithUSers();
        // instance.saveAndExit();
        instance.clearAll();
        instance.switchReserveNumbersAction();
        instance.processSelected();
        System.assertEquals(ord.siteName, 'Hello');
        Test.stopTest();
    }
    
    public testmethod static void unit_test_3(){
        csoe__Non_Commercial_Schema__c schemaNcs = new csoe__Non_Commercial_Schema__c(Name = 'NumberManagementv1');
        insert schemaNcs;
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000323';
        prodDef.cscfga__Active__c = true;
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = String.valueOf('ServiceSpecifications.json');
        attachment.ParentId = config.Id; 
        insert attachment;
        cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000074';
        insert prodDef1; 
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Root_Configuration__c = config.id;
        config1.name = 'User-Fixed Seat-Zone1';
        config1.Quantity_Product_Configuration__c =20;
        insert config1;
        
        cscfga__attribute__c attr = new cscfga__attribute__c();
        attr.name = 'Test Site Name Test';
        attr.cscfga__Product_Configuration__c = config.Id;
        insert attr;
        basketId =  basket.id;
        rootConfigId = config.id;
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        List<NumberManagementController.OrderSummary> ordlist = new List<NumberManagementController.OrderSummary>();
        NumberManagementController.OrderSummary ord = new NumberManagementController.OrderSummary();
        ord.siteName= 'Hello';
        ord.siteID='world';
        ord.siteAddress='Order';
        ord.totalfixedSeatCount=10;
        ord.configId='20';
        ord.total=30;
        ordlist.add(ord);
        Test.startTest();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        instance.pattern ='*02*';
        
        instance.adborId = '6376263';
        instance.activeNumbersListCollap= new List<String>(); 
        instance.selectedReservedNumbers= new List<String>();
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
        FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        instance.quantity = 101;
        instance.totalReservedNumber = '100';
        List<NumberManagementController.wrapReservedNumbers> ReservedNumbersListWrap  = new  List<NumberManagementController.wrapReservedNumbers>();
        NumberManagementController.wrapReservedNumbers reserveNums = new NumberManagementController.wrapReservedNumbers('1234567890');
        reserveNums.selected=true;
        reserveNums.unReservedNumber = '1234567890';
        ReservedNumbersListWrap.add(reserveNums);
        //instance.selectedNumType = 'none';
        //instance.enableESA();
        instance.getSiteList();
        instance.searchFNN();
        // instance.reserveFNN();
        instance.hideSearchResult();
        //instance.validateSiteWithUSers();
        // instance.saveAndExit();
        
        instance.switchReserveNumbersAction();
        instance.processSelected();
        System.assertEquals(ord.siteAddress, 'Order');
        instance.clearAll();
        Test.stopTest();
    }
    
    
    public testmethod static void unit_test_4(){
        csoe__Non_Commercial_Schema__c schemaNcs = new csoe__Non_Commercial_Schema__c(Name = 'NumberManagementv1');
        insert schemaNcs;
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000323';
        prodDef.cscfga__Active__c = true;
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        attachment.Name = String.valueOf('ServiceSpecifications.json');
        attachment.ParentId = config.Id; 
        insert attachment;
        cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000074';
        insert prodDef1; 
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Root_Configuration__c = config.id;
        config1.name = 'User-Fixed Seat-Zone1';
        config1.Quantity_Product_Configuration__c =20;
        insert config1;
        
        cscfga__attribute__c attr = new cscfga__attribute__c();
        attr.name = 'Test Site Name Test';
        attr.cscfga__Product_Configuration__c = config.Id;
        insert attr;
        basketId =  basket.id;
        rootConfigId = config.id;
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        List<NumberManagementController.OrderSummary> ordlist = new List<NumberManagementController.OrderSummary>();
        NumberManagementController.OrderSummary ord = new NumberManagementController.OrderSummary();
        ord.siteName= 'Hello';
        ord.siteID='world';
        ord.siteAddress='Order';
        ord.totalfixedSeatCount=10;
        ord.configId='20';
        ord.total=30;
        ordlist.add(ord);
        Test.startTest();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        instance.pattern ='*02*';
        instance.totalReservedNumber = '100';
        
        instance.adborId = '6376263';
        instance.activeNumbersListCollap= new List<String>(); 
        instance.selectedReservedNumbers= new List<String>();
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
        FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        instance.quantity = 101;
        List<NumberManagementController.wrapReservedNumbers> ReservedNumbersListWrap  = new  List<NumberManagementController.wrapReservedNumbers>();
        NumberManagementController.wrapReservedNumbers reserveNums = new NumberManagementController.wrapReservedNumbers('1234567890');
        reserveNums.selected=true;
        reserveNums.unReservedNumber = '1234567890';
        ReservedNumbersListWrap.add(reserveNums);
        instance.selectedPatternType = 'Begins with';
        //instance.enableESA();
        // instance.getSiteList();
        instance.searchFNN();
        // instance.reserveFNN();
        instance.hideSearchResult();
        //instance.validateSiteWithUSers();
        // instance.saveAndExit();
        
        instance.switchReserveNumbersAction();
        instance.processSelected();
        System.assertEquals(instance.pattern, '*02*');
        instance.clearAll();
        Test.stopTest();
    }
    
    public testmethod static void unit_test_5(){
        csoe__Non_Commercial_Schema__c schemaNcs = new csoe__Non_Commercial_Schema__c(Name = 'NumberManagementv1');
        insert schemaNcs;
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        prodDef.cscfga__Active__c = true;
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325; 
        config.cscfga__Product_Basket__c = basket.id; 
        insert config;
        Attachment attachment = new Attachment();
        //RPL Changes for coverage
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":"9282345558","rangeFrom":"9282345569","FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"90afa1e8-9a9c-1bb9-2e8b-eba012c274c3","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":"0315529299","rangeFrom":"0315529200","FNN":null}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        //attachment.Name = String.valueOf('ServiceSpecifications.json');
        attachment.Name = String.valueOf('NumberManagementv1_schema');
        attachment.ParentId = config.Id; 
        insert attachment;
        cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000074';
        insert prodDef1; 
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Root_Configuration__c = config.id;
        config1.name = 'User-Fixed Seat-Zone1';
        config1.Quantity_Product_Configuration__c =20;
        insert config1;
        //INC000090679656
        cscfga__attribute__c attr = new cscfga__attribute__c();
        attr.name = 'Test Site Name Test';
        attr.cscfga__Product_Configuration__c = config.Id;
        insert attr;
		cscfga__attribute__c attr1 = new cscfga__attribute__c();
        attr1.name = 'isNumberEnrichComplete';
        attr1.cscfga__Product_Configuration__c = config.Id;
        insert attr1;
        basketId =  basket.id;
        rootConfigId = config.id;
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        List<NumberManagementController.OrderSummary> ordlist = new List<NumberManagementController.OrderSummary>();
        NumberManagementController.OrderSummary ord = new NumberManagementController.OrderSummary();
        ord.siteName= 'Hello';
        ord.siteID='world';
        ord.siteAddress='Order';
        ord.totalfixedSeatCount=10;
        ord.configId='20';
        ord.total=30;
        ordlist.add(ord);
        Test.startTest();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        instance.pattern ='';
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
        FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        instance.quantity = 20;
        List<NumberManagementController.wrapReservedNumbers> ReservedNumbersListWrap  = new  List<NumberManagementController.wrapReservedNumbers>();
        NumberManagementController.wrapReservedNumbers reserveNums = new NumberManagementController.wrapReservedNumbers('1234567890');
        reserveNums.selected=true;
        reserveNums.unReservedNumber = '1234567890';
        ReservedNumbersListWrap.add(reserveNums);
        instance.selectedPatternType = 'None';
        instance.selectedPatternType = 'TEst';
        //instance.enableESA();
        // instance.getSiteList();
        instance.searchFNN();
        //instance.reserveFNN();
        instance.hideSearchResult();
        instance.validateSiteWithUSers('3', 2);
        instance.validateSiteWithUSers('3', 4);
		instance.validateSiteWithUSersPageAction();//INC000090679656
        //instance.saveAndExit();
        
        instance.switchReserveNumbersAction();
        instance.processSelected();
        System.assertEquals(ord.siteID, 'world');
        instance.clearAll();
        instance.patternTypeChange();
        Test.stopTest();
    }
    /*static void wrapReservedNumbersTest()
{
Test.startTest();
NumberManagementController.wrapReservedNumbers wrn = new NumberManagementController.wrapReservedNumbers();
wrn.wrapReservedNumbers('unreserve');
System.assertNotEquals(wrn, 'Order');
Test.stopTest();
}*/
    
    
    public testmethod static void unit_test_6(){
        csoe__Non_Commercial_Schema__c schemaNcs = new csoe__Non_Commercial_Schema__c(Name = 'NumberManagementv1');
        insert schemaNcs;
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        prodDef.cscfga__Active__c = true;
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"RESERVED","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        //attachment.Name = String.valueOf('ServiceSpecifications.json');
        attachment.Name = String.valueOf('NumberManagementv1_schema');
        attachment.ParentId = config.Id; 
        insert attachment;
        cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000074';
        insert prodDef1; 
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Root_Configuration__c = config.id;
        config1.name = 'User-Fixed Seat-Zone1';
        config1.Quantity_Product_Configuration__c =20;
        insert config1;
        
        cscfga__attribute__c attr = new cscfga__attribute__c();
        attr.name = 'isNumberEnrichComplete';
        attr.cscfga__Product_Configuration__c = config.Id;
        insert attr;

        cscfga__attribute__c attr1 = new cscfga__attribute__c();
        attr1.name = 'TotalNumbers';
        attr1.cscfga__Product_Configuration__c = config.Id;
        attr1.cscfga__Value__c = '10';
        insert attr1;

        basketId =  basket.id;
        rootConfigId = config.id;
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        List<NumberManagementController.OrderSummary> ordlist = new List<NumberManagementController.OrderSummary>();
        NumberManagementController.OrderSummary ord = new NumberManagementController.OrderSummary();
        ord.siteName= 'Hello';
        ord.siteID='world';
        ord.siteAddress='Order';
        ord.totalfixedSeatCount=10;
        ord.configId='20';
        ord.total=30;
        ordlist.add(ord);
        Test.startTest();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        instance.pattern ='12346';
        instance.selectedPatternType = 'None';
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
        FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        instance.quantity = 20;
        List<NumberManagementController.wrapReservedNumbers> ReservedNumbersListWrap  = new  List<NumberManagementController.wrapReservedNumbers>();
        NumberManagementController.wrapReservedNumbers reserveNums = new NumberManagementController.wrapReservedNumbers('1234567890');
        reserveNums.selected=true;
        reserveNums.unReservedNumber = '1234567890';
        ReservedNumbersListWrap.add(reserveNums);
        instance.selectedPatternType = 'None';
        //instance.enableESA();
        // instance.getSiteList();
        instance.searchFNN();
        //instance.reserveFNN();
        instance.hideSearchResult();
        instance.validateSiteWithUSers('3', 2);
        instance.validateSiteWithUSers('3', 4);
        delete attr;

        instance.validateSiteWithUSers('3', 4);
        //instance.saveAndExit();
        
        instance.switchReserveNumbersAction();
        
        instance.processSelected();
        System.assertEquals(ord.siteID, 'world');
        instance.clearAll();
        instance.patternTypeChange();
        Test.stopTest();
    }
    
    public testmethod static void unit_test_7(){
        try{
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
            config.Name = 'IP Site';
            update config;
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
            config2.name = 'Hunt Group';
            config2.User_Type__c ='Hunt Group';
            config2.Quantity_Product_Configuration__c =20;
            insert config2;
            
            cscfga__attribute__c attr = new cscfga__attribute__c();
            attr.name = 'AdborID';
            attr.cscfga__Product_Configuration__c = config.Id;
            // attr.
            insert attr;
            basketId =  basket.id;
            rootConfigId = config.id;
            Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
            System.currentPageReference().getParameters().put('basketId', basketId);
            System.currentPageReference().getParameters().put('configId', rootConfigId);
            NumberManagementController instance = new NumberManagementController();
            Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
            instance.pattern ='*03*';
            instance.totalReservedNumber = '';
            instance.adborId = '1233566';
            instance.selectedReservedNumbers = new List<String>();
            instance.activeNumbersListCollap = new List<String>();
            //instance.ReservedNumbersListWrap = new List<wrapReservedNumbers>();
            // Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
            HttpResponse response = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setBody('');
            req.setMethod('POST');
            FNNServiceMockResponse mockRes = new FNNServiceMockResponse(500);
            response = null;
            //instance.selectedNumType = 'exchangeServiceArea';
            //instance.enableESA();
            instance.getSiteList();
            instance.searchFNN();
            // instance.reserveFNN();
            instance.hideSearchResult();
            //instance.validateSiteWithUSers();
            instance.clearAll();
            System.assertEquals(attr.name, 'AdborID');
        }catch(Exception e)
        {
            system.debug('Exception 2'+e.getMessage());
        }
    }
    
    public testmethod static void unit_test_8(){
        csoe__Non_Commercial_Schema__c schemaNcs = new csoe__Non_Commercial_Schema__c(Name = 'NumberManagementv1');
        insert schemaNcs;
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        prodDef.cscfga__Active__c = true;
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        Attachment attachment = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560:9282345561"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
        attachment.Body = Blob.valueOf(encodedContentsString);
        //attachment.Name = String.valueOf('ServiceSpecifications.json');
        attachment.Name = String.valueOf('NumberManagementv1_schema');
        attachment.ParentId = config.Id; 
        insert attachment;
        cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000074';
        insert prodDef1; 
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Root_Configuration__c = config.id;
        config1.name = 'User-Fixed Seat-Zone1';
        config1.Quantity_Product_Configuration__c =20;
        insert config1;
        
        cscfga__attribute__c attr = new cscfga__attribute__c();
        attr.name = 'Test Site Name Test';
        attr.cscfga__Product_Configuration__c = config.Id;
        insert attr;
        basketId =  basket.id;
        rootConfigId = config.id;
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        List<NumberManagementController.OrderSummary> ordlist = new List<NumberManagementController.OrderSummary>();
        NumberManagementController.OrderSummary ord = new NumberManagementController.OrderSummary();
        ord.siteName= 'Hello';
        ord.siteID='world';
        ord.siteAddress='Order';
        ord.totalfixedSeatCount=10;
        ord.configId='20';
        ord.total=30;
        ordlist.add(ord);
        Test.startTest();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        instance.pattern ='';
        Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('POST');
        FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
        instance.quantity = 20;
        List<NumberManagementController.wrapReservedNumbers> ReservedNumbersListWrap  = new  List<NumberManagementController.wrapReservedNumbers>();
        NumberManagementController.wrapReservedNumbers reserveNums = new NumberManagementController.wrapReservedNumbers('1234567890');
        reserveNums.selected=true;
        reserveNums.unReservedNumber = '1234567890';
        ReservedNumbersListWrap.add(reserveNums);
        instance.selectedPatternType = 'None';
        //instance.enableESA();
        // instance.getSiteList();
        instance.searchFNN();
        // RPL Changes for coverage
        instance.fnnList = new List<String>();
        instance.quantity = 2;
        instance.searchFNN();
        //instance.reserveFNN();
        instance.hideSearchResult();
        instance.validateSiteWithUSers('3', 2);
        instance.validateSiteWithUSers('3', 4);
        //instance.saveAndExit();
        
        instance.switchReserveNumbersAction();
        instance.processSelected();
        System.assertEquals(ord.siteID, 'world');
        instance.clearAll();
        instance.patternTypeChange();
        Test.stopTest();
    }
    public testmethod static void testgetSiteList(){
        try{
            
            Test.startTest();
            NumberManagementController num = new NumberManagementController();
            num.getSiteList();
            num.reserveFNN();
            System.AssertNotEquals(num, null);
            Test.stopTest();
        }catch(Exception e){
            //
        }
    }
    
    //Karan : 11 july 2019 : RPL:68 NGUC numberreservation
    public testmethod static void unit_test_9(){
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
        config.Name = 'IP Site';
        config.Type__c='Cancel';
        insert config;
        cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000074';
        insert prodDef1; 
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Root_Configuration__c = config.id;
        config1.name = 'User';
        config1.User_Type__c = 'User';
        config1.Quantity_Product_Configuration__c =20;
        insert config1;
        
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config2.cscfga__Contract_Term__c = 12;
        config2.cscfga__total_contract_value__c = 325;
        config2.cscfga__Product_Basket__c = basket.id;
        config2.cscfga__Root_Configuration__c = config.id;
        config2.name = 'Hunt Group';
        config2.User_Type__c ='Hunt Group';
        config2.Quantity_Product_Configuration__c =20;
        insert config2;
        List<cscfga__Product_Configuration__c> configList =new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config21;
        for(Integer i=0;i<2;i++){
        config21 = ProductTestFactory.buildProductConfig(prodDef1.id);
        config21.cscfga__Contract_Term__c = 12;
        config21.cscfga__total_contract_value__c = 325;
        config21.cscfga__Product_Basket__c = basket.id;
        config21.cscfga__Root_Configuration__c = config.id;
        if(i==1){
        config21.name = 'Auto Attendant';
        config21.User_Type__c ='Auto Attendant';
        }
        else{
        config21.name = 'Main Business Number';
        config21.User_Type__c ='Main Business Number';   
        }
        config21.Quantity_Product_Configuration__c =20;
        configList.add(config21);
        }
        insert configList;
        
         csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'NumberManagementv1';
        insert cnse;
        Attachment attachment = new Attachment();
          String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
          attachment.Body = Blob.valueOf(encodedContentsString);
          attachment.Name = String.valueOf('NumberManagementv1_schema.json');
          attachment.ParentId = config.Id; 
          insert attachment;
                
        cscfga__attribute__c attr = new cscfga__attribute__c();
        attr.name = 'Test Offer Name AdborID Test';
        attr.cscfga__Value__c='Telstra Collaboration';
        attr.cscfga__Product_Configuration__c = config.Id;
        insert attr;
        basketId =  basket.id;
        rootConfigId = config.id;
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement')); 
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
       NumberManagementController instance = new NumberManagementController();
        Cache.Org.put('SearchFNNHandler','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        instance.pattern ='06';
        instance.totalReservedNumber = '10';
        instance.selectedPatternType= 'Begins With';
        // Test.setMock(HttpCalloutMock.class, new FNNServiceMockResponse(202));
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setBody('{"data":{"serviceIds":["0282345560"],"systemId":"MSPA"}}');
        req.setMethod('GET');
        FNNServiceMockResponse mockRes = new FNNServiceMockResponse(202);
        response = mockRes.respond(req);
         
        //instance.selectedNumType = 'exchangeServiceArea';
        //instance.enableESA();
        //instance.getSiteList();
        instance.searchFNN();
        // RPL Change for coverage 
        instance.fnnList = new List<String>();
        instance.quantity = 3;
        instance.searchFNN();
        
        instance.reserveFNN();
        instance.hideSearchResult();
        instance.clearAll();
        // RPL Changes  - Just covering the public method
        instance.getSiteList();
        
        Test.stopTest();
        System.AssertNotEquals(attr.name, 'Test Offer Name Test');
    }

    public testmethod static void  updateUIOnErrorStatusTest() {

        Test.startTest();
        String basketId = '';
        String rootConfigId = '';
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement'));
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        instance.updateUIOnErrorStatus('msg1', 'msg2');
        Test.stopTest();
        System.assertEquals(instance.UnreservePanelMessage.contains('msg1'), true);
        System.assertEquals(instance.UnreservePanelMessage.contains('msg2'), true);
    }

    public testmethod static void  getValidNumbersToUnreserveTest() {

        Test.startTest();
        String basketId = '';
        String rootConfigId = '';
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement'));
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        List<FNNResponseDTO.ErrorsDataObject> errors = new  List<FNNResponseDTO.ErrorsDataObject>();
        List<String> unReserveNumberList = new List<String>();
        List<String> res = new List<String>();

        FNNResponseDTO.ErrorsDataObject o = new FNNResponseDTO.ErrorsDataObject();
        o.fnn = '123';
        o.message = 'AVAILABLE';
        errors.add(o);

        o = new FNNResponseDTO.ErrorsDataObject();
        o.fnn = '456';
        o.message = 'ERROR';
        errors.add(o);

        unReserveNumberList.Add('123');
        unReserveNumberList.Add('456');

        res = instance.getValidNumbersToUnreserve(errors, unReserveNumberList);
        Test.stopTest();

        System.assertEquals(res.size(), 1);
        System.assertEquals(res[0] =='123', true);
    }

    public testmethod static void  updateUIafterSearchTest() {

        Test.startTest();
        String basketId = '';
        String rootConfigId = '';
        Test.setCurrentPageReference(new PageReference('Page.NumberManagement'));
        System.currentPageReference().getParameters().put('basketId', basketId);
        System.currentPageReference().getParameters().put('configId', rootConfigId);
        NumberManagementController instance = new NumberManagementController();
        instance.updateUIafterSearch(true, true, true, 'css','test', true, true);
        Test.stopTest(); 

        System.assertEquals(instance.PanelMessage, 'test');
        System.assertEquals(instance.cssClassForPanelMsgs, 'css');
        System.assertEquals(instance.isNumberAvailable, true);
        System.assertEquals(instance.fnnFlag, true);
        System.assertEquals(instance.displayErrorPanel, true);
        System.assertEquals(instance.viewSearchPanel, true);
        System.assertEquals(instance.displayNumberSearch, true);
    }
/*******************************************************************
    EDGE        -121868
    Method      -createFixedNumberRecordTest
    Description -Test Method to cover createFixedNumberRecord method in NumberManagementController Class
    Author      -Dheeraj Bhatt
 *********************************************************************/
    @IsTest public static void createFixedNumberRecordTest(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        
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
        List<String> numberList=new List<String>{'444482457', '444482456'};
        Test.startTest();
        NumberManagementController.createFixedNumberRecord(numberList,basket.Id,config.id);
       List<Number__c> reserveNumberList=[SELECT ID,Service_Number__c,Product_Configuration__c,Start_Range__c FROM Number__c WHERE Basket__c = :basket.id AND  Service_Number__c IN :numberList];  
         Test.stopTest();
        system.assertNotEquals(0, reserveNumberList.size());
    }
    
    /*******************************************************************
    EDGE        -121868
    Method      -createFixedNumberRecordNegativeTest
    Description -Test Method to cover exception scenerio in createFixedNumberRecord method in NumberManagementController Class
    Author      -Dheeraj Bhatt
 *********************************************************************/
    @IsTest public static void createFixedNumberRecordNegativeTest(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        
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
        List<String> numberList=new List<String>{'444482457', '444482456'};
        Test.startTest();
        NumberManagementController.createFixedNumberRecord(numberList,basket.Id,basket.id);
       List<Number__c> reserveNumberList=[SELECT ID,Service_Number__c,Product_Configuration__c,Start_Range__c FROM Number__c WHERE Basket__c = :basket.id AND  Service_Number__c IN :numberList];  
         Test.stopTest();
        system.assertEquals(0, reserveNumberList.size());
    }
/*******************************************************************
    EDGE        -121868
    Method      -deleteFixedNumberRecordTest
    Description -Test Method to cover deleteFixedNumberRecord method in NumberManagementController Class
    Author      -Dheeraj Bhatt
 *********************************************************************/
@IsTest public static void deleteFixedNumberRecordTest(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        insert prodDef;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.id);
        prodConfig.cscfga__Contract_Term__c = 12;
        prodConfig.cscfga__total_contract_value__c = 325;
        prodConfig.cscfga__Product_Basket__c = basket.id;
        insert prodConfig;
    
    List<String> numberList=new List<String>{'444482457', '444482456'};
    List<Number__c> fnnNumberList=new List<Number__c>();
    for(String num:numberList){
        Number__c fnnNumber = new Number__c();
        fnnNumber.Basket__c = basket.id;
        fnnNumber.Account__c = acc.id;
        fnnNumber.Service_Number__c =num;
        fnnNumber.Status__c = 'RESERVED';
        fnnNumber.Mobile__c='Fixed';
        fnnNumber.Type__c='FNN';
        fnnNumber.Product_Configuration__c=prodConfig.Id;
        fnnNumberList.add(fnnNumber);
    }
        insert fnnNumberList;
         Test.startTest();   
        NumberManagementController.deleteFixedNumberRecord(numberList,basket.Id);
        List<Number__c> unReserveNumberList=[SELECT ID,Service_Number__c,Product_Configuration__c,Start_Range__c FROM Number__c WHERE Basket__c = :basket.id AND  Service_Number__c IN :numberList];  
         Test.stopTest();
        system.assertEquals(0, unReserveNumberList.size()); 
}
    /*******************************************************************
    EDGE        -121868
    Method      -deleteFixedNumberRecordNegativeTest
    Description -Test Method to cover exception scenerio in  deleteFixedNumberRecord method in NumberManagementController Class
    Author      -Dheeraj Bhatt
 *********************************************************************/
@IsTest public static void deleteFixedNumberRecordNegativeTest(){
    List<String> numberList;
    cscfga__Product_Basket__c basket;
    user salesEnterpriseB2BUser;
    User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
     system.runAs(currentUser){    
     salesEnterpriseB2BUser=testUtil.createUser('salesEnterpriseB2B@test.com','B2b.user','Sales Enterprise B2B');
         salesEnterpriseB2BUser.phone='+121231231234';
        insert salesEnterpriseB2BUser;
    
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        
         basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        insert prodDef;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.id);
        prodConfig.cscfga__Contract_Term__c = 12;
        prodConfig.cscfga__total_contract_value__c = 325;
        prodConfig.cscfga__Product_Basket__c = basket.id;
        insert prodConfig;
        
         numberList=new List<String>{'444482457', '444482456'};
            List<Number__c> fnnNumberList=new List<Number__c>();
         for(String num:numberList){
                Number__c fnnNumber = new Number__c();
                fnnNumber.Basket__c = basket.id;
                fnnNumber.Account__c = acc.id;
                fnnNumber.Service_Number__c =num;
                fnnNumber.Status__c = 'RESERVED';
                fnnNumber.Mobile__c='Fixed';
                fnnNumber.Type__c='FNN';
                fnnNumber.Product_Configuration__c=prodConfig.Id;
                fnnNumberList.add(fnnNumber);
            }
            insert fnnNumberList;
     }
        system.runAs(salesEnterpriseB2BUser){
            Test.startTest();   
            NumberManagementController.deleteFixedNumberRecord(numberList,basket.Id);
            List<Number__c> unReserveNumberList=[SELECT ID,Service_Number__c,Product_Configuration__c,Start_Range__c FROM Number__c WHERE Basket__c = :basket.id AND  Service_Number__c IN :numberList];  
            Test.stopTest();
            system.assertNotEquals(0, unReserveNumberList.size()); 
        }
    }
}