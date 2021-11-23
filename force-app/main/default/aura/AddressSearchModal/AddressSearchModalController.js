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
   /* getSiteName : function (component, event, helper) {       
        helper.getSiteName(component, event, helper); 
    },*/
    saveContact : function (component, event, helper) {       
        helper.saveContact(component, event, helper); 
    },
    getConAddressTypes: function (component, event, helper) {
        helper.getContactAddressType(component, event, helper);
    },
    onChange : function(component, event, helper) {
        var addressType =component.find("addressType").get("v.value");
        if(addressType){
            helper.onChangeHelper(component, event, helper);
        }
    },
   
})