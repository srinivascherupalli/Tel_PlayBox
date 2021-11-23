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
        component.find("ApplicantThird").saveRecord($A.getCallback(function(saveResult) {
            
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
                console.log('Problem saving record, error: ' + 
                           JSON.stringify(saveResult));
            /*
                var cmpEvent = component.getEvent("ApplicationBooleanEvent");
                cmpEvent.setParams({
                    "firedComponent" : 4,
                    "appDetails": component.get("v.appDetailsSimple")
                });
                cmpEvent.fire();
              */
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
        if(component.get("v.litigationBoolean")){
        	component.get("v.appDetails").Civil_criminal_litigation_charges__c='Yes';    
        }else{
            component.get("v.appDetails").Civil_criminal_litigation_charges__c='No';
        }
        
        if(component.get("v.InvestBoolean")){
        	component.get("v.appDetails").Pending_government_investigations__c='Yes';    
        }else{
            component.get("v.appDetails").Pending_government_investigations__c='No';
        }
        if(component.get("v.InvestagationBoolean")){
        	component.get("v.appDetails").Violated_rules_govening_bus_practices__c='Yes';    
        }else{
            component.get("v.appDetails").Violated_rules_govening_bus_practices__c='No';
        }
        if(component.get("v.onaBoolean")){
        	component.get("v.appDetails").On_a_govt_or_sanctioned_party_watchlist__c='Yes';    
        }else{
            component.get("v.appDetails").On_a_govt_or_sanctioned_party_watchlist__c='No';
        }
        if(component.get("v.susBoolean")){
        	component.get("v.appDetails").Suspended_ineligible_for_govt_contract__c='Yes';    
        }else{
            component.get("v.appDetails").Suspended_ineligible_for_govt_contract__c='No';
        }
    },
    setBooleanForLitigation :function(component,event){
    	var changeValue = event.getParam("value");
        //alert(changeValue);
		   console.log(event.getSource().getLocalId());
        
            if(changeValue=="Yes"){
             //   alert("selectted yes");
                component.set("v.litigationBoolean", true);  
            }else{
                component.set("v.litigationBoolean", false);  
            }
            
    },
    setBooleanForInvestigation :function(component,event){
    	var changeValue = event.getParam("value");
        //alert(changeValue);
		console.log(event.getSource().getLocalId());
       // if(){    
            if(changeValue=="Yes"){
             	component.set("v.InvestBoolean", true);  
            }else{
                component.set("v.InvestBoolean", false);  
            }
        //}    
    },
    setBooleanForInvestigationQue1 :function(component,event){
    	var changeValue = event.getParam("value");
        //alert(changeValue);
		console.log(event.getSource().getLocalId());
       // if(){    
            if(changeValue=="Yes"){
             //   alert("selectted yes");
                component.set("v.InvestagationBoolean", true);  
            }else{
                component.set("v.InvestagationBoolean", false);  
            }
       // }    
    },
    setBooleanForInvestigationQue2 :function(component,event){
    	var changeValue = event.getParam("value");
        //alert(changeValue);
		console.log(event.getSource().getLocalId());
       // if(){    
            if(changeValue=="Yes"){
             //   alert("selectted yes");
                component.set("v.onaBoolean", true);  
            }else{
                component.set("v.onaBoolean", false);  
            }
       // }    
    },
    setBooleanForInvestigationQue3 :function(component,event){
    	var changeValue = event.getParam("value");
        //alert(changeValue);
		console.log(event.getSource().getLocalId());
       // if(){    
            if(changeValue=="Yes"){
             //   alert("selectted yes");
                component.set("v.susBoolean", true);  
            }else{
                component.set("v.susBoolean", false);  
            }
       // }    
    },
    validateForm: function(component, event, helper) {
        var validExpense;
           
        if(component.get("v.litigationBoolean"))
        {
            
             // alert(validExpense1);
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
        if(component.get("v.InvestBoolean") && validExpense){
            validExpense = component.find('expenseform1').reduce(function (validSoFar, inputCmp) {
                // Displays error messages for invalid fields
                
                inputCmp.showHelpMessageIfInvalid();
                //continueExe=false;
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
           
        
        if(component.get("v.InvestagationBoolean") && validExpense){
            validExpense = component.find('Governingform1').get('v.validity').valid;
            component.find('Governingform1').showHelpMessageIfInvalid();    
        }
        if(component.get("v.onaBoolean") && validExpense){
            validExpense = component.find('WatchLstform1').get('v.validity').valid;
             component.find('WatchLstform1').showHelpMessageIfInvalid();  
            
        }
        if(component.get("v.susBoolean") && validExpense){
            validExpense = component.find('suspensionform1').get('v.validity').valid;
            component.find('suspensionform1').showHelpMessageIfInvalid(); 
            
        }
        }
        // If we pass error checking, do some real work
        if(validExpense){
            console.log('---check--');
            
            this.saveRecord(component,event);
        }
    }
})