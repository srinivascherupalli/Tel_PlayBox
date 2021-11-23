({
	initialize : function(component, event, helper) {
      component.set('v.spinner',true);
        var recId=component.get('v.recordId');
        var action = component.get("c.initialize");        
        action.setParams({ caseId : recId});
        action.setCallback(this, function(response){            
        	var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner',false);
                var data=response.getReturnValue(); 
                var caseData=data['case'];
                var profileName=data['profileName'];
                var showAssignAllToMe = data['showAssignAllToMe'];
                var DSCUser = data['DSCUser'];
                console.log('######soc_AssignToAllQueue##########');
                console.log(data);
                if(DSCUser == 'true'){
                	component.set('v.DSCUser','true');    
                }
                console.log(caseData.soc_SFD_Offshore_Restricted__c);
                console.log(caseData.RecordType.DeveloperName);
                component.set('v.profileName',profileName);
                component.set('v.showAssignAllToMe',showAssignAllToMe);
                component.set('v.recordTypeDevName',caseData.RecordType.DeveloperName);
                component.set('v.offshoreRestricted',caseData.soc_SFD_Offshore_Restricted__c);
                
                }    
        });        
        $A.enqueueAction(action);
    },
    
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Case Assigned",
            "type":'success',
            "message": "All Child Cases assigned to Parent Owner successfully."
        });
        toastEvent.fire();
    },
    showErrorToast : function(component, event, helper,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',            
            message: 'Mandatory Fields: '+msg,
            type: 'error',
            mode:'sticky'
        });
        toastEvent.fire();
    }
})