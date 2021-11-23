({
	removeClass : function(component, event, helper) {
        var allTabs = document.querySelectorAll('.selected-tab-background-color');
        if(allTabs.length > 0)
        {
            allTabs[0].classList.remove('selected-tab-background-color','blue-text-tab');
            allTabs[0].classList.add('tab-background-color');
        }
	},
    addClass : function(component, event, helper) {
		event.currentTarget.classList.add('selected-tab-background-color','blue-text-tab');
        event.currentTarget.classList.remove('tab-background-color');
	},
    
})