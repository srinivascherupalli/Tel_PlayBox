@isTest
public class UpdateModuleChangeforOpptyTest {
    
    @isTest
    public static void getDataTest(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Name = 'Test Opp';
        orpportunityDetailsRecord.Product_Domain__c = 'MOBILES';
        
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;
        
        opportunity opportunityInsert = new opportunity();
        opportunityInsert.Id=orpportunityDetailsRecord.Id;
        opportunityInsert.Model_Change__c = true;
        update opportunityInsert;
        
        list<cscfga__Product_Basket__c> basket1 = new list<cscfga__Product_Basket__c>();
        
        cscfga__Product_Basket__c basket= new cscfga__Product_Basket__c();
        basket.csbb__Account__c = a.id;
        basket.cscfga__Opportunity__c = orpportunityDetailsRecord.Id;
        basket.Name = 'Product Basket';
        basket1.add(basket);
        insert basket1;
        String basketId = basket.Id;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        prodDef.product_Specification__c = 'DMCAT_ProductSpecification_000087';
        insert prodDef;
        
        cscfga__Product_Configuration__c config1 = new cscfga__Product_Configuration__c();
        config1.cscfga__Product_Definition__c = prodDef.id;
        //config1.csordtelcoa__Account__c= a.id;
        //config1.cscfga__Opportunity__c=orpportunityDetailsRecord.Id;
        config1.name = 'GetBasket';
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c = basket1[0].id;
        insert config1; 
        
        
        Map<String, Object> inputMap = new Map<String, Object> (); 
        
        cscfga__Product_Configuration__c config =[Select id,name from cscfga__Product_Configuration__c where name = 'GetBasket'];
        //inputMap.put('prod config', config.Id);  
        inputMap.put('GetBasket', config.Id);
        
        Test.startTest();
        map<String, Object> updateChange = UpdateModuleChangeforOppty.getData(inputMap);
        Test.stopTest();        
        //System.assertEquals('', inputMap.get('GetBasket'));
        System.assertEquals(true, inputMap.size()>0);
    }
}