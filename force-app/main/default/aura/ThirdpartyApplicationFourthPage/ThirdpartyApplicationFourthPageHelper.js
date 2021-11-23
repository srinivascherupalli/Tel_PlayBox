({
	helperMethod : function() {
		
	},
    
     saveRecord : function(component, event) {
        component.find("ApplicantPageFour").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
                 console.log('record Id'+saveResult.recordId);
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
     },
    
     saveRecordandNavigate : function(component, event) {
    	component.find("ApplicantPageFour").saveRecord($A.getCallback(function(saveResult) {
            
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult));
            
                var cmpEvent = component.getEvent("ApplicationBooleanEvent");
                cmpEvent.setParams({
                    "firedComponent" : 5,
                    "appDetails": component.get("v.appDetailsSimple")
                });
                cmpEvent.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult.error));
                component.set("v.recordError",JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
         
     },
       validateForm: function(component, event, helper) {
    	     var validExpense = component.find('expenseform').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            console.log('---check failure--');
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        // If we pass error checking, do some real work
        if(validExpense){
            console.log('---check--');
            this.saveRecordandNavigate(component,event);
        }
    }
    
    
})