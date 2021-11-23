({
    showToast : function(type,message,dur,mode) {
        var toastEvent = $A.get("e.force:showToast");
        var messageFmtd = '';
        var messagesplt = message.split('|');
        for (var i = 0; i < messagesplt.length; i++) {            
            messageFmtd += messagesplt[i] + '\n';
        }
        console.log(messageFmtd);
        toastEvent.setParams({
            "message": messageFmtd,
            "type": type,
            "duration": dur,
            "mode": mode,
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})