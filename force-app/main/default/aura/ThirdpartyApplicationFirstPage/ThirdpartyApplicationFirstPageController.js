({
	 doInit: function(component,event,helper) {
    	 var action=component.get("c.getQuestion");
        		action.setParams({"fieldSetname":component.get("v.FieldsetName"),
                          });
            var p = helper.executeAction(component, action); 
            
            p.then($A.getCallback(function(result){
                console.log(result);
                 component.set("v.queAndAns",result);
                
            })).catch($A.getCallback(function(error){
            // Something went wrong
            alert('An error occurred : ' + error.message);
        	})) 
         
         console.log('rec id'+component.get("v.recordId"));
         console.log('check 12');
        /* if(component.get("v.recordId")==null || component.get("v.recordId")=='undefined'){
         	component.find("ApplicantDetails").getNewRecord(
            "Application__c", // sObject type (objectApiName)
            "0122N0000004KRSQA2",      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.appDetailsSimple");
                var error = component.get("v.recordError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
               console.log("Record template initialized: " + rec.sobjectType);
            })
        );
          
            
            
            
         }*/
         
        
    },
            
    myAction : function(component, event, helper) {
		
	},
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        alert(changeValue);
    },
    handleSaveRecord: function(component, event, helper) {
    	helper.handleUpdateRecord(component,event);
    	
    },
    
    
   navigateToMyComponent : function(component, event, helper) {
       helper.validateForm(component,event,helper);
        // Get the component event by using the
        // name value from aura:registerEvent
        
    },
    
})