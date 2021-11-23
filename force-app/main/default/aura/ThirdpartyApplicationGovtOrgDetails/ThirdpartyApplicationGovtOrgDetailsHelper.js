({
	// really simple function that can be used in every component's helper file to make using promises easier.
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
         component.find("ApplicantGovtdetails").saveRecord($A.getCallback(function(saveResult) {
            
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult));
            
                var cmpEvent = component.getEvent("ApplicationBooleanEvent");
                cmpEvent.setParams({
                    "firedComponent" : 6,
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
    setBooleanValues : function(component,event){
        if(component.get("v.pickyesno")){
        	component.get("v.appDetails").Applicant_owned_whole_partly_by_a_govt__c='Yes';    
        }else{
            component.get("v.appDetails").Applicant_owned_whole_partly_by_a_govt__c='No';
        }
        
        if(component.get("v.Investyesno")){
        	component.get("v.appDetails").Currently_employed_by_govt_political_par__c='Yes';    
        }else{
            component.get("v.appDetails").Currently_employed_by_govt_political_par__c='No';
        }
    },
    validateForm: function(component, event, helper) {
        var validExpense1,validExpense2;
        if(component.get("v.pickyesno"))
        {
    	  	//var govvalue = component.find('expenseform1');
   		  	// var value = component.get('v.value');
            var field1 = component.find('expenseform1');
            console.log(field1.get('v.validity'));
            console.log(field1.get('v.validity').valid);
   			 if(field1.get('v.validity').valid) 
             {
       		 	//continue processing
       		 
                validExpense1='true';
   			 }
            else
            {
             
       		  field1.showHelpMessageIfInvalid();
             
    		}
       	 }
        else
        {
             validExpense1='true';
        }
        
		 if(component.get("v.Investyesno"))
        {  
             var field2 = component.find('expenseform2');
             if(field2.get('v.validity').valid) 
             {
       		 // continue processing
       		 
                 validExpense2='true';
   			 }
            else
            {
              
       		  field2.showHelpMessageIfInvalid();
                
    		}
       	 }
		        else
        {
            validExpense2='true';
        }
      
     
        // If we pass error checking, do some real work
        if(validExpense1 =="true" && validExpense2 =="true")
        {
            //alert('SaveRecod');
            console.log('---check--');
            this.saveRecord(component,event);
        }
    }
    
})