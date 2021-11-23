({
/*
EDGE-71679 (Related Leads)
Sprint 19.04
Team : SFO (Sravanthi)
*/
    //This helper functions calls internal function enqueueAction with the parameters set
    getData: function(cmp){
        if(cmp.get("v.ViewAllRec")==null){
            cmp.set("v.ViewAllRec","true")
        }
        console.log('account id in js' + cmp.get("v.recordId"));
        var params = { recordId: cmp.get("v.recordId") };
        this.enqueueAction(cmp, "getData", params, this.setData);
    },
    //This helper function helps parse the lead list 
    setData: function(cmp, data){
        
        cmp.set("v.data", JSON.parse(data));
    },
    //This helper function calls the controller(FindRelatedLeadsController) method to get related lead data 
    enqueueAction: function(cmp, method, params, callback){
        var action = cmp.get("c." + method); 
        if(params) action.setParams(params);
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS") {
                if(callback) callback.call(this, cmp, response.getReturnValue());
            } else if(response.getState() === "ERROR") {
            }
        });
        $A.enqueueAction(action);
    },
    //This helper function calls the controller(FindRelatedLeadsController) method to change the owner of the leads
    changeOwner : function(cmp, event, helper){
        var params = { recordId: cmp.get("v.recordId") };
        var action = cmp.get("c.changeOwner"); 
        action.setParams(params);
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue()){                	
                    $A.get("e.force:refreshView").fire();
                    this.showToast(cmp, event, helper); 
                }
                else if(!response.getReturnValue()){                	
                    $A.get("e.force:refreshView").fire();
                    this.showToastFalse(cmp, event, helper); 
                }
            } else if(response.getState() === "ERROR") {
                $A.get("e.force:refreshView").fire();
                this.showToastError(cmp, event, helper);                 
            }
        });
        $A.enqueueAction(action);		
    },
    //Toast message on succesfull owner change
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Lead owner has been updated successfully."
        });
        toastEvent.fire();
    },
    //Toast message when no leads match the criteria to change the owner
    showToastFalse : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": "No leads present in the queue"
        });
        toastEvent.fire();
    },
    //Toast message when there is sone technical error in changing the lead owner
    showToastError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error !",
            "message": "Unable to assign leads from the queue. Please retry. If error persists, click the feedback tab to create a case for Phoenix support to analyse the issue"
        });
        toastEvent.fire();
    }
})