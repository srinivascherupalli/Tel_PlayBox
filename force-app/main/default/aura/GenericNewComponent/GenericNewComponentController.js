({  
    //Handler for init event
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    //Handler for onClick of lightning-button
    handleClick : function(component, event, helper) {
        helper.launchModal(component, event, helper);
    },
    //Handler for onClick of close button
    closeFlowModal : function(component, event, helper) {
        console.log('***GenericNewComponent:closeFlowModal:Closing parent component');
        component.set("v.isOpen", false);
        window.history.back();
    },
    //helper method to check which component is to be invoked
    parseURL : function(component, event, helper) {
        helper.parseURLhelper(component, event, helper);          
    },
   //helper method to check which component is to be invoked
    selectFlow : function(component, event, helper) {
        helper.selectFlowHelper(component, event, helper);          
    }, 
})