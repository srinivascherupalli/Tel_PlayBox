public with sharing class NewBasketRedirectController_Button {

	public cscfga__Product_Basket__c basket {get; set;}
	public String basketId {get; set;}
	public String basketMap {get; set;}
	
	public NewBasketRedirectController_Button (ApexPages.StandardController c) {
		this.basket = (cscfga__Product_Basket__c)c.getRecord();
		
		String jsn = JSON.serialize(this.basket);
		Map<String, Object> basketSOMap = (Map<String, Object>)JSON.deserializeUntyped(jsn);
		
		Map<String, String> basketMap = new Map<String, String>();
		for (String key : basketSOMap.keySet()) {
			if (key != 'attributes') {
				basketMap.put(key, '' + basketSOMap.get(key));
			}
		}
		
		this.basketMap = JSON.serialize(basketMap);
	}
	
	@RemoteAction
	public static String createBasketRecord (String jsonBasketMap) {
		Map<String, String> basketMap = (Map<String, String>)JSON.deserialize(jsonBasketMap, Map<String, String>.class);
		
		cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
		basket.name = 'New Basket ' + DateTime.now();
		
		for (String fieldName : basketMap.keySet()) {
			basket.put(fieldName, basketMap.get(fieldName));
		}
		
		insert basket;
		
		return basket.id;
	}

}