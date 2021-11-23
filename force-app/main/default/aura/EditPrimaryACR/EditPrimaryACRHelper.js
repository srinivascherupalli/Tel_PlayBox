({
    /*
    EDGE-84140 (ACR Edit layout)
    Sprint 19.07
    Team : SFO (Subani & Sravanthi)
@Last Modified By: Sri Chittoori(Team SFO)               
@Last Modified Comments: EDGE-104316
    */

    //This helper functions calls internal function enqueueAction with the parameters set.
    getPrimaryACRData: function(cmp){        
        console.log('account id in js' + cmp.get("v.recordId"));
        var params = { recordId: cmp.get("v.recordId") };
        this.enqueueAction(cmp, "getACRRecordAccess", params, this.getPrimaryACRAccess);
        this.enqueueAction(cmp, "getPrimaryACRData", params, this.setData);
    },
    getPrimaryACRAccess: function(cmp, data){
        cmp.set("v.hasEditAccess", data);
    },
    //This helper function helps parse the ACR record 
    setData: function(cmp, data){      
        cmp.set("v.data", JSON.parse(data));
        cmp.set("v.editActive", true);
    },
    //This helper function calls the controller(FindRelatedACR.getPrimaryACRData) method to get related Primary ACR data 
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
    //This helper function is used to publish event "refreshChildComponent" to refresh ViewRelatedACR component.
    fireRefreshChildcomponentEvent:function(cmp, event) {
        var compEvents = $A.get("e.c:refreshChildComponent");
        compEvents.setParams({ "context" : "parentName" });
        compEvents.fire();
    },
    
    //This helper function is used to controle EDIT ACCESS.
    fireEditAccessEvent:function(cmp, event) {
         var allowEdit  = cmp.get("v.hasEditAccess")
        if(!allowEdit){            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Looks like there's a problem.",
                "message": "You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.",
                "type" : "Error"
            });
            toastEvent.fire(); 
        }
        else{            
	        cmp.set("v.isEdit", true);
        }
    }
       
})