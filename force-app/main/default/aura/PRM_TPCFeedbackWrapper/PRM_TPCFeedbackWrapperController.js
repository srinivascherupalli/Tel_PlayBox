({
    //Invoke flow
   invokeFlow: function(component, event, helper) {
       //component.set("v.showFeedbackCmp", "false");
		// DIGI-12086 : Hawaii updating createComponents to create new csGrantParentComponent
		var modalBody;
		$A.createComponents([
				["c:csGrandParent", {
					userType : 'PowerPartner'
				}]
			], //Create overlay Modal
			function(modalCmps, status, errorMessage) {
				if (status === "SUCCESS") {
					modalBody = modalCmps[0];
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: "slds-modal_small",
						closeCallback: function() {
							console.log('modal closed!');
							
						}
					});
				} else if (status === "ERROR") {
					console.log('ERROR: ', errorMessage);
				}
			}
		)
        component.find('feedbackCmp').closeModal();
	}
})