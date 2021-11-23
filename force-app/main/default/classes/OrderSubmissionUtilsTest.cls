@isTest
public class OrderSubmissionUtilsTest {
    @isTest
    static void isBeforeFulfilmentActivityCompleteByBasket_emptyBasketIdTest() {
        Test.startTest();                
            List<String> inCompleteAttrList = OrderSubmissionUtils.isBeforeFulfilmentActivityCompleteByBasket(null, OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE);
            System.assert(inCompleteAttrList == null, 'Error: Enrichment completion evaluated incorrectly');
        Test.stopTest();        
    }

    @isTest
    static void isBeforeFulfilmentActivityCompleteByBasket_inCompleteTest() {
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Product Def1', 'Core Plan');
        insert prodDef;
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c(csordtelcoa__Change_Type__c = '', name = 'Test Basket');
        insert prodBasket;
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
        insert prodConfig;
        
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute(AllAttributeTriggerHelper.AMC_STATUS, '', prodConfig.Id);
        insert attr;
        cscfga__Attribute_Field__c attrFld = new cscfga__Attribute_Field__c(cscfga__Attribute__c = attr.Id, Name = OrderSubmissionUtils.REQ_FOR_ENRICHMENT_ATTR, 
                                                                            cscfga__Value__c = OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE);
        
        insert attrFld;
        Test.startTest();                
            List<String> inCompleteAttrList = new List<String>(OrderSubmissionUtils.isBeforeFulfilmentActivityCompleteByBasket(prodBasket.Id, OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE));
            System.assertEquals(inCompleteAttrList.size(), 1, 'Error: Enrichment completion evaluated incorrectly');
        Test.stopTest();
    }

    @isTest
    static void isBeforeFulfilmentActivityCompleteByBasket_completeTest() {
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Product Def1', 'Core Plan');
        insert prodDef;
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c(csordtelcoa__Change_Type__c = '', name = 'Test Basket');
        insert prodBasket;
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
        insert prodConfig;
        
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute(AllAttributeTriggerHelper.AMC_STATUS, 'Val', prodConfig.Id);
        insert attr;
        cscfga__Attribute_Field__c attrFld = new cscfga__Attribute_Field__c(cscfga__Attribute__c = attr.Id, Name = OrderSubmissionUtils.REQ_FOR_ENRICHMENT_ATTR, 
                                                                            cscfga__Value__c = OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE);
        
        insert attrFld;
        Test.startTest();                
            List<String> inCompleteAttrList = new List<String>(OrderSubmissionUtils.isBeforeFulfilmentActivityCompleteByBasket(prodBasket.Id, OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE));
            System.assertEquals(inCompleteAttrList.size(), 0, 'Error: Enrichment completion evaluated incorrectly');
        Test.stopTest();    
    }

    @isTest
    static void isBeforeFulfilmentActivityCompleteByOrder_emptyOrderIdTest() {
        Test.startTest();                
            List<String> inCompleteAttrList = OrderSubmissionUtils.isBeforeFulfilmentActivityCompleteByOrder(null, OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE);
            System.assert(inCompleteAttrList == null, 'Error: Enrichment completion evaluated incorrectly');
        Test.stopTest();        
    }
        
    @isTest
    static void isBeforeFulfilmentActivityCompleteByOrder_inCompleteTest() {
        Account acct = AccountTestFactory.buildAccount('Acct1');
        insert acct;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Product Def1', 'Core Plan');
        insert prodDef;
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c(csordtelcoa__Change_Type__c = '', name = 'Test Basket');
        insert prodBasket;
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
        insert prodConfig;
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute(AllAttributeTriggerHelper.AMC_STATUS, '', prodConfig.Id);
        insert attr;
        cscfga__Attribute_Field__c attrFld = new cscfga__Attribute_Field__c(cscfga__Attribute__c = attr.Id, Name = OrderSubmissionUtils.REQ_FOR_ENRICHMENT_ATTR, 
                                                                            cscfga__Value__c = OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE);        
        insert attrFld;
                
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acct.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestOrder', acct.id, ord.id, ordReq.id);
        insert subs;
        csord__Service__c ser = ProductTestFactory.buildService('TestOrder', ord.id, subs.id, ordReq.id);
        ser.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        insert ser;
        
        Test.startTest();                
            List<String> inCompleteAttrList = new List<String>(OrderSubmissionUtils.isBeforeFulfilmentActivityCompleteByOrder(ord.Id, OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE));
            System.assertEquals(inCompleteAttrList.size(), 1, 'Error: Enrichment completion evaluated incorrectly');
        Test.stopTest();
    }
    
    @isTest
    static void isBeforeFulfilmentActivityCompleteByOrder_completeTest() {
        Account acct = AccountTestFactory.buildAccount('Acct1');
        insert acct;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Product Def1', 'Core Plan');
        insert prodDef;
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c(csordtelcoa__Change_Type__c = '', name = 'Test Basket');
        insert prodBasket;
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
        insert prodConfig;
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute(AllAttributeTriggerHelper.AMC_STATUS, 'Val', prodConfig.Id);
        insert attr1;
        cscfga__Attribute_Field__c attrFld = new cscfga__Attribute_Field__c(cscfga__Attribute__c = attr1.Id, Name = OrderSubmissionUtils.REQ_FOR_ENRICHMENT_ATTR, 
                                                                            cscfga__Value__c = OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE);        
        insert attrFld;
        cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute(AllAttributeTriggerHelper.AMC_STATUS, '', prodConfig.Id);
        insert attr2;
                
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acct.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestOrder', acct.id, ord.id, ordReq.id);
        insert subs;
        csord__Service__c ser = ProductTestFactory.buildService('TestOrder', ord.id, subs.id, ordReq.id);
        ser.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        insert ser;
        
        Test.startTest();                
            List<String> inCompleteAttrList = new List<String>(OrderSubmissionUtils.isBeforeFulfilmentActivityCompleteByOrder(ord.Id, OrderSubmissionUtils.ENRICHMENT_ATTR_VALUE));
            System.assertEquals(inCompleteAttrList.size(), 0, 'Error: Enrichment completion evaluated incorrectly');
        Test.stopTest();
    }    
}