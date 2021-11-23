({
	closeModalWindow: function (component) {
		//$A.get("e.force:closeQuickAction").fire();
		var modalDiv = component.find('MainDiv');
		$A.util.removeClass(modalDiv, "slds-show");
		$A.util.addClass(modalDiv, "slds-hide");
		// console.log('Modal window closed!');
	},
	   
	redirectToBasket: function (component, opptyId) { // INC000094617257 Fix
        console.log('Inside redirectToBasket');
		/*var navigateEvent = $A.get("e.force:navigateToSObject");
		navigateEvent.setParams({
			"recordId": basketId,
			"slideDevName": "detail",
			"isredirect": "true"
		});

		navigateEvent.fire();*/
        ////EDGE-151654 navigationfix start added by shubhi
         var returnURL ='';
        if(component.get("v.site") != null && component.get("v.site")!='' && component.get("v.site")!=undefined){
            if(component.get("v.OrgDetails") == 'Sandbox')
                returnURL = "/partners/s/opportunity/"+opptyId+'/view'; // INC000094617257 Fix
            else{
                returnURL = "/s/opportunity/"+opptyId;    // INC000094617257 Fix
            }
        }
        else{
            returnURL = "/lightning/r/opportunity/"+opptyId+'/view';   // INC000094617257 Fix
        }
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": returnURL,
            "slideDevName": "detail"
        });
        navEvt.fire();
        
        ////EDGE-151654 navigationfix end 
	},
	//EDGE - 77981
	isCancelationNBN: function (component, event, helper) {
		var basketId = component.get('v.basketId');
		
		var action = component.get("c.isCancelationNBN");
		action.setParams({
			"basketId": basketId,
		});
		action.setCallback(this, function (response) {
			var cancelNBN = response.getReturnValue();
			component.set("v.showOnlyCancelNBN", cancelNBN);
			console.log('NBNFlag=='+component.get("v.showOnlyCancelNBN"));
		});
		$A.enqueueAction(action);
	}
})