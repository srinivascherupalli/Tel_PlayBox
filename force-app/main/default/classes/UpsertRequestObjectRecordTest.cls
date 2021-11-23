@isTest
public class UpsertRequestObjectRecordTest {
    Static Map<String,String> JsonMap = new Map<String,String>();
    Static cs_SigmaToCSJSON dtoObj = new cs_SigmaToCSJSON();
    Static {
        List<StaticResource> JsonFromStaticResourceList = [select Name, Body from StaticResource where Name in ('SigmaCS_JSON', 'StaticAttributeTestJson','CommercialAttributeTestJson','CommercialAttributeBillingTestJson')];
        for(StaticResource sr : JsonFromStaticResourceList)
        {
            JsonMap.put(sr.Name, sr.Body.toString());
        }
    }
    static testMethod void testUpsertAttribute(){
        Test.startTest();
        dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));
        UpsertRequestObjectRecord.upsertAttribute(dtoObj);
        system.debug('testUpsertAttribute is' +UpsertRequestObjectRecord.lstAutoAddTrueJSON);
        system.debug('StaticAttributeTestJson is ' +JsonMap.get('StaticAttributeTestJson'));
        system.debug('CommercialAttributeTestJson is ' +JsonMap.get('CommercialAttributeTestJson'));
        String jsonStrTest1 = JsonMap.get('StaticAttributeTestJson').trim();
        String jsonStrTest2 = JsonMap.get('CommercialAttributeTestJson').trim();
        //system.assert(UpsertRequestObjectRecord.lstAutoAddTrueJSON.contains(JsonMap.get('jsonStrTest1')));
        Boolean iterateFlag = false;
        for(String str : UpsertRequestObjectRecord.lstAutoAddTrueJSON){
            //system.debug('all along this was a lie ' + str);
            if(!str.contains(jsonStrTest1)){
                iterateFlag = true;
            }
        }
        //system.debug('true or false season 1 ' + iterateFlag);
        //system.assert(UpsertRequestObjectRecord.lstAutoAddFailJSON.contains(JsonMap.get('jsonStrTest2')));
        Test.stopTest();
        system.assert(iterateFlag);
        
    }  

    static testMethod void testUpsertchargesAttribute(){
        Test.startTest();
        dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));
        UpsertRequestObjectRecord.upsertchargesAttribute(dtoObj);
        system.debug('testUpsertchargesAttribute is' +UpsertRequestObjectRecord.lstAutoAddFailJSON);
        system.debug('CommercialAttributeBillingTestJson is ' +JsonMap.get('CommercialAttributeBillingTestJson'));
        //system.debug('true or false ' + UpsertRequestObjectRecord.lstAutoAddFailJSON.contains(JsonMap.get('CommercialAttributeBillingTestJson')));
        String jsonStrTest3 = JsonMap.get('CommercialAttributeBillingTestJson').trim();
        system.debug('CommercialAttributeBillingTestJson is ' +jsonStrTest3);
        Boolean iterateFlag = false;
        for(String str : UpsertRequestObjectRecord.lstAutoAddFailJSON){
            //system.debug('all along this was a lie ' + str);
            if(str.contains(jsonStrTest3)){
                iterateFlag = true;
            }
        }
        //system.debug('true or false season 2 ' + iterateFlag);
        Test.stopTest();
        system.assertEquals(false,iterateFlag);
    }  
    
      @isTest static void test_upsertAssuranceAttributes(){
            //dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));
            dtoObj = cs_SigmaToCSJSON.parse(TestDataFactory.jsonSigmaString);
            System.debug('dtoObj : ' + dtoObj);
			System.assertEquals(dtoObj, dtoObj);
            UpsertRequestObjectRecord.upsertAssuranceAttributes(dtoObj);
            //UpsertRequestObjectRecord.upsertAssuranceAttributes(dtoObj);
        }
    
    private static List<cs_SigmaToCSJSON.cls_productStaticCharacteristics> fetchCharFromJSON(){
        cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
        jsonobjPrdtOff = dtoObj.productOffering;
        List<cs_SigmaToCSJSON.cls_products> productList = new List<cs_SigmaToCSJSON.cls_products>();   
        List<cs_SigmaToCSJSON.cls_productStaticCharacteristics> productChar = new List<cs_SigmaToCSJSON.cls_productStaticCharacteristics>();
        for(cs_SigmaToCSJSON.cls_products prod : jsonobjPrdtOff.products ){ 
            for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar : prod.productStaticCharacteristics)
            {
                productChar.add(prodStcChar);
            }  
        }
        return productChar;
    }

        @isTest static void test_getProductTechPhase(){
            dtoObj = cs_SigmaToCSJSON.parse(JsonMap.get('SigmaCS_JSON'));

            UpsertRequestObjectRecord.getProductTechPhase(fetchCharFromJSON());
            
            dtoObj = cs_SigmaToCSJSON.parse(TestDataFactory.jsonSigmaString);

            Boolean result = UpsertRequestObjectRecord.getProductTechPhase(fetchCharFromJSON());
			System.assertEquals(UpsertRequestObjectRecord.getProductTechPhase(fetchCharFromJSON()), result);

        }
}