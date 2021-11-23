({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);                  
    },
    doCloseOperation : function(component, event, helper) {
        helper.doCloseOperation(component, event, helper);        
    },
    searchAddressOpen : function (component, event, helper) {       
        helper.searchAddressOpen(component, event, helper); 
    },
    handleBubbling : function (component, event, helper) {       
        helper.handleBubbling(component, event, helper); 
    },
    searchedCompletedAction : function (component, event, helper) {       
        helper.searchedCompletedAction(component, event, helper); 
    },
    getAddressTypes : function (component, event, helper) {
        helper.getAddressTypes(component, event, helper);
    },
    saveAccount : function (component, event, helper) {       
        helper.saveAccount(component, event, helper); 
    },
    isAddressAvailable : function(component, event, helper){
        console.log('In isAddressAvailable');
        var addressType = component.find("addressType").get("v.value");
        if(addressType){
            helper.isAddressTypeAvailable(component,event,helper);
        }
    }
})