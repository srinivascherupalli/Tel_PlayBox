({
	addDelay : function(component, event, helper){
		window.setTimeout(
			$A.getCallback(function() {
				if(component.isValid()){
					var toastDiv= component.find('toastDiv');
					$A.util.removeClass(toastDiv, "slds-show");
					$A.util.addClass(toastDiv, "slds-hide");
				}
				else{
					console.log('Component is Invalid');
				}
			}), 6000 //EDGE-147513 added by shubhi
		);
	},
	
	closeToast : function(component){
		/*console.log('Inside closeToast after delay: '+ component);
		var toastDiv= component.find('toastDiv');
		$A.util.removeClass(toastDiv, "slds-show");
		$A.util.addClass(toastDiv, "slds-hide");*/
        if(component.get("v.isOKActive")){
            console.log('active');
            var toastDiv= component.find('toastDiv');
            $A.util.removeClass(toastDiv, "slds-show");
            $A.util.addClass(toastDiv, "slds-hide");
            var compEvent = component.getEvent("sampleComponentEvent"); 
        	compEvent.fire();
        }
        else{
            var toastDiv= component.find('toastDiv');
            $A.util.removeClass(toastDiv, "slds-show");
            $A.util.addClass(toastDiv, "slds-hide");
        }
	}
})