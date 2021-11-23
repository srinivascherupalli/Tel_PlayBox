/*
ClassName : UpsertSpecificationObjectRecordTest
Description:Test Class for UpsertSpecificationObjectRecord
*/

@isTest
private class UpsertSpecificationObjectRecordTest {
    Static Map<String,String> JsonMap = new Map<String,String>();
    Static cs_SigmaToCSJSON dtoObj = new cs_SigmaToCSJSON();
    Static{
        List<StaticResource> JsonFromStaticResourceList = [select Name, Body from StaticResource where Name in ('SigmaCS_JSON', 'SigmaCS_JSON_Update','SpecificationRecord_JSON','SpecificationRecord_JSON_Update','SpecificationChargeRecord_JSON','SpecificationChargeRecord_JSON_Update')];
        for(StaticResource sr : JsonFromStaticResourceList)
        {
            JsonMap.put(sr.Name, sr.Body.toString());
        }
    }
    @TestSetup
    public static void testSetup(){
        List<cscfga__Product_Definition__c> lstpd = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c = 'PS_000049';
        pd.cscfga__Active__c = true;
        lstpd.add(pd);
        cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd1.product_Specification__c = 'PS_000055';
        pd1.cscfga__Active__c = true;
        lstpd.add(pd1);
        cscfga__Product_Definition__c pd2 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd2.product_Specification__c = 'PS_00007';
        pd2.cscfga__Active__c = true;
        lstpd.add(pd2);
        cscfga__Product_Definition__c pd3 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd3.product_Specification__c = 'PS_000115';
        pd3.cscfga__Active__c = true;
        lstpd.add(pd3);
        cscfga__Product_Definition__c pd4 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd4.product_Specification__c = 'PS_000074';
        pd4.cscfga__Active__c = true;
        lstpd.add(pd4);
        cscfga__Product_Definition__c pd5 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd5.product_Specification__c = 'PS_000073';
        pd5.cscfga__Active__c = true;
        lstpd.add(pd5);       
        insert lstpd;
        
        List<csedm__Specification__c> specLst = new List<csedm__Specification__c>();
        csedm__Specification__c spec = new csedm__Specification__c();
        spec.Name = 'IP Site_Fulfilment';
        spec.csedm__identifier__c = '00d686c2-6da9-4c48-8e88-cb2d66dbda63';
        spec.csedm__Code__c = 'PS_000049';
        //spec.External_Id__c = 'DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000163';
        specLst.add(spec);
        insert specLst;                    
    } 
    
    @IsTest
    private static void testUpsertSpecificationChargeRecord(){
        Test.startTest();      
        dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));
        UpsertSpecificationObjectRecord.upsertSpecificationChargeRecord(dtoObj);       
        List<csedm__Specification__c> specObj = [Select Id, Name,External_Id__c,csedm__identifier__c,csedm__Code__c,csedm__Value__c from csedm__Specification__c where Name = 'IP Site_Fulfilment'];
        system.debug('specObj '+specObj);
        system.assertEquals('00d686c2-6da9-4c48-8e88-cb2d66dbda63', specObj[0].csedm__identifier__c);
        Test.stopTest();        
    }  
    @IsTest
    private static void testUpsertSpecificationRecord(){
        Test.startTest();      
        dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));
        UpsertSpecificationObjectRecord.upsertSpecificationRecord(dtoObj);       
        List<csedm__Specification__c> specObj = [Select Id, Name,External_Id__c,csedm__identifier__c,csedm__Code__c,csedm__Value__c from csedm__Specification__c where Name = 'IP Site_Fulfilment'];
        system.debug('specObj '+specObj);
        system.assertEquals('00d686c2-6da9-4c48-8e88-cb2d66dbda63', specObj[0].csedm__identifier__c);
        Test.stopTest();        
    }
    @IsTest
    private static void testUpsertSpecificationAssuranceRecord(){
        Test.startTest();      
        dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));
        UpsertSpecificationObjectRecord.upsertSpecificationAssuranceRecord(dtoObj);       
        List<csedm__Specification__c> specObj = [Select Id, Name,External_Id__c,csedm__identifier__c,csedm__Code__c,csedm__Value__c from csedm__Specification__c where Name = 'IP Site_Fulfilment'];
        system.debug('specObj '+specObj);
        system.assertEquals('00d686c2-6da9-4c48-8e88-cb2d66dbda63', specObj[0].csedm__identifier__c);
        Test.stopTest();        
    }    
}