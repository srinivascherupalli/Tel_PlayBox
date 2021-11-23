({
	closeModalWindow: function (component) {
		//$A.get("e.force:closeQuickAction").fire();
		var modalDiv = component.find('MainDiv');
		$A.util.removeClass(modalDiv, "slds-show");
		$A.util.addClass(modalDiv, "slds-hide");
	},
	redirectToBasket: function (component, basketId) {
		var navigateEvent = $A.get("e.force:navigateToSObject");
		navigateEvent.setParams({
			"recordId": basketId,
			"slideDevName": "detail",
			"isredirect": "true"
		});

		navigateEvent.fire();
	}
})