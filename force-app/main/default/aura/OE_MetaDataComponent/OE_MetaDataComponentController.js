({
    doInit : function(component, event, helper) {
    },
    handleCloseSignal: function(component, event) {
        console.log("handleCloseSignal from OE_MetaDataComponent");
        var oeCloseEvent = $A.get("e.c:OE_CloseEvent");
        oeCloseEvent.setParam("data", "close");
        oeCloseEvent.fire();

        // window.parent.postMessage('closeModals', '*');
        // let closeSignalEvent = $A.get("closesignal");
        // closeSignalEvent.setParams({ 'data': 'close' });
        // closeSignalEvent.fire();
    },
})