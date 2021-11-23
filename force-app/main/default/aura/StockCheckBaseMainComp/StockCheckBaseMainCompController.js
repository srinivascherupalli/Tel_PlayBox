({
	onChange : function(component, event, helper) {
		component.set("v.type",event.getSource().get("v.value"));//DPG-3510
	}
})