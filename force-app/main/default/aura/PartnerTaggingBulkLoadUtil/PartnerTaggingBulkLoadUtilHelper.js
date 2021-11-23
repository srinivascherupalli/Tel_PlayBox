({
	
     showToast: function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            mode: 'dismissible',
            type: type,
            message: message
        });
        toastEvent.fire();
    },

    
})