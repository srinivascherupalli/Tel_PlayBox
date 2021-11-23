({
	doInit : function(component, event, helper) {
		var renderPlanGbbScaleEvent = $A.get("e.c:PLanLevelGbbRender"); 
                    renderPlanGbbScaleEvent.setParams({
                        "showHideScale" :true });
                    renderPlanGbbScaleEvent.fire();
	}
})