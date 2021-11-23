({
	doInit: function (component, event, helper) {
        //helper.showExampleModal(component);
        console.log('Inside doInit');
		component.set("v.showSpinner", true);
		var url = window.location.host;
		var accountId = component.get('v.accountId');
		var basketId = component.get('v.basketId');
        var solutionId = component.get('v.solutionId');
		var customAttribute = component.get('v.customAttribute');
        var accessMode= component.get('v.accessMode');
        //var priceItemId=component.get('v.priceItemId');
        var configId=component.get('v.configId');
        //console.log(url);
		//console.log('configId'+configId);
        component.set("v.vfHost",url);
        //console.log('VfHost ----->'+component.get('v.vfHost'));
    }
})