/****************************************************************************
@Name: ViewRelatedACR
@Author: Sri Chittoori(Team SFO)
@CreateDate: 29/05/2019
@Description: Sprint 19.07 , EDGE-85148
*******************************************************************************/
({
	getAcrRecords : function(component, event, helper) {
        var action = component.get("c.viewACRs");
        action.setParams({
            recordId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var relatedACRs = response.getReturnValue();
            if (Boolean(relatedACRs)){                
                component.set("v.relatedACRs", (relatedACRs));
            }
        });
        $A.enqueueAction(action);
    },

    navigateToListComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ViewAllRelatedACRs",
            componentAttributes: {
                relatedACRs : component.get("v.relatedACRs"),
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();
    }, 

    navigateToSameComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        var relatedACRs = component.get("v.relatedACRs");
        evt.setParams({
            componentDef : "c:ViewRelatedACR",
            componentAttributes: {
                relatedACRs : component.get("v.relatedACRs"),
                recordId : component.get("v.recordId"),
                viewLimit : relatedACRs.length,
                viewVerRecom : true
            }
        });
        evt.fire();
    }, 
})