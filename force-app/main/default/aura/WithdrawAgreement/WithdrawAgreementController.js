({
	doInit : function(component, event, helper) {
        
        helper.checkstatus(component, event,helper);
		
	},
    saveRecord:function(component, event, helper){
    		var selectedPicklistValue= component.get("v.ltngSelectedvalue");
    		var accountId = component.get("v.recordId");
        var save_action = component.get("c.changestatus");
    	save_action.setParams({
            "accountIds": accountId,
    		"Reson":selectedPicklistValue
            
            });
        
        save_action.setCallback(this, function(response) {
            var status = response.getState();
          
            console.log("Hi i m here"+state);
            if(response.getState() === "SUCCESS") {
                console.log("status change to Withdraw");
            	}
        	});
     		 $A.enqueueAction(save_action);
        $A.get('e.force:refreshView').fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
         dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
           
               window.location.reload();
         
		},
    changetoPrevious :function(component, event, helper){
    
    var accountId = component.get("v.recordId");
        var save_action = component.get("c.changetoPreviousValue");
    	save_action.setParams({
            "accountIds": accountId,
            
            });
        debugger;
        save_action.setCallback(this, function(response) {
            var status = response.getState();
            debugger;
            console.log("Hi i m here"+state);
            if(response.getState() === "SUCCESS") {
                console.log("status change to Withdraw");
            	}
        	});
     		 $A.enqueueAction(save_action);
        $A.get('e.force:refreshView').fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
         dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
           
               window.location.reload();
}
    
})