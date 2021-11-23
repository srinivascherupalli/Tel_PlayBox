({
	doInit : function(component, event, helper) {
        //alert("Inside doInit -> RecordId = " + component.get("v.recordId"));
		helper.processEndDatedFCR(component, event, helper);
	}
})