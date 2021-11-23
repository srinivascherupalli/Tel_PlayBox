({
    openModel: function(component, event, helper) {
        component.set("v.GBBErrorComp", true);
    },
  
    closeModel: function(component, event, helper) {
       component.set("v.GBBErrorComp", false);
    }
 })