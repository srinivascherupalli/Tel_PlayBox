({
    afterRender : function(component, helper) {
        var ret = this.superAfterRender();
        var action = component.get("c.loggedInAsSysAdmin");
        action.setCallback(this, function(response) {
            //debugger;
            var state = response.getState();                                     
            if (state === "SUCCESS" && response.getReturnValue()) 
            {
                component.set("v.isSysAdminUser",response.getReturnValue());  
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Account"
                });
                createRecordEvent.fire();
            }
        });
        // enqueue the action 
        $A.enqueueAction(action);
        return ret;
    }
})