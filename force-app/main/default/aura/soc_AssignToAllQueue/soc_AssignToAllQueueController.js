({
	doInit : function(component, event, helper) { 
        helper.initialize(component, event, helper);
	},
        
    assignToQueue : function(component, event, helper) {
        component.set('v.showSpinner',true);
        var queueName=event.getSource().get("v.name");
        var recId=component.get('v.recordId');
        var action = component.get("c.assignCase");
        action.setParams({ caseId : recId,queueDeveloperName:queueName});
        action.setCallback(this, function(response) {
            component.set('v.showSpinner',false);
        	var state = response.getState();
            if (state === "SUCCESS") {
                console.log('##########AssigntoAllQueueResponse###########');
                console.log(response.getReturnValue());
                var data=response.getReturnValue();
                var result=data['status'];
                if (data['status'] == 'pass'){
                   	//window.location.reload( );
                   	$A.get('e.force:refreshView').fire();
                	helper.showSuccessToast(component, event, helper);                    
                }
                else if (data['status'] == 'fail')  {
                    var msg=data['response'];
                    var errorMsg="FIELD_CUSTOM_VALIDATION_EXCEPTION";
                    var n = msg.indexOf("FIELD_CUSTOM_VALIDATION_EXCEPTION");
                    var res = msg.slice(n+errorMsg.length+1);
                    var finalMsg = res.substring(0, res.length - 4);
                    console.log('res...');
                    console.log(res);               
                    helper.showErrorToast(component, event, helper,finalMsg);                    
                }      
            }    
        });        
        $A.enqueueAction(action);
	},
    
    openModel: function(component, event, helper) {
      helper.fetchClonedCaseRecord(component, event, helper);
   },
 
   closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   }
})