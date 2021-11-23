({
    /*
    EDGE-84140 (ACR Edit layout)
    Sprint 19.07
    Team : SFO (Subani & Sravanthi)
    @Last Modified By: Sri Chittoori(Team SFO)               
    @Last Modified Comments: EDGE-104316
    */
    //This function calls helper getPrimaryACRData Function to retrieve related Account Contact record for this contact.
    doInit: function(component, event, helper) {
        helper.getPrimaryACRData(component);                
    },
    //This function is initiated on press of edit button and switches the component view to edit form.
    edit : function(component, event, helper) {
       helper.fireEditAccessEvent(component, event);
    },
    //This function is initiated on press of save button and this initiates save action on acr
    save : function(component, event, helper) {
        component.find("edit").get("e.recordSave").fire();            
    },
    //Toast message on succesfull record update.
    handleSaveSuccess : function(component, event, helper) {           
        $A.get("e.force:closeQuickAction").fire();        
        $A.get("e.force:refreshView").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "ACR record has been updated successfully.",
            "type" : "Success"
        });
        toastEvent.fire();
        helper.fireRefreshChildcomponentEvent(component, event);
        component.set("v.isEdit", false);        
    },
    //This triggers from quickaction to close the pop up on press of cancel button.
    cancel: function(component, event, helper) {
        component.set("v.isEdit", false);
        $A.get("e.force:closeQuickAction").fire();
    },
    //Spinner functionality
    showSpinner:function(cmp){
        cmp.set("v.IsSpinner",true);
    },
    //Spinner functionality
    hideSpinner:function(cmp){        
        cmp.set("v.IsSpinner",false);        
    },
    
})