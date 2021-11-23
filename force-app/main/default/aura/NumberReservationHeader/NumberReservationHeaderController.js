({
	doInit : function(component, event, helper) {
        component.set("v.selectedtabId","Mobile");
		helper.handleClickedTab(component, event, helper);
	},
    handleClickedTab : function(component, event, helper) {
		helper.handleClickedTab(component, event, helper);
	},
    closeMainPopup : function(component, event, helper) {
		helper.closeMainPopup(component, event);
	}
})