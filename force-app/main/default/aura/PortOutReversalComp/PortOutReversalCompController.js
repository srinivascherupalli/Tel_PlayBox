({
    handleClosePopup : function(component, event, helper) {
        console.log('basket in aura: ',component.get("v.basket_id"));
        helper.handleClosePopup(component,event);
    },
    showToast : function(component, event, helper) {
        helper.showToast(component,event);
    },
     handleCallVFEvent: function(component, event, helper) {
     // alert('VF event called' +event.getParam('recordsString'));
     // EDGE-174219
        var cmpEvent1 =  $A.get("e.c:updatePortOutattributes");
                                cmpEvent1.setParams({
                                    "updaterec" : event.getParam('recordsString')
                                });
                                cmpEvent1.fire();
       
    }
})