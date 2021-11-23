({
    
    doInit: function (component, event, helper){
        component.set("v.loadingSpinner", true);
        helper.fetchDevices(component, event);
        helper.getDeviceType(component,event);
        helper.doInit(component, event);   
        component.set("v.loadingSpinner", false);
    },
    
    onReset: function (component, event, helper){
        helper.onReset(component, event);
    },
    
    onChange: function (component, event, helper){
        helper.onChange(component, event);
    },
    
    checkQuantity : function (component, event, helper) {
        helper.checkQuantity(component, event);  
    },
    
    changeData:function(component, event, helper){
        helper.changeData(component, event);
    },
    
    handleSelectAllContact: function(component, event, helper) {
        helper.handleSelectAllContact(component, event);  
    },
   
    checkQuantityMultiple: function(component, event,helper){
        helper.checkQuantityMultiple(component, event);  
    },
   
    handledeSelectAllContact : function(component, event,helper){
        helper.handledeSelectAllContact(component, event);
    },
    
    handleSelectedProducts : function(component, event,helper){
        helper.handleSelectedProducts(component, event);
    },
    
})