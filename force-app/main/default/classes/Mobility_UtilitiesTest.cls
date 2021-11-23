/*
* @Desc : Mobility Utility Test Class
* @Jira : DIGI-518
*/
@isTest
public class Mobility_UtilitiesTest {
    private void setup() { 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506340';
        billAcc.Account__c = acc.id;
        insert billAcc;
        
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('ProductDefTest', 'CoreTestPlan');
        prodDef.product_Specification__c='TestSpec';
        prodDef.name = 'AD1Test';
        insert prodDef;
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.Name = 'test order';
        ord.csord__Status2__c = 'Pending';
        insert ord;
        
        csord__Order__c ord1 = new csord__Order__c();
        ord1.csord__Identification__c = 'test identification1';
        ord1.Name = 'test order1';
        ord1.csord__Status2__c = 'Pending';
        insert ord1;
        
        Marketable_Offer__c moNGEM = new Marketable_Offer__c();
        moNGEM.OfferDefinationName__c ='Next Generation Enterprise Mobility';
        moNGEM.Name = 'Next Generation Plan';
        moNGEM.Offer_ID__c = 'DMCAT_Offer_001233';
        insert moNGEM;
        
        Marketable_Offer__c moNGEM1 = new Marketable_Offer__c();
        moNGEM1.OfferDefinationName__c ='Next Generation Enterprise Mobility1';
        moNGEM1.Name = 'CWP Mobility';
        moNGEM1.Offer_ID__c = 'DMCAT_Offer_0012331';
        insert moNGEM1;
        
        cscfga__Configuration_Offer__c offerDef = new cscfga__Configuration_Offer__c();
        offerDef.Name = 'CWP Mobility';
        offerDef.cscfga__Active__c=true;
        offerDef.cscfga__Description__c ='Description';
        insert offerDef;
        
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='CWP Mobility' ;
        moMob.Name = 'CWP Mobility';
        moMob.Offer_ID__c = 'CWP Mobility';
        insert moMob;
        
        cscfga__Product_Configuration__c prodConfig1 = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig1.cscfga__Product_Basket__c = basket.Id;        
        insert prodConfig1;
        
        cscfga__Product_Configuration__c newConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        newConfig.name='IP Site';
        newConfig.Type__c = 'Cancel';
        newConfig.cscfga__Product_Basket__c = basket.id;
        newConfig.cscfga__Product_Family__c='Mobility';
        newConfig.cscfga__unit_recurring_charge__c = 200;
        newConfig.Quantity_Product_Configuration__c =1;
        newConfig.cscfga__Product_Definition__c = prodDef.Id;
        newConfig.cscfga__unit_one_off_charge__c = 1;
       // newConfig.cscfga__Parent_Configuration__c = prodconfig1.id;
       // newConfig.Offer_Reference__c = offerDef.Id;
       // newConfig.OfferName__c = 'CWP Mobility';
       // newConfig.csordtelcoa__Replaced_Subscription__c = subs.id;
        newConfig.cscfga__Configuration_Offer__c = offerDef.id;
        insert newConfig;
        
        csord__Subscription__c subs = new csord__Subscription__c();
        subs.name  = 'Connected Workplace';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        subs.csord__Order__c = ord.id;
        subs.csordtelcoa__Product_Configuration__c = newConfig.id;
        subs.MarketableOffer__c = moNGEM.id;
        subs.Billing_Account__c = billAcc.id;
        subs.Right_to_Bill_Date__c = Datetime.now();

        insert subs; 
        csord__Subscription__c subs1 = new csord__Subscription__c();
        subs1.name  = 'Test subs1';
        subs1.csord__Identification__c = 'test identity';
        subs1.csord__Status__c = 'Pending';
        subs1.csord__Order__c = ord1.id;
        subs1.csordtelcoa__Product_Configuration__c = newConfig.id;
        subs1.MarketableOffer__c = moNGEM1.id;
        subs1.Billing_Account__c = billAcc.id;
        subs1.Right_to_Bill_Date__c = Datetime.now();
        insert subs1; 
        
        newConfig.csordtelcoa__Replaced_Subscription__c = subs.id;
        update newConfig;
        
        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = prodDef.Id,
            Name = 'AD1Test',
            Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Recurring_Charges',
            Snapshot_Attribute_Fields__c = 'Device'
        );
        insert ad1;
        
        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = prodDef.Id,
            Name = 'AD1Test',
            Snapshot_Attribute_Value_Field__c = 'Product_Module_Name',
            Snapshot_Attribute_Fields__c = 'Plan'
        );
        insert ad2;
        
        cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = prodDef.Id,
            Name = 'AD1Test',
            Snapshot_Attribute_Value_Field__c = 'Product_Module_Name',
            Snapshot_Attribute_Fields__c = 'MessageBank'
        );
        insert ad3;
        
        cscfga__Attribute_Definition__c ad4 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = prodDef.Id,
            Name = 'AD1Test',
            Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Onceoff_Charges',
            Snapshot_Attribute_Fields__c = 'Device'
        );
        insert ad4;
        
        cscfga__Attribute__c attr=new cscfga__Attribute__c();
        attr.name='Device Model';
        attr.cscfga__Product_Configuration__c = newConfig.Id;
        attr.cscfga__Value__c='1234';
        attr.cscfga__is_active__c = true;
        attr.cscfga__Attribute_Definition__c = ad1.Id;
        insert attr;
        
        cscfga__Attribute__c attr1=new cscfga__Attribute__c();
        attr1.name='TenancyID';
        attr1.cscfga__Product_Configuration__c = newConfig.Id;
        attr1.cscfga__Value__c='1234';
        attr1.cscfga__is_active__c = true;
        attr1.cscfga__Attribute_Definition__c = ad2.Id;
        insert attr1;
        
        cscfga__Attribute__c attr2=new cscfga__Attribute__c();
        attr2.name='TenancyID';
        attr2.cscfga__Product_Configuration__c = newConfig.Id;
        attr2.cscfga__Value__c='1234';
        attr2.cscfga__is_active__c = true;
        attr2.cscfga__Attribute_Definition__c = ad3.Id;
        insert attr2;
        
        cscfga__Attribute__c attr3=new cscfga__Attribute__c();
        attr3.name='TenancyID';
        attr3.cscfga__Product_Configuration__c = newConfig.Id;
        attr3.cscfga__Value__c='1234';
        attr3.cscfga__is_active__c = true;
        attr3.cscfga__Attribute_Definition__c = ad4.Id;
        insert attr3;
        
        Legacy_Service__c legSrvc = new Legacy_Service__c();
        legSrvc.Product_Basket__c = basket.id;
        legSrvc.Product_Type__c = 'Enterprise Mobility';
        legSrvc.Select__c = TRUE;
        legSrvc.Plan_Name__c = 'LegacyAMPlan';
        insert legSrvc;
        
        Service_Add_On__c ser1 = new Service_Add_On__c();
        ser1.Device_Description__c = 'IPhone 6';
        ser1.Monthly_Amount__c = 10.00;
        ser1.Residual_Remaining_Term__c =2;
        ser1.Legacy_Service__c =  legSrvc.Id;
        insert ser1;
        
    }
     
    @isTest static void getMobilityTypeProducts_Test() {
        
        ProductBasketDataHandler testclass= new ProductBasketDataHandler();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();        
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        Mobility_Utilities handler = new Mobility_Utilities();
        List<Map<String,Object>> rows = handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Devices', 'Type'=>'Recurring Charges'});
        rows.addAll(handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Mobile Services', 'Type'=>'Recurring Charges'}));
        //rows.addAll(handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Mobile Services', 'Type'=>'Recurring Charges'}));
        //List<Map<String,Object>> rows1 = handler.getMobilityTypeProducts(basketId,new Map<String,String>{'Order_Type'=>'Mobile Services', 'Type'=>'Recurring Charges'});
        List<Map<String,Object>> rows2 = handler.getMobilityTypeProducts(null,null);
		Test.stopTest();
        System.assert(rows.isEmpty() == false);
    }
    
    @isTest static void getMobilityCancelTypeProducts_Test() {
        //Mobility_UtilitiesTest testclass= new Mobility_UtilitiesTest();
        ProductBasketDataHandler testhandler= new ProductBasketDataHandler();
		RF_ProductBasketDataTestFactory testclass = new RF_ProductBasketDataTestFactory();
        testclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        Mobility_Utilities handler = new Mobility_Utilities();        
        List<Map<String,Object>> rows = handler.getMobilityCancelTypeProducts(basketId);
        List<Map<String,Object>> rows1 = handler.getMobilityCancelTypeProducts(null);
        Test.stopTest();
        System.assert(rows.isEmpty() == false );
    }
    
    @isTest static void getMobilityTransitionHardwareAndDevice_test(){//EDGE-175105
       RF_ProductBasketDataTestFactory testclass = new RF_ProductBasketDataTestFactory();
        ProductBasketDataHandler testhandler= new ProductBasketDataHandler();
        testclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        Mobility_Utilities handler = new Mobility_Utilities();
        List<Map<String,Object>> rows = handler.getMobilityTransitionHardwareAndDevice(basketId,new Map<String,String>{'Query_Type'=>'MobilityTransitionHardwareAndDevice'});
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
    } 
    
    @isTest static void getBSMobilityTransitionTest(){//EDGE-173365
        ProductBasketDataHandler testclass= new ProductBasketDataHandler();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        Mobility_Utilities handler = new Mobility_Utilities();
        List<Map<String,Object>> rows = handler.getBSMobilityTransition(basketId);
        List<Map<String,Object>> rows1 = handler.getBSMobilityTransition(null);
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
    }
    
    @isTest static void getCancelTypeProducts_Test() {
        ProductBasketDataHandler testclass= new ProductBasketDataHandler();
        RF_ProductBasketDataTestFactory rftestclass= new RF_ProductBasketDataTestFactory();
        rftestclass.setupdata();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        Mobility_Utilities handler = new Mobility_Utilities();
        List<Map<String,Object>> rows1 = handler.getCancelTypeProducts(null);
        List<Map<String,Object>> rows = handler.getCancelTypeProducts(basketId);
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
    }
}