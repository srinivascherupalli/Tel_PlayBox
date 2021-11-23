/*
Name : CustomlookupResult Helper
Description : Lightning Helper functions for Post verificatio of numbers 
Author: Kalashree Borgaonkar
Story: EDGE-90327
*/
({
	helperMethod : function() {
		
	},
    addNewRecord: function(component, event, helper) {
        console.log('Inside addNewRecord');
        if (!component.get('v.allowNewRecords')) {
            return;
        }

        var addRecordEvent;
        var overrideNewEvent = component.get('v.overrideNewEvent');
		console.log(overrideNewEvent);
        if (overrideNewEvent) {
            console.log('Inside if');
            // Start US - 3971
            var inputSearchText = component.find('lookupInput').getElement().value;
            //helper.navigateSiteAddressCustom(component, event, helper,inputSearchText);
            // End
            event.preventDefault();
        	event.stopPropagation();
        } else {
            console.log('Inside else');
            addRecordEvent = $A.get('e.force:createRecord');
            console.log(component.get('v.object'));
            addRecordEvent.setParams({
                "entityApiName": component.get('v.object')
            });
            console.log(addRecordEvent);
            addRecordEvent.fire();
        }
        helper.closeMenu(component, event, helper);
		component.getEvent("customOnUpdateEvent").fire();
    },
    closeMenu: function(component, event, helper) {
        component.set('v.focusIndex', null);
        component.set('v.openMenu', false);
    }
})