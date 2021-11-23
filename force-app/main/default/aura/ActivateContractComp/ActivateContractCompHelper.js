({
	showError  : function(component, event, helper,titlemsg,mssg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : titlemsg,
            message:mssg,
            duration:' 5000',
            key: 'info_alt',
            type: titlemsg,
            mode: 'pester'
        });
        toastEvent.fire();
    }, 
    fetchDetails : function(component, event, helper) {
    
     var action = component.get("c.getContractStatus");
             
            action.setParams({ conJunId : component.get("v.recordId")});
           
            action.setCallback(this, function(response) {
               
                var state = response.getState();
                if(state === "SUCCESS")
                {
                    var result= response.getReturnValue();
                    console.log(response.getReturnValue()); 
                    if(result.Restrict_Conga_Flow__c == true){
                        component.set("v.restrictConga",'Yes');
                    }
                     if(result.isTransitionContract__c == true){
                        component.set("v.Transitioncheck",'Yes');
                        // alert(component.get("v.Transitioncheck"));
                    }
                    
                    component.set("v.status",result.Status__c);
                    console.log('restrict val : '+component.get("v.restrictConga") );
                    console.log('status val : '+component.get("v.status") );
                     console.log('Transitioncheck val : '+component.get("v.Transitioncheck") );
                    
                }
                
            });
            $A.enqueueAction(action);
    }
})