({
    //Publish Event and set the parameters
	handleButtonClick : function(component, event, helper) {
        debugger;
		var appEvent = $A.get("e.c:jprScreenNavigationEvent"); 
        appEvent.setParams({"isPrevious" : "true"}); 
        appEvent.fire();
	}
})