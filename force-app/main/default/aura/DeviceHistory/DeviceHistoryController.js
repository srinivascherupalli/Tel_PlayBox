({ 
    doInit : function(component,event,helper){
        helper.checkLoggedInUser(component,event,helper);
    },  
 /*----------------------------------------------------------------------
 EDGE        -150172
 Method      -closeModal
 Description -close Modal on click of close icon on Modal
 Author      -Dheeraj Bhatt
 -----------------------------------------------------------------------*/
    closeModel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})