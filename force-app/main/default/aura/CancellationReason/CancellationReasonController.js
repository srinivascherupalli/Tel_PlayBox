({
	doInit: function (component, event, helper) {
		//$A.util.addClass(component.find("mySpinner"), "slds-hide");

		component.set("v.showSpinner1", true);
		var basketId = component.get('v.basketId');
		var accountId = component.get('v.accountId');
		var selectedrecord = component.get("v.selectedLookUpRecord");
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
		component.set("v.loaded", true);
		helper.isCancelationNBN(component, event, helper);
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
		component.set("v.isError", false);
		component.set("v.roleError", false);
        component.set("v.isEmpty_CancelReason", false);
		/* This Logic is added as Part of EDGE-> 63041 to Create Contact Role on Opportunity */
		var conObj = component.get("v.selectedLookUpRecord");
        /* EDGE-74980 - Making Cancellation Reason Field Mandatory*/
        component.set("v.isEmpty_CancelReason", false);
        const cancelReason = component.find("Input_Cancellation_Reason__c").get('v.value');
		//set the default accountId is null 
		// check if selectedLookupRecord is not equal to undefined then set the accountId from 
		// selected Lookup Object to Contact Object before passing this to Server side method
		if (conObj != null || conObj != undefined) {
			if ((conObj.Roles == undefined) || (conObj.Roles == '')) {
				component.set("v.showSpinner1", false);
				component.set("v.isError", true);
				isValid = false;
			} else if ((conObj.Roles != "Full Authority") && (conObj.Roles != "Legal Lessee")) {
				component.set("v.showSpinner1", false);
				component.set("v.roleError", true);
				conObj = null;
				isValid = false;
			}
            if(cancelReason == '' || cancelReason == null){
                component.set("v.showSpinner1", false);
                component.set("v.isEmpty_CancelReason", true);
                isValid = false;
            }
		} else {
			component.set("v.showSpinner1", false);
			component.set("v.isError", true);
			isValid = false;

		}

		if (isValid) {
			//call apex class method
			var conId = conObj.ContactId;
			//call apex class method
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
		//event.preventDefault();

		let redirectToBasket = component.get('v.redirectToBasket');
		var createEvent = component.getEvent("cancellationReasonUpdated"); // updated for EDGE-151654
		createEvent.setParams({
			"redirect": redirectToBasket
		});
		createEvent.fire();
	},
	onError: function (component, event, helper) {
		//event.preventDefault();
	},
    showRequiredFields: function(component, event, helper){
        $A.util.removeClass(component.find("Input_Cancellation_Reason__c"), "none");
    }
})