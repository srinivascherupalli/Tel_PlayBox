({
    handlePartnerShare : function(component, event, helper) {
		// Close the action panel
		console.log('closure being called********');
        component.set("v.showLoading","false");
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        window.location.reload();
        $A.get("e.force:refreshView").fire();
	},
    
    showSpinner: function (component, event) {
        console.log('showSpinner method being called********'+component.get("v.showLoading"));
        if(component.get("v.showLoading")){
        	component.set("v.showLoading","false");
        }else{
            component.set("v.showLoading","true");
        }
    }
})