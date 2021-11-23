({
	init : function(component, event, helper) {
        helper.isPartnerLoggedIn(component, event, helper);
        helper.getTableFieldSet(component, event, helper);
        helper.getPlanId(component,event,helper);
    },
    navigateToRecord : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: idx,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
    }
})