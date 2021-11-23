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
                	if(result.Applicant_owned_whole_partly_by_a_govt__c=='Yes'){
                        component.set("v.pickyesno",true);    
                    }
                    if(result.Currently_employed_by_govt_political_par__c=='Yes'){
                        component.set("v.Investyesno",true);    
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
        // Print out the selected value
         var changeValue = event.getParam("value");
        //alert("selected"+selected);
        if(event.getSource().getLocalId()=='ownedId'){
            if(changeValue=="Yes")
            {
             //   alert("selectted yes");
                component.set("v.pickyesno", true);  
                //var selecval=component.find("pickyesno").get("v.value");
            }
            else
            {
                component.set("v.pickyesno", false);  
            }
        }
        if(event.getSource().getLocalId()=='currentEmploy'){
            if(changeValue=="Yes")
            {
                // alert("selectted yes");
                component.set("v.Investyesno", true);  
                //var selecval=component.find("pickyesno").get("v.value");
            }
            else
            {
                component.set("v.Investyesno", false);  
            }
        }
    },
    
    onSelectChangeinvs : function(component, event, helper) 
    	{
        // Print out the selected value
        var selected = event.getParam("value");
       // console.log('@@@@@@@: ' + selected);
        
        if(selected=="Yes")
        {
         	// alert("selectted yes");
            component.set("v.Investyesno", true);  
          	//var selecval=component.find("pickyesno").get("v.value");
        	// alert("selecval"+selecval);
        }
        else
        {
            component.set("v.Investyesno", false);  
        }
        
    },
    handleSaveRecord: function(component, event, helper) {
        //helper.setBooleanValues(component,event);
        component.find("ApplicantGovtdetails").saveRecord($A.getCallback(function(saveResult) {
            
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
    
    navigateToMyComponent : function(component, event, helper) 
    {
        //helper.setBooleanValues(component,event);
	   	helper.validateForm(component, event, helper);
    },
    
})