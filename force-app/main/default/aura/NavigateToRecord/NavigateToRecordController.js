/****************************************************************************
@LastModified:   Sprint 21.03, P2OB-12586 :: Added logic to close the action panel
*****************************************************************************/
({    invoke : function(component, event, helper) {

    // Close the action panel if any opened
    // Added as part of P2OB-12586
    var dismissActionPanel = $A.get("e.force:closeQuickAction");
    dismissActionPanel.fire();
    
    // Get the record ID attribute
    var record = component.get("v.recordId");
    
    // Get the Lightning event that opens a record in a new tab
    var redirect = $A.get("e.force:navigateToSObject");
    
    // Pass the record ID to the event
    redirect.setParams({
        "recordId": record
    });
    
    // Open the record
    redirect.fire();
    
    
}})