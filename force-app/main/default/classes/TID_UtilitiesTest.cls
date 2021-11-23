/*
* @Desc : TID Utilities test class
* @Jira : DIGI-518
*/
@isTest
public class TID_UtilitiesTest {
    private void setup() { 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Committed_Data';
        ev.value__c='True';
        insert ev;
        
        Environment_Configurations__c environmentConfig = New Environment_Configurations__c();
        environmentConfig.No_Triggers__c = true;
        insert environmentConfig;
            
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test', 'Test');
        prodDef.product_Specification__c='DMCAT_ProductSpecification_000747';
        insert prodDef;
        
        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name='Professional Services-MDM Config';
        newConfig.Type__c = 'Cancel';
        newConfig.cscfga__Product_Basket__c = basket.id;
        newConfig.cscfga__Product_Family__c='Mobility';
        newConfig.cscfga__unit_recurring_charge__c = 200;
        newConfig.Quantity_Product_Configuration__c =1;
        newConfig.cscfga__Product_Definition__c = prodDef.Id;
        newConfig.cscfga__unit_one_off_charge__c = 1;
        newConfig.csordtelcoa__Replaced_Product_Configuration__c = NULL;
        insert newConfig;
        
        cscfga__Product_Configuration__c newConfig1 = new cscfga__Product_Configuration__c();
        newConfig1.name='Professional Services-MDM Config1';
        newConfig1.Type__c = 'New';
        newConfig1.cscfga__Product_Basket__c = basket.id;
        newConfig1.cscfga__Product_Family__c='Mobility';
        newConfig1.cscfga__unit_recurring_charge__c = 200;
        newConfig1.Quantity_Product_Configuration__c =1;
        newConfig1.cscfga__Product_Definition__c = prodDef.Id;
        newConfig1.cscfga__unit_one_off_charge__c = 1;
        newConfig1.csordtelcoa__Replaced_Product_Configuration__c = NULL;
        insert newConfig1;
        
        cscfga__Product_Configuration__c newConfig2 = new cscfga__Product_Configuration__c();
        newConfig2.name='Professional Services-MDM Config2';
        newConfig2.Type__c = 'Modify';
        newConfig2.cscfga__Product_Basket__c = basket.id;
        newConfig2.cscfga__Product_Family__c='Mobility';
        newConfig2.cscfga__unit_recurring_charge__c = 200;
        newConfig2.Quantity_Product_Configuration__c =1;
        newConfig2.cscfga__Product_Definition__c = prodDef.Id;
        newConfig2.cscfga__unit_one_off_charge__c = 1;
        newConfig2.csordtelcoa__Replaced_Product_Configuration__c = NULL;
        insert newConfig2;
        
        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = prodDef.Id,
            Name = 'AD1Test',
            Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Recurring_Charges',
            Snapshot_Attribute_Fields__c = 'Device'
        );
        insert ad1; 
        
        cscfga__Attribute__c attr=new cscfga__Attribute__c();
        attr.name='RecurringPrice';
        attr.cscfga__Product_Configuration__c = newConfig.Id;
        attr.cscfga__Value__c='1234';
        attr.cscfga__is_active__c = true;
        attr.cscfga__Attribute_Definition__c = ad1.Id;
        insert attr; 
        
        cscfga__Attribute__c attr1=new cscfga__Attribute__c();
        attr1.name='EarlyTerminationCharge';
        attr1.cscfga__Product_Configuration__c = newConfig1.Id;
        attr1.cscfga__Value__c='1234';
        attr1.cscfga__is_active__c = true;
        attr1.cscfga__Attribute_Definition__c = ad1.Id;
        insert attr1; 
        
        cscfga__Attribute__c attr2=new cscfga__Attribute__c();
        attr2.name='DisconnectionDate';
        attr2.cscfga__Product_Configuration__c = newConfig2.Id;
        attr2.cscfga__Value__c='1234';
        attr2.cscfga__is_active__c = true;
        attr2.cscfga__Attribute_Definition__c = ad1.Id;
        insert attr2; 
    }

    @isTest static void getTIDDetailsSuccess(){
        TID_UtilitiesTest testclass= new TID_UtilitiesTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TID_Utilities handler = new TID_Utilities();
        List<Map<String,Object>> rows = handler.getTIDDetails(basketId,new Map<String,String>{'Query_Type'=>'TIDDetails','Type'=>'New'});
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
    }
    @isTest static void getgetTIDDetailsFailure(){
        TID_UtilitiesTest testclass= new TID_UtilitiesTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TID_Utilities handler = new TID_Utilities();
        List<Map<String,Object>> rows = handler.getTIDDetails(null,null);
        Test.stopTest();
        System.assert(rows.isEmpty() == true);
    }
    @isTest static void getTIDDetailsMACSuccess(){
        TID_UtilitiesTest testclass= new TID_UtilitiesTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        String pmName = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TID_Utilities handler = new TID_Utilities();
        List<Map<String,Object>> rows = handler.getTIDDetails(basketId,new Map<String,String>{'Query_Type'=>'TIDDetails','Type'=>'Modify'});
        Test.stopTest();
        for(Map<String,Object> newRow: rows){
            pmName = String.valueOf(newRow.get('Product_Module_Name'));
        }
        System.assert(pmName == 'Internet Direct');
    }
    @isTest static void getgetTIDDetailsMACFailure(){
        TID_UtilitiesTest testclass= new TID_UtilitiesTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TID_Utilities handler = new TID_Utilities();
        List<Map<String,Object>> rows = handler.getTIDDetails(null,null);
        Test.stopTest();
        System.assert(rows.isEmpty() == true);
    }
    
    @isTest static void getTIDCancelSuccess(){
        TID_UtilitiesTest testclass= new TID_UtilitiesTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TID_Utilities handler = new TID_Utilities();
        List<Map<String,Object>> rows = handler.getTIDCancel(basketId,new Map<String,String>{'Query_Type'=>'TIDCancel','Type'=>'Cancel'});
        Test.stopTest();
        System.assert(rows.isEmpty() == false);
    }
    @isTest static void getTIDCancelFailure(){
        TID_UtilitiesTest testclass= new TID_UtilitiesTest();
        testclass.setup();
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        TID_Utilities handler = new TID_Utilities();
        List<Map<String,Object>> rows = handler.getTIDCancel(null,null);
        Test.stopTest();
        System.assert(rows.isEmpty() == true);
    }

}