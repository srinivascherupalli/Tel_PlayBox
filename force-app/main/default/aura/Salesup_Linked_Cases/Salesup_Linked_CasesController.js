({
    doInit : function(component, event, helper) {  
        
        var _action = component.get("c.fetchLinkedCases");
        _action.setParams({
            "recordId" : component.get("v.recordId")
        });

        _action.setCallback(this, function(res){
            if(res.getState()=='SUCCESS'){
                component.set('v.linkedCaseRecords', res.getReturnValue());
            }
        });
        $A.enqueueAction(_action);
    },

    viewAllLinkedCases : function(component,event,helper){
        helper.openViewAllLinkedCasesComponent(component, event);
    },

    handleSelect : function(component,event,helper){
        helper.openViewAllLinkedCasesComponent(component, event);
    },

    openCaseRecord : function(component,event,helper){
        
        var record_ID =  event.currentTarget.getAttribute("data-ID");
        var workspaceAPI = component.find("workspace"); 
        var navService = component.find("navService");

        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Case',
                recordId : event.currentTarget.getAttribute("data-ID") 
            },
        };

        workspaceAPI.isConsoleNavigation().then(function(response) {
            if(response == true){
                workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
                    workspaceAPI.openSubtab({
                        parentTabId: enclosingTabId,
                        pageReference: pageRef,
                        focus: true
                    }).catch(function(error) {
                        workspaceAPI.getAllTabInfo().then(function(response) {
                            workspaceAPI.focusTab({tabId : response[0].tabId})
                        })
                    });
                }); 
            }else{
                navService.generateUrl(pageRef)
                .then($A.getCallback(function(url) {
                    window.open(url, "_blank");
                }), $A.getCallback(function(error) {
                    console.log(error);
                }));
            }
        });
    }
})