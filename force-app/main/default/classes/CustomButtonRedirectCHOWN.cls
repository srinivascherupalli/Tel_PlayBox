/*************************************************************************************************
Name : CustomButtonRedirectCHOWN
TestClass:CustomButtonRedirectCHOWNTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.        Shubhi V            22-Feb-2021       EDGE-152457(new chown)
===============================================================================================================================
***************************************************************************************************/
global with sharing class CustomButtonRedirectCHOWN extends csbb.CustomButtonExt{
	public String performAction(String basketId){
		//String returnString = '';
			cscfga__Product_Basket__c productBasket = Model_ProductBasket.getProductBasket(basketId);
			if(productBasket != null)
			{
				String AccId ='';
                if(productBasket.BasketType__c.equalsIgnoreCase('Outgoing'))AccId=productBasket.csbb__Account__c;
                if(productBasket.BasketType__c.equalsIgnoreCase('Incoming'))AccId=productBasket.csordtelcoa__Previous_Product_Basket__r.csbb__Account__c;
				if(String.isBlank(AccId))return '{"status":"error","text":"Error"}';
                PageReference ref = new PageReference('/apex/MigrateSubscriptions?accountId='+ AccId +'&novation=true'); 
				ref.setRedirect(true);
				return '{"status":"ok","text":"Success", "redirectURL":"' + ref.getUrl() + '"}';     	
			}
			return '{"status":"error","text":"Error"}';
	}

}