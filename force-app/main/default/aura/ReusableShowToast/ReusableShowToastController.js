({
    doInit : function(component, event, helper) {
        //This is a reusable component for showing toast messages, created as part of US EDGE-167051
        //Valid values for Type are success, error, info and warning
        var message = component.get("v.message");
        var type = component.get("v.type");
        var dur = component.get("v.duration");
        var mode = component.get("v.mode");
        helper.showToast(type,message,dur,mode);
    }
})