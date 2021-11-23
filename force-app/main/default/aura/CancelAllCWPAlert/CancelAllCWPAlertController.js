({
    doInit : function(component, event, helper) {
    },
    onCancel : function(component, event, helper) {
        //console.log('****cancel event****' , event);
        var proceed=false;
        var createEvent = component.getEvent("alertCancelAllCWP");
        console.log('proceed'+proceed);
        createEvent.setParam("proceed", proceed);
        createEvent.fire();
        helper.closeModalWindow(component);
        //console.log('****after cancel event****' , event);
    },
    onConfirm : function(component, event, helper){
        //console.log('****success event****' , event);
        component.set("v.proceedToCancellation",true);
        var createEvent = component.getEvent("alertCancelAllCWP");
        createEvent.setParams({ "proceed": true });
        createEvent.fire();
    },
    onError  : function(component, event, helper) {
        //console.log('****error event****' , event);
    }
})