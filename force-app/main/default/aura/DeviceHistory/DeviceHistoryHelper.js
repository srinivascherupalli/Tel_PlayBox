/*----------------------------------------------------------------------
  EDGE        -150172
  Method      -checkLoggedInUser
  Description -check logged user is PRM  or CRM user
  Author      -Dheeraj Bhatt
  -----------------------------------------------------------------------*/
({
    checkLoggedInUser : function(component,event,helper){
        var action=component.get("c.checkForPartnerUser");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.isPartnerUser",response.getReturnValue())
                 component.set("v.loaded",false)
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    }
})