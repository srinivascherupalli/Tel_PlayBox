@isTest
private class CS_AttributeSpecsDTOTest {
	
	@isTest static void testSpecification() {
		String json = '{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"95f3f970-3828-4bae-b219-b8b2089ddf02","productConfigurationId":"a3T0l0000004qK0EAI","name":"IP VPN Port_Fulfilment","instanceId":"","guid":"fd163885-4b6a-5b7f-a387-3d12bae7d2a7","endDate":"","description":"","code":"PS_000030_Fulfilment","attributes":{"Class of Service":"DCOS","Port Role":"Primary","Multicast Enabled":"FALSE","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"07cbfa3f-f93a-4962-83fb-c2c41b156cd4","productConfigurationId":"a3T0l0000004qK0EAI","name":"Telstra Fibre Access_Fulfilment","instanceId":"","guid":"8609e29f-502c-d0e6-3a33-7252111e2f9a","endDate":"","description":"","code":"PS_000027_Fulfilment","attributes":{"IP Access Configuration":"Single Uplink","Access Role":"Primary","Class of Service":"DCOS","Multicast Enabled":"FALSE","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"a4e0l00000006IJAAY","legacyAttributes":[]}';

		List<CS_AttributeSpecsDTO.ServiceSpecification> specs = CS_AttributeSpecsDTO.parseSpec(json, 'Fulfilment');

		System.assertEquals(specs[0].version, String.valueOf(1));
		System.assertEquals(specs[0].status, 'Created');
		System.assertEquals(specs[0].startDate, '');
		System.assertEquals(specs[0].specification, '95f3f970-3828-4bae-b219-b8b2089ddf02');
		System.assertEquals(specs[0].name, 'IP VPN Port_Fulfilment');
		System.assertEquals(specs[0].code, 'PS_000030_Fulfilment');
		System.assertEquals(specs[0].description, '');
		System.assertEquals(specs[0].guid, 'fd163885-4b6a-5b7f-a387-3d12bae7d2a7');
		System.assertEquals(specs[0].instanceId, '');
	}
	
}