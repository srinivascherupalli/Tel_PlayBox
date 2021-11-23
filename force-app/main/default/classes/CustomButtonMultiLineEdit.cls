/*************************************************************************************************
Name : CustomButtonMultiLineEdit 
Description : Class called when add products button is clicked on the basket page to open the
              MLE Screen 
Test Class : CustomButtonMultiLineEditTest.apxc
Sr.No.    Developer Name      Date          Story Description
1.        Laxmi Rahate      20/03/2019      EDGE-73848 Assigned variable prodDefnId to Null- This was reported as Bug in Sonar Sheet. 
2.		  Laxmi Rahate      20/03/2019      EDGE-73848 Assigned variable flowId to Null- This was reported as Bug in Sonar Sheet. 
**************************************************************************************************/
global with sharing class CustomButtonMultiLineEdit extends csbb.CustomButtonExt{

    public String performAction (String basketId, String pcrIds){
     
        //String productName = 'Current Product Catalog';
	    String productName = 'Mobility';
        String screenFlowName ='MLEScreen';
        Id prodDefnId = null ; // Sr. No 1 
        Id flowId = null; // Sr. No 2 

		
		
        try{

			String productCheck = checkProductsInBasket(basketId, productName);
			if (productCheck != null)
			{
				return productCheck;
			}

            //Query the product definition named Current Product Catalog
			//EDGE-57213 changed to Mobility Product Definition
			cscfga__Product_Definition__c prodDefn = checkProductDefiniton(productName);		
            if (prodDefn == null)
			{
				return '{"status":"error", "text":"Please check the Mobility Product Definition"}';
			}
			prodDefnId = prodDefn.Id;
            //Query the ScreenFlow Product Association object with product definition as above and screen flow name as  MLE Screen
			cscfga__Screen_Flow_Product_Association__c flowAssociation = checkScreenFlowAssociation(screenFlowName, prodDefn.Id);
            if (flowAssociation == null)
			{
				return '{"status":"error", "text":"Please check the Mobility Product Definition"}';
			}
            flowId = flowAssociation.cscfga__Screen_Flow__c;
         
			PageReference mle = new PageReference('/apex/csmle__Editor?id=' + basketId + '&productDefinitionId='+prodDefnId+'&screenFlowId='+flowId+'&cssoverride=/resource/MLEHideButtonsCSS');
			//PageReference mle = new PageReference('/apex/csmle__Editor?id=' + basketId + '&productDefinitionId=a3V2O0000008XZmUAM&screenFlowId=a3b2N0000000BMc');
			return '{"status":"ok","text":"Launching Bulk Edit UI.....","redirectURL":"' + mle.getUrl() + '"}';
        }
        catch(Exception e)
        {
            return '{"status":"error", "text":"Please check the Product Definition and ScreenFlow Association"}';
        }  
    
	}

	@TestVisible
	private cscfga__Product_Definition__c checkProductDefiniton(string productName)
	{
		List<cscfga__Product_Definition__c> prodDefn = [Select Id from cscfga__Product_Definition__c where Name =:productName];
		if(prodDefn.size()>0)
		{
			return prodDefn[0];
		}
		else 
		{
			return null;
		}
		
	}

	@TestVisible
	private cscfga__Screen_Flow_Product_Association__c checkScreenFlowAssociation(String screenFlowName, Id prodDefnId)
	{
		List<cscfga__Screen_Flow_Product_Association__c> flowAssociation = [Select Id,cscfga__Screen_Flow__c from cscfga__Screen_Flow_Product_Association__c where cscfga__Screen_Flow_Name__c=:screenFlowName and cscfga__Product_Definition__c=:prodDefnId];
         
		if(flowAssociation.size()>0)
		{
			return flowAssociation[0];
		}
		else 
		{
			return null;
		}
	}

	@TestVisible
	private String checkProductsInBasket(String basketId, String productName)
	{
		Id convertedBasketId = Id.valueOf(basketId);
		List<cscfga__Product_Configuration__c> productConfigList = [SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.Name =: productName AND cscfga__Product_Basket__r.Id =: convertedBasketId];
		if (productConfigList.size()>0)
		{
			return null;
		}
		else{
			return '{"status":"error", "text":"' + Label.No_Mobility_Products_In_Basket + '"}';
		}
	}

}