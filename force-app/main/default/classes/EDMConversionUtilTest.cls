@isTest
private class EDMConversionUtilTest {
    
    @isTest static void testConversion() {
        String edmString = '{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000313","productConfigurationId":"a3T2O0000009Ul3UAE","name":"UC Numbers_Fulfilment","instanceId":"","includeBilling":false,"guid":"5a0544a7-cafd-bd7d-3c13-0dde0cb7b2ad","endDate":"","description":"","code":"DMCAT_ProductSpecification_000313_Fulfilment","attributes":{"Number":[{"attributes":{"listCode":"LE","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},"schemaId":"fed82542-4175-a89a-e761-5b903588ad65"},{"attributes":{"listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"3282345560"},"schemaId":"c893d8d7-f7f6-851c-0c1c-0aeabc12a273"}],"id":"","VoicePlan":"Complete Premium","__targetSystem":"FULFILMENT","parentSpec":"DMCAT_ProductSpecification_000312_Fulfilment"},"additionalAttributes":{"parentSpec":"28c5e04d-d069-7419-0fe4-0e9b2657e056"}}],"serviceId":"a4e2O0000004SGiQAM","legacyAttributes":[]}';
        String spec = EDMConversionUtil.ConvertServiceEDMToSpec(edmString);
        System.debug('spec::'+spec);
        System.assertNotEquals(null, spec);
    }
    
    @isTest static void testConversion2() {
        String edmString = '{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000312DMCAT_ProductSpecification_000313","productConfigurationId":"a3T2O0000009Ul3UAE","name":"UC Numbers_Fulfilment","instanceId":"","includeBilling":false,"guid":"5a0544a7-cafd-bd7d-3c13-0dde0cb7b2ad","endDate":"","description":"","code":"DMCAT_ProductSpecification_000313_Fulfilment","attributes":{"Number":[{"attributes":{"listCode":"LE","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},"schemaId":"fed82542-4175-a89a-e761-5b903588ad65"},{"attributes":{"listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"3282345560"},"schemaId":"c893d8d7-f7f6-851c-0c1c-0aeabc12a273"}],"id":"","VoicePlan":"Complete Premium","__targetSystem":"FULFILMENT","parentSpec":"DMCAT_ProductSpecification_000312_Fulfilment"},"additionalAttributes":{"parentSpec":"28c5e04d-d069-7419-0fe4-0e9b2657e056"}}],"serviceId":"a4e2O0000004SGiQAM","legacyAttributes":[]}';
        List<CS_SpecificationDTO.ServiceSpecification> spec = EDMConversionUtil.ConvertServiceEDMToSpecDTO(edmString, '');
        //System.debug('spec::'+spec);
        System.assertNotEquals(null, spec);
    }

}