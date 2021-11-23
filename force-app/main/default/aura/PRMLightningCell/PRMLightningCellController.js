({
    doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
	navigateToRecord : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        console.log('idx*****'+idx);
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