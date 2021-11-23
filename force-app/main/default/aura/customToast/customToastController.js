({
	onInit : function(component, event, helper) {
		if(component.get('v.type').toLowerCase() === 'success'){
			$A.util.addClass(component.find('typeDiv'), 'slds-theme--success');
		}
		else if(component.get('v.type').toLowerCase() === 'warning'){
			$A.util.addClass(component.find('typeDiv'), 'slds-theme--warning');
		}
        else if(component.get('v.type').toLowerCase() === 'error'){
			$A.util.addClass(component.find('typeDiv'), 'slds-theme--error');
		}
        else if(component.get('v.type').toLowerCase() === 'info'){
			$A.util.addClass(component.find('typeDiv'), 'slds-theme--info');
		}
        if(component.get("v.isOKActive")==false){
            helper.addDelay(component, event, helper);
        }
		
	},
	
	closeToast : function(component, event, helper){
		helper.closeToast(component);
	},
})