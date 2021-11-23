({
    doInitHandler : function(component, event, helper) {
      //  alert('*******'+component.get("v.ContractRecord"));
        component.set("v.loadingSpinner", true);
        var record_Id = component.get("v.recordId");
        var action = component.get("c.recordDetails");
        action.setParams({
            "recordId": record_Id,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();  
            if(component.isValid() && state === "SUCCESS") {
                
                //   alert(JSON.stringify(response.getReturnValue()));
                component.set('v.ContractRecord', response.getReturnValue());
                component.set("v.loadingSpinner", false);
                
            }
            else if(state === "ERROR"){
                helper.showError(component, event, helper);
            }
        });
        $A.enqueueAction(action);
        var items = [];
        var item1 = {
            "label": "Customer initiated change",
            "value": "Customer initiated change",
        };
        var item2 = {
            "label": "Contract content in error",
            "value": "Contract content in error",
        };
        var item3 = {
            "label": " Send to incorrect recipient",
            "value": " Send to incorrect recipient",
        };
        var item4 = {
            "label": "Change in offer conditions",
            "value": "Change in offer conditions",
        };
        var item5 = {
            "label": "Other (text)",
            "value": "Other (text)",
        };
        
        items.push(item1);
        items.push(item2);
        items.push(item3);
        items.push(item4);
        items.push(item5);
        component.set("v.options", items);
        component.set("v.loadingSpinner", false);

		 var actionPRM = component.get("c.userInfoPRM");
        actionPRM.setCallback(this, function(response) {
            var state = response.getState();  
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.isPRMUser", response.getReturnValue());
                }
            }
            else if(state === "ERROR"){            
            }
        });
        $A.enqueueAction(actionPRM);
		
				var actionOrgDetails = component.get("c.organizationInfo");
        actionOrgDetails.setCallback(this, function(response) {
            var state = response.getState();  
            //  alert(JSON.stringify(response.getReturnValue()) +'______'+response.getState());
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.OrgDetails", response.getReturnValue());
                }
            }
            else if(state === "ERROR"){
            }
        });
        $A.enqueueAction(actionOrgDetails);
    },
    cancelClickHandler : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },    
    handleRetractClickHandler : function(component, event, helper) {
        component.set("v.loadingSpinner", true);
        // alert(component.find("RetractionReason").get("v.value"));
        var record_Id = component.get("v.recordId");
        var retractReason = component.find("RetractionReason").get("v.value");
        var isValidated = this.validateSelectedRecordHandler(component, event, helper, retractReason, record_Id);
        var otherText = '';
      //  var isValidated = this.validateSelectedRecordHandler(component, event, helper, retractReason, record_Id);
        if(isValidated == true){
            if(retractReason.includes("Other") && retractReason.includes("text")){
                otherText = component.find("otherText").get("v.value");
            }
            var action = component.get("c.updateRecord");
            action.setParams({
                "recordId": record_Id,
                "retractReason": retractReason,
                "Othertext": otherText,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();  
                if(component.isValid() && state === "SUCCESS") {  
                    if(response.getReturnValue() == true){
                      /*  this.showNotificationHandler(component, event, helper);
                        var eUrl= $A.get("e.force:navigateToURL");
                        eUrl.setParams({
                            "url": '/'+record_Id 
                        });
                        eUrl.fire(); */
						
						  if(component.get("v.isPRMUser") == true){
                            if(component.get("v.OrgDetails") == 'Sandbox')
                                window.location.href = "/partners/s/contractjunction/"+record_Id+"/view";
                            else{
                                window.location.href = "/s/contractjunction/"+record_Id+"/view";    
                            }
                        }
                        else{
                            window.location.href='/'+record_Id; 
                        }
						
                        
                    }
                    component.set("v.loadingSpinner", false);
                }
                else if(state === "ERROR"){
                    
                }
            });  
            $A.enqueueAction(action);
        }
    },
    validateSelectedRecordHandler : function(component, event, helper, retractReason, record_Id) {
        if(retractReason == '' || retractReason == undefined){
            component.set("v.errorMsg","Reasons for retraction cannot be blank");
            component.set("v.loadingSpinner", false);
            helper.showError(component, event, helper);
            return false;
        }
        else{
            if(retractReason.includes("Other") && retractReason.includes("text")){
                var otherText = component.find("otherText").get("v.value");
                if(otherText == '' || otherText == undefined){
                    component.set("v.errorMsg","Other text cannot be blank");
                    component.set("v.loadingSpinner", false);
                    helper.showError(component, event, helper);
                    return false;
                }
                else{
                  // component.set("v.loadingSpinner", false); 
                }
                
            }
        }
        return true;
    },
    
    showNotificationHandler : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : "Success",
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    showError  : function(component, event, helper) {
        var toggleText = component.find("errorMsgId");
        $A.util.removeClass(toggleText,'toggle');
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("errorMsgId"),'toggle'); 
            }), 5000
        );
    },
    toggle : function(component, event, helper) {
        var toggleText = component.find("errorMsgId");
        $A.util.toggleClass(toggleText, "toggle");
    },
    handleChangeHandler : function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue.includes("Other") && selectedOptionValue.includes("text")){
            component.set("v.isDisable", true);
        }
        else{
            component.set("v.isDisable", false);
        } 
    }
})