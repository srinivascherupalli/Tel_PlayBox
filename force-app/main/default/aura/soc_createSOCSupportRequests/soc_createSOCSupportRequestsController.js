({
	doInit : function(component, event, helper) {
		helper.initialize(component, event, helper);
	},
    
     closeModal : function(component, event, helper) {
     		helper.closeModal(component, event, helper);
     },
    
    validateAndSave : function(component, event, helper){
        var isValid=helper.validate(component, event, helper);        
        if(isValid){
            helper.save(component, event, helper);
            
        }
     }

})