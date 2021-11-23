({
    openViewAllLinkedCasesComponent : function(component, event) {
        var workspaceAPI = component.find("workspace");
        var navService = component.find("navService");
        var recTempId = component.get("v.recordId");
        let _this = this;


        var pf = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__Salesup_ViewAllLinkedCases'
            },
            state: {
                "c__recordId": recTempId,
                "c__assignOption": btoa(component.get("v.assignOption"))
            }
        };  

        workspaceAPI.isConsoleNavigation().then(function(response) {
            if(response == true){
                _this.openWithinServiceConsole(workspaceAPI, pf);
            }else{
                navService.generateUrl(pf)
                .then($A.getCallback(function(url) {
                    window.open(url, "_blank");
                }), $A.getCallback(function(error) {
                    console.log(error);
                }));
            }
        });
    },

    openWithinServiceConsole : function(workspaceAPI, pf){
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: pf,
                focus: true
            }).then(function(subtabId) {
                workspaceAPI.setTabLabel({
                    tabId:subtabId,
                    label:"Linked Cases"
                });
                workspaceAPI.setTabIcon({
                    tabId: subtabId,
                    icon: "utility:case",
                    iconAlt: "Linked Cases" 
                });
                console.log("The new subtab ID is:" + subtabId);
            }).catch(function(error) {
                console.log("error");
            });
        });
    }
})