({
    validateCaseForm: function(component) {
        var validCase = true;

         // Show error messages if required fields are blank
        var allValid = component.find('caseField').reduce(function (validFields, inputCmp) {
            console.log('Error!!!!');
            console.log( inputCmp.showHelpMessageIfInvalid());
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
            console.log('allValid!!!!');
            // Verify we have an account to attach it to
            var opportunity = component.get("v.recordId");
            if($A.util.isEmpty(opportunity)) {
                validCase = false;
                console.log("Quick action context doesn't have a valid Opportunity.");
            }
        	return(validCase);
            
        }  
	}
       
})