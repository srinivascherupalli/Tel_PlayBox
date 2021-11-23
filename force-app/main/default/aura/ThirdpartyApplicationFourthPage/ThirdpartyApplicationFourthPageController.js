({
	 doInit: function(component,event,helper) {
    	var action=component.get("c.getData");
        console.log('--- rec id'+component.get("v.recordId"));
        action.setParams({"fieldSetname":component.get("v.FieldsetName"),
                          "recordid":component.get("v.recordId")
                          });
        action.setCallback(this, function(response){
        var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.queAndAns",response.getReturnValue());
                console.log('chec vals--'+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSaveRecord: function(component, event, helper) { 
        helper.saveRecord(component,event);
    },
  
   navigateToMyComponent : function(component, event, helper) 
    { var validExpense1;
   		// helper.validateForm(component,event,helper);
        var validExpense = component.find('expenseform');
        //alert('validExpense'+validExpense);
     validExpense1= component.find('expenseform').reduce(function (validSoFar, inputCmp)
                 {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            console.log('---check failure--');
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        // If we pass error checking, do some real work
        if(validExpense1){
            console.log('---check--');
           
            helper.saveRecordandNavigate(component,event);
        }
       
    },
    
})