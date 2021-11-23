({
    callApex: function(component, event, helper) {
        var parameters = helper.getParameteres(component, event);
        var callerComponent = parameters.component;
        var params = parameters.params;
        var controllerMethod = parameters.controllerMethod;
        return new Promise($A.getCallback(function(resolve, reject) {
            helper.submitToSF(resolve, reject,callerComponent, controllerMethod,params);
        }));
    },
     showToast: function(component, event, helper,mode, type, message) {
        var parameters = helper.getParameteres(component, event);
        var params = parameters.params;
        console.log(params);
        // var controllerMethod = parameters.controllerMethod;
        helper.showToast(params);
    },
    showNotice: function(component, nHeader, nVariant, syserr) {
        var parameters = helper.getParameteres(component, event);
        var nHeader = parameters.nHeader;
        var nVariant = parameters.nVariant;
        var syserr = parameters.syserr;
        component.find("notifLib").showNotice({
            header: nHeader,
            variant: nVariant,
            message: syserr
        });
    },

})