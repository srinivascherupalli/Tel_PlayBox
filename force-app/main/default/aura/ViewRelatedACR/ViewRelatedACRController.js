/****************************************************************************
@Name: ViewRelatedACR
@Author: Sri Chittoori(Team SFO)
@CreateDate: 29/05/2019
@Description: Sprint 19.07 , EDGE-85148
*******************************************************************************/

({
    doInit : function(component, event, helper) {        
        helper.getAcrRecords(component, event, helper);        
    },

    
    handleEventFired : function(cmp, event, helper) {
        var evt = $A.get("e.force:refreshView");
        evt.fire();
        helper.getAcrRecords(cmp, event, helper);
    },

    handleViewAll : function(component, event, helper) {
        if($A.get("$Browser.isPhone")){
            helper.navigateToSameComponent(component, event, helper);
        }
        else{            
            helper.navigateToListComponent(component, event, helper);
        }        
    }
    
})