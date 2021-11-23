({
	getMaterialGroups : function(planId, component){

        let action = component.get("c.getMaterialGroups");
        
		action.setParams({ commercialProdId: planId });
        
		action.setCallback(this, function (response) {
			let state = response.getState();
            
            if (state == "SUCCESS") {
				
				let responseVal = response.getReturnValue();
				
				if(responseVal.isSuccess){
					component.set("v.columnHeaders", Object.keys(responseVal.data));
					component.set("v.columnValues", Object.values(responseVal.data));
                    return;
				}
                
                component.set('v.errorMessage', responseVal.message);
                
            } else if (state === "ERROR") {
                
                let errors = action.getError();
                
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.errorMessage', errors[0].message);
                }else{
                    component.set('v.errorMessage', 
                                  'Oppo\'s something went wrong, contact to your admin or refresh the page');
                }
            }else{
                 component.set('v.errorMessage', 
                               'Oppo\'s something went wrong, contact to your admin or refresh the page');
            }
		});
        
        $A.enqueueAction(action);
	}
})