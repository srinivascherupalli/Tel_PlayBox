/*****************************************************************
Author : Aditya Pareek
Created Date : 01-08-2019 
Description : Test Class for SolutionWriter class.
Version History : 

Version             Change                     Owner
1.0                Created                    Aditya Pareek

*****************************************************************/

@isTest
public class SolutionWriterTest {

    @isTest
    static void testsolutionWrapper(){
    //Create Product Definition
        cscfga__Product_Definition__c  pdcwp = new cscfga__Product_Definition__c(name='Connected Workplace Solution',cscfga__Active__c = true, cscfga__Description__c ='test desc');
        insert pdcwp;
        
        //Create Schema
        String s = '{\n' +
    ' "attributes" : [ ' + 
      '{ "name":"Solution Name", ' + 
        '"value":"CWP" } ],\n' +
    ' "name" : "Connected Workplace",\n' +
    ' "description" : "CWP"\n' +
    '}';
        csutil__JSON_Data__c schcwp = new csutil__JSON_Data__c(Name='Connected Workplace Schema', csutil__value__c =s);
        insert schcwp;
        System.debug('<><><><>'+schcwp);
        cssdm__Solution_Definition__c  cwpsol = new cssdm__Solution_Definition__c(name='Connected Workplace',cssdm__Type__c = 'Main', cssdm__Product_Definition__c =pdcwp.id, cssdm__Schema__c=schcwp.id);
        insert cwpsol;
        cssdm__Solution_Definition__c  cwpsol1 = new cssdm__Solution_Definition__c(name='IP Site Test',cssdm__Type__c = 'Component', cssdm__main_component__c = cwpsol.id, cssdm__Product_Definition__c =pdcwp.id, cssdm__Schema__c=schcwp.id);
        insert cwpsol1;
        
       
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.Name = 'basket1';
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert basket;
        //create Product Configuration
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.Name = System.Label.Label_CWP;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.Type__c = 'New';
        config.cscfga__Configuration_Status__c = 'Valid';
        config.cscfga__Product_Family__c = 'Hardware';
        config.Quantity_Product_Configuration__c = 2;
        config.cscfga__Product_Definition__c = pdcwp.id;
       // config.cssdm__solution_association__c = cwpsol.id;
        upsert config; 
        
        cscfga__Product_Configuration__c config1 = config.clone(false,false,false,false);
        config1.cscfga__Parent_Configuration__c = config.id;
        insert config1;
        
        
        //Create Attributes attached to Product config & basket
        cscfga__Attribute__c attribute = new cscfga__Attribute__c(name='GUID', cscfga__Is_Line_Item__c=true, cscfga__is_active__c=true, cscfga__Product_Configuration__c=config.id, cscfga__Line_Item_Description__c='Hardware', cscfga__Price__c=10.00, cscfga__Recurring__c=false, cscfga__Value__c='100'); 
        insert attribute; 
        cscfga__Attribute__c attribute11 = new cscfga__Attribute__c(name='GUID', cscfga__Is_Line_Item__c=true, cscfga__is_active__c=true, cscfga__Product_Configuration__c=config1.id, cscfga__Line_Item_Description__c='Hardware', cscfga__Price__c=10.00, cscfga__Recurring__c=false, cscfga__Value__c='100'); 
        insert attribute11;  
        cscfga__Attribute__c attribute1 = new cscfga__Attribute__c(name='SolutionId', cscfga__Is_Line_Item__c=true, cscfga__is_active__c=true, cscfga__Product_Configuration__c=config.id, cscfga__Line_Item_Description__c='Hardware', cscfga__Price__c=10.00, cscfga__Recurring__c=true, cscfga__Value__c='100'); 
        insert attribute1; 
        List<cssdm__Solution_Definition__c> solutionList= [SELECT Id, Name,cssdm__Schema__r.csutil__value__c, cssdm__Product_Definition__c FROM cssdm__Solution_Definition__c WHERE Id=:cwpsol.Id];
        Map<Id, String> pc2GUIDMap = new Map<Id, String> {config.id => '100', config1.id => '100'};
        /*TODO: Change basket.id to account.id; under revised logic, product configurations in a solution may come from many baskets, 
        so we use the account to find all solution components instead*/
        SolutionWriter.CreateSolutionJSON(solutionList[0],basket.id, pc2GUIDMap);
        migrate_relatedproduct_wrapper relatedProduct = new migrate_relatedproduct_wrapper();
        relatedProduct.replacedConfigId = '';
    relatedProduct.relatedProductName = '';
    relatedProduct.productDefinitionId = '';
    relatedProduct.name = '';
    relatedProduct.guid = '';
    relatedProduct.groupName = '';
    relatedProduct.configurationId = '';
    relatedProduct.configData = '';
    relatedProduct.componentId = '';
    
    }
    
}