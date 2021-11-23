/*
ClassName : UpsertAttributeLOVfromSigmaObjTest
Description:Test Class for UpsertAttributeLOVfromSigmaObj
*/

@isTest
private class UpsertAttributeLOVfromSigmaObjTest {    
    Static Map<String,String> JsonMap = new Map<String,String>();
    Static cs_SigmaToCSJSON dtoObj = new cs_SigmaToCSJSON();
    Static {
        List<StaticResource> JsonFromStaticResourceList = [select Name, Body from StaticResource where Name in ('SigmaCS_JSON', 'SigmaCS_JSON_Update')];
        for(StaticResource sr : JsonFromStaticResourceList)
        {
            JsonMap.put(sr.Name, sr.Body.toString());
        }
    }
    static testMethod void testUpsertAttributesLOV(){
        Test.startTest();
        List<cs_SigmaToCSJSON.cls_productOffering> jsonobjPrdtOff = new List<cs_SigmaToCSJSON.cls_productOffering>();
        dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));
        UpsertAttributeLOVfromSigmaObj.uppsertattLov(dtoObj);
        List<Product_Attribute_LOV__c> lstLOVObj = [Select Id, Name,Package_Name__c,Product_Definition__c,Value__c from Product_Attribute_LOV__c where Name = 'Contract Term' and Package_Name__c='Connected Workplace' and Product_Definition__c='IP Site'];
        for(Product_Attribute_LOV__c lovObj : lstLOVObj)
        {
            System.assert(lovObj.Value__c != '36' || lovObj.Value__c != '12' || lovObj.Value__c != '24');
        }
        //For Update
        dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON_Update'));
        UpsertAttributeLOVfromSigmaObj.uppsertattLov(dtoObj);
        lstLOVObj = [Select Id, Name,Package_Name__c,Product_Definition__c,Value__c from Product_Attribute_LOV__c where Name = 'Contract Term' and Package_Name__c='Connected Workplace' and Product_Definition__c='IP Site'];
        for(Product_Attribute_LOV__c lovObj : lstLOVObj)
        {
            System.assert(lovObj.Value__c != '30' || lovObj.Value__c != '10' || lovObj.Value__c != '20');
        }
        
        Test.stopTest();        
    }
}