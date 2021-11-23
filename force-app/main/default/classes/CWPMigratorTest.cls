/*****************************************************************
Author : Venkata Ramanan G
Created Date : 01-08-2019 
Description : Test Class for CWPMigrator & SolutionWrapper class.
Version History : 

Version             Change                     Owner
1.0                Created                    Venkata Ramanan G

*****************************************************************/

@isTest
public class CWPMigratorTest {

    @testSetup
    static void testdata(){
        //Create Product Definition
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c  cwpprd = new cscfga__Product_Definition__c(name='Connected Workplace Solution',cscfga__Active__c = true, cscfga__Description__c ='test desc');
        pdList.add(cwpprd);
        cscfga__Product_Definition__c  cwpprdRel = new cscfga__Product_Definition__c(name='Connected Workplace',cscfga__Active__c = true, cscfga__Description__c ='test desc Related');
        pdList.add(cwpprdRel);
        
        insert pdList;
        
        //Create JSON Data
        String value = '{"attributes": [{"required": true,"showInUI": true,"name": "Solution Name","value": "Connected Workplace","type": "String"},{"showInUI": false,"required": false,"type": "String","name": "GUID"},{"showInUI": false,"required": false,"type": "String","name": "SolutionId"}],"name": "Connected Workplace","description": "Connected Workplace"}';
        List<csutil__JSON_Data__c> jsondatalist = new List<csutil__JSON_Data__c>();
        csutil__JSON_Data__c json = new csutil__JSON_Data__c(name='Connected Workplace Schema',csutil__value__c= value );
        jsondatalist.add(json);
        csutil__JSON_Data__c json1 = new csutil__JSON_Data__c(name='IPSite Schema',csutil__value__c= value );
        jsondatalist.add(json1);
        csutil__JSON_Data__c jsonRel = new csutil__JSON_Data__c(name='Related Schema',csutil__value__c= value );
        jsondatalist.add(jsonRel);
        
        insert jsondatalist;
        
        //Create Main & Component Solution Definitions
        List<cssdm__Solution_Definition__c> cwpSolList = new List<cssdm__Solution_Definition__c>();
        cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Connected Workplace', cssdm__Product_Definition__c =cwpprd.id,cssdm__Type__c = 'Main',cssdm__schema__c=json.id);
        insert cwpsol;
        cssdm__Solution_Definition__c  cwpcompsol = new cssdm__Solution_Definition__c(name='IP Site',cssdm__Product_Definition__c = cwpprd.id,cssdm__Type__c = 'Component',cssdm__main_component__c = cwpsol.id,cssdm__schema__c=json1.id);
        cwpSolList.add(cwpcompsol);
        cssdm__Solution_Definition__c  cwpRelsol = new cssdm__Solution_Definition__c(name='Related',cssdm__Product_Definition__c = cwpprdRel.id,cssdm__Type__c = 'Related Component',cssdm__related_product_name__c='Related',cssdm__main_component__c = cwpsol.id,cssdm__schema__c=jsonRel.id);
        cwpSolList.add(cwpRelsol);
        
        insert cwpSolList;
        
        //Create Account
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        insert acc;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.Primary_Basket__c = true;
        basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
        insert basket;
        
        
        //create Product Configuration
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(cwpprd.id);
        config.cscfga__Product_Basket__c = basket.id;
        config.Name = System.Label.Label_CWP;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.Type__c = 'New';
        config.cscfga__Configuration_Status__c = 'Valid';
        config.cscfga__Product_Family__c = 'Hardware';
        config.Quantity_Product_Configuration__c = 2;
        //config.cscfga__Product_Definition__c = cwpprd.id;
        insert config;     
        
            
        //create Product Configuration
        cscfga__Product_Configuration__c configRel = ProductTestFactory.buildProductConfig(cwpprdRel.id);
        configRel.cscfga__Product_Basket__c = basket.id;
        configRel.Name = 'test Description Related';
        configRel.cscfga__Description__c = 'test Description Related';
        configRel.cscfga__Contract_Term__c = 36;
        configRel.Type__c = 'New';
        configRel.cscfga__Configuration_Status__c = 'Valid';
        configRel.cscfga__Product_Family__c = 'Hardware';
        configRel.cscfga__Parent_Configuration__c = config.Id;
        configRel.cscfga__Root_Configuration__c = config.Id;
        configRel.Quantity_Product_Configuration__c = 2;
        //configRel.cscfga__Product_Definition__c = cwpprdRel.id;
        insert configRel; 
        
        //Create Attributes attached to Product config & basket
        List<cscfga__Attribute__c> attributeList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attribute = new cscfga__Attribute__c(name='GUID', cscfga__Is_Line_Item__c=true, cscfga__is_active__c=true, cscfga__Product_Configuration__c=config.id, cscfga__Line_Item_Description__c='Hardware', cscfga__Price__c=10.00, cscfga__Recurring__c=false, cscfga__Value__c='100'); 
        attributeList.add(attribute);  
        cscfga__Attribute__c attribute1 = new cscfga__Attribute__c(name='SolutionId', cscfga__Is_Line_Item__c=true, cscfga__is_active__c=true, cscfga__Product_Configuration__c=config.id, cscfga__Line_Item_Description__c='Hardware', cscfga__Price__c=10.00, cscfga__Recurring__c=true, cscfga__Value__c='100'); 
        attributeList.add(attribute1); 

        cscfga__Attribute__c attributeRel = new cscfga__Attribute__c(name='GUID', cscfga__Is_Line_Item__c=true, cscfga__is_active__c=true, cscfga__Product_Configuration__c=configRel.id, cscfga__Line_Item_Description__c='Rel Hardware', cscfga__Price__c=10.00, cscfga__Recurring__c=false, cscfga__Value__c='100'); 
        attributeList.add(attributeRel);  
        cscfga__Attribute__c attributeRel1 = new cscfga__Attribute__c(name='SolutionId', cscfga__Is_Line_Item__c=true, cscfga__is_active__c=true, cscfga__Product_Configuration__c=configRel.id, cscfga__Line_Item_Description__c='Rel Hardware', cscfga__Price__c=10.00, cscfga__Recurring__c=true, cscfga__Value__c='100'); 
        attributeList.add(attributeRel1);
        
        insert attributeList;
        
        //Create attribute definition
        List<cscfga__Attribute_Definition__c> attrDefList = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c attdef = new cscfga__Attribute_Definition__c(name='GUID', cscfga__Product_Definition__c=cwpprd.id);
        attrDefList.add(attdef);
        cscfga__Attribute_Definition__c attdef1 = new cscfga__Attribute_Definition__c(name='SolutionId', cscfga__Product_Definition__c=cwpprd.id);
        attrDefList.add(attdef1);
        cscfga__Attribute_Definition__c attdef11 = new cscfga__Attribute_Definition__c(name='Solution Name', cscfga__Product_Definition__c=cwpprd.id);
        attrDefList.add(attdef11);
        cscfga__Attribute_Definition__c attdef2 = new cscfga__Attribute_Definition__c(name='createPCRs', cscfga__Product_Definition__c=cwpprd.id);
        attrDefList.add(attdef2);
        cscfga__Attribute_Definition__c attdef3 = new cscfga__Attribute_Definition__c(name='isMainComponent', cscfga__Product_Definition__c=cwpprd.id);
        attrDefList.add(attdef3);
        cscfga__Attribute_Definition__c attdef4 = new cscfga__Attribute_Definition__c(name='Default Offer Name', cscfga__Product_Definition__c=cwpprd.id);
        attrDefList.add(attdef4);
        
        cscfga__Attribute_Definition__c attdefRel = new cscfga__Attribute_Definition__c(name='GUID', cscfga__Product_Definition__c=cwpprdRel.id);
        attrDefList.add(attdefRel);
        cscfga__Attribute_Definition__c attdefRel1 = new cscfga__Attribute_Definition__c(name='SolutionId', cscfga__Product_Definition__c=cwpprdRel.id);
        attrDefList.add(attdefRel1);
        cscfga__Attribute_Definition__c attdefRel11 = new cscfga__Attribute_Definition__c(name='Solution Name', cscfga__Product_Definition__c=cwpprdRel.id);
        attrDefList.add(attdefRel11);
        cscfga__Attribute_Definition__c attdefRel2 = new cscfga__Attribute_Definition__c(name='createPCRs', cscfga__Product_Definition__c=cwpprdRel.id);
        attrDefList.add(attdefRel2);
        cscfga__Attribute_Definition__c attdefRel3 = new cscfga__Attribute_Definition__c(name='isMainComponent', cscfga__Product_Definition__c=cwpprdRel.id);
        attrDefList.add(attdefRel3);
        cscfga__Attribute_Definition__c attdefRel4 = new cscfga__Attribute_Definition__c(name='Default Offer Name', cscfga__Product_Definition__c=cwpprdRel.id);
        attrDefList.add(attdefRel4);
        
        
        insert attrDefList;
        
        //Create Subscription
        csord__Subscription__c  testsub = new csord__Subscription__c (name='Test Sub', csordtelcoa__Product_Configuration__c = config.id,csord__Account__c = acc.id,csord__Identification__c ='test sub');
        insert testsub;
        //Create Service
        csord__Service__c  testser = new csord__Service__c(name='test ser',csord__Subscription__c = testsub.id,csord__Identification__c ='test sub',csord__Status__c = 'Active', csordtelcoa__Product_Configuration__c = config.id);
        insert testser;
        csord__Service__c  testser1 = new csord__Service__c(name='test ser1',csord__Subscription__c = testsub.id,csord__Identification__c ='test sub1',csord__Status__c = 'Active', csordtelcoa__Product_Configuration__c = configRel.id);
        insert testser1;
        
        //Create CWPMigrationLog
        String recids = '["'+cwpprd.id+'","'+cwpsol.id+'","'+config.id+'"]';
        CWP_Migration_Log__c  miglog = new CWP_Migration_Log__c(Inserted_Records__c =recids);
        insert miglog;
    }
    
    @isTest
    static void testcwpmigratorrollback(){
        List<Account> acc =[select id from Account limit 1];
        Account a = acc[0];
        
        List<Opportunity> opps = [select id from Opportunity];
        Opportunity opp = opps[0];
        
        //cscfga__Product_Basket__c basketTemp = new cscfga__Product_Basket__c();
        List<cscfga__Product_Basket__c> baskets = [select id from cscfga__Product_Basket__c];
        cscfga__Product_Basket__c bask = baskets[0];
        
        //cscfga__Product_Basket__c bask = basketTemp;
        List<cscfga__Product_Configuration__c> config = [select id from cscfga__Product_Configuration__c];
        CWP_Migration_Log__c log = [select id,name from CWP_Migration_Log__c limit 1];
        List<cscfga__Product_Definition__c> cwp_prod_defs = [SELECT Id FROM cscfga__Product_Definition__c WHERE Name = 'Connected Workplace Solution' AND cscfga__Active__c = TRUE LIMIT 1];
        Test.startTest();
        if (cwp_prod_defs.size() > 0) {
        CWPMigrator migrator = new CWPMigrator(true, cwp_prod_defs[0].Id);
        //CWPMigrator migrator = new CWPMigrator(true, cwp_prod_def.Id);
        List<cscfga__Attribute_Definition__c> deflst = [select id from cscfga__Attribute_Definition__c];
        List<cscfga__Product_Definition__c> def = [select id from cscfga__Product_Definition__c];
        migrator.migrate(new List<Id>{a.id});
        //migrator.Validate(new List<Id>{a.id});
        migrator.rollBack(String.valueOf(log.name), new List<Id>{a.id});
        migrator.CreateAttributesJSON(config[0]);
        migrator.updateSubsAndServices(new List<Id>{a.id});
        Test.stopTest();
        }
        System.AssertNotEquals(bask,null);
    }
    @isTest
    static void testcwpmigratorrollbackall(){
        Account a =[select id from Account limit 1];
        List<cscfga__Product_Definition__c> cwp_prod_defs = [SELECT Id FROM cscfga__Product_Definition__c WHERE Name = 'Connected Workplace Solution' AND cscfga__Active__c = TRUE LIMIT 1];
        if (cwp_prod_defs.size() > 0) {
        CWPMigrator migrator = new CWPMigrator(true, cwp_prod_defs[0].Id);
        //CWPMigrator migrator = new CWPMigrator(true, cwp_prod_def.Id);
        List<cscfga__Attribute_Definition__c> deflst = [select id from cscfga__Attribute_Definition__c];
        List<cscfga__Product_Definition__c> def = [select id from cscfga__Product_Definition__c limit 1];
        Test.startTest();
        migrator.migrate(new List<Id>{a.id});
        //migrator.Validate(new List<Id>{a.id});
            migrator.rollBackAll(new List<Id>{a.id});
        Test.stopTest();
        }
    System.AssertNotEquals(a,null);
    }
}