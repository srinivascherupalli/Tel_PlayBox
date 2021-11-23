@isTest
public class NumberEnrichmentValidationHelperTest
{
    private static cscfga__Product_Basket__c basket = null;
    @testSetup static void setup(){
     
    Account acc = new Account(Name = 'Burlington',Account_Status__c='Active');
    insert acc;
    
    basket = ProductTestFactory.buildEmptyBasket();
    basket.csbb__Account__c = acc.id;
    insert basket;
    
    cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
    prodDef.product_Specification__c = 'DMCAT_ProductOffering_000419';
    prodDef.cscfga__Active__c = true;
    insert prodDef;
    
    cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
    config.cscfga__Contract_Term__c = 12;
    config.cscfga__total_contract_value__c = 325;
    config.cscfga__Product_Basket__c = basket.id;
    config.csordtelcoa__Replaced_Product_Configuration__c = null;
    config.cscfga__Quantity__c = 2;
	insert config;
    
    csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
    cnse.name = 'NumberManagementv1';
    insert cnse;
        
     Attachment attachment = new Attachment();
     String encodedContentsString = '{"schema":{"attributes":[{"name":"MobileNumber","required":false,"showInUI":true,"type":"String"},{"name":"Status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O0000000156QAA","name":"MobileNumberManagementv1"},"configurations":[{"guid":"e68d805a-a9c3-4a98-f779-63d85abef824","MobileNumber":"61429745850","Status":"RESERVED","listCode":"No Entry Line"}]}';
     attachment.Body = Blob.valueOf(encodedContentsString);
     attachment.Name = String.valueOf('MobileNumberManagementv1_schema.json');
     attachment.ParentId = config.Id; 
     insert attachment;
     }
    
    @isTest static void validateMobilityProductsInBasketTest()
    {
        Test.startTest();
        setup();
        boolean validMobilityBasket = false;
        NumberEnrichmentValidationHelper nEhelper = new NumberEnrichmentValidationHelper();
        validMobilityBasket = nEhelper.validateMobilityProductsInBasket (basket.id);
        System.debug('Valid basket '+validMobilityBasket );
        System.assertEquals(validMobilityBasket, false);
        Test.stopTest();
    }
}