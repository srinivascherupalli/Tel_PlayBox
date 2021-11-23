({
	initialize : function(component, event, helper) {
        //var recId=component.get('v.recordId');
        var action = component.get("c.picklist_values");        
        action.setParams({ object_name : 'Case',field_name : 'soc_Support_Category_WO__c'});
        action.setCallback(this, function(response){            
        	var state = response.getState();
            if (state === "SUCCESS") {  
                var data=response.getReturnValue(); 
                console.log('doInit -- sfd_CreateSOCRequestController --PICKLIST  RESPONSE');
                console.log(data);
                component.set('v.options',data)
            }    
        });        
        $A.enqueueAction(action);
		
	},
    
    save : function(component, event, helper) {
        debugger;
        //P2OB-9178 : Enable spinner for wait-time 
        component.set("v.spinner",true);
        console.log('spinner on');
        var supportCategory=component.find("colorId").get("v.value");
        var description=component.find("description").get("v.value");
        var recId=component.get('v.oppId');
        var action = component.get("c.createSOCSupportRequest");        
        action.setParams({ oppId : recId,category:supportCategory,description:description});
        action.setCallback(this, function(response){            
        	var state = response.getState();
            //P2OB-9178 : Disable spinner 
            component.set("v.spinner",false);
            if (state === "SUCCESS") {
                helper.closeModal(component, event, helper);
                helper.showSuccessToast(component, event, helper); 

                var data=response.getReturnValue(); 
                $A.get('e.force:refreshView').fire();
                console.log('doInit -- sfd_CreateSOCRequestController --SAVE  RESPONSE');
                console.log(data);
            }    
        });        
        $A.enqueueAction(action);
		
	},
    
    validate : function(component, event, helper) {
        var supportCategory=component.find("colorId").get("v.value");
        var description=component.find("description").get("v.value");
        var descriptionNull=$A.util.isUndefinedOrNull(description);
        var descriptionBlank=description==''? true: false;
        var categoryNull=supportCategory=='none'? true: false;
        
        if(descriptionNull || descriptionBlank){
                $A.util.addClass(component.find("description"), "slds-has-error");
            }
            else{
                $A.util.removeClass(component.find("description"), "slds-has-error");
            }
             if(categoryNull){
                 $A.util.addClass(component.find("colorId"), "slds-has-error");
             }
            else{
                 $A.util.removeClass(component.find("colorId"), "slds-has-error");
    
            }
            return !descriptionNull && !descriptionBlank && !categoryNull;
        },
    
     closeModal : function(component, event, helper) {
     		$A.get("e.force:closeQuickAction").fire();
     },
    
    
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Case created",
            "type":'success',
            "message": "Case created successfully",
            "mode":"sticky"
        });
        toastEvent.fire();
    },
})