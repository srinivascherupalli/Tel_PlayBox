/*
	Author: Dunna, Uday Kumar
	Date: 14/09/2021
*/

@isTest
private class ManageOrderNotificationUtilTest {
	
	@isTest static void test_NotificationAttributesDataObject() {
		ManageOrderNotificationUtil.NotificationAttributesDataObject attrdto = new ManageOrderNotificationUtil.NotificationAttributesDataObject();
        List<ManageOrderNotificationUtil.NotificationAttributes> attrs = new List<ManageOrderNotificationUtil.NotificationAttributes>();
        ManageOrderNotificationUtil.NotificationAttributes attr = new ManageOrderNotificationUtil.NotificationAttributes();
		attr.name = 'status';
		attr.value = 'In Progress';
        attrs.add(attr);
		attrdto.attributes = attrs;
		System.assertEquals('status', attr.name);
		System.assertEquals('In Progress', attr.value);
	}
     
    @isTest static void test_NotificationAttributesDataObjectParse() {
        String json = '{"attributes":[{"name":"status", "value":"In Progress"}]}';
		ManageOrderNotificationUtil.NotificationAttributesDataObject attrdto = new ManageOrderNotificationUtil.NotificationAttributesDataObject();
        attrdto = ManageOrderNotificationUtil.parseAttributes(json);
        System.assertEquals('status', attrdto.attributes[0].name);
		System.assertEquals('In Progress', attrdto.attributes[0].value);
	}
	
	@isTest static void test_NotificationDetailsDataObject() {
		String json = '[{"productId":"1234", "status":"In Progress", "childProduct":[{"productId":"2345", "status":"In Progress"}]}]';		
		List<ManageOrderNotificationUtil.ChildProduct> childprods = new List<ManageOrderNotificationUtil.ChildProduct>();
		ManageOrderNotificationUtil.ChildProduct childprod = new ManageOrderNotificationUtil.ChildProduct();
		List<ManageOrderNotificationUtil.Product> products = new List<ManageOrderNotificationUtil.Product>();
		ManageOrderNotificationUtil.Product product = new ManageOrderNotificationUtil.Product();
		childprod.productId = '2345';
		childprod.status = 'In Progress';
		childprods.add(childprod);
		product.productId = '1234';
		product.status = 'In Progress';
		product.childProduct = childprods;
		products.add(product);
		//String s = JSON.serialize(product);
		System.assertEquals('In Progress', product.status);
		System.assertEquals('In Progress', product.childProduct[0].status);       
	}
 
	@isTest static void test_NotificationDetailsDataObjectParse() {
        String json = '{"product":{"productId":"1234", "status":"In Progress", "childProduct":[{"productId":"2345", "status":"In Progress"}]}}';		
		ManageOrderNotificationUtil.Product products = ManageOrderNotificationUtil.parse(json);
        System.debug('products::'+products);
		System.assertEquals('In Progress', products.status);
		System.assertEquals('1234', products.productId);
		System.assertEquals('In Progress', products.childProduct[0].status);
		System.assertEquals('2345', products.childProduct[0].productId);
	}
}