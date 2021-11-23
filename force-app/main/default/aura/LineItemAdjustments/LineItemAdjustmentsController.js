/* **************************************************************************
EDGE        -88294
component   -LineItemAdjustmentsController
Description -controller for LineItemAdjustmentsComponent 
Author      -Dheeraj Bhatt
********************************************************************************* */

/*doInit method for getting record On component load */
({
    doInit: function(component, event, helper) {
        component.set("v.recordId",component.get("v.recordId"));
        helper.doInit(component, event, helper);
    },
    /* for closing pop up model*/ 
    cancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    submit:function(component, event, helper){
     helper.helperSubmit(component, event, helper);
}
   })