({
	handleClickedTab : function(component, event, helper) {
        console.log(component.get("v.selectedtabId"));
        var cmpEvent = component.getEvent("NumberReservevt");
        cmpEvent.setParams({
            "selectedTabId" : component.get("v.selectedtabId"),
            "clickedAction" : "tabClicked"
        });
        cmpEvent.fire();
	},
    handleFinished : function(component, event, helper) {
        console.log('Inside ');
        var cmpEvent = component.getEvent("NumberFinish");
        cmpEvent.fire();
	},
    closeMainPopup : function (component){
         window.setTimeout(
             $A.getCallback(function() {
                 window.parent.postMessage("close", "*");
                 sessionStorage.setItem("close", "close");
             }),
             1000
         );
        return;
    }
})