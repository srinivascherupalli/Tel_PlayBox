({
    doInit: function (component, event, helper) {
		helper.getCSMDetails(component, event, helper);//EDGE-164004    
    },
    checkUser : function(component, event, helper) {
        helper.checkUser(component, event, helper);
    }, 
    createnewopportunity : function(component, event, helper) {
        helper.createnewopportunity(component, event, helper);//P2OB-13078
    }, 
    handleMenuSelect : function(component, event, helper){
        helper.handleMenuSelect(component, event, helper);
    },
    closeFlow : function(component, event, helper){
        console.log('closing quck action*****');
        $A.get("e.force:closeQuickAction").fire();
        window.location.reload();
        $A.get("e.force:refreshView").fire();
        
        
    },
   handlePOR : function(component, event, helper) {
        helper.handlePOR(component, event, helper);
    },    
     UpdateContactRole : function(component, event, helper) {
        helper.UpdateContactRole(component, event, helper);
    }, 
    
closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },

closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
        }
    }

})