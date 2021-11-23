/*
* @Author   : Yash
* @Date     : 24/11/2020
* @Desc     : Test class for ProductPricingHandler
* @Jira     : EDGE-184433,EDGE-176688
*/
@isTest
public class ProductPricingHandlerTest {
    private void setupFA() {
        List<cscfga__Product_Definition__c> ngemPDList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c ngemPD = ProductTestFactory.buildProductDefinition('Test','Test');
        ngemPD.product_Specification__c='DMCAT_ProductSpecification_001211';
        ngemPDList.add(ngemPD);
        insert ngemPDList;


        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(ngemPDList[0].id);
        config.cscfga__Product_Definition__c = ngemPDList[0].id;
        config.name='APPLE IPAD 9.7 G6 32GB 4GX TABLET SPACE GREY';
        prodConfigList.add(config);
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(ngemPDList[0].id);
        config1.cscfga__Product_Definition__c = ngemPDList[0].id;
        config1.name='AM PLAN';
        prodConfigList.add(config1);
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(ngemPDList[0].id);
        config2.cscfga__Product_Definition__c = ngemPDList[0].id;
        config2.name='AM PLAN';
        prodConfigList.add(config2);
        insert prodConfigList;

        List<cscfga__Attribute_Definition__c> attDefList = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = ngemPDList[0].Id,
            Name = 'AD1'
        );
        attDefList.add(ad);
        insert attDefList;

        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[0].Id,
            Name = 'OC',
            cscfga__Value__c = '10.10',
            cscfga__Price__c = 10.10,
            cscfga__Is_Line_Item__c = true,
            cscfga__Recurring__c = false,
            cscfga__Is_rate_line_item__c = false,
            cscfga__is_active__c = true
        );
        attList.add(att);
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[0].Id,
            Name = 'RC',
            cscfga__Value__c = '20.20',
            cscfga__Price__c = 20.20,
            cscfga__Is_Line_Item__c = true,
            cscfga__Recurring__c = true,
            cscfga__Is_rate_line_item__c = false,
            cscfga__is_active__c = true
        );
        attList.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = prodConfigList[1].Id,
            Name = 'RC',
            cscfga__Value__c = '30.30',
            cscfga__Price__c = 30.30,
            cscfga__Is_Line_Item__c = true,
            cscfga__Recurring__c = true,
            cscfga__Is_rate_line_item__c = false,
            cscfga__is_active__c = true
        );
        attList.add(att2);
        insert attList;

        List<cspmb__Price_Item__c> piList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c pitem = new cspmb__Price_Item__c();
        pitem.Name = 'PaymentTypeLookup';
        pitem.cspmb__Contract_Term__c = '12';
        pitem.cspmb__Recurring_Charge__c = 75;
        pitem.cspmb__One_Off_Charge__c = 750;
        pitem.Unit_Of_Measure__c='per device';
        piList.add(pitem);
        insert piList;
        
        System.debug('***Telstra:ProductPricingHandlerTest:setupFA:prodConfigList '+prodConfigList);

    }

    @isTest 
    static void getPricingDetailsTestFA(){
        ProductPricingHandlerTest testclass= new ProductPricingHandlerTest();
        testclass.setupFA();
        List<cscfga__Product_Configuration__c> prodConfigList = [select id,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c  from cscfga__Product_Configuration__c];
        List<cspmb__Price_Item__c> piList =  [select id,cspmb__One_Off_Charge__c,cspmb__Recurring_Charge__c from cspmb__Price_Item__c];
        List<cscfga__Attribute__c> attList =  [select id,Name,cscfga__Value__c from cscfga__Attribute__c];
        System.debug('***Telstra:ProductPricingHandlerTest:getPricingDetailsTestFA:prodConfigList '+prodConfigList);
        System.debug('***Telstra:ProductPricingHandlerTest:getPricingDetailsTestFA:piList '+piList);
        Test.startTest();
        Decimal finalVal1 = ProductPricingHandler.getPricingDetails('Device',prodConfigList[0],piList[0],'OC');
        Decimal finalVal2 = ProductPricingHandler.getPricingDetails('Device',prodConfigList[0],attList[1],'RC');
        Decimal finalVal3 = ProductPricingHandler.getPricingDetails('Plan',prodConfigList[1],piList[0],'RC');
        Decimal finalVal4 = ProductPricingHandler.getPricingDetails('Device',prodConfigList[2],piList[0],'RC');
        Test.stopTest();

        system.debug('finalVal1@@::' + finalVal1);
        system.debug('finalVal2R@@::' + finalVal2);
        system.debug('finalVal3R@@::' + finalVal3);
        system.debug('finalVal4R@@::' + finalVal4);

        System.assert(finalVal1 == 10.10);
        System.assert(finalVal2 == 20.20);
        System.assert(finalVal3 == 30.30);
        System.assert(finalVal4 == 00.00);  //Negative Scenario
    }
    @isTest 
    static void amDeviceHROCheckTest(){
        ProductPricingHandlerTest testclass= new ProductPricingHandlerTest();
        testclass.setupFA();
        List<cscfga__Product_Configuration__c> prodConfigList = [select id,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,cscfga__Product_Definition__r.product_Specification__c,(SELECT Id, Name, cscfga__Value__c from cscfga__Attributes__r)  from cscfga__Product_Configuration__c];
        Test.startTest();
        Decimal finalVal1 = ProductPricingHandler.amDeviceHROCheck(prodConfigList[0]);
        Decimal finalVal2 = ProductPricingHandler.amDeviceHROCheck(prodConfigList[2]);
        Test.stopTest();
        
        system.debug('finalVal1@@::' + finalVal1);
        system.debug('finalVal2R@@::' + finalVal2);
        
        System.assert(finalVal1 == 20.20);
        System.assert(finalVal2 == 0.00); //Negative Scenario
        
    }
}