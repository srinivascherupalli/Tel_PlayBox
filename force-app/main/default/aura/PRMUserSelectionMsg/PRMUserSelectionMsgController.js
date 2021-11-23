({
	doInit : function(component, event, helper) {
        
		var ErrorMsg = component.get("v.ListOfErrorMsg");
        var indexFetch = component.get("v.Index");
        var error = ErrorMsg[indexFetch];
        component.set("v.ErrorDisplay",error);
	}
})