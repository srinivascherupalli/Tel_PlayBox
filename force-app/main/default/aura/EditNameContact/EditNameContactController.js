({
	//To Handle Record Edit Form Success
	handleSuccess : function(component, event, helper) {
        helper.showToast('', 'Success', $A.get("$Label.c.ContactUpdateSccess"));
        helper.showHide(component);
    },
	//To Handle Record Edit Form Cancel
    handleCancel : function(component, event, helper) {
        helper.showHide(component);
        event.preventDefault();
    },
	//Fetching Current Contact Details
    getContactRecordDetails : function(component, event, helper) {
		var action = component.get("c.getContactDetails");
        action.setParams({"recordId":component.get("v.recordId")});
        var p = helper.executeAction(component, action);
        // use the promise to do something 	
        p.then($A.getCallback(function(result){
            console.log('--- Contact result '+JSON.stringify(result))
            component.set("v.contactInfo",result.con);
            component.find("ContactID").set("v.value", result.con.Id);
           })).catch($A.getCallback(function(error){
            // Something went wrong
            alert('An error occurred : ' + error.message);
        }));
          // EDGE-176104 Added for Active POR flag check
        var action1 = component.get("c.getporofcontact");
        action1.setParams({"contactId":component.get("v.recordId")});
        var p1 = helper.executeAction(component, action1);
        // use the promise to do something 	
         //   Boolean isPartnerOfRecord;//Default value 
      // Boolean isPartner;//Default value 
        p1.then($A.getCallback(function(result1){
         console.log('--- ActivePOR result '+JSON.stringify(result1));
         component.set("v.ActivePOR", result1.isPartnerOfRecord); 
         component.set("v.isPartner", result1.isPartner); 

            var action = component.get("v.ActivePOR");
            if(action)
            {
                setTimeout(()=>{
                let quickActionClose = $A.get("e.force:closeQuickAction");
                quickActionClose.fire();
              },100);
                  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Only Partners of Record have the authority to Edit details.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            

        })).catch($A.getCallback(function(error){
             alert('An error occurred : ' + error.message);
        }));
    },
    
    //this function will clear all entered values of input fields on Change of Name Change Reason field Value
	selectedNamechange : function(component, event, helper) {
        var select = component.find("mySelect");
        var nav =	select.get("v.value");
        var action = component.get("c.getRecordType");
        action.setParams({
            "nameChangeReason":component.find("mySelect").get("v.value")
        	});
        var p = helper.executeAction(component, action);
        // use the promise to do something 	
        p.then($A.getCallback(function(result){
            console.log('--- Contact result '+JSON.stringify(result))
            if(nav == $A.get("$Label.c.ContactLastName")){
               	component.set("v.recordTypeId", result);
                helper.handleDisable(component,true,false,true,true,true);
                helper.clearValues(component,'','','','',component.find("ClearMiddleName").set("v.checked",false));
            }
            else if(nav == $A.get("$Label.c.ContactFirstAndMiddleName")){
                component.set("v.recordTypeId", result);
				helper.handleDisable(component,true,true,false,false,false);
                helper.clearValues(component,'','','','',component.find("ClearMiddleName").set("v.checked",false));
            } 
			else if(nav == $A.get("$Label.c.Name_Marriage_or_Divorce")){
				component.set("v.recordTypeId", result);
				helper.handleDisable(component,false,false,true,true,true);
				helper.clearValues(component,'','','','',component.find("ClearMiddleName").set("v.checked",false));
			}
			else if(nav == $A.get("$Label.c.Name_Gender_Reassignment")){
				component.set("v.recordTypeId", result);
				helper.handleDisable(component,false,true,false,false,false);
				helper.clearValues(component,'','','','',component.find("ClearMiddleName").set("v.checked",false));
			}
			else if(nav == ''){
				helper.handleDisable(component,true,true,true,true,true);
				helper.clearValues(component,'','','','',component.find("ClearMiddleName").set("v.checked",false));
			}
			else {
				component.set("v.recordTypeId", result);
				helper.handleDisable(component,false,false,false,false,false);
				helper.clearValues(component,'','','','',component.find("ClearMiddleName").set("v.checked",false));
			}
        })).catch($A.getCallback(function(error){
            // Something went wrong
            alert('An error occurred : ' + error.message);
        }));     
    },
    //To handle Record Submission
    handleOnSubmit : function(component, event, helper){
        event.preventDefault();
        helper.submitRecord(component, event, helper);
    },
    //To Handle Error on Submission
    handleError: function(component, event, helper){
        helper.showToast('Error', 'error', $A.get("$Label.c.ContactUpdateError"));
        
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
		// make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
	},
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})