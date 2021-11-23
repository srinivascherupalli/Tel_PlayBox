({
   
	 doInit: function(component,event,helper) {
    	
         
         var action=component.get("c.getData");
        console.log('--- rec id'+component.get("v.recordId"));
        action.setParams({"fieldSetname":component.get("v.FieldsetName"),
                          "recordid":component.get("v.recordId")
                          });
        var p = helper.executeAction(component, action);
             
            // use the promise to do something 
            p.then($A.getCallback(function(result){
                console.log(result);
                component.set("v.queAndAns",result);
                if(component.get("v.recordId")!=null && component.get("v.recordId")!='undefined'){
                var action1=component.get("c.getApplication");
        		action1.setParams({"fieldSetname":component.get("v.FieldsetName"),
                          "recId":component.get("v.recordId")
                          });
                var Promise1=helper.executeAction(component, action1);
            	return Promise1;
               }
                
            })).then($A.getCallback(function(result){
                if(null!=result){
                	if(result.Civil_criminal_litigation_charges__c=='Yes'){
                        component.set("v.litigationBoolean",true);    
                    }
                    if(result.On_a_govt_or_sanctioned_party_watchlist__c=='Yes'){
                        component.set("v.onaBoolean",true);    
                    }
                    if(result.Suspended_ineligible_for_govt_contract__c=='Yes'){
                        component.set("v.susBoolean",true);    
                    }
                    if(result.Pending_government_investigations__c=='Yes'){
                        component.set("v.InvestBoolean",true);    
                    }
                    if(result.Violated_rules_govening_bus_practices__c=='Yes'){
                        component.set("v.InvestagationBoolean",true);    
                    }
                }
            })).catch(
        $A.getCallback(function(error){
            // Something went wrong
            alert('An error occurred : ' + error.message);
        })
     );
    
    },
          
    
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
       // alert(changeValue);
    },
    onSelectChange : function(component, event, helper) {
        if(event.getSource().getLocalId()=='criminal'){    
        	helper.setBooleanForLitigation(component, event);    
        }
        if(event.getSource().getLocalId()=='Investigation'){    
        	helper.setBooleanForInvestigation(component, event);    
        }
        if(event.getSource().getLocalId()=='Governing'){    
        	helper.setBooleanForInvestigationQue1(component, event);    
        }
        if(event.getSource().getLocalId()=='WatchLst'){    
        	helper.setBooleanForInvestigationQue2(component, event);    
        }
        if(event.getSource().getLocalId()=='suspension'){    
        	helper.setBooleanForInvestigationQue3(component, event);    
        }
        
    },
    
    
    handleSaveRecord: function(component, event, helper) {
        //helper.setBooleanValues(component,event);
       component.find("ApplicantThird").saveRecord($A.getCallback(function(saveResult) {
            
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
        }));
    },
    
    navigateToMyComponent : function(component, event, helper) {
        //helper.setBooleanValues(component,event);
       // alert("navigateToMyComponent");
   		helper.validateForm(component, event, helper);
    },
    
})