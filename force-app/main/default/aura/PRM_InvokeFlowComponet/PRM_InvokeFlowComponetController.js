({
    checkUser : function(component, event, helper) {
        helper.checkUser(component, event, helper);
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
})