({
    fetchAllLinkedCases : function(component, event) {

        var _action = component.get("c.fetchAllCaseRecords");
        //Set the Object parameters and Field Set name
        _action.setParams({
            recID : component.get("v.recordId"),
            strObjectName : "Case",
            strFieldSetName : "Salesup_DataTableFieldSet"
        });
        _action.setCallback(this, function(response){
            var state = response.getState();
            var objTemp = [];
            if(state === 'SUCCESS'){
                component.set("v.columns", response.getReturnValue().lstDataTableColumns);
                component.set("v.linkedCases", response.getReturnValue().lstDataTableData); 
            }else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0]);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(_action);
    },

    showToastMessage : function(component, event, typeStr, titleStr, messageStr) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
             "type":typeStr,
             "title": titleStr,
             "message": messageStr
        });
        toastEvent.fire();
    },

    toggle: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})