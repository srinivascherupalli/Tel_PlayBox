({
    selectCase: function(component, event, helper){
		//call the event
		var cmpEvent = component.getEvent("myEvent");
		
		//Pass the selected result(i.e Contact) value
		cmpEvent.setParams({
		"caseByEvent": component.get("v.cas")
		});
		
		//Fire an Event
		cmpEvent.fire();
	}
})