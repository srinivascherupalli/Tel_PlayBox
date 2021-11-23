({
    goToSearchAddress : function (component, event, helper) {       
        helper.goToSearchAddress(component, event, helper); 
    },
    handleInputRecord : function (component, event, helper) {       
        helper.handleInputRecord(component, event, helper); 
    },
    saveAddress : function(component, event, helper) {
        helper.saveAddress(component, event, helper);
    },
    toggle : function(component, event, helper) {
        helper.toggle(component, event, helper);
    },
    closeModel : function(component, event, helper) {
        helper.closeModel(component, event, helper);
    },
    navigateToNewAddress: function(component, event, helper) {
        helper.navigateToNewAddress(component, event, helper);
    },
    /*------------------------------------------------------
     * EDGE-122625
     * Method:changeData
     * Description: Method to change data
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
      changeData:function(component, event, helper){
        helper.changeData(component, event);
    },
})