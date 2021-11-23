({
	
    closeModalWindow : function(component) {
        //console.log('Close alert modal window!');
        //$A.get("e.force:closeQuickAction").fire();
        var modalDiv= component.find('MainDiv');
		$A.util.removeClass(modalDiv, "slds-show");
		$A.util.addClass(modalDiv, "slds-hide");
        //console.log('Modal window closed!');
    }
})