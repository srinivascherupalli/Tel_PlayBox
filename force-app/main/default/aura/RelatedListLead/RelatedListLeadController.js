({
/*
EDGE-71679 (Related Leads)
Sprint 19.04
Team : SFO (Sravanthi)
*/

    //This function calls helper getData Function to retrieve related leads
    doInit: function(cmp, event, helper) {
        helper.getData(cmp);
    },
    //This function calls helper changeOwner Function to change the owners of the leads in the related list
    handleClickAssign : function(cmp, event, helper) {
        helper.changeOwner(cmp, event, helper);
    },
    //This function is to redirect to the related record on click of the link
    handleClick: function(cmp, event, helper) {
        var evt = $A.get("e.force:navigateToSObject");
        console.log('recId : '+event.target.id);
        evt.setParams({
            "recordId":event.target.id,
            "slideDevName":'related'
        })
        evt.fire();
    },
    //This function is to redirect to view all records functionality ,recalls the same lightning component.
    navigateToMyComponent : function(component, event, helper) {
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:RelatedListLead",
        componentAttributes: {
            ViewAllRec : "false",
            recordId : component.get("v.recordId")
           
        }
    });
    evt.fire();
}
})