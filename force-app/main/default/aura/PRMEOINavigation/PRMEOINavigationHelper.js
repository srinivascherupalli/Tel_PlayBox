({
	fireEvent : function(step) {          
		var appEvent = $A.get("e.c:PRMEOIEvent");
        console.log("firing");
        appEvent.setParams({
            "data" : step
            });
        appEvent.fire();

	}
})