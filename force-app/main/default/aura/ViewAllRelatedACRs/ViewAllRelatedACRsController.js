/****************************************************************************
@Name: ViewRelatedACR
@Author: Sri Chittoori(Team SFO)
@CreateDate: 29/05/2019
@Description: Sprint 19.07 , EDGE-85148
*******************************************************************************/
({
    navToRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.target.id
        });
        navEvt.fire();		
    },
})