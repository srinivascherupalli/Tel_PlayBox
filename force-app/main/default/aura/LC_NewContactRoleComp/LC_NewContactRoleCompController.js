({
	doInit : function(component, event, helper) {
        
    	var recId=component.get('v.recordId');
        
       console.log('seltedrolerecId',recId);
        
        var action = component.get("c.getOpptydetails");        
        action.setParams({ "opptyconroleId": component.get("v.recordId")});
        action.setCallback(this, function(response){            
        	var state = response.getState();
            if (state === "SUCCESS") {  
                var data=response.getReturnValue(); 
                console.log('doInit -- Opptyconrole');
                console.log('doInit -- Opptyconroledata',data);
                component.set('v.Opptyconrole',data);
                var Opptyconroleconsle=data.Role;
                component.set('v.CustomerAccountId',data.AccountId);
                     } 
            else if (state === "ERROR") 
            { 
               var errors = response.getError();
                        if (errors) {
                                if (errors[0] && errors[0].message) 
                                {
                                    
                                    this.showToast(component,event,addressType,errors[0].message,'error'); 
                                    console.log('error',errors[0]);
                                    console.log('errorType',errors[0].message);
                                }
                    }
            }
            
        });        
        $A.enqueueAction(action);
        
		helper.initialize(component, event, helper);
	},
    //handle Industry Picklist Selection
    handleOnChange : function(component, event, helper) {
        var seltedrole = component.get("v.roleValue");
        component.set("v.selected",seltedrole); 
        component.set("v.roleValue",seltedrole); 
        // component.set("v.Opptyconrole.Role",seltedrole); 
        console.log('variable roleValue'+component.get("v.roleValue")); 


    },
     handleComponentEvent : function(component, event, helper) {
    	// get the selected Account record from the COMPONETN event 	 
       	var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        
		console.log('selectedAccountGetFromEvent');
       	console.log(selectedAccountGetFromEvent);
	   //	component.set("v.selectedRecord" , selectedAccountGetFromEvent);
       	component.set("v.CustomerContactId" , selectedAccountGetFromEvent.Id);
         
         console.log('selectedAccountGetFromEvent' , selectedAccountGetFromEvent);
         console.log('CustomerContactId', selectedAccountGetFromEvent.Id);
         console.log('opptyId', component.get("v.recordId"));
         
         var action = component.get("c.getOpptyrolefromcontactoppty");
         action.setParams({"opptyId": component.get("v.recordId"),
                          "contactId": component.get("v.CustomerContactId")});
            action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                 var data=response.getReturnValue(); 
                 console.log('doInit -- Opptyconroledata',data.Role);
                
                if(data.Role!=null)
                {
                    component.set('v.selectedValue',data.Role);
                	//component.set('v.isPrimaryflagval',data.IsPrimary);
                    console.log('Role true',data.Role);
                 	component.set('v.Showmsgroleexists',true);    
                }
                else
                {
                    console.log('Role else',data.Role);
                  component.set('v.Showmsgroleexists',false); 
                }
                
        	    var Opptyconroleconsle=data.Role;
                //var data="";
               } 
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
            }
        });
        $A.enqueueAction(action);   
         
     },
      onCheck: function(cmp, evt) {
		 var checkCmp = cmp.find("checkbox");
		 console.log('checked value'+checkCmp.get("v.value"));
		 checkCmp.set("v.isPrimaryflagval", checkCmp.get("v.value"));

	 },
    handleSave : function(component, event, helper) {
         console.log('Inside save');
        var action = component.get("c.createOpptyContactRole");    
        // var Id=component.get("v.recordId");
        var Primaryflagval=component.get("v.isPrimaryflagval");
        var CustomerContactId=component.get("v.CustomerContactId");
        
        console.log('CustomerContactId',CustomerContactId);
        var recId=component.get('v.recordId');
        console.log('opptyconroleId'+recId);
        var changedRoleval=component.get("v.roleValue");
        console.log('changedRoleval'+changedRoleval);
        action.setParams({ "opptyconroleId": recId,
                       "changedRole": changedRoleval,"primaryflag":component.get("v.isPrimaryflagval"),
                       "CustContactId":CustomerContactId} );
        action.setCallback(this, function(response){            
        	var state = response.getState();
            if (state === "SUCCESS") {  
             console.log("Record saved successfully");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record saved successfully.",
                    "type":"success"

                });
                toastEvent.fire();
                window.location.reload();
                // component.set("v.showModal", false);
          }  
        });        
      
        
         		
                     
              
          $A.enqueueAction(action);
        $A.enqueueAction(action2);	
     
	},
    handleSaveRecord: function(component, event, helper) {
        //helper.setBooleanValues(component,event);
        console.log("In handleSaveRecord.");
      
       component.find("forceRecordContactRole").saveRecord($A.getCallback(function(saveResult) {
	
           console.log("savestate"+saveResult.state);
           
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type":"success"

                });
                toastEvent.fire();

            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' +
                           JSON.stringify(saveResult.error));
                component.set("v.recordError",JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }
       
        ));
    }
})