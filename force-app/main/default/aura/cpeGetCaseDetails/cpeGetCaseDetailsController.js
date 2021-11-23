({
    handleRequestOrder : function(component, event, helper) {
        component.set('v.requestType','');
        component.set('v.requestType','Request Order');
    },

    handleRequestReQuote : function(component, event, helper) {
        component.set('v.requestType','Request Re-Quote');
        helper.handleFlowScreen(component, event, helper, 'ReQuote');
    },

    handleReject : function(component, event, helper) {
        component.set('v.requestType','Reject');
        helper.handleFlowScreen(component, event, helper, 'Reject');

    },

    closeModel: function(component, event, helper) {
        component.set('v.isOpen', false);
        component.set('v.showBtn', false);
    },

     //handle callback from flow
     handleStatusChange : function (component, event) {
        
        component.set("v.spinner",false);
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED") {
            
            component.set("v.showOrbBtn",false);
            component.set("v.isOpen",false);
            var varMessage = '';
            if(component.get("v.requestType") === "Request Re-Quote")
                varMessage = 'Quote line Item Record Created Successfully';
            else if(component.get("v.requestType") === "Request Re-Quote")
                varMessage = 'Record Updated Successfully';
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Success!",            
                "message": varMessage,
                "type": "Success",
                "duration":" 4000"
            });
            toastEvent.fire();
        }
        else if(event.getParam("status") === "ERROR") {
            component.set("v.showOrbBtn",false);
            component.set("v.isOpen",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Error!",            
                "message": "Please review and try again",
                "type": "error",
                "duration":" 4000"
            });
            toastEvent.fire();
        }else if( event.getParam("status") === "STARTED"){
            component.set('v.showBtn', true);
        }
    },
})