/*************************************************************************************************************************************************
 * Name			:	AfterValidationSyncOperations
 * Description	:	Used to Sync the product basket configuration attributes with the opportunity.
					Invoked from class CustomButtonOpportunitySync_v2
	Sr.No.  Developer Name      Date          Story         Description
	1.      Gnana               30/06/2020    EDGE-151354   Added logic for Device Care Contact Details
	2.      Pooja Bhat			22/09/2020    EDGE-178203   Technical Refactoring - Opportunity Sync - DML Operations
**************************************************************************************************************************************************/
public with sharing class AfterValidationSyncOperations {
	public String syncMsg = '';
	public cscfga__Product_Basket__c productBasket = new cscfga__Product_Basket__c();
	/*	* Constructor   :   AfterValidationSyncOperations
		* Params		:   cscfga__Product_Basket__c
	*/
	public AfterValidationSyncOperations(cscfga__Product_Basket__c oPB) {
		this.productBasket = oPB;        System.debug('AfterValidationSyncOperations currProductBasket***' + productBasket);
	}
	/*  * Method Name   :   performBasketUnsync
		* Purpose       :   Desyn the Product Basket details, OLI deletion logic is handled from ProductBasketTrigger after technical refactoring.
		* Params        :   none
		* Return Type   :   String
		* Called from   :   CustomButtonOpportunitySync_v2 
	*/
	public String performBasketUnsync() {
		doProductBasketSyncUnsync(false);
		checkforDCCRequired();
		updateProductBasket();
		return syncMsg;
	}	//End of performBasketUnsync()
	/*  * Method Name   :   performBasketSync
		* Purpose       :   Resync the Product Basket and setting primary basket flag to true. Below mentions logic is handled from ProductBasketTrigger after technical refactoring.
								a. New OLI's creation
								b. Updating parent Opportunity Details
								c. Desyncing of the other baskets(if any) related with the same parent opportunity.
		* Params        :   none
		* Return Type   :   String
		* Called from   :   CustomButtonOpportunitySync_v2 
	*/
	public String performBasketSync() {
		doProductBasketSyncUnsync(true);
		updateProductBasket();
		return syncMsg;
	}	//End of performBasketSync
	/*	* Method Name   :   doProductBasketSyncUnsync
		* Purpose       :   Set/Unset the basket Sync fields and Primary Basket field on Product Basket record
		* Params        :   boolean
		* Return Type   :   void
		* Called from   :   Class AfterValidationSyncOperations -> method executeActions()
	*/
	public void doProductBasketSyncUnsync(Boolean isSync) {
		productBasket.csbb__Synchronised_with_Opportunity__c        =   isSync;
		productBasket.csordtelcoa__Synchronised_with_Opportunity__c =   isSync;

        if(isSync){
            productBasket.Primary_Basket__c                         =   true;
        }

	}   //End of doProductBasketSyncUnsync()
	/*	* Method Name   :   checkforDCCRequired
		* Purpose       :   Update basket field Is_Device_Care_Contact_Required__c = Yes, if basket include any configuration with
							Type = New and PD = Mobile Device Care and 
		* Params        :   none
		* Return Type   :   void
		* Called from   :   Class AfterValidationSyncOperations -> method executeActions()
		* Disclaimer    :   Added as part of EDGE-151354
	*/
	public void checkforDCCRequired() {
		List<cscfga__Product_Configuration__c> configList = [SELECT Id,cscfga__Product_Definition__r.Name,Type__c FROM cscfga__Product_Configuration__c 
																WHERE cscfga__Product_Basket__c = :productBasket.Id 
																AND cscfga__Product_Definition__r.name = 'Mobile Device Care'
																AND Type__c = 'New'];
		if(!configList.isEmpty() && configList.size() > 0) {
			productBasket.Is_Device_Care_Contact_Required__c = 'Yes';
		}
	}   //End of checkforDCCRequired()
	/*	* Method Name   :   updateProductBasket
		* Purpose       :   Perform update operation on basket and return error message to Basket Page(if any)
		* Params        :   none
		* Return Type   :   void
		* Called from   :   Class AfterValidationSyncOperations -> method executeActions()
	*/
	public void updateProductBasket() {
		try {
			if(productBasket.Id!=null && !Approval.isLocked(productBasket.Id)) {
				update productBasket;
				String oppRedirectURL	=	'';
				if(productBasket.cscfga__Opportunity__c!=null) {
					Opportunity opp		=	new Opportunity(Id=productBasket.cscfga__Opportunity__c);	
					oppRedirectURL		= 	new ApexPages.StandardController(opp).view().getURL();
				}
				syncMsg = '{"status":"ok","text":"Basket sync with Opportunity completed successfully","redirectURL":"' + oppRedirectURL + '"}';
			}
		} catch (Exception e) {
			String displayMessage = e.getMessage();
			if(displayMessage == null || displayMessage.contains('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY') || displayMessage.contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY')) {
				syncMsg = '{"status":"error","text":"Only the opportunity owner can sync the product basket"}';
			}
		}
	}   //End of updateProductBasket()
}   //End of class AfterValidationSyncOperations