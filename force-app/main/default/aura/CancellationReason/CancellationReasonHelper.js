({
	closeModalWindow: function (component) {
		//$A.get("e.force:closeQuickAction").fire();
		var modalDiv = component.find('MainDiv');
		$A.util.removeClass(modalDiv, "slds-show");
		$A.util.addClass(modalDiv, "slds-hide");
		// console.log('Modal window closed!');
	},
	redirectToBasket: function (component, basketId) {
		var navigateEvent = $A.get("e.force:navigateToSObject");
		navigateEvent.setParams({
			"recordId": basketId,
			"slideDevName": "detail",
			"isredirect": "true"
		});

		navigateEvent.fire();
	},
	//EDGE - 77981
	isCancelationNBN: function (component, event, helper) {
		var basketId = component.get('v.basketId');
		
		var action = component.get("c.isCancelationNBN");
		action.setParams({
			"basketId": basketId,
		});
		action.setCallback(this, function (response) {
			var cancelNBN = response.getReturnValue();
			component.set("v.showOnlyCancelNBN", cancelNBN);
			console.log('NBNFlag=='+component.get("v.showOnlyCancelNBN"));
		});
		$A.enqueueAction(action);
	}
})