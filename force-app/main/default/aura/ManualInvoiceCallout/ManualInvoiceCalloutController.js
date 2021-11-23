({
	doInit : function(component, event, helper) {
		
        component.set("v.caseId",component.get("v.recordId"));
       helper.initHelper(component,event,helper);
	}
})