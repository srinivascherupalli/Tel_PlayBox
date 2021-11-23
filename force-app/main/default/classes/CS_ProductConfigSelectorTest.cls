/*************************************************************************************************
Name : CS_ProductConfigSelectortor
Test class:CS_ProductConfigSelectorTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Ankit Goswami     19/11/2020     EDGE-178204:External ID & Order Type Framework
===============================================================================================================================
***************************************************************************************************/
@isTest
public class CS_ProductConfigSelectorTest {
    
    @testSetup
    static void testdata(){

        Account testAccount = AccountTestFactory.buildAccount ('testAccount');
        RecordType recType = [Select id, name From RecordType Where sObjectType = 'Account' and Name = 'Partner'];
        testAccount.RecordTypeID = recType.id;
        insert testAccount;
        
        Opportunity testOpp = ProductTestFactory.getOpportunityBasic (testAccount);
        testOpp.Account = testAccount;
        testOpp.Product_Type__c = 'Modular';
        insert testOpp;

        cscfga__Product_Basket__c testBasket = ProductTestFactory.buildEmptyBasket();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
        pd1.Name = 'IP Network';
        pd1.cscfga__Description__c = 'Description';
        insert pd1;
       
        List <cscfga__Product_Configuration__c> listTestConfig = new List <cscfga__Product_Configuration__c>();
 
        cscfga__Product_Configuration__c testConfig = ProductTestFactory.buildProductConfig (pd1.id );
        testConfig.Name = 'IP Network1';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Family__c = 'Modular';
        testConfig.Quantity_Product_Configuration__c = 1;
        testConfig.cscfga__Contract_Term__c = 12;
        testConfig.cscfga__Product_Definition__c =pd1.id ;
        testConfig.Quantity_Product_Configuration__c = 6;
        testConfig.cscfga__discounts__c = '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        testConfig.cscfga__total_recurring_charge__c = 100;
        testConfig.cscfga__total_one_off_charge__c = 10;
        listTestConfig.add (testConfig);
    
        cscfga__Product_Configuration__c testConfigCancel = ProductTestFactory.buildProductConfig (pd1.id );
        testConfigCancel.Name = 'IP Network';
        testConfigCancel.cscfga__Product_Basket__c = testBasket.Id;
        testConfigCancel.cscfga__Product_Family__c = 'Modular';
        testConfigCancel.Quantity_Product_Configuration__c = 1;
        testConfigCancel.cscfga__Contract_Term__c = 12;
        testConfigCancel.Type__c ='Cancel';
        testConfigCancel.cscfga__discounts__c = '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        testConfigCancel.Quantity_Product_Configuration__c = 6;
        testConfig.cscfga__total_recurring_charge__c = 100;
        testConfig.cscfga__total_one_off_charge__c = 10;
        listTestConfig.add (testConfigCancel);

        insert listTestConfig;
           
      
        List <cscfga__Attribute__c> listTestAttribute = new List <cscfga__Attribute__c>();

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'EarlyTerminationCharge';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        testAttribute.cscfga__Is_Line_Item__c = true;
        testAttribute.cscfga__is_active__c = true;
        testAttribute.cscfga__Line_Item_Description__c = 'Test';        
        testAttribute.cscfga__Recurring__c = true;
        testAttribute.cscfga__Price__c = 100;
        listTestAttribute.add (testAttribute); 

        cscfga__Attribute__c testChargeAttribute = new cscfga__Attribute__c();
        testChargeAttribute.Name = 'RC';
        testChargeAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        testChargeAttribute.cscfga__Is_Line_Item__c = true;
        testChargeAttribute.cscfga__is_active__c = true;
        testChargeAttribute.cscfga__Line_Item_Description__c = 'Test';        
        testChargeAttribute.cscfga__Recurring__c = true;
        testChargeAttribute.cscfga__Price__c = 59.09;
        testChargeAttribute.cscfga__Value__c = '59.09';
        testChargeAttribute.cscfga__List_Price__c = 59.09;
        testChargeAttribute.cscfga__Discount_Type__c = 'amount';

        
        listTestAttribute.add (testChargeAttribute); 
    
        cscfga__Attribute__c testAttributeETC =  ProductTestFactory.buildPriceAttribute ('ETCCancel','100',testConfigCancel.Id,true,100); 
        testAttributeETC.cscfga__Is_Line_Item__c = true;
        testAttributeETC.cscfga__is_active__c = true;
        testAttributeETC.cscfga__Line_Item_Description__c = 'Test Cancel';        
       
        listTestAttribute.add (testAttributeETC);
        insert listTestAttribute; 
        
        List<cscfga__Attribute_Field__c> attrFieldList= new  List<cscfga__Attribute_Field__c>();
        cscfga__Attribute_Field__c attrField=new cscfga__Attribute_Field__c();
        attrField.name ='IncrementalRevenue';
        attrField.cscfga__Attribute__c=testAttribute.id;
        attrField.cscfga__Value__c='0';
        attrFieldList.add(attrField);
        
        cscfga__Attribute_Field__c attrField1=new cscfga__Attribute_Field__c();
        attrField1.name ='TechTransRevenue';
        attrField1.cscfga__Attribute__c=testAttributeETC.id;
        attrField1.cscfga__Value__c='0';
        attrFieldList.add(attrField1);
        insert attrFieldList;
        
        Product2 prodct2=new Product2();
        prodct2.Family='Modular'; 
        prodct2.IsActive=true;
        prodct2.Name='Test';
        prodct2.ProductCode='test';
        insert prodct2;
         

    }
     @isTest
    public static void getSObjectFieldListTest(){
        CS_ProductConfigSelector sObjectTestList = new CS_ProductConfigSelector();
        test.startTest();
         List<Schema.SObjectField> listOfAccountIdParentAccountId = sObjectTestList.getSObjectFieldList();
        System.assertNotEquals(NULL, listOfAccountIdParentAccountId);
        test.stopTest();
    }
    
    @isTest
    public static void getSObjectTypeTest(){
        CS_ProductConfigSelector sObjectTestList1 = new CS_ProductConfigSelector();
        test.startTest();
        Schema.sObjectType testSchemaType = sObjectTestList1.getSObjectType();
        System.assertNotEquals(NULL, testSchemaType);
        test.stopTest();
    }
    
    @isTest
    public static void selectByIdTest(){
        CS_ProductConfigSelector sObjectTestList2 = new CS_ProductConfigSelector();
        set<id>productBasketIdSet=new set<id>();
        list<string>fieldList=new list<string>();
        list<cscfga__Product_Basket__c> productBasketIdList=[select id from cscfga__Product_Basket__c];
        for(cscfga__Product_Basket__c proBas: productBasketIdList){
         productBasketIdset.add(proBas.id);
        }
        test.startTest();
        list<cscfga__Product_Configuration__c> testAttributeList = sObjectTestList2.selectById(productBasketIdset);
        sObjectTestList2.setFieldsToQuery(fieldList);
         System.assertNotEquals(true, !testAttributeList.isEmpty());
        test.stopTest();
    }
    
}