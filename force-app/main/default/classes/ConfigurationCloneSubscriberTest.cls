@isTest
public class ConfigurationCloneSubscriberTest {
    public static testMethod void onMessageTest() {

        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);

        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        System.assertNotEquals(null,opp);

        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;

        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.cscfga__Configuration_Status__c = 'Valid';

        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Description__c = 'test Description 1';
        config1.cscfga__Contract_Term__c = 24;
        config1.cscfga__Configuration_Status__c = 'Valid';

        cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
        config2.cscfga__Product_Basket__c = basket.id;
        config2.cscfga__Description__c = 'test Description 2';
        config2.cscfga__Contract_Term__c = 12;
        config2.cscfga__Configuration_Status__c = 'Valid';

        cscfga__Product_Configuration__c config3 = ProductTestService.createProductConfiguration();
        config3.cscfga__Product_Basket__c = basket.id;
        config3.cscfga__Description__c = 'test Description 4';
        config3.cscfga__Contract_Term__c = 12;
        config3.cscfga__Configuration_Status__c = 'Valid';
        
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>{config, config1, config2, config3};
        update configList;

        String value = '{"ConfigIdsOldToNew":{"'+config.id+'":["'+config1.id+'","'+config2.id+'","'+config3.id+'"]}}';
            //,"ID2":{"'+config.id+'":["'+config1.id+'","'+config2.id+'","'+config3.id+'"]}}';
        Map<String, Object> payLoad = (Map<String, Object>) JSON.deserializeUntyped(value);
        System.debug('payLoad<><>'+payLoad.keyset());
      
        Set<ID> productConfigurationsForUpdateId = new Set<ID>();
        Map<Id, String> idStatusMap = new Map<Id, String>();
        
        Map<ID,String> prodConfigTobasketMap= new Map<ID,String>();

        List<cscfga__Attribute__c> attributeListToBeUpdated= new List<cscfga__Attribute__c> ();
        productConfigurationsForUpdateId.add (config.id);
        productConfigurationsForUpdateId.add (config1.id);
        productConfigurationsForUpdateId.add (config2.id);
        productConfigurationsForUpdateId.add (config.id); 
        
       
		List<cscfga__Attribute__c> atts = new List<cscfga__Attribute__c>();
		
		cscfga__Attribute__c attr1 = new cscfga__Attribute__c ();
		attr1.name = 'ServiceabilityLocation';
		attr1.cscfga__Product_Configuration__c = config1.Id;
		atts.add(attr1);
		
		cscfga__Attribute__c attr2 = new cscfga__Attribute__c ();
		attr2.name = 'Widefeas Code';
		attr2.cscfga__Product_Configuration__c = config2.Id;
		atts.add(attr2);
		
		
		cscfga__Attribute__c attr3 = new cscfga__Attribute__c ();
		attr3.name = 'SiteNetworkZone';
		attr3.cscfga__Product_Configuration__c = config3.Id;
		atts.add(attr3);
		
		cscfga__Attribute__c attr4 = new cscfga__Attribute__c ();
		attr4.name = 'Test';
		attr4.cscfga__Product_Configuration__c = config.Id;
		atts.add(attr4);
		
		insert atts;
        System.assertNotEquals(null,attributeListToBeUpdated);

         ConfigurationCloneSubscriber cCS = new ConfigurationCloneSubscriber();
         cCS.onMessage('ProductConfiguration','Cloned',payLoad);
       }
}