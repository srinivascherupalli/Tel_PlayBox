/*-------------------------------------------------------- 
//EDGE -66472/84934/66471
Description: Schedule/Reshceulde/Rebook Reserve  
Author:Ila/Mahima/Kalashree
--------------------------------------------------------*/
({
    myAction : function(component, event, helper) {
        
    },
    doInit: function (component, event, helper){
        helper.doInit(component, event);
    },
    handleShowSlots: function(component, event, helper)
    {
        helper.handleShowSlots(component, event);
    },
    handleEvent : function(component, event, helper) {
        helper.handleEvent (component, event, helper); 
    },
    doCloseOperation: function(component, event, helper){
        helper.doCloseOperation(component, event);       
    },
    onConfirmComplete:function(component, event, helper)
    {
        helper.onConfirmComplete(component, event, helper)
    },
    onSelection:function(component, event, helper){
        helper.onSelection(component, event);
    },
    onReasonChange:function(component, event, helper){
        helper.onReasonChange(component, event);
    },
    handleConfirmAppt: function(component, event,helper){
        helper.handleConfirmAppt(component, event);
    }
})