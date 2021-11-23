@IsTest
public class DatesO2ADTOTest {
	
	static testMethod void testParse() {
		String json = '{'+
		' \"datesO2AList\":['+
		' {'+
		'   \"Sale_Order_ID\": \"ON00145811\",'+
		'   \"Order_Item_ID\": \"ON00145811|SVC-000187271|8d15e372-c487-6cd7-cb4a-ddd1bc74197b\",'+
		'   \"telstraCommittedDate\": \"2020-12-14T19:09:40+00:00\",'+
		'   \"currentForecastedDeliveryDate\": \"2020-12-14T19:01:12+00:00\",'+
		'   \"productCompletionDate\": \"2020-12-08T13:40:13+00:00\",'+
		'   \"productCancellationDate\": \"\",'+
		'   \"ServiceActivationDate\": \"2020-12-05T19:01:12+00:00\",'+
		'   \"ServiceDeactivationDate\": \"\",'+
		'   \"DesignCompletionDate\": \"\",'+
		'   \"InstallationDate\": \"2020-12-1T19:01:12+00:00\",'+
		'   \"EquipmentDeliveredDate\": \"\",'+
		'   \"CustomerOrderAcceptanceDate\": \"\",'+
		'   \"EstimatedDeliveryDate\": \"\"'+
		' },'+
		' {'+
		'   \"Sale_Order_ID\": \"ON00147118\",'+
		'   \"Order_Item_ID\": \"ON00147118|SVC-000189133|1a4f1398-caf5-3ff4-0a22-6e543eac9e70\",'+
		'   \"telstraCommittedDate\": \"2020-12-11T19:09:40+00:00\",'+
		'   \"currentForecastedDeliveryDate\": \"2020-12-11T19:01:12+00:00\",'+
		'   \"productCompletionDate\": \"\",'+
		'   \"productCancellationDate\": \"2020-12-07T13:40:13+00:00\",'+
		'   \"ServiceActivationDate\": \"2020-12-10T19:01:12+00:00\",'+
		'   \"ServiceDeactivationDate\": \"\",'+
		'   \"DesignCompletionDate\": \"2020-12-2T19:01:12+00:00\",'+
		'   \"InstallationDate\": \"\",'+
		'   \"EquipmentDeliveredDate\": \"2020-12-3T19:01:12+00:00\",'+
		'   \"CustomerOrderAcceptanceDate\": \"2020-12-5T19:01:12+00:00\",'+
		'   \"EstimatedDeliveryDate\": \"2020-12-5T19:01:12+00:00\"'+
		' }'+
		' ]'+
		''+
		'}';
		DatesO2ADTO obj = DatesO2ADTO.parse(json);
		System.assert(obj != null);
	}
}