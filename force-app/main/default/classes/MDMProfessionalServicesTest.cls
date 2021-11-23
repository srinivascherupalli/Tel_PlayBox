/*
* @Desc : MDM Professional Service test class
* @Jira : DIGI-518
*/
@isTest
public class MDMProfessionalServicesTest {
    private void setup() { 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        
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
        
        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name='Professional Services-MDM Config';
        newConfig.Type__c = 'Cancel';
        newConfig.cscfga__Product_Basket__c = basket.id;
        newConfig.cscfga__Product_Family__c='Mobility';
        newConfig.cscfga__unit_recurring_charge__c = 200;
        newConfig.Quantity_Product_Configuration__c =1;
        newConfig.cscfga__Product_Definition__c = prodDef.Id;
        newConfig.cscfga__unit_one_off_charge__c = 1;
        insert newConfig;
                
        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = prodDef.Id,
            Name = 'AD1Test',
            Snapshot_Attribute_Value_Field__c = 'GSTExcl_Total_Recurring_Charges',
            Snapshot_Attribute_Fields__c = 'Device'
        );
        insert ad1; 
        
        cscfga__Attribute__c attr=new cscfga__Attribute__c();
        attr.name='TenancyID';
        attr.cscfga__Product_Configuration__c = newConfig.Id;
        attr.cscfga__Value__c='1234';
        attr.cscfga__is_active__c = true;
        attr.cscfga__Attribute_Definition__c = ad1.Id;
        insert attr;     
    }
    
    @isTest static void getMDMProfServicesTestSuccess(){
        MDMProfessionalServicesTest testclass= new MDMProfessionalServicesTest();
         testclass.setup();
         Test.startTest();
         cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
         String basketId = '';
         if(prodBasket !=null)
             basketId = prodBasket.id;
         MDMPS_Utilities handler = new MDMPS_Utilities();
         List<Map<String,Object>> rows = handler.getMDMProfServices(basketId,new Map<String,String>{'Query_Type'=>'MDMProfServiceDetails','Offer_Name'=>'Professional Services-MDM Config'});
         Test.stopTest();
         System.assert(rows.isEmpty() == false);
        List<Map<String,Object>> failedRows = handler.getMDMProfServices(null,null);
        System.assert(failedRows.isEmpty() == true);
    }
}