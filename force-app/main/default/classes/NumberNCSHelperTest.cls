/********************************************************************************************************************************
Class Name      :   NumberNCSHelper and ManageOrderNotificationServiceMSUpdate
Test Class     :   NumberNCSHelperTest
Change.No.    Developer Name        Date            Story        Description
1.            Gnana                 01/10/2020      EDGE-174174  Added test method
***********************************************************************************************************************************/
@isTest
public class NumberNCSHelperTest {
    
    @Testsetup
    static void dataSetup(){
        
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='EnableHV';
        csSite.value__c='True';
        insert csSite;
        
      EnvironmentVariable__c tokenCustomSetting = new EnvironmentVariable__c();         
      tokenCustomSetting.Name = 'EnableThrowException';        
       tokenCustomSetting.Value__c = 'false';        
      insert tokenCustomSetting; 
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        insert ordReq2;
        
        csord__Order__c ord1 = ProductTestFactory.buildOrder('Resume_12345', acc.id, 'Created', ordReq2.id);
        ord1.csord__Order_Request__c = ordReq2.Id;
        ord1.csordtelcoa__Opportunity__c = opp.Id;
        insert ord1;
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('Resume_123456', acc.id, 'Created', ordReq2.id);
        ord1.csord__Order_Request__c = ordReq2.Id;
        ord1.csordtelcoa__Opportunity__c = opp.Id;
        insert ord2;
        
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        csord__Subscription__c subRes=new csord__Subscription__c();
        subRes.name  = 'test sub12';
        subRes.csord__Identification__c = 'test identity12';
        subRes.csord__Order__c = ord1.Id;
        subRes.Sub_status__c = 'Active';
        subRes.csord__Status__c='Active';
        subList.add(subRes);
        
        csord__Subscription__c subRes2=new csord__Subscription__c();
        subRes2.name  = 'test sub122';
        subRes2.csord__Identification__c = 'test identity122';
        subRes2.csord__Order__c = ord2.Id;
        subRes2.Sub_status__c = 'Active';
        subRes2.csord__Status__c='Active';
        subList.add(subRes2);
        insert subList;
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        List<cscfga__Product_Configuration__c> lisOfPC = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        lisOfPC.add(userPC);
        cscfga__Product_Configuration__c userPC2 = new cscfga__Product_Configuration__c(Name = 'IP site2', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        lisOfPC.add(userPC2);
        insert lisOfPC;
                
        List<csord__Service__c> servs = new List<csord__Service__c>();
        
        csord__Service__c servRe = new csord__Service__c();
        servRe.name ='tst servRe';
        servRe.csord__Identification__c  = 'test servRe';
        servRe.csord__Subscription__c = subRes.Id;
        servRe.csord__Status__c = 'Service Created';
        servRe.csord__Order__c = ord1.Id;
        servRe.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(servRe);
        
        csord__Service__c servRe2 = new csord__Service__c();
        servRe2.name ='tst servRe 2';
        servRe2.csord__Identification__c  = 'test servRe 2';
        servRe2.csord__Subscription__c = subRes2.Id;
        servRe2.csord__Status__c = 'Service Created';
        servRe2.csord__Order__c = ord2.Id;
        servRe2.csordtelcoa__Product_Configuration__c = userPC2.id;
        servs.add(servRe2);
        
        insert servs;
        
        csord__Service__c serv = [select id,csordtelcoa__Service_Number__c from csord__Service__c where id =: servRe.Id limit 1];

        List<Number__c> listofNum = new List<Number__c>();
        Number__c num=new Number__c();
        num.name='Num test4';
        num.Subscription_number__c=subRes.csordtelcoa__Subscription_Number__c;
        num.Type__c='New';
        num.Service_Number__c='61474850547';
        num.Status__c='Provisioning In Progress';
        num.Product_ID__c='gb58-89jk-yuit-fr46';
        num.Service_Id__c = serv.csordtelcoa__Service_Number__c;
        listofNum.add(num);
        insert listofNum;
        
        csoe__Non_Commercial_Schema__c ncs= new csoe__Non_Commercial_Schema__c();
        ncs.Name='NumberManagementv1';
        ncs.csoe__Schema__c='{"attributes":[{"showInUI":true,"required":false,"type":"String","name":"FNN"},{"showInUI":true,"required":false,"type":"String","name":"rangeFrom"},{"showInUI":true,"required":false,"type":"String","name":"rangeTo"},{"showInUI":true,"required":false,"type":"String","name":"status"},{"showInUI":true,"required":false,"type":"String","name":"listCode"}],"name":"NumberManagementv1","description":"NumberManagementv1"}';
        ncs.csoe__Description__c='NumberManagementv1';
        
        insert ncs;
        
        List<Attachment> atts = new List<Attachment>();
        
        Attachment attRes = new Attachment();
        attRes.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRe.Id+'","legacyAttributes":[]}');
        attRes.Name = 'ServiceSpecifications.json';
        attRes.ParentId = servRe.Id;
        atts.add(attRes);
        
        Attachment attsNum = new Attachment();
        attsNum.Body = Blob.valueOf('{"schema":{"attributes":[{"type":"String","showInUI":true,"required":false,"name":"FNN"},{"type":"String","showInUI":true,"required":false,"name":"rangeFrom"},{"type":"String","showInUI":true,"required":false,"name":"rangeTo"},{"type":"String","showInUI":true,"required":false,"name":"status"},{"type":"String","showInUI":true,"required":false,"name":"listCode"}],"id":"a6k2O00000003LyQAI","name":"NumberManagementv1"},"configurations":[{"FNN":"61350605919","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line","guid":"a16035c5-7716-c099-4621-304572ae92fa"},{"FNN":"61350605920","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line","guid":"100ce120-77f7-2be3-7588-96eb3a5532da"}]}');
        attsNum.Name = 'NumberManagementv1.json';
        attsNum.ParentId = userPC.Id;
        atts.add(attsNum);
 
        insert atts;
        
        
    }
                                     
    public  static testmethod void unittest1(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
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
        csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'NumberManagementv1';
        insert cnse;
        Attachment attachment = new Attachment();
          String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
          attachment.Body = Blob.valueOf(encodedContentsString);
          attachment.Name = String.valueOf('NumberManagementv1_schema.json');
          attachment.ParentId = config.Id; 
          insert attachment;
       List<NumberNCSDTO.Configuration> numberList = new List<NumberNCSDTO.Configuration>();
       NumberNCSDTO ncsdt=  NumberNCSDTO.parse(encodedContentsString);
        System.debug(ncsdt);
        numberList.addAll(ncsdt.configurations);
        NumberNCSHelper ncsHelp = new NumberNCSHelper();
        ncsHelp.checkForExistingNCS(config.id);
        ncsHelp.getNumbersFromNCS(config.Id);
        ncsHelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList);
        ncsHelp.createNewNCS(config.Id, 'NumberManagementV1',numberList);
        ncsHelp.getTotalCountOfNumbers(config.Id);
        ncsHelp.populateConfigListToUpsert(numberList);
        ncsHelp.updateNCSForStatus(config.Id);
        ncshelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList,cnse);
        ncsHelp.createNewNCS(config.Id, 'NumberManagementV1',numberList,cnse);
        System.assertEquals(ncsHelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList),'Success');
        //EDGE-90967 start
        Map<String,List<NumberNCSDTO.Configuration>> configIdToNumberList = new Map<String,List<NumberNCSDTO.Configuration>>();
        configIdToNumberList.put(config.Id, numberList);
        System.assertEquals(ncsHelp.updateExistingNCSbulk(new List<String>{config.Id},'NumberManagementV1',configIdToNumberList),'Success');
        //EDGE-90967 end

    }
    
    
        public  static testmethod void unittest2(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductSpecification_000087';
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'NumberManagementv1';
        insert cnse;
        Attachment attachment = new Attachment();
          String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
          attachment.Body = Blob.valueOf(encodedContentsString);
          attachment.Name = String.valueOf('NumberManagementv1_schema.json');
          attachment.ParentId = config.Id; 
          insert attachment;
       List<NumberNCSDTO.Configuration> numberList = new List<NumberNCSDTO.Configuration>();
       NumberNCSDTO ncsdt=  NumberNCSDTO.parse(encodedContentsString);
        System.debug(ncsdt);
        numberList.addAll(ncsdt.configurations);
        NumberNCSHelper ncsHelp = new NumberNCSHelper();
        ncsHelp.checkForExistingNCS(basket.id);
        ncsHelp.getNumbersFromNCS(config.Id);
        ncsHelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList);
        ncsHelp.createNewNCS(config.Id, 'NumberManagementV1',numberList);
        ncsHelp.getTotalCountOfNumbers(config.Id);
        ncsHelp.populateConfigListToUpsert(numberList);
        ncsHelp.updateNCSForStatus(config.Id);
        ncshelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList,cnse);
        ncsHelp.createNewNCS(config.Id, 'NumberManagementV1',numberList,cnse);
        System.assertEquals(ncsHelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList),'Success');
    }
    
     public  static testmethod void unittest3(){
        Account acc = new Account(Name = 'Burlington');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        insert basket;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductSpecification_000087';
        insert prodDef;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c = basket.id;
        insert config;
        csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
        cnse.name = 'NumberManagementv1';
        insert cnse;
        Attachment attachment = new Attachment();
          String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"RESERVED","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
          attachment.Body = Blob.valueOf(encodedContentsString);
          attachment.Name = String.valueOf('NumberManagementv1_schema.json');
          attachment.ParentId = config.Id; 
          insert attachment;
       List<NumberNCSDTO.Configuration> numberList = new List<NumberNCSDTO.Configuration>();
       NumberNCSDTO ncsdt=  NumberNCSDTO.parse(encodedContentsString);
        //System.debug(ncsdt);
        numberList.addAll(ncsdt.configurations);
        List<String> deleteList = new List<String>();
        deleteList.add('7282345560');
        deleteList.add('9282345560');
         //Story: EDGE-100660; Author: Ila
         Map<Id, List<String>> pcToNumList = new Map<Id, List<String>>();
         pcToNumList.put(config.Id,deleteList);
        NumberNCSHelper ncsHelp = new NumberNCSHelper();
        ncsHelp.checkForExistingNCS(basket.id);
        ncsHelp.getNumbersFromNCS(config.Id);
        ncsHelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList);
        ncsHelp.createNewNCS(config.Id, 'NumberManagementV1',numberList);
        ncsHelp.getTotalCountOfNumbers(config.Id);
        ncsHelp.populateConfigListToUpsert(numberList);
        ncsHelp.updateNCSForStatus(config.Id);
        ncshelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList,cnse);
        ncsHelp.createNewNCS(config.Id, 'NumberManagementV1',numberList,cnse);
        ncsHelp.deleteExistingNCS(config.Id,deleteList);
         //Story: EDGE-100660; Author: Ila
        ncsHelp.deleteExistingNCSMultiplePC(pcToNumList);
        System.assertEquals(ncsHelp.updateExistingNCS(config.Id,'NumberManagementV1',numberList),'Success');
    }
    
    public static testmethod void unittest4(){
         Account acc = new Account(Name = 'Burlington');
        insert acc;
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
          String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"IN TRANSITION","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
          attachment.Body = Blob.valueOf(encodedContentsString);
          attachment.Name = String.valueOf('MobileNumberManagementv1_schema.json');
          attachment.ParentId = config.Id; 
          insert attachment;
        String guid= '746e220b-e219-f6d6-7c53-3827bb97bc1d';
        NumberNCSHelper.fetchNumberUsingGUID(config.Id, guid);
        System.assertNotEquals(null,guid);
    }
    
    @IsTest
    public static void testGetNumbersforBDS()
    {
        Test.startTest();
        EnvironmentVariable__c env_var =  new EnvironmentVariable__c();
        env_var.name = 'EnableB2B4';
        env_var.value__c = 'true';
        insert env_var;

        EnvironmentVariable__c env_var2=  new EnvironmentVariable__c();
            env_var2.name='ValidationIPUCE';
            env_var2.value__c='1';
            insert env_var2;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
            insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
            insert prod;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        List<PricebookEntry> testpbeList = new List<PricebookEntry>{standardPBE, pbe};
        insert testpbeList;

        Account acc = new Account(Name = 'Test Account');
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        insert billingAccount;

        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);

        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.Project_ID__c = 'testAc01';
        basket.Billing_Account__c = billingAccount.id;
        basket.Project_Manager_Contact_Number__c = '0999999999';
        basket.Project_Complexity__c = 'Complex';
        basket.PM_Required__c = false;
        basket.cscfga__Opportunity__c = opp.Id;
        update basket;

        cscfga__Product_Definition__c IPsite = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Network');
        insert IPsite;

        cscfga__Product_Configuration__c IPSitePC = new cscfga__Product_Configuration__c(
            Name = 'IP Site', cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c = IPSite.Id,
            csedm__CFS_Mapping_List__c = 'TestSpec'
        );
        insert IPSitePC;

        cscfga__Product_Configuration__c IPSitePC2 = new cscfga__Product_Configuration__c(
            Name = 'IP Site 2', cscfga__Product_Basket__c = basket.Id,
            cscfga__Product_Definition__c = IPSite.Id,
            csedm__CFS_Mapping_List__c = 'TestSpec',
            csordtelcoa__Replaced_Product_Configuration__c = IPSitePC.Id
        );
        insert IPSitePC2;

        Attachment attachment = new Attachment();
          String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
          attachment.Body = Blob.valueOf(encodedContentsString);
          attachment.Name = String.valueOf('NumberManagementv1_schema.json');
          attachment.ParentId = IPSitePC.Id; 
          insert attachment;

        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'testSubscription2';
        testSubscription2.csord__Identification__c = 'TestValue2';
        testSubscription2.csordtelcoa__Product_Configuration__c = IPSitePC2.Id;
        insert testSubscription2;
        
        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'testSubscription3';
        testSubscription3.csord__Identification__c = 'TestValue3';
        testSubscription3.csordtelcoa__Product_Configuration__c = IPSitePC.Id;
        insert testSubscription3;

        csord__Service__c testService2 = new csord__Service__c();
        testService2.Name = 'testService2';
        testService2.csord__Status__c = 'Success';
        testService2.csord__Subscription__c = testSubscription2.Id;
        testService2.csord__Identification__c = 'TestValue2';
        testService2.csordtelcoa__Product_Configuration__c = IPSitePC2.Id;
        testService2.csordtelcoa__Service_Number__c = 'SVC-000011210';
        insert testService2;
        
        List<csord__Service__c> serviceListForSerNum = [Select Id,csordtelcoa__Product_Configuration__c, csordtelcoa__Service_Number__c, createddate from csord__Service__c LIMIT 1];

        String srvNumber = serviceListForSerNum[0].csordtelcoa__Service_Number__c;
        Set<String> res = new Set<String>();
        NumberNCSHelper ncsHelp = new NumberNCSHelper();

        List<csord__Service__c> serviceList = [Select Id,csordtelcoa__Product_Configuration__c, csordtelcoa__Service_Number__c, createddate from csord__Service__c where csordtelcoa__Service_Number__c =:srvNumber];
        List<csord__Service__c> serviceList2 = [Select Id,csordtelcoa__Product_Configuration__c, csordtelcoa__Service_Number__c, createddate from csord__Service__c];
        System.debug('NumberNCSHelperTest serviceList: ' + serviceList);
        System.debug('NumberNCSHelperTest serviceList2: ' + serviceList2);

        res = ncsHelp.getNumbersforBDS(srvNumber);
        Test.stopTest();
        System.assertNotEquals(null, res);
    }

    @isTest
    public static void testGetNumbersforBDSInvalidSerNum()
    {
        String srvNumber = 'test';
        Set<String> res = new Set<String>();
        NumberNCSHelper ncsHelp = new NumberNCSHelper();
        Test.startTest();
        res = ncsHelp.getNumbersforBDS(srvNumber);
        Test.stopTest();

        System.assertEquals(null, res);
    }

    @isTest
    public static void testDeleteExistingNCSInvalidInput()
    {
        NumberNCSHelper ncsHelp = new NumberNCSHelper();
        Test.startTest();
        String res = ncsHelp.DeleteExistingNCS(null,null);
        Test.stopTest();

        System.assertEquals('Success',res);
    }

    @isTest
    public static void testFetchNCSInstanceInvalidInput()
    {
        NumberNCSHelper ncsHelp = new NumberNCSHelper();
        Test.startTest();
        csoe__Non_Commercial_Schema__c res = ncsHelp.fetchNCSInstance(null);
        Test.stopTest();

        System.assertEquals(null, res);
    }

    @isTest
    public static void testUpdateExistingNCSInvalidInput()
    {
        NumberNCSHelper ncsHelp = new NumberNCSHelper();
        Test.startTest();
        String res = ncsHelp.updateExistingNCS(null,null,null,null);
        Test.stopTest();

        System.assertEquals('Failure', res);
    }

    //EDGE-90967
    @isTest
    public static void testUpdateExistingNCSbulkInvalidInput()
    {
        NumberNCSHelper ncsHelp = new NumberNCSHelper();
        Test.startTest();
        String res = ncsHelp.updateExistingNCSbulk(null,null,null);
        Test.stopTest();

        System.assertEquals('Failure', res);
    }
    
    // EDGE-174174 Added test method
    @isTest
    static void testprocessNotificationRecordMSComplete(){
        List<NotificationParameters>paramsList = new List<NotificationParameters>();
        Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
        
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' AND csord__Order__r.Name= 'Resume_12345' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'Resume_12345' limit 1][0];
        
        Test.startTest();
        NotificationParameters  notif = new NotificationParameters();
        notif.externalOrderId = ord.csord__Order_Number__c;
        notif.eventTimestamp = '2018-02-24T06:08+10:00';
        notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes = '"attributes":[{"name":"status","value":"Complete"}]';
        notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
        notif.eventType = 'statusNotification';
        notif.orderItemVersion = 1;
        notif.sourceSystem = 'FULFILMENT';
        paramsList.add(notif);
        orderItemIdNotifMap.put(notif.orderItemId,paramsList);
        
        ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
        Test.stopTest();
        Number__c num =[select id,status__c from Number__c where name = 'Num test4' limit 1];
        System.debug('number status...'+num.status__c);
        System.assertEquals('Provisioned', num.status__c);
    }
}