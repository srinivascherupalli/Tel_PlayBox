({
	doInit: function (component, event, helper) {
		//$A.util.addClass(component.find("mySpinner"), "slds-hide");

		component.set("v.showSpinner1", true);
		var basketId = component.get('v.basketId');
		var accountId = component.get('v.accountId');
		var action = component.get("c.getOpportunityId");
		action.setParams({
			"basketId": basketId
		});

		action.setCallback(this, function (response) {

			var oppId = response.getReturnValue();
			component.set("v.opportunityId", oppId);
			component.set("v.showSpinner1", false);
		});

		$A.enqueueAction(action);

		var action = component.get("c.getAccountDetails");
		action.setParams({
			"basketId": basketId,
			"accountId": accountId
		});
		action.setCallback(this, function (response) {
			var acc = response.getReturnValue();
			component.set("v.acc1", acc);
			component.set("v.accountId", acc.Id)

		});
		$A.enqueueAction(action);
	},
	onCancel: function (component, event, helper) {
		helper.closeModalWindow(component);
	},
	showToolTip: function (component, event, helper) {
		component.set("v.showToolTipBoolean", true);
	},
	hideToolTip: function (component, event, helper) {
		component.set("v.showToolTipBoolean", false);
	},
	onSave: function (component, event, helper) {
		component.set("v.showSpinner1", true);
		var isValid = true;
		component.set("v.isError1", false);
		component.set("v.roleError1", false);
		var conObj = component.get("v.selectedLookUpRecord");
		if (conObj != null || conObj != undefined) {
			if ((conObj.Roles == undefined) || (conObj.Roles == '')) {
				component.set("v.showSpinner1", false);
				component.set("v.isError1", true);
				isValid = false;
			} else if ((conObj.Roles != "Full Authority") && (conObj.Roles != "Legal Lessee")) {
				component.set("v.showSpinner1", false);
				component.set("v.roleError1", true);
				conObj = null;
				isValid = false;
			}
		} else {
			component.set("v.showSpinner1", false);
			component.set("v.isError1", true);
			isValid = false;
		}
		if (isValid) {
			var conId = conObj.ContactId;
			var action = component.get('c.createContactInOpportunity');
			var OppId = component.get("v.opportunityId");
			action.setParams({
				'OppId': OppId,
				'conId': conId
			})
			action.setCallback(this, function (response) {
				//store state of response
				var state = response.getState(); 
				if (state === "SUCCESS") {
					component.set("v.showSpinner1", false);
				}
			});
			$A.enqueueAction(action);

			let basketId = component.get('v.basketId');

			component.find("editForm").submit();

		}

	},
	onSuccess: function (component, event, helper) { 
		let redirectToBasket = component.get('v.redirectToBasket');
		var createEvent = component.getEvent("modifyReasonUpdated");
		createEvent.setParams({
			"redirect": redirectToBasket
		});
		createEvent.fire();
	},
	onError: function (component, event, helper) {
		//event.preventDefault();
	}
})