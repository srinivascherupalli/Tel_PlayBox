({
	doInit: function (component, event, helper) {
		console.log('isAddress::'+component.get("v.isAddress")+' isContact::'+component.get("v.isContact"));
		var record = component.get('v.selectedRecord');
		//component.set("v.selectedRecord" , record);
		component.set("v.loaded", true);
		component.set("v.mySelectedRecord", record);
		if (component.get('v.selectedRecord') != null) {
			var getSelectRecord = component.get("v.selectedRecord");
			// call the event   
			var compEvent = component.getEvent("oSelectedRecordEvent");
			// set the Selected sObject Record to the event attribute.  
			compEvent.setParams({
				"recordByEvent": getSelectRecord
			});
			// fire the event  
			compEvent.fire();
		}

	},
	onfocus: function (component, event, helper) {
		var forOpen = component.find("searchRes");
		$A.util.addClass(forOpen, 'slds-is-open');
		$A.util.removeClass(forOpen, 'slds-is-close');
		var getInputkeyWord = '';
		helper.searchHelper(component, event, getInputkeyWord);
	},
	onblur: function (component, event, helper) {
		component.set("v.listOfSearchRecords", null);
		var forclose = component.find("searchRes");
		$A.util.addClass(forclose, 'slds-is-close');
		$A.util.removeClass(forclose, 'slds-is-open');
	},
	keyPressController: function (component, event, helper) {
		// get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchKeyWord");
		// check if getInputKeyWord size id more then 0 then open the lookup result List and 
		// call the helper 
		// else close the lookup result List part.   
		if (getInputkeyWord.length > 0) {
			var forOpen = component.find("searchRes");
			$A.util.addClass(forOpen, 'slds-is-open');
			$A.util.removeClass(forOpen, 'slds-is-close');
			helper.searchHelper(component, event, getInputkeyWord);
		} else {
			component.set("v.listOfSearchRecords", null);
			var forclose = component.find("searchRes");
			$A.util.addClass(forclose, 'slds-is-close');
			$A.util.removeClass(forclose, 'slds-is-open');
		}
	},

	// function for clear the Record Selaction 
	clear: function (component, event, heplper) {
		var pillTarget = component.find("lookup-pill");
		var lookUpTarget = component.find("lookupField");

		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set("v.SearchKeyWord", null);
		component.set("v.listOfSearchRecords", null);
		component.set("v.selectedRecord", {});
	},

	// This function call when the end User Select any record from the result list.   
	handleComponentEvent: function (component, event, helper) {
		var selectedAccountGetFromEvent = event.getParam("recordByEvent");
		component.set("v.selectedRecord", selectedAccountGetFromEvent);

		var forclose = component.find("lookup-pill");
		$A.util.addClass(forclose, 'slds-show');
		$A.util.removeClass(forclose, 'slds-hide');

		var forclose = component.find("searchRes");
		$A.util.addClass(forclose, 'slds-is-close');
		$A.util.removeClass(forclose, 'slds-is-open');

		var lookUpTarget = component.find("lookupField");
		$A.util.addClass(lookUpTarget, 'slds-hide');
		$A.util.removeClass(lookUpTarget, 'slds-show');

	},
})