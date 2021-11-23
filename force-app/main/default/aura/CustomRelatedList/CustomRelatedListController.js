/*
    ****************************************************************************
    @Name: CustomRelatedList
    @Author: Sri Chittoori(Team SFO)
    @CreateDate: 29/05/2019
    @Description: Sprint 19.07 , EDGE-85148 :: This component is to display the ACR record
    *******************************************************************************
*/
({
    navToRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.acr.Id")
        });
        navEvt.fire();		
    }
})