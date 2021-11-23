({
    doInit : function(component, event, helper) {
        
		let planId = component.get("v.planId");
		
		if(planId){    
			helper.getMaterialGroups(planId, component);
		}else{
			component.set("v.errorMessage", "Plan name is blank, please select plan name first");
		}
	}
})