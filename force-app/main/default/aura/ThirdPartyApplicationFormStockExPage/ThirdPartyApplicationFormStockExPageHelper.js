({
    
    executeAction: function(cmp, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var retVal=response.getReturnValue();
                    resolve(retVal);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(Error("Error message: " + errors[0].message));
                        }
                    }
                    else {
                        reject(Error("Unknown error"));
                    }
                }
            });
        $A.enqueueAction(action);
        });
	},
	saveRecord : function(component, event) {
        //alert("in Save");
        component.find("ApplicantThirdExg").saveRecord($A.getCallback(function(saveResult) {
            
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult));
            
                var cmpEvent = component.getEvent("ApplicationBooleanEvent");
                cmpEvent.setParams({
                    "firedComponent" : 3,
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
       // alert("in Validate");
         var validExpense;
         var pick=component.get("v.pickyesno");
        
        if(component.get("v.pickyesno"))
        {
            
             // alert("Testpickyesno");
           validExpense = component.find('expenseform').reduce(function (validSoFar, inputCmp) {
                // Displays error messages for invalid fields
                inputCmp.showHelpMessageIfInvalid();
                //continueExe=false;
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
           }
        	else
            {
                validExpense='true';
             }

        if(validExpense){
            
     validExpense = component.find('expenseformperson').reduce(function (validSoFar, inputCmp) {
                // Displays error messages for invalid fields
              inputCmp.showHelpMessageIfInvalid();
                //continueExe=false;
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
        }
        
  
        /*
        if(component.get("v.InvestBoolean") && validExpense){
            validExpense = component.find('expenseform1').reduce(function (validSoFar, inputCmp) {
                // Displays error messages for invalid fields
                
                inputCmp.showHelpMessageIfInvalid();
                //continueExe=false;
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
       
       
        }
         */
        // If we pass error checking, do some real work
        if(validExpense){
            console.log('---check--');
            
            this.saveRecord(component,event);
        }
       
    }
    
})