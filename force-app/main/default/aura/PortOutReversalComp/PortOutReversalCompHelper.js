({
    handleClosePopup : function(component,event) {
        console.log('in handleClosePopup');
        window.setTimeout(
            $A.getCallback(function() {
                window.parent.postMessage("close", "*");
                sessionStorage.setItem("close", "close");
            }),
            1000
        );
       return;
    },
    showToast : function(component,event) {
        console.log('in custom toast');
        $A.createComponent(
            "c:customToast",
            {
                type: type,
                message: message,
                title: title
            },
            function(customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");                    
                    body.set("v.body", customComp);
                }
            }
        );
    }
})