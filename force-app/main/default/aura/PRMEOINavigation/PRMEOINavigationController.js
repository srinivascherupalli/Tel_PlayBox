({
    step1 : function(component, event, helper) {
        helper.fireEvent('1');
		//_prmEOI.step1();
	}, step2 : function(component, event, helper) {
		//_prmEOI.step2();
		helper.fireEvent('2');
		component.set("v.currentStep","2");
	}, step3 : function(component, event, helper) {
		//_prmEOI.step3();
				helper.fireEvent('3');
                 component.set("v.currentStep","3");


	} ,step4 : function(component, event, helper) {
		//_prmEOI.step4();
				helper.fireEvent('4');
                 component.set("v.currentStep","4");


	}
})