/*-----------------------------------------------------------------------------------------------
Name : CheckInventoryHelper
Description : Lightning UI Helper for checking stock availability for mobile devices 
Author: Aishwarya Yeware
Story: EDGE-80858
---------------------------------------------------------------------------------*/
({
    
     doInit: function (component, event){
        
    },
    /*---------------------------------------------------------------------------------------
    Name : checkInventory
    Description : Method to check available stock in inventory for selected mobile device
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/
	checkInventory : function(component, event) {
         var myval=component.get("v.productId");
        
         component.set("v.loadingSpinner", true);
        var action = component.get("c.checkStock");
        action.setParams({"skuID" : myval});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var options = response.getReturnValue();
                component.set("v.loadingSpinner", false);
              var available=options.stockAvailable;
				if(available=='Check Failed.Please Retry'){
				 component.set("v.available",options.stockAvailable);
				}
				else{
                component.set("v.available",options.stockAvailable + ' Available');
				}
                if(options.restocked !=null){
                component.set("v.restocked",options.restocked);
                }
                else{
                    component.set("v.restocked",'');
                }
                    
                
            }
            
        });
        $A.enqueueAction(action); 
    },
    
    	
	
})