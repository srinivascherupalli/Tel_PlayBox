({
    //EDGE -66472/84934/66471, initialise component
    doInit : function(component, event) {
        var key = component.get("v.key");
        var map = component.get("v.map");
        component.set("v.value" , map[key]);
    },
    //EDGE -66472/84934/66471, Action on confirm appt
    confirmAppt: function(component, event)
    {
        var key = event.currentTarget.name;
        var dateslot = event.currentTarget.title;
        var timeslot = event.currentTarget.value;
        
        var appEvent = $A.get("e.c:ConfirmAppointment");
        appEvent.setParams({"slotKey" : key });
        appEvent.setParams({"startDateSlot" : dateslot });
        appEvent.setParams({"slotTime" : timeslot });
        appEvent.fire();
    }
})