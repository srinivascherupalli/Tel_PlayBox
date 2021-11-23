/*-------------------------------------------------------- 
//EDGE -66472/84934/66471
Description: Handle Schedule/Reshcedule/Rebook Search & Reserve 
Author:Ila/Mahima/Kalashree
--------------------------------------------------------*/

({
    doInit : function(component, event, helper) {
        helper.initOrder(component, event, helper);
        helper.fetchSubs(component, event, helper);
        helper.fetchReqApp(component, event, helper);
        helper.helperShowSaveProgressButton(component, event, helper);
    },
    handleSchedule: function(component, event, helper) {
               helper.handleSchedule(component, event);
    },
    handleReScheduleRebook:function(component, event, helper) {
               helper.handleReScheduleRebook(component, event);
    },
    searchedCompletedAction:function(component, event, helper){
        helper.searchedCompletedAction(component, event);
    },
    openPop : function(component, event, helper) {
        helper.openPop(component, event, helper);

},
     closePop : function(component, event, helper) {
      helper.closePop(component, event, helper);  
},
    saveProgress: function(component, event, helper) {
      helper.helperSaveProgress(component, helper);

},
    
})